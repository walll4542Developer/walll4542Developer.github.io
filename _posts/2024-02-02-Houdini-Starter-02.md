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

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/012.png){: .align-left}

- 오브젝트는 모두 /obj 하위에 있어야 합니다. 
- 렌더러는 /out 하위에 있어야 합니다.
- 메테리얼은 /mat 하위에 있어야 합니다.

오브젝트에는 카메라와 라이트도 포함됩니다.
{: .notice--info}
{: .text-justify}

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/014.png){: .align-left}

