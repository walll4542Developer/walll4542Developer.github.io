#ifndef MMN_SUMMONSTONE_INPUT_INCLUDED
#define MMN_SUMMONSTONE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"

CBUFFER_START(UnityPerMaterial)
    TEXTURE2D(_MainTex);
    SAMPLER(sampler_MainTex);
    float4 _MainTex_ST;

    TEXTURE2D(_NoiseTex);
    SAMPLER(sampler_NoiseTex);
    float4 _NoiseTex_ST;

    half _Intensive;
    half4 _Color;

    half _LightReceive;
    
    half _CutoutThreshold;
    half _AlphaTestRange;
    half _BendRange;
    half _GradientRange;

    half4 _ColorA;
    half4 _ColorB;

    float _Speed;
    float _Power;
    float _NoiseSize;
CBUFFER_END

half TriplanarNoise(float3 positionWS, float3 normalWS)
{
    float3 position = positionWS;

    half triplanarX = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.zy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    half triplanarY = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xz * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    half triplanarZ = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;

    float3 normalBlend = abs(normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    half nx = triplanarX * normalBlend.x;
    half ny = triplanarY * normalBlend.y;
    half nz = triplanarZ * normalBlend.z;

    half triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

half4 ProcessNoiseAlphaTest(half4 resultColor, float2 uv, half gradientRange, 
                            half cutout, half range, half alphaTest, 
                            half noise0, half noise1, half4 colorA, half4 colorB)
{
    float uvGradient;
    #ifdef _UVGRADIENT_U
        uvGradient = uv.x;
    #elif _UVGRADIENT_V
        uvGradient = uv.y;
    #else
        uvGradient = 1;
    #endif

    uvGradient = saturate(1- uvGradient + gradientRange);
    noise0 *= uvGradient;

    half stepNoise = step(cutout, noise0);
    half3 noiseAlphaTest = lerp(resultColor.rgb * colorA.rgb, resultColor.rgb * colorB.rgb, stepNoise);
    
    half stepValue = (1 - step(cutout, noise0)) * saturate(step(cutout, noise0 + range));
    
    // 색을 floor 사용하여 5단계로(floor * 5 * 0.2) 끊어서 섞어줌
    half3 color = lerp(colorA.rgb, colorB.rgb, floor(noise1 * 5) * 0.2);

    resultColor.rgb = lerp(noiseAlphaTest, color, stepValue);
    resultColor.a = noise0 + alphaTest;

    return resultColor;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Math Noise Generator
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// float NoiseRandom(float3 uv3d)
// {
//     float result = frac(sin(uv3d.x * 127 + uv3d.y * 645 + uv3d.z * 789) * _randomize + (_Time.y * _speed));
//     //+ (_Time.y * _speed)
//     return result;
// }

// float NoiseTexel(float3 positionWS, float noiseTexture) 
// {
//     float3 i = floor(positionWS * _NoiseSize);
//     float3 uv3d = smoothstep(0, 1, frac(positionWS * _NoiseSize));

//     float a = NoiseRandom(i + float3(0, 0, 0));
//     float b = NoiseRandom(i + float3(1, 0, 0));
//     float c = NoiseRandom(i + float3(0, 1, 0));
//     float d = NoiseRandom(i + float3(1, 1, 0));
//     float e = NoiseRandom(i + float3(0, 0, 1));
//     float f = NoiseRandom(i + float3(1, 0, 1));
//     float g = NoiseRandom(i + float3(0, 1, 1));
//     float h = NoiseRandom(i + float3(1, 1, 1));

//     float ab = lerp(a, b, uv3d.x);
//     float cd = lerp(c, d, uv3d.x);
//     float abcd = lerp(ab, cd, uv3d.y);
//     float ef = lerp(e, f, uv3d.x);
//     float gh = lerp(g, h, uv3d.x);
//     float efgh = lerp(ef, gh, uv3d.y);

//     float result = lerp(abcd, efgh, uv3d.z);

//     return result;
// }

// float FractalNoise(float3 positionWS, int Iteration, float noiseTexture)
// {
//     float Texel = 1;
//     float power = 0.5;
//     float result = 0;
//     for (int i = 0; i < Iteration; i++) 
//     {
//         result += NoiseTexel(positionWS * Texel, noiseTexture) * power;
//         Texel *= 2;
//         power *= 0.5;
//     }
//     return result;
// }

//////////////////////////////////////////////////////////////////////////////////////////////////////////

struct Attributes
{
    float4 positionOS : POSITION;
    float4 texcoord : TEXCOORD0;
    half4 color : COLOR;
    float3 normalOS : NORMAL;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;      // World space position
    #ifdef _FOG_RCV_ON
        half fogCoord : TEXCOORD2;      // x: fogFactor
    #endif
    float3 normalWS : NORMAL;

    half4 color : COLOR0;               // low-precision, 0–1 range data
    float4 positionCS : SV_POSITION;    // Homogeneous clip space position

    UNITY_VERTEX_INPUT_INSTANCE_ID
};
		

#endif // MMN_SUMMONSTONE_INPUT_INCLUDED
