---
title: "(UnityShader) 12 URP Shader Graph"
date: "2020-02-03T11:37:59.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Ramp shader이번 포스트에서는 Look-Up texture를 사용하는 Ramp Shader의 한 종류인 밸브의 Warped texture 방식을 구현 해보도록 하겠습니다.Look-Up texture(룩-업 텍스쳐)란?간단한 정의로 아티스트가 미리 작성해놓은 텍스처라고 생각하시면 됩니다.이제는 너무"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-12-urp-shader-graph"
original_modified: "2020-02-23T18:55:03.654Z"
image: "/assets/images/wix/ab3e5346ae-ce7a39_b01b2f4d86ff4d06a26b427c138cabd8~mv2.gif"
---

## **Ramp shader**

이번 포스트에서는 Look\-Up texture를 사용하는 Ramp Shader의 한 종류인 밸브의 Warped texture 방식을 구현 해보도록 하겠습니다.

**Look\-Up texture(룩\-업 텍스쳐)란?**

![](/assets/images/wix/dd2807e8f7-ce7a39_bd2498d75f254f558c0417dc32babae5~mv2.png)

간단한 정의로 아티스트가 미리 작성해놓은 텍스처라고 생각하시면 됩니다.

![](/assets/images/wix/b356fc9f82-ce7a39_337cb3b3f5b2470da7dc289c65b278e0~mv2.png)

이제는 너무 봐서 익숙한 하프\-램버트로 시작합니다.

다음은 준비된 룩업텍스쳐를 쉐이더 그래프에 드래그&amp;드랍합니다.

![](/assets/images/wix/fce9d3631f-ce7a39_b5009381b2694f2783daf30e6f973e7f~mv2.png)

여기서 갑자기 퀴즈, 텍스쳐의 UV는 float2 데이터입니다. 만약 여기에 강제로 (0,0)을 넣는다면 어떤색이 나올까요?

![](/assets/images/wix/7b9e863f71-ce7a39_63a20dab7cfd450386af5b184747fb36~mv2.png)

정답은 OpenGL 방식을 따르는 유니티는 텍스쳐의 (0,0) 좌표에 있는 가장 왼쪽 아래의 짙은 빨강 색이 출력됩니다.

![](/assets/images/wix/38ac6049fb-ce7a39_c93e432850f9431baaf730f15ab2325f~mv2.png)

하지만 우리의 생각과 반대로 가장 오른쪽의 회색이 나옵니다. 우리가 뭔가 실수 한 것일까요?

![](/assets/images/wix/83afcccd08-ce7a39_ef4b2de31e294bae89da15019cb8a8e2~mv2.png)

맞습니다. 텍스쳐의 모드를 Clamp로 해줘야 합니다. 디폴트 값이 Repeat로 설정 되어 있었기 때문에 0,0 좌표가 텍스쳐를 한 바퀴 넘어가서 회색이 나오고 만 것입니다.

![](/assets/images/wix/f135b8c4a5-ce7a39_f12bb0f6d3394eb29e43262fa0fe6c71~mv2.png)

이제는 저희가 예측했던 대로 잘 나옵니다.

![](/assets/images/wix/e59a92db24-ce7a39_03837f24b50140a58d790d37f5cd614c~mv2.png)

그렇다면 하프\-램버트 데이터를 UV로 사용하면 어떻게 될까요?

![](/assets/images/wix/ab3e5346ae-ce7a39_b01b2f4d86ff4d06a26b427c138cabd8~mv2.gif)

어두운 부분은 UV값이 0,0이기 때문에 가장 어두운 빨강 색을 출력합니다.

반대로 밝은 부분은 UV값이 1,1이니 가장 밝은 회색이 출력됩니다.

즉, **빛 = UV** 로 사용하는 것입니다.

![](/assets/images/wix/71a2c4fbc1-ce7a39_380cc01e335743c0b972f4a10306492b~mv2.png)

물론 텍스쳐가 여기서도 Repeat로 설정 되어 있다면 위 이미지 처럼 얼굴에 회색이 침범해버려서 보기 안좋아지니 꼭 Clamp로 바꿔주도록 합시다.

