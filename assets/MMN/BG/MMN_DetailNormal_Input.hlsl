#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    // float4 _BaseMap2_ST;
    // float _BaseMap2BlendWeight;
    float4 _BaseColor;
    float _VertexColorWeight;
    float4 _DetailMap_ST;
    float _DetailMapYenable;
    // float4 _BumpMap_ST;
    // float4 _DetailBumpMap_ST;
    float4 _SecondMap_ST;
    float _AlbedoTintStrength;
    float4 _SpecColor;
    float4 _EmissionColor;
    float _Cutoff;
    float _Glossiness;
    float _DetailBumpScale;
    float _SecondMapOffset;
    float _SecondMapScale;
    float _SecondMapBlendHardness;
    float _RaycastHarftoneClip;
    float _RampY;
    
CBUFFER_END


//GlobalVariables
// half _Global_CloudDensity;
// half _Global_CloudSpeed;
// half _Global_CloudScale;
// half _Global_CloudEdgeHardness;

//Dot 관련도사실 쓸모없을거라 생각합니다만 혹시나 하는 마음에 남겨둡니다.
// #ifdef UNITY_DOTS_INSTANCING_ENABLED
//     UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
//         UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
//         UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
//         UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
//         UNITY_DOTS_INSTANCED_PROP(float , _Cutoff)
//         UNITY_DOTS_INSTANCED_PROP(float , _Surface)
//     UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

//     #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_BaseColor)
//     #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_SpecColor)
//     #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata_EmissionColor)
//     #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Cutoff)
//     #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float  , Metadata_Surface)
// #endif


// TEXTURE2D(_BaseMap2);       SAMPLER(sampler_BaseMap2);
TEXTURE2D(_DetailMap);       SAMPLER(sampler_DetailMap);
// TEXTURE2D(_DetailBumpMap);       SAMPLER(sampler_DetailBumpMap);
TEXTURE2D(_SecondMap);           SAMPLER(sampler_SecondMap);
// TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

// half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
// {
//     half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
//     #ifdef _SPECGLOSSMAP
//         //specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
//     #elif defined(_SPECULAR_COLOR)
//         specularSmoothness = specColor;
//     #endif

//     #ifdef _GLOSSINESS_FROM_BASE_ALPHA
//         specularSmoothness.a = exp2(10 * alpha + 1);
//     #else
//         specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
//     #endif

//     return specularSmoothness;
// }

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);

    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;

    return specularSmoothness;
}


// inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
// {
//     outSurfaceData = (SurfaceData)0;

//     half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
//     outSurfaceData.alpha = albedoAlpha.a * _BaseColor.a;
//     AlphaDiscard(outSurfaceData.alpha, _Cutoff);

//     outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
//     #ifdef _ALPHAPREMULTIPLY_ON
//         outSurfaceData.albedo *= outSurfaceData.alpha;
//     #endif

//     // half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
//     outSurfaceData.metallic = 0.0; // unused
//     // outSurfaceData.specular = specularSmoothness.rgb;
//     // outSurfaceData.smoothness = specularSmoothness.a;
//     outSurfaceData.specular = _SpecColor.rgb;
//     outSurfaceData.smoothness = _SpecColor.a;
//     outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
//     outSurfaceData.occlusion = 1.0; // unused
//     outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
// }

#endif
