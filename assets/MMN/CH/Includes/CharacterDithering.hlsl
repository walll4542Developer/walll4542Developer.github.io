#ifndef MMN_CHARACTER_DITHERING
#define MMN_CHARACTER_DITHERING

#include "../../Includes/EnvironmentHelper.hlsl"

void HalftoneAlphaClip(float clipStrength, float4 positionNDC)
{
    float halftoneAlpha = 1.0;
    float transition = saturate(abs(1 - clipStrength)); // 정규화된 트랜지션이 아닌 거리 값(1 초과)이 들어와서 음수가 되도 양수로 바꿔줍니다.
    Unity_Dither_linear(transition, positionNDC, halftoneAlpha);
    
    halftoneAlpha = lerp(halftoneAlpha, 1, unity_OrthoParams.w); // Ortho 에서는 동작 안하게 합니다.
    clip(halftoneAlpha);
}

#endif // MMN_CHARACTER_DITHERING
