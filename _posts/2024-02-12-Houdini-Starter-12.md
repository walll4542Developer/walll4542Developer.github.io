---
title: "후디니 입문 12 - Vex 함수 : 노이즈"
excerpt: "노이즈 함수의 시작점이 항상 ${0}$에서 시작하도록 보정합니다. 이를 영점 중앙 노이즈(Zero-Centered noise)라고 합니다."
date: 2024-02-12 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-12.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---


노이즈 함수의 시작점이 항상 ${0}$에서 시작하도록 보정합니다. 이를 **영점 중앙 노이즈(Zero-Centered noise)**라고 합니다.

```hlsl
float x = @P.x;
// float y = noise(x * abs(beta) + gamma) * alpha + delta;
float y = noise((x * abs(beta) + gamma) * alpha) + delta;
@P = set(x, y, 0);
```

${\delta}$ ${0.5}$로 설정

노이즈 함수에 ${\alpha}$ 를 포함

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- 게임 수학 입문 - 삼각함수 : [https://walll4542developer.github.io/math/Trigonometric-functions](https://walll4542developer.github.io/math/Trigonometric-functions)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
- 나무위키/파동 : [https://namu.wiki/w/%ED%8C%8C%EB%8F%99](https://namu.wiki/w/%ED%8C%8C%EB%8F%99)