#ifndef MMN_CHARACTER_APPLY_FX_INCLUDED
#define MMN_CHARACTER_APPLY_FX_INCLUDED

#include "../MMN_Character_Global_Input.hlsl"
#include "CharacterEffectTint.hlsl"
#include "CharacterInnerGlow.hlsl"
#include "CharacterInflate.hlsl"

// NOTE @jihun.song : 아래 프로퍼티 변수들(_로 시작하는 변수)은 MMN_Character_Global_Input.hlsl을 살펴보세요.

// NOTE @jihun.song : 이펙트 틴트가 딤포그에 묻혀서 던전에서 흐릿하게 나오는 문제를 해결하기 위해 아래와 같이
// 두가지 타이밍으로 분리한다. 포그에 묻혀도 되는지, 아닌지에 따라 적절한 함수에 원하는 효과를 넣어야 한다.

// 포그에 묻혀도 되는 FX : 포그 연산 이전에 호출해야한다.
void ApplyFx_BeforeFog(inout float3 resultColor, float3 viewDirectionWS, float3 normalWS)
{
    // NOTE @jihun.song: 순서가 중요하다. 아래에 있을 수록 컬러를 덮어쓴다.
    ApplyInnerGlow(resultColor, viewDirectionWS, normalWS, _InnerGlow, _InnerGlowPower, _InnerGlowColor);
    ApplyInflateColor(resultColor, _InflateWidth, _InflateColor);
}

// 포그에 묻히면 안되는 FX : 포그 연산 이후에 호출해야한다.
void ApplyFx_AfterFog(inout float3 resultColor, float3 viewDirectionWS, float3 normalWS)
{
    // NOTE @jihun.song: 순서가 중요하다. 아래에 있을 수록 컬러를 덮어쓴다.
    ApplyEffectTintColor(resultColor, _EffectTint);
}

#endif //MMN_CHARACTER_APPLY_FX_INCLUDED
