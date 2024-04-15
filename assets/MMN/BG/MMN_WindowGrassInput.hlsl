#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float _VertexColorWeight;
    // float _AlbedoTintStrength;
    float4 _SpecColor;
    float _Gloss;
    float4 _EmissionColor;//MetaPass에서 사용하기 위한 변수
    float _Cutoff;
    float _Surface;
    float _WindMultiply;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    float _WindSpeedMultiply;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    float _VertexAniOn;//Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    float _RaycastHarftoneClip;
    float _OutsideInside;
    float4 _EmissionColorDark;
    float4 _EmissionColorBright;
    float _TempNight2DaySwitchTest;
    float _ALPHATEST;
CBUFFER_END


TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

//실제로 사용하지 않지만 내장된 메타패스에서 참조합니다. 물론 메타패스를 따로 만들면 되긴 하지만 번잡하므로 남겨둡니다. (...)
float4 SampleSpecularSmoothness(float2 uv, float alpha, float4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap))
{
    float4 specularSmoothness = float4(0.0h, 0.0h, 0.0h, 1.0h);

    specularSmoothness = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv) * specColor;

    return specularSmoothness;
}



#endif
