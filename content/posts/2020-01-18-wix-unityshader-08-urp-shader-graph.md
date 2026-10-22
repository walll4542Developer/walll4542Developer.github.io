---
title: "(UnityShader) 08 URP Shader Graph"
date: "2020-01-18T17:55:44.243Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: " 벡터의 내적이전 포스트에서 벡터의 합과 차에 대해서 공부했었습니다. 벡터의 다른 연산으로는 내적(dot)과 외적(cross)이 있습니다. 먼저 내적에 대해 알아봅시다.내적 연산은 다음 두가지의 방식으로 값을 구할 수 있습니다.첫번째는 벡터U(x,y)의 성분과 벡터V(x,y)의 성분을 각각 곱하고 더한 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-08-urp-shader-graph"
original_modified: "2020-02-23T18:55:24.709Z"
image: "/assets/images/wix/37ebae4500-ce7a39_f939e0c7a173477fae5d45c8d6cc4c6a~mv2.png"
---

## **벡터의 내적**

이전 포스트에서 벡터의 합과 차에 대해서 공부했었습니다. 벡터의 다른 연산으로는 내적(dot)과 외적(cross)이 있습니다. 먼저 내적에 대해 알아봅시다.

내적 연산은 다음 두가지의 방식으로 값을 구할 수 있습니다.

![](/assets/images/wix/37ebae4500-ce7a39_f939e0c7a173477fae5d45c8d6cc4c6a~mv2.png)

첫번째는 벡터U(x,y)의 성분과 벡터V(x,y)의 성분을 각각 곱하고 더한 값입니다.

![](/assets/images/wix/f8423be14e-ce7a39_13e0b38a32b5402caded5436016058e5~mv2.png)

(V’는 V에 코사인 세타를 곱한 값입니다)

두번째로는 V벡터를 V(x,0)으로 분해하고(V’) U벡터의 크기와의 곱에 코사인 세타를 곱한 값과 같습니다.

V(0,y)는 내적 연산의 결과에 영향을 미치지 않기 때문입니다.

이제 이 공식을 가지고 다르게 생각해봅시다.

빛은 광자(Photon)로 이루어져있습니다. 빛 알갱이들이 물체의 표면에 부딪혀서 반사되어 우리의 눈으로 들어올 때 시신경이 물체를 감지 할 수 있는 겁니다.

![](/assets/images/wix/702b5cf3cc-ce7a39_2f1dd601e7914d69bda43d2daced80bc~mv2.png)

태양에서 세개의 광자가 나와서 폴리곤에 부딪혔다고 가정합시다. 빨간색 폴리곤은 빛에 수직이고 파란색 폴리곤은 조금 기울어졌습니다. 어떤 폴리곤이 우리 눈에 더 밝게 보일까요?

![](/assets/images/wix/47bfa0fe96-ce7a39_c29d2708ac054bdf8505902f5ab417cb~mv2.png)

정답은 빨간색입니다. 광자의 숫자는 그대로지만 광자가 부딪친 면적은 파란색이 더 넓기 때문에 파란색이 빨간색 보다 어둡습니다. 폴리곤의 기울기, 즉 각도에 따라 명암을 결정할 수 있습니다.

그렇다면 광자의 운동도 벡터로 생각하고 폴리곤 표면의 노말도 벡터로 생각한다면 어떨까요?

![](/assets/images/wix/26bec4a617-ce7a39_49d71116297041ce9166ea43a4222c29~mv2.png)

그렇습니다. 위에서 배운 공식 대로 두 벡터의 내적을 계산 할 수 있습니다.

위에서 배운 식대로 내적을 계산해봅시다. 유니티 엔진에서 노말 벡터는 단위벡터입니다. 그리고 빛 또한 단위벡터입니다. 그러니 두 벡터의 크기가 모두 1으로 고정 되어 있습니다.

![](/assets/images/wix/26ef227d1d-ce7a39_a3dcea76b52b40f1bbef845388415809~mv2.png)

내적을 계산해보면 결국 코사인 세타가 곧 내적 값이 됩니다. 달리말하면 각도에 코사인 함수를 적용한 값입니다.

![](/assets/images/wix/124026e076-ce7a39_c7eae0b5683a400cb5b3554ce5728951~mv2.png)

위와 같은 식으로 각도마다 대응하는 내적 값을 구할 수 있습니다. 1과 \-1 사이의 값이 보입니다. 저 수치를 색으로 사용하면 명암이 나올 것 같습니다. 이것을 노드로 작성해봅시다.

## **벡터의 내적 응용**

![](/assets/images/wix/d39d404f0e-ce7a39_ae3ea51c6d5849f3a5ecf25cb8e4629c~mv2.png)

먼저 노말 벡터 노드 부터 생성합시다. 노말 벡터의 공간은 ‘월드’ 좌표여야 합니다. 오브젝트의 중심을 월드 좌표로 설정하는 것입니다.

UV 노드와 색이 비슷합니다. UV 노드와 똑같이 좌표 값을 색으로 표현했기 때문입니다.

![](/assets/images/wix/6843850acd-ce7a39_981706efd90640c283855ff9d336f34e~mv2.png)

차이점은 축이 하나더 늘어났을 뿐입니다.

![](/assets/images/wix/52cfe747e6-ce7a39_949f6eb63e5146ce8a8d15a0598007bb~mv2.gif)

![](/assets/images/wix/c8d0616878-ce7a39_c1302f3e96c446899e241d5a71954b14~mv2.gif)

