#ifndef MMN_SUMMONSTONE_INPUT_INCLUDED
#define MMN_SUMMONSTONE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 texcoord : TEXCOORD0;
    float4 color : COLOR;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR;
    float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
    float4 fogCoord : TEXCOORD1; 		    // x : fogcoord				yzw :
    float3 positionWS : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float4 positionNDC : TEXCOORD4;
};

TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
TEXTURE2D(_NoiseTex);           SAMPLER(sampler_NoiseTex);

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    float4 _NoiseTex_ST;

    float4 _Color;

    float _CutoutThreshold;
    
    float _uvGradient;
    float _GradientRange;

    float _AlphaTestRange;
    float _BendRange;

    float4 _ColorA;
    float4 _ColorB;

    float _Power;
    float _Speed;
    float _NoiseSize;

    float _Mode;
    float _TransitionValue;

    float _RaycastHarftoneClip;
    float _RaycastMinimumAlpha;

    float _NearPlaneAlpha;
    float _NearPlaneInvertDistance;

    float _LightReceive;
    float _LightRatio;

    float _SoftParticle;
    float _SoftParticleNearFadeDistance;
    float _SoftParticleFarFadeDistance;
    float _SoftParticleFadeOutRange;

    float _FogReceive;
CBUFFER_END

float TriplanarNoise(float3 positionWS, float3 normalWS)
{
    float3 position = positionWS;

    float triplanarX = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.zy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    float triplanarY = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xz * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    float triplanarZ = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;

    float3 normalBlend = abs(normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    float nx = triplanarX * normalBlend.x;
    float ny = triplanarY * normalBlend.y;
    float nz = triplanarZ * normalBlend.z;

    float triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

float4 ProcessNoiseAlphaTest(float4 resultColor, float2 uv, float gradientRange,
                            float cutout, float range, float alphaTest,
                            float noise0, float noise1, float4 colorA, float4 colorB,
                            float uvGradientDirection)
{
    float uvGradient;
    if (uvGradientDirection == 1.0)
    {
        uvGradient = uv.x;
    }
    else if (uvGradientDirection == 2.0)
    {
        uvGradient = uv.y;
    }
    else
    {
        uvGradient = 1;
    }

    uvGradient = saturate(1 - uvGradient + gradientRange);
    noise0 *= uvGradient;

    float stepNoise = step(cutout, noise0);
    float3 noiseAlphaTest = lerp(resultColor.rgb * colorA.rgb, resultColor.rgb * colorB.rgb, stepNoise);

    float stepValue = (1 - step(cutout, noise0)) * saturate(step(cutout, noise0 + range));

    // 색을 floor 사용하여 5단계로(floor * 5 * 0.2) 끊어서 섞어줌
    float3 color = lerp(colorA.rgb, colorB.rgb, floor(noise1 * 5) * 0.2);

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

#endif // MMN_SUMMONSTONE_INPUT_INCLUDED
