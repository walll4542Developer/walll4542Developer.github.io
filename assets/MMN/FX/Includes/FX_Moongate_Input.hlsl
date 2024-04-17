#ifndef MMN_FX_MOONGATE_INPUT_INCLUDED
#define MMN_FX_MOONGATE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
// #include "Assets/PatchableAssets/Shaders/MM/BG/MM_BG_Include.hlsl"

#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/BendingVertex.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/CustomLighting.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/BlendingHelper.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float _VertexColorWeight;
    float _AlbedoTintStrength;
    float _Cutoff;
    float _Surface;
    float _RaycastHarftoneClip;
    float4 _Color;

    float4 _NoiseTexture_ST;
    float _Lerp;
    float _EdgeWidth;
    float4 _OffColor;
    float4 _OnColor;
    float4 _EdgeColor;
CBUFFER_END

TEXTURE2D(_NoiseTexture);
    SAMPLER(sampler_NoiseTexture);



#endif // MMN_FX_MOONGATE_INPUT_INCLUDED

