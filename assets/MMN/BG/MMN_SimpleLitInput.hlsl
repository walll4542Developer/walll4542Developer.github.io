#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float _VertexColorWeight;
    float _AlbedoTintStrength;
    float4 _SpecColor;
    float _Gloss;
    float _halfLambertWeight;
    float _BackfaceReceiveShadowOff;
    float4 _EmissionColor;
    float _Cutoff;
    float _Surface;
    float _WindMultiply;
    float _WindSpeedMultiply;
    float _VertexAniOn;
    float _RaycastHarftoneClip;
    float _Night2DayEnum;
    float _ALPHATEST;
    float _BackFaceNormalturn;
    float _CenterPointHeight;
    float _GroundAOarea;
    float _GroundAOintensity;
CBUFFER_END

half _Global_Night2Day;

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 그래서 최소한만 남겨 둡니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);
half4 SampleSpecularSmoothness(float2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0, 0, 0, 1);
    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;
    return specularSmoothness;
}


#endif
