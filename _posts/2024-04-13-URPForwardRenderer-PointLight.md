---
title: "Unity URP Forward Renderer - Additional light Tweak"
excerpt: "Unity URP Forward Renderer - Additional light Tweak"
date: 2024-04-13 00:00:00 -0000
categories: Unity
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-20.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

이 연구는 유니티 2021 버전 기준으로 작성되었음을 알립니다. 
{: .notice--info}

유니티 URP에서 포워드 렌더러는 오브젝트 당(per object) 에디셔널 라이트(Additional Light) 갯수가 보통의 경우 최대 8개로 제한되어 있습니다. 

물론 SRP를 수정해서 포인트라이트 최대치 갯수를 늘리면 쉽게 해결되는 문제지만 회사에서 프로젝트를 진행해보면 *프로젝트 히스토리상의 이유*로 수정하면 안되거나 못하는 경우들이 종종 있습니다. 

(담당 인원이 없다거나, 유니티 버전 업데이트에 대응을 못한다던가, 안정성 또는 유지보수 문제로 수정 하면 안되는 경우같은 어른의 이유)

유니티 로직에 따라서 라이트 갯수가 최대치 이상이면 라이트 인덱스(Light Index)에 따라 선입선출(First In, First Out) 순서대로 라이트를 렌더링 하지 않습니다.

그러나 라이트 인덱스는 업데이트(Update)타이밍으로, 매 프레임 갱신되기 떄문에 에디셔널 라이트의 포지션이 바뀌는 경우 라이트 인덱스도 같이 바뀝니다.

그래서 셰이더를 사용하여 일종의 가짜 에디셔널 라이트를 그릴 수 있는 방법에 대해서 고민했습니다.

## 레퍼런스(Reference)
- 