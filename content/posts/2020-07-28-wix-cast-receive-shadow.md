---
title: "(UnityShader) 04 Cast & Receive Shadow"
date: "2020-07-28T15:31:22.626Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(커스텀 Fragment 쉐이더와 유니티 standard 쉐이더)카툰 쉐이더를 프래그먼트로 작성하면서 서피스 쉐이더가 알아서 붙여주던 여러 자동 생성 패스와 함수들이 없어져서 가장 치명적이었던건 바로 그림자가 없다는 것이었습니다.NdotL 공식 자체는 단 하나의 라이트 벡터와 대응하는 오브젝트 노말 사이"
original_url: "https://walll4542.wixsite.com/watchthis/post/cast-receive-shadow"
original_modified: "2020-08-18T04:09:27.498Z"
image: "/assets/images/wix/9d6d99bff6-ce7a39_0a4f826a43f44a91b979d5c8a1e0240d~mv2.png"
---

![](/assets/images/wix/5dfa586d94-ce7a39_5ee77ffb02a34dc0968a7ccf8d38f924~mv2.png)

(커스텀 Fragment 쉐이더와 유니티 standard 쉐이더)

![](/assets/images/wix/12af82c80e-ce7a39_d9947fe348714c45b261277f022f4fda~mv2.png)

카툰 쉐이더를 프래그먼트로 작성하면서 서피스 쉐이더가 알아서 붙여주던 여러 자동 생성 패스와 함수들이 없어져서 가장 치명적이었던건 바로 그림자가 없다는 것이었습니다.

NdotL 공식 자체는 단 하나의 라이트 벡터와 대응하는 오브젝트 노말 사이의 관계만 다루고, 제2의 조명이 존재 할 경우, 혹은 다른 오브젝트가 조명을 가려버릴 경우는 고려 되지 않습니다. (다른 조명이 존재할 경우 조명의 숫자 만큼 내적을 하고 결과 값을 전부 더하는 식으로 처리합니다만 이번 포스트에서는 다루지 않습니다)

오브젝트가 조명을 받는 면은 밝아지고 그렇지 않은 면은 어두워져서 명암은 있지만, 오브젝트가 조명을 가렸을 때 그림자를 만들어야 하고**(Cast)**, 오브젝트 표면에도 그림자가 생겨야 합니다**(Receive)**. 그림자가 없는 결과물은 이번에 진행하는 배경 씬 툰쉐이더에서도 매우 부자연스러웠기 때문에 이번에는 쉐도우 캐스트 리시브를 프래그먼트로 짜보려 합니다.

게임 엔진에서 그림자를 렌더링하는 여러가지 방식이 존재하며 이론은 전혀 모르지만, 저희가 엔진을 공부하였고 쉐이더를 공부 했기 때문에 배운 것을 바탕으로 그림자의 연산 방식을 추측 해보았습니다.

먼저 유니티 엔진에서 고품질의 **GI(Global** **Illumination****)** 를 얻기 위해 *라이트 맵(Light map)*을 구웠던(bake) 일이 떠오릅니다.

라이트 벡터의 방향대로 라이트 샘플(Light Sample), 현실에서는 광자를 쏘아 보내서 오브젝트를 구성하는 폴리곤과의 '충돌 체크'를 통해 샘플이 폴리곤에 부딪히는 부분이 생길 것입니다.

그렇다면 현실의 물리 법칙대로 광자를 반사 시켜야 할 것입니다. 반사각을 구하기 위해 라이트 벡터와 폴리곤의 노말 값을 가지고 리플렉션(Reflection) 벡터를 연산하고 방향대로 다시 라이트 샘플을 쏘아 보내고... 이 과정을 계속 반복합니다.

하지만 이런 식이라면 라이트 샘플은 무한히 반사되어 튕겨져 나오고 연산이 영원히 끝나지 않아서 우리의 CPU는 녹아버릴 것입니다. 그래서 아티스트가 엔진에서 라이트 샘플이 반사되는 최대 바운스(bounces) 횟수를 제어 할 수 있게 되어 있습니다.

유니티 엔진의 경우는 디폴트 값이 2번 입니다만, 시네마틱에서 쓰는 아놀드(Arnold) 렌더러의 경우는 디폴트가 999번이나 됩니다. 대충 생각해도 라이트 샘플 갯수 \* 바운스 횟수 만큼 계산해야 하니 렌더링이 오래 걸리는 데에는 다 이유가 있습니다...

![](/assets/images/wix/35303514a6-ce7a39_bb37465111b0400899b7de530fab50d6~mv2.png)

