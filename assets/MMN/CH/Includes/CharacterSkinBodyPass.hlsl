#ifndef MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED
#define MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterAtlas.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterApplyFresnel.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterDebugging.hlsl"


float4 BasePassFragment(Varyings input) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Skin diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

    float3 baseColor = baseMap.rgb;
    float alpha = 1.0;
    #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY)
        alpha = baseMap.a * _AlphaOverride;
    #endif

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    float3 dyedBaseColor = baseColor;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            ApplyDyeColor(dyedBaseColor, _DyeColor1, _DyeColor2, _DyeColor3);
        }
    #endif

    #ifdef _TINTCOLOR_FEATURE
        dyedBaseColor *= _TintColor.rgb;
    #endif

    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
    // Input data
    InputData inputData;
    InitializeCharacterInputData(input, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv.xy, _BaseMap);

    // Light
    Light mainLight;
    LightingData lightingData;
    InitializeLightData(inputData, mainLight, lightingData);

    // from script
    CharacterData characterData = InitializeCharacterData();

    //-----------------------------------------------------------------------------
    // 문신 / 횽터
    //-----------------------------------------------------------------------------
    float2 tattooUV = TransformUV(_TattooMapScalePosition, _TattooMapRotation, input.uv.xy);
    float4 tattooMap = SAMPLE_TEXTURE2D(_TattooMap, sampler_TattooMap, tattooUV);
    float3 tattooColor = tattooMap.rgb;

    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            if (IS_TRUE(_IsScarMode))
            {
                tattooColor = ApplySkinColorForScar(tattooColor, _DyeColor1.rgb);
            }
            else
            {
                tattooColor = ApplySkinColorForTattoo(tattooColor, _DyeColor1.rgb);
            }
        }
    #endif
    dyedBaseColor = lerp(dyedBaseColor, tattooColor, tattooMap.a);

    //-----------------------------------------------------------------------------
    // Process Color
    //-----------------------------------------------------------------------------
    float4 resultColor;
    resultColor.rgb = ProcessCharacterColor(inputData,
        mainLight, lightingData, characterData,
        dyedBaseColor, SKIN_SHADING, _SilhouetteOff, _SilhouetteTintColor);

    #ifdef _OUTLINE_FEATURE
        float3 outlineColor = OnePassOutline(SKIN_SHADING, inputData, mainLight.direction, _OutlineColorMode);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = float3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
    #endif

    #ifdef _FRESNEL_FEATURE
        float3 fresnelColor = ApplyFresnel(dyedBaseColor, lightingData.mainLightColor, lightingData.giColor,
            inputData.normalWS, inputData.viewDirectionWS, _FresnelColor.rgb, _FresnelRange, _FresnelPower);
        resultColor.rgb += fresnelColor;
    #endif

    #ifdef _DISSOLVE_FEATURE
        if (IS_TRUE(_IsDissolve))
        {
            resultColor.rgb = ApplyDissolve(resultColor.rgb,
                inputData.positionWS, inputData.normalWS, input.positionOS,
                _DissolveAmount, _NotUseDirection, _DissolveDirection, _DissolvePanningSpeed,
                TEXTURE2D_ARGS(_DissolveMap, sampler_DissolveMap), _DissolveMap_ST, _DissolveTexScale,
                _DissolveCutoff, _DissolveCutoffSmoothness,
                _DissolveColor.rgb, _DissolveWidth, _DissolveEdgeColor.rgb, _DissolveEdgeWidth);
        }
    #endif

    ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
    resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
    ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

    resultColor.a = alpha;

    #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY) && defined(_GRADIENT_ALPHA_FEATURE)
        if (IS_TRUE(_IsGradientAlpha))
        {
            float visualHeight = (_GradientAlphaHeight <= 0.001) ? characterData.visualHeight : _GradientAlphaHeight;
            float gradientAlpha = (inputData.positionWS.y - characterData.characterPos.y) / max(visualHeight, 0.001);
            resultColor.a *= saturate(max(gradientAlpha, 0.1));
        }
    #endif

    #ifdef _THIEF_HIDE
        resultColor.a *= _EffectAlphaValue;
    #endif

    //-----------------------------------------------------------------------------
    // 디버그
    //-----------------------------------------------------------------------------
    #if defined(DEBUG_SHADING_OFF)
    {
        #if !defined(DEBUG_OUTLINE_OFF) && defined(_OUTLINE_FEATURE)
            dyedBaseColor *= outlineColor;
        #endif

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

#endif // MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED
