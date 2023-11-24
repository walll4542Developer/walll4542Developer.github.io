#ifndef MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
#define MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../../Includes/BendingVertex.hlsl"
#include "../../Includes/VectorRigHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    VECTOR_RIG_ATTRIBUTES(1, 2, 3, 4, 5)
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
};

Varyings DepthPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VECTOR_RIG_DEFORM_VERTEX(input, input.positionOS)
    VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

    output.positionCS = vertexInput.positionCS;

    return output;
}

float4 DepthPassFragment(Varyings input) : SV_Target
{
    return float4(1.0, 1.0, 1.0, 1.0);
}

#endif // MMN_CHARACTER_DEPTH_ONLY_PASS_INCLUDED
