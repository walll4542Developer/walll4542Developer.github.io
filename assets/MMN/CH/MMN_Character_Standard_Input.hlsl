#ifndef MMN_CHARACTER_STANDARD_INPUT_INCLUDED
#define MMN_CHARACTER_STANDARD_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
float4 _BaseMap_MipInfo;

#ifdef _EMISSION_FEATURE
    TEXTURE2D(_EmissionMap);
    SAMPLER(sampler_EmissionMap);
#endif

#ifdef _DISSOLVE_FEATURE
    TEXTURE2D(_DissolveMap);
    SAMPLER(sampler_DissolveMap);
#endif

#ifdef _TEXTURE_LERP_FEATURE
    TEXTURE2D(_BaseMap2);
    SAMPLER(sampler_BaseMap2);
#endif

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;

#ifdef _ALPHA_OVERRIDE_FEATURE
    half _AlphaOverride;
    half _AlphaScaleMin;
    half _AlphaScaleMax;
    #ifdef _GRADIENT_ALPHA_FEATURE
        half _IsGradientAlpha;
        half _GradientAlphaHeight;
    #endif
#endif

#ifdef _TINTCOLOR_FEATURE
    half4 _TintColor;
#endif

#ifdef _TWO_SIDE_FEATURE
    half _BackFaceDarkenAmount;
#endif

#ifdef _TEXTURE_LERP_FEATURE
    half _LerpTex;
#endif

#ifdef _DYE_FEATURE
    half _IsDyable;
    half4 _DyeColor1;
    half4 _DyeColor2;
    half4 _DyeColor3;
#endif

#ifdef _SILHOUETTE_FEATURE
    half _SilhouetteOff;
    half4 _SilhouetteTintColor;
#endif

    half4 _OutlineColor;
    half _OutlineColorMode;
    // half _OutlineWidth;

    half _IsMetal;
    half4 _MetalTintColor;
    half _Smoothness;
    half _SpecularStrength;

#ifdef _EMISSION_FEATURE
    half3 _EmissionColor;
    half _IsApplyFogToEmission;
    half _ApplyFogToEmissionFactor;
    half _IsEnableEmissionAtNight;
    half _IsBreathingEmissionMode;
    half _BreathingEmissionModePeriod;
#endif

#ifdef _FRESNEL_FEATURE
    half4 _FresnelColor;
    half _FresnelRange;
    half _FresnelPower;
#endif

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

#ifdef _ARBALEST_FEATURE
    half _RemainedMagazine;
    half _MagazineNumber;
#endif

#ifdef _WEAPON_GRADE_FEATURE
    half4 _WeaponGradeColor;
#endif

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // #ifndef MMN_CHARACTER_STANDARD_INPUT_INCLUDED
