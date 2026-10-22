---
title: "(UnityShader) 13 URP Shader Graph"
date: "2020-02-05T15:30:59.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Vertex PositionVertex position이란 오브젝트를 이루는 정점의 위치 값을 말 하는 것입니다.렌더링 파이프라인에 따르면 저 위의 포지션 / 탄젠트 / 노말은 픽셀 쉐이더의 이전 단계인 버텍스 쉐이더로 동작합니다.노드 옆의 입력 가능 데이터를 보니 Object space 를 넣어달라고 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-13-urp-shader-graph"
original_modified: "2020-05-27T10:55:40.420Z"
image: "/assets/images/wix/dd91e9a016-ce7a39_0e5ae99f3eaf4ae9963c809ea3e129eb~mv2.gif"
---

## Vertex Position

Vertex position이란 오브젝트를 이루는 정점의 위치 값을 말 하는 것입니다.

렌더링 파이프라인에 따르면 저 위의 포지션 / 탄젠트 / 노말은 픽셀 쉐이더의 이전 단계인 버텍스 쉐이더로 동작합니다.

![](/assets/images/wix/916ccd9254-ce7a39_c1532ec0bec24852b77ebf05df2e0f70~mv2.png)

노드 옆의 입력 가능 데이터를 보니 Object space 를 넣어달라고 적혀 있습니다.

![](/assets/images/wix/9bf2a10c50-ce7a39_a167694a3de24371ae9d32264b06cc0f~mv2.png)

![](/assets/images/wix/dd91e9a016-ce7a39_0e5ae99f3eaf4ae9963c809ea3e129eb~mv2.gif)

그렇기 때문에 버텍스 포지션을 변경하려면 같은 Position 노드를 사용합니다. 위의 경우 World position 값을 컬러로 출력한 결과입니다.

피벗의 중심이 월드의 (0,0,0) 이기 때문에 오브젝트의 좌표를 움직이면 색이 변하는 것을 관찰할 수 있습니다.

Object position 값을 컬러로 출력하면 피벗이 오브젝트의 중심이기 때문에 아무리 움직여도 변화가 없습니다.

![](/assets/images/wix/791fb551b4-ce7a39_ab453500e9dd47028e2cbcb2fe372105~mv2.png)

그렇다면 임의의 숫자를 추가하여 봅시다. 예를 들어 G 채널(y 좌표)에 1을 더해봅시다.

![](/assets/images/wix/e0a576922e-ce7a39_330fa4957cf64a5599b1109a9b703b89~mv2.png)

y 축으로 모든 버텍스가 1미터 만큼 움직인 모습입니다.

![](/assets/images/wix/ace75b1a04-ce7a39_c1f758f6be06460f98afbc29c28d0963~mv2.png)

![](/assets/images/wix/2682064102-ce7a39_23f7a2c40b7340818663d17d423d89c8~mv2.gif)

Time 과 sine 함수를 이용해 y축을 위아래로 1미터 왕복운동으로 움직이도록 노드를 짰습니다.

버텍스 컬러를 사용해서 원하는 부분의 버텍스만 움직이도록 응용해봅시다.

![](/assets/images/wix/60ff9aead6-ce7a39_3cbe06de1e1b44beb15ed1339626f03b~mv2.png)

버텍스 컬러의 빨강색을 칠한 부분만 움직이도록 머리에 칠해봅시다.

색의 수치에 따라 움직임의 세기가 달라지게 하기 위해서 R채널 값을 1보다 낮은색으로도 칠합시다.

![](/assets/images/wix/c966d2fb9e-ce7a39_53bdc4a4074846bfa8a57c051f15a894~mv2.png)

위와 같이 lerp 함수를 사용해서 원래 오브젝트 포지션 값과 움직이는 오브젝트 포지션 값을 선형 보간 합니다.

![](/assets/images/wix/5abe47b214-ce7a39_4e6ff2dadf9a48709bc340b26dbf806d~mv2.gif)

R채널의 수치에 따라 버텍스의 움직이는 세기이 다릅니다. 그렇다면 다른 방향으로 버텍스가 움직이게 해봅시다. 예를들어 노말 방향으로 움직이게 하는 것은 어떨까요?

![](/assets/images/wix/59563686b8-ce7a39_6979b7d64f124ed99b065e0ebf685c8f~mv2.png)

하프 램버트로 사인 타임 그래프를 수직\-수평 이동 시켜서 0\~1으로 제한하고 그 값을 노말 벡터와 곱해줍니다.

이 값을 포지션에 더해주면 노말 벡터 방향으로 버텍스가 움직입니다.

![](/assets/images/wix/cb163c5052-ce7a39_e492c42bac974443a9fc6b78b250be54~mv2.gif)

노말 방향으로 움직이게 했더니 완전 호빵맨 처럼 부풀어버립니다. 수치가 너무 크기 때문입니다. 0.2 정도를 곱해서 움직임을 줄여줍시다.

![](/assets/images/wix/6791a5a52e-ce7a39_a0f9f2ce50b44420aa8746f548637b34~mv2.png)

버텍스 컬러로 원하는 부분만 노말 방향으로 버텍스가 움직이게끔 노드를 작성했습니다.

![](/assets/images/wix/3f774998fe-ce7a39_2efe36857238457d934cede8e7d0b7f6~mv2.gif)

잘 작동합니다.
