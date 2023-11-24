#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half _VertexColorWeight;
    // half _AlbedoTintStrength;
    half4 _SpecColor;
    half _Gloss;
    half4 _EmissionColor;//MetaPass에서 사용하기 위한 변수
    half _Cutoff;
    half _Surface;
    half _WindMultiply;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _WindSpeedMultiply;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _VertexAniOn;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _RaycastHarftoneClip;
    half _OutsideInside;
    half4 _EmissionColorDark;
    half4 _EmissionColorBright;
    half _TempNight2DaySwitchTest;
    float _ALPHATEST;
CBUFFER_END


TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
half4 SampleSpecularSmoothness(half2 uv, half alpha, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);

    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;

    return specularSmoothness;
}



#endif
