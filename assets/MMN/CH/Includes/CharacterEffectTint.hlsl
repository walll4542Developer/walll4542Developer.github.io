#ifndef MMN_CHARACTER_EFFECT_TINT_INCLUDED
#define MMN_CHARACTER_EFFECT_TINT_INCLUDED

#include "../MMN_Character_Global_Input.hlsl"

// void ApplyEffectTintColor(inout float3 characterColor)
// {
//     float3 tintedColor = _EffectTint.rgb * min(1.0, characterColor * 20.0 + 0.3);
//     characterColor = lerp(characterColor, tintedColor.rgb, min(1.0, _EffectTint.a));
// }

void ApplyEffectTintColor(inout half3 characterColor, half4 effectTintColor)
{
    half3 tintedColor = effectTintColor.rgb * min(1.0, characterColor * 20.0 + 0.3);
    characterColor = lerp(characterColor, tintedColor.rgb, min(1.0, effectTintColor.a));
}

#endif //MMN_CHARACTER_EFFECT_TINT_INCLUDED
