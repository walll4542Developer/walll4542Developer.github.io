#ifndef UNIVERSAL_SHADOW_CASTER_DISSOLVE_PASS_INCLUDED
#define UNIVERSAL_SHADOW_CASTER_DISSOLVE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 customdata : TEXCOORD1;
    float4 color : COLOR;
};

struct Varyings
{
    float4 uv0 : TEXCOORD0;
    float4 uv1 : TEXCOORD1;
    float4 positionOS : TEXCOORD2;
    float3 positionWS : TEXCOORD3;
    float4 positionCS : SV_POSITION;
    float4 screenPos : TEXCOORD4;
    float3 normalWS : TEXCOORD5;
};

float4 GetShadowPositionHClip(in float3 positionWS, in float3 normalWS)
{
    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #else
        positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    output.uv0.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv1 = input.customdata;

    output.positionOS = input.positionOS;
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionWS = positionByWind(positionWS, _WindMultiply, _WindSpeedMultiply, 1 - saturate(input.color.a + _VertexAniOn));
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.positionCS = GetShadowPositionHClip(output.positionWS, output.normalWS);
    output.screenPos = ComputeScreenPos(output.positionCS);
    return output;
}

void DissolveShadow(
    in float3 positionOS, in float3 positionWS, in float3 normalWS,
    in float3 dissolveDirection, in float dissolveEdgeWidth, in float dissolveWidth, in float dissolveAmount,
    in float noiseCutoff, in float noiseCutoffSmoothness, in float noiseTexScale)
{
    float3 direction = normalize(dissolveDirection.xyz);
    float movingPosition = dot(positionOS, direction);

    float dissolvePos = (movingPosition + dissolveAmount) * noiseTexScale;

    float triplanarNoise = TriplanarNoise(positionWS, normalWS);
    dissolvePos += triplanarNoise;

    float dissolveResult = smoothstep(dissolvePos, dissolvePos + noiseCutoffSmoothness, min(dissolveEdgeWidth + dissolveWidth, dissolveWidth));
    clip(dissolveResult - noiseCutoff);
}

float4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    float4 customdata = input.uv1;
    float2 uv = input.uv0.xy;

    // 디졸브 연산
    #if _CUSTOMDATA_ON
        _DissolveAmount += customdata.x;
    #endif

    DissolveShadow(
        input.positionOS.xyz, input.positionWS.xyz, input.normalWS.xyz,
        _DissolveDirection.xyz, _DissolveEdgeWidth, _DissolveWidth, _DissolveAmount,
        _NoiseCutoff, _NoiseCutoffSmoothness, _NoiseTexScale);

    // LOD 디더링 기능
    float fadeValue;
    float lodFade;
    if (unity_LODFade.x != 0)
    {
        if (unity_LODFade.x > 0)
        {
            fadeValue = unity_LODFade.x ;
        }
        else
        {
            fadeValue = 1 + unity_LODFade.x;
        }
        Unity_Dither_linear(fadeValue, input.screenPos, lodFade, 0.5);
        clip(lodFade);
    }
    else
    {
        fadeValue = 1;
    }

    Alpha(SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);

    return 0;
}

#endif // UNIVERSAL_SHADOW_CASTER_DISSOLVE_PASS_INCLUDED
