---
title: "후디니 입문 08 - Vex 언어 : 정보의 연산 방식과 Vop 이해"
excerpt: "Vex 언어를 사용하는 노드는 어트리뷰트 랭글(attributewrangle) 노드만 있는 것이 아닙니다. 이번에는 새로운 Vop 노드에 대해서 알아보고자 합니다. 또한 서로 다른 데이터 타입들끼리 연산 했을 때 결과가 어떻게 결정되는지 알아보며 Vex와 Vop의 차이점에 대해서 다루겠습니다."
date: 2024-02-08 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-08.png
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
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

이전 포스트[(링크)](https://walll4542developer.github.io/houdini/Houdini-Beginner-07-Vex-DataType) 에서 후디니에서 주로 사용되는 위의 네 가지 데이터 타입이 있다는 것을 배웠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/109.png)

Vex 언어를 사용하는 노드는 어트리뷰트 랭글(Attribute Wrangle) 노드만 있는 것이 아닙니다. 이번에는 새로운 **Vop** 노드에 대해서 알아보고자 합니다.

또한 서로 다른 데이터 타입들끼리 연산 했을 때 결과가 어떻게 결정되는지 알아보며 Vex와 Vop의 차이점에 대해서 다루겠습니다.

예를 들어 `float` ${+}$ `int` 를 연산하는 경우를 생각해봅시다.

```hlsl
float a = 1.5;
int b = 2;

@c = a + b;
```

이때 `@c` 의 데이터 타입은 어떻게 될까요?
- Vex 에서는 연산 결과를 담아줄 변수의 데이터 타입이 **미리 정해져** 있어야 합니다.
- Vop 에서는 연산 결과를 담아줄 변수의 데이터 타입을 후디니가 알아서 **판단**합니다.

### Vex의 연산 방식

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/105.png)
![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/106.png)

Vex는 값을 미리 정해둡니다.

`@c`가 아니라 `f@c`라면 어떻게 연산하던 데이터 타입은 `float`일 것이며, `i@c` 라면 `int`입니다

결과가 `int`가 되면 소수점 부분을 버리고 정수 부분만 남는 것을 확인하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/107.png)

`int b` 를 벡터(vector)에 더한다면 `b`의 정수 부분만큼 벡터의 모든 성분에 같은 값이 더해집니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/108.png)

`float a`를 더해도 같은 방식으로 벡터의 모든 성분에 같은 값이 더해집니다.

### Vop의 연산 방식

Vop의 판단 기준은 **연산 순서**입니다. 

Vop로 `float` ${+}$ `int` 를 계산하는 상황이라면 `float`이 앞에 있기 때문에 데이터 타입도 `float`으로 결정됩니다. \\
반대로 `int`가 앞에 있는 `int` ${+}$ `float` 상황이라면 데이터 타입도 `int`로 결정됩니다.

다음은 실제로 Vop 노드를 사용하며 자세히 알아보겠습니다.

## Vop 노드 사용하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/109.png)

노드를 생성할 때 **'Attribute Vop'** 를 선택합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/052.gif)

노드를 더블 클릭하면 마치 마야(Maya), 언리얼 엔진의 블루프린트(BluePrint), 유니티 엔진의 셰이더 그래프(ShaderGraph) 같은 느낌의 유사한 그래프 에디터 UI가 나옵니다. 이는 Vop 노드 내부를 구성하는 그래프 에디터입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/053.gif)

Vop 노드 내부에서 값을 읽고 쓰기 위해서 먼저 **상수(Constant)** 노드를 만들어줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/110.png)

상수 노드를 선택하고 파라미터(Parameter)의 'Constant Type'에서 후디니에서 다룰 수 있는 다양한 종류의 상수를 설정해줄 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/111.png)

`float` 을 선택하고 값을 3으로 설정합니다. 하지만 지금으로서는 아무것도 출력하지 않습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/112.png)

'const1' 노드의 값을 어트리뷰트(Attribute)로 지정하여 출력하려면 **바인드 익스포트(Bind Export)** 라는 노드를 사용해야 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/054.gif)
![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/113.png)

바인드 익스포트 노드의 이름(name)은 `k`로 정하고 타입(Type)도 `float`으로 설정하였습니다.

그리고 'const1' 노드와 인풋(intput)과 아웃풋(output)을 연결하면 값을 어트리뷰트 `k`로 내보낼 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/055.gif)

여타 다른 그래프 에디터 처럼 많은 연산 기능이 노드의 형태로 제공됩니다. 예를 들어 위 이미지 처럼 더하기(Add) 노드가 존재할 뿐만 아니라 상수들 끼리 모든 사칙연산이 가능합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/114.png)

바인드 익스포트로 출력한 결과 `a`와 `b`의 아웃풋을 가지고 다시 연산을 수행할 수도 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/116.png)

`a`와 `b`를 더하고 이를 다시 바인드 익스포트로 출력하는데, 이때 출력하는 값의 이름을 `a`로 정하면 위와 같이 `a`의 값이 2로 *업데이트* 되는 것을 확인 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/118.png)

그렇다면 앞서 이야기한 Vop의 **연산 순서**를 생각해봅시다.

위 이미지와 같은 더하기 노드로 ${1 + 1.2}$를 연산할 때,

`int`가 앞에 있는 `int` ${+}$ `float` 상황이라면 결국 `a`의 데이터 타입도 `int`로 결정되고

`a`의 값은 소수 부분이 버려지고 정수 부분만 남은 ${2}$가 되는 것을 실제로 확인 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/056.gif)

`GeometryVopGlobal` 노드가 인풋(input) 입니다. 포지션 값인 `P` 에 `Vector3` ${(1, 0, 0)}$ 를 더해서 포지션 값을 변경 할 수 있습니다.

`GeometryVopOutput` 노드가 아웃풋(Output)입니다. 앞서 계산한 결과를 연결해서 포지션 값을 변경할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/057.gif)
![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/119.png)

`GeometryVopGlobal` 노드의 값을 자세히 보시면 데이터 마다 색상이 다릅니다. 데이터 타입을 컬러로 표현하여 보기 쉽게 처리한 것입니다.

### Vex / Vop 의 차이점
앞서 알아보았듯이 Vex가 할 수 있는 모든 작업을 Vop에서도 할 수 있으며 그 역(Converse)도 마찬가지입니다.

결국 둘은 본질적으로 같습니다. 같은 계산을 노드로 표현하느냐, 코드로 표현하느냐에서 발생하는 표현 방식의 차이가 필연적으로 **연산 순서의 차이**로 나타나게 되는 것입니다.


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
