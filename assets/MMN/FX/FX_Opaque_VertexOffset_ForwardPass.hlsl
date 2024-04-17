#ifndef FX_OPAQUE_VERTEXOFFSET_FORWARDPASS_INCLUDED
#define FX_OPAQUE_VERTEXOFFSET_FORWARDPASS_INCLUDED

#include "FX_VertexOffsetFuction.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_FresnelEffect.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float4 texcoord0 : TEXCOORD0;           // xyz: ParticleSystem의 velocity(속도의 방향 - 월드 -), w: ParticleSystem의 speed(속도의 스칼라)
    float4 customData : TEXCOORD1;
    float4 color : COLOR;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
    float4 uv1 : TEXCOORD1; 				// xyzw : custom data
    float3 viewDirWS : TEXCOORD2;
    float4 fogCoord : TEXCOORD7; 		    // x : fogcoord				yzw :
    float3 positionWS : TEXCOORD8;
    float4 positionOS : TEXCOORD9;
    float3 normalWS : TEXCOORD10;
};

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

Varyings vert (Attributes input)
{
    Varyings output = (Varyings)0;

    float3 finalOffset = AnimateVertexOffset(_OffsetMode, input.color, input.customData.xyz, input.customData.w,
        _TimeSpeed, _SinScope, _Sphereofinfluence, _VelocityVector.xyz, _Threshold);
    float4 objectVertexPosition = float4(input.positionOS.xyz + finalOffset, input.positionOS.w);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(objectVertexPosition.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.normalWS = normalInput.normalWS;
    output.uv0.xy = TRANSFORM_TEX(input.texcoord0.xy, _MainTex);
    output.positionWS = TransformObjectToWorld(objectVertexPosition.xyz);
    output.viewDirWS = GetWorldSpaceViewDir(output.positionWS);
    output.positionOS = objectVertexPosition;
    output.positionCS = vertexInput.positionCS;
    output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

    return output;
}

float4 frag(Varyings input) : SV_Target
{
    float3 normalWS = normalize(input.normalWS);
    float3 viewDirWS = SafeNormalize(input.viewDirWS);

    // 베이스 텍스처와 틴트 칼라 합성, 틴트 칼라 조절 연산
    float4 diffuseAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0.xy);
    float4 color = diffuseAlpha * _Color * _Intensity_Color;
    float alpha = color.a;
    clip(alpha - _AlphaCutoff);

    color.rgb += ApplyFresnelEffect(normalWS, viewDirWS, _FresnelColor.rgb, _FresnelRange, _FresnelPower);

    float4 finalColor = float4(color.rgb, alpha);

    ApplyLightColor(finalColor, normalWS, _LightRatio, _LightReceive);
    ApplyFogColor(finalColor, input.positionWS, normalWS, /*Blend Mode*/ 0, _FogReceive, input.fogCoord);

    #if defined(DEBUG_DISPLAY)
    {
        return FXDebuggingColor(input, color, alpha);
    }
    #endif

    return finalColor;
}
#endif
