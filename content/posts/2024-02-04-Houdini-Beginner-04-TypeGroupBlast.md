---
title: "후디니 입문 04 - 데이터 타입, 그룹, 블라스트"
excerpt: "노드로 생성한 데이터들을 머지 노드를 사용해서 하나로 합쳐줄 때, 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다."
date: 2024-02-04 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-04.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---
## 데이터 타입
노드로 생성한 데이터들을 머지(Merge) 노드를 사용해서 하나로 합쳐줄 때, **노드가 가지고 있는 데이터 타입이 모두 동일**해야 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/053.png)

예를 들어 더하기(Add) 노드로 생성한 포인트 두 개가 있을 때, 위 이미지 처럼 한 쪽에만 컬러(Color) 노드를 연결하는 경우 경고 표시가 나옵니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/054.png)

한 쪽 포인트에는 컬러 데이터인 `Cd` 값이 들어있는데, 다른 쪽 포인트에는 없어서 그렇습니다.

머지 노드로 합쳤는데 두 포인트가 가진 데이터 타입이 일치하지 않기 떄문입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/055.png)

양쪽 모두 컬러 노드를 연결해서 `Cd` 값이 있으면 경고 표시는 사라집니다.

### 그룹(Group) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/057.png)

그룹(Group) 노드는 연결된 노드가 가진 데이터에 그룹 정보를 추가합니다.

'Group name' 에서 그룹의 이름을 지정할 수 있으며, 'Group Type'에서 특정 타입의 데이터에만 그룹을 지정하는 것도 가능합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/011.gif)

그룹 노드를 사용해서 연결하면 그룹으로 지정된 포인트들이 색상이 변하고 활성화 됩니다.

그룹은 한 번에 하나의 노드에만 연결할 수 있습니다. 그래서 머지 노드로 합쳐준 이후에 사용하게 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/059.png)

예를 들어 위와 같이 7개의 포인트를 씬에 배치하고 컬러도 다르게 설정 했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/060.png) 

그런 다음 각 포인트들을 그룹 **A**와 그룹 **B**의 두 그룹으로 묶어줬습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/012.gif) 

위 처럼 머지 되는 순서를 변경하면 포인트 인덱스는 변하지만 그룹 정보는 그대로 입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/061.png) 

인포(Info) 창에서 정보를 확인하면 2개의 포인트 그룹이 있으며, 각각 이름은 **A**와 **B**라고 쓰여있는 것을 확인 할 수 있습니다.

### 블라스트(Blast) 노드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/013.gif) 

블라스트(Blast) 노드를 사용하면 원하는 그룹 이름을 지정해서 해당 그룹만 출력되게 하거나 반대로 출력되지 않게 할 수 있습니다. 

그룹 이름은 대소문자를 구분합니다.
{: .notice--info}

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/014.gif) 

여러 그룹을 한 번에 제어할 수도 있습니다. 그룹 이름을 띄어쓰기로 구분합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/063.png) 

블라스트 노드는 인풋(input)으로 들어온 그룹 데이터 타입을 'Guess from Group'으로 추측해서 자동으로 맞춰줄 수도 있지만 복잡한 노드를 설계하게 될 경우 데이터 타입을 명시하는 것이 권장됩니다.

왜냐하면 인풋 데이터는 다르지만 그룹 이름이 중복되는 경우에는 우리가 원하는 대로 분류되지 않을 수 있기 때문입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/015.gif) 

또한 위 처럼 포인트 데이터 타입의 포인트 인덱스를 가지고도 블라스트를 실행할 수도 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/016.gif) 

'${-}$' 기호를 사용해서 인덱스의 범위를 조절해서 블라스트를 실행할 수도 있습니다.

예를 들어 '${0-2}$', '${4-5}$' 등으로 묶어주면 '${3}$'과 '${6}$'만 남습니다.

## 그룹 데이터 타입

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/067.png) 

그룹으로 묶을 수 있는 데이터 타입은 다음의 네 가지로 분류됩니다.

- Primitives
- Points
- Edges
- Vertices

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/064.png) 

먼저 프리미티브(primitives) 타입의 그룹을 사용해보기 위해서 'platonic solids' 노드를 사용하여 다면체들을 씬에 배치했습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/065.png) 

다면체의 면의 갯수에 따라 달라진 프리미티브 그룹이 생성된 것을 확인 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/017.gif) 

컬러 노드도 그룹 이름에 따라서 적용할 그룹을 지정해 줄 수 있습니다.

컬러 노드의 output에 다시 새로운 컬러 노드를 연결하면 전체 색상이 변합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/018.gif) 

그룹을 지정해주면 해당 그룹만 컬러가 변화하는 것을 확인하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/019.gif) 

트랜스폼(Transform), 서브디비전(Subdivision) 등등 거의 모든 지오메트리(geometry) 노드는 그룹을 지정할 수 있습니다.

지금까지는 개별적으로 생성된 도형들을 그룹으로 묶어줬지만 이번에는 단일 오브젝트 내부에서 그룹을 지어보고자 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/068.png) 

예를 들어 박스를 생성했습니다. 박스는 points 8개, 프리미티브 6개로 구성되어 있습니다.

Vertices와 Polygons에 대한 설명은 지금 시점에서는 다루지 않겠습니다.
{: .notice--info}

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/020.gif) 

위 움짤처럼 그룹 노드를 생성한다음 데이터 타입을 프리미티브로 정하고 'Base Group' 탭에서 그룹으로 묶어줄 프리미티브의 범위를 설정할 수 있습니다.

단일 오브젝트인 박스 내부에서도 박스를 구성하는 요소들 끼리 그룹을 분류할 수 있는 것입니다.

### 그룹 셀렉트(Select) 모드

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/021.gif) 

'Base Group' 에서 입력하지 않고 씬 뷰 에서 마우스로 원하는 프리미티브를 직접 선택하는 **셀렉트(Select) 모드**를 사용할 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/069.png) 

'Base Group' 또는 씬 뷰의 마우스 아이콘을 누르면 **셀렉트(Select) 모드**를 사용 가능합니다.

혹은 씬 뷰 위에 마우스를 두고 **S** 키를 눌러도 셀렉트 모드가 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/022.gif) 

셀렉트 모드에서 여러 개의 프리미티브 를 선택하거나 취소하려면 **Shift** 키를 누르고 왼쪽 클릭으로 선택합니다. 물론 드래그로 선택하는 것도 가능합니다.

**ESC** 키를 누르면 셀렉트 모드를 취소할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/023.gif) 

셀렉트 모드에서 'Edges' 를 선택하는 방법도 동일합니다. 더블 클릭하면 연결된 엣지(Edges) 끼리 선택할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/024.gif) 

반대로 셀렉트 모드에서 먼저 선택을 하고 그룹 노드를 만드는 방법도 있습니다.

위 처럼 씬 뷰에서 그룹 노드를 만들어주면 선택한 부분들이 그룹으로 묶여서 생성됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/025.gif) 

셀렉트 모드에서 먼저 선택을 하고 블라스트 하는 것도 가능합니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)