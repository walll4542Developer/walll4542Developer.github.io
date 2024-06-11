#ifndef MMN_CHARACTER_LIGHTING_VERTICALGRADIENT
#define MMN_CHARACTER_LIGHTING_VERTICALGRADIENT

float GetVerticalGradientRemapped(float3 positionWS, CharacterData characterData)
{
    float absoluteHeadHeight = abs(characterData.headHeight);
    float verticalGradient = (positionWS.y - characterData.footHeight) / max(absoluteHeadHeight, 0.001);
    float gradientDirection = FastSign(characterData.headHeight);
    verticalGradient *= gradientDirection;
    // 기본값으로는 캐릭터의 턱 근처에서부터 1.0 초과 값, 발목 근처부터 0.0 미만 값이 나타난다.
    // 약간 보정해서 이마 위에서 발 바닥 정도까지로 잡는다. 정확히 잡을 필요는 없다.
    verticalGradient = saturate((verticalGradient + 0.05) * 0.85);
    // 안해도 식이 깨질 것 같지 않으나 일단 둔다. 나중에 빼자.
    // verticalGradient = saturate(verticalGradient);

    // const float flattenPosition = 0.4;  // 캐릭터 바닥이 0, 머리가 1. 이 값보다 작으면 셰이딩이 들어가고, 크면 점점 머리쪽으로 향할 수록 플랫해진다.
    // const float flattenWidth = 0.5;     // [0.1 ~ 0.9] 플랫으로 변하는 폭. 값이 커지면 서서히 플랫해지고, 작으면 flattenPosition 근처에서 급격하게 변한다.
    // const float flattenThreshold = 0.4; // absoluteHeadHeight가 이 값보다 작으면 전체를 플랫한 셰이딩으로 처리한다.

    // float remapped = smoothstep(flattenPosition, saturate(flattenPosition + flattenWidth), verticalGradient);
    // remapped = (absoluteHeadHeight >= flattenThreshold) ? remapped : 1.0;

    // 범위 테스트용
    // float remapped = (((verticalGradient + 0.0) * 1.0) < 0.0 || ((verticalGradient + 0.0) * 1.0) > 1.0) ? 1.0 : 0.0;
    float remapped = verticalGradient;
    return remapped;
}

#endif // MMN_CHARACTER_LIGHTING_VERTICALGRADIENT
