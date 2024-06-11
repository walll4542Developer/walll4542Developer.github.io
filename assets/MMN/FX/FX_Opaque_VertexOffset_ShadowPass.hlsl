#ifndef FX_OPAQUE_VERTEXOFFSET_SHADOWPASS_INCLUDED
#define FX_OPAQUE_VERTEXOFFSET_SHADOWPASS_INCLUDED

#include "FX_VertexOffsetFuction.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

// Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
// For Directional lights, _LightDirection is used when applying shadow Normal Bias.
// For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 texcoord0 : TEXCOORD0;           // xyz: ParticleSystem의 velocity(속도의 방향 - 월드 -), w: ParticleSystem의 speed(속도의 스칼라)
    float4 customData : TEXCOORD1;
    float4 color : COLOR;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 texcoord0 : TEXCOORD0;
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    float3 finalOffset = AnimateVertexOffset(_OffsetMode, input.color, input.customData.xyz, input.customData.w,
        _TimeSpeed, _SinScope, _Sphereofinfluence, _VelocityVector.xyz, _Threshold);
    float3 objectVertexPosition = input.positionOS.xyz + finalOffset;

    float3 positionWS = TransformObjectToWorld(objectVertexPosition);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    #if UNITY_REVERSED_Z
        output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #else
        output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #endif

    output.texcoord0 = input.texcoord0;

    return output;
}

float4 frag(Varyings input) : SV_TARGET
{
    float4 color = 0;

    float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord0.xy).a;
    clip(alpha - _AlphaCutoff);

    return color;
}

#endif
