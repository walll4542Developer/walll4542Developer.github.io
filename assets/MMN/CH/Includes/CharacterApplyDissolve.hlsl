#ifndef MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED
#define MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED

#ifdef _DISSOLVE_FEATURE

#include "CharacterData.hlsl"

struct DissolveInput
{
    float4 range;
    float notUseDirection;
    float3 direction;

    float panningSpeed;

    TEXTURE2D(dissolveMap);
    SAMPLER(dissolveMapSampler);
    float4 dissolveMapST;

    float useCutoff;

    float4 mainColor;
    float mainWidth;
    float4 edgeColor;
    float edgeWidth;

    float3 positionWS;
    float3 positionOS;
    float3 normalWS;
    CharacterData characterData;
};

float2 OffsetPanning(float2 uv, float4 texture_ST, float speed)
{
    float panningSpeed = speed * _Time.y;
    float2 tilingOffset = uv * texture_ST.xy + texture_ST.zw;
    float2 panning = tilingOffset + panningSpeed;
    return panning;
}

float TriplanarNoise(in DissolveInput input)
{
    float triplanarX = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.zy, input.dissolveMapST, input.panningSpeed), 0).r;
    float triplanarY = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.xz, input.dissolveMapST, input.panningSpeed), 0).r;
    float triplanarZ = SAMPLE_TEXTURE2D_LOD(input.dissolveMap, input.dissolveMapSampler, OffsetPanning(input.positionWS.xy, input.dissolveMapST, input.panningSpeed), 0).r;

    float3 normalBlend = abs(input.normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    float nx = triplanarX * normalBlend.x;
    float ny = triplanarY * normalBlend.y;
    float nz = triplanarZ * normalBlend.z;

    float triplanarNoise = nx + ny + nz;
    return triplanarNoise;
}

// #ifdef DISSOLVE_WORLDSPACE
// // NOTE: 파라미터로 들어오는 모든 벡터는 노멀라이즈 되어 있다고 가정함. 회전은 Y축 기준만 다룸.
// float3 RotateFromTo(float3 characterDirection, float3 inputDirection)
// {
//     if (abs(inputDirection.x) <= 0.0001 && abs(inputDirection.z) <= 0.0001)
//     {
//         return inputDirection;
//     }

//     const float3 foward = float3(0.0, 0.0, -1.0);
//     float cosA = dot(foward, inputDirection);
//     float3 sinA = cross(foward, inputDirection);
//     float signedSinA = (sinA.y + sinA.z);

//     // Y 축 기준 회전만 다룸.
//     float3x3 rotation = float3x3(cosA, 0.0, -signedSinA, 0.0, 1.0, 0.0, signedSinA, 0.0, cosA);
//     return mul(rotation, characterDirection);
// }
// #endif

float3 ApplyDissolve(in float3 resultColor, in float progress, in DissolveInput input)
{
    if (progress <= 0.0)
    {
        return resultColor;
    }

// #ifdef DISSOLVE_WORLDSPACE
//     float3 direction = RotateFromTo(input.characterData.direction3D, input.direction);
//     float3 position = input.positionWS - input.characterData.characterPos;
// #else
    float3 direction = input.direction;
    float3 position = input.positionOS;
// #endif
    bool notUseDirection = (length(direction) <= 0.00001) || (input.notUseDirection >= 0.999999);

    float dissolvePosition = dot(position, direction) * input.range.w;
    dissolvePosition = notUseDirection ? 0.0 : dissolvePosition;

    float triplanarNoise = TriplanarNoise(input);

    bool signDirection = (direction.x + direction.y + direction.z) < 0.0;
    float progressDirection = signDirection ? 1.0 : -1.0;

    float rangeMin = notUseDirection ? -2.0 : -dot(input.range.xyz, direction) * input.range.w;
    rangeMin = direction.y >= 0.0 ? rangeMin : input.range.y / input.range.w + input.mainWidth + input.edgeWidth;

    float rangeMax = notUseDirection ? 1.0 : dot(input.range.xyz, direction) * input.range.w;
    rangeMax = direction.y <= 0.0 ? rangeMax : rangeMax * 0.5;

    float dissolve = (dissolvePosition + triplanarNoise);
    dissolve -= lerp(rangeMin, rangeMax, progress) * (notUseDirection ? -1.0 : progressDirection);

    float dissolveMin = dissolve;
    float dissolveMax = dissolve + input.mainWidth;
    float dissolveArea = saturate((-dissolveMin) / (dissolveMax - dissolveMin + 0.000001));

    float edgeMin = dissolve;
    float edgeMax = dissolve + input.edgeWidth;
    float edgeArea = saturate((-edgeMin) / (edgeMax - edgeMin + 0.000001));

    float3 finalColor = 0;
    finalColor = lerp(input.mainColor.rgb, resultColor, dissolveArea);
    finalColor = lerp(input.edgeColor.rgb, finalColor, edgeArea);

    float cutoff = 1.0 - min(1.0, dissolve);
    clip(cutoff - input.useCutoff);

    return finalColor;
}

#endif // _DISSOLVE_FEATURE

#endif // MMN_CHARACTER_APPLY_DISSOLVE_INCLUDED
