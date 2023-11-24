#ifndef MMN_CHARACTER_LERPTEX_INPUT_INCLUDED
#define MMN_CHARACTER_LERPTEX_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/CH/MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float4 _BaseMap_TexelSize;
float4 _BaseMap_MipInfo;

TEXTURE2D(_BaseMap2);
SAMPLER(sampler_BaseMap2);

CBUFFER_START(UnityPerMaterial)
    float _ShadingType;
    float4 _TintColor;
    
    float4 _BaseMap_ST;
    float _LerpTex;


#ifdef _SILHOUETTE_FEATURE
    float _SilhouetteOff;
    float4 _SilhouetteTintColor;
#endif

    float4 _OutlineColor;
    float _OutlineColorMode;
    float _OutlineWidth;

    // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들. (MMN_Character_Global_Input.hlsl 에 정의됨)
    // 반드시 수정/추가가 필요할 때 관련된 모든 셰이더의 Property {} 에도 동일하게 넣어줘야 한다!
    // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
    MM_DECLARE_PROPERTIES_FROM_SCRIPT
CBUFFER_END

#endif // #ifndef MMN_CHARACTER_LERPTEX_INPUT_INCLUDED
