---
title: "(UnityShader) 07 URP Shader Graph"
date: "2020-01-17T07:36:46.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "이전 포스트에서 선형 보간으로 텍스처를 섞었던 것 처럼 특정 채널에만Roughness(Smoothness)를 넣어봅시다.참고로 스무스니스는 러프니스를 반전한 값입니다. PBR에서는 러프니스가 기준이고 오직 유니티 엔진만 반대 기준인 스무스니스를 사용하기 때문에 앞으로는 러프니스라고 부르도록 하겠습니다.R"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-07-urp-shader-graph"
original_modified: "2020-01-17T07:36:46.000Z"
image: "/assets/images/wix/b9d6ab2fa2-ce7a39_c282ba4c3c104b5aa4306cd1bd7eb537~mv2.gif"
---

![](/assets/images/wix/473904116b-ce7a39_d9114300332e4a80a84bea97ae7d564a~mv2.png)

이전 포스트에서 선형 보간으로 텍스처를 섞었던 것 처럼 특정 채널에만Roughness(Smoothness)를 넣어봅시다.

참고로 스무스니스는 러프니스를 반전한 값입니다. PBR에서는 러프니스가 기준이고 오직 유니티 엔진만 반대 기준인 스무스니스를 사용하기 때문에 앞으로는 러프니스라고 부르도록 하겠습니다.

![](/assets/images/wix/d99ed8ca75-ce7a39_4d7c25cde8164456ac50ac91b5027e46~mv2.png)

R채널을 그대로 러프니스에 연결해 봅시다.

![](/assets/images/wix/37c0a5463c-ce7a39_fee3d97c2ab54974ad67ea3f92d679f6~mv2.gif)

![](/assets/images/wix/6547a9882e-ce7a39_3a531724d0b0497992c024848b2531ec~mv2.png)

R채널만 러프니스 값이 들어간 것을 확인할 수 있습니다만 너무 반짝 거리기 때문에 노말맵도 연결하고 러프니스 값을 줄여보도록 합시다.

![](/assets/images/wix/22f46270ae-ce7a39_1ca515bb3f544859b6a8a6d64cd6912a~mv2.png)

![](/assets/images/wix/cf782379ed-ce7a39_84c13855cd8d439a991b27c0f393e06c~mv2.gif)

R채널 자체에 0.5 정도의 값을 곱해서 러프니스 값을 절반으로 만듭니다. 하지만 아직도 보기 좋지 않네요. 채널도 B채널으로 바꾸고 노말맵도 B채널에만 들어가도록 노드를 짜봅시다.

![](/assets/images/wix/daadcf3958-ce7a39_7f9d3afa5c2b4fb7a3393e5744756d05~mv2.png)

![](/assets/images/wix/dc0175e457-ce7a39_f94f676e19ec4ae8a6b6710568a967d0~mv2.png)

선형 보간 함수를 사용해 URP 노말맵 부록에서 배웠듯이 완전히 비어있는 노말을 숫자로 표현하여 벡터(0,0,1)과 노말맵을 B 채널으로 선형 보간 해줍니다.

![](/assets/images/wix/8865d0e2e5-ce7a39_034c7d2401094a1c836cb943f2178baa~mv2.png)

![](/assets/images/wix/cb1709bfc7-ce7a39_719463237cf043c28922142027f95d4d~mv2.gif)

노말맵의 세기를 조절하기 위해 Lerp 함수를 한번 더 응용하여 T값을 변수로 빼고 기존의 노말맵과 비어있는 노말값인 (0,0,1)과 선형 보간합니다.

노말맵의 세기를 1 이상으로 만드려면 어떻게 해야 될까요?

![](/assets/images/wix/abc9dba71f-ce7a39_f90a4f02914c4e90a34de3926a33ffc9~mv2.png)

![](/assets/images/wix/0cf2a61be3-ce7a39_7a8f88bc77a84927aa9ecfb29d954ead~mv2.gif)

R 채널과 G 채널에 1이상의 값을 곱해주면 됩니다. 단 R과 G 값이 1보다 크면 노말이 뒤집혀 버리기 때문에 Clamp 노드로 \-1\~1 사이의 값으로 잘라버리거나 다른 방법으로 제한해야 합니다.

![](/assets/images/wix/1aa2a37562-ce7a39_24a8593ee38d4742940dabb191a64632~mv2.png)

![](/assets/images/wix/b9d6ab2fa2-ce7a39_c282ba4c3c104b5aa4306cd1bd7eb537~mv2.gif)

저번 포스트에서 서술 했던 타임 함수로 오프셋 이동을 하게 만들면 노말맵만 움직이게 하는 것도 가능합니다.

## **벡터 연산**

![](/assets/images/wix/3960ab8e12-ce7a39_9af004daff274f729ec6cb0963879ee8~mv2.png)

여기에 두 벡터2 U(1,2)와 V(\-1,1)가 있습니다.

벡터의 합연산은 각 인자들 끼리 더해주면 됩니다.

(1\-1,2\+1) = (0,3)

벡터의 차연산은 자연수의 사칙연산과 똑같이 연산의 순서에 따라 결과값이 바뀝니다.

U\-V = (1,2) \- (\-1,1) = (2,1)

V\-U = (\-1,1) \- (1,2) = (\-2,\-1)
