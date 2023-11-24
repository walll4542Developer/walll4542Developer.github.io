#ifndef UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED
#define UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURECUBE(_CubeMap);       SAMPLER(sampler_CubeMap);

CBUFFER_START(UnityPerMaterial)
    half4 _BaseMap_ST;
    half4 _BaseColor;
    half _VertexColorWeight;
    half _AlbedoTintStrength;
    half4 _SpecColor;
    half _Gloss;
    half _RampY;
    half _BackfaceReceiveShadowOff;
    half4 _EmissionColor;
    half _Surface;
    half _Night2DayEnum;
    half _ALPHATEST;
    half _Lerp;
    half _Global_Night2Day;

    // DepthOnly 지원을 위한 변수
    half _Cutoff;
    half _WindMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _WindSpeedMultiply; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _VertexAniOn; //Shadow와 Depthpass를 심플릿과 같이 쓰기 위해 놔둔것
    half _RaycastHarftoneClip;
CBUFFER_END

#endif // UNIVERSAL_FLOORREFLECTION_INPUT_INCLUDED
