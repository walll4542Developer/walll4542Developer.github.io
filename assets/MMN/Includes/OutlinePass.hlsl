#ifndef OUTLINE_PASS_INCLUDED
#define OUTLINE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//#include "../VectorRigHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    //VECTOR_RIG_ATTRIBUTES(1, 2, 3, 4, 5)

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

float4 _OutlineColor;
float _OutlineWidth;

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    //VECTOR_RIG_DEFORM_VERTEX(input, input.positionOS)
    
    output.uv = input.texcoord;

    //Select Normal
    float3 normal = input.normalOS.xyz;
    #ifdef _SMOOTHNORMAL_ON
        //normal = input.tangentOS.xyz;
    #endif

    #ifdef _SMOOTHNORMAL_ON
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
        float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalize(normal));

        //Normalized Device Coordinates (NDC)
        float3 NDCNormal = normalize(mul((float3x3)UNITY_MATRIX_P, viewNormal)) * output.positionCS.w;
        float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
        float aspect = abs(nearUpperRight.y / nearUpperRight.x);
        NDCNormal.x *= aspect;
        output.positionCS.xy += _OutlineWidth * NDCNormal.xy;
    #else
        float3 outlinePos = input.positionOS.xyz + normalize(normal) * _OutlineWidth;
        output.positionCS = TransformObjectToHClip(outlinePos);
    #endif

    return output;
}

float4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);

    float4 resultColor;

    resultColor.rgb = _OutlineColor.rgb;
    resultColor.a = 1;
    
    return resultColor;
}
#endif // OUTLINE_PASS_INCLUDED
