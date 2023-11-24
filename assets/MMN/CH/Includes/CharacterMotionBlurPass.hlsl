#ifndef MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED
#define MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED

float4x4 _Global_PreviousViewMatrix; // 참고 : MMShaderPropertySetup.cs
float4x4 _PreviousLocalToWorldMatrix;

float4x4 _CurrentWorldToLocalMatrix;
float4x4 _CurrentLocalToWorldMatrix;

// per frame, x minLengthSmoothStart, y minLengthSmoothEnd, z maxLength, w 예비
float4 _MotionBlurLengthFactors; 
float _MotionBlurMultiplier;
int _VertexBufferStride;

// MMN_Character_Global_Input.hlsl에 명세
// float _MotionBlurLerpValue;
// int _VertexBufferLength;

ByteAddressBuffer _PreviousVertexBuffer;

float3 GetPreviousVertexPosition(int id) {
    float3 previousVertexPosition = float3(0, 0, 0);
    previousVertexPosition.x = asfloat(_PreviousVertexBuffer.Load(id));
    previousVertexPosition.y = asfloat(_PreviousVertexBuffer.Load(id + 4));
    previousVertexPosition.z = asfloat(_PreviousVertexBuffer.Load(id + 8));
    return previousVertexPosition;
}

float cheapsmoothstep(float a, float b, float x)
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
    // https://deskcat.io/d/Q71720/MM-기술-오브젝트-모션블러-다듬기
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
    float motionVectorDotNormal = dot(normalize(motionVector), normalize(currentNormal.xyz));
    motionVectorDotNormal = max(0.0, motionVectorDotNormal);

    // -- clamp(최소 길이, 최대 길이)
    // vertex motion blur는 초당 60프레임을 기준으로 되어있다, 이 보다 프레임레이트가 낮을 경우 적절한 길이를 추정한다
    // 최소 임계값을 스케일링한다
    float inverseDelta = max(0.001, unity_DeltaTime.y); // pause 일 때 대비
    float frameRateRatio = 60.0 / min(60.0, inverseDelta);
    float motionBlurMinLengthSmoothStart = _MotionBlurLengthFactors.x * frameRateRatio;
    float motionBlurMinLengthSmoothEnd = _MotionBlurLengthFactors.y * frameRateRatio;

    // 최소 모션 길이(최소 임계 값) 적용
    float currentMotionLength = length(motionVector);
    float minMotionLengthSmooth = cheapsmoothstep(motionBlurMinLengthSmoothStart, motionBlurMinLengthSmoothEnd, currentMotionLength);

    minMotionLengthSmooth = lerp(0.001, minMotionLengthSmooth, step(motionBlurMinLengthSmoothStart, currentMotionLength));
    motionVector = motionVector * minMotionLengthSmooth;

    // 최대 모션 길이 적용
    currentMotionLength = length(motionVector);
    currentMotionLength = max(0.001, currentMotionLength); // 정지 상태 대비(버텍스 위치에 변화가 없는 경우)
    float maxMotionLengthRatio = lerp(1.0, _MotionBlurLengthFactors.z / currentMotionLength, step(_MotionBlurLengthFactors.z, currentMotionLength));
    motionVector *= maxMotionLengthRatio;

    // -- 모션블러 효과로 인한 최종 버텍스 위치를 계산
    currentVertex.xyz += motionVector * motionVectorDotNormal * _MotionBlurMultiplier;

    // -- View -> World -> Object Space
    currentVertex.xyz = mul(UNITY_MATRIX_I_V, currentVertex).xyz;
    currentVertex.xyz = mul(_CurrentWorldToLocalMatrix, currentVertex).xyz;

    // 0 < _MotionBlurLerpValue <= 1.0, 모션블러 적용
    // 0 == _MotionBlurLerpValue, positionOS를 그대로 반환
    return lerp(positionOS, currentVertex.xyz, _MotionBlurLerpValue);
}
#endif // #ifndef MMN_CHARACTER_MOTION_PASS_VERTEX_INCLUDED