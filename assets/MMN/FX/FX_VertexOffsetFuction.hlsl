#ifndef FX_VERTEXOFFSETFUCTION_INCLUDED
#define FX_VERTEXOFFSETFUCTION_INCLUDED

float3 AnimateVertexOffset(real offsetMode, real4 vertexColor, float3 velocityVector, float velocityScala,
    float timeSpeed, float sinScope, float sphereOfInfluence, float3 direction, float threshold)
{
    // 버텍스 컬러
    real4 unpackVertexColor = vertexColor;
    unpackVertexColor.z = ((vertexColor.z * 2.0) - 1.0) * 0.1; // [-0.1 ~ 0.1]

    // 시간 값이 계속 흐르다가 오버플로우 나지 않게 frac를 사용하여 소숫점만 반복하여 사용합니다.
    float time = frac(_Time.y * 0.001); // [0.000 ~ 1.000]
    time = time * 1000.0; // [0.0 ~ 1.0]

    // 커스텀 데이터와 timeSpeed 중 높은 쪽으로 속도를 조절합니다.
    time = time * max(timeSpeed, velocityScala);

    // sin 함수와 time으로 버텍스들을 움직입니다.
    float sinOffset = sin((unpackVertexColor.z * sinScope) + time); // [-1 ~ 1]

    // sphereOfInfluence 을 조절하여 버텍스 컬러를 통해 움직임을 제어합니다.
    sinOffset = sinOffset * (1.0 + (vertexColor.z * (sphereOfInfluence - 1.0))); // [-1 ~ 1] * [0 ~ 0.9]

    // 기존 노드에서 셰이더 교체 시 결과를 그대로 옮겨오기 위해 넣어줍니다.
    // 파티클 시스템 커스텀 데이터에 Velocity와 (외부 프로퍼티로 지정한) 움직일 방향을 외적하여 움직일 방향축을 정합니다.
    float3 moveDirection = direction;
    if (offsetMode <= 0.5)
    {
        moveDirection = normalize(cross(velocityVector, direction));
    }

    // 최종 결과물
    float3 finalOffset = moveDirection * sinOffset * threshold;
    return finalOffset;
}

#endif