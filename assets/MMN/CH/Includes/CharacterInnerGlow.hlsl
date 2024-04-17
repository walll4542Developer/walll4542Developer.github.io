#ifndef MMN_CHARACTER_FX_INNER_GLOW_INCLUDED
#define MMN_CHARACTER_FX_INNER_GLOW_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../MMN_Character_Global_Input.hlsl"

void ApplyInnerGlow(inout float3 color, float3 viewDirWS, float3 normalWS,
    float innerGlow, float innerGlowPower, float4 innerGlowColor)
{
    float fresnel = 1.0 - saturate(dot(normalWS, viewDirWS));
    fresnel = pow(fresnel, innerGlowPower);
    fresnel = saturate(fresnel);
    color = lerp(color, innerGlowColor.rgb, saturate(fresnel * innerGlow));
}

#endif // MMN_CHARACTER_FX_INNER_GLOW_INCLUDED
