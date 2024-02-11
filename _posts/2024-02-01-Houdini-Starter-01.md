---
title: "후디니 입문 01 - 인터페이스"
excerpt: 후디니는 작업 환경을 커스텀 할 수 있습니다. 인터페이스 / 작업 환경을 설정하고 저장과 불러오기 하는 방법을 배웁니다.
date: 2024-02-01 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-01.png
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo.png){: .align-center}

## 작업 환경 커스터마이징
후디니는 작업 환경을 커스텀 할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/000.png){: .align-center}

후디니를 처음 실행한 화면입니다. 최초 작업 환경은 위와 같이 Scene View, Parameter View, Network View 로 구성되어 있습니다.\\
작업 환경을 본인에게 알맞게 커스텀 하기 위해서 모든 탭을 제거하고 처음부터 추가해보겠습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/003.gif){: .align-center}

모든 탭을 제거하면 가장 마지막 탭은 지워지지 않고 남습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/008.png){: .align-center}

탭 오른쪽 위에 위치한 역삼각형 버튼을 누르면 Split Pane Left/Right 또는 Top/Bottom 버튼이 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/002.gif){: .align-center}

이 버튼을 클릭하면 창이 좌우 또는 상하로 분리됩니다. 이를 이용하여 원하는 대로 탭을 분할하고 배치할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/001.gif){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/007.png){: .align-center}

Parameter View는 Network View에 마우스를 올려두고 P 키를 누르면 Network View 내부에서 끄고 켤 수 있습니다.
또한 마우스로 드래그하여 축소 또는 확장이 가능합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/027.png){: .align-center}
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/028.png){: .align-center}
 
Network View에 마우스를 올려두고 C 키를 누르면 노드 색상을 변경할 수 있는 팔레트가 오른쪽 아래에 열립니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/009.png){: .align-center}

Scene View에 마우스를 올려두고 D 키를 누르면 Scene View의 Display Options를 설정할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/010.png){: .align-center}

BackGround 탭에서 Scene View의 색상을 설정해 줄 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/011.png){: .align-center}

최종적으로 저는 위와 같이 인터페이스를 구성했습니다.

### 인터페이스 링크

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/004.gif){: .align-center}

구성한 인터페이스에서 Scene View 와 Network View 그리고 Geometry SpreadSheet 는 연동이 되어 있지 않습니다.\\
우리가 설정한 인터페이스들이 같은 정보를 연동하려면 위와 같이 링크를 설정해야 합니다.\\
저는 모든 탭의 링크를 1번으로 지정했습니다.

### 작업 환경 프리셋 저장 / 로드하기
후디니는 커스텀한 작업 환경 프리셋을 만들어 저장하고 로드하는 기능을 제공합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/002.png){: .align-center}

예를 들어 위 이미지 처럼 작업 환경을 설정하고 저장하고자 한다면

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/006.png){: .align-center}

후디니 창에서 왼쪽 위 Build 버튼을 눌러줍시다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/001.png){: .align-center}

위 이미지와 같은 메뉴가 나오는데요, Save Current Desktop As... 버튼을 누르면 지금 화면에 설정 되어있는 작업 환경을 프리셋으로 저장할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/003.png){: .align-center}

저장할 프리셋의 이름을 지정해 줄 수 있습니다. 저는 MyShelf 라는 이름을 써서 저장했습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/004.png){: .align-center}

Save 버튼을 눌러주면 지정된 경로에 성공적으로 저장되었다는 알림창이 나옵니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/005.png){: .align-center}

OK 버튼을 눌러주면 인터페이스가 성공적으로 저장되었음을 알 수 있습니다.


