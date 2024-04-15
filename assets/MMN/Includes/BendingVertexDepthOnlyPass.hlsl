//인클루드 경로
//#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertexDepthOnlyPass.hlsl"
#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/BendingVertex.hlsl"

struct Attributes
{
    float4 position : POSITION;
    float2 texcoord : TEXCOORD0;
    float4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    float4 color : COLOR;
    float4 screenPos : TEXCOORD1;
    float3 viewDir : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    // output.positionCS = TransformObjectToHClip(input.position.xyz);


    //카메라 각도에 따라 휘어지는 범위를 조정
    // float3 cameraForwardVector = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
    // _Global_VertexPositionOffset.y += cameraForwardVector.y * _Global_VertexPositionOffset.z;

    // float3 positionWS = TransformObjectToWorld(input.position.rgb);
    // float3 positionVS = TransformWorldToView(positionWS);
    
    // //휘어지기
    // float zOffset = positionVS.z/(_Global_VertexPositionOffset.a+0.000001);//0으로 나누는 사태를 방지하기 위해
    // positionVS += float3(_Global_VertexPositionOffset.xy,0)*zOffset*zOffset*zOffset;

    // output.positionCS = TransformWViewToHClip(positionVS.rgb);



    VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.position.xyz);


    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.screenPos = ComputeScreenPos(output.positionCS);
    float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.viewDir = viewDirWS;
    output.positionCS = vertexInput.positionCS;
    return output;
}

float4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
    return 0;
}
#endif
