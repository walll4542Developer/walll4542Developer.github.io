---
title: "OpenGL 입문 02 - 그래픽스 역사(History of Graphics)"
excerpt: "그래픽스 시스템의 역사를 하드웨어(Hardware)와 소프트웨어(Software) 관점에서 알아봅니다."
date: 2024-04-24 00:00:00 -0000
categories: Study
tag: OpenGL

header:
  teaser: /assets/images/Docs/Computer%20Graphics/Thumbnail-02.png
  overlay_image: /assets/images/Docs/Computer%20Graphics/Thumbnail-02.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 그래픽스 시스템

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/Thumbnail-02.png)

그래픽스 시스템의 역사를 하드웨어(Hardware)와 소프트웨어(Software) 관점에서 알아봅니다.

## 초기 그래픽스 하드웨어
### 최초의 그래픽스 프로그램
![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/002.png)

(OXO, Alexander S. Douglas)
{: .text-center}

최초의 그래픽스 프로그램은 1952년 영국 캠브릿지(Cambridge) 대학의 알렉산더 더글라스(Alexander S. Douglas)가 박사 학위 논문(Ph.D. Thesis)을 작성하는 과정에서 개발 된 틱택토(Tic-Tac-Toe) 게임 **OXO**입니다. 

사실 OXO가 컴퓨터 그래픽스 프로그램이라기 보다는 사용자 인터페이스, HCI(Human Computer Interface) 분야의 시초를 알리는 논문에 가깝습니다.

컴퓨터 그래픽스가 본격적으로 발전하기 시작한 것은 1960년대 흑백 TV가 등장하여 이를 컴퓨터용 모니터로 사용하기 시작했을 때 부터입니다. 

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/005.png)

(Wireframe Render Image)
{: .text-center}

초기 컴퓨터 그래픽스 하드웨어들은 모니터의 한계 때문에 선분만 출력 가능했기 때문에 현재까지도 이어져온 것이 바로 와이어프레임(Wireframe) 방식 렌더링입니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/004.png)

(Sketchpad, Ivan Sutherland)
{: .text-center}

1960년대 당시 가장 획기적인 발전중 하나는 우리가 현재 사용하는 펜 타블렛(Pen Tablet)으로 펜을 사용하여 화면에 직접 그리는 방식입니다.

{% include embed/youtube.html id='6orsmFndx_o' %}

1963년 MIT(Massachusetts Institute of Technology)의 이반 서덜랜드(Ivan Sutherland)가 박사 과정에서 처음으로 제안한 것입니다. 다만 이때까지도 사용자 인터페이스 관점에서의 발전에 가까웠습니다.

### 래스터 시스템(Raster System)의 출현

1970년대로 넘어가면서 컴퓨터 메모리 기술이 발전하기 시작하여 비교적 큰 용량의 데이터를 실시간으로 전송하는 것이 가능해졌고 그로 인해 메모리 기술이 TV와 결합되면서 프레임 버퍼(Framebuffer)가 탄생합니다. 

프레임 버퍼란 전체 화면이 **2차원 배열(Array)으로 구성**되어 있을 때 **전체 화면을 저장하는 메모리**입니다.

또한 컬러 TV가 발명되면서 컬러 모델(Color Model), 3D 모델의 가능성이 보이기 시작하면서 컴퓨터 그래픽스 표준들도 이때 처음 만들어집니다. GKS(Graphic Kernel System), Core 등의 표준 그래픽스 라이브러리들이 등장합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/007.png)

(Steve Jobs & Steve Wozniak, Apple II)
{: .text-center} 

1977년 스티브 잡스(Steve Jobs)와 스티브 워즈니악(Steve Wozniak)이 만든 8비트(8bit) 개인용 컴퓨터(Personal Computer) 애플 2(Apple II) 가 출시되었고 프레임 버퍼를 사용하는 기술들이 워크스테이션(Workstation)에 적용됩니다. 

이때부터 PC 기반 게임이 제작되기 시작하지만 아직 완전한 3D는 아니며 간단한 2D 그래픽 화면의 게임이 개발됩니다.

## 근현대 그래픽스 하드웨어
### 최신 반도체 기술의 적용

1980년대는 컴퓨터 하드웨어들이 획기적으로 발전하면서 CPU 성능도 좋아지고 메모리 용량도 커집니다. 발전한 성능과 메모리를 기반으로 **포토 리얼리스틱(Photo-realistic)**, 사실주의, 사진에 가까운 이미지를 렌더링하는 것이 가능해집니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/008.png)

(Silicon Graphics)
{: .text-center}

특히 **실리콘 그래픽스(Silicon Graphics)**라는 회사가 3D 그래픽스의 발전에 지대한 공헌을 합니다. 실리콘 그래픽스는 3D 그래픽스의 VLSI(Very-Large Scale Integrated circuits)칩을 설계했으며 OpenGL의 전신(前身)이 되는 IRIS GL 표준 라이브러리를 작성합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/009.png)

(Man in black & Jurassic park)
{: .text-center}

