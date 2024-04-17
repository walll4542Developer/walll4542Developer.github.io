#ifndef MMN_FX_OBJECT_DECAL_FOR_CAMPFIRE_INCLUDED
#define MMN_FX_OBJECT_DECAL_FOR_CAMPFIRE_INCLUDED

#include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"

half2 GetLightAttenuation(float lightRange)
{
    // Light attenuation in universal matches the unity vanilla one.
    // attenuation = 1.0 / distanceToLightSqr
    // We offer two different smoothing factors.
    // The smoothing factors make sure that the light intensity is zero at the light range limit.
    // The first smoothing factor is a linear fade starting at 80 % of the light range.
    // smoothFactor = (lightRangeSqr - distanceToLightSqr) / (lightRangeSqr - fadeStartDistanceSqr)
    // We rewrite smoothFactor to be able to pre compute the constant terms below and apply the smooth factor
    // with one MAD instruction
    // smoothFactor =  distanceSqr * (1.0 / (fadeDistanceSqr - lightRangeSqr)) + (-lightRangeSqr / (fadeDistanceSqr - lightRangeSqr)
    //                 distanceSqr *           oneOverFadeRangeSqr             +              lightRangeSqrOverFadeRangeSqr

    // The other smoothing factor matches the one used in the Unity lightmapper but is slower than the linear one.
    // smoothFactor = (1.0 - saturate((distanceSqr * 1.0 / lightrangeSqr)^2))^2
    float lightRangeSqr = lightRange * lightRange;
    float fadeStartDistanceSqr = 0.8 * 0.8 * lightRangeSqr;
    float fadeRangeSqr = (fadeStartDistanceSqr - lightRangeSqr);
    float oneOverFadeRangeSqr = 1.0 / fadeRangeSqr;
    float lightRangeSqrOverFadeRangeSqr = -lightRangeSqr / fadeRangeSqr;
    float oneOverLightRangeSqr = 1.0 / max(0.0001, lightRange * lightRange);

    // On untethered devices: Use the faster linear smoothing factor (SHADER_HINT_NICE_QUALITY).
    // On other devices: Use the smoothing factor that matches the GI.
    half2 lightAttenuation = half2(0.0, 0.0);
    lightAttenuation.x = oneOverFadeRangeSqr;
    lightAttenuation.y = lightRangeSqrOverFadeRangeSqr;

    return lightAttenuation;
}

// Fills a light struct given a perObjectLightIndex
Light GetAdditionalLightForCampFire(float3 positionWS, float4 lightPositionWS, float lightRange, float3 lightColor)
{
    half2 distanceAndSpotAttenuation = GetLightAttenuation(lightRange);

    float3 lightVector = lightPositionWS.xyz - positionWS;
    float distanceSqr = max(dot(lightVector, lightVector), HALF_MIN);

    half3 lightDirection = half3(lightVector * rsqrt(distanceSqr));
    float attenuation = DistanceAttenuation(distanceSqr, distanceAndSpotAttenuation.xy);

    Light light;
    light.direction = lightDirection;
    light.distanceAttenuation = attenuation;
    light.shadowAttenuation = 1.0;
    light.color = half3(0.0, 0.0, 0.0);
    light.layerMask = 0;

    return light;
}

#define LINEAR_TO_GAMMA_POW 0.45454545454545

float LinearToGammaSpace(float value)
{
    if (value <= 0.0)
        return 0.0;
    else if (value <= 0.0031308)
        return 12.92 * value;
    else if (value < 1.0)
        return 1.055 * PositivePow(value, 0.4166667) - 0.055;
    else if (value == 1.0)
        return 1.0;
    else
        return PositivePow(value, 0.45454545454545);
}

