---
title: "후디니 입문 04 - 데이터 타입, 그룹, 블라스트"
excerpt: "노드로 생성한 데이터들을 Merge 노드를 사용해서 하나로 합쳐줄 때, 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다."
date: 2024-02-04 00:00:00 -0000
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
그룹의 이름을 지정할 수 있으며 특정 타입의 데이터에만 그룹을 지정하는 것도 가능합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/011.gif){: .align-center}

Group 노드를 사용해서 연결하면 그룹으로 지정된 포인트들이 색상이 변하고 활성화 됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/056.png){: .align-center}

