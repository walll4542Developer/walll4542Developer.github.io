#ifndef MMN_CHARACTER_EMISSION
#define MMN_CHARACTER_EMISSION

#include "Assets/PatchableAssets/Shaders/MMN/Includes/Night2DayControl.hlsl"

half3 ApplyEmissionColor(half3 emissionMap, half3 emissionColor,
    half isEnableEmissionAtNight, half isBreathingEmissionMode, half breathingEmissionModePeriod)
{
    half3 emissionBase = emissionMap * emissionColor;

    breathingEmissionModePeriod = max(0.0001, breathingEmissionModePeriod);
    half breathing = sin(_Time.y * PI / breathingEmissionModePeriod) * 0.5 + 0.5;
    half3 breathingEmission = lerp(emissionBase * 0.3, emissionBase, breathing);

    half3 emissionResult = lerp(emissionBase, breathingEmission, isBreathingEmissionMode);
    emissionResult *= (1.0 - (_Global_Night2Day * isEnableEmissionAtNight));

    return emissionResult;
}

half3 ApplyEmissionColorLOD(in half3 resultColor, half3 emissionMap, half3 emissionColor,
    half isEnableEmissionAtNight)
{
    half3 emissionResult = emissionMap * emissionColor;
    emissionResult *= (1.0 - (_Global_Night2Day * isEnableEmissionAtNight));

    return emissionResult;
}

#endif // MMN_CHARACTER_EMISSION
