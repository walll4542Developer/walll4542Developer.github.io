#ifndef UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

TEXTURE2D(_NoiseTex);           SAMPLER(sampler_NoiseTex);
TEXTURE2D(_SpecGlossMap);       SAMPLER(sampler_SpecGlossMap);

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
    half _Cutoff;
    half _Surface;
    half _WindMultiply;
    half _WindSpeedMultiply;
    half _VertexAniOn;
    half _RaycastHarftoneClip;
    half _Night2DayEnum;
    half _ALPHATEST;
    half _BackFaceNormalturn;
    
    // Dissolve
    half _DissolveAmount;
    half4 _DissolveDirection;
    float4 _NoiseTex_ST;
    half _NoiseTexScale;
    half _NoiseCutoff;
    half _NoiseCutoffSmoothness;
    half _DissolveWidth;
    half4 _DissolveColor;
    half _DissolveEdgeWidth;
    half4 _DissolveEdgeColor;
CBUFFER_END

//GlobalVariables
// half _Global_CloudDensity;
// half _Global_CloudSpeed;
// half _Global_CloudScale;
// half _Global_CloudEdgeHardness;
half _Global_Night2Day;

half TriplanarNoise(float3 positionWS, float3 normalWS)
{
    float3 position = positionWS;

    half triplanarX = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.zy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    half triplanarY = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xz * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;
    half triplanarZ = SAMPLE_TEXTURE2D_LOD(_NoiseTex, sampler_NoiseTex, position.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw, 0).r;

    float3 normalBlend = abs(normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    half nx = triplanarX * normalBlend.x;
    half ny = triplanarY * normalBlend.y;
    half nz = triplanarZ * normalBlend.z;

    half triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

void DissolveColor(inout half4 resultColor, in float3 positionOS, in float3 positionWS, in float3 normalWS, in float4 customdata)
{
    float3 direction = normalize(_DissolveDirection.xyz);
    half movingPosition = dot(positionOS, direction);

    #if _CUSTOMDATA_ON
        _DissolveAmount += customdata.x;
    #endif
    
    half dissolvePos = (movingPosition + _DissolveAmount) * _NoiseTexScale;

    half triplanarNoise = TriplanarNoise(positionWS, normalWS);
    dissolvePos += triplanarNoise;

    half edge = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, 0.0);
    half dissolve = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, min(_DissolveEdgeWidth, _DissolveWidth));
    half alpha = smoothstep(dissolvePos, dissolvePos + _NoiseCutoffSmoothness, min(_DissolveEdgeWidth + _DissolveWidth, _DissolveWidth));

    resultColor.rgb = lerp(_DissolveEdgeColor.rgb, resultColor.rgb, edge);
    resultColor.rgb = lerp(_DissolveColor.rgb, resultColor.rgb, dissolve);
    resultColor.a = alpha;
}

#endif // UNIVERSAL_SIMPLE_LIT_DISSOLVE_INPUT_INCLUDED
