#ifndef MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED
#define MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED

float4x4 _Global_PreviousViewMatrix; // ���� : MMShaderPropertySetup.cs
float4x4 _PreviousLocalToWorldMatrix;

float4x4 _CurrentWorldToLocalMatrix;
float4x4 _CurrentLocalToWorldMatrix;

// per frame, x minLengthSmoothStart, y minLengthSmoothEnd, z maxLength, w ����
float4 _MotionBlurLengthFactors;
float _MotionBlurMultiplier;
int _VertexBufferStride;

// MMN_Character_Global_Input.hlsl�� ����
// float _MotionBlurLerpValue;
// int _VertexBufferLength;

ByteAddressBuffer _PreviousVertexBuffer;

float3 GetPreviousVertexPosition(int id)
{
    float3 previousVertexPosition = float3(0, 0, 0);
    previousVertexPosition.x = asfloat(_PreviousVertexBuffer.Load(id));
    previousVertexPosition.y = asfloat(_PreviousVertexBuffer.Load(id + 4));
    previousVertexPosition.z = asfloat(_PreviousVertexBuffer.Load(id + 8));
    return previousVertexPosition;
}

float CheapSmoothstep(float a, float b, float x)
{
    float t = (x - a) / (b - a); // remap

    t = max(0.0, min(1.0, t)); // saturate

    // https://www.shadertoy.com/view/4ldSD2
    t = 1.0 - t * t; // cheap smooth step
    t = 1.0 - t * t;

    return t;
}

float3 CaculateMotionBlurVertexPositionOS(float3 positionOS, float3 normalOS, uint id)
{
    // https://deskcat.io/d/Q71720/MM-���-������Ʈ-��Ǻ���-�ٵ��
    int vertexID = min(max(0, _VertexBufferLength - 1), max(0, (int)id)) * _VertexBufferStride;

    // -- Object(model) Space
    float4 previousVertex = _VertexBufferLength == 0 ? float4(positionOS, 1.0) : float4(GetPreviousVertexPosition(vertexID), 1.0);
    //float3 previousNormal = _PreviousVertexBuffer[vertexID].normal.xyz;

    float4 currentVertex = float4(positionOS, 1.0);
    float4 currentNormal = float4(normalOS, 0.0);

    // -- Object -> World -> View Space
    previousVertex = mul(mul(_Global_PreviousViewMatrix, _PreviousLocalToWorldMatrix), previousVertex);
    float4x4 currentMatrixMV = mul(UNITY_MATRIX_V, _CurrentLocalToWorldMatrix);
    currentVertex = mul(currentMatrixMV, currentVertex);
    currentNormal = mul(currentMatrixMV, currentNormal);

    float3 motionVector = (previousVertex.xyz - currentVertex.xyz);
    float3 motionVectorNormalized = normalize(motionVector);
    float motionVectorDotNormal = dot(motionVectorNormalized, normalize(currentNormal.xyz));
    motionVectorDotNormal = max(0.0, motionVectorDotNormal);

    float3 viewDirection = mul(currentMatrixMV, float4(UNITY_MATRIX_IT_MV[2].xyz, 0.0)).xyz;
    float motionVectorDotViewDirection = dot(motionVectorNormalized, normalize(viewDirection));
    motionVectorDotViewDirection = abs(motionVectorDotViewDirection);
    motionVectorDotViewDirection = clamp(motionVectorDotViewDirection, 0.0, 1.0);
    motionVectorDotViewDirection = 1.0 - (motionVectorDotViewDirection);

    // MotionVector�� ī�޶� Forward�� ������ ���� ����ġ�� �۾�����, ������ ���� ����ġ�� Ŀ������ �Ѵ�
    // https://deskcat.io/d/R12498/MM-���-����-����-����-1-2��-3��°-����-�̹�-����-õõ��-�ٰ���-��-�̻���-�����#Shader
    motionVectorDotNormal *= motionVectorDotViewDirection;

    // -- clamp(�ּ� ����, �ִ� ����)
    // vertex motion blur�� �ʴ� 60�������� �������� �Ǿ��ִ�, �� ���� �����ӷ���Ʈ�� ���� ��� ������ ���̸� �����Ѵ�
    // �ּ� �Ӱ谪�� �����ϸ��Ѵ�
    float inverseDelta = max(0.001, unity_DeltaTime.y); // pause �� �� ���
    float frameRateRatio = 60.0 / min(60.0, inverseDelta);
    float motionBlurMinLengthSmoothStart = _MotionBlurLengthFactors.x * frameRateRatio;
    float motionBlurMinLengthSmoothEnd = _MotionBlurLengthFactors.y * frameRateRatio;

    // �ּ� ��� ����(�ּ� �Ӱ� ��) ����
    float currentMotionLength = length(motionVector);
    float minMotionLengthSmooth = CheapSmoothstep(motionBlurMinLengthSmoothStart, motionBlurMinLengthSmoothEnd, currentMotionLength);

    minMotionLengthSmooth = lerp(0.001, minMotionLengthSmooth, step(motionBlurMinLengthSmoothStart, currentMotionLength));
    motionVector = motionVector * minMotionLengthSmooth;

    // �ִ� ��� ���� ����
    currentMotionLength = length(motionVector);
    currentMotionLength = max(0.001, currentMotionLength); // ���� ���� ���(���ؽ� ��ġ�� ��ȭ�� ���� ���)
    float maxMotionLengthRatio = lerp(1.0, _MotionBlurLengthFactors.z / currentMotionLength, step(_MotionBlurLengthFactors.z, currentMotionLength));
    motionVector *= maxMotionLengthRatio;

    // -- ��Ǻ��� ȿ���� ���� ���� ���ؽ� ��ġ�� ���
    currentVertex.xyz += motionVector * motionVectorDotNormal * _MotionBlurMultiplier;

    // -- View -> World -> Object Space
    currentVertex.xyz = mul(UNITY_MATRIX_I_V, currentVertex).xyz;
    currentVertex.xyz = mul(_CurrentWorldToLocalMatrix, currentVertex).xyz;

    // 0 < _MotionBlurLerpValue <= 1.0, ��Ǻ��� ����
    // 0 == _MotionBlurLerpValue, positionOS�� �״�� ��ȯ
    return lerp(positionOS, currentVertex.xyz, _MotionBlurLerpValue);
}

#endif // #ifndef MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED