---
title: "후디니 입문 09 - Vex 언어 : 시계 애니메이션 만들기"
excerpt: "Vex 와 Vop 을 복습하는 차원으로 후디니에서 시계 시스템을 구현해보고자 합니다."
date: 2024-02-09 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-09.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/120.png)

## 시계 애니메이션 만들기

이전 포스트[(링크)](https://walll4542developer.github.io/houdini/Houdini-Beginner-08-Vex-Vop) 에서 배웠던 Vex 와 Vop 을 복습하는 차원으로 후디니에서 간단한 시계 애니메이션을 구현해보고자 합니다.

### 시계 외형 만들기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/058.gif)

먼저 **서클(Circle) 노드**를 준비합니다. 첫번째 서클은 파라미터(Parameter)에서 디비전스(Divisions)  값을 ${12}$로 설정합니다. 왜냐하면 시계에서 표현하는 시간 단위가 ${12}$시간이기 때문입니다.

두번째 서클은 디비전스 값을 ${60}$으로 설정합니다. 분 단위를 표현하기 위해서 입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/059.gif)

파라미터에서 'Delete Geometry But Keep the Points' 를 체크해주면 포인트(Point)들만 남습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/060.gif)

유니폼 스케일(Uniform Scale) 값을 조절하여 시간 단위를 표현할 포인트들의 위치를 분 단위와 겹치지 않도록 배치해줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/061.gif)

'Copy to points' 노드를 사용하여 시간 단위를 표현하는 포인트들의 위치에 구(Sphere)를 복제하여 배치해줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/122.png)

박스(Box) 노드를 사용하여 시계의 시침을 만들었습니다. 같은 방식으로 분침과 초침을 만들고 트랜스폼(Transform) 노드와 연결해서 시, 분, 초침이 시간에 따라 회전하도록 만들 계획입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/062.gif)

트랜스폼의 로테이션(Rotation) 에서 `Z`값을 가지고 회전하면 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/123.png)

같은 방식으로 분침과 초침을 만들어 주고 적당히 사이즈를 조절합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/124.png)

시계를 구성하는 노드를 역할 별로 구분하여 널(Null) 노드로 묶어줍니다. 

이름은 역할에 맞춰서 `Clock_Point` 와 `Clock_Stick` 으로 지정했습니다.

### 시계 로직 구성하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/125.png)

다음은 우리가 시간을 지정하면 시계가 정확한 시, 분, 초침의 위치를 맞춰서 움직이는 부분을 만들 것입니다. 포인트 노드 하나와 어트리뷰트 랭글(Attribute Wrangle)노드를 준비합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/127.png)

```hlsl
float totalRotation = 360.0;
int oneSecondFrame = 24;
int secondDividision = 60;
int minuteDividision = 60;
int hourDivision = 12;
```

시계를 구성하는 요소들을 변수로 선언하는 것 부터 시작합니다. 

- 모든 침이 한 바퀴 회전하는 각도는 ${360˚}$
- 애니메이션의 속도는 ${24}$ frame per second
- 초침은 ${60}$ 초
- 분침은 ${60}$ 
- 시침은 ${12}$ 

#### 채널(Channel) 함수

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/063.gif)

```hlsl
f@a = ch("a");
```

각 변수들을 파라미터에서 손쉽게 제어할 수 있도록 파라미터와 변수를 직접 연결해주는 **채널(Channel) 함수**를 사용할 것입니다. 

위와 같이 `ch()` 로 사용하고 큰 따옴표 ${""}$ 사이에 파라미터의 이름을 지정할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/126.png){: .align-left}
버튼을 누르면 파라미터 `A` 가 생성된 것을 확인 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/064.gif)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/128.png)

필요 없는 파라미터는 'Edit Parameter Interface' 를 눌러 직접 제거해줄 수 있습니다.

```hlsl
int setSecond = chi("setSecond");
int setMinute = chi("setMinute");
int setHour = chi("setHour");
```

- `chf()`
- `chi()`
- `chv()`

위와 같은 방식으로 파라미터가 어떤 데이터 타입을 가지는 변수인지 미리 지정할 수도 있습니다.

```hlsl
f@secondRotation;
f@minuteRotation;
f@hourRotation;
```

이제 시, 분, 초침은 ${1}$초에 몇 도(˚)만큼 회전하는지를 생각해봅시다. 각도 값이기 때문에 어트리뷰트를 `float`으로 선언 했습니다.

