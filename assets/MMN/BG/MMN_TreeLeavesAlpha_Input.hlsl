#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half4 _SpecColor;
    half4 _EmissionColor;
    // half _Cutoff;
    half _Surface;
    half _AOarea;
    half _AOintensity;
    half _AOVertical;
    half _NormalLerp;
    half _CenterPointHeight;
    half _ShadingPow;
    half _ReceiveShadowStrength;
    half _TopLightThickness;
    // half4 _TopLightColor;
    half _WindMultiply;
    half _WindSpeedMultiply;
    half _RimArea;
    half _RimRange;
    half4 _RimColor;
    half _GrassPushPower;
    // half _ReceiveGIStrength;
    half _RaycastHarftoneClip;
    float _ALPHATEST;
CBUFFER_END

//GlobalVariables
// half _Global_CloudDensity;
// half _Global_CloudSpeed;
// half _Global_CloudScale;
// half _Global_CloudEdgeHardness;


//아래 함수는 사실상 여기 계산에서는 안쓰지만 메타패스에서 사용해서 일단 끼얹어봅니다. 두어도 별 문제 없어 보입니다
//TODO:나무는 라이트맵을 굽지 않아서 메타패스를 사실 쓰지 않지만 공용 메타패스를 꺼놓지 않아 살려둡니다. 추후 확인 필요
TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
    // #ifdef _SPECGLOSSMAP
    //     specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
    // #elif defined(_SPECULAR_COLOR)
    //     specularSmoothness = specColor;
    // #endif

    // #ifdef _GLOSSINESS_FROM_BASE_ALPHA
    //     specularSmoothness.a = exp2(10 * alpha + 1);
    // #else
    //     specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
    // #endif

    return specularSmoothness;
}



// #ifdef UNITY_DOTS_INSTANCING_ENABLED
//     UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
//     UNITY_DOTS_INSTANCED_PROP(float4, _BaseColor)
//     UNITY_DOTS_INSTANCED_PROP(float4, _SpecColor)
//     UNITY_DOTS_INSTANCED_PROP(float4, _EmissionColor)
//     UNITY_DOTS_INSTANCED_PROP(float, _Cutoff)
//     UNITY_DOTS_INSTANCED_PROP(float, _Surface)
//     UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

//     #define _BaseColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__BaseColor)
//     #define _SpecColor          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__SpecColor)
//     #define _EmissionColor      UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__EmissionColor)
//     #define _Cutoff             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata__Cutoff)
//     #define _Surface            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float, Metadata__Surface)
// #endif


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

//     half4 specularSmoothness = 0;//SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
//     outSurfaceData.metallic = 0.0; // unused
//     outSurfaceData.specular = 0;//specularSmoothness.rgb;
//     outSurfaceData.smoothness = 0;//specularSmoothness.a;
//     outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
//     outSurfaceData.occlusion = 1.0; // unused
//     outSurfaceData.emission = 0;//SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));

// }

#endif