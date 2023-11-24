#ifndef MMN_CHARACTER_EMISSION
#define MMN_CHARACTER_EMISSION

#include "Assets/PatchableAssets/Shaders/MMN/Includes/Night2DayControl.hlsl"

float3 ApplyEmissionColor(float3 emissionMap, float3 emissionColor,
    float isEnableEmissionAtNight, float isBreathingEmissionMode, float breathingEmissionModePeriod)
{
    float3 emissionBase = emissionMap * emissionColor;

    breathingEmissionModePeriod = max(0.0001, breathingEmissionModePeriod);
    float breathing = sin(_Time.y * PI / breathingEmissionModePeriod) * 0.5 + 0.5;
    float3 breathingEmission = lerp(emissionBase * 0.3, emissionBase, breathing);

    float3 emissionResult = lerp(emissionBase, breathingEmission, isBreathingEmissionMode);
    emissionResult *= (1.0 - (_Global_Night2Day * isEnableEmissionAtNight));

    return emissionResult;
}

float3 ApplyEmissionColorLOD(in float3 resultColor, float3 emissionMap, float3 emissionColor,
    float isEnableEmissionAtNight)
{
    float3 emissionResult = emissionMap * emissionColor;
    emissionResult *= (1.0 - (_Global_Night2Day * isEnableEmissionAtNight));

    return emissionResult;
}

#endif // MMN_CHARACTER_EMISSION