맨 인 블랙(Man in black) 쥐라기 공원(Jurassic park) 등 유명 할리우드 영화에서 사용된 컴퓨터 그래픽스가 실리콘 그래픽스의 하드웨어와 소프트웨어로 제작되었으며 아카데미 특수효과상을 석권합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/RenderMan_Logo.png)

(Renderman)
{: .text-center}

이 시기의 특징으로는 최신 반도체 기술을 이용하여 그래픽스 파이프라인을 제작하기 시작했다는 것이며 산업 표준으로는 **피그스(PHIGS), 렌더맨(RenderMan)** 등의 소프트웨어들이 등장 합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/011.png)

(ATI & AMD)
{: .text-center}

또한 **ATI**라는 회사는 팹리스(Fabrication-less) 방식으로 3D 그래픽스 칩을 설계하고 **그래픽 카드**를 제작하였고 PC 시장이 성장할 때 컴퓨터에 내장되는 그래픽 카드를 제공하면서 함께 성장합니다. 

ATI가 추후 AMD에 인수 합병되었지만 유명한 그래픽 카드인 *Radeon* 시리즈는 ATI 시절에 제작된 네이밍으로 유명합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/Nvidia_Logo.png)

(Nvidia)
{: .text-center}

후발 주자로는 **NVIDIA**가 있습니다. AMD에서 반도체 설계를 담당하던 직원들이 독립하여 창업한 회사로 지금도 유명한 그래픽 카드인 *GeForce* 시리즈를 제작했으며 최근에는 인공지능 분야까지 진출하면서 현재는 그래픽 카드에 있어서 독보적인 위치의 회사로 성장합니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/Pixar_Logo.png)

(Pixar)
{: .text-center}

1990년대로 들어오면서 그래픽스 표준이 정립되었고 OpenGL API가 완전한 표준으로 정착하게 됩니다. 

포토 리얼리스틱 그래픽 분야에서는 **Pixar**가 컴퓨터 그래픽스 만으로 제작된 애니메이션이 상업적 성공을 거둘 수 있음을 증명하였습니다.

2000년대는 AMD, NVIDIA 사의 고급 그래픽 카드들이 포토 리얼리스틱 이미지를 실시간으로 만들어내는 것이 가능해지면서 게임 그래픽스 시장에서 포토 리얼리스틱 방향으로 상업적인 성공을 거두게 됩니다. 

또한 반도체의 소형화가 거듭 발전하면서 휴대형 게임기와 스마트폰 시장이 탄생하였고 이러한 모바일 그래픽스(Mobile Graphics)에서도 동일하게 포토 리얼리스틱한 이미지를 구현하는 방향이 상업적인 성공을 거두고 있습니다.

## 그래픽스 API 소프트웨어
### OpenGL의 탄생까지
그래픽스 API란 'Application Programmer Interface'의 약자로서 C나 C++ 같은 고급 언어의 라이브러리들 중에서 그래픽스 프로그래머를 위해 만들어진 라이브러리를 바로 그래픽스 API라고 부릅니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/006.png)

([Graphic Kernel System](https://www.computerhope.com/jargon/g/gks.htm))
{: .text-center} 

최초의 그래픽스 전용 API는 1977년 개발된 **GKS(Graphical kernel system)**입니다. 개발 당시에는 2D 그래픽스만 구현 가능 했으나 같은 년도 개발된 라이브러리 중 하나인 **Core**는 2D와 3D 그래픽스 모두 구현 가능합니다.

1988년에는 **PHIGS(Programmers Hierarchical Graphics System)**가 개발되어 그래픽스 전용의 구조체(Structure)를 정의하고 그래픽스 데이터 베이스 모델을 제작하게 됩니다. 이때 부터 3D 그래픽을 체계적으로 만들 수 있다는 이론이 완전히 정립됩니다.

이 시기 실리콘 그래픽스는 기존의 그래픽스 라이브러리에서 고급 프로그래밍 언어로 구현되어 있던 API를 반도체의 형태로 물리적으로 제작해버리고 병렬처리 기술까지 도입해서 더욱 빠르게 발전 시켰습니다. 

이러한 반도체 칩과 직접 통신하는 수준의 그래픽스 API를 실리콘 그래픽스에서 제작하게 되는데요, 바로 **IRIS GL**입니다. 

IRIS GL은 당시로서는 엄청난 고성능 API였으나... 개발자들이 *하드웨어 설계 전문가* 였기 때문에 인터페이스에서 좋지 못한 평가를 받았습니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/OpenGL_Logo.png)

(OpenGL)
{: .text-center}


그래서 기존에 실리콘 그래픽스사에서 제공하던 그래픽 라이브러리의 인터페이스를 개선하고 체계적으로 만들자는 논의가 활발해졌고 OpenGL이 탄생했습니다. 

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/Khronos_Logo.png)

(Khronos Group)
{: .text-center}

OpenGL의 발전과 품질 관리를 위한 조직으로 **ARB(Architectural Review Board)** 가 만들어졌습니다. 이후 ARB가 **크로노스 그룹(Khronos Group)** 에 흡수되었으며 대부분의 명망있는 IT 기업들은 모두 크로노스 그룹에 가입하여 컨소시엄(Consortium) 형태로 OpenGL의 표준을 관리하게 됩니다. 

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/OpenGL_Fam.png)

