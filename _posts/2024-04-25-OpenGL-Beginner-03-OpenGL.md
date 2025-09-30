---
title: "OpenGL 입문 03 - OpenGL 소개"
excerpt: "OpenGL 라이브러리 전반에 대해서 소개합니다."
date: 2024-04-25 00:00:00 -0000
categories: Study
tag: OpenGL

header:
  teaser: /assets/images/Docs/Computer%20Graphics/Thumbnail-03.png
  overlay_image: /assets/images/Docs/Computer%20Graphics/Thumbnail-03.png
  overlay_filter: 0.8

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## OpenGL 라이브러리(OpenGL Library)
OpenGL 라이브러리 전반에 대해서 소개합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/017.png)

(simplified OpenGL software diagram)
{: .text-center}

OpenGL은 C, C++ 언어에서 라이브러리 형태로 제공되고 있습니다.

- 정적 라이브러리(Static Library) : 컴파일 시에 결합하는 방식
  - `.lib` 확장자이며 현재는 기본적인 정보만 저장됩니다.
- 동적 라이브러리(Dynamic Library) : 실행 시에 결합하는 방식
  - `.so`(Shader Object, Unix/Linux) 또는 `.dll` (Dynamic-link library, Windows)

OpenGL 라이브러리의 핵심은 OpenGL 코어 라이브러리(OpenGL Core Library)라고 부릅니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/013.png)

(GeForce Graphic Card Device Driver, Nvidia)
{: .text-center}

- `libGL.so` : Unix/Linux, Mac 을 지원합니다.
- `opengl32.dll` : Windows 를 지원합니다.

OpenGL의 기능은 그래픽 카드에 의존적(Dependent)이기 때문에 그래픽 카드 제조사들이 그래픽 카드 디바이스 드라이버(Device Driver)를 배포하여 코어 라이브러리를 최신 사양으로 업데이트 해줍니다.

## 윈도우 시스템(Windows System)

OpenGL은 2D 또는 3D 그래픽을 출력하기 위해 설계되었으나 이미지를 출력하기 위해서는 반드시 윈도우가 필요합니다. 그래서 윈도우 시스템에 대한 설명이 필요합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/015.png)

- MS Windows : MS Windows
- X Windows : Linux
- iOS Windows : Mac

윈도우 시스템은 2D 화면을 위해서 설계되어 있습니다. 화면에 2D 윈도우를 생성, 이동, 크기조절, 축소, 삭제 하는 역할을 담당합니다.

OpenGL이 윈도우 시스템에게 요청하면 윈도우 시스템에서 윈도우를 만들어줍니다. 그런 다음 윈도우 내부에서 2D 또는 3D 그래픽을 출력하는 방식으로 **역할이 분담**되어 있습니다.

문제는 지원해야할 윈도우 시스템의 종류가 OS마다 다르고 시장 점유율도 비슷하다는 점입니다. 

최대한 많은 호환성을 확보하기 위해서 멀티 플랫폼(Multi-Platform)으로 개발해야 합니다. 하지만 개발자가 각각의 OS에 대해서 소스코드를 새로 작성하기에는 너무 비효율적입니다. 따라서 플랫폼과 상관없이 단일 소스코드로 제작할 수 있어야 합니다.

### GLFW(OpenGL Frame Work)

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/014.png)