월드 좌표는 오브젝트를 아무리 트랜스폼 해도 변하지 않습니다.

![](/assets/images/wix/77b6db79c2-ce7a39_5de9eb5c9e5a4a46a8ceec01cfe96aab~mv2.png)

다음은 라이트 벡터입니다. URP Shader Graph 에서는 라이트 소스에 대한 노드를 제공하지 않습니다. 그래서 직접 커스텀 함수 노드를 추가하고 아래와 같이 hlsl 코드를 작성해야 합니다.

![](/assets/images/wix/86cd6f30a7-ce7a39_5c4c602b00b84ac38516049644e42435~mv2.png)

\# if SHADERGRAPH\_PREVIEW

Direction = float3(1,0,0);

Color = float3(0,1,0);

\# else

Light light = GetMainLight();

Direction = light.direction;

Color = light.color;

\# endif

![](/assets/images/wix/b829c6fa52-ce7a39_a4cc57abe6a34480a6300bb8fd38218e~mv2.png)

커스텀 함수 노드로 조명의 벡터와 조명의 컬러값을 받아옵니다.

![](/assets/images/wix/03ca319333-ce7a39_680c149d50084b53b47e12cc5a1d2537~mv2.png)

![](/assets/images/wix/36e25d163e-ce7a39_b2b27e677e894d81b0be01d454ab8264~mv2.gif)

함수가 제대로 작동하는지 라이트 벡터를 출력해봅시다.

![](/assets/images/wix/0d8e0eefbd-ce7a39_e32d247aec7e418e87bf7b9557ffce4f~mv2.png)

이제 월드 노말 벡터와 커스텀 펑션으로 받은 라이트 벡터의 내적을 구하고 컬러로 출력합니다.

![](/assets/images/wix/dbee887ff8-ce7a39_9d6223b3ab584b22b4769be3f59609d3~mv2.png)

다음과 같은 결과물이 출력됩니다. 하지만 지금 결과물에서는 검은색 부분이 0이 아닌 음수로 처리되고 있습니다. 제대로된 라이팅을 위해 0과 1사이의 값만 남겨줘야 합니다.

![](/assets/images/wix/0e940ae3c2-ce7a39_7412ed6301044af7a7bd868d4e1ccfa5~mv2.png)

Clamp 노드 혹은 Saturate 노드를 이용해 0\~1 사이의 값으로 자른 뒤 앰비언트 노드를 추가하여 스카이박스의 앰비언트 컬러를 더해줍시다.

![](/assets/images/wix/6399e78592-ce7a39_9e6fd2c6dd9b4e4bb7384096ef0fa706~mv2.gif)

앰비언트 컬러가 반영됩니다. 조명의 색도 반영 되도록 만들고 싶다면 커스텀 함수의 컬러 값으로 받아온 조명 색을 곱해주면 됩니다.

## **Half\-Lambert**

하지만 지금은 그림자가 너무 강해서 예쁘지 않습니다. 전체 면적의 절반이 0이하의 값이라서 그렇습니다. Half lambert 공식을 이용해 예쁘게 보정 해봅시다.

![](/assets/images/wix/99be63fbd2-ce7a39_0b818e3d7ce945a285e00fcd8e4e75a9~mv2.png)

먼저 음수의 색 값을 살리기 위해 Clamp 노드를 지웁니다.

![](/assets/images/wix/fec69f64ee-ce7a39_7e22c765c7d64e9f82eabff718c2a5bd~mv2.png)

![](/assets/images/wix/d0cf11ba74-ce7a39_694a5dba94b6480895eabc0e64506af0~mv2.png)

Half lambert 공식은 위와 같습니다. 색의 변화를 한 눈에 알 수 있게 그라디언트로 표현했습니다. 0.5를 곱했을 때 색 범위가 절반으로 줄어듭니다. 그다음 0.5를 더하면 0\~1 사이의 값만 남게 되는 것입니다.

이번에는 음영이 너무 약해졌으니 제곱(Power) 노드로 좀 더 보정 해봅시다.

![](/assets/images/wix/58a70e2120-ce7a39_81cfcd669d0d4ee3b38591dc566f1df9~mv2.png)

0\~1 사이의 색을 제곱 하는 것은 어떤 의미가 있을까요?

![](/assets/images/wix/53840c9ab7-ce7a39_a172052d743040bc91afadd98e75a4ac~mv2.png)

세로 축은 그라디언트의 범위고 가로축은 대응되는 색을 숫자로 나타낸 것입니다. 항등함수 *f*(*x*)=*x* 그래프와 동일합니다.

2만큼 제곱 하면 균일하게 선형으로 0부터 1까지 분포되어있는 그라디언트의 어두운 부분을 강제로 확장하는 것입니다. 반대로 1/2을 제곱하면 유리수 지수 법칙에 의해 전체 값의 제곱근만큼 증가 하니 어두운 부분을 강제로 축소 합니다.

지식이 있다면 감마 보정(Gamma Collection) 그래프와 매우 비슷하게 생겼다는 점을 눈치 챌 수 있습니다.

![](/assets/images/wix/0d113079b1-ce7a39_f142ca2a886144c5b92a91f9e5537fd2~mv2.png)

![](/assets/images/wix/3f9d54ba8d-ce7a39_8bf75e2c63554be4a8538545be57ecc6~mv2.png)

Half\-lambert 공식에 조명의 색 까지 곱해준 최종 결과물입니다.
