---
title: "후디니 입문 03 - 점, 선, 면 그리고 바운드"
excerpt: 테스트
date: 2024-02-03 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-03.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo.png){: .align-center}

## Add

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/035.png){: .align-center}

후디니에서 점, 선, 면 모두 'Add' 라는 노드를 사용해서 구현 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/033.png){: .align-center}

Add 노드를 처음 생성하면 Scene view에는 아무 것도 출력되지 않습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/037.png){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/005.gif){: .align-center}

'Points' 탭의 'Number of Points'에서 '+' 버튼을 눌러서 추가해주면 공간 상의 좌표만 있고 물리적 실체는 없는 '포인트'가 생성됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/036.png){: .align-center}

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/034.png){: .align-left} 버튼을 누르면 Scene view에서 포인트 인덱스를 확인할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/039.png){: .align-center}

다음은 선을 만들어 보겠습니다. 포인트와 포인트를 이으면 선을 만들 수 있기 때문에 포인트를 하나 더 생성 해보겠습니다.
add1 노드를 복사해서 add2를 생성합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/040.png){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/038.png){: .align-center}

add2의 위치 좌표는 1, 0, 0 으로 설정합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/040.png){: .align-center}

add1 노드와 add2 노드를 동시에 보려면 Merge 노드를 사용해서 하나로 합쳐줘야 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/006.gif){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/041.png){: .align-center}

add1 노드와 add2 노드의 순서를 바꿔서 포인트 인덱스를 변경 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/043.png){: .align-center}

선을 만들기 위해서는 Add 노드가 하나 더 필요합니다. Add 노드를 하나 더 생성하고 merge의 output에 연결해줍시다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/007.gif){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/042.png){: .align-center}

이번에는 'Points' 가 아니라 'Polygons' 탭의 'By pattern' 에서 'By group' 으로 변경해주면 두 포인트가 연결되어 선으로 변합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/044.png){: .align-center}

다음은 면입니다. 포인트를 위 이미지 처럼 4개를 배치했습니다. 이때 포인트 인덱스의 순서는 0-1-2-3으로 **반시계방향** 입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/046.png){: .align-center}

포인트들을 By group으로 이어주면 위와 같은 순서로 연결됩니다. 0번과 3번 포인트의 연결은 되어있지 않습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/047.png){: .align-center}

'Closed' 체크박스를 클릭하면 시작과 끝 포인트를 기준으로 닫히면서 0번과 3번 포인트가 연결되어 면이 됩니다.

하지만 **반시계방향** 순서로 포인트를 생성했기 때문에 노말이 아래쪽으로 뒤집혀 있습니다. 그래서 생성된 면의 색상이 빛을 받지 않는 어두운 푸른색입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/048.png){: .align-center}

포인트 인덱스를 위 이미지와 같이 **시계방향**으로 맞춰주겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/008.gif){: .align-center}

merge 노드 내부에서 생성 순서를 **시계방향**으로 변경하면 생성된 면의 색상이 회색으로 변하는 것을 확인하실 수 있습니다.

## Bound

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/049.png){: .align-center}

포인트 인덱스를 조작하여 위와 같이 별 모양을 만들 수도 있습니다. 

하지만 이렇게 포인트들을 일일히 이어붙히는 것은 고된 일입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/050.png){: .align-center}

그래서 'Bound' 노드를 활용하여 몇 개의 포인트만으로 입체 도형을 만들어 볼 것입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/051.png){: .align-center}

먼저 add1 노드를 bound1 노드와 이어줍니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/052.png){: .align-center}

bound1에서 Lower/Upper Padding 값을 이용하여 포인트를 기준으로 0.1 미터 만큼 간격을 주면 0.2 세제곱미터 부피의 정육면체를 만들 수 있습니다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/010.gif){: .align-center}

두 개 이상의 포인트를 가지고 포인트의 위치를 변경하여 직육면체를 생성할 수도 있습니다.