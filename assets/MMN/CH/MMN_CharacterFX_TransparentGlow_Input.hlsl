#ifndef MMN_CHARACTER_FX_TRANSPARENTGLOW_INPUT_INCLUDED
#define MMN_CHARACTER_FX_TRANSPARENTGLOW_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BumpMap_ST;

    float4 _Color;
    float _TintColorIntensity;

    float _BumpPower;
    float4 _FresnelColor;
    float _FresnelPower;
    float _FresnelRange;
    
    float _InflateInverseNormal;

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // #ifndef MMN_CHARACTER_FX_TRANSPARENTGLOW_INPUT_INCLUDED
