#ifndef MMN_CHARACTER_FX_NOISEALPHATEST_INPUT_INCLUDED
#define MMN_CHARACTER_FX_NOISEALPHATEST_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
float4 _BaseMap_MipInfo;
TEXTURE2D(_NoiseTex);
SAMPLER(sampler_NoiseTex);
TEXTURE2D(_SecondTex);
SAMPLER(sampler_SecondTex);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;

#ifdef _DYE_FEATURE
    half _IsDyable;
    half4 _DyeColor1;
    half4 _DyeColor2;
    half4 _DyeColor3;
#endif

#ifdef _SILHOUETTE_FEATURE
    half _SilhouetteOff;
    half4 _SilhouetteTintColor;
#endif

    half4 _OutlineColor;
    half _OutlineColorMode;
    // half _OutlineWidth;

    float4 _NoiseTex_ST;
    float4 _SecondTex_ST;
    half _Cutoff;
    half _SecondTexPower;

    half _uvGradient;
    half _GradientRange;
    half _AlphaTestRange;
    half _BendRange;

    half4 _ColorA;
    half4 _ColorB;

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END


half4 ProcessNoiseAlphaTest(half4 resultColor, float2 uv, half uvGradientDirection)
{
    // 노이즈 알파테스트 연산
    float2 flowDirection;
    if (uvGradientDirection == 1.0)
    {
        flowDirection = float2(_Time.x, 0.0);
    }
    else if (uvGradientDirection == 2.0)
    {
        flowDirection = float2(0.0, _Time.x);
    }
    else
    {
        flowDirection = float2(_Time.x, _Time.x);
    }

    float2 noiseUV = TRANSFORM_TEX(uv.xy, _NoiseTex);
    half noise0 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
    half noise1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV * 2.0).r;

    float2 secondNoiseUV = TRANSFORM_TEX(uv.xy, _SecondTex);
    half secondNoise = SAMPLE_TEXTURE2D(_SecondTex, sampler_SecondTex, secondNoiseUV + flowDirection).r;
    secondNoise *= _SecondTexPower;

    noise0 = saturate(noise0 + secondNoise);
    noise1 = saturate(noise1 + secondNoise);

    half uvGradient;
    if (uvGradientDirection == 1.0)
    {
        uvGradient = noiseUV.x;
    }
    else if (uvGradientDirection == 2.0)
    {
        uvGradient = noiseUV.y;
    }
    else
    {
        uvGradient = 1;
    }

    uvGradient = saturate(uvGradient + _GradientRange);
    noise0 *= uvGradient;

    half stepNoise = step(_Cutoff, noise0);
    half3 noiseAlphaTest = lerp(resultColor.rgb * 0.3, resultColor.rgb, stepNoise);

    half stepValue = (1.0 - step(_Cutoff, noise0)) * saturate(step(_Cutoff, noise0 + _BendRange));

    // 색을 floor 사용하여 5단계로(floor * 5 * 0.2) 끊어서 섞어줌
    half3 color = lerp(_ColorA.rgb, _ColorB.rgb, floor(noise1 * 5.0) * 0.2);

    resultColor.rgb = lerp(noiseAlphaTest, color, stepValue);
    resultColor.a = noise0 + _AlphaTestRange;
    clip(resultColor.a - _Cutoff);

    return resultColor;
}

#endif // #ifndef MMN_CHARACTER_FX_NOISEALPHATEST_INPUT_INCLUDED
