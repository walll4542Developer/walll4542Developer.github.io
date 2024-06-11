#ifndef VECTOR_RIG_HLSL_HELPER_INCLUDED
#define VECTOR_RIG_HLSL_HELPER_INCLUDED

#ifdef _VECTOR_RIG
    int useNormal = 0;
    int useUV = 0;
    float scaleFactor = 1;
    float4x4 posCodeMats[16];
    float4x4 normCodeMats[16];
    float4x4 uvCodeMats[16];
    float4x4 boneToObject;

    void deform(in float4 weights0, in float4 weights1, in float4 weights2, in float4 weights3, in float2 groupId,
        inout float4 vertex)
    {
        int gid = (int)(groupId[0]) * 4;

        float4 posDeformVec = mul(posCodeMats[gid], weights0)
                            + mul(posCodeMats[gid+1], weights1)
                            + mul(posCodeMats[gid+2], weights2)
                            + mul(posCodeMats[gid+3], weights3);

        posDeformVec *= scaleFactor;
        posDeformVec = mul(boneToObject, posDeformVec);

        vertex = vertex + posDeformVec;
    }
    
    void deform(in float4 weights0, in float4 weights1, in float4 weights2, in float4 weights3, in float2 groupId,
        inout float4 vertex, inout float3 normal, inout float2 uv)
    {
        float4 posDeformVec = float4(0, 0, 0, 0);
        float4 normDeformVec = float4(0, 0, 0, 0);
        float4 uvDeformVec = float4(0, 0, 0, 0);

        int gid = (int)(groupId[0]) * 4;

        posDeformVec =
            mul(posCodeMats[gid], weights0)
            + mul(posCodeMats[gid+1], weights1)
            + mul(posCodeMats[gid+2], weights2)
            + mul(posCodeMats[gid+3], weights3);

        posDeformVec *= scaleFactor;
        posDeformVec = mul(boneToObject, posDeformVec);

        if (useNormal != 0)
        {
            normDeformVec =
                mul(normCodeMats[gid], weights0)
                + mul(normCodeMats[gid+1], weights1)
                + mul(normCodeMats[gid+2], weights2)
                + mul(normCodeMats[gid+3], weights3);
        }

        if (useUV != 0)
        {
            uvDeformVec =
                mul(uvCodeMats[gid], weights0)
                + mul(uvCodeMats[gid+1], weights1)
                + mul(uvCodeMats[gid+2], weights2)
                + mul(uvCodeMats[gid+3], weights3);
        }

        vertex = vertex + posDeformVec;
        normal = normal + normDeformVec.xyz;
        uv = uv + uvDeformVec.xy;
    }

    #define VECTOR_RIG_ATTRIBUTES(idx1, idx2, idx3, idx4, idx5) \
        float4 weights0 : TEXCOORD##idx1; \
        float4 weights1 : TEXCOORD##idx2; \
        float4 weights2 : TEXCOORD##idx3; \
        float4 weights3 : TEXCOORD##idx4; \
	    float2 groupId : TEXCOORD##idx5;

    #define VECTOR_RIG_DEFORM_VERTEX(input, vertex) deform(input.weights0, input.weights1, input.weights2, input.weights3, input.groupId, vertex);
    #define VECTOR_RIG_DEFORM(input, vertex, normal, uv) deform(input.weights0, input.weights1, input.weights2, input.weights3, input.groupId, vertex, normal, uv);
#else
    #define VECTOR_RIG_ATTRIBUTES(idx1, idx2, idx3, idx4, idx5)
    #define VECTOR_RIG_DEFORM_VERTEX(input, vertex)
    #define VECTOR_RIG_DEFORM(input, vertex, normal, uv)
#endif

#endif // VECTOR_RIG_HLSL_HELPER_INCLUDED
