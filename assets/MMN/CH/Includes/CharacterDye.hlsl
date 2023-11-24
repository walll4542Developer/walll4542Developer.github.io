#ifndef MMN_CHARACTER_DYE_HELPER
#define MMN_CHARACTER_DYE_HELPER

#ifdef _DYE_FEATURE

// 텍스쳐가 sRGB 모드일 경우(sRGB 체크 일 때)에 아래 값을 1로 설정해야한다.
#define SRGB_TEXTURE_MODE 1

static const float ReferenceColorValue = 1.347368421; // 192 기준 그레이 컬러일 때 염색 컬러가 그대로 나오게 하는 보정 값
static const float ThresholdMask = 0.0078125; // 마스크의 플로팅 오차를 보정하기 위한 값

inline float3 DyedColor(float3 texColor, float3 maskColor, float3 dyeColor1, float3 dyeColor2, float3 dyeColor3)
{
    float3 finalColor;

    float3 originalColor = texColor * saturate(1.0f - maskColor.r - maskColor.g - maskColor.b); // original color
    float3 dyeColor = dyeColor1 * maskColor.r + dyeColor2 * maskColor.g + dyeColor3 * maskColor.b; // dye color
    float isMaskArea = step(0.001, (maskColor.r + maskColor.g + maskColor.b));

    //------------------------------
    // 0 ~ 0.7529412(192): MULTIPLY
    // 0.7568627(193) ~ 1: SCREEN
    //------------------------------
    float3 srgbTexColor = FastLinearToSRGB(texColor);
    float3 offset = srgbTexColor - float3(0.7529412, 0.7529412, 0.7529412); // delta color

    float3 cLow = dyeColor * srgbTexColor * ReferenceColorValue; // low range color (dyeColor multiplied by normalized-texColor)
    float3 cHigh = offset + dyeColor - (offset * dyeColor); // SCREEN

    float3 s = step(float3(0.0f, 0.0f, 0.0f), offset); // 0, 1 switch
    float3 dyedColor = saturate(lerp(cLow, cHigh, s)) * isMaskArea;
    finalColor = saturate(originalColor + dyedColor);

    return finalColor;
}

void ApplyDyeColor(inout float3 resultColor, float4 dyeColor1)
{
    resultColor = DyedColor(resultColor.rgb, float3(1, 0, 0), dyeColor1.rgb, float3(1, 1, 1), float3(1, 1, 1));
}

void ApplyDyeColorOnlyMask(inout float3 resultColor, float4 dyeColor1, float4 dyeColor2, float4 dyeColor3)
{
    // resultColor = DyedColor(float3(1, 1, 1), resultColor.rgb, dyeColor1.rgb, dyeColor2.rgb, dyeColor3.rgb);
    resultColor = dyeColor1.rgb * resultColor.r + dyeColor2.rgb * resultColor.g + dyeColor3.rgb * resultColor.b;
}

// 압축 공식
// float3 override = step(0.001, maskMap.r + maskMap.g + maskMap.b);
// float3 r1 = baseMap.rgb * 0.5 + 0.5;
// float3 r2 = (1.0 - (maskMap.rgb * baseMap.rgb)) * 0.5;
// float3 c = (r1 * (1.0 - override)) + (r2 * override);

// 풀기 공식
// float3 base = max(0.0, (compressedColor - 0.5) * 2.0);
// float3 mask = (1.0 - min(1.0, compressedColor * 2.0));

void ApplyDyeColor(inout float3 resultColor, float4 dyeColor1, float4 dyeColor2, float4 dyeColor3)
{
    float3 compressedColor = resultColor.rgb;
    #if SRGB_TEXTURE_MODE
        compressedColor = FastLinearToSRGB(compressedColor);
    #endif

    float3 base = max(0.0, (compressedColor - 0.5) * 2.0);
    float3 mask = (1.0 - min(1.0, compressedColor * 2.0));

    float3 originalColor = FastSRGBToLinear(base);

    float3 dyedColor1 = dyeColor1.rgb * (step(ThresholdMask, mask.r) * mask.r);
    float3 dyedColor2 = dyeColor2.rgb * (step(ThresholdMask, mask.g) * mask.g);
    float3 dyedColor3 = dyeColor3.rgb * (step(ThresholdMask, mask.b) * mask.b);

    float3 dyedColor = dyedColor1 + dyedColor2 + dyedColor3;
    dyedColor *= ReferenceColorValue;
    resultColor = saturate(dyedColor + originalColor);

    // NOTE @jihun.song
    // 압축되어 넘어온 컬러에는 마스크에 베이스의 계조가 합성(곱하기)되어 있는 상태이다.
    // 기존 처럼 0.75(기준 컬러 192)를 기준으로 곱/스크린 연산 중 하나를 선택할 때
    // 마스크 컬러를 기준으로 해야한다. (베이스에는 계조가 없고 오리지널 컬러만 있음)
    //
    // 마스크 컬러에서 0.75 이상일 때 스크린 연산을 하는 공식을 그대로 적용하면
    // 일부 의도와 다른 경우(스크린 연산이어야 하는데 아닌 경우)가 발생할 수 있다.
    // 예를 들어, 압축하기 전 베이스의 계조가 0.75이고 마스크가 1이면 합성되어 넘어온 계조
    // 즉, 마스크에 들어가 있는 계조가 그대로 0.75이기 때문에 문제는 없다.
    // 하지만 베이스가 0.75였는데 마스크가 1보다 작은 값이라면, 0.8 정도였다면,
    // 합성되어 넘어온 계조의 값은 0.6(위 압축공식과 풀기공식에 대입)이 되기 때문에
    // 기준인 0.75보다 작아서 스크린 연산이 되지 않는다.
    //
    // 그래서 일단 스크린 연산을 하는 것은 보류함.
    //
    // https://deskcat.io/d/O70657/MM-미술-채택-베이스-텍스쳐의-RGB-채널에-마스크-넣기
}

