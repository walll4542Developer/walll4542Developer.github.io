#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float4 color : COLOR;
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    float4 color : COLOR;
    float4 screenPos : TEXCOORD1;
    float3 viewDir : TEXCOORD2;
    float cameraDistance : TEXCOORD3; 
    float4 positionWS : TEXCOORD4;

};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    output.viewDir = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);
    output.positionWS.xyz = vertexInput.positionWS;

    return output;
}

float4 DepthOnlyFragment(Varyings input) : SV_TARGET
{

    float4 diffuseAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    float alpha = 1;

    // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
    // #if defined(_GLOBAL_NEARHALFTONECLIP_ON) && defined(_NEARHALFTONECLIP_ON)
    //     {
    //         //가까워지면 하프톤으로 사라지게 하는 기능
    //         float halftoneAlpha;
    //         float cameraDistance = input.cameraDistance  ;
    //         NearHarftoneAlphaTesting(cameraDistance, input.screenPos, 0.5, halftoneAlpha);
    //         clip(halftoneAlpha);
    //     }
    // #endif

    #if RAYCAST
        //레이케스트 되면 사라지는 기능
        float RaycasthalftoneAlpha;
        float dist = distance((input.screenPos.xy / input.screenPos.w - 0.5), float2(0, 0));
        dist = saturate(dist);
        dist = pow(dist, 1.5);
        // dist = pow(dist,10);
        dist = saturate(dist);
        dist += 2 - (_RaycastHarftoneClip * 2);
        Unity_Dither_linear(dist, input.screenPos, RaycasthalftoneAlpha);
        RaycasthalftoneAlpha = saturate(RaycasthalftoneAlpha);
        clip(RaycasthalftoneAlpha - _Cutoff);
    #endif

    return 0;
}
#endif
