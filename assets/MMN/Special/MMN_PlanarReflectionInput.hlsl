#ifndef UNIVERSAL_PLANARREFLECTION_INPUT_INCLUDED
#define UNIVERSAL_PLANARREFLECTION_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_PlanarReflectionTexture);
SAMPLER(sampler_PlanarReflectionTexture);

TEXTURECUBE(_LowOptionCubeTexture);
SAMPLER(sampler_LowOptionCubeTexture);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;

    float4 _ReflectionColor;
    float _Smoothness;
    int _StencilRef;
    float _Glossiness;
    float4 _ReflectionAmbient;

    float _LowOptionEnable;
    float _LowOptionReflectionRatio;
    float4 _LowOptionAdjustColor;
CBUFFER_END

// DepthOnly 지원을 위한 변수
float _WindMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _WindSpeedMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _VertexAniOn; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
float _RaycastHarftoneClip;
float _Cutoff;

//GlobalVariables
float _Global_Night2Day;

#endif // UNIVERSAL_PLANARREFLECTION_INPUT_INCLUDED
