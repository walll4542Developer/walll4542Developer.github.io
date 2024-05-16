---
title: "OpenGL 입문 04 - OpenGL 설치 및 실행"
excerpt: "OpenGL과  GLFW, GLEW를 설치 및 실행 후 간단한 프로그램을 작성합니다."
date: 2024-04-25 00:00:00 -0000
categories: OpenGL Graphics
tag: Research

header:
  teaser: /assets/images/Docs/Computer%20Graphics/Thumbnail-04.png
  overlay_image: /assets/images/Docs/Computer%20Graphics/Thumbnail-04.png
  overlay_filter: 0.8

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요
OpenGL과 GLFW, GLEW를 설치 및 실행 후 간단한 프로그램을 작성합니다.

## 설치 단계

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/019.png){: .align-center}

([Geforce Experience](https://www.nvidia.co.kr/Download/index.aspx?lang=kr), Nvidia)
{: .text-center}

먼저 OpenGL을 설치하기 위하여 그래픽 카드 드라이버를 최신으로 업데이트 합니다. OpenGL 4.x 이상 버전을 지원하는지 확인하세요.

만약 Nvidia 그래픽 카드를 사용하신다면 [Nvidia 다운로드 센터](https://www.nvidia.co.kr/Download/index.aspx?lang=kr)나 [Nvidia Geforce Experience](https://www.nvidia.com/en-us/geforce/geforce-experience/) 를 이용하여 그래픽 카드를 최신으로 업데이트 해주세요.

### GLFW 설치 하기

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/018.png){: .align-center}

([Windows Pre-compiled binary](https://www.glfw.org/download), GLFW)
{: .text-center}

GLFW를 본인 컴퓨터의 운영체제(32 bit / 64 bit) 에 알맞게 다운로드 받습니다. 저는 64 bit을 다운로드 받고 진행 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/020.png){: .align-center}

`glfw-3.4.bin.WIN64.zip` 파일이 자동으로 다운로드 됩니다. 

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/021.png){: .align-center}

다운로드 받은 `.zip` 파일을 압축 해제 하고 본인이 사용하는 Visual Studio 컴파일러(Compiler) 버전에 맞는 폴더가 있는지 확인합니다.

예를 들어 Visual Studio 2022 버전을 사용한다면 `lib-vc2022` 폴더가 있는지 확인하세요.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/022.png){: .align-center}

(C:\Program Files\Microsoft Visual Studio\20xx\Professional(커뮤니티 버전이면 Community)\VC\Tools\MSVC\xx.yy.zzzzz)
{: .text-center}

본인이 사용하는 Visual Studio 의 컴파일러 버전 `xx.yy.zzzzz`의 폴더를 찾아서 들어갑니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/023.png){: .align-center}

내부를 살펴보면 위와 같이 컴파일러 폴더 하위에 `include` `lib` `bin` 폴더가 분리되어 있습니다. 

이 폴더 위치에 맞춰서 GLFW의 파일을 대응되는 위치에 직접 옮겨줘야 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/024.png){: .align-center}

`include` `lib` `bin` 순서대로 설치 하겠습니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/001.gif){: .align-center}

먼저 `xx.yy.zzzzz/include`에 GLFW 파일이 들어있는 폴더 `glfw-3.4.bin.WIN64/include/GLFW`를 복사 후 붙혀넣기 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/002.gif){: .align-center}

다음은 `xx.yy.zzzzz\lib\x64` 에 `glfw-3.4.bin.WIN64\lib-vc2022` 하위의 `glfw3.lib` `glfw3_mt.lib` `glfw3dll.lib` 파일을 복사 후 붙혀넣기 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/003.gif){: .align-center}

마지막으로 `xx.yy.zzzzz\bin\Hostx64\x64` 에 `glfw3.dll` 파일을 복사 후 붙혀넣기 합니다.

### IDE 설정하기

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/025.png){: .align-center}

**C++ 과 Windows 콘솔**을 사용하는 템플릿으로 시작하는 것이 가장 무난합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/026.png){: .align-center}

미리 컴파일 된 헤더(Pre-compiled headers) 옵션을 **사용 안 함**으로 설정하는 것을 권장합니다. `pch.cpp`, `pch.h` 로 등록되어 있다면 이를 삭제 하는 것이 좋습니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/027.png){: .align-center}

본인 컴퓨터의 운영체제에 맞춰서 **x64**, 컴파일 모드를 반드시 **release** 모드로 설정해야 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/028.png){: .align-center}

```c
#pragma comment(lib, "glfw3.lib")
```

`glfw3.lib`를 추가 종속성(Additional dependencies)에 추가하거나 `#pragma` 전처리기를 이용하여 추가해줍니다.




### GLFW 간단한 프로그램 작성

`hello-glfw.c` 

```c
#include<GLFW/glfw3.h>
#pragma comment(lib,"glfw3.lib")

const unsigned int WIN_W = 300;
const unsigned int WIN_H = 300;

int main(void)
{
  // start GLFW
  glfwInit();
  GLFWwindow * window = glfwCreateWindow(WIN_W, WIN_H, "Hello GLFW", NULL, NULL);
  glfwMakeContextCurrent(window);

  // main loop
  while (!glfwWindowShouldClose(window))
  {
    glfwPollEvents();
  }

  // done
  glfwTerminate();
  return 0;
}
```




### GLEW 설치

## Linux에서 OpenGL 컴파일

## 레퍼런스(Reference)
- Nvidia 다운로드 센터 : [https://www.nvidia.co.kr/Download/index.aspx?lang=kr](https://www.nvidia.co.kr/Download/index.aspx?lang=kr)
- Nvidia Geforce Experience : [https://www.nvidia.com/en-us/geforce/geforce-experience/](https://www.nvidia.com/en-us/geforce/geforce-experience/)
- GLFW : [https://www.glfw.org/](https://www.glfw.org/)
- GLEW : [https://glew.sourceforge.net/](https://glew.sourceforge.net/)
- OpenGL Extension : [https://www.khronos.org/opengl/wiki/OpenGL_Extension](https://www.khronos.org/opengl/wiki/OpenGL_Extension)