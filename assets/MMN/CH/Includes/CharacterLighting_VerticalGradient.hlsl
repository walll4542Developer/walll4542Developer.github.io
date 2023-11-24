#ifndef MMN_CHARACTER_LIGHTING_VERTICALGRADIENT
#define MMN_CHARACTER_LIGHTING_VERTICALGRADIENT

float GetVerticalGradientRemapped(float3 positionWS, CharacterData characterData)
{
    const float flatnessPosition = 0.4; // 캐릭터 바닥이 0, 머리가 1. 이 값보다 작으면 셰이딩이 들어가고, 크면 점점 머리쪽으로 향할 수록 플랫해진다.
    const float flatnessWidth = 0.5; // [0.1 ~ 0.9] 플랫으로 변하는 폭. 값이 커지면 서서히 플랫해지고, 작으면 flatnessPosition 근처에서 급격하게 변한다.

    float verticalGradient = (positionWS.y - characterData.characterPos.y) / max(characterData.visualHeight, 0.001);
    float remapped = smoothstep(flatnessPosition, saturate(flatnessPosition + flatnessWidth), verticalGradient);
    return remapped;
}

#endif // MMN_CHARACTER_LIGHTING_VERTICALGRADIENT
