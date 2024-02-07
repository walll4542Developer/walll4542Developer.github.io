#ifndef MMN_CHARACTER_EYE_BASE_INPUT_INCLUDED
#define MMN_CHARACTER_EYE_BASE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_EyeballTexture);
SAMPLER(sampler_EyeballTexture);
float4 _EyeballTexture_TexelSize;
float4 _EyeballTexture_MipInfo;

TEXTURE2D(_EyeballPupilMaskTexture);
SAMPLER(sampler_EyeballPupilMaskTexture);

TEXTURE2D(_PupilTexture);
SAMPLER(sampler_PupilTexture);

CBUFFER_START(UnityPerMaterial)
    float4 _EyeballTexture_ST;
    half _Alpha;

    float4 _EyeballPupilMaskTexture_ST;
    float4 _PupilTexture_ST;

    half _PupilMaskThresholdMin;
    half _PupilMaskThresholdMax;

    int _EyeballTextureRowNum;
    int _EyeballTextureColNum;
    int _EyeballIndexFromOne;

    int _PupilTextureRowNum;
    int _PupilTextureColNum;
    int _PupilIndexFromOne;

    float4 _LeftEyeball_TS;
    float4 _RightEyeball_TS;
    float4 _LeftPupil_TS;
    float4 _RightPupil_TS;
    half _LeftPupil_Enable;
    half _RightPupil_Enable;
    half _Pupil_Position_Debug;

    float2 _EyePositionOffset;
    float _EyeRotationOffset;

    float2 _PupilPositionOffset;

    half _IsDyable;
    half4 _DyeColor1;

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // MMN_CHARACTER_EYE_BASE_INPUT_INCLUDED
