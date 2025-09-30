---
title: "후디니 입문 06 - 절차생성(Procedural) 모델링"
excerpt: "후디니에서 절차생성 모델링 개념의 핵심은 모델의 모든 데이터를 하나의 인풋으로 제어하여 모델링 데이터를 생산하는 시스템을 구축하는 것입니다. 예를 들어 테이블을 절차생성으로 모델링 하고 싶다면, 단일 노드의 파라미터에 적절한 초기값만 설정하면 테이블이 생성되어야 합니다."
date: 2024-02-06 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-06.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
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

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/075.png)

먼저 우리는 오직 다른 기능은 없이 파라미터들만 제어하기 위한 노드가 필요합니다.

그래서 비어있는 **Null 노드**를 생성합니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/076.png)

이 노드는 제어하는 역할을 담당할 것이기 때문에 노드의 이름을 컨트롤러(Controller) 라고 정했습니다.

컨트롤러 노드는 위 이미지와 같이 어떤 파라미터도 가지고 있지 않지만, 여기에 우리가 필요한 여러가지 커스텀 파라미터(Custom Parameter)를 추가할 것입니다.

### 파라미터(parameter) 설정하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/077.png)

톱니바퀴 모양 아이콘을 클릭하면 **'Edit Parameter Interface...'** 라는 메뉴가 나옵니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/040.gif)

이를 클릭하면 여러가지 파라미터를 선택 하고 생성할 수 있는 창으로 연결됩니다.

왼쪽에서 드래그 앤 드랍을 통해 오른쪽으로 원하는 파라미터를 옮겨 올 수 있습니다. 여러가지 파라미터를 정리할 수 있도록 폴더 기능도 제공합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/078.png)

여기서 파라미터를 생성하기 전에 *테이블은 정말 단순한 가구지만* 이를 절차생성 하려면 테이블의 구조에 대해서 먼저 고민해 볼 필요가 있습니다.

테이블은 크게 두 가지로 구분되는데요, 테이블 탑이라고 부르는 상판(TableTop)과 상판을 받치는 하부구조로 구분됩니다. 

상판과 하부구조 둘 다 디자인에 따라 천차만별의 다양성이 있겠으나, 이번에는 절차생성이 처음인 만큼 위 이미지와 같이 박스(box) 형태의 상판과 ${4}$개의 박스 형태의 다리가 붙어있는 가장 심플한 구조인 것으로 생각하겠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/079.png)

먼저 상판의 형태와 크기를 결정하고자 합니다.

포인트를 하나 생성하고 트랜스폼(Transform) 노드로 ${4}$개로 복제한 다음, 하나의 바운드(Bound) 노드로 묶어서 상판을 제작하겠습니다. 

이때 상판의 중앙 좌표는 ${(0, 0, 0)}$ 에 있는 것이 계산하기 편하므로 각 포인트의 위치 좌표는 위 이미지와 같습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/041.gif)

바운드 노드로 묶으면 상판이 만들어지고, `Upper Padding` 값을 조절하면 상판의 두께를 제어할 수 있습니다.

지금 제작한 바운드 노드의 기능을 컨트롤러 노드에 파라미터 추가한 다음 트랜스폼 노드와 연결해서 다시 제작 해보겠습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/080.png)

먼저 포인트의 위치는 ${(1, 0, 1)}$ 에 둡니다. 왜냐하면 트랜스폼 노드의 스케일(scale) 값을 사용해서 파라미터를 제어할 것이기 때문에 포인트의 포지션 값이 1이어야 스케일 계산을 하기 쉽기 때문입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/081.png)

이전에 제작했던 컨트롤러 노드의 'Edit Parameter Interface...' 메뉴로 진입해서 위와 같이 파라미터를 작성합니다.

이름(name)은 파라미터의 **변수 이름**이며 라벨(Label)은 파라미터 윈도우에 표시되는 이름입니다. *둘은 엄연히 다릅니다!*

