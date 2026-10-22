---
title: "(UnityShader) 03 Shader Programming"
date: "2020-04-26T03:30:42.678Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "이전 포스트에서 복수의 텍스쳐를 받아 선형 보간을 통해 섞어서 출력하는 방법을 배웠습니다. 오늘은 텍스쳐의 UV 데이터에 대해서 배워 보려 합니다.UV란 3D 오브젝트에 2D 텍스쳐를 입히기 위해 오브젝트를 2D 전개도로 펼쳐 놓은 것입니다. 맥스나 마야같은 모델링 프로그램을 통해 오브젝트를 엔진으로 i"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-03-shader-programming"
original_modified: "2020-06-03T10:09:58.666Z"
image: "/assets/images/wix/cfed691f91-ce7a39_e1e2222191234a059d875f13ef361ffd~mv2.gif"
---

이전 포스트에서 복수의 텍스쳐를 받아 선형 보간을 통해 섞어서 출력하는 방법을 배웠습니다. 오늘은 텍스쳐의 UV 데이터에 대해서 배워 보려 합니다.

![](/assets/images/wix/c96d1d5f43-ce7a39_d87e463e99774a8b891325624239b55e~mv2.png)

UV란 3D 오브젝트에 2D 텍스쳐를 입히기 위해 오브젝트를 2D 전개도로 펼쳐 놓은 것입니다. 맥스나 마야같은 모델링 프로그램을 통해 오브젝트를 엔진으로 import 할 때 버텍스 데이터(인덱스, 위치, 노말, 컬러, UV 등등)을 받아와서 엔진 내에서 재구성합니다.

버텍스가 2D 전개도 좌표 위에서 어디에 위치하는지에 따라 그래프의 x,y축, float2의 값을 가지게 됩니다. 이것은 디지털 가산혼합에서 색이 3개 float의 비율에 따라 정해지듯이 **UV도 0과 1사이의 비율**으로 정해집니다.

![](/assets/images/wix/8d7e4c4d56-ce7a39_fafbb1c159ec4a7e8f8eacf0e88e6005~mv2.png)

이렇게 하면 텍스쳐와 오브젝트의 사이즈에 상관없이 UV는 일정하다는 장점이 있습니다. 픽셀 하나하나 마다 대응하는 float2(U,V) 값은 변동하지 않는다는 것 입니다.

(이처럼 UV는 비율이라서 픽셀로 표현하기에 애매한 값들이 생기는데, 이런 데이터를 처리하는 방식이 몇가지 있습니다. 이것을 **'필터링'** 이라고 하며 나중에 다루도록 하겠습니다)

위 자료에서 DirectX와 OpenGL의 UV 기준점이 다르다는 것을 볼 수 있습니다. 유니티의 경우 OpenGL 방식을 따르기 때문에 왼쪽 아래 기준 (0,0) 입니다.

그렇다면 UV 데이터는 0\~1 사이의 값인데 1 이상의 값을 넣으면 어떻게 처리할까요? 한번 직접 해봅시다.

![](/assets/images/wix/fce630d079-ce7a39_d060eedf3a854d19b96b7533790b9e94~mv2.png)

```hlsl
float4 c = tex2D(_MainTex , IN.uv_MainTex * 2);
```





이제 코드에서 필요없는 부분은 다 지운다는 말은 생략하겠습니다. 코드에서 UV 데이터는 uv\_MainTex 이며 여기에 \*2를 하게 되면 UV 크기가 제곱으로 확장되는 것과 같습니다. 좌표 (0,0) 에는 당연히 어떤 수를 곱해도 그대로이며 좌표(1,1)는 (2,2)가 됩니다.

![](/assets/images/wix/9546ee2451-ce7a39_d4363f7178a24c05962be801d08eea9c~mv2.png)

결과는 2\*2 타일링이 되었습니다. (1,1)을 초과하는 UV 데이터는 다시 (0,0)으로 반복되었습니다.

![](/assets/images/wix/982e027ce2-ce7a39_f1369cfe835a4426b25380edf7557137~mv2.png)

타일링 되지 않게 할 수도 있습니다. 텍스쳐의 Warp Mode가 Repeat로 되어있어서 반복되는 것입니다.

![](/assets/images/wix/68983bccc4-ce7a39_9562bb8c225d43eba0ee76206e9c6f94~mv2.png)

Wrap Mode를 Clamp로 설정해주면 위와 같이 하나만 나옵니다. 텍스쳐의 가장 바깥쪽에 있는 픽셀을 쭉 늘려버린 것으로 나머지 부분을 채우는 것입니다.

![](/assets/images/wix/afa8b4df43-ce7a39_b9db5435dee049c9979cd6fb930fff7d~mv2.png)

![](/assets/images/wix/2624fb1ceb-ce7a39_fd90b50b817342f38dc225e0b44bed3e~mv2.gif)

