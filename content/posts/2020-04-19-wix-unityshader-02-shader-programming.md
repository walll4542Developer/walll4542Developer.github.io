---
title: "(UnityShader) 02 Shader Programming"
date: "2020-04-19T07:23:15.461Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "이번 포스트에서는 기본적인 프로퍼티 사용법과 텍스쳐 기능을 살펴보려 합니다. Properties프로퍼티를 만지기 전에 한번 전체 구조를 짚고 넘어갑시다. CGPROGRAM ~ ENDCG 내부 코드들을 제외하곤 전부 유니티의 자체 문법인 ShaderLab이라고 이전 포스트에서 설명을 드렸습니다. 유니티 엔"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-02-shader-programming"
original_modified: "2020-06-03T10:09:16.519Z"
image: "/assets/images/wix/ab97a8e5f1-ce7a39_a41a7da56dde4599a496b011b63c00ad~mv2.gif"
---

이번 포스트에서는 기본적인 프로퍼티 사용법과 텍스쳐 기능을 살펴보려 합니다.

![](/assets/images/wix/6a6ccb9e4a-ce7a39_58a18c2cbb254103ae7917116e510239~mv2.png)

## Properties

프로퍼티를 만지기 전에 한번 전체 구조를 짚고 넘어갑시다. CGPROGRAM \~ ENDCG 내부 코드들을 제외하곤 전부 유니티의 자체 문법인 *ShaderLab*이라고 이전 포스트에서 설명을 드렸습니다.

유니티 엔진의 ShaderLab으로 작성된 스크립트들은 각 디바이스에 맞는 쉐이더 언어로 자동 번역됩니다. 개발자 입장에서 기기 호환성을 위해 새로 코드를 짜야할 필요가 없는 엄청난 장점인 것이죠. 따라서 프로퍼티 부분은 유니티에서 Surface 쉐이더를 사용하든, Vertex&amp;Fragment 쉐이더를 사용하든 앞으로도 변할 일이 없으니 걱정하지 않으셔도 됩니다.

![](/assets/images/wix/6612221cd1-ce7a39_f6b13b123866485180140a09e002e833~mv2.png)

항상 위와 같이 필요없는 코드를 지워 깨끗하게 만들어 주는 것으로 시작을 합시다. surf 함수 내부도 깨끗이 밀어줍시다.

![](/assets/images/wix/93ec59c6b8-ce7a39_a1ef08cf257c458db543094a5281547a~mv2.png)

위와 같이 surf 함수를 작성합니다. 거듭 강조하지만 Albedo가 아니라 Emission을 사용하는 것은 **조명 연산이 없어 그림자 또한 없기 때문에** 가장 직관적으로 결과를 확인 할 수 있기 때문입니다.

![](/assets/images/wix/ab97a8e5f1-ce7a39_a41a7da56dde4599a496b011b63c00ad~mv2.gif)

SubShader 내부에서 fixed4(float4) \_Color; 로 변수 선언되고 surf 함수 내에서 Emission 된 것을 프로퍼티에서 \_Color를 받아와 연결되었습니다. 실시간으로 Hue shift를 해도 바로 적용 하는 것을 확인 할 수 있습니다.

이전 포스트에서 SurfaceOutputStandard 구조체 속의 Emission은 순수한 색이기 때문에 float3 값이라는 것을 배웠습니다만 \_Color는 엄연히 fixed4 자료형입니다. 하지만 surf 함수에서는 어떤 오류도 일어나지 않았습니다.

***ShaderLab*****에서 이러한 실수를 자체적으로 보정**해주기 때문입니다. fixed4혹은 float4 자료형float4(r,g,b,a)를 float3(r,g,b)에 넣어도 넘치는 마지막 네번째 인자 a는 무시됩니다. 하지만 이런 보정 기능은 한계가 존재합니다.

![](/assets/images/wix/4655d711f7-ce7a39_e08b32b1bcf34b42bf65309c41750abe~mv2.png)

예를들어 \_Color가 float2일때 float3에 넣으려고 한다면 어떻게 될까요?

![](/assets/images/wix/c49dddcf5b-ce7a39_5c037977a93243da8c4a988135424bd1~mv2.png)

