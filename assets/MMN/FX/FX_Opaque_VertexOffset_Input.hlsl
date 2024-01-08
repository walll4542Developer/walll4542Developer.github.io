#ifndef FX_OPAQUE_VERTEXOFFSET_INPUT_INCLUDED
#define FX_OPAQUE_VERTEXOFFSET_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
    real _OffsetMode;

    float4 _MainTex_ST;
    real4 _Color;
    real _Intensity_Color;
    real4 _EmissionColor;
    real _AlphaCutoff;

    float _Sphereofinfluence;
    float4 _VelocityVector;
    float _TimeSpeed;
    float _Threshold;
    float _SinScope;

    real _FogPower;
    real _LightRatio;

    real _Mode;
    real _TransitionValue;
CBUFFER_END

#endif
