---
title: "후디니 입문 19 - Solver"
excerpt: "Solver 노드는 이전 프레임의 결과에 만들어준 규칙을 시간에 따라 이터레이션 횟수만큼 반복하는 기능입니다. 후디니에서 많은 연산이 필요한 물리 시뮬레이션(Simulation)을 시행 할 때 주로 사용됩니다."
date: 2024-02-19 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-19.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/166.png)

`Solver` 노드는 이전 프레임의 결과에 만들어준 규칙을 시간에 따라 이터레이션 횟수만큼 반복하는 기능입니다. 후디니에서 많은 연산이 필요한 물리 시뮬레이션(Simulation)을 시행 할 때 주로 사용됩니다.

몇 가지 조건을 갖춘다면 `Solver` 노드는 `forloop`와 동일하게 사용 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/167.png)

`Solver` 노드를 더블 클릭하면 노드 내부로 들어갈 수 있습니다. 

여기에 `forloop` 의 내용을 복사후 붙혀넣기해서 `Prev_Frame` 과 `OUT` 사이에 연결합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/127.gif)

파라미터(Parameter)의 **'Reset Simulation'** 버튼을 눌러서 시뮬레이션에 사용된 캐시(Cache)를 모두 초기화 한 후 애니메이션을 플레이해서 결과를 보면 `forloop`와 동일한 결과임을 알 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/170.png)

시뮬레이션 캐시는 후디니의 타임라인에 파란색으로 나타납니다.

만약 `Solver` 노드 내부에 반복 해야 할 내용이 수정되었다면 캐시의 색상이 파란색에서 주황색으로 바뀝니다. 

이때 애니메이션을 다시 재생하거나, 시작 프레임으로 가거나, 'Reset Simulation' 버튼을 눌러서 캐시를 지운다음 재생하면 캐시의 색상이 다시 파란색으로 바뀌고 정상적으로 재생됩니다.

### 솔버(Solver) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/168.png)

- 'Start Frame' 은 시뮬레이션을 시작할 프레임입니다.
- 'Sub Steps' 는 한 프레임당 반복할 횟수입니다. 단, 최초 'Start Frame'에는 적용되지 않습니다. 이후부터 정상 적용됩니다. 

`Solver` 노드를 응용하면서 실제 동작을 구체적으로 살펴보겠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/169.png)

```hlsl
@Alpha = 1.0;
i@count = 0;
s@condition = "a";
```

이번에는 박스가 아닌 더하기(Add) 노드로 포인트(Point)를 하나 생성했습니다.

어트리뷰트 랭글 노드를 추가하고 이름을 `init`으로 지은 다음 위와 같이 초기 값을 설정해줬습니다.

`Solver`의 'Start Frame'을 ${11}$으로 설정합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/128.gif)

```hlsl
if(s@condition == "a" && i@count >= 9)
{
    s@condition = "b";
}

if(s@condition == "b" && i@count <= 0)
{
    s@condition = "a";
}
```

```hlsl
if(s@condition == "a")
{
    i@count ++;
}
else
{
    i@count --;
}
```

다음은 `Solver` 노드 내부에 어트리뷰트 랭글 노드 두개를 추가하고 위와 같이 작성합니다.

`i@count` 값이 ${9}$보다 크다면 `s@condition` 값을 `b`로 바꿉니다.

`s@condition` 값이 `a` 라면 매 프레임마다 ${1}$씩 `i@count` 를 증가시키고 아니면 반대로 감소시킵니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/171.png)

```hlsl
@P.y = i@count;
```

`Solver`의 반복이 끝난 시점에서 포인트의 높이 `@P.y`을 `i@count`로 정한다면, 포인트의 위치는 ${y}$축 방향으로 ${9}$까지 올라갔다가 다시 ${0}$으로 내려오는 것을 반복할 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/129.gif)

완성입니다. 끝까지 읽어주셔서 감사합니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
