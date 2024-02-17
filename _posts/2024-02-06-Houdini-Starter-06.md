---
title: "후디니 입문 06 - 절차생성(Procedural) 모델링"
excerpt: "후디니에서 절차생성 모델링 개념의 핵심은 모델의 모든 데이터를 하나의 인풋으로 제어하여 모델링 데이터를 생산하는 시스템을 구축하는 것입니다. 예를 들어 테이블을 절차생성으로 모델링 하고 싶다면, 단일 노드의 파라미터에 적절한 초기값만 설정하면 테이블이 생성되어야 합니다."
date: 2024-02-06 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-06.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 절차생성(Procedural) 모델링
이번에는 후디니를 이용한 절차생성(Procedural) 모델링의 기본기에 대해서 배워보겠습니다.

후디니에서 절차생성 모델링 개념의 핵심은 모델의 **모든 데이터를 하나의 인풋(input)으로 제어하여 모델링 데이터를 생산하는 시스템**을 구축하는 것입니다.

예를 들어 테이블을 절차생성으로 모델링 하고 싶다면, 단일 노드의 파라미터(Parameter)에 적절한 초기값만 설정하면 테이블이 생성되어야 합니다. 그래서 이번 시간에는 테이블을 절차생성 할 수 있는 시스템을 구축 해보겠습니다.

### 널(null) 노드

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/075.png){: .align-center}

먼저 우리는 오직 다른 기능은 없이 파라미터들만 제어하기 위한 노드가 필요합니다. \\
그래서 비어있는 **Null 노드**를 생성합니다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/076.png){: .align-center}

이 노드는 제어하는 역할을 담당할 것이기 때문에 노드의 이름을 컨트롤러(Controller) 라고 정했습니다. \\
컨트롤러 노드는 위 이미지와 같이 어떤 파라미터도 가지고 있지 않지만, 여기에 우리가 필요한 여러가지 커스텀 파라미터(Custom Parameter)를 추가할 것입니다.

### 파라미터(parameter) 설정하기

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/077.png){: .align-center}

톱니바퀴 모양 아이콘을 클릭하면 'Edit Parameter Interface...' 라는 메뉴가 나옵니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/040.gif){: .align-center}

이를 클릭하면 여러가지 파라미터를 선택 하고 생성할 수 있는 창으로 연결됩니다. \\
왼쪽에서 드래그 앤 드랍을 통해 오른쪽으로 원하는 파라미터를 옮겨 올 수 있습니다. \\
여러가지 파라미터를 정리할 수 있도록 폴더 기능도 제공합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/078.png){: .align-center}

여기서 파라미터를 생성하기 전에 *테이블은 정말 단순한 가구지만* 이를 절차생성 하려면 테이블의 구조에 대해서 먼저 고민해 볼 필요가 있습니다.

테이블은 크게 두 가지로 구분되는데요, 테이블 탑이라고 부르는 상판(TableTop)과 상판을 받치는 하부구조로 구분됩니다. 

상판과 하부구조 둘 다 디자인에 따라 천차만별의 다양성이 있겠으나, 이번에는 절차생성이 처음인 만큼 위 이미지와 같이 박스(box) 형태의 상판과 4개의 박스 형태의 다리가 붙어있는 가장 심플한 구조인 것으로 생각하겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/079.png){: .align-center}

먼저 상판의 형태와 크기를 결정하고자 합니다. \\
포인트를 하나 생성하고 트랜스폼(Transform) 노드로 4개로 복제한 다음, 하나의 바운드(Bound) 노드로 묶어서 상판을 제작하겠습니다. \\
이때 상판의 중앙은 0, 0, 0 에 있는 것이 계산하기 편하므로 각 포인트의 위치 좌표는 위 이미지와 같습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/041.gif){: .align-center}

바운드 노드로 묶으면 상판이 만들어지고, Upper Padding 값을 조절하면 상판의 두께를 제어할 수 있습니다. \\
지금 제작한 노드의 기능을 파라미터와 연결해서 다시 제작 해보겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/080.png){: .align-center}

먼저 포인트의 위치는 1, 0, 1에 둡니다. 왜냐하면 트랜스폼 노드의 스케일(scale) 값을 사용해서 파라미터를 제어할 것이기 때문에 포인트의 포지션 값이 1이어야 스케일 계산이 가능하기 때문입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/081.png){: .align-center}

이전에 제작했던 컨트롤러 노드의 'Edit Parameter Interface...' 메뉴로 진입해서 위와 같이 파라미터를 작성합니다. \\
이름(name)은 파라미터의 **변수 이름**이며 라벨(Label)은 파라미터 윈도우에 표시되는 이름입니다. *둘은 엄연히 다릅니다!* \\
또한 파라미터의 범위(Range)를 제한 해줄 수 있습니다. 상판의 x축 크기를 결정하는 파라미터인 SizeX의 값은 최소 0이며 최대 5로 설정했습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/082.png){: .align-center}

폴더를 제작할 때는 'End Tab Group' 옵션을 활성화 해서 폴더가 파라미터를 담는 끝 부분이 있도록 합니다. \\
활성화 하지 않으면 이후에 추가되는 파라미터들도 따로 폴더를 설정하지 않을 경우엔 모두 해당 폴더에 추가됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/083.png){: .align-center}




## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))