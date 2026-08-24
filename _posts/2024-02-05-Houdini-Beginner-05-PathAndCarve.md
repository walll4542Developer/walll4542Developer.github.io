---
title: "후디니 입문 05 - 패스 그리기, 카브 활용"
excerpt: "다수의 포인트들을 이어서 선을 그리는 방법에 대해서 학습했습니다. 이번에는 선을 사용하여 특정 오브젝트가 따라 움직일 수 있도록 패스를 그려보겠습니다."
date: 2024-02-05 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-05.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---
## 별 만들기
이전 포스트에서 배웠던 Add, Group, Blast 노드를 사용하여 선을 그려 5각형의 별을 그려볼 것입니다.

### 서클(Circle) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/026.gif)

서클(Circle) 노드를 활용하여 원하는 갯수의 변을 가진 정다각형을 그려줄 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/027.gif)

더하기(Add) 노드를 추가하여 'Delete Geometry But Keep the Points' 를 체크 하면 프리미티브(Primitive) 나 폴리곤(Polygon), 버텍스(Vertex)는 제거되고 오직 포인트(Point) 데이터만 남습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/028.gif)

다음은 포인트들을 이어서 선을 그릴 것입니다. 블라스트(Blast) 노드를 사용하여 원하는 순서대로 포인트를 분리해줍니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/070.png)

블라스트 노드를 각각 다른 포인트에 대해서 반복해주고, 별이 그려지는 순서대로 정렬하면 위와 같이 완성할 수 있습니다.

## 패스 그리기
다수의 포인트들을 이어서 선을 그리는 방법에 대해서 복습했습니다.

이번에는 선을 사용하여 특정 오브젝트가 따라 움직일 수 있도록 **패스**를 그려보겠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/071.png)

위와 같이 중간에 한 번 회전하는 패스를 그렸습니다. 그런데 패스가 너무 딱딱하고 각졌기 때문에 이를 부드럽게 만들고 싶습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/072.png)

패스를 곡선으로 만들어 주기 위해서 **리샘플(Resample)** 노드를 사용할 것입니다.

리샘플은 기존에 존재하는 포인트와 포인트 사이에 새 포인트를 생성하거나 기존에 있던 포인트를 제거하는 방식으로 포인트의 갯수를 조절하여 패스의 해상도를 결정합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/029.gif)

파라미터의 Maximum Segment Length 체크박스를 선택하고 길이(Length) 값을 변경하면 포인트와 포인트 사이의 최소 간격을 지정할 수 있습니다.

이때 시작 포인트와 끝 포인트는 항상 유지됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/030.gif)

파라미터의 Maximum Segments 체크박스를 선택하고 세그먼트(Segment) 값을 변경하면 포인트의 최대 갯수를 제한 할 수 있습니다.

이때 시작 포인트와 끝 포인트는 항상 유지됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/031.gif)

두 파라미터를 복합적으로 응용하여 위와 같이 패스의 해상도를 조절 할 수도 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/032.gif)

리샘플 노드의 결과물에 **서브디바이드(Subdivide)** 노드를 사용해서 리샘플 된 패스를 따라 부드럽게 만들 수 있습니다. 

그 다음엔 리샘플의 세그먼트 값을 조절해서 곡률을 조절해서 원하는 곡률으로 조절할 수 있습니다.

### 카브(Carve) 노드
카브(Carve) 노드를 사용하면 패스의 시작과 끝 지점을 비율으로 결정할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/034.gif)

${1}$미터 길이의 선분을 만들고 카브 노드를 연결했습니다.

'First U' 가 시작점, 'Second U' 가 끝점입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/035.gif)

아까 만든 회전하는 패스에 카브 노드를 연결했습니다.

First U 값을 바꾸면 패스의 길이가 변화합니다. 또한 시작점의 포인트 인덱스 넘버가 0번으로 고정되어있는 것을 확인할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/036.gif)

여기서 포인트 인덱스 ${0}$번을 블라스트 노드로 분리해보면 패스를 따라서 포인트가 움직이는 것처럼 보입니다.

이를 응용하여 포인트 인덱스 ${0}$번에 고정된 오브젝트가 패스를 따라 움직이는 애니메이션을 만들어 줄 수 있을 것 같습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/037.gif)

반대로 'Second U' 를 사용하면 끝점의 포인트 인덱스가 계속 변하는 것을 볼 수 있습니다.

이를 방지하기 위해서는 새로운 노드인 **소트(Sort)** 가 필요합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/073.png)

소트 노드는 포인트 인덱스를 원하는 순서대로 정렬할 수 있습니다.

정렬 방식에서 인덱스를 역순으로 바꿔주는 'Reverse' 를 선택하고 결과를 봅시다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/038.gif)

끝점인 'Second U' 가 항상 인덱스 ${0}$번인 것을 확인 할 수 있습니다.

이제 인덱스 ${0}$번에 구(Sphere) 오브젝트를 고정해서 애니메이션 해볼 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/074.png)

위와 같이 'Copy to points' 노드를 사용하면 원하는 포인트 인덱스에 오브젝트를 고정할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/039.gif)

세그먼트의 값을 바꿔도 오브젝트가 패스를 따라 이동하는 것을 볼 수 있습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)