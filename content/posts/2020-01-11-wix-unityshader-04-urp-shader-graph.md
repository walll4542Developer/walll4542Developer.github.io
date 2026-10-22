---
title: "(UnityShader) 04 URP UV Texture Coordinate"
date: "2020-01-11T10:33:03.917Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "이번 포스트에서는 UV, Texture Coordinate (텍스쳐 좌표계)에 대해 알아봅시다.지난시간에 사용했던 PRB 쉐이더 그래프를 열어봅시다.스페이스바나 우클릭 - Creat node로 위의 창을 열고 Master를 클릭합니다.잠깐, 마스터 노드 안에 언릿이 있습니다.눌렀더니 언릿 마스터 노드가 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-04-urp-shader-graph"
original_modified: "2020-01-12T05:09:19.351Z"
image: "/assets/images/wix/1b7a23e433-ce7a39_5ff4a2e2ad9f4d50b5cb6cf7fb898fa3~mv2.gif"
---

![](/assets/images/wix/fa5862f64a-ce7a39_c32fcfe1e4c5495a8f01062fb4fb4155~mv2.png)

이번 포스트에서는 UV, Texture Coordinate (텍스쳐 좌표계)에 대해 알아봅시다.

지난시간에 사용했던 PRB 쉐이더 그래프를 열어봅시다.

![](/assets/images/wix/d06f1c9501-ce7a39_3d13f2686e6643ed9d4356647421d6bd~mv2.png)

스페이스바나 우클릭 \- Creat node로 위의 창을 열고 Master를 클릭합니다.

![](/assets/images/wix/bc9def15a1-ce7a39_a871dafcbb8640c49625f90b2722cabc~mv2.png)

잠깐, 마스터 노드 안에 언릿이 있습니다.

![](/assets/images/wix/d5a16c269b-ce7a39_3fef305f57bb4d4bb6c58fc1a914a6b5~mv2.png)

눌렀더니 언릿 마스터 노드가 생겼습니다. 즉 쉐이더 그래프 내부의 노드를 변경하지 않은 채로 결과물이 PBR이나 VFX 였던걸 Unlit으로 바꿀 수 있고 그 역도 가능하다는 것이죠.

![](/assets/images/wix/d552984b81-ce7a39_0e4a4ca24aa34927a80aa9ae6270d80f~mv2.png)

여러 마스터 노드를 꺼내두고 어떤걸 액티브 해주느냐에 따라 최종 결과물을 바꿔줄수도 있습니다.

![](/assets/images/wix/5dfa4abdf7-ce7a39_cc03c14f71b046838dd9822110c3cac5~mv2.png)

(더 이상 이렇게 만들 필요가 없어졌습니다)

![](/assets/images/wix/ef05998cd6-ce7a39_80036d7f880241f4a8e35aa4b392dcd2~mv2.png)

언릿 마스터 노드에 다음과 같이 노드를 연결합니다.

![](/assets/images/wix/5d48d9bea2-ce7a39_8562b6264db34c2b82ee8e27cecf7d8e~mv2.png)

Texture 2D Asset 노드는 텍스쳐를 프로퍼티로 만들어줍니다.

텍스처가 오브젝트에 매핑되려면 **두가지 정보가 필요**합니다.

하나는 어떤 이미지가 들어갈 것인지, 다른 하나는 어떤 위치에 들어갈 지. 즉 텍스처 데이터와 UV 데이터가 필요합니다.

UV는 버텍스가 가지고 있는 정보입니다. 3차원의 물체를 2차원으로 좌표 값을 넣어 펴주는 것이지요.

프로그래머들은 이 좌표 값을 텍스쳐 코디네이트, 줄여서 **Texcoord**라고 부릅니다.

![](/assets/images/wix/8d7e4c4d56-ce7a39_fafbb1c159ec4a7e8f8eacf0e88e6005~mv2.png)

