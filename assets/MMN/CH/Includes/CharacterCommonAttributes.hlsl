#ifndef MMN_CHARACTER_COMMON_ATTRIBUTES_INCLUDED
#define MMN_CHARACTER_COMMON_ATTRIBUTES_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../../Includes/VectorRigHelper.hlsl"
#include "CharacterMacro.hlsl"

struct Attributes
{
    // half4 color : COLOR; // r: outline mask, g: silhouette mask, b: object-fog mask, a: inflate mask
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;

    float2 texcoord0 : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
    uint id : SV_VertexID;
    VECTOR_RIG_ATTRIBUTES(2, 3, 4, 5, 6)
};

struct Varyings
{
    // half4 color : COLOR;
    float4 positionCS : SV_POSITION; // Homogeneous clip space position

    float4 uv : TEXCOORD0;

    float4 positionWS : TEXCOORD1;  // xyz: position, w: camera distance
    float3 normalWS : TEXCOORD2;     // xyz: normal
    float4 tangentWS : TEXCOORD3;    // xyz: tangent, w: sign
    float3 bitangentWS : TEXCOORD4;  // xyz: bitangent
    float3 viewDirWS : TEXCOORD5;

    float4 fogCoord : TEXCOORD6;     // x: fogFactor, yzw: vertexLighting

    float4 positionNDC : TEXCOORD7;
#ifdef _WEAPON_GRADE_FEATURE
    float2 outlineNDC : TEXCOORD8;
#endif
    float3 positionOS : TEXCOORD9;
};

#endif // #ifndef MMN_CHARACTER_COMMON_ATTRIBUTES_INCLUDED
