#ifndef UNIVERSAL_TERRAIN_LIT_INPUT_INCLUDED
#define UNIVERSAL_TERRAIN_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _BaseColor;
float _Cutoff;
CBUFFER_END

#define _Surface 0.0 // Terrain is always opaque

    CBUFFER_START(_Terrain)
    float _NormalScale0, _NormalScale1, _NormalScale2, _NormalScale3;
    float _Metallic0, _Metallic1, _Metallic2, _Metallic3;
    float _Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3;
    float4 _DiffuseRemapScale0, _DiffuseRemapScale1, _DiffuseRemapScale2, _DiffuseRemapScale3;
    float4 _MaskMapRemapOffset0, _MaskMapRemapOffset1, _MaskMapRemapOffset2, _MaskMapRemapOffset3;
    float4 _MaskMapRemapScale0, _MaskMapRemapScale1, _MaskMapRemapScale2, _MaskMapRemapScale3;

    float4 _Control_ST;
    float4 _Control_TexelSize;
    float _DiffuseHasAlpha0, _DiffuseHasAlpha1, _DiffuseHasAlpha2, _DiffuseHasAlpha3;
    float _LayerHasMask0, _LayerHasMask1, _LayerHasMask2, _LayerHasMask3;
    float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _Splat3_ST;
    float _HeightTransition;
    float _NumLayersCount;

    float4 _SpecColor;
    float _Glossiness;

    float _V_T2M_Splat1_uvScale;
    float _V_T2M_Splat2_uvScale;
    float _V_T2M_Splat3_uvScale;
    float _V_T2M_Splat4_uvScale;

    float _V_T2M_Splat2_Vector1;
    float _V_T2M_Splat2_Vector2;
    float4 _V_T2M_Splat2_EdgeColor;
    // float _V_T2M_Splat2_Vector4;

    float _V_T2M_Splat3_Vector1;
    float _V_T2M_Splat3_Vector2;
    float4 _V_T2M_Splat3_EdgeColor;
    // float _V_T2M_Splat3_Vector4;

    float _V_T2M_Splat4_Vector1;
    float _V_T2M_Splat4_Vector2;
    float4 _V_T2M_Splat4_EdgeColor;
    // float _V_T2M_Splat4_Vector4;

    TEXTURE2D(_V_T2M_Splat1_mask);        SAMPLER(sampler_V_T2M_Splat1_mask);
    TEXTURE2D(_V_T2M_Splat2_mask);        
    TEXTURE2D(_V_T2M_Splat3_mask);        
    TEXTURE2D(_V_T2M_Splat4_mask);        

    #ifdef UNITY_INSTANCING_ENABLED
        float4 _TerrainHeightmapRecipSize;   // float4(1.0f/width, 1.0f/height, 1.0f/(width-1), 1.0f/(height-1))
        float4 _TerrainHeightmapScale;       // float4(hmScale.x, hmScale.y / (float)(kMaxHeight), hmScale.z, 0.0f)
    #endif
    #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
    #endif
    CBUFFER_END

// float _Global_CloudDensity;
// float _Global_CloudSpeed;
// float _Global_CloudScale;
// float _Global_CloudEdgeHardness;


TEXTURE2D(_Control);    SAMPLER(sampler_Control);
TEXTURE2D(_Splat0);     SAMPLER(sampler_Splat0);
TEXTURE2D(_Splat1);
TEXTURE2D(_Splat2);
TEXTURE2D(_Splat3);

#ifdef _NORMALMAP
    TEXTURE2D(_Normal0);     SAMPLER(sampler_Normal0);
    TEXTURE2D(_Normal1);
    TEXTURE2D(_Normal2);
    TEXTURE2D(_Normal3);
#endif

// #ifdef _MASKMAP
    TEXTURE2D(_Mask0);      SAMPLER(sampler_Mask0);
    TEXTURE2D(_Mask1);
    TEXTURE2D(_Mask2);
    TEXTURE2D(_Mask3);
// #endif

TEXTURE2D(_MainTex);       SAMPLER(sampler_MainTex);
TEXTURE2D(_SpecGlossMap);  SAMPLER(sampler_SpecGlossMap);
TEXTURE2D(_MetallicTex);   SAMPLER(sampler_MetallicTex);

float4 SampleMetallicSpecGloss(float2 uv, float albedoAlpha)
{
    float4 specGloss;
    specGloss = SAMPLE_TEXTURE2D(_MetallicTex, sampler_MetallicTex, uv);
    specGloss.a = albedoAlpha;
    return specGloss;
}

inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    outSurfaceData = (SurfaceData)0;
    float4 albedoSmoothness = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
    outSurfaceData.alpha = 1;

    float4 specGloss = SampleMetallicSpecGloss(uv, albedoSmoothness.a);
    outSurfaceData.albedo = albedoSmoothness.rgb;

    outSurfaceData.metallic = specGloss.r;
    outSurfaceData.specular = float3(0.0h, 0.0h, 0.0h);

    outSurfaceData.smoothness = specGloss.a;
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
    outSurfaceData.occlusion = 1;
    outSurfaceData.emission = 0;
}

#endif
