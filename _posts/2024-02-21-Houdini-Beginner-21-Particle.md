---
title: "후디니 입문 21 - Particle System Part 2"
excerpt: "solver 노드를 사용하여 파티클 시스템(Particle System) 구현을 모방하고 원리를 이해하고자 합니다."
date: 2024-02-21 00:00:00 -0000
categories: Study
tag: Houdini

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-21.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/135.gif)

이전 포스트에서는 일정 주기로 포인트를 생성하고 이동하는 것을 구현했습니다.

이번에는 반대로 **일정 시간이 흐르면 포인트가 소멸**하도록 해보겠습니다.

### 바이패스(Bypass)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/181.png)

노드가 많아질 경우 노드를 일일히 제거하고 다시 사용하기에는 손이 많이 갑니다. 

그래서 원하지 않는 노드를 무시하고 진행하는 **바이패스(Bypass)** 기능이 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/138.gif)

노란색 화살표 아이콘을 클릭하여 바이패스 기능을 활성화 할 수 있습니다.

### 포인트 소멸

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/179.png)

어트리뷰트 랭글(Attribute Wrangle) 노드를 추가하고 이름을 `Update_Age` 로 설정했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/136.gif)

```hlsl
i@Age ++;
```

`solver` 노드 내부에서 포인트가 생성될 때를 기준으로 매 프레임 마다 `i@Age` 값이 ${1}$ 만큼 증가할 것이고 이를 포인트의 수명으로 사용할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/180.png)

```hlsl
if(i@Age > 30)
{
  removepoint(0, @ptnum);
}
```

다음은 `i@Age` 값이 ${30}$ 보다 크면 포인트를 제거할 수 있도록 이름을 `Remove_Point` 로 설정한 어트리뷰트 랭글 노드를 작성합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/137.gif)

`i@Age` 값이 ${30}$ 보다 큰 포인트는 소멸하는 것을 확인 할 수 있습니다.

## 충돌 규칙

다음은 움직이는 포인트들이 벽에 부딪치면 튕겨져 나오는 충돌 규칙을 설정해보려고 합니다.

포인트들은 ${2}$차원 평면의 **사각형 박스** 안에 있도록 구현할 것입니다.

핵심 아이디어는 벽에 부딪친 포인트의 방향을 반대로 바꿔서 **반사** 하는 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/182.png)

```hlsl
f@xMin= chf("xMin");
f@xMax = chf("xMax");

f@yMin= chf("yMin");
f@yMax = chf("yMax");
```

포인트가 부딪치는 벽을 한계라는 뜻의 `limit` 이라는 이름으로 정했습니다. 파라미터(Parameter)로 박스의 크기를 정해줄 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/183.png)

```hlsl
//hscript
-ch("xMax")
-ch("yMax")
```

직사각형 박스로 구현할 생각이라 박스의 크기를 `xMin` 과 `yMin`을 부호 반전한 값으로 설정합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/184.png)

`solver` 노드의 ${2}$번 인풋(input)으로 `limit`의 값이 들어오기 때문에 위와 같이 ${2}$번 인풋(input)의 이름을 `get_limit` 으로 바꾸었습니다.

```hlsl
float xMin = point(1, "xMin", 0);
float xMax = point(1, "xMax", 0);
float yMin = point(1, "yMin", 0);
float yMax = point(1, "yMax", 0);

if(@P.x > xMax || @P.x < xMin)
{
  v@velocity = v@velocity * {-1, 1, 1};
}

if(@P.y > yMax || @P.y < yMin)
{
  v@velocity = v@velocity * {1, -1, 1};
}
```

${x}$축과 ${y}$축의 `limit` 값보다 포인트의 위치가 크거나 작을 경우 벡터(Vector)가 반대로 되도록 설정했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/139.gif)

`@P.x` 값이 ${[-50, 50]}$ 또는 `@P.y` 값이 ${[-40, 40]}$ 범위를 넘어설 경우 반사되어 움직이는 것을 확인 할 수 있습니다.

<!-- 다음은 박스가 보이도록 박스의 테두리를 렌더링 하고자 합니다. -->

```hlsl
vector a = set(@xMin, @yMin, 0);
vector b = set(@xMin, @yMax, 0);
vector c = set(@xMax, @yMin, 0);
vector d = set(@xMax, @yMax, 0);
```

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
