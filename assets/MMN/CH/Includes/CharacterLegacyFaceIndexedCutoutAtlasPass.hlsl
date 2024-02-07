#ifndef MMN_LEGACY_CHARACTER_FACE_INDEXEDCUTOUTATLAS_PASS_INCLUDED
#define MMN_LEGACY_CHARACTER_FACE_INDEXEDCUTOUTATLAS_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// #include "../Includes/BendingVertex.hlsl"

#include "Includes/CharacterLighting.hlsl"
#include "Includes/CharacterAtlas.hlsl"
#include "Includes/CharacterDye.hlsl"
#include "Includes/CharacterDithering.hlsl"
#include "Includes/CharacterApplyFx.hlsl"
#include "Includes/CharacterApplyFog.hlsl"
#include "Includes/CharacterDebugging.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    half3 normalOS : NORMAL;

    float2 texcoord : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;

    float2 texcoord : TEXCOORD0;

    float4 positionWS : TEXCOORD1;  // xyz: position, w: camera distance
    half3 normalWS : TEXCOORD2;     // xyz: normal
    half3 viewDirWS : TEXCOORD3;

    half4 fogCoord : TEXCOORD4;     // x: fogFactor, yzw: vertexLighting

    half4 positionNDC : TEXCOORD5;
};


//--------------------------------------
// CustomFunction
float2 rotateUV(in float2 uv, in float rotation)
{
    return float2(
        cos(rotation) * uv.x + sin(rotation) * uv.y,
        cos(rotation) * uv.y - sin(rotation) * uv.x
    );
}
//--------------------------------------

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    float2 uvOffset, uvScale;
    CalcUvOffsetScale_Legacy((half)_AtlasTextureColNum, (half)_AtlasTextureRowNum,
        (half)(_AtlasIndexFromOne - 1), uvOffset, uvScale);

    float aspectRatio = (float)_AtlasTextureRowNum / (float)_AtlasTextureColNum;
    float2 displacedTexcoord = input.texcoord - float2(0.5, 0.5);
    displacedTexcoord = displacedTexcoord + _PositionOffset;
    displacedTexcoord.x = displacedTexcoord.x * aspectRatio;
    displacedTexcoord = rotateUV(displacedTexcoord, _RotationOffset);
    displacedTexcoord.x = displacedTexcoord.x / aspectRatio;
    displacedTexcoord = displacedTexcoord + float2(0.5, 0.5);
    output.texcoord = TRANSFORM_TEX(displacedTexcoord, _IndexedCutoutAtlasTexture) * uvScale + uvOffset;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    output.normalWS = half3(normalInput.normalWS);
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = AdditionalLightsVertex(output.positionWS.xyz, output.normalWS);
        output.fogCoord = half4(fogFactor, vertexLight); //fogFactorAndVertexLight
    #else
        output.fogCoord = half4(fogFactor, 0.0, 0.0, 0.0);
    #endif

    output.positionNDC = ComputeScreenPos(output.positionCS);

    return output;
}

// 버텍스의 Normal을 그대로 사용하는 경우
void InitializeCharacterInputData(Varyings input, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS.xyz;

    inputData.viewDirectionWS = SafeNormalize(input.viewDirWS);

    inputData.normalWS.xyz = input.normalWS.xyz;

    inputData.shadowCoord = half4(0, 0, 0, 0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
        inputData.vertexLighting = input.fogCoord.yzw;
    #else
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
        inputData.vertexLighting = half3(0, 0, 0);
    #endif

    inputData.bakedGI = 1.0; //음영을 사용 안하도록

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = half4(1, 1, 1, 1);
}

half4 frag(Varyings input) : SV_Target
{
    half4 baseMap = SAMPLE_TEXTURE2D(_IndexedCutoutAtlasTexture, sampler_IndexedCutoutAtlasTexture, input.texcoord + _PositionOffset);
    half3 baseColor = baseMap.rgb;
    half alpha = baseMap.a * _Alpha;

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    //-----------------------------------------------------------------------------
    // 염색
    half3 dyedBaseColor = baseColor;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            ApplyDyeColor(dyedBaseColor.rgb, _DyeColor1);
        }
    #endif
    //-----------------------------------------------------------------------------

    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
    // Input data
    InputData inputData;
    InitializeCharacterInputData(input, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.texcoord.xy, _IndexedCutoutAtlasTexture);

    // Light
    Light mainLight;
    LightingData lightingData;
    InitializeLightData(inputData, mainLight, lightingData);

    // from script
    CharacterData characterData = InitializeCharacterData();

    //-----------------------------------------------------------------------------
    // Process Color
    //-----------------------------------------------------------------------------
    half4 resultColor;
    resultColor.rgb = ProcessCharacterColorSimple(inputData,
        mainLight, lightingData, characterData,
        dyedBaseColor);

    ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
    resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
    ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

    resultColor.a = alpha;

    #ifdef _THIEF_HIDE
        resultColor.a *= _EffectAlphaValue;
    #endif

    //-----------------------------------------------------------------------------
    // 디버그
    //-----------------------------------------------------------------------------
    #if defined(DEBUG_SHADING_OFF)
    {
        return half4(dyedBaseColor, resultColor.a);
    }
    #endif

    #if defined(DEBUG_DISPLAY)
    {
        return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, dyedBaseColor, alpha);
    }
    #endif
    //-----------------------------------------------------------------------------

    return resultColor;
}

#endif // MMN_LEGACY_CHARACTER_FACE_INDEXEDCUTOUTATLAS_PASS_INCLUDED
