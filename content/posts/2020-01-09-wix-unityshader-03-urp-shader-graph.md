---
title: "(UnityShader) 03 URP Shader Graph"
date: "2020-01-09T09:32:52.542Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(유니티쉐이더) 03 유니버설 렌더링 파이프라인 쉐이더 그래프Float 부동 소수점 연산벡터4는 각각 R,G,B,A(XYZW)의 네가지 float 데이터가 붙어있는 덩어리와 같습니다.벡터 연산은 같은 자릿수의 벡터와 연산해야 합니다. 하지만 직접 쉐이더 그래프에서 연산을 해 보시면 아시겠지만 다른 자리와"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-03-urp-shader-graph"
original_modified: "2020-01-09T09:44:06.336Z"
image: "/assets/images/wix/b12166e7e6-ce7a39_767b133206554043b4034fa2d8041737~mv2.gif"
---

(유니티쉐이더) 03 유니버설 렌더링 파이프라인 쉐이더 그래프

## **Float 부동 소수점 연산**

벡터4는 각각 R,G,B,A(XYZW)의 네가지 float 데이터가 붙어있는 덩어리와 같습니다.

벡터 연산은 같은 자릿수의 벡터와 연산해야 합니다. 하지만 직접 쉐이더 그래프에서 연산을 해 보시면 아시겠지만 다른 자리와의 연산도 강제적으로 가능합니다.

![](/assets/images/wix/b4c2bf6f97-ce7a39_feb9c2343b74435c8dd8040af8957888~mv2.png)

벡터4(0,1,0.5,0)와 벡터3(0,0,0.5)의 합연산을 하면 Output이 세자릿수 벡터3으로 강제되어 RGB(0,1,1)의 Cyan 색이 나오게 됩니다.

![](/assets/images/wix/fd08477233-ce7a39_75028d6c64f2426ab4bb21e7e72050ab~mv2.png)

한자릿수 벡터는 예외로 모든 자리의 벡터와 연산합니다. 예를들어 벡터4(0,0,0,0)와 벡터1(1)을 합연산 하면 벡터4(1,1,1,1)이 됩니다.

![](/assets/images/wix/0f2be99825-ce7a39_2a8fbd23ad0a427b9071444e75bc431a~mv2.png)

**One minus(1\-x)**

1 \- (1,0,1,0) = (0,1,0,1) 으로 G채널이 1인 초록색이 나옵니다.

값을 반전시킨다는 특성 때문에 많은 연산에서 쓰입니다.

![](/assets/images/wix/9b7f1f1cc1-ce7a39_10657a67d9594c5bbed38d2d8888ff7c~mv2.png)

중요한 기능이기 때문에 **One minus** 노드가 따로 존재합니다.

## **벡터 분해 결합**

벡터의 구성 요소들을 따로 분해할 수도 있고 합쳐서 새로운 벡터를 만들 수 도 있습니다.

![](/assets/images/wix/3b4eeab6f5-ce7a39_e0ce741eaae3472fa79392c8930542fb~mv2.png)

Split 노드로 각 요소를 분해하고 Combine 노드로 다시 합치는 과정입니다.

위 처럼 G채널과 B채널의 값을 서로 바꿔서 float4(1,0,1,0)을 float4(1,1,0,0)으로 바꾸어 색이 노란색이 됬습니다. 이것을 **스위즐링**이라고 합니다.

![](/assets/images/wix/f88ce082ce-ce7a39_ab942188c8ec44ad9d2fe74e9c4f21a4~mv2.png)

이렇게 텍스처에서 필요한 채널만 사용할 수 도 있습니다.

**응용실습 \- 컬러 바 만들기**

![](/assets/images/wix/b12166e7e6-ce7a39_767b133206554043b4034fa2d8041737~mv2.gif)

![](/assets/images/wix/5052032557-ce7a39_025f0022e0084bad90caac8f4216d356~mv2.png)

콤바인(Combine) 노드 하나와 벡터1 세개를 사용하여 프로퍼티에서 컬러를 따로 조절할 수 있게 만들었습니다.

**응용실습 \- 흑백 필터 만들기**

![](/assets/images/wix/bc1da96b3b-ce7a39_2338511bcf154afe8d01ecf750aec62b~mv2.gif)

![](/assets/images/wix/8697f14a5f-ce7a39_b14a6532666749e88f3aa09f27958a86~mv2.png)

텍스처의 R,G,B 채널을 각각 더하고 합한 값을 채널 숫자 만큼 3으로 나누면 평균값, 즉 흑백이 구해집니다. 거기에 선형 보간 함수(Linear interpolation)를 사용하고 0\~1 사이 값의 슬라이드로 흑백과 컬러를 전환 할 수 있습니다.
