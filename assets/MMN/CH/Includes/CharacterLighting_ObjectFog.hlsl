#ifndef MMN_CHARACTER_LIGHTING_OBJECTFOG
#define MMN_CHARACTER_LIGHTING_OBJECTFOG

//-----------------------------------------------------------------------------
// Object fog
//-----------------------------------------------------------------------------
// 캐릭터의 중심점에서 먼 쪽으로 칠하는 fog
// 먼 쪽 다리를 단색으로 빼면 공간감이 살기 때문에 구현하는 것이다.
// 문제1: 캐릭터가 쓰러졌다거나 중심점에서부터 멀어지는 애니메이션을 할 경우 이상해지는 것
// 문제2: 캐릭터별로 중심점을 전달해주어야 함
// 문제3: 몬스터 같이 바운딩 박스가 클 경우 먼쪽이 매우 별로로 보인다.
// 달리기 할 때 다리가 예쁘게 보이는 정도로 튜닝은 해두었음.
// 주석을 풀면 볼 수 있다.
// 그냥 하지말자... -_-

// void CharacterObjectFog(inout half3 resultColor, half3 positionWS, half3 characterPos, half visualHeight, half power, half4 fogColor)
// {
//     // half3 cameraPos = GetCameraPositionWS() - inputData.positionWS.xyz;
//     // half3 charPos = characterPos - inputData.positionWS.xyz;
//     // half mask = saturate(dot(half2(cameraPos.xz), half2(charPos.xz)) * 1.0) * (1.0 -verticalGradientRemapped); // y축 제거
//     // half3 fogColor = 0.1 * lightingData.giColor;
//     // resultColor = lerp(resultColor,fogColor,mask);
// }

// void CharacterObjectFog2(inout half3 resultColor, half3 positionWS, half3 characterPos, half visualHeight, half power, half4 fogColor)
// {
//     // half3 cameraPos = GetCameraPositionWS() - positionWS.xyz;
//     // half3 charPos = half3(characterPos.x, characterPos.y + (visualHeight * 0.5), characterPos.z) - positionWS.xyz;
//     // half mask = saturate(dot(cameraPos, half3(charPos.x, 0, charPos.z))); // y축 제거
//     // half flat = 1 - saturate(dot(half3(0, 1, 0), positionWS.xyz - characterPos.xyz));
//     // mask = pow(mask, power) * flat; // 0.45
//     // resultColor = lerp(resultColor, resultColor * fogColor.rgb, mask);
//     // resultColor = mask;
// }


#endif // MMN_CHARACTER_LIGHTING_OBJECTFOG
