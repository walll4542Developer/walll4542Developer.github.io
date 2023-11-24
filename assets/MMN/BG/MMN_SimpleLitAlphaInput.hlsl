#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
half4 _BaseColor;
half _VertexColorWeight;
half _AlbedoTintStrength;
half4 _SpecColor;
half _Gloss;
half4 _EmissionColor;
half _Cutoff;
half _Surface;
half _WindMultiply;
half _WindSpeedMultiply;
half _VertexAniOn;
half _RaycastHarftoneClip;
CBUFFER_END



//Dot 관련도사실 쓸모없을거라 생각합니다만 혹시나 하는 마음에 남겨둡니다. 
#ifdef UNITY_DOTS_INSTANCING_ENABLED
    UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
    UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
    UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
    UNITY_DOTS_INSTANCED_PROP(float, _Cutoff)
    UNITY_DOTS_INSTANCED_PROP(float, _Surface)
    UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

    #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__BaseColor)
    #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__SpecColor)
    #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__EmissionColor)
    #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata__Cutoff)
    #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata__Surface)
#endif

TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
// half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))  
// {
//     half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);

//         specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;

//     return specularSmoothness;
// }



#endif
