---
title: "(UnityShader) 14 URP Shader Graph"
date: "2020-02-08T12:58:56.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "2-Pass Outline쉐이더로 외곽선을 그리는 방법중 프레넬을 사용한 방식은 저번 포스트에서 이미 다뤘습니다. 이번에는 2-pass 방식으로 외곽선을 그려보도록 합시다.패스(Pass) 란 저희와 같은 쉐이더 입문 단계에서는 ‘그린다’ 와 동의어라고 생각해도 됩니다.2-pass를 풀어서 쓰면 ‘두번 그"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-14-urp-shader-graph"
original_modified: "2020-02-08T12:58:56.000Z"
image: "/assets/images/wix/66ef06e2a6-ce7a39_eaf9056eff514250ae469158bf956461~mv2.gif"
---

## **2\-Pass Outline**

쉐이더로 외곽선을 그리는 방법중 프레넬을 사용한 방식은 저번 포스트에서 이미 다뤘습니다. 이번에는 2\-pass 방식으로 외곽선을 그려보도록 합시다.

**패스(Pass)** 란 저희와 같은 쉐이더 입문 단계에서는 **‘그린다’** 와 동의어라고 생각해도 됩니다.

2\-pass를 풀어서 쓰면 ‘두번 그린다’는 뜻이고 렌더링 파이프라인에 대해 작성한 포스트에서 배웠던 과정을 말 그대로 두번 시행 합니다. 똑같은 일을 두번 반복하는 것이니 연산이 두 배로 무겁지만… 다른 방식과 비교해보면 나름 가벼워서 많이 쓰이는 방식이라고 합니다.

심지어 맥스에서도 직접 만들어 볼 수 있을 정도로 간단합니다.

![](/assets/images/wix/18a9dd4a7e-ce7a39_fcbb44cfc17349b28c3f0b34bf7c8a31~mv2.png)

여기 노말 방향을 뒤집은 구체(Sphere)가 있습니다. 노말 방향을 뒤집었기 때문에 앞면은 안보이고 내부만 보이는 형태가 됩니다.

![](/assets/images/wix/e46d45ee06-ce7a39_870e4b1ca1fc4e6da1a3d6c1b54f75da~mv2.png)

추가로 노말 방향이 멀쩡한 구체를 하나 만들고 겹쳐 놓으면 기존의 구체가 외곽선이 됩니다. 정말 어이없이 2\-pass 완성입니다…

![](/assets/images/wix/76034efd7c-ce7a39_a824b2903ecb47f5b33033f0d3984a91~mv2.gif)

(도넛 모양을 스케일만 키웠을 경우 내부에 외곽선이 생기지 않음)

**주의할 점은 버텍스가 노말 벡터 방향으로 확장이 된 오브젝트와 겹쳐야** 정확하고 일정한 외곽선이 나온다는 점입니다. 스케일을 늘린다고 되는 것이 아닙니다.

![](/assets/images/wix/126a09b4b2-ce7a39_551d3a80670b4eb8ac2af18e7409244c~mv2.gif)

(버텍스가 노말벡터 방향으로 확장이 된 오브젝트가 우측, 스케일만 키운 쪽이 좌측)

![](/assets/images/wix/da669159b4-ce7a39_cf4c2947338f4c2497cab16b80fcb7e3~mv2.png)

투패스 방식은 간단하고 가볍기도 하지만 위 이미지의 빨간 동그라미 부분을 보면 알 수 있듯이 외곽선의 형태가 올바르지도 않고 닫히지 않은 Plane 같은 도형에는 외곽선이 생기지 않는다는 큰 한계를 가지고 있습니다.

장단점과 원리를 파악했으니 투패스 방식을 URP 쉐이더 그래프로 구현해보도록 합시다.

![](/assets/images/wix/5c6875b699-ce7a39_0dd401709a8445deb1d10d6989f5d513~mv2.png)

참고로 노드 에디터의 PBR master 노드를 비주얼 스튜디오로 열어보면 HLSL 스크립트로 Pass 라고 적혀있는 코드들을 볼 수 있습니다.

![](/assets/images/wix/c02902435c-ce7a39_51cd02b473a44fe1845c63b6166e0fb0~mv2.png)

Create \- Rendering \- URP \- Pipeline Asset (Forward Renderer)를 클릭합니다.

![](/assets/images/wix/185cef5ec6-ce7a39_ef6a7c6b533e4096b285777f10a93f96~mv2.png)

파이프라인 에셋과 파이프라인 렌더러가 만들어집니다. 유니티에서 파이프라인을 아티스트가 원하는 대로 뜯어 고쳐 커스텀으로 사용할 수 있게 만든 기능입니다.

![](/assets/images/wix/fd04b8fd82-ce7a39_e03e38bc89184482ba09f4dbf48ff856~mv2.png)

파이프라인 에셋을 활성화 시켜주기 위해 Edit \- Project Settings 를 클릭하고 Graphics 메뉴를 엽니다.

![](/assets/images/wix/e3bb9d7e85-ce7a39_72af81e173b74576aceca883d95444ba~mv2.png)

