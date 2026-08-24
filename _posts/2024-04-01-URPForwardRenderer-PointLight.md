---
title: "Unity URP Forward Renderer - Additional light Tweak"
excerpt: "Unity URP Forward Renderer - Additional light Tweak"
date: 2024-04-01 00:00:00 -0000
categories: Research
tag: Shader

header:
  teaser: 
  overlay_image: /assets/images/Docs/Thumbnails/code.png
  overlay_filter: 0.8

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

이 연구는 Unity URP 2021.3~ 버전 기준으로 작성되었음을 미리 알립니다. 
{: .notice--info}

Unity URP에서 포워드 렌더러는 오브젝트 당(per object) 에디셔널 라이트(Additional Light) 갯수가 보통의 경우 최대 ${8}$개로 제한되어 있습니다. 

물론 SRP를 수정해서 포인트라이트 최대치 갯수를 늘리면 해결되는 문제지만 *프로젝트 히스토리상의 이유*로 수정하는 비용이 너무 커서 못하는 경우들이 종종 있습니다. 

(가용 인적 자원 부족이나, 유니티 버전 업데이트에 대응을 못한다던가, 안정성 또는 유지보수 문제로 수정 하면 안되는 경우 같은 어른의 사정)

유니티 로직에 따라서 라이트 갯수가 최대치 이상이 되는 경우, 라이트 인덱스(Light Index) 순서에 따라 선입선출(First In, First Out)으로 라이트를 렌더링 하지 않도록 처리합니다.

그러나 라이트 인덱스는 업데이트(Update) 타이밍에 매 프레임 갱신되기 때문에 예를 들어 에디셔널 라이트의 포지션이 바뀌는 경우 라이트 인덱스도 같이 바뀝니다.

그래서 셰이더를 사용하여 일종의 **가짜 에디셔널 라이트**를 그릴 수 있는 방법에 대해서 고민했습니다.

## 계획

```csharp
// GetLightAttenuationAndSpotDirection
if (lightType != LightType.Directional)
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
    float fadeStartDistanceSqr = 0.8f * 0.8f * lightRangeSqr;
    float fadeRangeSqr = (fadeStartDistanceSqr - lightRangeSqr);
    float oneOverFadeRangeSqr = 1.0f / fadeRangeSqr;
    float lightRangeSqrOverFadeRangeSqr = -lightRangeSqr / fadeRangeSqr;
    float oneOverLightRangeSqr = 1.0f / Mathf.Max(0.0001f, lightRange * lightRange);

    // On untethered devices: Use the faster linear smoothing factor (SHADER_HINT_NICE_QUALITY).
    // On other devices: Use the smoothing factor that matches the GI.
    lightAttenuation.x = GraphicsSettings.HasShaderDefine(Graphics.activeTier, BuiltinShaderDefine.SHADER_API_MOBILE) || SystemInfo.graphicsDeviceType == GraphicsDeviceType.Switch ? oneOverFadeRangeSqr : oneOverLightRangeSqr;
    lightAttenuation.y = lightRangeSqrOverFadeRangeSqr;
}
```

`UniversalRenderPipelineCore` 클래스에서 포인트 라이트(Pointlight)의 감쇠(Attenuation)를 `GetLightAttenuationAndSpotDirection()` 함수에서 위와 같이 계산합니다. 

이때 사용하는 플랫폼에 따라서 라이트 계산이 달라지는데요. 모바일 기준으로는 `oneOverFadeRangeSqr` 값을 사용하고 닌텐도 스위치(Nintendo Switch)인 경우에는 `oneOverLightRangeSqr`를 사용합니다.

공식을 그대로 셰이더로 옮겨서 GPU로 연산하게 해봅시다.

## 레퍼런스(Reference)