---
title: "(UnityShader) 11 URP Shader Graph"
date: "2020-01-31T10:12:23.545Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Toon shader이번 포스트에서는 유니티 쉐이더 그래프로 게임 <젤다의 전설 : 야생의 숨결> 처럼 간단한 툰 쉐이더(혹은 Cel shading)의 원리를 파악 해볼 것입니다.먼저 하프램버트 공식으로 0~1 사이 값의 기본적인 명암을 만들어줍니다. 다음은 부드러운 그라데이션을 여러 단계로 끊어지도록 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-11-urp-shader-graph"
original_modified: "2020-02-23T18:55:11.136Z"
image: "/assets/images/wix/5655822d91-ce7a39_cb6cce7d3f63472581e7205eb452a38b~mv2.png"
---

## **Toon shader**

![](/assets/images/wix/5655822d91-ce7a39_cb6cce7d3f63472581e7205eb452a38b~mv2.png)

이번 포스트에서는 유니티 쉐이더 그래프로 게임 &lt;젤다의 전설 : 야생의 숨결&gt; 처럼 간단한 툰 쉐이더(혹은 Cel shading)의 원리를 파악 해볼 것입니다.

![](/assets/images/wix/77783f5923-ce7a39_2ecfa61c1b1c43928e5c8ee4a279e6c8~mv2.png)

먼저 하프램버트 공식으로 0\~1 사이 값의 기본적인 명암을 만들어줍니다.

다음은 부드러운 그라데이션을 여러 단계로 끊어지도록 단계를 나눠줘야합니다. 여러가지 방식이 있지만 먼저 새로운 함수들을 소개드리면서 천천히 알아보도록 합시다.

![](/assets/images/wix/4afb10a810-ce7a39_e9d78b07f3ba4c88bd5c9e86ce72cd63~mv2.png)

![](/assets/images/wix/b4d3c485ab-ce7a39_4553fc9f0e614eb887eb319b72c9ede2~mv2.png)

**Step 함수**를 사용하여 0.5 이상의 값은 1으로 반환하고 0.5 미만의 값은 0으로 반환한 뒤 원 마이너스 함수로 값을 반전 하였습니다.

![](/assets/images/wix/bdbace333f-ce7a39_a6edae284b2849e0aed4ee4ec39577f1~mv2.png)

![](/assets/images/wix/c6cf5d56c5-ce7a39_9054a986b04a40d186beac7448b319c3~mv2.png)

위와 같이 반전하고 임의의 색을 곱해줘서 그림자의 색을 바꿔 줄 수도 있습니다.

현재는 명암이 검은색 아니면 흰색의 1단계 뿐입니다. 여러개의 단계를 가지려면 어떻게 해야 할까요?

예를들어 명암을 5단계 정도로 늘려봅시다. 방법은 단순하게 5를 곱해버리면 됩니다.

![](/assets/images/wix/3f944b2c0f-ce7a39_aa455ff7b52347fabf4c6c8623950872~mv2.png)

이해를 돕기 위해 만든 y축이 색이고 x축이 색인 그라디언트 그래프입니다. 저번 포스트중 제곱 연산에 대해 다뤘을 때에도 같은 그래프였습니다. 0\~1 그라디언트에 5를 곱하면 색의 범위가 다섯배 늘어납니다.

표현하고자 한 만큼 색의 범위를 늘렸으니 이제는 단계를 나눠봅시다. 세가지의 방법이 있습니다. **내림, 올림, 반올림** 입니다.

![](/assets/images/wix/cc51b5319c-ce7a39_09325e9dbbb74c51bb14c791eedd6219~mv2.png)

**floor 함수는 내림**이며, 0.999…까지는 0의 값으로 내립니다. 1.999… 역시 1으로 내립니다. 1보다 작으면 무조건 0으로 반환합니다. 근본적으로 소수점 이하를 버리는 것과 같습니다. floor(1.x) = 1.x \- 0.x

![](/assets/images/wix/b66bea49a6-ce7a39_3280a451177540b3a687e8ea8e59927b~mv2.png)

**ceil 함수는 올림**이며, 0을 1의 값으로 올립니다. 0.001 역시 1으로 올립니다.

1보다 작으면 무조건 1으로 반환합니다. 근본적으로 1을 더하고 소수점 이하를 버리는 것과 같습니다. ceil(1.x) = 1.x \+ 1 \- 0.x

![](/assets/images/wix/a8c3cf1af7-ce7a39_a071faeeebde402bae527ebaf35343b4~mv2.png)

**round 함수는 반올림**이며, 0.5 이상의 값은 1이고 0.5 미만의 값은 0입니다.

![](/assets/images/wix/e984156851-ce7a39_c6af8b283258437fb1474fc55efa4f9a~mv2.png)

내림, 올림, 반올림 이후 5를 곱해줬던 것을 다시 5로 나눠주면(혹은 0.2를 곱하는 것도 똑같겠죠?) 0\~1 사이의 계단 형태 그래프가 결과로 나옵니다.

![](/assets/images/wix/0f8474852f-ce7a39_2a1275fe114c4cae881f18017b0f2241~mv2.png)

하지만 결과물은 영 만족스럽지 못합니다. 좀 더 여러 요소들을 추가해봅시다.

![](/assets/images/wix/27d2f4db97-ce7a39_be406eeeab924105b29987957eae90d1~mv2.png)

![](/assets/images/wix/bd8555f913-ce7a39_c22a06b4ce45402b9b2af5596c22c2f4~mv2.gif)

하프램버트 \* 툰 쉐이더 \+ 스페큘러 입니다. 탄젠트 노말을 월드 노말으로 사용해서 질감을 더했고 스페큘러도 step 함수로 (1,1,1) 흰색만 나오도록 변경하였습니다.

이번에는 기존에 배웠던 지식을 응용하여 가장 쉬운 방식의 외곽선을 추가해보도록 합시다.

![](/assets/images/wix/cfa3d9c7ae-ce7a39_c8a45fff46b74464abb1d6066c7fdd7d~mv2.png)

![](/assets/images/wix/4a4f0ecba5-ce7a39_06f8f3d2f34545348aba009b02bdf46a~mv2.gif)

림 라이트 공식을 응용하면 조금 부정확하지만 외곽선을 그려줄 수 있습니다.

![](/assets/images/wix/2917ad785a-ce7a39_a748267ef1454218969eacd3c451157a~mv2.png)

구 형태의 부드러운 표면에서는 step 함수로 잘라주면 외곽선이 되지만 각진 표면을 가진 하드섭 모델링의 경우 매우 이상해집니다.

![](/assets/images/wix/9ced2af3bc-ce7a39_0801845415354f828a0d5f849f85c509~mv2.png)

![](/assets/images/wix/290a1c2422-ce7a39_9d66326e3e4a4f9d8e80c9632eeb8612~mv2.png)

당연히 테두리 색을 바꿔주는 것도 가능합니다.
