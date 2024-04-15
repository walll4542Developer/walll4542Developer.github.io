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

float4 GetColorByIndex(int index)
{
    // 24는 와이어링이 존재하지 않는 버텍스
    // 마젠타로 설정하지만 실제로는 텍스처에 기록된 고유 색이 나와야 한다
    // 마젠타가 노출되는 경우 텍스처에는 염색이 할당되어 있는데 와이어링이 안된 경우이다.
    return index < 12 ? 
                index < 6 ? 
                    index < 3 ? 
                        index < 2 ? 
                            index == 0 ? _DyeColor1 : _DyeColor2 :
                            _DyeColor3 :
                        index < 5 ? 
                            index < 4 ? _DyeColor4 : _DyeColor5 :
                            _DyeColor6 :
                    index < 9 ?
                        index < 8 ? 
                            index == 6 ? _DyeColor7 : _DyeColor8 :
                        _DyeColor9 :
                    index < 11 ?
                        index < 10 ? _DyeColor10 : _DyeColor11 :
                        _DyeColor12 :
                index < 18 ?
                    index < 15 ? 
                        index < 14 ? 
                            index == 12 ? _DyeColor13 : _DyeColor14 :
                            _DyeColor15 :
                        index < 17 ? 
                            index == 15 ? _DyeColor16 : _DyeColor17 :
                            _DyeColor18 :
                    index < 21 ?
                        index < 20 ? 
                            index == 18 ? _DyeColor19 : _DyeColor20 :
                            _DyeColor21 :
                        index < 23 ? 
                            index == 21 ? _DyeColor22 : _DyeColor23 :
                            index == 23 ? _DyeColor24 : float4(1, 0, 1, 1);
}

float4 BasePassFragment(Varyings input, FRONT_FACE_TYPE isFacing : FRONT_FACE_SEMANTIC) : SV_Target
{
    //-----------------------------------------------------------------------------
    // 병합 머티리얼 연산
    //-----------------------------------------------------------------------------
    int uvIntegralPartX = 0;
    int uvIntegralPartY = 0;
    
    // 텍스처 UV는 UV 소수부 사용
    float uvFractionalPartX = modf(input.uv.x, uvIntegralPartX);
	float uvFractionalPartY = modf(input.uv.y, uvIntegralPartY);
    input.uv.xy = float2(uvFractionalPartX, uvFractionalPartY);

    // 염색 슬롯 및 텍스처 인덱스는 UV 정수부 사용
    int dyeIndex1 = int(uvIntegralPartX/25) % 25;
    int dyeIndex2 = uvIntegralPartX % 25;
    int dyeIndex3 = uvIntegralPartY % 25;
    int textureIndex = int(uvIntegralPartY/25) % 25;

    float2 mergedUV = input.uv.xy;
    mergedUV.x = input.uv.x * _UVXOffset[textureIndex];
    if(textureIndex == 0)
    {
        mergedUV.y = input.uv.y * _UVYOffset[0];
    }
    else
    {
        mergedUV.y = input.uv.y * (_UVYOffset[textureIndex] - _UVYOffset[textureIndex - 1]) + _UVYOffset[textureIndex - 1];
    }
	mergedUV = TRANSFORM_TEX(mergedUV, _BaseMap);
    
    //-----------------------------------------------------------------------------
    // Diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, mergedUV);
    float3 baseColor = baseMap.rgb;
    float alpha = baseMap.a;

    #ifdef _TEXTURE_LERP_FEATURE
        float4 baseMap2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, mergedUV);
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

    float3 dyedBaseColor = baseColor;
    float4 _useDyeColor1;
    float4 _useDyeColor2;
    float4 _useDyeColor3;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            _useDyeColor1 = GetColorByIndex(dyeIndex1);
            _useDyeColor2 = GetColorByIndex(dyeIndex2);
            _useDyeColor3 = GetColorByIndex(dyeIndex3);
            ApplyDyeColor(dyedBaseColor, _useDyeColor1, _useDyeColor2, _useDyeColor3);
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
    float4 resultColor;
    resultColor.rgb = ProcessCharacterColorFull(inputData,
        mainLight, lightingData, characterData, isFacing, backFaceDarkenAmount,
        _ShadingType, dyedBaseColor, _SilhouetteOff, _SilhouetteTintColor,
        _IsMetal, _Smoothness, alpha, _SpecularStrength, _MetalTintColor);

    #ifdef _OUTLINE_FEATURE
        float3 outlineColor = OnePassOutline(inputData, mainLight.direction, _OutlineColorMode, _ShadingType);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = float3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
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

#endif // MMN_CHARACTER_STANDARD_PASS_MERGED_INCLUDED
