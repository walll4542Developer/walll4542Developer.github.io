#ifndef MMN_LEGACY_CHARACTER_EYE_EMOTION_PASS_INCLUDED
#define MMN_LEGACY_CHARACTER_EYE_EMOTION_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

// #include "../Includes/BendingVertex.hlsl"

#include "Includes/CharacterLighting.hlsl"
#include "Includes/CharacterAtlas.hlsl"
#include "Includes/CharacterDye.hlsl"
#include "Includes/CharacterDithering.hlsl"
#include "Includes/CharacterApplyFx.hlsl"
#include "Includes/CharacterApplyFog.hlsl"
#include "Includes/CharacterApplyDissolve.hlsl"
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

    float4 positionNDC : TEXCOORD5;
    float3 positionOS : TEXCOORD6;
};


//--------------------------------------
// CustomFunction
float2 rotateUV(in float2 uv, in half rotation)
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

    output.texcoord = input.texcoord;

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
    float2 eyeballUvOffset, eyeballUvScale;
    CalcUvOffsetScale_Legacy((half)_EyeballTextureColNum, (half)_EyeballTextureRowNum,
        (half)(_EyeballIndexFromOne - 1), eyeballUvOffset, eyeballUvScale);

    float2 eyeballTexcoord;
    float2 clampedUVEyeball;
    float2 eyeballClipRect00 = TRANSFORM_TEX(float2(0.0, 0.0), _EyeballTexture) * eyeballUvScale + eyeballUvOffset;
    float2 eyeballClipRect51 = TRANSFORM_TEX(float2(0.5, 1.0), _EyeballTexture) * eyeballUvScale + eyeballUvOffset;
    float2 eyeballClipRect50 = TRANSFORM_TEX(float2(0.5, 0.0), _EyeballTexture) * eyeballUvScale + eyeballUvOffset;
    float2 eyeballClipRect11 = TRANSFORM_TEX(float2(1.0, 1.0), _EyeballTexture) * eyeballUvScale + eyeballUvOffset;

    // Left eye
    if (input.texcoord.x < 0.5)
    {
        float2 centeredTexcoord = input.texcoord - float2(0.25, 0.5);
        centeredTexcoord = centeredTexcoord - (_RightEyeball_TS.xy + float2(-_EyePositionOffset.x, _EyePositionOffset.y));
        centeredTexcoord = centeredTexcoord / _RightEyeball_TS.zw;
        centeredTexcoord.x = centeredTexcoord.x * 2.0;
        centeredTexcoord = rotateUV(centeredTexcoord, _EyeRotationOffset);
        centeredTexcoord.x = centeredTexcoord.x * 0.5;
        centeredTexcoord = centeredTexcoord + float2(0.25, 0.5);
        eyeballTexcoord = TRANSFORM_TEX(centeredTexcoord, _EyeballTexture) * eyeballUvScale + eyeballUvOffset;
        clampedUVEyeball = clamp(eyeballTexcoord, eyeballClipRect00, eyeballClipRect51);
    }
    // Right eye
    else
    {
        float2 centeredTexcoord = input.texcoord - float2(0.75, 0.5);
        centeredTexcoord = centeredTexcoord - (_LeftEyeball_TS.xy + _EyePositionOffset);
        centeredTexcoord = centeredTexcoord / _LeftEyeball_TS.zw;
        centeredTexcoord.x = centeredTexcoord.x * 2.0;
        centeredTexcoord = rotateUV(centeredTexcoord, -_EyeRotationOffset);
        centeredTexcoord.x = centeredTexcoord.x * 0.5;
        centeredTexcoord = centeredTexcoord + float2(0.75, 0.5);
        eyeballTexcoord = TRANSFORM_TEX(centeredTexcoord, _EyeballTexture) * eyeballUvScale + eyeballUvOffset;
        clampedUVEyeball = clamp(eyeballTexcoord, eyeballClipRect50, eyeballClipRect11);
    }

    half4 eyeballColor = SAMPLE_TEXTURE2D(_EyeballTexture, sampler_EyeballTexture, clampedUVEyeball);
    if (eyeballColor.a < 0.01)
    {
        discard;
    }

    half3 baseColor = eyeballColor.rgb;
    half alpha = eyeballColor.a * _Alpha;

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
    // Input data
    InputData inputData;
    InitializeCharacterInputData(input, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.texcoord.xy, _EyeballTexture);

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
        baseColor);

    #ifdef _DISSOLVE_FEATURE
        DissolveInput dissolveInput;
        dissolveInput.range = _DissolveRange;
        dissolveInput.notUseDirection = _NotUseDirection;
        dissolveInput.direction = _DissolveDirection.xyz;
        dissolveInput.panningSpeed = _DissolvePanningSpeed;
        dissolveInput.dissolveMap = _DissolveMap;
        dissolveInput.dissolveMapSampler = sampler_DissolveMap;
        dissolveInput.dissolveMapST = _DissolveMap_ST;
        dissolveInput.useCutoff = _DissolveCutoff;
        dissolveInput.mainColor = _DissolveColor;
        dissolveInput.mainWidth = _DissolveWidth;
        dissolveInput.edgeColor = _DissolveEdgeColor;
        dissolveInput.edgeWidth = _DissolveEdgeWidth;
        dissolveInput.positionWS = inputData.positionWS;
        dissolveInput.positionOS = input.positionOS;
        dissolveInput.normalWS = inputData.normalWS;
        dissolveInput.characterData = characterData;
        resultColor.rgb = ApplyDissolve(resultColor.rgb, _DissolveAmount, dissolveInput);
    #endif

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
        return half4(baseColor, resultColor.a);
    }
    #endif

    #if defined(DEBUG_DISPLAY)
    {
        return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, baseColor, alpha);
    }
    #endif
    //-----------------------------------------------------------------------------

    return resultColor;
}

#endif // MMN_LEGACY_CHARACTER_EYE_EMOTION_PASS_INCLUDED
