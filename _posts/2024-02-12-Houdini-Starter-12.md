---
title: "후디니 입문 12 - Vex 함수 : 파동함수의 합성"
excerpt: "sin(), cos(), noise() 같은 파동 함수들을 간단히 덧셈으로 합성해줄 수 있습니다."
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

## 파동함수의 합성

`sin()`, `cos()`, `noise()` 같은 파동 함수들을 간단히 덧셈으로 합성해줄 수 있습니다.

`noise()` 함수의 시작점을 항상 ${0}$에서 시작하도록 보정해줄 수 있습니다. 이처럼 시작점이 ${0}$인 노이즈를 **영점 중앙 노이즈(Zero-Centered noise)**라고 합니다.

```hlsl
float x = @P.x;
// float y = noise(x * abs(beta) + gamma) * alpha + delta;
float y = noise((x * abs(beta) + gamma) * alpha) + delta;
@P = set(x, y, 0);
```

`noise()` 함수가 항상 0.5에서 시작하기 때문에 ${\delta}$ 값을 ${-0.5}$로 설정하고 `noise()`  함수에 ${* \alpha}$ 연산을 포함하면 됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/146.png){: .align-center}

```hlsl
float y = sin(x * abs(beta) + gamma) * alpha + delta;
f@y = y;
```

```hlsl
float y = noise((x * abs(beta) + gamma) * alpha) + delta;
f@y = y;
```

`sin()` 과 `noise()` 두 가지의 파동 함수를 합성하기 위해 함수 그래프의 `@P.y` 값을 어트리뷰트(attribute) `f@y` 값으로 내보냅니다.

## @ptnum

```hlsl
float a = point(0, "y", @ptnum);
float b = point(1, "y", @ptnum);
```

`point(,,)` 함수를 사용하여 `f@y` 값을 받아옵니다.

```hlsl
point("주소","어트리뷰트 이름",'포인트 인덱스') // Vex
point("주소", '포인트 인덱스', "어트리뷰트 이름", '어트리뷰트 주소'); // hscript
```

`point(,,)` 함수에서 '포인트 인덱스' 자리에 `@ptnum` 을 사용하면 `y`의 포인트 인덱스와 값을 그대로 가져올 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/077.gif){: .align-center}

```hlsl
float a = point(0, "y", @ptnum);
float b = point(1, "y", @ptnum);

float x = @P.x;
float y = a + b;

@P = set(x, y, 0);
```

두 파동 함수의 합성된 결과를 확인하실 수 있습니다.



## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- 게임 수학 입문 - 삼각함수 : [https://walll4542developer.github.io/math/Trigonometric-functions](https://walll4542developer.github.io/math/Trigonometric-functions)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
- 나무위키/파동 : [https://namu.wiki/w/%ED%8C%8C%EB%8F%99](https://namu.wiki/w/%ED%8C%8C%EB%8F%99)