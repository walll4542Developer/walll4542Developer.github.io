#ifndef MMN_CHARACTER_INFLATE_HELPER
#define MMN_CHARACTER_INFLATE_HELPER

#include "../MMN_Character_Global_Input.hlsl"

float3 CharacterInflateWidth(float3 positionOS, float3 normalOS, float inflateWidth)
{
    float maskedWidth = 0.1 * max(0.0, inflateWidth);
    float3 offset = normalOS * maskedWidth;
    return positionOS.xyz + offset;
}

void ApplyInflateColor(inout float3 resultColor, float inflateWidth, float4 inflateColor)
{
    float width = pow(max(0.0, inflateWidth), 0.03);
    resultColor = lerp(resultColor, inflateColor.rgb, saturate(width));
}

#endif // MMN_CHARACTER_INFLATE_HELPER