곱셈 부분을 아예 변수로 적용해서 타일링 해봤습니다. 그렇다면 가로나 세로축 한쪽에만 타일링이 되게 하고 싶다면 어떻게 해야될까요?

![](/assets/images/wix/1a26b969ad-ce7a39_a4280225f2e0432cb32f2b772fa1561c~mv2.png)

![](/assets/images/wix/c21d3db733-ce7a39_4d47352f6a84440e9eedc07ba93bb39d~mv2.gif)

답은 간단합니다. 비록 IN.uv\_MainTex 라고 써있지만 사실 uv 데이터는 float2기 때문에 float2(\_u,\_v) 를 곱해주면 가로 세로 축을 따로 조절할 수 있는 겁니다.

![](/assets/images/wix/a5579f3914-ce7a39_bffd061ef3da44e686d2b26d088df097~mv2.png)

그렇다면 곱셈이 아니라 덧셈이라면 어떻게 될까요?

![](/assets/images/wix/59a553ebf9-ce7a39_8b046cd08351422d9c07b92e466e02cd~mv2.gif)

곱셈은 (0,0) 부분에 영향을 주지 못하지만 덧셈은 다릅니다. 따라서 텍스쳐 전체가 같은 비율 그대로 움직이게 됩니다. 이것을 오프셋(Offset)이라고 합니다. 변수에 타임 함수를 더하면 영원히 임의의 방향으로 텍스쳐가 이동하게 될 것입니다.

![](/assets/images/wix/27d5be7488-ce7a39_a7eebdc729fa474aaeefca9d38dad284~mv2.png)

![](/assets/images/wix/e43d13b1be-ce7a39_19ecee8338cd40358b0163ac6d42bfbf~mv2.gif)

지금까지 배웠던 타일링, 오프셋, 들을 모두 하나로 모아서 프로퍼티로 조절 할 수 있도록 쉐이더를 작성하였습니다. UV 데이터는 float2 라고 공부했었는데 그렇다면 UV를 색과 이미지로 볼 수 있지 않을까요?

![](/assets/images/wix/afae125633-ce7a39_d2574c07d9ce447396ce82bb5bd51a8a~mv2.png)

```hlsl
o.Emission = IN.uv_MainTex.x;
```





위와 같이 UV의 U 데이터만 한번 출력해 봅시다.

![](/assets/images/wix/6a32df3c1e-ce7a39_43dd2c7fb04847f6b534b2481fbe8327~mv2.png)

0\~1의 그레이스케일 그라데이션이 나옵니다. 그렇다면 UV데이터를 Emission에 집어넣기 위해 float3로 만들어줍시다. B 채널에는 데이터가 없으니 0으로 해줍시다.

![](/assets/images/wix/4df2c58a61-ce7a39_d71ca2d4444840f98ee290af8942a42b~mv2.png)

![](/assets/images/wix/0a8037debc-ce7a39_35e3a46e362044c5a91640829da216fd~mv2.png)

이것이 바로 저희가 눈으로 보고 싶었던 UV의 모습입니다. 이제 지금 까지 배웠던 기능들을 이용해서 응용 실습을 해봅시다. 타오르는 불 쉐이더 이펙트를 만들어 볼 건데 그 전에 생각해봅시다. 이글거리는 불규칙적인 움직임을 어떻게 구현할 것인가?

![](/assets/images/wix/5868ce578a-ce7a39_8bbd5eace2fb4f46b19bd7c2ec5bccab~mv2.png)

d의 uv에 타임 함수를 더해서 오프셋 이동을 하게 만들고

c의 uv에 d를 더해주면 어떻게 움직일까요?

![](/assets/images/wix/6976168a55-ce7a39_b089fecf80c546ae8a7dc74dac7a50e4~mv2.gif)

UV의 움직임을 잘 파악할 수 있게 체크 이미지를 넣었습니다. 체크 텍스쳐의 uv에 d 텍스쳐가 더해짐으로서 일렁이는 움직임이 생겼습니다.

![](/assets/images/wix/cfed691f91-ce7a39_e1e2222191234a059d875f13ef361ffd~mv2.gif)

값이 큰 노이즈 텍스쳐를 넣으면 UV가 더욱 강력하게 왜곡됩니다. 노이즈 텍스쳐 왜곡의 세기와 흐르는 속도와 방향을 조절하는 프로퍼티를 작성 해봅시다.

![](/assets/images/wix/76f95b7a65-ce7a39_7d321c877cc445e7843173d1714371c7~mv2.png)

![](/assets/images/wix/b81a19b399-ce7a39_48b9977fcb414e44aa9d9220be826cfb~mv2.gif)

추가로 HDR 컬러가 있을 때 후처리의 Bloom을 받을 수 있게 했고 오프셋 이동 방향도 결정 할 수 있게 쉐이더를 작성 했습니다.
