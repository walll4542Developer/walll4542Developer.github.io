---
title: "후디니 입문 15 - Vex 함수 : 거리 값을 다루는 함수들"
excerpt: "후디니에서 두 벡터 사이의 거리(Distance) 값을 측정하고 다루는 함수들을 소개하고자 합니다."
date: 2024-02-15 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-15.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

후디니에서 두 벡터 사이의 **거리(Distance) 값**을 측정하고 다루는 함수들을 소개하고자 합니다.

Length 와 Distance nearpoint

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/094.gif){: .align-center}

함수를 사용하기 위해 준비가 필요합니다. 원점을 중심으로 회전 운동을 하는 포인트를 만들어줄 것입니다.

```hlsl
// hscript 방식
cos($FF), 0, sin($FF);
```

```hlsl
// Vex 방식
float speed = @Frame * 0.1; // 원하는 만큼 속도를 조절할 것
@P = set(cos(speed), 0, sin(speed));
```

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/148.png){: .align-center}

포인트의 위치를 편하게 정할 수 있도록 **hscript 방식**으로 작성할 것입니다.

'add1' 노드의 'Point 0' 파라미터의 ${x}$,${z}$값에 회전 행렬을 사용합니다. `$FF` 변수는 후디니의 현재 프레임 값을 의미합니다. 

따라서 후디니에서 애니메이션을 재생하면 현재 프레임 값이 회전 행렬에 대입되고, 그렇게 계산된 ${xz}$ 평면에서 포인트 위치 값을 알 수 있습니다.

```hlsl
float l = length(vector);
float d = distance(vector, vector);
```

- length 는 **벡터의 크기** 입니다.
- distance 는 **두 벡터 사이의 거리** 입니다.

Vex의 `length`, `distance` 는 hlsl 문법과 동일하게 동작합니다.

### 응용하기

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/095.gif){: .align-center}

```hlsl
vector a = point(0, "P", 0);
vector b = point(1, "P", 0);
vector c = point(2, "P", 0);

f@dist = distance(a, b);
f@length = length(a - b);
```

- `a`는 ${(cos, 0, sin)}$ 에 위치하고 있습니다.
- `b`는 ${(1, 0, 0)}$ 에 위치하고 있습니다.
- `c`는 ${(0, 0, 0)}$ 원점에 위치하고 있습니다.

`a` 가 회전하면서 `b` 와 가까워질수록 `f@dist` 값은 감소하며 완전히 겹치면 ${0}$이됩니다. \\
반대로 멀어질 수록 `f@dist` 값은 증가하며 가장 멀리 있을 때는 ${2.0}$ 이 됩니다.

`f@length` 값도 `f@dist`와 동일한 값이 나옵니다. 왜냐하면 `a`에서 `b`를 뺄셈하면 벡터 `a`의 꼬리에서 벡터 `b`의 머리까지의 크기와 방향을 가지는 새로운 벡터가 생성됩니다.

이를 **Head to tail** 이라고 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/096.gif){: .align-center}

```hlsl
removepoint("주소", '포인트 인덱스');
```

`removepoint(,)` 함수를 이용하면 원하는 포인트를 제거할 수 있습니다. 

```hlsl
vector a = @P;
vector b = point(1, "P", 0);

f@dist = distance(a, b);

if(f@dist < chf("limit"))
{
    removepoint(0, @ptnum);
}
```

`limit` 값보다 `f@dist`가 더 작으면 해당하는 모든 포인트를 제거하도록 코드를 작성했습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)