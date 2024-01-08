#ifndef MMN_CHARACTER_EYE_EMOTION_INPUT_INCLUDED
#define MMN_CHARACTER_EYE_EMOTION_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_EyeballTexture);
SAMPLER(sampler_EyeballTexture);
float4 _EyeballTexture_TexelSize;
float4 _EyeballTexture_MipInfo;

#ifdef _DISSOLVE_FEATURE
    TEXTURE2D(_DissolveMap);
    SAMPLER(sampler_DissolveMap);
#endif

CBUFFER_START(UnityPerMaterial)
    float4 _EyeballTexture_ST;
    half _Alpha;

    int _EyeballTextureRowNum;
    int _EyeballTextureColNum;
    int _EyeballIndexFromOne;

    float4 _LeftEyeball_TS;
    float4 _RightEyeball_TS;

    float2 _EyePositionOffset;
    float _EyeRotationOffset;

#ifdef _DISSOLVE_FEATURE
    half _DissolveAmount;

    half4 _DissolveRange;
    half _NotUseDirection;
    half3 _DissolveDirection;

    half _DissolvePanningSpeed;
    half4 _DissolveMap_ST;

    half _DissolveCutoff;

    half4 _DissolveColor;
    half _DissolveWidth;
    half4 _DissolveEdgeColor;
    half _DissolveEdgeWidth;
#endif

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // MMN_CHARACTER_EYE_EMOTION_INPUT_INCLUDED
