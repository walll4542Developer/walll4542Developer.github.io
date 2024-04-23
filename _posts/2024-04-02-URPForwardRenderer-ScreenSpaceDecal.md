---
title: "Unity URP Forward Renderer - Screen Space Decal"
excerpt: "Unity URP에서 데칼 기능이 제대로 지원되지 않는 버전이 있습니다. 또는 드로우 콜(DrawCall)을 절약하기 위해 뎁스 노말(DepthNormal) 패스를 사용하지 않는 프로젝트도 있죠. 그럴 때는 직접 데칼 시스템을 구현해야 합니다. **스크린 스페이스 데칼(Screen Space Decal)**을 간단히 셰이더로 제작하는 방법을 소개합니다."
date: 2024-04-02 00:00:00 -0000
categories: Unity
tag: Research

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

Unity URP에서 데칼 기능이 제대로 지원되지 않는 버전이 있습니다. 예를 들어 데칼의 레이어 마스크(LayerMask) 기능이 없다거나...

또는 드로우 콜(DrawCall)을 절약하기 위해 뎁스 노말(DepthNormal) 패스를 사용하지 않는 프로젝트도 있죠.

그럴 때는 직접 데칼 시스템을 구현해야 합니다. **스크린 스페이스 데칼(Screen Space Decal)**을 간단히 셰이더로 제작하는 방법을 소개합니다.

### 스크린 스페이스 데칼의 장점
- 뎁스 노말 버퍼를 사용하지 않습니다. 대신 카메라 뎁스 텍스쳐(CameraDepthTexture)를 사용합니다.
- 제작하기 쉽고 연산이 가볍습니다.
- 구조가 간단해서 확장성이 좋아 개발중 추가 스펙이 생겨도 대응할 수 있습니다.
- 데칼 박스(box)만 적절히 배치하면 아티스트가 즉시 사용할 수 있습니다.

URP의 렌더러 피처(RendererFeature)를 사용하면 약간의 오버드로우(Overdraw)가 발생하지만 레이어 마스크 기능도 구현 할 수 있습니다.

## 계획

![Houdini-Starter](/assets/images/Docs/ScreenSpaceDecal/000.png){: .align-center}

박스를 배치 했을 때 박스의 밑면과 바닥이 닿는 경계 부분의 픽셀을 검출하고, 그 픽셀에만 데칼 텍스쳐가 맵핑 되어야 합니다.

![Houdini-Starter](/assets/images/Docs/ScreenSpaceDecal/001.png){: .align-center}

카메라 뎁스 텍스쳐를 이용하여 씬(Scene) 전체의 깊이 값을 알아낼 수 있습니다.

이를 바탕으로 경계면이 어디인지 계산 할 수 있습니다. 마젠타로 표시한 경계면의 픽셀만 살리고 나머지 픽셀은 버려야합니다.

![Houdini-Starter](/assets/images/Docs/ScreenSpaceDecal/002.png){: .align-center}

해당 픽셀을 계산하는 방법은 박스를 오브젝트 스페이스(Object Space)로 행렬 변환(Matrix transformation)하면 됩니다.

유니티에서 박스를 만들면 ${1.0^{3}}$ 부피의 정육면체가 생성 되며 박스의 피벗(pivot)은 자동으로 박스 중심에 위치하게 되어있습니다.

따라서 정육면체의 버텍스(Vertex) 위치에 해당하는 오브젝트 스페이스의 좌표에서 ${x, y, z}$ 축의 범위는 ${[-0.5, 0.5]}$가 되는 것입니다.

예를 들어 위 이미지 처럼 `float3(0.1, -0.1, -0.5)`는 마젠타로 표시한 경계면 픽셀 내부에 있다는 것을 알 수 있습니다.

`float3(0.4, 0.8, -0.5)`는 ${y}$축 위치가 ${0.8}$이니 경계면 외부에 있다고 알 수 있습니다.

![Houdini-Starter](/assets/images/Docs/ScreenSpaceDecal/003.png){: .align-center}

`uv` 데이터는 오브젝트 포지션 값중 ${xz}$ 평면을 사용합니다.

