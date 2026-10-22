---
title: "(UnityShader) 09 URP Shader Graph"
date: "2020-01-23T07:45:12.649Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: " Rim light지난 포스트에서 우리는 디렉셔널 라이트 조명이 완전히 벡터와 같다는 걸 배웠습니다. 그렇다면 벡터3라면 무엇이든 조명 대신으로 사용 할 수 있을 것입니다.예를 들어 카메라의 View Direction(벡터3)를 조명으로 사용해보도록 합시다.📷뷰 디렉션(View Direction)노드를 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-09-urp-shader-graph"
original_modified: "2020-02-23T18:55:20.085Z"
image: "/assets/images/wix/20c94e2172-ce7a39_7c0bfd7f4b3042a98ef3f949cc64fa70~mv2.png"
---

## **Rim light**

![](/assets/images/wix/77b6db79c2-ce7a39_5de9eb5c9e5a4a46a8ceec01cfe96aab~mv2.png)

지난 포스트에서 우리는 디렉셔널 라이트 조명이 완전히 벡터와 같다는 걸 배웠습니다. 그렇다면 벡터3라면 무엇이든 조명 대신으로 사용 할 수 있을 것입니다.

예를 들어 카메라의 View Direction(벡터3)를 조명으로 사용해보도록 합시다.

📷

뷰 디렉션(View Direction)노드를 꺼내봅시다. 참고로 URP에서는 뷰 디렉션이 정규화가 되어 있지 않기 때문에 노말라이즈 시켜줘야 합니다.

([https://chulin28ho.tistory.com/569?category=822622](<https://chulin28ho.tistory.com/569?category=822622>))

📷

📷

월드 노말 벡터와 뷰 벡터를 내적 연산(NdotV) 하면 위와 같은 결과물을 얻게 됩니다. 메인 카메라의 방향을 빛으로 쓰기 때문에 카메라 벡터와 수직인 표면은 0이고 마주보면 1의 값을 갖게 되는 것입니다. 그리고 빛이 닿지 않는 뒷면은 음수의 내적 값이 나옵니다.

📷

📷

음수 부분을 없애기 위해 Saturate 노드로 전체 값을 0과 1사이로 자릅니다. 그리고 one minus 노드로 값을 반전 하면 반대의 결과가 나옵니다.

![](/assets/images/wix/53840c9ab7-ce7a39_a172052d743040bc91afadd98e75a4ac~mv2.png)

이전 포스트에서 우리는 제곱 연산에 대해 공부했었습니다. 제곱을 통해 어두운 부분을 확장시켜준다면?

📷

📷

짜잔! 림라이트가 나왔습니다. 하지만 결과물을 보면 정확한 의미의 역광은 아닙니다. 눈코입 주변에 생겨서는 안되는 림라이트가 존재합니다.

잘못된 림라이트를 없애주고 싶다면 버텍스 페인트를 칠한 부분에 림라이트가 생기지 않도록 노드를 짜면 됩니다. 이번 포스트에서는 현 상태로 계속 진행 하도록 하겠습니다.

📷

이전 포스트에서 배웠던 노말 벡터와 라이트 벡터의 내적 연산(NdotL)을 통해 구한 램버트 모델과 디퓨즈 텍스처를 곱합니다.

그리고 림라이트를 더해줍니다. 더하는 과정에서 1이 넘는 값이 생기기 때문에 saturate 노드로 0\~1 사이로 잘라줍니다.

📷

림라이트는 사실 프레넬 리플렉션때문에 생기는 빛이기 때문에 림라이트의 색에 스카이박스의 앰비언트 컬러를 곱해주는식으로 처리를 할 수 도 있습니다.

림라이트의 세기를 조정하는 프로퍼티를 만들거나 전체 결과값에 라이트 컬러를 곱해줄 수도 있습니다.

![](/assets/images/wix/4afe0bbde3-ce7a39_0bb39eb9f250457c94093577a2613209~mv2.png)

지금까지는 월드 노말에 내적연산을 해왔지만 모델 데이터에 노말맵이 있다면 Transform 노드를 이용해 월드 노말으로 변형하여 사용할 수 있습니다.

![](/assets/images/wix/20c94e2172-ce7a39_7c0bfd7f4b3042a98ef3f949cc64fa70~mv2.png)

NdotV 데이터를 그대로 알파맵으로 사용하고 임의의 색을 곱하면 위와 같은 결과를 얻을 수도 있습니다.

위 데이터를 삼각함수와 타임으로 프레넬 이펙트로 만들어 줄 수도 있습니다. 그 부분은 따로 삼각함수를 다루는 부록으로 정리하도록 하겠습니다.

![](/assets/images/wix/0b4995fec9-ce7a39_acf81dd075084af08d0ab0fda4a2fce2~mv2.png)

![](/assets/images/wix/79e96c3f54-ce7a39_5c9c4f8fa5824a228ad723a4687ef47a~mv2.png)

NdotV는 정말 수많은 응용이 있습니다. 예를 들어 Blend를 Additive로 처리하면 검은색은 투명으로 처리를 합니다. 반투명 보호막 같은 느낌을 내기에 좋습니다.

![](/assets/images/wix/4ab05de932-ce7a39_d15013e7f70846ff84100191491184c8~mv2.gif)

값을 반전한다면 유사 볼류메트릭 처럼 사용할 수 있습니다.
