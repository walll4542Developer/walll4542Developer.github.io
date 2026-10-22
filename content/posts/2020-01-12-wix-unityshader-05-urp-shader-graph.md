---
title: "(UnityShader) 05 URP UV Texture Coordinate"
date: "2020-01-12T09:17:38.865Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: " 지난번 포스트에서 색이 곧 숫자고 숫자가 곧 색이라는 것을 직접 노드를 연결하면서 배웠습니다.그렇다면 0.5 회색 텍스처와 숫자 0.5를 더한 것의 결과값이 똑같아야 합니다....어째서 둘의 결과가 다른 걸까요?이미지가 sRGB 공간으로 설정되어 있기 때문에 그렇습니다. 체크박스를 풀어주면 정상적으로 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-05-urp-shader-graph"
original_modified: "2020-01-12T09:18:26.131Z"
image: "/assets/images/wix/0376fb154e-ce7a39_e054f29a2efc4d42860c1daba14bf64a~mv2.gif"
---

지난번 포스트에서 색이 곧 숫자고 숫자가 곧 색이라는 것을 직접 노드를 연결하면서 배웠습니다.

그렇다면 0.5 회색 텍스처와 숫자 0.5를 더한 것의 결과값이 똑같아야 합니다.

![](/assets/images/wix/8c9784f4ce-ce7a39_4efde5fd79954ec5a2272b092143d7c2~mv2.png)

...어째서 둘의 결과가 다른 걸까요?

![](/assets/images/wix/fc8a3bd410-ce7a39_09d4591be6394acb9bafe13a15252f85~mv2.png)

![](/assets/images/wix/56b0022ff6-ce7a39_c38f8cbd1cb8481b9d7733ee146a2378~mv2.png)

이미지가 sRGB 공간으로 설정되어 있기 때문에 그렇습니다. 체크박스를 풀어주면 정상적으로 결과값이 나옵니다. 이제 0.5 회색 대신에 아래와 같은 텍스쳐를 넣어서 응용하여 봅시다.

![](/assets/images/wix/cf7fe184f8-ce7a39_968e9bacb4d0430e98e54972968f394b~mv2.png)

![](/assets/images/wix/b268621846-ce7a39_cbdb28c15e894a689bdfe6b0924ba401~mv2.png)

정확한 결과 값을 얻기 위하여 임포트한 텍스처는 압축을 None으로 설정하여 압축을 풀어줍니다.

![](/assets/images/wix/0f01a1b50f-ce7a39_1a92c4c45a04487a9202cfa6de0ef84a~mv2.png)

체커 텍스쳐의 중앙 부분만 왼쪽 아래로 일그러진 것을 확인 할 수 있습니다.

![](/assets/images/wix/621ffa7e63-ce7a39_8db4c37453394779b36f3c3926ad617f~mv2.gif)

이전 포스트에서 배웠던 Time 노드를 추가하여 움직이게 했더니 엄청나게 구겨집니다.

![](/assets/images/wix/a10e75e7ab-ce7a39_4fc28333fb9944a3a5f961b8d7090d60~mv2.gif)

텍스처 결과 값에 0.1을 곱하여 텍스쳐의 색 대비를 줄여 주면 구겨지는 것을 줄일 수 있습니다. 이걸 이용하여 타오르는 불꽃 이미지를 쉐이더로 만들어 볼 것입니다.

![](/assets/images/wix/f91eec8877-ce7a39_6c2d7fa8d99b4032896f520605681127~mv2.png)

알파 채널이 존재하는 불꽃 이미지를 준비하고 위와 같이 연결해 줍니다.

![](/assets/images/wix/1049a674d3-ce7a39_b1550c028df441b98700859ab2e26cfc~mv2.png)

![](/assets/images/wix/664c8ea05c-ce7a39_db7b26908264465c9b625a4368305eae~mv2.png)

(머임??)

![](/assets/images/wix/536e2c6d77-ce7a39_374b2484a1b44b71b341840cc6b0b298~mv2.png)

마스터 노드에서 이미지가 불투명(Opaque)로 되어있어서 그렇습니다. 투명(Transparent)로 바꿔주고 0.5가 디폴트로 되어있는 AlphaClipThreshold 값을 0으로 바꿔줍니다.

AlphaClipThreshold는 정해진 값 이상부터 선형 보간을 해주기 때문에 이 수치를 0으로 해주면 알파 맵이 부드럽게 나옵니다.

![](/assets/images/wix/5ecb257d95-ce7a39_2bf000584ca14918ba95b8b3cf9b0511~mv2.png)

![](/assets/images/wix/5e3d5eead5-ce7a39_a8dad55da0d941d2972dd14f17ab5762~mv2.png)

불꽃이 겹칠수록 빛이 나는 성질을 살리고, 불꽃의 뒤쪽 배경이 보여야 하기 때문에 blend 모드를 Addtive로 바꾸고 two side를 켜줍니다.

![](/assets/images/wix/68d00b875b-ce7a39_944ab788bf3d41b88928df7ab8ae4bce~mv2.png)

Addtive 모드가 알파 채널을 인식하지 않기 때문에 알파 채널과 기존 텍스처를 곱해서 검은색으로 만들어주면 됩니다.

![](/assets/images/wix/0376fb154e-ce7a39_e054f29a2efc4d42860c1daba14bf64a~mv2.gif)

UV가 위로 흐르도록 노드를 작성하고 연결해주면 타오르는 불꽃 완성입니다.
