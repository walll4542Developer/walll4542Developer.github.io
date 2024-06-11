#ifndef FX_OPAQUE_VERTEXOFFSET_INPUT_INCLUDED
#define FX_OPAQUE_VERTEXOFFSET_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
    float _LightReceive;
    float _LightRatio;

    float _FogReceive;

    float _OffsetMode;

    float4 _MainTex_ST;

    float4 _Color;
    float _Intensity_Color;
    float4 _EmissionColor;
    float _AlphaCutoff;

    float4 _FresnelColor;
    float _FresnelRange;
    float _FresnelPower;

    float _Sphereofinfluence;
    float4 _VelocityVector;
    float _TimeSpeed;
    float _Threshold;
    float _SinScope;
CBUFFER_END



#endif
