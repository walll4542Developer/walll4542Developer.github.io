#ifndef UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED
#define UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURECUBE(_CubeMap);       SAMPLER(sampler_CubeMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float4 _SpecColor;
    float _Gloss;
    float _Lerp;
CBUFFER_END

// DepthOnly 지원을 위한 변수
float _WindMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _WindSpeedMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _VertexAniOn; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _RaycastHarftoneClip;
float _Cutoff;

#endif // UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED
