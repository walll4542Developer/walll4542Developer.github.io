#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float _VertexColorWeight;
    float4 _DetailMap_ST;
    float _DetailMapYenable;
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

TEXTURE2D(_DetailMap);       SAMPLER(sampler_DetailMap);
TEXTURE2D(_SecondMap);           SAMPLER(sampler_SecondMap);

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);

    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;

    return specularSmoothness;
}


#endif