// half3 RgbToHsv(half3 c)
// {
//     const half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
//     half4 p = lerp(half4(c.bg, K.wz), half4(c.gb, K.xy), step(c.b, c.g));
//     half4 q = lerp(half4(p.xyw, c.r), half4(c.r, p.yzx), step(p.x, c.r));
//     half d = q.x - min(q.w, q.y);
//     const half e = 1.0e-4;
//     return half3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
// }

// 스킨 컬러를 적용할 때 스킨 컬러의 70퍼센트만 곱해준다.
// 이 공식은 포토샵에서 스킨 컬러 레이어를 70퍼센트 Opacity로
// 아래 오리지널 컬러 레이어와 Multiply 해주는 것과 같다.
float3 ApplySkinColorForScar(float3 originalColor, float3 skinColor)
{
    float layerOpacity = 1.0;
    
    // Hue, Saturation, Value
    // Ranges:
    //  Hue [0.0, 1.0]
    //  Sat [0.0, 1.0]
    //  Lum [0.0, HALF_MAX]
    float3 skinColorHSV = RgbToHsv(skinColor);
    float3 originalColorHSV = RgbToHsv(originalColor);

    // 흉터는 명도로 구분
    layerOpacity = saturate(layerOpacity - lerp(0, 0.1, skinColorHSV.z)/*명도를 정규화 하지 않고 매직 넘버를 사용한다.*/);

    // 홍조는 채도로 구분
    // if (originalColorHSV.y > 0.5) // 일정 채도 보다 높으면 
    // {
    //     layerOpacity = 0; // 홍조 텍스쳐 그대로 나감
    //     originalColorHSV.y = saturate(originalColorHSV.y - 0.1); // 매직 넘버
    //     originalColor = HsvToRgb(originalColorHSV);
    // }

    if (originalColorHSV.y > 0.5) // 일정 채도 보다 높으면 
    {
        layerOpacity = lerp(0.7, 0.0, skinColorHSV.z);
        originalColorHSV.y = saturate(originalColorHSV.y + lerp(0.3, -0.16, skinColorHSV.z) * 0.6 + (lerp(-0.04, 0.45, pow(skinColorHSV.y, 3)))); // 매직 넘버
        originalColorHSV.z = originalColorHSV.z + lerp(-0.34, 0.2, skinColorHSV.z); // 매직 넘버
        originalColor = HsvToRgb(originalColorHSV);
    }

    return ((skinColor * layerOpacity) + (1.0 - layerOpacity)) * originalColor;
}

float3 ApplySkinColorForTattoo(float3 originalColor, float3 skinColor)
{
    float layerOpacity = 0.7;
    return ((skinColor * layerOpacity) + (1.0 - layerOpacity)) * originalColor;
}

float3 ApplySkinColor(float3 originalColor, float3 skinColor)
{
    const float layerOpacity = 0.7;
    return ((skinColor * layerOpacity) + (1.0 - layerOpacity)) * originalColor;
}

// 모노톤은 스킨 컬러를 좀 더 강하게 적용한다. 이유는 오리지널 컬러가 밝은 상태이기 때문에
// 스킨 컬러보다 오리지널 컬러의 비중이 높으면 너무 하얗게 떠 보이는 문제가 있다.
float3 ApplySkinColorForMonotone(float3 originalColor, float3 skinColor)
{
    const float layerOpacity = 0.99;
    return ((skinColor * layerOpacity) + (1.0 - layerOpacity)) * originalColor;
}

#endif // _DYE_FEATURE

#endif // MMN_CHARACTER_DYE_HELPER
