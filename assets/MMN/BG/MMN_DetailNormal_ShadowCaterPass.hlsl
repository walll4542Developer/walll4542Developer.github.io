
#ifndef UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED
#define UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

float3 _LightDirection;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

    #if UNITY_REVERSED_Z
        positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
        positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

float4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}

#endif






// #ifndef UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED
// #define UNIVERSAL_SHADOW_CASTER_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
// #include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"

// float3 _LightDirection;
// // float _Global_CloudSpeed;
// // float _Global_CloudScale;
// // TEXTURE2D(_Global_Texture);        SAMPLER(sampler_Global_Texture);

// struct Attributes
// {
//     float4 positionOS: POSITION;
//     float3 normalOS: NORMAL;
//     float2 texcoord: TEXCOORD0;
//     float4 color: COLOR;
//     UNITY_VERTEX_INPUT_INSTANCE_ID
// };

// struct Varyings
// {
//     float2 uv: TEXCOORD0;
//     float4 positionCS: SV_POSITION;
//     float4 color: COLOR;
// };

// float4 GetShadowPositionHClip(Attributes input)
// {

//     float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

//     // positionWS = positionByWind(positionWS, _WindMultiply, _WindSpeedMultiply, 1 - saturate(input.color.a + _VertexAniOn));
//     // float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
//     float3 normalWS = TransformObjectToWorldDir(normalize(input.positionOS.rgb));
//     normalWS = 0;

//     float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

//     #if UNITY_REVERSED_Z
//         positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
//     #else
//         positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
//     #endif

//     return positionCS;
// }

// Varyings ShadowPassVertex(Attributes input)
// {
//     Varyings output;
//     UNITY_SETUP_INSTANCE_ID(input);

//     output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
//     output.positionCS = GetShadowPositionHClip(input);
//     output.color = input.color;

//     return output;
// }

// float4 ShadowPassFragment(Varyings input): SV_TARGET
// {
//     Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);

//     return 0;
// }

// #endif