(OpenGL Family)
{: .text-center}

- OpenGL : 워크스테이션 또는 PC 기반
- OpenGL ES (Embedded System) : 스마트폰 기반
- OpenGL SC (Safety Critical) : 군사용, 차량용, 보안용
- WebGL (JavaScript) : HTML5를 지원하는 웹 기반

OpenGL은 본래 워크스테이션이나 PC를 기준으로 작동하게 설계되었습니다. 그러다 시장에 스마트폰이 출현하면서 스마트폰에 최적화된 3D 그래픽스 라이브러리가 필요해서 OpenGL ES를 개발하게 됩니다.

군사용이나 차량용 등 에러가 없어야 하고 안정성이 중요한 분야에는 OpenGL SC 라는 이름으로 별도로 지원합니다.

웹 버전에는 HTML5가 개발되면서 자바 스크립트(JavaScript)에서 OpenGL을 구현한 WebGL 이라는 이름으로 지원합니다.

OpenGL ES은 스마트폰 시장에서 시장점유율이 압도적으로 높습니다. 예를 들어 iPhone이 OpenGL ES를 채택하여 사용합니다.

크로노스 그룹에서 컨소시엄 형태로 OpenGL의 표준을 관리하기 때문에 다양한 제조사에서 그래픽 카드를 생산하고 있습니다. 

그래서 제조사마다 성능 차이가 있을 수 있고 예를 들어 NVIDIA의 그래픽 카드가 다른 제조사들보다 OpenGL 처리 성능이 더 우수하다는 평가를 받고 있습니다.

### 다양한 시도들

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/010.png)

(DirectX)
{: .text-center}

**DirectX**는 마이크로 소프트(Microsoft)사의 PC OS인 윈도우즈(Windows) 및 콘솔 엑스박스(Xbox) 전용 그래픽스 API 입니다.

컨소시엄 형태가 아닌 마이크로소프트라는 단일 기업이 단독으로 개발하기 때문에 발전속도가 빠르고 굉장히 많은 기능을 가지고 있습니다.

다만 마이크로소프트가 개발한 기종에서만 작동하며 스마트폰에서는 사용이 불가능하다는 치명적인 단점이 있습니다.

현재의 추세는 셰이더 프로그래밍 분야에서 OpenGL과 호환성을 추구하고 있습니다. 

#### 로우 레벨(Low-Level) 그래픽스 API

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/DirectX3D12_Logo.png)

(DirectX3D 12)
{: .text-center}

OpenGL과 DirectX는 아주 긴 기간동안 서로 경쟁하며 꾸준히 성장하고 상업적으로 성공해왔습니다. 두 그래픽스 API가 고도화 될수록 기능이 방대해져 접근성이 떨어지고 사용하기도 어려워 오버헤드(Overhead)가 커지게 되었습니다.

![ComputerGraphics](/assets/images/Docs/Computer%20Graphics/012.png)

(Apple Metal, AMD Mentle, Khronos Group Vulkan)
{: .text-center}

그래서 고성능을 보장하되 오버헤드가 적고 멀티 플랫폼(Multi Platform)에서 사용할 수 있는 로우 레벨 그래픽스 API의 필요성이 생기게 됩니다.

- DirectX3D 12 : 로우 레벨 API 추가
- Metal : Apple 개발
- Mentle : AMD 개발
- Vulkan : 크로노스 그룹에서 OpenGL과 별도 제공

이러한 로우 레벨 언어는 고성능에 초점이 맞춰져 있습니다. 여러 기기의 성능을 최고로 발휘 할 수 있도록 최적화하는 것에 목적이 있습니다. 

크로노스 그룹이 멀티 플랫폼과 멀티 스레딩(Multi-Threading) 지원에 초점을 잡은 **Vulkan**을 밀어주고 있습니다. OpenGL과 연관성이 많기 때문에 OpenGL을 배웠다면 Vulkan에 입문하기에도 *비교적* 쉽습니다. 

그러나 Vulkan은 다른 API에 비해서 개발 난이도가 너무 높다는 치명적 단점이 있습니다. 대형 개발사가 많은 자금과 시간을 투자해야만 제 성능을 끌어낼 수 있기 때문에 대부분의 개발 환경에서 외면받고 있습니다.

로우 레벨 그래픽스 API 중에서 난이도도 낮고 성능도 뛰어난 것은 Apple 에서 개발한 **Metal** API라고 평가 받고 있습니다. 물론 iOS 외 다른 기기는 지원 하지 않는다는 것이 유일한 단점입니다.

그래서 OpenGL의 가장 마지막 버전이 2017년에 개발되었으나 지금까지도 게임 업계, 특히 모바일에서는 OpenGL ES를 주로 사용하고 있는 실정입니다.

## 레퍼런스(Reference)
- OXO : [https://en.wikipedia.org/wiki/OXO_%28video_game%29](https://en.wikipedia.org/wiki/OXO_%28video_game%29)
- GKS : [https://www.computerhope.com/jargon/g/gks.htm](https://www.computerhope.com/jargon/g/gks.htm)