- 초침은 ${1}$초에 ${360 / 60 = 6˚}$ 만큼 회전 해야합니다. 
- 분침은 ${1}$초에 ${6 / 60 = 0.1˚}$ 만큼 회전 해야합니다. 
- 시침은 ${1}$초에 ${0.1 / 12 = 0.008333˚}$ 만큼 회전 해야합니다. 

```hlsl
f@secondRotation = setSecond * (totalRotation / secondDividision);
f@minuteRotation = setMinute * (totalRotation / minuteDividision);
f@hourRotation = setHour * (totalRotation / hourDivision); 
```

수식을 코드로 변환하면 위와 같이 정리할 수 있습니다. 그런데 위 코드는 초, 분, 시침 간의 관계를 고려하고 있지 않습니다.

```hlsl
f@secondRotation = setSecond * (totalRotation / secondDividision);
f@minuteRotation = setMinute * (totalRotation / minuteDividision)
    + (f@secondRotation / secondDividision);
f@hourRotation = setHour * (totalRotation / hourDivision) 
    + (f@minuteRotation / minuteDividision) 
    + ((f@secondRotation / secondDividision) / minuteDividision);
```

- 초침이 회전할 때 분침은 초침이 움직인 값 만큼 더 회전해야 합니다.
- 분침이 회전할 때 시침은 분침이 움직인 값 만큼 더 회전해야 합니다. 

따라서 위와 같이 필요한 회전 값을 정리해줄 수 있습니다.

#### 포인트(point) 함수

이제 초침을 회전 시키려면 초침의 트랜스폼의 로테이션(Rotation) 에서 `Z`값을 조절해야 합니다.

파라미터에 로테이션 값을 전달하기 위해서 `point(,,,)`함수를 사용할 것입니다.

```hlsl
point("주소", '포인트 인덱스', "어트리뷰트 이름", '어트리뷰트 주소');
```

포인트 함수에 필요한 인자는 네 가지 입니다. 구성은 위와 같습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/130.png)

주소를 사용하기 쉽게 하기 위해서 먼저 어트리뷰트 랭글 노드의 이름을 `Info`로 변경했습니다.

```hlsl
point(/obj/Clock/Info, 0, P, 3);
```

예를 들어 어트리뷰트 `P` 인 포지션의 `P[z]`값을 파라미터로 가져오고 싶다면 위와 같이 작성하면 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/129.png)

```hlsl
-point("/obj/Clock/Info", 0, secondRotation, 0)
```

초침의 트랜스폼의 로테이션(Rotation) 파라미터의 `Z`값에 포인트 함수를 사용하여 `secondRotation` 의 회전 값을 입력했습니다. 

`secondRotation` 은 단일 `float` 이기 때문에 어트리뷰트 주소는 ${0}$입니다.

시계방향으로 회전해야 하기 때문에 함수 앞에 음수 기호 '${-}$'를 넣었습니다.

파라미터에 입력하는 값은 Vex와 다르게 세미콜론 ${;}$ 이 필요없음에 유의하세요.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/065.gif)

초침이 회전하면 분침과 초침도 따라 회전하는 것을 확인 할 수 있습니다.

#### @Frame

다음은 시간의 흐름이 시계에 적용되어 시계가 알아서 움직이도록 애니메이션 할 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/131.png)

(VOP 노드 인풋에도 포함되어 있습니다)
{: .text-center}

후디니에서 시간 값을 가져오려면 프레임 값인 `@Frame` 어트리뷰트를 사용해야 합니다. 대소문자에 유의하세요.

```hlsl
int oneSecondFrame = 24;
f@fps = (totalRotation / secondDividision) / oneSecondFrame * @Frame;
f@secondRotation = setSecond * (totalRotation / secondDividision) * f@fps;
```

`f@fps`로 초당 프레임을 정의해줍시다. 애니메이션에서 흔히 사용하는 ${24}$ fps 정도가 좋을 것 같습니다. `oneSecondFrame` 값을 ${24}$ 로 정의해줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/066.gif)

`(totalRotation / secondDividision)` 를 ${24}$ fps 로 나눠주면 ${1}$ 초에 ${6˚}$ 를 회전하는 ${24}$ fps 시계 애니메이션이 완성됩니다.


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
