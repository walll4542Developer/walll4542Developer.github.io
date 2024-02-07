#ifndef MMN_CHARACTER_LIMIT_BRIGHT_FOR_BLOOM_INCLUDED
#define MMN_CHARACTER_LIMIT_BRIGHT_FOR_BLOOM_INCLUDED

void LimitBrightForBloom(inout half3 resultColor)
{
    // 블룸값 제어를 위해 컬러의 최대값을 제한한다.
    const half3 LIMIT_BRIGHT = half3(1.0, 1.0, 1.0);
    resultColor.r = min(resultColor.r, LIMIT_BRIGHT.r);
    resultColor.g = min(resultColor.g, LIMIT_BRIGHT.g);
    resultColor.b = min(resultColor.b, LIMIT_BRIGHT.b);
}

#endif // MMN_CHARACTER_LIMIT_BRIGHT_FOR_BLOOM_INCLUDED
