#ifndef MMN_CHARACTER_FROM_SCRIPT_INPUT_INCLUDED
#define MMN_CHARACTER_FROM_SCRIPT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Includes/CharacterMacro.hlsl"

// NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
// 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
// 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
// 매크로를 사용하는 이유는 한방에 넣으려고... 근데 셰이더의 Property {} 에는 매크로를 쓸 수 없어서 일일히 손으로 한땀한땀 해야 된다냥... 그렇다냥... 뿅!
// 아래 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
#define MM_DECLARE_PROPERTIES_FROM_SCRIPT \
    float4 _CharacterPositionAndVisualHeight; \
    float4 _CharacterDirection; \
    float4 _CharacterHeadDirection; \
    float _TopShadow; \
    float _BottomShadow; \
    float _HalftoneClip; \
    float _CustomLightMode; \
    float3 _CustomLightDirection; \
    float3 _CustomLightColor; \
    float3 _CustomGIColor; \
    float4 _EffectTint; \
    float _InnerGlow; \
    float _InnerGlowPower; \
    float4 _InnerGlowColor; \
    float _EffectAlphaValue; \
    float _MotionBlurLerpValue; \
    int _VertexBufferLength;
//--------------------------------------------------------------------------------

#endif // MMN_CHARACTER_FROM_SCRIPT_INPUT_INCLUDED
