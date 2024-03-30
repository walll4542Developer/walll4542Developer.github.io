---
title: "후디니 입문 17 - Foreach 반복문"
excerpt: "지금까지 공부한 여러 함수들을 응용하여 위와 같은 간단한 라인 애니메이션을 제작해보고자 합니다."
date: 2024-02-16 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-17.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/151.png){: .align-center}

후디니에서 노드로 `foreach` 반복문을 사용하는 방법에 대해서 알아보겠습니다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/111.gif){: .align-center}

후디니의 `foreach` 반복문 동작을 다음과 같이 정의할 수 있습니다.
>`foreach input` 는 모든 `input`을 분해(blast)한 뒤, `foreach` 블록(block)의 내부 작업을 수행하고 나서 하나의 결과로 묶어(merge)줍니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/153.png){: .align-center}

빨간색 네모로 강조된 주황색으로 묶여있는 부분을 블록(block)이라고 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/152.png){: .align-center}

`input`으로 포인트(point) 또는 프리미티브(Primitive)가 들어올 수 있습니다.

### 응용하기

절차 생성 모델링으로 배경 모델링 바닥에 사용할 잔디를 만들어 보겠습니다.


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
