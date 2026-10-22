---
title: "(UnityShader) 10 URP Shader Graph"
date: "2020-01-27T16:12:12.941Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Phong Reflection model빛을 받는 모든 물체에는 정반사와 난반사가 일어납니다. 물체의 표면을 보면 가장 밝은 하이라이트 부분이 있습니다. 하얀 동그라미 부분이 정반사 = Specular(스페큘러)에 의해 생기는 것입니다.(정반사와 난반사)스페큘러는 왜 생기는 걸까요? 물 표면에 반사된 하"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-10-urp-shader-graph"
original_modified: "2020-02-23T18:55:15.790Z"
image: "/assets/images/wix/0455fddfe3-ce7a39_2a145a7be2dc40089183d5175bfc1e1f~mv2.png"
---

## **Phong Reflection model**

![](/assets/images/wix/ee3adb3f2a-ce7a39_9c42d7b466e9406797059ca400facbf2~mv2.png)

빛을 받는 모든 물체에는 정반사와 난반사가 일어납니다. 물체의 표면을 보면 가장 밝은 하이라이트 부분이 있습니다. 하얀 동그라미 부분이 정반사 = Specular(스페큘러)에 의해 생기는 것입니다.

![](/assets/images/wix/0feeefc67f-ce7a39_46e1faeaf2414acf9beb86a4ef257273~mv2.jpg)

(정반사와 난반사)

스페큘러는 왜 생기는 걸까요? 물 표면에 반사된 하늘이나 거울에 비친 자신의 모습을 본 적이 있을 겁니다. 반대로 모래와 돌 같이 거친 표면에는 하늘과 우리 모습이 보이지 않습니다.

위에서 경험 할 수 있듯이 물체 표면의 매끄러운 정도에 따라 난반사와 정반사의 비율이 결정됩니다. 게임 엔진에서 기본적으로 제공하는 물리 기반 렌더링 메테리얼에서는 이 값을 Roughness(유니티는 반전된 값인 Smoothness) 라고 합니다.

![](/assets/images/wix/0455fddfe3-ce7a39_2a145a7be2dc40089183d5175bfc1e1f~mv2.png)

(Bui Tuong Phong)

이번 포스트에서는 부이 뜨엉 퐁 아저씨가 개발하고 이름 붙인 ‘퐁 리플렉션 모델’의 스페큘러 공식을 구현 해볼 것입니다.

![](/assets/images/wix/158f8ee1f1-ce7a39_4e942e6bbcff4d70a6a647b9a5762e9d~mv2.png)

쉐이더 그래프 작성에 들어가기전에 기본적으로 이해해야 할 벡터 개념입니다.

PBR의 스펙큘러 공식과 달리 퐁 리플렉션 모델은 물체의 러프니스 값을 특정하지 않습니다. 대신 정반사 각도와 카메라의 각도가 얼마나 일치하는가 비교하여 표면의 정반사율을 구하는 방식입니다.

그러기 위해선 태양에서  날아온 라이트 벡터가 물체 표면에서 정반사된 리플렉션 벡터를 구해야 합니다.

### ***R=2(L⋅ N)N\-L***

리플렉션 벡터(R)는 위와 같은 공식으로 계산할 수 있습니다. (L 라이트 벡터, N 노말 벡터)

![](/assets/images/wix/90330f03ac-ce7a39_c61d2ee4170e4027b29b9502d124b7a7~mv2.png)

이렇게 구한 리플렉션 벡터를 뷰 벡터와 내적 연산을 하면 각도 차이인 코사인 세타 값이 나옵니다. 값이 0이라면 스페큘러가 생기지 않는 것이고 값이 1이라면 그 부분이 스페큘러가 가장 강한 곳입니다. 이제 쉐이더 그래프로 노드를 작성해봅시다.

![](/assets/images/wix/faab10f7eb-ce7a39_8b6146394faf4761aece500f3ced9b34~mv2.png)

