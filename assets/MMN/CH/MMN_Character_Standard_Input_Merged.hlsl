#ifndef MMN_CHARACTER_STANDARD_INPUT_MERGED_INCLUDED
#define MMN_CHARACTER_STANDARD_INPUT_MERGED_INCLUDED

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
    float _ShadingType;

    float4 _BaseMap_ST;

#ifdef _ALPHA_OVERRIDE_FEATURE
    float _AlphaOverride;
    float _AlphaScaleMin;
    float _AlphaScaleMax;
    #ifdef _GRADIENT_ALPHA_FEATURE
        float _IsGradientAlpha;
        float _GradientAlphaHeight;
    #endif
#endif

#ifdef _TINTCOLOR_FEATURE
    float4 _TintColor;
#endif

#ifdef _TWO_SIDE_FEATURE
    float _BackFaceDarkenAmount;
#endif

#ifdef _DYE_FEATURE
    float _IsDyable;
    float4 _DyeColor1;
    float4 _DyeColor2;
    float4 _DyeColor3;
    float4 _DyeColor4;
    float4 _DyeColor5;
    float4 _DyeColor6;
    float4 _DyeColor7;
    float4 _DyeColor8;
    float4 _DyeColor9;
    float4 _DyeColor10;
    float4 _DyeColor11;
    float4 _DyeColor12;
    float4 _DyeColor13;
    float4 _DyeColor14;
    float4 _DyeColor15;
    float4 _DyeColor16;
    float4 _DyeColor17;
    float4 _DyeColor18;
    float4 _DyeColor19;
    float4 _DyeColor20;
    float4 _DyeColor21;
    float4 _DyeColor22;
    float4 _DyeColor23;
    float4 _DyeColor24;

	float _UVXOffset[8];
    float _UVYOffset[8];

#endif

#ifdef _SILHOUETTE_FEATURE
    float _SilhouetteOff;
    float4 _SilhouetteTintColor;
#endif

    float4 _OutlineColor;
    float _OutlineColorMode;
    // float _OutlineWidth;

    float _IsMetal;
    float4 _MetalTintColor;
    float _Smoothness;
    float _SpecularStrength;

#ifdef _EMISSION_FEATURE
    float3 _EmissionColor;
    float _IsApplyFogToEmission;
    float _ApplyFogToEmissionFactor;
    float _IsEnableEmissionAtNight;
    float _IsBreathingEmissionMode;
    float _BreathingEmissionModePeriod;
#endif

#ifdef _FRESNEL_FEATURE
    float4 _FresnelColor;
    float _FresnelRange;
    float _FresnelPower;
#endif

#ifdef _DISSOLVE_FEATURE
    float _DissolveAmount;

    float4 _DissolveRange;
    float _NotUseDirection;
    float3 _DissolveDirection;

    float _DissolvePanningSpeed;
    float4 _DissolveMap_ST;

    float _DissolveCutoff;

    float4 _DissolveColor;
    float _DissolveWidth;
    float4 _DissolveEdgeColor;
    float _DissolveEdgeWidth;
#endif

#ifdef _ARBALEST_FEATURE
    float _RemainedMagazine;
    float _MagazineNumber;
#endif

#ifdef _WEAPON_GRADE_FEATURE
    float4 _WeaponGradeColor;
#endif

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // #ifndef MMN_CHARACTER_STANDARD_INPUT_MERGED_INCLUDED
