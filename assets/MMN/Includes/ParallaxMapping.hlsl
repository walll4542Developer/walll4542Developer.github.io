#ifndef MMN_PARALLAX_MAPPING_INCLUDED
#define MMN_PARALLAX_MAPPING_INCLUDED

// Return view direction in tangent space, make sure tangentWS.w is already multiplied by GetOddNegativeScale()
// half3 GetViewDirectionTangentSpace(half4 tangentWS, half3 normalWS, half3 viewDirWS)
// {
//     // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
//     half3 unnormalizedNormalWS = normalWS;
//     const half renormFactor = 1.0 / length(unnormalizedNormalWS);

//     // use bitangent on the fly like in hdrp
//     // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
//     half crossSign = (tangentWS.w > 0.0 ? 1.0 : - 1.0); // we do not need to multiple GetOddNegativeScale() here, as it is done in vertex shader
//     half3 bitang = crossSign * cross(normalWS.xyz, tangentWS.xyz);

//     half3 WorldSpaceNormal = renormFactor * normalWS.xyz;       // we want a unit length Normal Vector node in shader graph

//     // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
//     // This is explained in section 2.2 in "surface gradient based bump mapping framework"
//     half3 WorldSpaceTangent = renormFactor * tangentWS.xyz;
//     half3 WorldSpaceBiTangent = renormFactor * bitang;

//     half3x3 tangentSpaceTransform = half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
//     half3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);

//     return viewDirTS;

// }


half3 GetTangentSpaceViewDir(half4 tangentWS, half3 normalWS, half3 viewDirWS)
{

    half3 bitangentWS = cross(normalWS.xyz, tangentWS.xyz);

    half3 WorldSpaceNormal = normalize(normalWS.xyz);       // we want a unit length Normal Vector node in shader graph
    half3 WorldSpaceTangent = normalize(tangentWS.xyz);
    half3 WorldSpaceBiTangent = normalize(bitangentWS.xyz);

    //메트릭스 연산
    half3x3 tangentSpaceTransform = half3x3(WorldSpaceTangent, WorldSpaceBiTangent, WorldSpaceNormal);
    half3 viewDirTS = mul(tangentSpaceTransform, viewDirWS);
    // 메트릭스 연산 대신 닷 공식으로 하는 법. 같은 공식이라고 하는데 작동결과를 보면 잘 모르겠다
    // half3 viewDirTS = float3(dot(viewDirWS, WorldSpaceTangent), dot(viewDirWS, WorldSpaceNormal), dot(viewDirWS, WorldSpaceBiTangent));

    return viewDirTS;
}

half2 ParallaxOffset1Step(half height, half amplitude, half3 viewDirTS)
{
    height = height * amplitude;// - amplitude / 2.0;
    half3 v = normalize(viewDirTS);
    v.z += 0.42;
    return height * (v.xy / v.z);
}

float2 ParallaxMapping(float h, half3 viewDirTS, half scale)
{
    //하이트맵을 여기서 계산하지 않고 결과값만 가져오기
    // half h = SAMPLE_TEXTURE2D(heightMap, sampler_heightMap, uv).g;
    float2 offset = ParallaxOffset1Step(h, scale, viewDirTS);
    return offset;
}

#endif // MMN_PARALLAX_MAPPING_INCLUDED
