#ifndef MMN_CHARACTER_STOCKINGS_PASS_INCLUDED
#define MMN_CHARACTER_STOCKINGS_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterAtlas.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
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

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

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
    // Stockings Color
    //-----------------------------------------------------------------------------
    float3 dyedBaseColor = baseColor;

    // _Denier : [10 ~ 180] 범위의 값을 가짐.
    float nomalizedDenier = (_Denier - 10.0) / 170.0;
    float reverseNomalizedDenier = 1.0 - nomalizedDenier;

    float3 skinColor = _DyeColor1.rgb;
    float3 stockingsColor = _DyeColor2.rgb;
    float3 stockingsBlendColor = sqrt(stockingsColor * skinColor);
    stockingsBlendColor = lerp(stockingsBlendColor, stockingsColor, nomalizedDenier); // 두께가 얇으면 스킨과 스타킹이 적절히 섞인 컬러로, 두꺼울 수록 스타킹 본연의 색으로 표현.
    float3 stockingsHighlightColor = lerp(skinColor, float3(1, 1, 1), nomalizedDenier); // 두께가 얇으면 스킨색으로, 두꺼울 수록 흰색으로 표현

    float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);

    // 스타킹 베이스 컬러 공식.
    // 기본 N dot V 공식인데 두께가 얇으면 스킨의 컬러가 넓은 면적이 되도록,
    // 두꺼울 수록 스킨은 튀어나온 곳에만 보이고 대부분 스타킹 본연의 컬러가 나오도록 표현.
    float denierFactor = (180.0 - _Denier) / 170.0;
    denierFactor = saturate(PositivePow(denierFactor, 5.0));
    float stockingsBaseFactor = max(0.0, nDotV * denierFactor - (denierFactor * 0.3) - 0.06);
    dyedBaseColor = lerp(stockingsBlendColor, skinColor, stockingsBaseFactor);

    // 스타킹 하이라이트 컬러 공식.
    // 두께가 얇으면 하이라이트가 넓게 표현하고, 두꺼울 수록 좁게 표현함.
    // 그리고 두꺼울 수록 하이라이트가 연하게 보이도록 조정.
    float stockingsHighlightFactor = saturate(nDotV - lerp(nomalizedDenier * 0.2 + 0.6, 0.96, PositivePow(nomalizedDenier, 0.2)));
    stockingsHighlightFactor *= reverseNomalizedDenier * 1.2;
    dyedBaseColor += stockingsHighlightColor * stockingsHighlightFactor * nomalizedDenier * 0.4;

    // 스타킹 마스킹
    // 텍스쳐의 RGB 채널이 0이면 스타킹이 보이고, 1이면 스킨이 그대로 보임. (망사 표현용)
    // 텍스쳐의 A 채널이 0이면 스타킹이 보이고, 1이면 텍스쳐에 그려놓은 컬러(RGB)가 보임. (문양 표현용)
    dyedBaseColor = lerp(dyedBaseColor, skinColor, min(baseMap.r, min(baseMap.g, baseMap.b)));
    dyedBaseColor = lerp(dyedBaseColor, baseColor, baseMap.a);

    // dyedBaseColor = stockingsMask;
    // dyedBaseColor = stockingsBlendColor;
    // dyedBaseColor = stockingsBaseFactor;
    // dyedBaseColor = stockingsHighlightFactor;
    // dyedBaseColor = nomalizedDenier;

    #ifdef _TINTCOLOR_FEATURE
        dyedBaseColor *= _TintColor.rgb;
    #endif

    //-----------------------------------------------------------------------------
    // Process Color
    //-----------------------------------------------------------------------------
    float4 resultColor;
    resultColor.rgb = ProcessCharacterColor(inputData,
        mainLight, lightingData, characterData,
        dyedBaseColor, STOCKINGS_SHADING, _SilhouetteOff, _SilhouetteTintColor);

    #ifdef _OUTLINE_FEATURE
        float3 outlineColor = OnePassOutline(STOCKINGS_SHADING, inputData, mainLight.direction, _OutlineColorMode);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = float3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
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

#endif // MMN_CHARACTER_STOCKINGS_PASS_INCLUDED
