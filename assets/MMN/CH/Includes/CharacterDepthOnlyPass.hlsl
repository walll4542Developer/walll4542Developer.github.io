#ifndef MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
#define MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

#include "CharacterData.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterMotionBlurPass.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;

#ifdef _DISSOLVE_FEATURE
    float4 tangentOS : TANGENT;
#endif

#ifdef _VERTEX_OBJECT_MOTION_BLUR
    uint id : SV_VertexID;
#endif
};

struct Varyings
{
    float4 positionCS : SV_POSITION;

#ifdef _DISSOLVE_FEATURE
    float4 positionWS : TEXCOORD1;  // xyz: position, w: camera distance
    float3 normalWS : TEXCOORD2;     // xyz: normal
    float3 positionOS : TEXCOORD3;
#endif
};

Varyings DepthPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

#ifdef _VERTEX_OBJECT_MOTION_BLUR
    // 오브젝트 모션블러(버텍스)를 적용한다
    float3 positionOS = CaculateMotionBlurVertexPositionOS(input.positionOS.xyz, input.normalOS, input.id);
#else
    float3 positionOS = input.positionOS.xyz;
#endif

    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    output.positionCS = vertexInput.positionCS;
#ifdef _DISSOLVE_FEATURE
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionOS = positionOS;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = normalInput.normalWS;
#endif

    return output;
}

float4 DepthPassFragment(Varyings input) : SV_Target
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
        ApplyDissolve(float3(1.0, 1.0, 1.0), _DissolveAmount, dissolveInput);
    #endif

    return float4(1.0, 1.0, 1.0, 1.0);
}

#endif // MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
