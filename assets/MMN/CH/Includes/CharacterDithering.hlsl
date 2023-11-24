#ifndef MMN_CHARACTER_DITHERING
#define MMN_CHARACTER_DITHERING

#include "../../Includes/EnvironmentHelper.hlsl"

void HalftoneAlphaClip(float clipStrength, float4 positionNDC)
{
    float halftoneAlpha = 1.0;
    clipStrength = 2.0 - clipStrength;
    Unity_Dither_linear(clipStrength, positionNDC, halftoneAlpha);

    halftoneAlpha *= min(1.0, halftoneAlpha);
    halftoneAlpha -= saturate(0.5 - unity_OrthoParams.w); //orth에서는 작동안되게 만들어 줍니다. 송지훈 팀장님 감사
    clip(halftoneAlpha);
}

#endif // MMN_CHARACTER_DITHERING
