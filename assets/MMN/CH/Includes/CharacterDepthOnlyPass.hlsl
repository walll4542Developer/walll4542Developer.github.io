#ifndef MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
#define MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "../../Includes/BendingVertex.hlsl"
// #include "../../Includes/VectorRigHelper.hlsl"

#include "CharacterData.hlsl"
#include "CharacterApplyDissolve.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;

#ifdef _DISSOLVE_FEATURE
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
#endif

    // VECTOR_RIG_ATTRIBUTES(1, 2, 3, 4, 5)
};

struct Varyings
{
    float4 positionCS : SV_POSITION;

#ifdef _DISSOLVE_FEATURE
    float4 positionWS : TEXCOORD1;  // xyz: position, w: camera distance
    half3 normalWS : TEXCOORD2;     // xyz: normal
    float3 positionOS : TEXCOORD3;
#endif
};

Varyings DepthPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    // VECTOR_RIG_DEFORM_VERTEX(input, input.positionOS)

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexInput.positionCS;
#ifdef _DISSOLVE_FEATURE
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionOS = input.positionOS.xyz;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = normalInput.normalWS;
#endif

    return output;
}

half4 DepthPassFragment(Varyings input) : SV_Target
{
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

    return half4(1.0, 1.0, 1.0, 1.0);
}

#endif // MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
