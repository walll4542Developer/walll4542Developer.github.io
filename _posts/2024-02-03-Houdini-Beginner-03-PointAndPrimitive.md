---
title: "후디니 입문 03 - 점, 선, 면 그리고 바운드"
excerpt: "후디니에서 점, 선, 면 모두 더하기(Add) 라는 노드를 사용해서 구현 할 수 있습니다."
date: 2024-02-03 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-03.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---
## 더하기(Add) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/035.png)

후디니에서 점, 선, 면 모두 더하기(Add) 라는 노드를 사용해서 구현 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/033.png)

더하기 노드를 처음 생성하면 씬 뷰(Scene View)에는 아무 것도 출력되지 않습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/037.png)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/005.gif)

'Points' 탭의 'Number of Points'에서 '${+}$' 버튼을 눌러서 추가해주면 공간 상의 좌표만 있고 물리적 실체는 없는 **'포인트'**가 생성됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/036.png)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/034.png){: .align-left} 
버튼을 누르면 씬 뷰에서 포인트 인덱스를 확인할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/039.png)

다음은 선을 만들어 보겠습니다. 포인트와 포인트를 이으면 선을 만들 수 있기 때문에 포인트를 하나 더 생성하겠습니다.

add1를 복사해서 add2를 생성합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/040.png)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/038.png)

add2의 위치 좌표는 ${(1, 0, 0)}$으로 설정합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/040.png)

add1와 add2를 동시에 보려면 머지(Merge) 노드를 사용해서 하나로 합쳐줘야 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/006.gif)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/041.png)

add1와 add2의 순서를 바꿔서 포인트 인덱스를 변경 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/043.png)

선을 만들기 위해서는 더하기 노드가 하나 더 필요합니다. 더하기 노드를 하나 생성하고 머지(merge)의 아웃풋(output)에 연결해줍시다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/007.gif)

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/042.png)

이번에는 'Points' 가 아니라 'Polygons' 탭의 'By pattern' 에서 'By group' 으로 변경해주면 두 포인트가 연결되어 선으로 변합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/044.png)

다음은 면입니다. 포인트를 위 이미지 처럼 ${4}$개를 배치했습니다. 이때 포인트 인덱스의 순서는 ${(0-1-2-3)}$으로 **반시계방향** 입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/046.png)

포인트들을 'By group'으로 이어주면 위와 같은 순서로 연결됩니다. 하지만 ${0}$번과 ${3}$번 포인트의 연결은 되어있지 않습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/047.png)

'Closed' 체크박스를 클릭하면 시작과 끝 포인트를 기준으로 닫히면서 ${0}$번과 ${3}$번 포인트가 연결되어 면이 됩니다.

하지만 **반시계방향** 순서로 포인트를 생성했기 때문에 노말이 아래쪽으로 뒤집혀 있습니다. 그래서 생성된 면의 색상이 빛을 받지 않는 어두운 푸른색입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/048.png)

포인트 인덱스를 위 이미지와 같이 **시계방향**으로 맞춰주겠습니다. 포인트 인덱스의 순서는 ${(0-1-2-3)}$으로 **시계방향** 입니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/008.gif)

머지(merge) 노드 내부에서 생성 순서를 **시계방향**으로 변경하면 생성된 면의 색상이 회색으로 변하는 것을 확인하실 수 있습니다.

## 바운드(Bound) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/049.png)

포인트 인덱스를 조작하여 위와 같이 별 모양을 만들 수도 있습니다.

하지만 이렇게 포인트들을 일일히 이어붙히는 것은 고된 일입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/050.png)

그래서 **바운드(Bound)** 노드를 활용하여 몇 개의 포인트만으로 입체 도형을 만들어 볼 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/051.png)

먼저 add1를 bound1와 이어줍니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/052.png)

bound1에서 `Lower/Upper Padding` 값을 이용하여 포인트를 기준으로 ${0.1m}$ 만큼 간격을 주면 ${0.2m^{3}}$ 부피의 정육면체를 만들 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/010.gif)

두 개 이상의 포인트를 가지고 포인트의 위치를 변경하여 직육면체를 생성할 수도 있습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)