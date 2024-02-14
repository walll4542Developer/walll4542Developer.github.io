---
title: "후디니 입문 05 - 패스 그리기, 카브 활용"
excerpt: "노드로 생성한 데이터들을 Merge 노드를 사용해서 하나로 합쳐줄 때, 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다."
date: 2024-02-05 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-04.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 별 만들기

지난 시간에 배웠던 Add, Group, Blast 노드를 사용하여 선을 그려 5각형의 별을 그려볼 것입니다.

### Circle 노드

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/026.gif){: .align-center}

Circle 노드를 활용하여 원하는 크기의 변을 가진 정다각형을 그려줄 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/027.gif){: .align-center}

Add 노드를 추가하여 'Delete Geometry But Keep the Points' 를 체크 하면 Primitive 나 Polygon, Vertex는 제거되고 오직 포인트(Point) 데이터만 남습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/028.gif){: .align-center}

다음은 포인트들을 이어서 선을 그릴 것입니다. Blast 노드를 사용하여 원하는 순서대로 포인트를 분리해줍니다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/070.png){: .align-center}

Blast 를 각각 다른 포인트에 대해서 반복해주고, 별이 그려지는 순서대로 정렬하면 위와 같이 완성할 수 있습니다.

## 패스 그리기

다수의 포인트들을 이어서 선을 그리는 방법에 대해서 복습했습니다. \\
이번에는 선을 사용하여 특정 오브젝트가 따라 움직일 수 있도록 **패스**를 그려보겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/071.png){: .align-center}

위와 같이 중간에 한 번 회전하는 패스를 그렸습니다. 그런데 패스가 너무 딱딱하고 각졌기 때문에 이를 부드럽게 만들고 싶습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/072.png){: .align-center}

패스를 곡선으로 만들어 주기 위해서 리샘플(Resample) 노드를 사용할 것입니다.

리샘플은 기존에 존재하는 포인트와 포인트 사이에 새 포인트를 생성하거나 기존에 있던 포인트를 제거하는 방식으로 포인트의 갯수를 조절하여 **패스의 해상도**를 결정합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/029.gif){: .align-center}

파라미터의 Maximum Segment Length 체크박스를 선택하고 길이(Length) 값을 변경하면 포인트와 포인트 사이의 최소 간격을 지정할 수 있습니다. \\
이때 시작 포인트와 끝 포인트는 항상 유지됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/030.gif){: .align-center}

파라미터의 Maximum Segments 체크박스를 선택하고 세그먼트(Segment) 값을 변경하면 포인트의 최대 갯수를 제한 할 수 있습니다. \\
이때 시작 포인트와 끝 포인트는 항상 유지됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/031.gif){: .align-center}

두 파라미터를 복합적으로 응용하여 위와 같이 패스의 해상도를 조절 할 수도 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/032.gif){: .align-center}

서브디바이드(Subdivide) 노드를 사용해서 



## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))