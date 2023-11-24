#ifndef UNIVERSAL_SIMPLE_LIT_BUMP_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_BUMP_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    // float4 _V_T2M_Control_ST;
    float4 _T2M_SplatMap_0_ST;
    half4 _BaseColor;
    // half4 _SpecColor;
    half4 _EmissionColor;
    // half _Cutoff;
    // float _ALPHATEST;
    
    float _V_T2M_Splat1_uvScale;
    float _V_T2M_Splat2_uvScale;
    float _V_T2M_Splat3_uvScale;
    float _V_T2M_Splat4_uvScale;

    //float4 _V_T2M_Splat1_Vector;
    float4 _V_T2M_Splat2_Vector;
    float _V_T2M_Splat2_Vector1;
    float _V_T2M_Splat2_Vector2;
    // float _V_T2M_Splat2_Vector3;
    float4 _V_T2M_Splat2_EdgeColor;
    // float _V_T2M_Splat2_Vector4;

    float4 _V_T2M_Splat3_Vector;
    float _V_T2M_Splat3_Vector1;
    float _V_T2M_Splat3_Vector2;
    // float _V_T2M_Splat3_Vector3;
    float4 _V_T2M_Splat3_EdgeColor;
    // float _V_T2M_Splat3_Vector4;

    float4 _V_T2M_Splat4_Vector;
    float _V_T2M_Splat4_Vector1;
    float _V_T2M_Splat4_Vector2;
    // float _V_T2M_Splat4_Vector3;
    float4 _V_T2M_Splat4_EdgeColor;
    // float _V_T2M_Splat4_Vector4;

    // float _Glossiness;
    float _SnowMask_R;
    float _SnowMask_G;
    float _SnowMask_B;
    float _SnowMask_A;
CBUFFER_END


//GlobalVariables
// half _Global_CloudDensity;
// half _Global_CloudSpeed;
// half _Global_CloudScale;
// half _Global_CloudEdgeHardness;


// TEXTURE2D(_SpecGlossMap);        SAMPLER(sampler_SpecGlossMap);
// TEXTURE2D(_V_T2M_Control);       SAMPLER(sampler_V_T2M_Control);
TEXTURE2D(_T2M_SplatMap_0);       SAMPLER(sampler_T2M_SplatMap_0);
TEXTURE2D(_T2M_Layer_0_Diffuse);        SAMPLER(sampler_T2M_Layer_0_Diffuse);
TEXTURE2D(_T2M_Layer_1_Diffuse);        SAMPLER(sampler_T2M_Layer_1_Diffuse);
TEXTURE2D(_T2M_Layer_2_Diffuse);        SAMPLER(sampler_T2M_Layer_2_Diffuse);
TEXTURE2D(_T2M_Layer_3_Diffuse);        SAMPLER(sampler_T2M_Layer_3_Diffuse);
// TEXTURE2D(_V_T2M_Splat1_bumpMap);        SAMPLER(sampler_V_T2M_Splat1_bumpMap);
// TEXTURE2D(_V_T2M_Splat2_bumpMap);        SAMPLER(sampler_V_T2M_Splat2_bumpMap);
// TEXTURE2D(_V_T2M_Splat3_bumpMap);        SAMPLER(sampler_V_T2M_Splat3_bumpMap);
// TEXTURE2D(_V_T2M_Splat4_bumpMap);        SAMPLER(sampler_V_T2M_Splat4_bumpMap);
// TEXTURE2D(_V_T2M_Splat1_mask);        SAMPLER(sampler_V_T2M_Splat1_mask);
// TEXTURE2D(_V_T2M_Splat2_mask);        SAMPLER(sampler_V_T2M_Splat2_mask);
// TEXTURE2D(_V_T2M_Splat3_mask);        SAMPLER(sampler_V_T2M_Splat3_mask);
// TEXTURE2D(_V_T2M_Splat4_mask);        SAMPLER(sampler_V_T2M_Splat4_mask);



//metapass 에서 사용합니다. 별 필요는 없지만 살려둡시다
half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
    //#ifdef _SPECGLOSSMAP
    //    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
    //#elif defined(_SPECULAR_COLOR)
    specularSmoothness = specColor;
    //#endif

    #ifdef _GLOSSINESS_FROM_BASE_ALPHA
        specularSmoothness.a = exp2(10 * alpha + 1);
    #else
        specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
    #endif

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

//     //half4 specularSmoothness = SampleSpecularSmoothness(uv, outSurfaceData.alpha, _SpecColor, TEXTURE2D_ARGS(_SpecGlossMap, sampler_SpecGlossMap));
//     outSurfaceData.metallic = 0.0; // unused
//     outSurfaceData.specular = _SpecColor.rgb;
//     outSurfaceData.smoothness = 0.0; // unused
//     outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
//     outSurfaceData.occlusion = 1.0; // unused
//     //outSurfaceData.emission = SampleEmission(uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
//     outSurfaceData.emission = 0.0; // unused
// }

#endif
