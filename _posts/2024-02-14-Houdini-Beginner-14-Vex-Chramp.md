---
title: "후디니 입문 14 - Vex 함수 : Chramp"
excerpt: "함수가 그리는 그래프를 원하는 형태의 램프로 수정할 수 있는 채널 램프(Chramp) 함수에 대해서 소개하고자 합니다. Chramp(,) 는 정규화된 ${0}$ 에서 ${1}$ 사이 값에 대하여 대응할 함수를 직접 그래프를 제어하여 묘사할 수 있는 함수입니다."
date: 2024-02-14 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-14.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

후디니에서 함수가 그리는 그래프를 원하는 형태의 **램프**로 수정할 수 있는 채널 램프(Chramp) 함수에 대해서 소개하고자 합니다.

`Chramp(,)` 는 정규화된 ${0}$ 에서 ${1}$ 사이 값에 대하여 대응할 함수를 **직접 그래프를 제어**하여 묘사할 수 있는 함수입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/087.gif)

함수를 사용하기 위해 준비가 필요합니다. 먼저 위 처럼 포인트 두 개를 생성하고 'By Group'으로 묶어서 선을 만들어주세요. 

`Length` 값은 ${0.02}$ 정도로 아주 촘촘하게 포인트가 생성되도록 제어해주세요.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/147.png)

```hlsl
Chramp("램프 이름", 'input')
```
위와 같은 용법으로 사용합니다.
- "램프 이름"은 `Chramp(,)` 으로 생성되는 램프의 이름을 지정할 수 있습니다.
- `input`은 `Chramp(,)` 가 받아들일 데이터이며 그래프의 가로축에 대응 됩니다.

## 응용하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/088.gif)

```hlsl
@P.y = chramp("ramp", @P.y);
```

인풋(input)으로 `@P.y`를 사용하면 ${0}$ 에서 ${1}$ 사이의 값을 가진 포지션 y축의 그래프를 제어하는 것과 같습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/089.gif)

그래프에 마우스 커서를 올리고 좌클릭을 하면 그래프의 포인트(Point)가 생성됩니다. 
또한 'Delete' 키를 눌러서 포인트를 제거할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/090.gif)

포인트와 포인트 사이를 **보간(Interpolation)하는 방식을 변경**할 수 있습니다.

포인트를 선택하고 'Interpolation' 파라미터(Parameter) 값을 베지어(Bezier), 컨스턴트(Constant) 등으로 바꾸면 선택된 포인트의 보간 방식이 해당 값으로 바뀝니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/091.gif)

`@P.y` 값을 ${2}$ 로 설정해보면 그래프가 ${1}$ 이 넘는 값을 표현하지 못하고 끊어지는 것을 확인 할 수 있습니다. 

대신 `@P.x`를 ${2}$ 로 설정하면 전체 그래프가 ${x}$ 축 방향으로 두 배 늘어나게 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/092.gif)

```hlsl
float input = @P.x - int(@P.x);
@P.y = chramp("ramp", input);
```

그래프가 늘어나지 않고 ${0}$ 에서 ${1}$ 사이의 패턴을 늘어난 만큼 반복하려면 `@P.x`의 소수점 이하 부분이 반복되도록 구현해야합니다.

Vex 언어에는 소수부가 반복되게 하는 hlsl 언어의 `frac()`같은 함수가 없기 때문에 직접 만들어줘야 합니다.

`int()`로 형변환 해서 소수점 부분을 버린 `int(@P.x)`를 원본 `@P.x`에서 뺄셈하면 소수부만 남도록 구현 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/093.gif)

제작한 패턴이 ${0}$ 에서 시작해서 ${1}$ 으로 끝나기 때문에, 패턴이 끊김없이 이어지도록 끝 값을 ${0}$ 으로 바꾸는 처리를 해줄 수도 있습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)