---
title: "후디니 입문 10 - Vex 함수 : Point & if"
excerpt: "다수의 포인트와 프리미티브 데이터를 다루는 여러가지 함수들에 대해서 소개합니다."
date: 2024-02-10 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-10.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

지금까지는 한 두개의 포인트 데이터만 다뤘다면 이번 포스트부터는 다수의 포인트와 프리미티브 데이터를 다루는 여러가지 함수들에 대해서 소개합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/132.png)

함수를 소개하기 위한 예제를 준비 할 것입니다.

서클(Circle)노드와 더하기(Add) 노드를 연결한 다음 'Delete Geometry But Keep the Points' 옵션으로 포인트만 남겨서 ${13 - 23 - 37}$ 형태로 포인트를 배치합니다.

또한 더하기(Add) 노드로 단일 포인트 세 개를 각각 ${(2, 0, 0) (2, 1, 0) (2, 2, 0)}$ 에 배치합니다.

그리고 어트리뷰트 랭글(Attribute Wrangle) 노드를 연결해서 위와 같이 만들어주시면 준비가 끝납니다.

### 포인트(Point) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/129.png)

```hlsl
-point("/obj/Clock/Info", 0, secondRotation, 0)
```

이전 포스트[(링크)](https://walll4542developer.github.io/houdini/Houdini-Beginner-09-Vex-ClockAnimation)에서는 포인트(Point) 함수를 파라미터(Parameter)에서 입력하는 방식을 배웠는데요, 이것은 Vex가 아니라 **hscript** 라고 부릅니다.

Vex 에서의 포인트 함수와 hscript 의 포인트 함수는 문법이 약간 다릅니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/133.png)

```hlsl
point("주소", "어트리뷰트 이름", '포인트 인덱스') // Vex
point("주소", '포인트 인덱스', "어트리뷰트 이름", '어트리뷰트 주소'); // hscript
```
어트리뷰트(Attribute) 노드가 가진 인풋(input)의 주소는 왼쪽에서부터 ${0, 1, 2, 3}$ 입니다.

Vex의 경우는 포인트 함수에서 벡터(Vector)와 배열(Array) 정보도 다룰 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/134.png)
![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/135.png)

```hlsl
vector pos = point(1, "P", 0);
@p = pos;
vector k = point(2, "P", 0); 
v@k = k;
vector a = point(3, "Cd", 0);
@Cd = a;
```

위와 같이 포인트 함수로 다른 노드의 포지션, 컬러, 어트리뷰트를 인풋으로 받아온 다음 다시 변수와 어트리뷰트로 설정 해줄 수 있습니다.

### 조건문(if)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/136.png)

```hlsl
if(@P.x > 0)
{
  @Cd = {1, 0, 0};
}
else
{
  @Cd = {0, 0, 1};
}
```

Vex의 조건문은 c계열 언어에서 사용하는 조건문과 완전히 동일한 문법 구성을 가집니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/137.png)

```hlsl
if(@P.x < -1)
{
  @Cd = {1, 0, 0};
}
else if(@P.x > -1 && @P.x < 1)
{
  @Cd = {0, 1, 0};
}
else
{
  @Cd = {0, 0, 1};
}
```

다중 조건문도 가능합니다.


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
