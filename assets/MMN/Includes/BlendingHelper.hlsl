#ifndef BLENDING_HELPER_INCLUDED
#define BLENDING_HELPER_INCLUDED

real3 OverlayBlend(real3 src, real3 dst)
{
    // 원래 공식 - if 가 들어간다
    // real3 blendResult = (dst > 0.5) ? (1.0 - (2.0 * (1.0 - src) * (1.0 - dst))) : (2.0 * src * dst);

    // if를 없애고 계산식으로 대체한 공식
    real3 blend1 = (1.0 - (2.0 * (1.0 - src) * (1.0 - dst)));
    real3 blend2 = (2.0 * src * dst);

    real3 split = saturate(ceil(dst - 0.5));
    real3 blendResult = blend1 * split + blend2 * (1.0 - split);

    return saturate(blendResult);
}

real3 LinearLightBlend(real3 src, real3 dst)
{
    // 원래 공식 - if 가 들어간다
    // real3 blendResult = (src > 0.5) ? (dst + (2.0 * src) - 1.0) : (dst + (2.0 * (src - 0.5)));

    // if를 없애고 계산식으로 대체한 공식
    real3 blend1 = (dst + (2.0 * src) - 1.0);
    real3 blend2 = (dst + (2.0 * (src - 0.5)));

    real3 split = saturate(ceil(dst - 0.5));
    real3 blendResult = blend1 * split + blend2 * (1.0 - split);

    return saturate(blendResult);
}

real3 ScreenBlend(real3 src, float strength)
{
    real3 blendResult = 1.0 - (1.0 - src) * (1.0 - strength);
    return saturate(blendResult);
}

real3 TextureTintBlend(real3 src, real3 tint, float strength) // strength: [-1.0 ~ 1.0]

{
    real3 tintPower = lerp(src, tint, saturate(strength));
    real3 blend1 = lerp(real3(0, 0, 0), tint, tintPower);
    real3 blend2 = (src * tint * (strength + 1.0));

    float split = saturate(strength);
    real3 blendResult = blend1 * split + blend2 * (1.0 - split);

    return saturate(blendResult);
}

#endif // BLENDING_HELPER_INCLUDED