![](/assets/images/wix/99131843f5-ce7a39_98f516e19487438cb1f734c4df2b06d3~mv2.png)

![](/assets/images/wix/f5c72fb1a9-ce7a39_8476ab10fefd49bd98c62aac9e3f4e68~mv2.png)

아티스트가 룩업 텍스쳐를 직접 그려서 사용하는 방식이기 때문에 위와 같이 램버트 공식을 직접 그려서(!) 쓰는 방법도 가능합니다.

![](/assets/images/wix/9adb8fc391-ce7a39_3254bcafed564c4e97f03c8ba743544b~mv2.png)

![](/assets/images/wix/d9fa5d74f8-ce7a39_753dc9bf90a44ecebdcecea64d7856d0~mv2.png)

광원이 없으면서도 역광을 그려내거나 SSS를 직접 그려서 표현 하는 것이 가능합니다. 모바일 같이 극한으로 연산량을 줄여야 하는 프로젝트에서 위와 같은 꼼수로 가볍게 처리할 수 있습니다.

저번 포스트에서 공부한 툰 쉐이더를 응용 해서 룩업 텍스쳐 한 장에서 외곽선 까지 아티스트 답게 직접 그려내도록 해봅시다.

지금의 룩업 텍스쳐는 가로로 긴 형태입니다. 빛의 밝기 정보가 벡터1이니까 축도 하나만 사용하는 것입니다. Y(V)축 공간이 낭비되고 있습니다.

그리고 저희는 이전 포스트에서 프레넬(N dot V)을 이용한 외곽선을 만들어봤습니다. 모든게 준비 됐습니다. 프레넬 정보를 텍스쳐의 y축에 담아보도록 합시다.

***UV(N dot L , N dot V)***

![](/assets/images/wix/3d3e72b8aa-ce7a39_cd65b40d6da043a18d829282586e7d7e~mv2.png)

포토샵을 켜서 512 \* 512 정도의 사이즈로 텍스처를 그려줍니다.

![](/assets/images/wix/7e335910bb-ce7a39_4962cb0a1db74f33bc9139bf4be7a600~mv2.png)

프레넬 공식 대로 0에 가까울수록 외곽선이 생기게끔 텍스처의 y좌표에서 0 부분에 검은색을 칠해줍시다.

UV의 y축에 프레넬 공식이 들어가게 노드를 짜면 외곽선이 생기는 것을 볼 수 있습니다.

![](/assets/images/wix/2ed4e49611-ce7a39_a1fe2fcf94c44775a5eb5bd4ab5a6cbb~mv2.png)

위와 같이 텍스쳐를 작성하여 어두운 면일수록 외곽선이 두꺼워지도록 응용하는 것도 가능합니다.

## Pre\-integrated skin BRDF texture

![](/assets/images/wix/797d16ce0b-ce7a39_5b4415cb506a43a6a6f2682c5e3486db~mv2.png)

BRDF란 양방향 반사도 분포 함수의 줄임말입니다.

세상 모든 물체가 빛을 반사시키는 종류만 있는 것은 아닙니다. 빛이 완전히 통과 해버리는 물질도 있고, 어느정도는 투과하다가 물체 내부에서 산란되는 경우 또는 빛을 완전히 흡수해버리는 반타블랙 같은 물질들이 있습니다.

즉 어떤 부분이 얼마나 두꺼운지(혹은 아예 산란이 일어나지 않는지)를 나타내는 정보가 필요하고 아티스트는 어떤 부분이 얼마나 산란이 일어날 지에 대해 0과 1으로 그려서 맵으로 표현해 줄 수 있는데 이것을 두께(Tickness)맵이라고 부릅니다.

***UV(N dot L , Tickness)***

![](/assets/images/wix/be85e0a395-ce7a39_e1ce67921b254e77a45387d1763921db~mv2.png)

표면 산란(SubSurface Scattering)이 얼마나 일어날 지에 대한 데이터를 V축에 입력한 것입니다.

![](/assets/images/wix/d927b398cf-ce7a39_e70dc1d8e5c74113876063f3bf8dd8a7~mv2.gif)

이 데이터를 알베도 텍스처와 곱해주면 위와 같은 최종 결과물이 나옵니다.
