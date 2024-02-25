---
title: "후디니 입문 09 - Vex 언어 - 시계 애니메이션 만들기"
excerpt: "Vex 와 Vop 을 복습하는 차원에서 후디니에서 시계 시스템을 구현해보고자 합니다."
date: 2024-02-09 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-09.png
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/120.png){: .align-center}

## 시계 애니메이션 만들기

이전 포스트[(링크)](https://walll4542developer.github.io/houdini/Houdini-Starter-08/) 에서 배웠던 Vex 와 Vop 을 복습하는 차원에서 후디니에서 간단한 시계 애니메이션을 구현해보고자 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/058.gif){: .align-center}

먼저 **서클(Circle) 노드**를 준비합니다. 첫번째 서클은 파라미터(Parameter)에서 디비전스(Divisions)  값을 ${12}$로 설정합니다. 왜냐하면 시계에서 표현하는 시간 단위가 ${12}$시간이기 때문입니다.

두번째 서클은 디비전스 값을 ${60}$으로 설정합니다. 분 단위를 표현하기 위해서 입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/059.gif){: .align-center}

파라미터에서 'Delete Geometry But Keep the Points' 를 체크해주면 포인트(Point)들만 남습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/060.gif){: .align-center}

유니폼 스케일(Uniform Scale) 값을 조절하여 시간 단위를 표현할 포인트들의 위치를 분 단위와 겹치지 않도록 배치해줍니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/061.gif){: .align-center}

'Copy to points' 노드를 사용하여 시간 단위를 표현하는 포인트들의 위치에 구(Sphere)를 복제하여 배치해줍니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/121.png){: .align-center}

같은 방식으로 분 단위도 노드를 정리해줍니다. 




## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
