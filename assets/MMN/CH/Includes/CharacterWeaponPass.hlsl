#ifndef MMN_CHARACTER_STANDARD_PASS_INCLUDED
#define MMN_CHARACTER_STANDARD_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterWeapon.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterEmission.hlsl"
#include "CharacterApplyFresnel.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterApplyArbalestMagazine.hlsl"
#include "CharacterDebugging.hlsl"


float4 BasePassFragment(Varyings input, FRONT_FACE_TYPE isFacing : FRONT_FACE_SEMANTIC) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    float3 baseColor = baseMap.rgb;
    float alpha = baseMap.a;

    #ifdef _TEXTURE_LERP_FEATURE
        float4 baseMap2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, uv);
        baseColor = lerp(baseColor, baseMap2.rgb, _LerpTex);
    #endif

    // 메탈 재질에서 알파는 마스크 값이다. 그래서 메탈이 아닐 때만 처리한다.
    if (IS_FALSE(_IsMetal))
    {
        #ifdef _ALPHA_TEST
            clip(alpha - _Cutoff);
        #endif

        #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY)
            alpha *= _AlphaOverride;
        #else
            alpha = 1.0;
        #endif
    }

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

    float backFaceDarkenAmount = 1.0;
    #ifdef _TWO_SIDE_FEATURE
        backFaceDarkenAmount = _BackFaceDarkenAmount;
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
    // Process Color
    //-----------------------------------------------------------------------------
    float2 flatShadingAmount = float2(_FlatShadingAmountTop, _FlatShadingAmountBottom);
    float verticalGradientRemapped = GetVerticalGradientRemapped(inputData.positionWS.xyz, characterData);
    verticalGradientRemapped = clamp(verticalGradientRemapped, flatShadingAmount.y, flatShadingAmount.x);

    float4 resultColor;
    resultColor.rgb = ProcessCharacterColorFull(inputData,
        mainLight, lightingData, characterData, isFacing, backFaceDarkenAmount, verticalGradientRemapped,
        _ShadingType, flatShadingAmount, dyedBaseColor, _SilhouetteOff, _SilhouetteTintColor,
        _IsMetal, _Smoothness, alpha, _SpecularStrength, _MetalTintColor);

    #ifdef _OUTLINE_FEATURE
        float3 outlineColor = OnePassOutline(inputData, mainLight.direction, characterData, verticalGradientRemapped, _OutlineColorMode, _ShadingType);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = float3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
    #endif

    #ifdef _WEAPON_GRADE_FEATURE
        float4 weaponGradeColor = _WeaponGradeColor;
        resultColor = OnePassWeaponOutline(resultColor, weaponGradeColor, input.positionNDC, input.outlineNDC, inputData, mainLight);
    #endif

    #ifdef _ARBALEST_FEATURE
        ApplyArbalestMagazine(resultColor, _RemainedMagazine, _MagazineNumber);
    #endif

    #ifdef _EMISSION_FEATURE
        float3 emissionMap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb;
        float3 emissionResult = ApplyEmissionColor(emissionMap, _EmissionColor,
            _IsEnableEmissionAtNight, _IsBreathingEmissionMode, _BreathingEmissionModePeriod);
        resultColor.rgb += emissionResult;
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

    float4 appliedFogResultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
    #ifdef _EMISSION_FEATURE
        float3 noFogResultColorWithEmissionMask = (resultColor.rgb * emissionMap) + (appliedFogResultColor.rgb * (1.0 - emissionMap));
        resultColor.rgb = lerp(noFogResultColorWithEmissionMask.rgb, appliedFogResultColor.rgb, _IsApplyFogToEmission * _ApplyFogToEmissionFactor);
    #else
        resultColor.rgb = appliedFogResultColor.rgb;
    #endif

    ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

    resultColor.a = IS_FALSE(_IsMetal) ? alpha : 1.0; // 메탈 재질에서 알파는 마스크 값이기 때문에 무조건 1을 반환한다.

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

#endif // MMN_CHARACTER_STANDARD_PASS_INCLUDED