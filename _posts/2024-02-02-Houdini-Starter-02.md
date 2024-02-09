---
title: "후디니 입문 02 - 주소 개념과 카메라, 라이트, 렌더러"
excerpt: 인터페이스 / 작업 환경을 설정합니다.
date: 2024-02-02 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo.png
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---
![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/013.png){: .align-center}

## 주소 개념
후디니의 Network View에서 사용하는 모든 노드에는 고유한 주소가 존재합니다.
후디니는 모든 네트워크 간의 연결을 주소 입력을 바탕으로 하며, 주소 개념이 후디니 설계 철학입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/012.png){: .align-center}

- 오브젝트는 모두 /obj 하위에 있어야 합니다. 
- 렌더러는 /out 하위에 있어야 합니다.
- 메테리얼은 /mat 하위에 있어야 합니다.

오브젝트에는 카메라와 라이트도 포함됩니다.
{: .notice--info}

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/014.png){: .align-center}

예를 들어 렌더링을 하기 위해서는 렌더러와 카메라가 필요하기 때문에 /out 하위에서 mantra 렌더러 노드를 생성 했습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/016.png){: .align-center}

같은 방식으로 /obj 하위에서 카메라 노드를 생성하였습니다. 이름은 'cam1'입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/015.png){: .align-center}

mantra 렌더러에 카메라의 주소를 입력하는 부분이 있습니다. 이전에 /obj 하위에 만든 카메라를 사용하려면 '/obj/cam1' 라는 주소를 입력해야 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/017.png){: .align-center}

또한 mantra 렌더러에서 Objects 탭을 선택하면 렌더링 하거나 하지 않을 오브젝트의 주소를 입력해서 직접 필터링 할 수도 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/018.png){: .align-center}

입력창에 '*' 기호가 있는 것을 보실 수 있는데요. 이는 존재하는 모든 오브젝트를 사용하겠다는 뜻입니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/019.png){: .align-center}

/obj 하위에서 각각 세 개의 박스와 라이트를 생성하고 위와 같이 이름을 지어줬습니다.

- light는 l_a, l_b, l_c
- box는 box_a, box_b, box_c

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/020.png){: .align-center}
'*' 기호를 모두 지우고 Force Objects 탭과 Force Lights 탭에 이전에 생성한 오브젝트와 라이트 노드의 이름을 입력했습니다. 

Force~ 는 강제로 렌더링 할 오브젝트를 지정하는 기능입니다.


