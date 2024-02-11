---
title: "후디니 입문 03 - 점, 선, 면 그리고 바운드"
excerpt: 3D 아티스트의 기준에서 이해하는 점, 선, 면에 대한 개념은 프로그래머 또는 수학자들의 개념과는 다른 부분이 있습니다. 컴퓨터 그래픽스에서 다루는 데이터나 유클리드 기하학의 엄밀한 정의보다는 폴리곤 덩어리들이 3차원 공간에서 이루는 형태와 기능에 집중하는 사람들이기 때문입니다. 
date: 2024-02-03 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-03.png
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## Add 노드 사용하기

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/035.png){: .align-center}

후디니에서 점, 선, 면 모두 Add 라는 노드를 사용해서 구현 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/033.png){: .align-center}

Add 노드를 처음 생성하면 Scene view에는 아무 것도 출력되지 않습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/037.png){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/005.gif){: .align-center}

Points 탭의 Number of Points에서 '+' 버튼을 눌러서 추가해주면 공간 상의 좌표만 있고 물리적 실체는 없는 '포인트'가 생성됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/036.png){: .align-center}

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/034.png){: .align-left} 버튼을 누르면 Scene view에서 포인트 인덱스를 확인할 수 있습니다.





