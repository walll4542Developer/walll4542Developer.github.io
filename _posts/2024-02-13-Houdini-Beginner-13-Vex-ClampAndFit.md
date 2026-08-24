---
title: "후디니 입문 13 - Vex 함수 : Clamp 와 Fit"
excerpt: "삼각함수가 그리는 파동의 진폭을 제어하는 두 가지 함수 clamp와 fit에 대해서 소개하고자 합니다."
date: 2024-02-13 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-13.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

후디니에서 삼각함수가 그리는 파동의 **진폭**을 제어하는 두 가지 함수 `clamp(,,)`와 `fit(,,,,)` 에 대해서 소개하고자 합니다.

```hlsl
clamp(y, 'y의 최솟값', 'y의 최대값');
fit(y, 'y의 최솟값', 'y의 최대값', 'y의 진폭 최솟값', 'y의 진폭 최대값')
```

함수를 사용하기 위해 준비가 필요합니다. 다음과 같은 코드를 작성해주세요.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/081.gif)

```hlsl
float x = @P.x;
float y = sin(x * abs(beta) + gamma) * alpha + delta;

@P = set(x, y, 0);
```

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/142.png)

- ${\alpha}$(알파)는 진폭을 조절 합니다.
- ${\beta}$(베타)는 파장을 조절 합니다.
- ${\gamma}$(감마)는 그래프를 수평이동 합니다.
- ${\delta}$(델타)는 그래프를 수직이동 합니다.

### 클램프(clamp) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/082.gif)

```hlsl
float a = point(0, "y", @ptnum); // "y"는 sin 그래프

float min = chf("min");
float max = chf("max");

float x = @P.x;
float y = clamp(a, min, max);

@P = set(x, y, 0);
```

`clamp(,,)` 함수는 `min`을 ${y}$의 최솟값으로, `max`를 ${y}$의 최대값으로 잘라내는 함수입니다.

Vex 언어에서는 hlsl 처럼 `saturate()` 함수가 없어서 대신 `clamp(,,)`를 사용해야 합니다.
{: .notice--info}

### 핏(fit) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/083.gif)

```hlsl
float a = point(0, "y", @ptnum);

float min = chf("min");
float max = chf("max");
float outMin = chf("outMin");
float outMax = chf("outMax");

float x = @P.x;
float y = fit(a, min, max, outMin, outMax);

@P = set(x, y, 0);
```

`fit(,,,,)` 함수는 `min`을 ${y}$의 최솟값으로, `max`를 ${y}$의 최대값으로 잘라낸 다음 `outMin` 과 `outMax` 값에 맞춰 진폭을 늘리고 줄이는 함수입니다.

연산 순서가 중요한데요, `min`, `max`가 먼저 적용되고 난 다음에 `outMin` 과 `outMax`가 적용됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/084.gif)

`outMin` 과 `outMax` 값에 맞춰 진폭을 늘리고 줄이기 때문에, `outMax` 값이 `outMin` 값보다 작아지는 경우에는 그래프가 ${y}$축 방향으로 **반전**됩니다.

## 응용하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/085.gif)

```hlsl
float x = @P.x;
float y = noise(x * abs(beta) + gamma) * alpha + delta;

@P = set(x, y, 0);
f@y = y;
@Cd = {0, 0, 1};
```

눈으로 보기 편하도록 `noise()` 함수에 포인트 컬러 어트리뷰트(attribute)를 추가해서 파란색으로 출력 하고 `clamp(,,)` 와 `fit(,,,,)` 는 빨간색으로 출력해서 겹쳐놓고 비교해봅니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/086.gif)

```hlsl
float x = @P.x;
float a = point(0, "y", @ptnum);

float min = chf("min");
float max = chf("max");
float outMin = chf("outMin");
float outMax = chf("outMax");

float y = fit(a, min, max, outMin, outMax);
// float y = clamp(a, min, max);

@P = set(x, y, 0);
@Cd = {1, 0, 0};
```

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- 게임 수학 입문 - 삼각함수 : [https://walll4542developer.github.io/math/Trigonometric-functions](https://walll4542developer.github.io/math/Trigonometric-functions)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
- 나무위키/파동 : [https://namu.wiki/w/%ED%8C%8C%EB%8F%99](https://namu.wiki/w/%ED%8C%8C%EB%8F%99)