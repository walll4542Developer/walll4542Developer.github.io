---
title: "후디니 입문 17 - Foreach 반복문"
excerpt: "후디니에서 foreach 반복문 노드를 사용하는 방법에 대해서 알아보겠습니다."
date: 2024-02-17 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-17.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/151.png)

후디니에서 노드로 `foreach` 반복문을 사용하는 방법에 대해서 알아보겠습니다. 

### foreach 반복문

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/111.gif)

후디니의 `foreach` 반복문 동작을 다음과 같이 정의할 수 있습니다.
>`foreach input` 는 모든 `input`을 분해(blast)한 뒤, `foreach` 블록(block)의 내부 작업을 수행하고 나서 하나의 결과로 묶어(merge)줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/153.png)

빨간색 네모로 강조된 주황색으로 묶여있는 부분을 블록(block)이라고 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/152.png)

`input`으로 포인트(point) 또는 프리미티브(Primitive)가 들어올 수 있습니다.

## 응용하기

### 절차생성 모델링

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/111.gif)

절차생성(Procedural) 모델링([링크](https://walll4542developer.github.io/houdini/Houdini-Beginner-06-Procedural)) 방식으로 배경 모델링 바닥에 사용할 잔디를 만들어 보겠습니다.

#### 랜드(rand) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/155.png)

```hlsl
f@seed = rand(0);
```

`rand()` 함수를 사용하면 ${0}$에서 ${1}$사이의 랜덤한 값을 `f@seed` 에 반환합니다.

`random()` 함수와는 다릅니다! `rand()`입니다. 혼동하지 않도록 주의하세요.
{: .notice--info}

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/112.gif)

```hlsl
f@seed = rand(chi("randomSeed"));
```

`randomSeed` 값을 파라미터로 설정하면 랜덤 값을 조절하기 더 쉽습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/113.gif)

서클(Circle) 노드와 스캐터(Scatter) 노드를 사용하면 서클이 만든 폴리곤 범위 내부에 포인트를 무작위로 배치합니다. 포인트 숫자는 'Force Total Count' 로 조절 할 수 있습니다.

서클은 XZ Plane 방향으로 설정해야 합니다.
{: .notice--info}

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/156.png)

```hlsl
f@seed = rand(@ptnum);
```

모든 `@ptnum` 포인트의 포인트 인덱스 값을 넣어준다면 모든 포인트가 각각 `f@seed` 값을 가지게 됩니다. 

이제 ${y}$축 방향으로 포인트 몇 개를 직접 배치하여 잔디의 형태를 만들어 보겠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/157.png)

```hlsl
vector directionA = set(0, 1, 0);
vector directionB = set(1, 1, 0);

vector a = @P + directionA;
vector b = @P + directionA + directionB;

addpoint(0, a);
addpoint(0, b);
```

포인트 ${a}$와 ${b}$를 배치하고 더하기(Add) 노드를 사용해서 'By group'으로 세그먼트(Segment)으로 만듭니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/114.gif)

리샘플(Resample) 노드와 서브디바이드(subdivide) 노드를 사용해서 부드럽게 보간합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/115.gif)

```hlsl
float seedX = rand(f@seed);
float x = fit(seedX, 0, 1, -1, 1);

vector directionA = set(0, 1, 0);
vector directionB = set(x, 1, 0);

vector a = @P + directionA;
vector b = @P + directionA + directionB;

addpoint(0, a);
addpoint(0, b);
```

이미 랜덤인 시드 값을 한 번 더 `rand()` 적용함으로서 더욱 랜덤하게 만들어 줄 수 있습니다.

랜덤으로 생성된 `f@seed` 값을 `fit(,,,,)`으로 편집 해서 잔디가 자라나는 방향을 설정할 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/116.gif)

```hlsl
float seedX = rand(f@seed);
float x = fit(seedX, 0, 1, -1, 1);

float seedZ = rand(f@seed + 0.123); // random
float z = fit(seedZ, 0, 1, -1, 1);

vector directionA = set(0, 1, 0);
vector directionB = set(x, 1, z);
```

같은 방식을 ${(x, y, z)}$ 모두에 적용할 수 있습니다. 다만 높이인 ${y}$는 카브(carve) 노드를 사용해서 제어할 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/117.gif)

```hlsl
float seedY = rand(@seed + 0.321);
f@y = fit(seedY, 0, 1, chf("min"), 1);
```

`min` 값으로 잔디의 높이 최저치를 설정합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/158.png)

```hlsl
point("../y", 0, "y", 0)
```

`f@y`를 카브 노드의 'SecondU' 값으로 사용합니다.

그런데 카브 노드를 사용하게 되면 전체 세그먼트에 사용되는 포인트 숫자가 균일하지 않게 됩니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/118.gif)

전체 세그먼트 길이와 상관없이 포인트 숫자가 일정하도록 한 번 더 리샘플(Resample) 노드와 서브디바이드(subdivide) 노드를 사용합니다.

서브디바이드 노드로 카브의 결과 값을 부드럽게 수정한 다음, 리샘플 노드의 'Maximum Segment Length' 옵션을 사용하여 최대 세그먼트 숫자를 강제합니다.

#### 폴리와이어(Polywire) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/119.gif)

폴리와이어(Polywire) 노드는 세그먼트 데이터를 기반으로 폴리곤 와이어를 만드는 노드입니다.

'Wire Radius'를 조절하면 폴리곤 와이어의 반지름을 제어합니다. 잔디 모양을 폴리곤으로 표현하기 위하여 와이어의 길이에 따라 반지름을 다르게 설정하고자 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/149.png)

리샘플(resample) 노드에서 'curve U Attribute'를 체크하면 `@curveu` 어트리뷰트를 만들수 있습니다.

`@curveu`는 커브의 시작과 끝 길이를 ${0}$과 ${1}$사이로 정규화한 값을 반환합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/160.png)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/121.gif)

```hlsl
@thickness = chramp("ramp", @curveu) * chf("thickness");
@Cd = {0, 1, 0};
```

'Wire Radius' 값을 `chramp(,)`로 제어하며 `@curveu` 값을 램프로 사용합니다. 

잔디의 형태를 램프를 수정하여 묘사해줍니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/159.png)

이전에 서클(Circle) 노드와 스캐터(Scatter) 노드를 사용하여 포인트를 무작위 위치에 배치해두었습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/161.png)

```hlsl
f@seed = random(@ptnum);
```

이 포인트들을 **잔디가 위치할 포인트로 사용**합니다. 지금까지 작업한 내용을 `foreach` 블록 내부로 옮깁니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/162.png)

컬러(color) 노드를 사용하여 잔디의 색상도 적당히 바꿔줍시다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/122.gif)

포인트 숫자는 'Force Total Count' 로 조절 할 수 있습니다. \\
서클의 'Uniform Scale' 값을 키워서 풀이 자라는 영역을 조절 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/123.gif)

절차생성 모델링으로 잔디를 완성했습니다. 끝까지 읽어주셔서 감사합니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