([GLFW, OpenGL Frame Work](https://www.glfw.org/))
{: .text-center}

이런 문제를 해결할 방법으로 모든 윈도우 시스템이 공통적으로 사용하는 기능만 모아서 제공하는 **가상 윈도우 시스템**인 **GLFW**가 개발되었습니다. 

GLFW는 스마트폰을 위한 OpenGL ES나 로우 레벨(Low-Level) 언어인 Vulkan도 지원하고 있습니다. Linux, MS Windows, Mac 등 대부분의 윈도우 시스템을 지원하는 것은 물론 Android OS 까지도 일부 지원합니다. 

앞으로 OpenGL을 사용하여 그래픽스 프로그래밍을 진행하는 포스트를 작성 할 경우 **GLFW** 를 사용합니다.
{: .notice--info}

다만 모든 윈도우 시스템과의 연결을 지원하기 위해서 정말 윈도우의 기본적인 기능들만 있기 때문에 고급 기능을 사용하려면 OS 마다 따로 구현해야 한다는 단점이 있습니다.

## OpenGL 익스텐션(Extension)
![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/GLviewExtensionViewer.png)

([GLview](https://opengl-extension-viewer.softonic.kr/), [OpenGL Extensions Viewer](https://play.google.com/store/apps/details?id=com.realtechvr.glview&pcampaignid=web_share))
{: .text-center}

- OpenGL Extension : [https://www.khronos.org/opengl/wiki/OpenGL_Extension](https://www.khronos.org/opengl/wiki/OpenGL_Extension)

[OpenGL 익스텐션(Extension)](https://opengl-extension-viewer.softonic.kr/)은 단일 회사가 아니라 **여러 회사에서 사용하는 표준**이라는 점에 착안하여 개발 되었습니다. 

어떤 그래픽 카드 제조사가 그래픽 카드를 제작하든 OpenGL을 지원할 경우에 반드시 제공해야 하는 핵심 기능을 모아둔 것이 OpenGL 코어 라이브러리 입니다.

OpenGL 익스텐션은 핵심 기능은 아니라서 *제공하지 않아도 문제 없지만 OpenGL 표준의 일부*인 기능들을 이야기 합니다. 현재 이런 익스텐션의 숫자는 400개 이상입니다.

익스텐션을 따로 제공하는 이유는 그래픽 카드의 최신 기술을 익스텐션의 형태로 시장에 먼저 제공하여 자사 그래픽 카드의 상품성과 경쟁력을 강화할 수 있기 때문입니다.

또한 익스텐션은 그래픽 카드 제조사들이 발전 방향성이 다른 경우에 발생하는 OpenGL 표준에 대한 문제를 해결할 수 있습니다.

예를 들어 타사에서 개발한 최신 기능을 자사에서는 지원하지 않는 경우 OpenGL 코어 라이브러리가 될 수 없기에 이런 기능을 익스텐션으로 먼저 출시 합니다.

추후 익스텐션 중에서 뛰어난 성능 또는 상업적 성공을 거두어 그래픽 카드 시장에서 범용적으로 사용하는 익스텐션이 되는 경우 OpenGL 코어 라이브러리에 포함 시킬 수 있습니다.

이런 익스텐션 구조의 특수성 덕분에 그래픽 카드 제조사들 사이에서 공정한 **경쟁**이 일어납니다. 어느 제조사든 표준을 유지하기 때문에 개발자들이 코어 라이브러리만으로 개발한다면 높은 이식성(portability)과 호환성을 보장 할 수 있습니다.

시장에서 성능이 훌륭한 것으로 평가받는 익스텐션이 있고 특정 제조사에서 이를 지원하는 그래픽 카드를 제작한다면 개발자들이 더 높은 효율로 동작하는 소프트웨어를 개발할 것이기 때문에 자사 그래픽 카드 제품의 장점이 됩니다.

### GLEW(OpenGL Extension Wrangler Library)

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/016.png)

(SourceForge, [GLEW](https://glew.sourceforge.net/))
{: .text-center}

문제는 OpenGL 익스텐션은 시장에서 새로운 그래픽 카드가 출시될 때 마다 신규 익스텐션이 등록될 수 있으며 익스텐션은 지금 현재도 지속적으로 업데이트 되고 있습니다. 

신규 익스텐션이 등록 될 때 마다 개발자가 일일히 어떤 익스텐션을 사용해야 하는지 판단해야 하고 어떻게 사용할 지 고민해야 합니다.

그래서 OpenGL 익스텐션 사용을 도와주는 전문 라이브러리인 **GLEW** 가 개발됩니다. 

```c
#include<glew.h>
glewInit();
```

모든 버전의 OpenGL 사용을 지원하며 어떤 익스텐션이 사용 가능한지 검사 해주고 익스텐션으로 등록된 모든 함수에 대한 인터페이스를 제공합니다. 지원하지 않는 함수는 자동으로 에러 처리해줍니다.

## OpenGL 라이브러리의 특징

OpenGL은 3D 그래픽스를 목적으로 설계된 라이브러리이기 때문에 모든 함수가 3D 출력을 목표로 동작합니다.
- 프리미티브(Primitives) 출력
  - 점(Point), 선분(Segment), 삼각형(Triangles)
- 속성(Attribute) 설정
  - 색상(Color), 텍스쳐 좌표(Texture Coordinate) 등등
- 질의(Query)
  - 현재 상태에 대한 질의
- 변환(Transformation)
  - 모델(Model), 뷰(View), 프로젝션(Projection) 행렬 변환 

OpenGL의 가장 핵심은 프리미티브(Primitives) 출력 기능입니다. 프리미티브란 화면에 출력할 도형을 말하며 이러한 프리미티브의 속성을 정의 해줄 수 있습니다. 예를 들어 삼각형의 색상을 정의하여 같은 도형이라도 빨간색 또는 파란색 등 서로 다른 색상으로 출력 할 수 있습니다.

그 외에는 화면 상에 무엇이 출력되고 있는지 물어보는 질의 기능도 가지고 있으며, 피사체가 될 오브젝트(Object)를 촬영할 카메라의 속성과 위치 그리고 거리 등을 설정하는 행렬 변환 기능이 있습니다.

### 프리미티브 (Primitives) 출력

프리미티브 중에서 가장 중요한 것은 삼각형입니다. **모든 오브젝트를 작은 삼각형들의 집합**으로 이루어져있다고 생각하는 아이디어입니다. 

예를 들어 거대한 산을 표현한 배경을 작은 삼각형들로 분할해서 **근사(Approximation)** 처리하면 자연스럽게 렌더링 할 수 있습니다.

또한 가까운 오브젝트는 삼각형을 밀도 높게 분할해서 많이 사용하고 반대로 멀리 있는 오브젝트는 적게 사용할 수 있습니다. 이를 **정제(Refinement)**라고 합니다.

### OpenGL 스테이트(State) 관리

OpenGL은 스테이트 머신(State Machine) 개념으로 구현되어 있습니다. 예를 들어 삼각형의 색상이나 텍스쳐 등 속성(Attribute)을 OpenGL 내부 구현에서는 **스테이트(State)**라고 부릅니다. 

OpenGL 으로 오브젝트를 렌더링 하는 과정은 먼저 스테이트를 설정한 다음 프리미티브를 출력하는 순서입니다. 그래서 같은 프리미티브를 가지고 다른 색상으로 출력해줄 수 있습니다.

### 객체 지향(Object Orientation) 개념의 부재
객체 지향 개념이 탄생하기 전에 C로 OpenGL이 개발되었기 때문에 C++의 객체 지향 개념을 전혀 사용하지 않습니다. 이런 문제를 개선하고자 C++ 인터페이스를 도입하려 했지만 효율성 문제로 기각되었습니다.

```c
void glUniform3i(GLint location, GLint v0, GLint v1, GLint v2);
void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
void glUniform3iv(GLint location, GLsizei count, const GLint * value);
```

대표적으로 함수 오버로딩(Function Overloading)을 사용하지 못해서 위 함수들 처럼 사용하려는 자료형에 따라 함수 이름이 달라져야 합니다.

### 코딩 컨벤션(Coding convention)

이러한 문제 때문에 OpenGL은 함수 작명에 대한 코딩 컨벤션(Coding convention)이 있습니다.

- 모든 OpenGL / GLFW / GLEW 함수는 접두어 `gl` / `glfw` / `glew` 으로 시작하며 출신 성분을 확실히 표기합니다.
- 접미어 `2` / `3` / `4` 는 함수가 다루는 좌표의 차원(Dimension)을 의미 합니다.
- 접미어 `i`(int) / `ui`(unsigned int) / `f`(float) / `d`(double, 64-bit float) 는 데이터 타입(Data Type)을 의미 합니다.
- 접미어 `v`는 벡터(Vector) 또는 배열(Array)를 의미합니다.

```c
void glUniform3fv(GLint location, GLsizei count, const GLfloat * value);
```

예를 들어 `glUniform3fv()`는 **OpenGL**의 함수이며, **3차원**의 **배열**을 다루는 함수라는 것을 알 수 있습니다.

#### OpenGL 접미어(Suffixes) 

- 접미어 / 데이터 타입 / OpenGL / C 언어
  - `b` / 8-bit int / GLbyte / signed char
  - `s` / 16-bit int / GLshort / short
  - `i` / 32-bit int / GLint, GLsizei / int, long
  - `f` / 32-bit float / GLfloat *(GLclampf)* / float
  - `d` / 64-bit float / GLdouble *(GLclampd)* / double
  - `ub` / 8-bit unsigned int / GLubyte, GLboolean / unsigned char
  - `us` / 16-bit unsigned int / GLushort / unsigned short
  - `ui` / 32-bit unsigned int / GLuint, GLenum, GLbitfield / unsigned int, unsigned long

#### OpenGL 데이터 타입(Datatype)과 상수(Constant)

```c
#include<GL/glew.h>
#include<GLFW/glfw3.h>
```

전형적인 OpenGL 프로그램을 작성할 때 `glew.h`에서 OpenGL 익스텐션의 자료형과 상수 등을 가져와서 사용할 것이며 `glfw3.h`에서 가상 윈도우 시스템을 가져와서 사용하게 됩니다.

## 레퍼런스(Reference)
- GLFW : [https://www.glfw.org/](https://www.glfw.org/)
- GLEW : [https://glew.sourceforge.net/](https://glew.sourceforge.net/)
- OpenGL Extension : [https://www.khronos.org/opengl/wiki/OpenGL_Extension](https://www.khronos.org/opengl/wiki/OpenGL_Extension)