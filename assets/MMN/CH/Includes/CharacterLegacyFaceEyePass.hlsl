#ifndef MMN_LEGACY_CHARACTER_FACE_EYE_PASS_INCLUDED
#define MMN_LEGACY_CHARACTER_FACE_EYE_PASS_INCLUDED

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
    float3 normalOS : NORMAL;

    float2 texcoord : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;

    float2 texcoord : TEXCOORD0;
    float4 pupilTexcoord : TEXCOORD1;
    float4 pupilClipRect : TEXCOORD2;

    float4 positionWS : TEXCOORD3;  // xyz: position, w: camera distance
    float3 normalWS : TEXCOORD4;     // xyz: normal
    float3 viewDirWS : TEXCOORD5;

    float4 fogCoord : TEXCOORD6;     // x: fogFactor, yzw: vertexLighting

    float4 positionNDC : TEXCOORD7;
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

    float2 pupilUvOffset, pupilUvScale;
    CalcUvOffsetScale_Legacy((float)_PupilTextureColNum, (float)_PupilTextureRowNum,
        (float)(_PupilIndexFromOne - 1), pupilUvOffset, pupilUvScale);

    output.texcoord = input.texcoord;

    // Left pupil
#if !_MASK_ON
    if (_LeftPupil_Enable > 0.5)
#endif
    {
        float2 centeredTexcoord = input.texcoord - float2(0.5, 0.5);
        centeredTexcoord = centeredTexcoord - (_LeftPupil_TS.xy + _PupilPositionOffset + _EyePositionOffset);
        centeredTexcoord = centeredTexcoord / _LeftPupil_TS.zw;
        centeredTexcoord = centeredTexcoord + float2(0.5, 0.5);
        output.pupilTexcoord.xy = TRANSFORM_TEX(centeredTexcoord, _PupilTexture) * pupilUvScale + pupilUvOffset;
    }
#if !_MASK_ON
    else
    {
        output.pupilTexcoord.xy = float2(0.0, 0.0);
    }

    // Right pupil
    if (_RightPupil_Enable > 0.5)
#endif
    {
        float2 centeredTexcoord = input.texcoord - float2(0.5, 0.5);
        centeredTexcoord = centeredTexcoord - (_RightPupil_TS.xy + _PupilPositionOffset + float2(-_EyePositionOffset.x, _EyePositionOffset.y));
        centeredTexcoord = centeredTexcoord / _RightPupil_TS.zw;
        centeredTexcoord = centeredTexcoord + float2(0.5, 0.5);
        output.pupilTexcoord.zw = TRANSFORM_TEX(centeredTexcoord, _PupilTexture) * pupilUvScale + pupilUvOffset;
    }
#if !_MASK_ON
    else
    {
        output.pupilTexcoord.zw = float2(0.0, 0.0);
    }
#endif

    output.pupilClipRect.xy = TRANSFORM_TEX(float2(0.0, 0.0), _PupilTexture) * pupilUvScale + pupilUvOffset;
    output.pupilClipRect.zw = TRANSFORM_TEX(float2(1.0, 1.0), _PupilTexture) * pupilUvScale + pupilUvOffset;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    output.normalWS = float3(normalInput.normalWS);
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float3 vertexLight = AdditionalLightsVertex(output.positionWS.xyz, output.normalWS);
        output.fogCoord = float4(fogFactor, vertexLight); //fogFactorAndVertexLight
    #else
        output.fogCoord = float4(fogFactor, 0.0, 0.0, 0.0);
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

    inputData.shadowCoord = float4(0, 0, 0, 0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
        inputData.vertexLighting = input.fogCoord.yzw;
    #else
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
        inputData.vertexLighting = float3(0, 0, 0);
    #endif

    inputData.bakedGI = 1.0; //음영을 사용 안하도록

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = float4(1, 1, 1, 1);
}

float4 frag(Varyings input) : SV_Target
{
    float2 eyeballUvOffset, eyeballUvScale;
    CalcUvOffsetScale_Legacy((float)_EyeballTextureColNum, (float)_EyeballTextureRowNum,
        (float)(_EyeballIndexFromOne - 1), eyeballUvOffset, eyeballUvScale);

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

    float4 eyeballColor = SAMPLE_TEXTURE2D(_EyeballTexture, sampler_EyeballTexture, clampedUVEyeball);
    if (eyeballColor.a < 0.01)
    {
        discard;
    }

    float2 clampedUVLeft = clamp(input.pupilTexcoord.xy, input.pupilClipRect.xy, input.pupilClipRect.zw);
    float2 clampedUVRight = clamp(input.pupilTexcoord.zw, input.pupilClipRect.xy, input.pupilClipRect.zw);
    float4 leftPupilColor = SAMPLE_TEXTURE2D_BIAS(_PupilTexture, sampler_PupilTexture, clampedUVLeft, -1.2);
    float4 rightPupilColor = SAMPLE_TEXTURE2D_BIAS(_PupilTexture, sampler_PupilTexture, clampedUVRight, -1.2);
    float4 pupilColor = float4(lerp(leftPupilColor.rgb, float3(1.0, 0.0, 0.0), _Pupil_Position_Debug) * leftPupilColor.a + lerp(rightPupilColor.rgb, float3(0.0, 0.0, 1.0), _Pupil_Position_Debug) * rightPupilColor.a, leftPupilColor.a + rightPupilColor.a);

    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            ApplyDyeColor(pupilColor.rgb, _DyeColor1);
        }
    #endif

    float eyeballColorMin = min(eyeballColor.r, min(eyeballColor.g, eyeballColor.b));
    float eyeballColorMask = smoothstep(_PupilMaskThresholdMin, _PupilMaskThresholdMax, eyeballColorMin * eyeballColor.a);
    float4 maskedPupilColor = eyeballColorMask * pupilColor;
    #if _MASK_ON
        float4 maskTextureMask = SAMPLE_TEXTURE2D_BIAS(_EyeballPupilMaskTexture, sampler_EyeballPupilMaskTexture, clampedUVEyeball, -1.2);
        maskedPupilColor = maskTextureMask * pupilColor;
    #endif
    float3 maskedColor = maskedPupilColor.rgb * maskedPupilColor.a + eyeballColor.rgb * (1 - maskedPupilColor.a);

    float3 dyedBaseColor = maskedColor;
    float alpha = eyeballColor.a * _Alpha;

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
    float4 resultColor;
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
        return float4(dyedBaseColor, resultColor.a);
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

#endif // MMN_LEGACY_CHARACTER_FACE_EYE_PASS_INCLUDED
