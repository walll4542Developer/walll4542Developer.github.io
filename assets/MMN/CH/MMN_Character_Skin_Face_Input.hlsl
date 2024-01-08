#ifndef MMN_CHARACTER_SKIN_FACE_INPUT_INCLUDED
#define MMN_CHARACTER_SKIN_FACE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
float4 _BaseMap_MipInfo;
TEXTURE2D(_MouthMap);
SAMPLER(_MouthMap_linear_clamp_sampler);
TEXTURE2D(_EmotionMouthMap);
SAMPLER(sampler_EmotionMouthMap);
TEXTURE2D(_TattooMap);
SAMPLER(sampler_TattooMap);
TEXTURE2D(_BeardMap);
SAMPLER(sampler_BeardMap);
TEXTURE2D(_AccessoryMap);
SAMPLER(sampler_AccessoryMap);

#ifdef _DISSOLVE_FEATURE
    TEXTURE2D(_DissolveMap);
    SAMPLER(sampler_DissolveMap);
#endif

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;

#ifdef _ALPHA_OVERRIDE_FEATURE
    half _AlphaOverride;
#endif

#ifdef _TINTCOLOR_FEATURE
    half4 _TintColor;
#endif

#ifdef _DYE_FEATURE
    half _IsDyable;
    half4 _DyeColor1;
    half4 _DyeColor2;
    half4 _DyeColor3;
#endif

    half _MouthShowType;
    float4 _MouthMapScalePosition;
    half _MouthMapRotation;

    half4 _EmotionMouthMapAtlasSize;
    float4 _EmotionMouthMapScalePosition;

    half _MouthPushStrength;

    half _IsScarMode;
    half4 _TattooMapScalePosition;
    half _TattooMapRotation;

// NOTE @jihun.song 230605 : 이제 문신/흉터는 염색하지 않는 스펙으로 확정됨.
// #ifdef _DYE_FEATURE
//     half _IsDyableTattoo;
//     half4 _TattooDyeColor1;
//     half4 _TattooDyeColor2;
//     half4 _TattooDyeColor3;
// #endif

    float4 _BeardMapScalePosition;
    half _BeardMapRotation;

#ifdef _DYE_FEATURE
    half _IsDyableBeard;
    half4 _BeardDyeColor1;
    half4 _BeardDyeColor2;
    half4 _BeardDyeColor3;
#endif

    float4 _AccessoryMapScalePosition;
    half _AccessoryMapRotation;

#ifdef _DYE_FEATURE
    half _IsDyableAccessory;
    half4 _AccessoryDyeColor1;
    half4 _AccessoryDyeColor2;
    half4 _AccessoryDyeColor3;
#endif

    float _FlatShadingOff;

#ifdef _SILHOUETTE_FEATURE
    half _SilhouetteOff;
    half4 _SilhouetteTintColor;
#endif

    half4 _OutlineColor;
    half _OutlineColorMode;
    // half _OutlineWidth;

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

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // MMN_CHARACTER_SKIN_FACE_INPUT_INCLUDED
