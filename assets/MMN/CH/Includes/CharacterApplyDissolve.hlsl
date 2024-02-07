#ifndef MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED
#define MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED

#ifdef _DISSOLVE_FEATURE

#include "CharacterData.hlsl"

struct DissolveInput
{
    half4 range;
    half notUseDirection;
    half3 direction;

    half panningSpeed;

    TEXTURE2D(dissolveMap);
    SAMPLER(dissolveMapSampler);
    half4 dissolveMapST;

    half useCutoff;

    half4 mainColor;
    half mainWidth;
    half4 edgeColor;
    half edgeWidth;

    float3 positionWS;
    float3 positionOS;
    half3 normalWS;
    CharacterData characterData;
};

float2 OffsetPanning(float2 uv, half4 texture_ST, half speed)
{
    half panningSpeed = speed * _Time.y;
    float2 tilingOffset = uv * texture_ST.xy + texture_ST.zw;
    float2 panning = tilingOffset + panningSpeed;
    return panning;
}

half TriplanarNoise(in DissolveInput input)
{
    half triplanarX = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.zy, input.dissolveMapST, input.panningSpeed), 0).r;
    half triplanarY = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.xz, input.dissolveMapST, input.panningSpeed), 0).r;
    half triplanarZ = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.xy, input.dissolveMapST, input.panningSpeed), 0).r;

    half3 normalBlend = abs(input.normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    half nx = triplanarX * normalBlend.x;
    half ny = triplanarY * normalBlend.y;
    half nz = triplanarZ * normalBlend.z;

    half triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

// #ifdef DISSOLVE_WORLDSPACE
// // NOTE: 파라미터로 들어오는 모든 벡터는 노멀라이즈 되어 있다고 가정함. 회전은 Y축 기준만 다룸.
// half3 RotateFromTo(half3 characterDirection, half3 inputDirection)
// {
//     if (abs(inputDirection.x) <= 0.0001 && abs(inputDirection.z) <= 0.0001)
//     {
//         return inputDirection;
//     }

//     const half3 foward = half3(0.0, 0.0, -1.0);
//     half cosA = dot(foward, inputDirection);
//     half3 sinA = cross(foward, inputDirection);
//     half signedSinA = (sinA.y + sinA.z);

//     // Y 축 기준 회전만 다룸.
//     half3x3 rotation = half3x3(cosA, 0.0, -signedSinA, 0.0, 1.0, 0.0, signedSinA, 0.0, cosA);
//     return mul(rotation, characterDirection);
// }
// #endif

half3 ApplyDissolve(in half3 resultColor, in half progress, in DissolveInput input)
{
    if (progress <= 0.0)
    {
        return resultColor;
    }

// #ifdef DISSOLVE_WORLDSPACE
//     half3 direction = RotateFromTo(input.characterData.direction3D, input.direction);
//     half3 position = input.positionWS - input.characterData.characterPos;
// #else
    half3 direction = input.direction;
    half3 position = input.positionOS;
// #endif
    bool notUseDirection = (length(direction) <= 0.00001) || (input.notUseDirection >= 0.999999);

    half dissolvePosition = dot(position, direction) * input.range.w;
    dissolvePosition = notUseDirection ? 0.0 : dissolvePosition;

    half triplanarNoise = TriplanarNoise(input);

    bool signDirection = (direction.x + direction.y + direction.z) < 0.0;
    half progressDirection = signDirection ? 1.0 : -1.0;

    half rangeMin = notUseDirection ? -2.0 : -dot(input.range.xyz, direction) * input.range.w;
    rangeMin = direction.y >= 0.0 ? rangeMin : input.range.y / input.range.w + input.mainWidth + input.edgeWidth;

    half rangeMax = notUseDirection ? 1.0 : dot(input.range.xyz, direction) * input.range.w;
    rangeMax = direction.y <= 0.0 ? rangeMax : rangeMax * 0.5;

    half dissolve = (dissolvePosition + triplanarNoise);
    dissolve -= lerp(rangeMin, rangeMax, progress) * (notUseDirection ? -1.0 : progressDirection);

    half dissolveMin = dissolve;
    half dissolveMax = dissolve + input.mainWidth;
    half dissolveArea = saturate((-dissolveMin) / (dissolveMax - dissolveMin + 0.000001));

    half edgeMin = dissolve;
    half edgeMax = dissolve + input.edgeWidth;
    half edgeArea = saturate((-edgeMin) / (edgeMax - edgeMin + 0.000001));

    half3 finalColor = 0;
    finalColor = lerp(input.mainColor.rgb, resultColor, dissolveArea);
    finalColor = lerp(input.edgeColor.rgb, finalColor, edgeArea);

    half cutoff = 1.0 - min(1.0, dissolve);
    clip(cutoff - input.useCutoff);

    return finalColor;
}

#endif // _DISSOLVE_FEATURE

#endif // MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED
