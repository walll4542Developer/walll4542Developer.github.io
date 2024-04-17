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
    float _IsDyable;
    float4 _DyeColor1;
    float4 _DyeColor2;
    float4 _DyeColor3;
#endif

#ifdef _SILHOUETTE_FEATURE
    float _SilhouetteOff;
    float4 _SilhouetteTintColor;
#endif

    float4 _OutlineColor;
    float _OutlineColorMode;
    // float _OutlineWidth;

    float4 _NoiseTex_ST;
    float4 _SecondTex_ST;
    float _Cutoff;
    float _SecondTexPower;

    float _uvGradient;
    float _GradientRange;
    float _AlphaTestRange;
    float _BendRange;

    float4 _ColorA;
    float4 _ColorB;

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END


float4 ProcessNoiseAlphaTest(float4 resultColor, float2 uv, float uvGradientDirection)
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
    float noise0 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;
    float noise1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV * 2.0).r;

    float2 secondNoiseUV = TRANSFORM_TEX(uv.xy, _SecondTex);
    float secondNoise = SAMPLE_TEXTURE2D(_SecondTex, sampler_SecondTex, secondNoiseUV + flowDirection).r;
    secondNoise *= _SecondTexPower;

    noise0 = saturate(noise0 + secondNoise);
    noise1 = saturate(noise1 + secondNoise);

    float uvGradient;
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

    float stepNoise = step(_Cutoff, noise0);
    float3 noiseAlphaTest = lerp(resultColor.rgb * 0.3, resultColor.rgb, stepNoise);

    float stepValue = (1.0 - step(_Cutoff, noise0)) * saturate(step(_Cutoff, noise0 + _BendRange));

    // 색을 floor 사용하여 5단계로(floor * 5 * 0.2) 끊어서 섞어줌
    float3 color = lerp(_ColorA.rgb, _ColorB.rgb, floor(noise1 * 5.0) * 0.2);

    resultColor.rgb = lerp(noiseAlphaTest, color, stepValue);
    resultColor.a = noise0 + _AlphaTestRange;
    clip(resultColor.a - _Cutoff);

    return resultColor;
}

#endif // #ifndef MMN_CHARACTER_FX_NOISEALPHATEST_INPUT_INCLUDED
