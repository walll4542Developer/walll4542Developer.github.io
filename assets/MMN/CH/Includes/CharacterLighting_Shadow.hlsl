#ifndef MMN_CHARACTER_LIGHTING_RECEIVESHADOW
#define MMN_CHARACTER_LIGHTING_RECEIVESHADOW

//-----------------------------------------------------------------------------
// Received shadow
// receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
//                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
//-----------------------------------------------------------------------------
float GetReceivedShadow(float3 lightDirWS, float3 positionWS, float3 characterCenterPos,
    float visualHeight, float topShadow, float bottomShadow)
{
    float cloudShadow = MMN_GlobalTex_CloudShadows(positionWS.xyz).r;

    // NOTE @jihun.song
    // 0이면 그림자를 받지 않는상태, 1이면 그림자를 받는 상태라고 스크립트에서 넘어온다.
    // 이렇게 넘어온 값을 계산의 편의를 위해 역수로 사용한다.
    //
    // (그림자는 어두워야 하므로 0으로 사용하기 위해서인데, 그러면 왜 스크립트에서 그림자를 받는 상태를 0,
    // 그림자를 받지 않는 상태를 1로 하지 않았냐면 다음과 같은 이유가 있어서 이다.
    // 실제로 들어오는 값인 _TopShadow, _BottomShadow 글로벌 프로퍼티의 기본 값은 0으로 설정이 되는데
    // 이 값을 그대로 사용하면, 즉 그림자를 받는 상태가 0인 상태로 사용하게 되면 기본 값이 그림자를 받고 있는
    // 상태가 되기 때문에, 스크립트에서 값을 넣어주지 않는 한, 항상 그림자를 받고 있는, 즉 어두운 상태로 되기 때문이다.)
    topShadow = 1.0 - topShadow;
    bottomShadow = 1.0 - bottomShadow;

    float gradientWidth = visualHeight * 0.5;

    float3 lightTangent = cross(lightDirWS, float3(0, 1, 0));
    lightTangent = cross(lightDirWS, lightTangent);

    float shadowGradient = dot(lightTangent, positionWS - characterCenterPos);
    shadowGradient = saturate(shadowGradient / gradientWidth + 0.5);

    float receivedShadow = lerp(topShadow, bottomShadow, shadowGradient);
    receivedShadow = min(receivedShadow, cloudShadow);
    receivedShadow = min(1.0, smoothstep(0.0, 1.0, saturate(receivedShadow * 2.0 - 0.5)));

    if (_CustomLightMode == 1)
    {
        receivedShadow = 1.0;
    }

    return receivedShadow;
}

// NOTE @jihun.song - 22.09.19 : 그림자를 받는 부분이 spreadAmount에 의해 값이 스텝처럼 되어서 임시로 막아둠.
float GetReceivedShadow2(float3 lightDirWS, float3 positionWS, float3 characterCenterPos, float visualHeight,
    float topShadow, float bottomShadow)
{
    float cloudShadow = MMN_GlobalTex_CloudShadows(positionWS.xyz).r;

    topShadow = 1.0 - topShadow;
    bottomShadow = 1.0 - bottomShadow;

    // 약식 그라데이션 그림자
    // 캐릭터 중심으로부터의 거리에 라이트를 곱해서 그라데이션을 만듦
    // 캐릭터 크기에 영향을 받아서 정확한 모양이 나오지 않을 것이나 그라데이션 모양은 매우 예쁘게 잡히고 셰이더가 간단해진다.
    // 몬스터 같이 바운딩 박스 사이즈가 크면 별로 안예쁘게 나올 수 밖에 없음
    // 몬스터는 사용하지 않는게 좋을 것 같다.
    float spreadAmount = visualHeight * 4.0;
    float3 centerOffset = float3(0, -0.5, 0);
    float lightMask = dot(float3(1, -1, 1) * spreadAmount * (characterCenterPos - positionWS) + centerOffset, lightDirWS);
    float receivedShadow = lerp(bottomShadow, topShadow, saturate(lightMask));
    receivedShadow = min(receivedShadow, cloudShadow);

    if (_CustomLightMode == 1)
    {
        receivedShadow = 1.0;
    }

    return receivedShadow;
}

#endif // MMN_CHARACTER_LIGHTING_RECEIVESHADOW
