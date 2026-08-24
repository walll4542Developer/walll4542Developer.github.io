---
title: "후디니 입문 15 - Vex 함수 : 거리 값을 다루는 함수들"
excerpt: "후디니에서 두 벡터 사이의 거리(Distance) 값을 측정하고 다루는 함수들을 소개하고자 합니다."
date: 2024-02-15 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-15.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

후디니에서 두 벡터 사이의 **거리(Distance) 값**을 측정하고 다루는 함수들을 소개하고자 합니다.

- `Length()`
- `Distance(,)`
- `nearpoint(,)`

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/094.gif)

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

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/148.png)

포인트의 위치를 편하게 정할 수 있도록 **hscript 방식**으로 작성할 것입니다.

'add1' 노드의 'Point 0' 파라미터의 ${x}$,${z}$값에 회전 행렬을 사용합니다. `$FF` 변수는 후디니 hscript 문법에서 현재 프레임 값을 의미합니다. 

따라서 후디니에서 애니메이션을 재생하면 현재 프레임 값이 회전 행렬에 대입되고, 그렇게 계산된 ${xz}$ 평면에서 포인트 위치 값을 알 수 있습니다.

```hlsl
float l = length(vector);
float d = distance(vector, vector);
```

- length 는 **벡터의 크기** 입니다.
- distance 는 **두 벡터 사이의 거리** 입니다.

Vex의 `length`, `distance` 는 hlsl 문법과 동일하게 동작합니다.

## 응용하기

### 길이(Length), 거리(Distance) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/095.gif)

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

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/096.gif)

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

`limit` 값보다 `f@dist`가 더 작으면 해당하는 모든 포인트를 제거하도록 코드를 작성했습니다. //
`f@dist` 값의 응용은 무궁무진하여 `@Cd` 등의 포인트 컬러 값으로 사용할 수도 있을 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/097.gif)

`f@dist` 값을 사용해서 `a` 와 가장 가까운 포인트를 찾아낸 다음 가장 가까운 포인트의 인덱스 넘버가 ${0}$이 되도록 정렬할 수 있습니다.

if문을 제거한 다음, 소트(Sort) 노드를 추가합니다. 노드의 'Point Sort' 파라미터 값을 **By attribute** 로 설정하고 `dist` 값을 받아옵니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/098.gif)

`dist` 값이 가장 작은 순서대로 포인트 인덱스가 새롭게 정렬됩니다. 그래서 가장 가까운 포인트의 인덱스는 항상 ${0}$이 됩니다.

블라스트(blast) 노드를 사용하여 가장 가까운 포인트 인덱스 ${0}$번을 떼낸 다음 'By Group'으로 선으로 이어주면 위와 같은 연출을 만들 수 있습니다.

### 니어 포인트(nearPoint) 함수

```hlsl
nearpoint("주소", '포인트 포지션')
```

앞서 가장 가까운 포인트를 소트(Sort) 노드를 응용하여 찾아봤습니다. 그런데 Vex의 내장 함수중에 같은 기능을 하는 `nearpoint(,)` 함수가 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/099.gif)

```hlsl
int pointNumber = nearpoint(1, @P);
vector pos = point(1, "P", pointNumber);

addpoint(0, pos);
```

`nearpoint(,)` 함수는 `@P`의 위치와 가장 가까운 포인트의 포인트 넘버를 반환합니다. 


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)