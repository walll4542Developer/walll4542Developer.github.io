---
title: "후디니 입문 08 - Vex 언어 : 정보의 연산 방식과 Vop 이해"
excerpt: "Vex 언어를 사용하는 노드는 어트리뷰트 랭글(attributewrangle) 노드만 있는 것이 아닙니다. 이번에는 새로운 Vop 노드에 대해서 알아보고자 합니다. 또한 서로 다른 데이터 타입들끼리 연산 했을 때 결과가 어떻게 결정되는지 알아보며 Vex와 Vop의 차이점에 대해서 다루겠습니다."
date: 2024-02-08 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-07.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 정보의 연산 방식

- `float`
- `int`
- `vector`
- `string`

이전 포스트[(링크)](https://walll4542developer.github.io/houdini/Houdini-Starter-07/) 에서 후디니에서 주로 사용되는 위의 네 가지 데이터 타입이 있다는 것을 배웠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/109.png){: .align-center}

Vex 언어를 사용하는 노드는 어트리뷰트 랭글(attributewrangle) 노드만 있는 것이 아닙니다. 이번에는 새로운 **Vop** 노드에 대해서 알아보고자 합니다.

또한 서로 다른 데이터 타입들끼리 연산 했을 때 결과가 어떻게 결정되는지 알아보며 Vex와 Vop의 차이점에 대해서 다루겠습니다.

예를 들어 `float` ${+}$ `int` 를 연산하는 경우를 생각해봅시다.

```
float a = 1.5;
int b = 2;

@c = a + b;
```

이때 `@c` 의 데이터 타입은 어떻게 될까요?
- Vex 에서는 연산 결과를 담아줄 변수의 데이터 타입이 **미리 정해져** 있어야 합니다.
- Vop 에서는 연산 결과를 담아줄 변수의 데이터 타입을 후디니가 알아서 **판단**합니다.

### Vex의 연산 방식

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/105.png){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/106.png){: .align-center}

Vex는 값을 미리 정해둡니다.

`@c`가 아니라 `f@c`라면 어떻게 연산하던 데이터 타입은 `float`일 것이며, `i@c` 라면 `int`입니다

결과가 `int`가 되면 소수점 부분을 버리고 정수 부분만 남는 것을 확인하실 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/107.png){: .align-center}

`int b` 를 벡터(vector)에 더한다면 `b`의 정수 부분만큼 벡터의 모든 성분에 같은 값이 더해집니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/108.png){: .align-center}

`float a`를 더해도 같은 방식으로 벡터의 모든 성분에 같은 값이 더해집니다.

### Vop의 연산 방식

Vop의 판단 기준은 **연산 순서**입니다. 

Vop로 `float` ${+}$ `int` 를 계산하는 상황이라면 `float`이 앞에 있기 때문에 데이터 타입도 `float`으로 결정됩니다. \\
반대로 `int`가 앞에 있는 `int` ${+}$ `float` 상황이라면 데이터 타입도 `int`로 결정됩니다.

## Vop 노드 사용하기

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/109.png){: .align-center}

노드를 생성할 때 **'Attribute Vop'** 를 선택합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/052.gif){: .align-center}

노드를 더블 클릭하면 Vop 노드 내부를 구성하는 그래프 에디터가 나타납니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/053.gif){: .align-center}

Vop 노드 내부에서 값을 읽고 쓰기 위해서 먼저 **상수(Constant)** 노드를 만들어줍니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/110.png){: .align-center}

상수 노드를 선택하고 파라미터 뷰의 'Constant Type'에서 후디니에서 다룰 수 있는 다양한 종류의 상수를 설정해줄 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/111.png){: .align-center}



## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
