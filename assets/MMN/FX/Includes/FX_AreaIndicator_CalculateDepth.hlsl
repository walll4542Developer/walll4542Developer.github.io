#ifndef MMN_FX_AREAINDICATOR_DEPTH
#define MMN_FX_AREAINDICATOR_DEPTH

// 22-10-23 jaehyun.kim 사용되지 않습니다. 바닥에 파묻히지 않았을 때도 반투명하게 보이기 때문.
// float CalculateDepthOpaque(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
// {
//     float rawDepth = SampleSceneDepth(uv);
//     float sceneZ = LinearEyeDepth(rawDepth, ZBufferParams);
//     float thisZ = LinearEyeDepth(positionWS, GetWorldToViewMatrix());

//     float minAlpha = alpha * 0.4;
//     float maxAlpha = alpha;

//     float depth = max(minAlpha, min(1.0, pow(max(0, sceneZ - thisZ), 0.3)));
//     float depthAlpha = saturate(min(maxAlpha, depth));

//     return depthAlpha;
// }

/*
float CalculateDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
{
    float rawDepth = _CameraDepthTexture.SampleLevel(_LinearSampler, uv, 0).r;
    float sceneZ = LinearEyeDepth(_CameraDepthTexture.SampleLevel(_LinearSampler, uv, 0).r, _ZBufferParams);
    float thisZ = LinearEyeDepth(positionWS.z, _ZBufferParams);

    float normalizedRawDepth = (2.0f * rawDepth - 1.0f) * _ProjectionParams.w; // 정규화된 rawDepth 값을 구한다.

    float depthValue = (1.0f / (thisZ - sceneZ)) * normalizedRawDepth; // 두 깊이 값의 차이에 정규화된 rawDepth 값을 곱하여 깊이 값을 구한다.

    return depthValue;
}
*/

float CalculateBaseDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha, float depthLength)
{
    // DepthTexture 가져오기
    float rawDepth = SampleSceneDepth(uv);
    // DepthTexture로 깊이 값 가져오기
    float sceneZ = LinearEyeDepth(rawDepth, ZBufferParams);
    // 월드 포지션을 뷰 공간으로 변환
    float thisZ = LinearEyeDepth(positionWS, GetWorldToViewMatrix());

    // 월드상 픽셀이 위치한 값과 카메라가 보는 깊이 값의 차이를 구한다.
    float depth = thisZ - sceneZ;
    depth *= depthLength;

    float compressionRatio = 1;
    float compressedDepth = saturate(1 - ((1.0 - exp2(-depth * compressionRatio)) / (1.0 - exp2(-compressionRatio))));

    float nearMax = 0.0001; // 값을 올리면 전체적으로 진해집니다. (최소 값)
    float nearPower = 6; // 값을 올리면 경계부분의 그라데이션 폭이 좁아집니다.
    float nearDepth = max(nearMax, pow(compressedDepth, nearPower));

    return compressedDepth * alpha;
}

float CalculateBaseDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
{
    // DepthTexture 가져오기
    float rawDepth = SampleSceneDepth(uv);
    // DepthTexture로 깊이 값 가져오기
    float sceneZ = LinearEyeDepth(rawDepth, ZBufferParams);
    // 월드 포지션을 뷰 공간으로 변환
    float thisZ = LinearEyeDepth(positionWS, GetWorldToViewMatrix());

    // 월드상 픽셀이 위치한 값과 카메라가 보는 깊이 값의 차이를 구한다.
    float depth = thisZ - sceneZ;
    // depth = depth * 3;
    // depth = pow(depth * 4, 5) * 0.001;

    float compressionRatio = 1;
    float compressedDepth = saturate(1 - ((1.0 - exp2(-depth * compressionRatio)) / (1.0 - exp2(-compressionRatio))));

    float nearMax = 0.0001; // 값을 올리면 전체적으로 진해집니다. (최소 값)
    float nearPower = 1; // 값을 올리면 경계부분의 그라데이션 폭이 좁아집니다.
    float nearDepth = max(nearMax, pow(compressedDepth, nearPower));

    return compressedDepth * alpha;
}

float CalculateDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha, float depthLength)
{
    return CalculateBaseDepthAlpha(uv, ZBufferParams, positionWS, alpha, depthLength);
}

float CalculateDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
{
    return CalculateBaseDepthAlpha(uv, ZBufferParams, positionWS, alpha);
}

// 기존 코드
// float CalculateDepthAlpha(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
// {
//     float rawDepth = SampleSceneDepth(uv);
//     float sceneZ = LinearEyeDepth(rawDepth, ZBufferParams);
//     float thisZ = LinearEyeDepth(positionWS, GetWorldToViewMatrix());

//     float farMin = 0.25; // 값을 올리면 멀리 있는 테두리 부분이 진해집니다.
//     float farPower = 2.2; // 값을 올리면 멀리 있는 테두리의 범위가 좁아집니다.
//     float farRange = 0.2; // 값을 올리면 멀리 있는 테두리의 범위가 넓어집니다.
//     float farRate = 0.8; // 값을 올리면 멀리 있는 테두리의 전체가 진해집니다.
//     float farDepth = min(farMin, pow(((thisZ - sceneZ) * farRange), farPower)) * farRate;

//     float nearMax = 0.5; // 값을 올리면 전체적으로 진해집니다. (최소 값)
//     float nearPower = 4.0; // 값을 올리면 경계부분의 그라데이션 폭이 좁아집니다.
//     float nearDepth = max(nearMax, pow((1.0 - saturate(thisZ - sceneZ)), nearPower));
//     float depth = max(farDepth, nearDepth);

//     return saturate(depth) * alpha;
// }

float CalculateDepthAlphaTargetRing(float2 uv, float4 ZBufferParams, float3 positionWS, float alpha)
{
    float rawDepth = SampleSceneDepth(uv);
    float sceneZ = LinearEyeDepth(rawDepth, ZBufferParams);
    float thisZ = LinearEyeDepth(positionWS, GetWorldToViewMatrix());

    //float minAlpha = alpha * 0.12;
    //float maxAlpha = alpha * 0.25;
    float minAlpha = alpha * 0.04;
    float maxAlpha = alpha * 0.10;

    float depth = max(minAlpha, thisZ - sceneZ);
    float depthAlpha = saturate(min(maxAlpha, depth));

    return depthAlpha;
}

float3 CalculateGreyScale(float3 color, float alpha)
{
    return lerp(color, dot(color, half3(0.3,0.6,0.1)), 1.0 - alpha);
}

#endif // MMN_FX_AREAINDICATOR_DEPTH
