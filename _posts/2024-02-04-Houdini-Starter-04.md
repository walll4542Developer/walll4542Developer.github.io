---
title: "후디니 입문 04 - 데이터 타입, 그룹, 블라스트"
excerpt: "3D 아티스트의 기준에서 이해하는 점, 선, 면에 대한 개념은 프로그래머 또는 수학자들의 개념과는 다른 부분이 있습니다. 컴퓨터 그래픽스에서 다루는 데이터나 유클리드 기하학의 엄밀한 정의보다는 폴리곤 덩어리들이 3차원 공간에서 이루는 형태와 기능에 집중하는 사람들이기 때문입니다."
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

Add 노드로 생성한 포인트들을 Merge 노드를 사용해서 하나로 합쳐줄 때, Add 노드가 가지고 있는 데이터 타입이 모두 동일해야 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/053.png){: .align-center}

예를 들어 포인트 두 개가 있을 때, 위 이미지 처럼 한 쪽에만 color 노드를 연결하는 경우 경고 표시가 나옵니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/054.png){: .align-center}

한 쪽 포인트에는 color 데이터인 cd 값이 들어있는데, 다른 쪽 포인트에는 없어서 그렇습니다. \\
merge로 합쳤는데 두 포인트가 가진 데이터 타입이 일치하지 않기 떄문입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/055.png){: .align-center}

양쪽 모두 color 노드를 연결해서 cd 값이 있으면 경고 표시는 사라집니다.

## Group 노드

Group 노드는 

