---
title: "(UnityShader) 02 URP Shader Graph"
date: "2020-01-06T18:58:20.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(유니티쉐이더) 02 유니버설 렌더링 파이프라인 쉐이더 그래프이 포스트는 2020년 1월에 작성되었습니다. 현재의 유니티와는 다를 수 있습니다.현재 제일 최신 정식 릴리즈인 2019.3.0f3 버전 입니다. 그렇습니다. 유니티가 결국엔 LWRP / HDRP 나누던거 다 그냥 URP 하나로 합쳤습니다.UR"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-02-urp-shader-graph"
original_modified: "2020-01-06T18:58:20.000Z"
image: "/assets/images/wix/990defa3ee-ce7a39_5582ec2fdb474b4abcb2532321ccb2e6~mv2.png"
---

(유니티쉐이더) 02 유니버설 렌더링 파이프라인 쉐이더 그래프

이 포스트는 2020년 1월에 작성되었습니다. 현재의 유니티와는 다를 수 있습니다.

![](/assets/images/wix/fdaef57c94-ce7a39_5a4f193dbba64d91adaae83551a79c95~mv2.png)

현재 제일 최신 정식 릴리즈인 2019.3.0f3 버전 입니다. 그렇습니다. 유니티가 결국엔 LWRP / HDRP 나누던거 다 그냥 URP 하나로 합쳤습니다.

URP로 들어오면서 언리얼 엔진처럼 노드로 쉐이더를 작성 할 수 있도록 Shader Graph 기능이 추가되었습니다. 우리는 쉐이더 그래프 기본 조작에 대해 알아볼 것입니다.

![](/assets/images/wix/990defa3ee-ce7a39_5582ec2fdb474b4abcb2532321ccb2e6~mv2.png)

URP 프로젝트를 열면 기본적으로 에셋 몇개와 후처리, 리플렉션 / 라이트 프로브가 들어있는 기본 씬을 하나 던져줍니다. Hierarchy에서 카메라와 디렉셔널 라이트(Directional light)를 제외하고 깔끔하게 지워 줍시다.

![](/assets/images/wix/dd2ad6c447-ce7a39_aaf877163c614c2f8b502cd6e0f2be12~mv2.png)

에셋 창에서 우클릭하여 Create \- Shader 의 목록을 보면 다음과 같이 저희가 찾던 그래프가 있습니다.

**Unlit Graph**

: Un\-light. 단어 그대로 빛이 없는, 빛에 대한 연산을 하지 않는 쉐이더에 대한 노드 에디터 입니다.

**PBR Graph**

: 물리 기반 쉐이더를 작성하는 노드 에디터입니다.

**VFX Shader Graph**

: 이펙트에 사용되는 쉐이더를 제작할 때 사용하는 노드 에디터 입니다.

**Sub Graph**

: 언리얼의 메테리얼 인스턴스처럼 쉐이더에서 동작하고 재사용 할 수 있는 함수를 편집하는 노드 에디터 입니다.

PBR Graph를 선택하여 생성합니다.

![](/assets/images/wix/20bbaf159f-ce7a39_9de80c117ed14470b1eb9b8003252714~mv2.png)

PBR 그래프 아이콘을 더블 클릭을 하면 아래와 같은 창이 열립니다.

![](/assets/images/wix/05efc29d7d-ce7a39_ee2b91c1582148ceb1fb1e5ff846afc4~mv2.png)

**블랙보드** **PBR 마스터 노드** **프리뷰**

**블랙보드**는 그래픽 아티스트가 메테리얼의 인스펙터(Inspector) 창에서 변수를 조작할 수 있도록 프로퍼티(Property)로 선언하는 부분입니다.

**PBR 마스터 노드**에서 모든 핵심 코드들을 작성하고 편집할 수 있습니다.

각 항목 괄호의 숫자는 변수가 가진 정보량을 나타냅니다. 예를 들어 버텍스 포지션 값은 X,Y,Z로 Vector3이기 때문에 (3)으로 적혀 있습니다.

