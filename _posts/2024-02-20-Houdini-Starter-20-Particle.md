---
title: "후디니 입문 20 - Particle System"
excerpt: "solver 노드를 사용하여 파티클 시스템(Particle System) 구현을 모방하고 원리를 이해하고자 합니다."
date: 2024-02-20 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-20.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

`solver` 노드를 사용하여 파티클 시스템(Particle System) 구현을 모방하여 원리를 이해하고자 합니다. 

포인트를 생성하고 원하는 방향으로 포인트를 이동시키는 간단한 동작부터 구현 해보겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/172.png){: .align-center}

먼저 위와 같은 구성으로 노드를 준비합니다. 'add1' 이 생성할 포인트이며 'add2'는 포인트의 속도 파라미터(parameter)를 담당할 것입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/130.gif){: .align-center}

```hlsl
v@velocity = chv("velocity");
```

```hlsl
vector velocity = point(1, "velocity", 0);
@P += velocity;
```

포인트를 생성하고 `v@velocity` 값으로 방향과 크기가 있는 벡터 ${(1, 1, 0)}$를 설정해서 매 프레임 마다 벡터 방향으로 포인트가 벡터 크기만큼 이동하게 했습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/173.png){: .align-center}

널(null) 노드의 이름을 각각 'container' 와 'info'로 바꿔줍니다.

또한 파라미터를 담당하는 'add2' 를 `solver` 노드의 네 번째 인풋(input)으로 설정합니다.

### 스위치(Switch) 노드

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/175.png){: .align-center}

이번에는 포인트 한 개를 생성하는 것이 아니라 여러개의 포인트를 생성해서 내가 원하는 타이밍에 원하는 방향으로 이동하도록 하고 싶습니다. 

이를 위해서 **스위치(Switch) 노드**를 사용할 것입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/174.png){: .align-center}

```hlsl
$FF == 15 // hscript
```

스위치 노드의 'Select Input' 에 hscript 구문을 사용할 수 있습니다.

`$FF` 는 현재 프레임 값을 뜻합니다. 현재 프레임이 ${15}$일 경우 참(true)이라서 ${1}$을 반환하고 거짓(false)이면 ${0}$을 반환합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/131.gif){: .align-center}

반환하는 값은 스위치 노드에 연결된 인풋 데이터의 순서와 같습니다. 

인풋 데이터를 보시면 'null' 노드가 ${0}$번 이며, 솔버 노드의 네 번째 인풋인 'get_info'가 ${1}$번입니다.

따라서 현재 프레임이 ${15}$일 경우 순서 ${1}$번 'get_info' 가 스위치 노드의 결과로 반환되는 것입니다.



## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
