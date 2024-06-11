#ifndef UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_NoiseTex);           SAMPLER(sampler_NoiseTex);
TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _BaseColor;
    float _VertexColorWeight;
    float _AlbedoTintStrength;
    float4 _SpecColor;
    float _Gloss;
    float _RampY;
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

    // Dissolve
    float _DissolveAmount;
    float4 _DissolveDirection;
    float4 _NoiseTex_ST;
    float _NoiseTexScale;
    float _NoiseCutoff;
    float _NoiseCutoffSmoothness;
    float _DissolveWidth;
    float4 _DissolveColor;
    float _DissolveEdgeWidth;
    float4 _DissolveEdgeColor;
CBUFFER_END

//GlobalVariables
// float _Global_CloudDensity;
// float _Global_CloudSpeed;
// float _Global_CloudScale;
// float _Global_CloudEdgeHardness;
float _Global_Night2Day;

float TriplanarNoise(float3 positionWS, float3 normalWS)
{
    float3 position = positionWS;

    float triplanarX = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.zy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    float triplanarY = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xz * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    float triplanarZ = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;

    float3 normalBlend = abs(normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    float nx = triplanarX * normalBlend.x;
    float ny = triplanarY * normalBlend.y;
    float nz = triplanarZ * normalBlend.z;

    float triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

void DissolveColor(inout float4 resultColor, in float3 positionOS, in float3 positionWS, in float3 normalWS, in float4 customdata)
{
    float3 direction = normalize(_DissolveDirection.xyz);
    float movingPosition = dot(positionOS, direction);

    #if _CUSTOMDATA_ON
        _DissolveAmount += customdata.x;
    #endif

    float dissolvePos = (movingPosition + _DissolveAmount) * _NoiseTexScale;

    float triplanarNoise = TriplanarNoise(positionWS, normalWS);
    dissolvePos += triplanarNoise;

    float edge = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, 0.0);
    float dissolve = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, min(_DissolveEdgeWidth, _DissolveWidth));
    float alpha = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, min(_DissolveEdgeWidth + _DissolveWidth, _DissolveWidth));

    resultColor.rgb = lerp(_DissolveEdgeColor.rgb, resultColor.rgb, edge);
    resultColor.rgb = lerp(_DissolveColor.rgb, resultColor.rgb, dissolve);
    resultColor.a = alpha;
}

#endif // UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED
