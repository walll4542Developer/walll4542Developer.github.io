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
    float _AlphaOverride;
#endif

#ifdef _TINTCOLOR_FEATURE
    float4 _TintColor;
#endif

#ifdef _DYE_FEATURE
    float _IsDyable;
    float4 _DyeColor1;
    float4 _DyeColor2;
    float4 _DyeColor3;
#endif

    float _MouthShowType;
    float4 _MouthMapScalePosition;
    float _MouthMapRotation;

    float4 _EmotionMouthMapAtlasSize;
    float4 _EmotionMouthMapScalePosition;

    float _MouthPushStrength;

    float _IsScarMode;
    float4 _TattooMapScalePosition;
    float _TattooMapRotation;

// NOTE @jihun.song 230605 : 이제 문신/흉터는 염색하지 않는 스펙으로 확정됨.
// #ifdef _DYE_FEATURE
//     float _IsDyableTattoo;
//     float4 _TattooDyeColor1;
//     float4 _TattooDyeColor2;
//     float4 _TattooDyeColor3;
// #endif

    float4 _BeardMapScalePosition;
    float _BeardMapRotation;

#ifdef _DYE_FEATURE
    float _IsDyableBeard;
    float4 _BeardDyeColor1;
    float4 _BeardDyeColor2;
    float4 _BeardDyeColor3;
#endif

    float4 _AccessoryMapScalePosition;
    float _AccessoryMapRotation;

#ifdef _DYE_FEATURE
    float _IsDyableAccessory;
    float4 _AccessoryDyeColor1;
    float4 _AccessoryDyeColor2;
    float4 _AccessoryDyeColor3;
#endif

    float _FlatShadingOff;

#ifdef _SILHOUETTE_FEATURE
    float _SilhouetteOff;
    float4 _SilhouetteTintColor;
#endif

    float4 _OutlineColor;
    float _OutlineColorMode;
    // float _OutlineWidth;

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

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // MMN_CHARACTER_SKIN_FACE_INPUT_INCLUDED