리플렉션 공식을 자동으로 계산해주는 Reflection 노드를 가져와 라이트 벡터를 리플렉션 벡터를 구합니다. 여기서 주의할 점이 있습니다.

![](/assets/images/wix/3760dd4e1c-ce7a39_f2f06dcb0ac94d42ba47b2387a3fb065~mv2.png)

(위는 리플렉션 노드, 아래는 실제 리플렉션 공식을 따른 계산)

리플렉션 벡터의 방향이 뒤집힌채로 나오기 때문에 리플렉션 벡터의 방향을 \-1을 곱해서 반전 해주고 정규화 해주어야 합니다.

![](/assets/images/wix/fe1c700c37-ce7a39_f01001d467de47869e008c04acc53679~mv2.png)

리플렉션 벡터를 뷰 벡터와 내적합니다. saturate 로 자르고 power로 곱해서 스펙큘러의 범위를 수정해줍니다.

![](/assets/images/wix/2d6af95268-ce7a39_838b05f54d5742e29e24ef5195382ee5~mv2.gif)

짜잔! 퐁 리플렉션 모델의 스페큘러 입니다. 여기에 저번 포스트에서 공부한 림라이트와 하프\-램버트를 더해줍시다.

![](/assets/images/wix/3628652afa-ce7a39_15bcaf553b6d49f39236322e49a7c977~mv2.png)

![](/assets/images/wix/d56e539aa2-ce7a39_0ee42a9cbbda4d9faa8e59a0c4bb4c73~mv2.png)

피부의 질감이 살아났습니다. 다만 스페큘러가 약하게 들어가야 되는 부분까지 들어가니 특정 부분의 스페큘러를 줄여보도록합시다.

![](/assets/images/wix/4ef518a49f-ce7a39_b21119e82d3140e6812f0d038bfedc5f~mv2.png)

스페큘러를 약하게 할 부분은 0에 가깝게 칠하고, 스페큘러가 강하게 나오고 싶은 부분은 1에 가깝게 칠한 마스크용 텍스처를 작성하고 곱해주면 됩니다.

![](/assets/images/wix/fbc39158e4-ce7a39_e39a228e50bf45de98ed307ba68de430~mv2.gif)

머리카락쪽으로 카메라를 돌리면 이마에 있던 스페큘러가 약해지는 것을 볼 수 있습니다.

## **Blinn\-Phong Reflection model**

이제 다음 단계로 넘어가서 블린 아저씨가 퐁 스페큘러를 개조한 Blinn\-phong(블린\-퐁) 스페큘러를 만들어 봅시다.

![](/assets/images/wix/158f8ee1f1-ce7a39_4e942e6bbcff4d70a6a647b9a5762e9d~mv2.png)

퐁 리플렉션 모델이 나온 당시에는 리플렉션 벡터를 계산 하고 뷰 벡터와 내적하는 것은 꽤 무거운 연산이었습니다.

![](/assets/images/wix/d6ea527256-ce7a39_a8699242bb0c454fad4c952674d84e4f~mv2.png)

그래서 **블린** 아저씨가 리플렉션 벡터를 계산하는 부분을 빼버리고 단순히 뷰 벡터와 라이트 벡터를 더하면 나오는 중간 값인 **Half\-Vector(하프 벡터)**로 대체 합니다.

![](/assets/images/wix/8de363bf75-ce7a39_0ff2654685c24177879427e6b50e0274~mv2.png)

![](/assets/images/wix/8b8ed3d9f3-ce7a39_132bf7bc8aad4adcb2f3e489c93e3be4~mv2.gif)

블린\-퐁 리플렉션 모델의 장점은 가볍다는데 있습니다. 단점으로는 스페큘러가 얼굴 정면에 맺힐 때는 퐁 리플렉션 모델의 결과와 매우 흡사하지만 스페큘러가 나타나고 사라질 때, **즉 내적값이 0에 가까울 때를** 주의깊게 관찰하면 퀄리티가 좋지 못합니다.
