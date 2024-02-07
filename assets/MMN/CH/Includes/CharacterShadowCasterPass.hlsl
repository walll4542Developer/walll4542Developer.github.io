#ifndef MMN_CHARACTER_SHADOW_CASTER_PASS_INCLUDED
#define MMN_CHARACTER_SHADOW_CASTER_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
// #include "../../Includes/BendingVertex.hlsl"
// #include "../../Includes/VectorRigHelper.hlsl"

#include "CharacterData.hlsl"
#include "CharacterApplyDissolve.hlsl"

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

    float2 texcoord : TEXCOORD0;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;

#ifdef _DISSOLVE_FEATURE
    float4 positionWS : TEXCOORD1;  // xyz: position, w: camera distance
    half3 normalWS : TEXCOORD2;     // xyz: normal
    float3 positionOS : TEXCOORD3;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

float4 GetShadowPositionHClip(Attributes input, float3 positionWS, half3 normalWS)
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

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

#ifdef _DISSOLVE_FEATURE
    output.positionWS.xyz = vertexInput.positionWS.xyz;
    output.positionOS = input.positionOS.xyz;
    output.normalWS = normalInput.normalWS;
#endif

    output.positionCS = GetShadowPositionHClip(input, vertexInput.positionWS.xyz, normalInput.normalWS);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    half alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).a;

    #ifdef _ALPHA_TEST
        clip(alpha - _Cutoff);
    #endif

    #ifdef _DISSOLVE_FEATURE
        CharacterData characterData = InitializeCharacterData();

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
        dissolveInput.positionWS = input.positionWS.xyz;
        dissolveInput.positionOS = input.positionOS;
        dissolveInput.normalWS = SafeNormalize(input.normalWS.xyz);
        dissolveInput.characterData = characterData;
        ApplyDissolve(half3(1.0, 1.0, 1.0), _DissolveAmount, dissolveInput);
    #endif

    return 0;
}

#endif // MMN_CHARACTER_SHADOW_CASTER_PASS_INCLUDED