위 처럼 오류가 나는데, 해석하자면 half3 자료형에 float2를 변환하여 넣을 수 없다고 오류메시지가 나옵니다. 따라서 원칙적으로는 항상 대입할 자료형의 크기를 맞춰줘야 하는 것이죠.

이제 다른방식으로 응용을 해봅시다. 위의 GIF 움짤 처럼 컬러바를 세개를 만들어 RGB채널을 각각 조절하고 싶다면 프로퍼티를 어떻게 구성해야 할까요?

![](/assets/images/wix/90557f6aba-ce7a39_7fa572dab2ea4a2eb8a93aca0e21aff4~mv2.png)

![](/assets/images/wix/c72f3df51d-ce7a39_bcea3a060e33467ba7a778adfdb397cc~mv2.gif)

R,G,B 채널을 각각 프로퍼티로 선언하고 변수로도 선언하며 surf 함수 내에서 R,G,B를 float3으로 합쳐주면 됩니다.

우리는 더 나아가서 여기에 색이 얼마나 밝거나 어두운지를 조절하는 인자를 추가해 볼 것입니다.

![](/assets/images/wix/22e2b7db0b-ce7a39_4803d3b51cf04e7681999605f0fc3257~mv2.png)

이렇게 단순히 \+1과 \-1 사이 값을 가진 프로퍼티를 추가해주면 됩니다. 이유를 설명하려면 '밝기' 개념에 대해 명확하게 정의 할 필요가 있습니다.

URP Shader Gragh 포스트를 정독하신 여러분이라면 **가산 혼합**에서 밝기 라는 것은 결국 R,G,B 채널의 값이 얼마나 크고 작은지에 따라 결정 된다는 점을 이미 배웠습니다. 다만 엔진과 모니터에서 표현될 수 있는 색은 최저 float3(0,0,0) \~ float3(1,1,1)이 한계입니다.

![](/assets/images/wix/2c94e7ec50-ce7a39_cdd8c461cc904ee2b6d596f57edac2e3~mv2.gif)

위의 자료를 보시면 쉽게 이해 할 수 있습니다. Brightness가 1일때, 데이터 상으로는 float3(1.62,1.25,2.0) 이 되버리는 것이죠. (반대로 \-1이라면 음수의 색이 나오는데 검은색 입니다) 하지만 눈으로 보는 결과는 float3(1,1,1)과 똑같습니다.

**눈에 보이는 색은 똑같더라도 데이터상으로는 다른 색**이라는 점을 이해하셔야 다음 단계로 진행 할 수 있습니다.

## Texture2D

이번에는 오브젝트에 텍스쳐를 입혀주는 쉐이더를 작성 하겠습니다.

![](/assets/images/wix/8643ce1b35-ce7a39_3e554e18bb554ce3be8b0771225d4a8b~mv2.png)

보통 텍스쳐 변수의 이름은 \_MainTex라고 명명합니다. 다른 쉐이더 작성자들과의 일종의 약속 이기 때문이죠. 이렇게 해두면 코드를 뜯어볼 때 서로 알아보기도 쉬우며, 다른 쉐이더로 교체하더라도 텍스쳐 데이터가 그대로 살아있기 때문입니다.

텍스쳐는 프로퍼티에서 **2D** 라고 합니다. 변수 선언 부분을 보면 또 다릅니다. **sampler2D**라는 자료형으로 받아오는 것을 볼 수 있습니다. 그럼 샘플러2D 자료형은 몇자리 벡터일까요? 사실 정해진 값이 없습니다. sampler2D는 오로지 텍스처의 픽셀 정보만을 가지고 있는 것입니다.

모든 텍스쳐는 3D 오브젝트에 입혀지려면 따로 UV데이터가 필요하기 때문입니다. 그래서 Input 구조체 부분에서 float2 uv\_Maintex; 라고 선언해주는 부분이 있습니다. 이로서 float2로 UV 데이터를 만들어줍니다.

```hlsl
void surf (Input IN, inout SurfaceOutputStandard o)
        {
 float4 c = tex2D(_MainTex , IN.uv_MainTex);

            o.Emission = c.rgb;
        }
 ENDCG
```





