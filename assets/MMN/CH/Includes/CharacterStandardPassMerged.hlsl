#ifndef MMN_CHARACTER_STANDARD_PASS_MERGED_INCLUDED
#define MMN_CHARACTER_STANDARD_PASS_MERGED_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterEmission.hlsl"
#include "CharacterApplyFresnel.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterApplyArbalestMagazine.hlsl"
#include "CharacterDebugging.hlsl"

half4 BasePassFragment(Varyings input, FRONT_FACE_TYPE isFacing : FRONT_FACE_SEMANTIC) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    half3 baseColor = baseMap.rgb;
    half alpha = baseMap.a;

    #ifdef _TEXTURE_LERP_FEATURE
        half4 baseMap2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, uv);
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
            float alphaScaleRange = _AlphaScaleMax - _AlphaScaleMin;
            alpha = (alpha * alphaScaleRange) + _AlphaScaleMin;
        #else
            alpha = 1.0;
        #endif
    }

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    half3 dyedBaseColor = baseColor;
    half4 _useDyeColor1;
    half4 _useDyeColor2;
    half4 _useDyeColor3;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            if(input.uv.y < _UVOffset2)
            {
                _useDyeColor1 = _DyeColor1;
                _useDyeColor2 = _DyeColor2;
                _useDyeColor3 = _DyeColor3;
            }
            else if(input.uv.y < _UVOffset3)
            {
                _useDyeColor1 = _DyeColor4;
                _useDyeColor2 = _DyeColor5;
                _useDyeColor3 = _DyeColor6;
            }
            else if(input.uv.y < _UVOffset4)
            {
                _useDyeColor1 = _DyeColor7;
                _useDyeColor2 = _DyeColor8;
                _useDyeColor3 = _DyeColor9;
            }
            else if(input.uv.y < _UVOffset5)
            {
                _useDyeColor1 = _DyeColor10;
                _useDyeColor2 = _DyeColor11;
                _useDyeColor3 = _DyeColor12;
            }
            else if(input.uv.y < _UVOffset6)
            {
                _useDyeColor1 = _DyeColor13;
                _useDyeColor2 = _DyeColor14;
                _useDyeColor3 = _DyeColor15;
            }
            else if(input.uv.y < _UVOffset7)
            {
                _useDyeColor1 = _DyeColor16;
                _useDyeColor2 = _DyeColor17;
                _useDyeColor3 = _DyeColor18;
            }
            else if(input.uv.y < _UVOffset8)
            {
                _useDyeColor1 = _DyeColor19;
                _useDyeColor2 = _DyeColor20;
                _useDyeColor3 = _DyeColor21;
            }
            else if(input.uv.y < 1)
            {
                _useDyeColor1 = _DyeColor22;
                _useDyeColor2 = _DyeColor23;
                _useDyeColor3 = _DyeColor24;
            }
            ApplyDyeColor(dyedBaseColor, _useDyeColor1, _useDyeColor2, _useDyeColor3);
        }
    #endif

    #ifdef _TINTCOLOR_FEATURE
        dyedBaseColor *= _TintColor.rgb;
    #endif

    half backFaceDarkenAmount = 1.0;
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
    half4 resultColor;
    resultColor.rgb = ProcessCharacterColorFull(inputData,
        mainLight, lightingData, characterData, isFacing, backFaceDarkenAmount,
        dyedBaseColor, _SilhouetteOff, _SilhouetteTintColor,
        _IsMetal, _Smoothness, alpha, _SpecularStrength, _MetalTintColor);

    #ifdef _OUTLINE_FEATURE
        half3 outlineColor = OnePassOutline(inputData, mainLight.direction, _OutlineColorMode);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = half3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
    #endif

    #ifdef _ARBALEST_FEATURE
        ApplyArbalestMagazine(resultColor, _RemainedMagazine, _MagazineNumber);
    #endif

    #ifdef _EMISSION_FEATURE
        half3 emissionMap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb;
        half3 emissionResult = ApplyEmissionColor(emissionMap, _EmissionColor,
            _IsEnableEmissionAtNight, _IsBreathingEmissionMode, _BreathingEmissionModePeriod);
        resultColor.rgb += emissionResult;
    #endif

    #ifdef _FRESNEL_FEATURE
        half3 fresnelColor = ApplyFresnel(dyedBaseColor, lightingData.mainLightColor, lightingData.giColor,
            inputData.normalWS, inputData.viewDirectionWS, _FresnelColor.rgb, _FresnelRange, _FresnelPower);
        resultColor.rgb += fresnelColor;
    #endif

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

    half4 appliedFogResultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
    #ifdef _EMISSION_FEATURE
        half3 noFogResultColorWithEmissionMask = (resultColor.rgb * emissionMap) + (appliedFogResultColor.rgb * (1.0 - emissionMap));
        resultColor.rgb = lerp(noFogResultColorWithEmissionMask.rgb, appliedFogResultColor.rgb, _IsApplyFogToEmission * _ApplyFogToEmissionFactor);
    #else
        resultColor.rgb = appliedFogResultColor.rgb;
    #endif

    ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

    resultColor.a = IS_FALSE(_IsMetal) ? alpha : 1.0; // 메탈 재질에서 알파는 마스크 값이기 때문에 무조건 1을 반환한다.

    #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY) && defined(_GRADIENT_ALPHA_FEATURE)
        if (IS_TRUE(_IsGradientAlpha))
        {
            half visualHeight = (_GradientAlphaHeight <= 0.001) ? characterData.visualHeight : _GradientAlphaHeight;
            half gradientAlpha = (inputData.positionWS.y - characterData.characterPos.y) / max(visualHeight, 0.001);
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

#endif // MMN_CHARACTER_STANDARD_PASS_MERGED_INCLUDED