([http://bobby\-parker.com/architectural\-rendering\-blog/all\-you\-need\-to\-know\-about\-ambient\-occlusion](<http://bobby-parker.com/architectural-rendering-blog/all-you-need-to-know-about-ambient-occlusion>))

PBR의 앰비언트 오큘루젼(Ambient Occlusion)맵 또한 빛이 아무리 난반사 되더라도 폴리곤이 너무 구석진 곳에 있어 빛이 일정 이하 수준 밖에 도달 하지 못하는 픽셀을 계산하여 베이크한 맵 입니다.

![](/assets/images/wix/9d6d99bff6-ce7a39_0a4f826a43f44a91b979d5c8a1e0240d~mv2.png)

(움브라, 페넘브라, 앤텀브라 [https://en.wikipedia.org/wiki/Umbra,\_penumbra\_and\_antumbra](<https://en.wikipedia.org/wiki/Umbra,_penumbra_and_antumbra>))

우리의 현실에서 볼 수 있는 가장 큰 그림자인 낮과 밤을 우주에서 본다고 생각해 봅시다. 빛이 아예 없는 부분*(Umbra)*도 있고, 약하지만 조금 씩은 들어오는 부분*(Penumbra)*도 있습니다. 그림자는 지구에 가까울 수록 그림자의 비율이 높으며 멀어질 수록 점점 빛이 들어와 그림자가 감쇠*(Attenuation)*되는 것을 볼 수 있습니다.

따라서 유니티 라이트 맵 베이크 방식이라면 광자가 충돌하지 않는 부분이 곧 **빛이 들지 않는 부분이며 그림자가 존재한다**고 정의 내릴 수 있을 것입니다. 라이트 맵을 직접 구워보면 알 수 있지만 처음에는 완전 어두운 상태에서 시작하고 과정이 진행되면서 빛이 들어오는 부분은 점점 밝아지고 해상도가 올라갑니다.

하지만 리얼타임으로 그림자를 연산하기 위해서는 라이트맵 베이크는 실시간으로는 동작 할 수가 없습니다. 너무 무겁고 오래걸립니다. 실제 게임에서는 어떤 방식을 사용할까요?

![](/assets/images/wix/ea83c140ee-ce7a39_b2b052316fba4965a81f103bdee01519~mv2.png)

![](/assets/images/wix/c0b3e9a22b-ce7a39_1fad0ca8096247cf8799b825ad7a753f~mv2.png)

PCSS(Percentage\-Closer Soft Shadows)

엔비디아가 시그라프에서 발표한 유명한 소프트 쉐도우(Soft shadow) 계산 방식 중 하나인 PCSS입니다.

공식을 설명하자면 w\-light는 광원 입니다. 중간에 있는 블로커(Blocker*)*는 빛을 차단하는 오브젝트를 뜻하며, d\-blocker(distance of blocker)는 블로커와 광원과의 거리이며, d\-receiver는 그림자가 생기는 오브젝트와 라이트 벡터 사이의 거리를 뜻합니다. 그림자를 받는 부분과 빛을 가리는 블로커와 광원을 서로 평행하다고 가정해서 계산하게 됩니다.

빨간색 쉐도우 맵(Shadow Map)으로 표시 된 영역을 샘플링해 얼마나 빛을 차단하는지를 계산하면 빛을 받는 정도를 알 수 있게 됩니다. 라이트 벡터 기준으로 깊이 값을 샘플링하여 해당 픽셀이 가려지는 정도를 계산하고 해당 픽셀의 그림자 평균 비율으로 페넘브라를 계산 하는 것을 위 자료에서 볼 수 있습니다.

![](/assets/images/wix/412f96ec63-ce7a39_610b6ce610444a6fb46bfedbd7527a8f~mv2.png)

(스크린 스페이스 쉐도우 맵 : [https://learnopengl.com/Advanced\-Lighting/Shadows/Shadow\-Mapping](<https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping>))

유니티 엔진은 리얼타임 그림자 연산을 PCSS가 아닌 다른 방식으로 수행 하고 있습니다. 바로 **SSSM(Screen Space Shadow Map)** 방식입니다.

포워드 렌더링을 기준으로, 작동 원리는 먼저 '카메라 기준' 깊이 텍스처를 렌더링 합니다. 다음은 그림자 연산을 위한 버퍼를 따로 마련합니다. 이 버퍼는 '광원 기준'으로 깊이 텍스처를 렌더링 합니다. 여기서는 광원 기준 깊이 텍스처를 *'쉐도우 맵'*이라고 부릅니다. 이렇게 완성된 뎁스 텍스쳐와 쉐도우 맵을 버퍼에서 값을 비교하여 그림자 영역을 계산합니다.

![](/assets/images/wix/06c42f8f14-ce7a39_4a3de66927904fe0acd37c0a89b2a5fe~mv2.png)

(버퍼 속의 쉐도우 맵)

앞에서 유니티 라이트 맵 베이크에 대해 말할 때 정리했듯이, **빛이 들지 않는 부분이 곧 그림자입니다.** 따라서 광원 기준으로 생성된 쉐도우 맵에 저장된 깊이 값 보다 카메라 기준 뎁스 텍스쳐의 깊이 값이 더 크다면, 다른 오브젝트에 의해서 가려졌다고 판단하고 해당 픽셀에 그림자를 렌더링 합니다.

![](/assets/images/wix/c896d7ca9b-ce7a39_d3b06cf866df4848aa192a8b5539f3ec~mv2.png)

(Mesh Renderer 항목)

리얼타임 렌더링에서 뎁스 텍스처와 쉐도우 맵을 위해 추가적인 드로우 콜을 쓰고 카메라에 렌더링되는 모든 픽셀에 대해서 비교 연산을 해야 되기 때문에 리소스를 많이 잡아먹습니다. 메시 렌더러에서 캐스트 쉐도우와 리시브 쉐도우는 꼭 그림자가 필요한 오브젝트에게만 설정해줌으로서 드로우 콜을 절약 할 수 있습니다.

```hlsl

#include "Lighting.cginc"
#include "AutoLight.cginc"
```





다음 포스트에서는 프래그먼트 쉐이더를 이용하여 유니티의 .cginc 속에 이미 작성되어 있는 SSSM 함수에 접근하여 다른 오브젝트가 만드는 그림자를 리시브 하는 부분을 작성하고, 그림자를 렌더링하는 패스를 추가하여 캐스트 까지 만들 것입니다.
