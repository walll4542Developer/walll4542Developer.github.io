#ifndef MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED
#define MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED

// Return view direction in tangent space, make sure tangentWS.w is already multiplied by GetOddNegativeScale()
float3 GetViewDirectionTangentSpace(float4 tangentWS, float3 normalWS, float3 viewDirWS)
{
    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    float3 unnormalizedNormalWS = normalWS;
    const float renormFactor = 1.0 / length(unnormalizedNormalWS);

    // use bitangent on the fly like in hdrp
    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
    float crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0); // we do not need to multiple GetOddNegativeScale() here, as it is done in vertex shader
    float3 bitang = crossSign * cross(normalWS.xyz, tangentWS.xyz);

    float3 WorldSpaceNormal = renormFactor * normalWS.xyz;       // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    float3 WorldSpaceTangent = renormFactor * tangentWS.xyz;
    float3 WorldSpaceBiTangent = renormFactor * bitang;

    float3x3 tangentSpaceTransform = float3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    float3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);

    return viewDirTS;
}

float2 GetParallaxOffset1Step(float height, float amplitude, float3 viewDirTS)
{
    height = height * amplitude - amplitude / 2.0;
    float3 v = normalize(viewDirTS);
    v.z += 0.42;
    return height * (v.xy / v.z);
}

#endif // MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED
