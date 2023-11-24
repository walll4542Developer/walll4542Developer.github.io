#ifndef MMN_CHARACTER_EYE_PUPIL_PASS_INCLUDED
#define MMN_CHARACTER_EYE_PUPIL_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterAtlas.hlsl"
#include "CharacterParallaxMapping.hlsl"
#include "CharacterLighting.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterDebugging.hlsl"


float4 BasePassFragment(Varyings input) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
    // Input data
    InputData inputData;
    InitializeCharacterInputData(input, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv.xy, _BaseMap);

    //-----------------------------------------------------------------------------
    // Diffuse
    //-----------------------------------------------------------------------------
    float3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, inputData.normalWS, inputData.viewDirectionWS);
    float2 pupilParallaxOffset = GetParallaxOffset1Step(0, _PupilDepth, viewDirTS);

    _BaseMapScalePosition.zw -= pupilParallaxOffset * float2(10.0, 5.0);

    float2 uv = ConvertToAtlasUV(_BaseMapAtlasSize.xy, _BaseMapAtlasSize.z, _BaseMapScalePosition, _BaseMapAtlasSize.w, input.uv.xy);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    float3 baseColor = baseMap.rgb;
    float alpha = baseMap.a * _AlphaOverride;

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    float3 dyedBaseColor = baseColor;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            ApplyDyeColor(dyedBaseColor, _DyeColor1, _DyeColor2, _DyeColor3);
        }
    #endif

    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
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

#endif //#ifndef MMN_CHARACTER_EYE_PUPIL_PASS_INCLUDED
