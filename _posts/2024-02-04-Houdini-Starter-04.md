---
title: "후디니 입문 04 - 데이터 타입, 그룹, 블라스트"
excerpt: "노드로 생성한 데이터들을 Merge 노드를 사용해서 하나로 합쳐줄 때, 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다."
date: 2024-02-04 00:00:00 -0000
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

## 데이터 타입

노드로 생성한 데이터들을 Merge 노드를 사용해서 하나로 합쳐줄 때, 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/053.png){: .align-center}

예를 들어 Add 노드로 생성한 포인트 두 개가 있을 때, 위 이미지 처럼 한 쪽에만 color 노드를 연결하는 경우 경고 표시가 나옵니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/054.png){: .align-center}

한 쪽 포인트에는 color 데이터인 cd 값이 들어있는데, 다른 쪽 포인트에는 없어서 그렇습니다. \\
merge로 합쳤는데 두 포인트가 가진 데이터 타입이 일치하지 않기 떄문입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/055.png){: .align-center}

양쪽 모두 color 노드를 연결해서 cd 값이 있으면 경고 표시는 사라집니다.

## Group 노드

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/057.png){: .align-center}

Group 노드는 연결된 노드가 가진 데이터에 그룹 정보를 추가합니다. \\
Group name 에서 그룹의 이름을 지정할 수 있으며, Group Type에서 특정 타입의 데이터에만 그룹을 지정하는 것도 가능합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/011.gif){: .align-center}

Group 노드를 사용해서 연결하면 그룹으로 지정된 포인트들이 색상이 변하고 활성화 됩니다. \\
그룹은 한 번에 하나의 노드에만 연결할 수 있습니다. 그래서 Merge 노드로 합쳐준 이후에 사용하게 됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/059.png){: .align-center}

예를 들어 위와 같이 7개의 포인트를 씬에 배치하고 컬러도 다르게 설정 했습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/060.png){: .align-center} 

그런 다음 각 포인트들을 그룹 A와 그룹 B의 두 그룹으로 묶어줬습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/012.gif){: .align-center} 

위 처럼 merge 되는 순서를 변경하면 포인트 인덱스는 변하지만 그룹 정보는 그대로 입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/061.png){: .align-center} 

Info 창에서 보면 2개의 포인트 그룹이 있으며, 각각 이름은 A와 B라고 쓰여있는 것을 확인 할 수 있습니다.

## Blast 노드

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/013.gif){: .align-center} 

Blast 노드를 사용하면 원하는 그룹 이름을 지정해서 해당 그룹만 출력되게 하거나 반대로 출력되지 않게 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/014.gif){: .align-center} 

여러 그룹을 한 번에 제어할 수도 있습니다. 그룹 이름을 띄어쓰기로 구분합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/063.png){: .align-center} 

Blast 노드는 input으로 들어온 그룹 데이터 타입을 Guess from Group으로 추측해서 자동으로 맞춰줄 수도 있지만 \\
복잡한 노드를 설계하게 될 경우 데이터 타입을 명시하는 것이 권장됩니다. \\
왜냐하면 input 데이터는 다르지만 그룹 이름이 중복되는 경우에는 우리가 원하는 대로 분류되지 않을 수 있기 때문입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/015.gif){: .align-center} 

또한 위 처럼 포인트 데이터 타입의 포인트 인덱스를 가지고도 blast를 실행할 수도 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/016.gif){: .align-center} 

'${-}$' 기호를 사용해서 인덱스의 범위를 조절해서 blast를 실행할 수도 있습니다. \\
예를 들어 0-2, 4-5 등으로 묶어주면 3과 6만 남습니다.