빨간 네모에 저희가 만든 URP에셋을 드래그&amp;드롭 하여 집어 넣습니다.

![](/assets/images/wix/e958000ad4-ce7a39_2a8d64ce67d14647965e10dff9c47457~mv2.png)

같은 Project Settings의 하위 메뉴인 Quality의 Rendering 에도 드래그&amp;드롭 해줍니다.

![](/assets/images/wix/0cdd161f21-ce7a39_b07fc137d2994ab8a996ce71ba349c4a~mv2.png)

URP에셋\_렌더러를 선택하면 현재 적용된 에셋의 렌더러를 조작할 수 있습니다. 현재 렌더러는 모든 레이어를 그리는 옵션이 기본으로 되어있습니다.

![](/assets/images/wix/7b1ec2a492-ce7a39_b8c07cef82f94ea6aa9c38eca144eff5~mv2.png)

2\-Pass Outline을 적용할 오브젝트의 레이어를 Custom으로 설정하고

![](/assets/images/wix/71c5aae37b-ce7a39_67d0c44557c64131bcddaba394983daf~mv2.png)

URP에셋\_렌더러에서 Custom 레이어의 체크를 해제합니다.

![](/assets/images/wix/db422ac2ce-ce7a39_76a248e9001d4768a04ecaa38cedee6c~mv2.png)

이렇게 하면 적용할 오브젝트를 그리지 않게 됩니다. 이제 패스를 추가하여 두번 그리게 만들어 봅시다.

![](/assets/images/wix/e444077888-ce7a39_bfb2f177900f44688dabfe7006d47275~mv2.png)

Renderer Features의 \+ 버튼을 눌러 Render Objects를 클릭합니다.

![](/assets/images/wix/785b61ac77-ce7a39_3a4de42d3de34a418b8d91b7c2616c6f~mv2.png)

이렇게 하면 1 pass 가 추가 된 것입니다.

![](/assets/images/wix/636e70037d-ce7a39_7ae87ae6dfb748929e66685ff6e683e1~mv2.png)

Pass로 그려야할 레이어인 Custom을 선택해주고 위에도 Everything으로 바꿔줍시다.

이렇게 하면 똑같은 오브젝트를 두번 그립니다. 2\-Pass 입니다.

![](/assets/images/wix/6a7f6a89c1-ce7a39_f07a923b3a5e492d88d851bfa7610fd9~mv2.png)

Overrides를 보면 두번째 패스에 외곽선으로 사용할 메테리얼을 따로 적용할 수 있습니다.

![](/assets/images/wix/abe6dc0cc1-ce7a39_8fd16ac27716434cbdd26cb61bf60db2~mv2.png)

Outline 메테리얼을 만들고 Unlit 쉐이더 그래프를 적용하니 회색으로 나옵니다. 제대로 적용된 것을 확인 할 수 있습니다.

![](/assets/images/wix/6ba0bf9102-ce7a39_336bbf1d220240b6812defc87dbf5c3b~mv2.png)

![](/assets/images/wix/0352f56f85-ce7a39_d2679e60f94443efa23dbcdccb9d315d~mv2.png)

투패스 방식에서 외곽선이 출력되는 원리를 생각해 봅시다. 지난시간에 공부한 대로 노말 방향으로 버텍스 포지션이 확장되는 쉐이더를 노드로 짜면 위와 같은 결과가 나옵니다.

문제는 쉐이더 그래프에는 노말의 방향을 뒤집는 노드가 없다는 점입니다. 그래서 괴상한 방법으로 진행해야 합니다.

![](/assets/images/wix/ecea79bf07-ce7a39_2974f1c81b4240cdbd9114906686169b~mv2.png)

먼저 Two sided를 켜줍니다.

![](/assets/images/wix/620f114df3-ce7a39_77592eb33ad64378bad6dfeb9c69e00c~mv2.png)

Is front face? 노드와 Branch 노드를 꺼냅니다.

노드 이름을 보면 알 수 있듯이 is front face 노드는 이것이 앞면인지 아닌지를 검증합니다. 앞면이 맞으면 True, 아니면 False를 반환하는 출력값이 참/거짓인 bool 논리 연산 노드입니다.

이것을 T/F 값을 받을수 있는 Branch 노드로 참이면 1 거짓이면 0을 반환하도록 만듭니다.

![](/assets/images/wix/28b4260bb2-ce7a39_58c93c9ef9d44d96b212956ed1ba017c~mv2.png)

결과 값을 알파에 연결하면 **앞면이면 투명하게, 뒷면이면 불투명하게** 만들어서 외곽선만 보이도록 처리하는 것입니다.

![](/assets/images/wix/66ef06e2a6-ce7a39_eaf9056eff514250ae469158bf956461~mv2.gif)

투패스 방식으로 매우 기본적인 수준의 외곽선을 얻을 수 있습니다. 여기에 Depth buffer를 이용한 후처리 외곽선이나 프레넬 외곽선을 추가해서 좀 더 자연스러운 외곽선을 표현 할 수 있습니다.