이제 surf 함수 내부를 들여다봅시다. 샘플러2D를 RGBA 채널이 다 들어있는 float4 c로 받는 부분입니다. tex2D()를 통해 오브젝트에 입힐 텍스처의 이름과 UV 데이터를 가져와야 하는데 마침표 ' **.** ' 를 이용해 Input 구조체 속에 선언한 UV를 가져올 수 있습니다.

![](/assets/images/wix/f86da0fb74-ce7a39_11130c81aebb43478c4ab59d399479fb~mv2.png)

프로퍼티를 설정 해주었기 때문에 인스펙터 창에서 텍스쳐 이미지를 드래그 앤 드랍으로 손 쉽게 교체 할 수 있습니다. 여기까지 왔으면 텍스처의 색도 한 번 바꿔보고 싶습니다. 예를 들어 채도를 뺀 흑백으로 바꿔봅시다.

![](/assets/images/wix/d5f511e2ff-ce7a39_e380786d0b7e48caa2c64caa70a5c1b0~mv2.png)

항상 색이 **가산 혼합**이라는 점을 명심한다면 답은 간단합니다. **'흑백'**이라는 것은 R,G,B 채널의 값에 **차이가 없다**는 것입니다.

```hlsl
o.Emission = (c.r + c.g + c.b)/3;
```





RGB 채널을 모두 더해서 3으로 나눠 평균을 냅시다.

![](/assets/images/wix/7bbeaa6670-ce7a39_5a0ff3775e064574b6249fa52a391d62~mv2.png)

성공적으로 흑백이 되었습니다. 그런데 채도가 있는 컬러 텍스쳐와 흑백 사이를 프로퍼티에서 전환 가능하게 만들 수 는 없을까요?

![](/assets/images/wix/44d87cb27d-ce7a39_ed18d4d7285046dda41d113c164e7916~mv2.png)

![](/assets/images/wix/ba8c12ba22-ce7a39_caff38d8a21540aea2326a4647a4ef1e~mv2.gif)

## Linear interpolation

자연스럽게 섞으려면(Blend) 선형 보간 함수(**L**inear Int**erp**olation)에 대해 알아야 합니다. 선형 보간의 가장 일반적인 시각적 형태는 그라데이션 입니다.

lerp 함수는 ***lerp(A,B,C)***의 형태로 사용하며 A와 B의 자료형이 같아야 하고, C의 자료형은 float1 고정입니다. [URP Shader Graph 포스트 링크](</posts/wix-unityshader-06-urp-shader-graph/>)를 보시면 자세한 설명이 있습니다.

이제 좀 더 욕심을 내서 선형 보간 함수를 이용해 텍스쳐 두개를 한 오브젝트에 혼합 해봅시다.

![](/assets/images/wix/9bbbd14e81-ce7a39_b621a4ad099340a68b16deba6c12e808~mv2.png)

![](/assets/images/wix/6196ed2fc0-ce7a39_8cd101599b9e4ab4b013a3d3f04456e9~mv2.gif)

간단합니다. 두번쨰로 받는 텍스처의 프로퍼티, 구조체, 변수 선언, surf 함수 내부 모두를 복제한 뒤 변수명만 다르게 해주면 됩니다. 이렇게 텍스쳐를 하나 더 받고 lerp 함수를 사용하면 자연스레 블렌딩 됩니다.

그렇다면 설마, 알파 채널을 가진 텍스쳐의 투명한 부분만 오려서 얹어주고 싶다면?

![](/assets/images/wix/f5c64dd13d-ce7a39_e036b120ac934041b9d732319e2397e4~mv2.png)

![](/assets/images/wix/246326de73-ce7a39_614f5fdf83b34b26907f4b2f6089918b~mv2.png)

![](/assets/images/wix/23cb831216-ce7a39_a18905f1f86d45418e86d7d9f3960a09~mv2.png)

알파 채널은 완전한 흑백(grayscale)인) float1이니까 lerp 함수의 세번째 인자에 d.a **알파채널을** 넣어도 정상 작동합니다.

알파 채널의 검은 부분은 0이고 흰색 부분은 1입니다. 따라서 lerp에 집어 넣으면 0에 가까울수록 투명해지는 것이지요.
