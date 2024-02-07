#ifndef MMN_GRASSINPUT_INCLUDED
#define MMN_GRASSINPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half4 _SpecColor;
    half4 _EmissionColor;
    half _Cutoff;
    half4 _TopColor;
    half _Glossiness;
    half _Shake;
    half _ShakeSpeed;
    half _GrassPushPower;
    half _WindMultiply;
    half _WindSpeedMultiply;
    half _GlobalTextureBlending;
    half _RaycastHarftoneClip;
    half _ShadowDimming;
    //지형 컬러를 따라서 풀 칼라가 변하는 기능인데 사용성이 나빠서 일단 봉인
    // half _GlobalTextureBottomBlending;
    half _TextureBlendingScroll;
    half _VertexAniOn;
    float _ALPHATEST;
    half _GrassVisualRange;
    half _GrassVisualActionToggle;
// CBUFFER_END

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _InstancingColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

//GlobalVariables
// half _Global_CloudDensity;
// half _Global_CloudSpeed;
// half _Global_CloudScale;
// half _Global_CloudEdgeHardness;
float4 _Global_Grass_TextureSP;
half _Global_Grass_VisualRangeFactor;
//지형 컬러를 따라서 풀 칼라가 변하는 기능인데 사용성이 나빠서 일단 봉인
// float4 _Global_Grass_Bottom_TextureSP;

//Dot 관련도사실 쓸모없을거라 생각합니다만 혹시나 하는 마음에 남겨둡니다.
#ifdef UNITY_DOTS_INSTANCING_ENABLED
    UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float, _Surface)
    UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

    #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_BaseColor)
    #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_SpecColor)
    #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata_EmissionColor)
    #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_Cutoff)
    #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata_Surface)
#endif

TEXTURE2D(_Global_Grass_Texture);
SAMPLER(sampler_Global_Grass_Texture);

TEXTURE2D(_LightMap);
SAMPLER(sampler_LightMap);

//지형 컬러를 따라서 풀 칼라가 변하는 기능인데 사용성이 나빠서 일단 봉인
// TEXTURE2D(_Global_Grass_Bottom_Texture);
// SAMPLER(sampler_Global_Grass_Bottom_Texture);

#endif // MMN_GRASSINPUT_INCLUDED

