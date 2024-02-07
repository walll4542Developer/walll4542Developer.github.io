// #ifndef MMN_CHARACTER_INFLATE_HELPER
// #define MMN_CHARACTER_INFLATE_HELPER

// #include "../MMN_Character_Global_Input.hlsl"

// float3 CharacterInflateWidth(float3 positionOS, float3 normalOS, half inflateWidth)
// {
//     half maskedWidth = 0.1 * max(0.0, inflateWidth);
//     float3 offset = normalOS * maskedWidth;
//     return positionOS.xyz + offset;
// }

// void ApplyInflateColor(inout half3 resultColor, half inflateWidth, half4 inflateColor)
// {
//     half width = pow(max(0.0, inflateWidth), 0.03);
//     resultColor = lerp(resultColor, inflateColor.rgb, saturate(width));
// }

// #endif // MMN_CHARACTER_INFLATE_HELPER