참고로 언리얼(DirectX)와 유니티(OpenGL)은 UV의 방향이 다릅니다. 언리얼은 왼쪽 위가 (0,0) 유니티는 왼쪽 아래가 (0,0) 입니다.

이제 쉐이더 그래프에서 UV 노드를 꺼내 보도록 합시다.

![](/assets/images/wix/7e0b5a809e-ce7a39_df5473f43cc3405c880e35be6e963527~mv2.png)

UV 데이터가 초록과 빨강의 색으로 나타나 있는 것을 볼 수 있습니다. 색은 곧 숫자입니다. 즉 R과 G 채널에 뭔가 값이 들어 있다는 걸 알 수 있습니다.

![](/assets/images/wix/1e044816dd-ce7a39_a518aeb3acdf4fa190ae3cca3bf8fadb~mv2.png)

채널별로 Split 노드를 사용해서 나눠보니 흑백 그라디언트가 들어있습니다.

위에서 유니티(OpenGL)의 UV 데이터 형태를 설명했듯이 R 채널에는 왼쪽이 0 오른쪽이 1이고 G 채널에는 위쪽이 1 아래쪽이 0입니다. 각각 R채널이 U, G 채널이 V에 대응한다는 것을 알 수 있습니다.

![](/assets/images/wix/9139a1ff82-ce7a39_7729fd101ecb47469ccaa5d4650e99ac~mv2.png)

참고로 B채널과 A채널에는 데이터가 들어있지 않습니다. 유니티는 여기에 라이트맵용 UV 데이터를 따로 넣어줄 수 있습니다. 즉 한 오브젝트가 여러개의 UV를 가지는 일이 가능하다는 뜻입니다.

![](/assets/images/wix/ef03fee627-ce7a39_ccd68b037c7e4e3bbe95a1bbde847488~mv2.png)

그렇다면 UV 데이터를 다시 숫자로 생각해서 2를 곱한다면 어떻게 될까요?

UV에서 노란색 영역이 넓어졌고 텍스쳐에 2를 곱한 UV를 적용하면 텍스쳐가 2x2 로 타일링이 된 것을 확인 할 수 있습니다.

(텍스처 이미지의 속성이 Clamp냐 Repeat에 따라 다르지만 Repeat 기준으로 생각합시다)

![](/assets/images/wix/5837a92fe9-ce7a39_8480401da416474895518a4e0ebaf54f~mv2.png)

곱셈은 타일링이 됬는데 그렇다면 덧셈은 어떻게 될까요? 0.5를 더해서 얻어낸 결과물 입니다. 텍스쳐가 0.5 만큼 아래로 내려가고 0.5만큼 왼쪽으로 움직였습니다. 오프셋 이동이 일어났습니다.

![](/assets/images/wix/42237fe5e5-ce7a39_16edafad50bb4c90aae1c49a2d676200~mv2.png)

타일링 &amp; 오프셋 노드가 따로 존재합니다만 원리는 똑같습니다.

![](/assets/images/wix/59ed1f9535-ce7a39_08c4a60c51cf4a879c877464ce34d158~mv2.gif)

타임 함수를 사용해 UV에 직접 값을 더해주면 이렇게 실시간으로 오프셋이 이동 하는걸 볼 수 있습니다. U와 V 양쪽에 둘다 값이 들어 갔기 때문에 왼쪽 아래로 흐르게 됩니다.

![](/assets/images/wix/8e27c61aa8-ce7a39_a7418d241e2b4fbc9776edf313d44d6d~mv2.gif)

R채널에만 값을 집어넣는다면 당연히 U 방향으로만 텍스쳐가 오프셋 이동을 합니다.

![](/assets/images/wix/1b7a23e433-ce7a39_5ff4a2e2ad9f4d50b5cb6cf7fb898fa3~mv2.gif)

텍스쳐에 \-1 을 곱해준다면 위와 같이 방향을 반대로 바꿔줄 수 있습니다.