박스의 오브젝트 포지션에서 축의 범위는 ${[-0.5, 0.5]}$ 라는 것을 위에서 알고 있습니다.

여기에 단순히 ${0.5}$만큼 더하면 범위는 ${[0, 1]}$이 되며 이 값을 `uv`로 사용하면 됩니다.

## 작업

```hlsl
float2 screenUV = screenPos.xy * 2 - 1;
float rawDepth = SampleSceneDepth(screenPos.xy / screenPos.w);
float3 negateScreenPos = float3(screenUV.x, -1 * screenUV.y, rawDepth);
```

작업 계획대로 먼저 `screenUV`를 중앙 정렬한 다음 카메라 뎁스 텍스쳐 `rawDepth` 와 묶습니다.

`negateScreenPos`에서 ${y}$축을 반전하는 이유는 데칼이 경계면 바닥을 향하게 계산하기 위해서입니다.

![Houdini-Starter](/assets/images/Docs/ScreenSpaceDecal/004.png){: .align-center}

```hlsl
decalWorldSpace = mul(UNITY_MATRIX_I_VP, float4(negateScreenPos, 1));
decalWorldSpace.xyz = decalWorldSpace.xyz / decalWorldSpace.w;
float3 decalObjectSpace = TransformWorldToObject(decalWorldSpace.xyz);
```

`negateScreenPos`과 `rawDepth`를 월드 스페이스(world space)으로 행렬 변환하면 카메라 뎁스 또한 월드 스페이스가 됩니다.

그렇게 계산한 `decalWorldSpace`을 깊이 값인 `decalWorldSpace.w` 값으로 나누면 스크린 스페이스 데이터에 깊이 데이터가 추가됩니다.

마지막으로 데칼 범위 밖에 있는 픽셀을 잘라내기 위해서 박스를 오브젝트 포지션으로 행렬 변환합니다.

```hlsl
float3 a = step(-0.5, decalObjectSpace);
float3 b = 1 - (step(0.5, decalObjectSpace));

boundingBox = all(a * b);
```

${x, y, z}$ 축의 범위는 ${[-0.5, 0.5]}$라는 것을 알고 있으니 `step()` 함수를 사용해서 ${0.5}$ 이상, ${-0.5}$ 미만의 픽셀을 ${0}$으로 만들어 잘라냅니다.

```hlsl
decalUV = (decalObjectSpace + 0.5).xy;
```
그리고 오브젝트 스페이스를 ${0.5}$만큼 더한 값을 `uv`로 사용하면 완성입니다.

```hlsl
void ScreenSpaceDecal(in float4 screenPos, out float2 decalUV, out float boundingBox, out float4 decalWorldSpace)
{
    float2 screenUV = screenPos.xy * 2 - 1;
    float rawDepth = SampleSceneDepth(screenPos.xy / screenPos.w);

    float3 negateScreenPos = float3(screenUV.x, -1 * screenUV.y, rawDepth);

    decalWorldSpace = mul(UNITY_MATRIX_I_VP, float4(negateScreenPos, 1));
    decalWorldSpace.xyz = decalWorldSpace.xyz / decalWorldSpace.w;
    float3 decalObjectSpace = TransformWorldToObject(decalWorldSpace.xyz);

    float3 a = step(-0.5, decalObjectSpace);
    float3 b = 1 - (step(0.5, decalObjectSpace));

    boundingBox = all(a * b);
    decalUV = (decalObjectSpace + 0.5).xy;
}
```

URP의 렌더러 피처(RendererFeature)를 사용하면 약간의 오버드로우(Overdraw)가 발생하지만 레이어 마스크 기능도 구현 할 수 있습니다.

## 레퍼런스(Reference)
- Unity URP Decal : [https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/renderer-feature-decal.html](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/renderer-feature-decal.html)
- Decals & Stickers in Unity Shader Graph and URP : [https://youtu.be/f7iO9ernEmM?si=I8YdcbWVCJIQuFIO](https://youtu.be/f7iO9ernEmM?si=I8YdcbWVCJIQuFIO)