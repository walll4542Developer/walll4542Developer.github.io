---
title: "OpenGL 입문 03 - OpenGL 소개(Introducing the OpenGL)"
excerpt: "OpenGL 라이브러리 전반에 대해서 소개합니다."
date: 2024-04-25 00:00:00 -0000
categories: OpenGL Graphics
tag: Research

header:
  teaser: /assets/images/Docs/Computer%20Graphics/Thumbnail-01.png
  overlay_image: /assets/images/Docs/Computer%20Graphics/Thumbnail-01.png
  overlay_filter: 0.8

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## OpenGL 라이브러리(OpenGL Library)
OpenGL 라이브러리 전반에 대해서 소개합니다.

OpenGL은 C, C++ 언어에서 라이브러리 형태로 제공되고 있습니다.

- 정적 라이브러리(Static Library) : 컴파일 시에 결합하는 방식
  - `.lib` 확장자이며 현재는 기본적인 정보만 저장됩니다.
- 동적 라이브러리(Dynamic Library) : 실행 시에 결합하는 방식
  - `.so`(Shader Object, Unix/Linux) 또는 `.dll` (Dynamic-link library, Windows)

OpenGL 라이브러리의 핵심은 OpenGL 코어 라이브러리(OpenGL Core Library)라고 부릅니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/013.png){: .align-center}

(GeForce Graphic Card Device Driver, Nvidia)
{: .text-center}

- `libGL.so` : Unix/Linux, Mac 을 지원합니다.
- `opengl32.dll` : Windows 를 지원합니다.

OpenGL의 기능은 그래픽 카드에 의존적(Dependent)이기 때문에 그래픽 카드 제조사들이 그래픽 카드 디바이스 드라이버(Device Driver)를 배포하여 코어 라이브러리를 최신 사양으로 업데이트 해줍니다.

## 윈도우 시스템(Windows System)

OpenGL은 2D 또는 3D 그래픽을 출력하기 위해 설계되었으나 이미지를 출력하기 위해서는 반드시 윈도우가 필요합니다. 그래서 윈도우 시스템에 대한 설명이 필요합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/015.png){: .align-center}

- MS Windows : MS Windows
- X Windows : Linux
- iOS Windows : Mac

윈도우 시스템은 2D 화면을 위해서 설계되어 있습니다. 화면에 2D 윈도우를 생성, 이동, 크기조절, 축소, 삭제 하는 역할을 담당합니다.

OpenGL이 윈도우 시스템에게 요청하면 윈도우 시스템에서 윈도우를 만들어줍니다. 그런 다음 윈도우 내부에서 2D 또는 3D 그래픽을 출력하는 방식으로 **역할이 분담**되어 있습니다.

문제는 지원해야할 윈도우 시스템의 종류가 OS마다 다르고 시장 점유율도 비슷하다는 점입니다. 

최대한 많은 호환성을 확보하기 위해서 멀티 플랫폼(Multi-Platform)으로 개발해야 합니다. 하지만 개발자가 각각의 OS에 대해서 소스코드를 새로 작성하기에는 너무 비효율적입니다. 따라서 플랫폼과 상관없이 단일 소스코드로 제작할 수 있어야 합니다.

### GLFW(OpenGL Frame Work)

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/014.png){: .align-center}

([GLFW, OpenGL Frame Work](https://www.glfw.org/))
{: .text-center}

이런 문제를 해결할 방법으로 모든 윈도우 시스템이 공통적으로 사용하는 기능만 모아서 제공하는 **가상 윈도우 시스템**인 **GLFW**가 개발되었습니다. 

GLFW는 스마트폰을 위한 OpenGL ES나 로우 레벨(Low-Level) 언어인 Vulkan도 지원하고 있습니다. Linux, MS Windows, Mac 등 대부분의 윈도우 시스템을 지원하는 것은 물론 Android OS 까지도 일부 지원합니다. 

앞으로 OpenGL을 사용하여 그래픽스 프로그래밍을 진행하는 포스트를 작성 할 경우 **GLFW** 를 사용합니다.
{: .notice--info}

다만 모든 윈도우 시스템과의 연결을 지원하기 위해서 정말 윈도우의 기본적인 기능들만 있기 때문에 고급 기능을 사용하려면 OS 마다 따로 구현해야 한다는 단점이 있습니다.

## OpenGL 익스텐션(Extension)
![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/GLviewExtensionViewer.png){: .align-center}

([GLview](https://opengl-extension-viewer.softonic.kr/), [OpenGL Extensions Viewer](https://play.google.com/store/apps/details?id=com.realtechvr.glview&pcampaignid=web_share))
{: .text-center}

[OpenGL 익스텐션(Extension)](https://opengl-extension-viewer.softonic.kr/)은 단일 회사가 아니라 **여러 회사에서 사용하는 표준**이라는 점에 착안하여 개발 되었습니다. 

어떤 그래픽 카드 제조사가 그래픽 카드를 제작하든 OpenGL을 지원할 경우에 반드시 제공해야 하는 핵심 기능을 모아둔 것이 OpenGL 코어 라이브러리 입니다.

OpenGL 익스텐션은 핵심 기능은 아니라서 *제공하지 않아도 문제 없지만 OpenGL 표준의 일부*인 기능들을 이야기 합니다. 현재 이런 익스텐션의 숫자는 400개 이상입니다.

익스텐션을 따로 제공하는 이유는 그래픽 카드의 최신 기술을 익스텐션의 형태로 시장에 먼저 제공하여 자사 그래픽 카드의 상품성과 경쟁력을 강화할 수 있기 때문입니다.

또한 익스텐션은 그래픽 카드 제조사들이 발전 방향성이 다른 경우에 발생하는 OpenGL 표준에 대한 문제를 해결할 수 있습니다.

예를 들어 타사에서 개발한 최신 기능을 자사에서는 지원하지 않는 경우 OpenGL 코어 라이브러리가 될 수 없기에 이런 기능을 익스텐션으로 먼저 출시 합니다.

추후 익스텐션 중에서 뛰어난 성능 또는 상업적 성공을 거두어 그래픽 카드 시장에서 범용적으로 사용하는 익스텐션이 되는 경우 OpenGL 코어 라이브러리에 포함 시킬 수 있습니다.

이런 익스텐션 구조의 특수성 덕분에 그래픽 카드 제조사들 사이에서 공정한 경쟁이 일어납니다. 어느 제조사든 표준을 유지하기 때문에 개발자들이 코어 라이브러리만으로 개발한다면 높은 이식성(portability)과 호환성을 보장 할 수 있습니다.

시장에서 성능이 훌륭한 것으로 평가받는 익스텐션이 있고 특정 제조사에서 이를 지원하는 그래픽 카드를 제작한다면 개발자들이 더 높은 효율로 동작하는 소프트웨어를 개발할 것이기 때문에 자사 그래픽 카드 제품의 장점이 됩니다.

## OpenGL 라이브러리의 특정



## 레퍼런스(Reference)
- GLFW : [https://www.glfw.org/](https://www.glfw.org/)
- OpenGL Extension : [https://www.khronos.org/opengl/wiki/OpenGL_Extension](https://www.khronos.org/opengl/wiki/OpenGL_Extension)