이렇게 작성된 쉐이더 노드를 **프리뷰** 창에서 미리 볼 수 있습니다.

![](/assets/images/wix/4fa62a1d03-ce7a39_75e871fe593c4c5f9f32e00fe24008f5~mv2.png)

블랙보드에서 Vector1 변수를 추가해 봅시다.

![](/assets/images/wix/05600a6364-ce7a39_36255c1d89b5405aa1c7540cabf9e571~mv2.png)

Exposed 체크박스

: 체크박스에 체크가 되어 있다면 인스펙터 창에서 변수를 조작할 수 있습니다.

Reference

: 쉐이더 그래프 내부에서 프로그래머가 접근할 때 사용할 이름을 변경 할 수 있습니다.

![](/assets/images/wix/038eedfbe6-ce7a39_192afe5d3f6642c4a2ffc897275c7b92~mv2.png)

![](/assets/images/wix/1abd0aceb8-ce7a39_3c4726d42fcd4e22945fc449a7429c8c~mv2.png)

Default

: 프로퍼티에서 제한 없는 값을 입력해줄 수 있습니다.

![](/assets/images/wix/439177117b-ce7a39_a03d183cc72b44b0b48375e29159a250~mv2.png)

Slider

: 프로퍼티를 제한된 슬라이드의 형태로 만들어줍니다.

![](/assets/images/wix/00bba2ae46-ce7a39_771375ea04204f2aadfb9a75c962dc60~mv2.png)

우클릭 할 경우 프로퍼티의 이름 자체를 변경 할 수 있습니다.

![](/assets/images/wix/4edc2bfc14-ce7a39_96a9279000cf4a92bfd17021a511e86a~mv2.png)

Precision

: 변수의 크기를 결정합니다.

![](/assets/images/wix/2e9adac515-ce7a39_034c8e7795e048bb834eb36df8f3f3c6~mv2.png)

Vector4 /  Color

기본적으로 둘은 똑같습니다. 컬러의 RGBA와 벡터4의 XYZW가 대응하기 때문입니다.

Color 노드가 HDR 인터페이스를 사용한다는 것 외에는 차이가 없습니다.

![](/assets/images/wix/dd35e7ef0d-ce7a39_f2ef324bd14b433889822c1063c189d7~mv2.png)

위 처럼 벡터3의 X값에 1을 넣어도 컬러 노드의 빨강과 동일한 결과물이 나옵니다.

![](/assets/images/wix/2b1d0da243-ce7a39_04f30e57c05d467e8942efe4da605687~mv2.png)

![](/assets/images/wix/f998c8f419-ce7a39_afbe12e8652c4b47b9b2f2baca35979c~mv2.png)

Texture2D / Cubemap

텍스쳐를 받는 노드입니다. 큐브맵 노드는 유니티의 큐브맵 스카이박스등에 사용됩니다.

![](/assets/images/wix/dd7c281bb8-ce7a39_2692ecfa0ab64191afa5887a34254c51~mv2.png)

Matrix

행렬 데이터를 받는 노드입니다. Exposed가 잠겨있고 쉐이더 그래프 에디터 내부에서만 작동합니다.

어느정도 변수 조작법에 대해 알았으니 기본적인 컬러 연산을 해봅시다. RGB는 **가산혼합**이기 때문에 더할수록 밝아집니다.

![](/assets/images/wix/8e878f8989-ce7a39_a8a321e88d484cec887519eb4e0ed36c~mv2.png)

Vector의 합과 곱은 제대로 결과물이 나오는데 Color의 합과 곱은 결과물이 이상합니다..?

![](/assets/images/wix/b649ed1cfd-ce7a39_b3109c9e48c54bcc97df2bc7991ee35c~mv2.png)

![](/assets/images/wix/565d171180-ce7a39_37c40b5d1b844d3d873415826632f066~mv2.png)

쉐이더 그래프에서 Color 노드는 sRGB 컬러 공간으로 인식을 하기 때문에 컬러 공간 변환 노드를 거쳐서 Linear를 RGB로 바꿔줘야 합니다...
