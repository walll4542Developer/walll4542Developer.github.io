#ifndef MMN_GRASSINPUT_INCLUDED
#define MMN_GRASSINPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

// CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float4 _SpecColor;
    float4 _EmissionColor;
    float _Cutoff;
    float4 _TopColor;
    float _Glossiness;
    float _Shake;
    float _ShakeSpeed;
    float _GrassPushPower;
    float _WindMultiply;
    float _WindSpeedMultiply;
    float _GlobalTextureBlending;
    float _RaycastHarftoneClip;
    float _ShadowDimming;
    //지형 컬러를 따라서 풀 칼라가 변하는 기능인데 사용성이 나빠서 일단 봉인
    // float _GlobalTextureBottomBlending;
    float _TextureBlendingScroll;
    float _VertexAniOn;
    float _ALPHATEST;
    float _GrassVisualRange;
    float _GrassVisualActionToggle;
// CBUFFER_END
    static const float defaultVisualRange = 20.0;

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
    UNITY_DEFINE_INSTANCED_PROP(float4, _InstancingColor)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

//GlobalVariables
// float _Global_CloudDensity;
// float _Global_CloudSpeed;
// float _Global_CloudScale;
// float _Global_CloudEdgeHardness;
float4 _Global_Grass_TextureSP;
float _Global_Grass_VisualRangeFactor;
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

