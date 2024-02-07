#ifndef MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED
#define MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED

// Return view direction in tangent space, make sure tangentWS.w is already multiplied by GetOddNegativeScale()
half3 GetViewDirectionTangentSpace(half4 tangentWS, half3 normalWS, half3 viewDirWS)
{
    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
    half3 unnormalizedNormalWS = normalWS;
    const half renormFactor = 1.0 / length(unnormalizedNormalWS);

    // use bitangent on the fly like in hdrp
    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
    half crossSign = (tangentWS.w > 0.0 ? 1.0 : -1.0); // we do not need to multiple GetOddNegativeScale() here, as it is done in vertex shader
    half3 bitang = crossSign * cross(normalWS.xyz, tangentWS.xyz);

    half3 worldSpaceNormal = renormFactor * normalWS.xyz;       // we want a unit length Normal Vector node in shader graph

    // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
    // This is explained in section 2.2 in "surface gradient based bump mapping framework"
    half3 worldSpaceTangent = renormFactor * tangentWS.xyz;
    half3 worldSpaceBiTangent = renormFactor * bitang;

    half3x3 tangentSpaceTransform = half3x3(worldSpaceTangent, worldSpaceBiTangent, worldSpaceNormal);
    half3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);

    return viewDirTS;
}

half2 GetParallaxOffset1Step(half amplitude, half3 viewDirTS)
{
    half height = -amplitude / 2.0;
    half3 v = normalize(viewDirTS);
    v.z += 0.42;
    return height * (v.xy / v.z);
}

#endif // MMN_CHARACTER_PARALLAX_MAPPING_INCLUDED