또한 파라미터의 범위(Range)를 제한 해줄 수 있습니다. 상판의 ${x}$축 크기를 결정하는 파라미터인 `SizeX`의 값은 최소 ${0}$이며 최대 ${5}$로 설정했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/082.png)

폴더를 제작할 때는 'End Tab Group' 옵션을 활성화 해서 폴더가 파라미터를 담는 끝 부분이 있도록 합니다.

활성화 하지 않으면 이후에 추가되는 파라미터들도 따로 폴더를 설정하지 않을 경우엔 모두 해당 폴더에 추가됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/043.gif)

'Edit Parameter Interface' 창에서 파라미터를 선택하고 단축키 'Ctrl + C, V'로 복사 후 붙혀넣기도 가능합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/083.png)

컨트롤러 노드에 `SizeX` 와 `SizeY` 파라미터가 추가된 것을 확인 하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/042.gif)

다음은 컨트롤러 노드의 파라미터와 트랜스폼 노드의 파라미터를 연결할 것입니다.

복사하길 원하는 파라미터에 마우스 우클릭을 하면 위와 같이 여러가지 메뉴가 나옵니다. 여기서 **'Copy Parameter'** 를 클릭해서 파라미터를 복사합니다.

다음은 연결 해야하는 'transform1' 노드의 `scale` ${x}$값 파라미터에 마우스를 가져다 대고 우클릭 후 **'Paste Relative References'** 버튼을 누르면 파라미터가 초록색으로 변하며 연결 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/044.gif)

초록색으로 표시된 파라미터와 연결되어 포인트가 스케일 되어 위치가 변하는 것을 확인 하실 수 있습니다.

이는 파라미터 값을 일종의 수식과 함수로 연결한 것이며, 수식을 직접 입력해서 연결하거나 내용을 편집할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/045.gif)

파라미터의 라벨을 클릭하면 파라미터를 수식이 아닌 실제로 계산하는 수치 값을 확인 할 수 있습니다.

## 테이블 만들기

예를 들어 수식의 제일 앞 부분에 음수 부호 '${-}$' 를 입력한다면 파라미터로 들어오는 수치 값을 음수로 받을 수 있습니다.

위 이미지에서 파라미터가 음수가 되게 하였을 때 포인트의 위치가 음수 값의 좌표로 이동하는 것을 확인 하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/046.gif)

트랜스폼 노드의 스케일 파라미터 값에 음수를 입력하여 포인트들의 좌표가 ${(x, y) (-x, y) (x, -y) (-x, -y)}$ 가 되도록 하고 바운드 노드와 연결하면 위 이미지 처럼 원점 ${(0, 0, 0)}$ 에서 대칭하는 테이블탑을 만들 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/047.gif)

같은 방식으로 컨트롤러에 테이블탑의 두께를 조절할 프로퍼티를 넣어줍니다. 저는 'TopThick' 이라는 이름으로 정했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/048.gif)

다음은 테이블의 다리(Leg)를 만들 차례입니다. 트랜스폼 노드로 만든 포인트들의 좌표를 재활용해서  다리를 만들어줄 것입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/084.png)

트랜스폼 노드를 하나 더 추가하고, 둘을 머지(merge) 노드로 합친 다음 바운드 노드로 박스를 만들어 다리를 만들었습니다. 이것을 세번 더 반복하여 4개의 다리를 모두 만들어줍시다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/049.gif)

다음은 다리의 두께를 결정해줄 `LegThick` 파라미터를 추가합니다. 이를 레그(leg) 의 모든 바운드 노드의 `Lower Padding` 그리고 `Upper Padding` 값에 파라미터로 연결해줍니다.

위 이미지 처럼 같은 노드 내부의 파라미터 값을 연결하는 것도 가능합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/085.png)

컨트롤러의 `LegThick` 값을 'Lower Padding' 의 `x` 파라미터에 연결했습니다.

그 다음 다시 'Lower Padding' 의 `x` 파라미터를 복사 해서 `z` 파라미터에 연결했으나 `ch("../Controller/LegThick")` 가 아닌 `ch("minpadx")` 로 연결된 것을 확인 할 수 있습니다.



## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)