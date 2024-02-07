#ifndef FX_OPAQUE_VERTEXOFFSET_FORWARDPASS_INCLUDED
#define FX_OPAQUE_VERTEXOFFSET_FORWARDPASS_INCLUDED

#include "FX_VertexOffsetFuction.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

struct Attributes
{
    real4 color : COLOR;
    float4 positionOS : POSITION;
    real3 normalOS : NORMAL;
    real4 tangentOS : TANGENT;

    float2 texcoord0 : TEXCOORD0;
    float4 customData : TEXCOORD1;  // xyz: ParticleSystem의 velocity(속도의 방향 - 월드 -), w: ParticleSystem의 speed(속도의 스칼라)
};

struct Varyings
{
    real4 color : COLOR;
    float4 positionCS : SV_POSITION;

    float2 uv : TEXCOORD0;
    float4 positionWS : TEXCOORD1;
    real3 normalWS : TEXCOORD2;
    real fogCoord : TEXCOORD3;
};

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

Varyings vert (Attributes input)
{
    Varyings output = (Varyings)0;

    float3 finalOffset = AnimateVertexOffset(_OffsetMode, input.color, input.customData.xyz, input.customData.w,
        _TimeSpeed, _SinScope, _Sphereofinfluence, _VelocityVector.xyz, _Threshold);
    float3 objectVertexPosition = input.positionOS.xyz + finalOffset;

    // Output Data 계산부
    output.uv = TRANSFORM_TEX(input.texcoord0.xy, _MainTex);

    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.positionWS.xyz = TransformObjectToWorld(objectVertexPosition);
    output.positionCS = TransformObjectToHClip(objectVertexPosition);

    output.fogCoord = ComputeFogFactor(output.positionCS.z);

    return output;
}

real4 frag(Varyings input) : SV_Target
{
    float3 normalWS = normalize(input.normalWS);
    float3 positionWS = normalize(input.positionWS.xyz);

    // 베이스 텍스처와 틴트 칼라 합성, 틴트 칼라 조절 연산
    real4 diffuseAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    real4 color = diffuseAlpha * _Color * _Intensity_Color;

    ApplyLightColor(color, normalWS, _LightRatio);
    ApplyFogColor(color, positionWS, normalWS, _Mode, _FogPower, input.fogCoord);

    #if defined(DEBUG_DISPLAY)
    {
        return FXDebugColor(normalWS, positionWS, input.fogCoord, color.rgb, color.a);
    }
    #endif

    float alpha = color.a;
    clip(alpha - _AlphaCutoff);

    return color;
}

#endif
