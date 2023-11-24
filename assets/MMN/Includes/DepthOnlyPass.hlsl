//배경에선 사용 안합니다. 벡터리깅 백업용? 캐릭터쪽에서 쓰나요? 

#ifndef DEPTH_ONLY_PASS_INCLUDED
#define DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//#include "../VectorRigHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    //VECTOR_RIG_ATTRIBUTES(1, 2, 3, 4, 5)

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    //VECTOR_RIG_DEFORM_VERTEX(input, input.positionOS)

    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    return output;
}

real frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);

    return 1.0;
}

#endif // DEPTH_ONLY_PASS_INCLUDED
