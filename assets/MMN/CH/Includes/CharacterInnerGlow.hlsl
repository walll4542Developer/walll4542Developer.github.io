#ifndef MMN_CHARACTER_FX_INNER_GLOW_INCLUDED
#define MMN_CHARACTER_FX_INNER_GLOW_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../MMN_Character_Global_Input.hlsl"

void ApplyInnerGlow(inout half3 color, half3 viewDirWS, half3 normalWS,
    half innerGlow, half innerGlowPower, half4 innerGlowColor)
{
    half fresnel = 1.0 - saturate(dot(normalWS, viewDirWS));
    fresnel = pow(fresnel, innerGlowPower);
    fresnel = saturate(fresnel);
    color = lerp(color, innerGlowColor.rgb, saturate(fresnel * innerGlow));
}

#endif // MMN_CHARACTER_FX_INNER_GLOW_INCLUDED