float4 AdditionalLightForDecal(float3 normalWS, float3 decalPositionWS,
    float4 lightPositionWS, float lightIntensity, float lightRange, float4 lightColor)
{
    float4 result = float4(0, 0, 0, 0);

    // NOTE @jihun.song: 포인트 라이트의 껐켰 상태를 가지고 처리했는데 여전히 문제가 있어서 일단 막아둠.
    // 무슨 문제냐면, 실제로 포인트 라이트 정보를 주는 건 렌더러 오브젝트 마다 다르게 주다 보니
    // (더 정확히는 각 오브젝트가 처리하는 포인트라이트가 좀 다르다보니 - 순서에 따라 잘리거나 할 수 있어서 -)
    // 배경의 바닥은 빛을 안받는데 여기에서 검사하는 위치(lightPositionWS)에서는 빛을 받고 있다라고 판단하는
    // 경우가 있음. 그래서 바닥은 포인트 라이트를 처리를 못하고, 여기에서는 포인트가 켜져있다고 검출돼서
    // 바닥은 빛이 없고 데칼도 안그리는 상황이 발생됨.
    // 그래서 지금은 실시간 빛과 데칼을 모두 그리는 것으로 처리함.

    // #if defined(_ADDITIONAL_LIGHTS)
    //     uint meshRenderingLayers = GetMeshRenderingLightLayer();
    //     uint pixelLightCount = GetAdditionalLightsCount();

    //     // 디버깅을 위한 부분
    //     // if (pixelLightCount == 0)
    //     // {
    //     //     result = float4(1, 1, 1, 1);
    //     // }
    //     // else if (pixelLightCount == 1)
    //     // {
    //     //     result = float4(1, 0, 0, 1);
    //     // }
    //     // else if (pixelLightCount == 2)
    //     // {
    //     //     result = float4(0, 1, 0, 1);
    //     // }
    //     // else if (pixelLightCount == 3)
    //     // {
    //     //     result = float4(0, 0, 1, 1);
    //     // }
    //     // else if (pixelLightCount == 4)
    //     // {
    //     //     result = float4(1, 1, 0, 1);
    //     // }
    //     // else if (pixelLightCount == 5)
    //     // {
    //     //     result = float4(0, 1, 1, 1);
    //     // }
    //     // else if (pixelLightCount == 6)
    //     // {
    //     //     result = float4(1, 0, 1, 1);
    //     // }
    //     // else if (pixelLightCount == 7)
    //     // {
    //     //     result = float4(1, 0.5, 0, 1);
    //     // }
    //     // else if (pixelLightCount >= 8 && pixelLightCount < 13)
    //     // {
    //     //     result = float4(0, 0.5, 1, 1);
    //     // }
    //     // else
    //     // {
    //     //     result = float4(0, 0, 0, 1);
    //     // }
    //     // return result;

    //     // 먼저 캠프파이어의 포인트 라이트가 켜져 있는지 검사한다.
    //     float3 isTurnOnLights = float3(0.0, 0.0, 0.0);
    //     LIGHT_LOOP_BEGIN(pixelLightCount)
    //         Light light = GetAdditionalLight(lightIndex, lightPositionWS);

    //     #ifdef _LIGHT_LAYERS
    //         if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
    //     #endif
    //         {
    //             float3 attenuatedLightColor = light.color * light.distanceAttenuation * 0.0001;
    //             isTurnOnLights += attenuatedLightColor;
    //         }
    //     LIGHT_LOOP_END

    //     // return float4(saturate(isTurnOnLights), 1);

    //     if (length(isTurnOnLights) >= 0.1)
    //     {
    //         return result;
    //     }
    // #endif

    // 데칼을 포인트라이트의 정보 값에 맞게 그린다.
    Light light = GetAdditionalLightForCampFire(decalPositionWS, lightPositionWS, lightRange, lightColor);

    float distancePlayer = length(_Global_pos - lightPositionWS);
    float attenuationViaPlayerPos = saturate(1.0 - (distancePlayer - 20.0) / 40.0);

    // float3 attenuatedLightColor = lightColor * LinearToGammaSpace(lightIntensity * 2.0); // 데칼만 단독으로 그릴 때
    float3 attenuatedLightColor = lightColor * LinearToGammaSpace(lightIntensity * attenuationViaPlayerPos);
    float3 attenuation = light.distanceAttenuation;
    attenuatedLightColor *= attenuation;

    float nDotL = saturate(dot(-normalWS, light.direction));
    float3 additionalLightColor = attenuatedLightColor * nDotL;
    // additionalLightColor *= surfaceData.albedo; // albedo를 곱해주는 대신 블렌드 모드를 (SrcColor, One) 으로 해야한다.

    result.rgb = saturate(additionalLightColor);
    result.a = attenuation;

    return result;
}

#endif // #ifndef MMN_FX_OBJECT_DECAL_FOR_CAMPFIRE_INCLUDED
