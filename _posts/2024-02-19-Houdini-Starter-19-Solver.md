---
title: "후디니 입문 19 - Solver"
excerpt: "Solver 노드는 이전 프레임의 결과에 만들어준 규칙을 시간에 따라 이터레이션 횟수만큼 반복하는 기능입니다. 후디니에서 많은 연산이 필요한 물리 시뮬레이션(Simulation)을 시행 할 때 주로 사용됩니다."
date: 2024-02-19 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-19.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/166.png){: .align-center}

`Solver` 노드는 이전 프레임의 결과에 만들어준 규칙을 시간에 따라 이터레이션 횟수만큼 반복하는 기능입니다. 후디니에서 많은 연산이 필요한 물리 시뮬레이션(Simulation)을 시행 할 때 주로 사용됩니다.

몇 가지 조건을 갖춘다면 `Solver` 노드는 `forloop`와 동일하게 사용 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/167.png){: .align-center}

`Solver` 노드를 더블 클릭하면 노드 내부로 들어갈 수 있습니다. 

여기에 `forloop` 의 내용을 복사후 붙혀넣기해서 `Prev_Frame` 과 `OUT` 사이에 연결합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/127.gif){: .align-center}

파라미터(Parameter)의 **'Reset Simulation'** 버튼을 눌러서 시뮬레이션에 사용된 캐시(Cache)를 모두 초기화 한 후 애니메이션을 플레이해서 결과를 보면 `forloop`와 동일한 결과임을 알 수 있습니다.

### 솔버(Solver) 노드



## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
