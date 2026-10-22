---
title: "(UnityShader) Voronoi diagram"
date: "2021-01-31T08:53:13.887Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "안녕하세요. 이번 포스트에서는 보로노이 다이어 그램을 만들어 볼 것입니다.보로노이 다이어그램은 자연물에서 흔히 관찰 할 수 있는 패턴입니다. 2차원 평면에 분포한 점들 사이의 거리를 기반으로 평면을 나누는 방법 중 하나 입니다.(Georgy Voronoi)러시아 수학자 그레고리 보로노이의 이름을 따서 지"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-voronoi-pattern"
original_modified: "2022-12-25T03:21:38.480Z"
image: "/assets/images/wix/3d7f59d8a2-ce7a39_ee1306c6ac31431a96f7f06ff04007cf~mv2.gif"
---

안녕하세요. 이번 포스트에서는 보로노이 다이어 그램을 만들어 볼 것입니다.

![](/assets/images/wix/3d7f59d8a2-ce7a39_ee1306c6ac31431a96f7f06ff04007cf~mv2.gif)

![](/assets/images/wix/fdb8162d69-ce7a39_e21883a54ebc4bebbaebb26f7871b7e3~mv2.png)

보로노이 다이어그램은 자연물에서 흔히 관찰 할 수 있는 패턴입니다. 2차원 평면에 분포한 점들 사이의 거리를 기반으로 평면을 나누는 방법 중 하나 입니다.

![](/assets/images/wix/da719fd738-ce7a39_80fd1f5bc035415eb46ca4a9f2bcd9ff~mv2.jpg)

(Georgy Voronoi)

러시아 수학자 그레고리 보로노이의 이름을 따서 지어졌으며 다른 이름으로 보노로이 테셀레이션, 보노로이 분해, 보노로이 파티션이라고도 부릅니다.

![](/assets/images/wix/9afc3adda3-ce7a39_3b0a09304d4c4bf68bb6323eeaa7d312~mv2.png)

보로노이 다이어그램을 쉐이더로 구현하는 기본 아이디어는 다음과 같습니다.

먼저 평면에 점을 무작위로(Random) 배치합니다.

두 점 사이의 경계선을 정할 때, 두 점과의 거리가 동일한 지점을 이은 선을 경계선으로 정합니다.

이렇게 만들어진 각각의 영역을 보로노이 셀(Voronoi cell)라고 합니다.

![](/assets/images/wix/3ea07e9cec-ce7a39_0cca10f86b2d4013922f3647880964d5~mv2.png)

```hlsl
float2 uv = 2 * (i.uv - 0.5);
```





먼저 평면에 점을 찍는 과정부터 시작해봅시다. 평면에 해당하는 위와 같은 수식으로 **1\~\-1** 범위로 확장합시다. 원점이 중간에 오게 하는 것입니다.

![](/assets/images/wix/89fc94c2e1-ce7a39_b9127170b35642b18b151d472082c656~mv2.gif)

```hlsl
float2 uv = 2 * (i.uv - 0.5);
float distance = 1-length(uv);

col.rgb = smoothstep(_Min, _Max, distance);
col.a = 1;
```





간단하게 length 함수로 점 하나를 찍었습니다. 점의 크기를 조절 할 수 있게 smoothstep 함수로 보간합니다.

![](/assets/images/wix/95a64f835a-ce7a39_42df3dab2e82443ea71606293f1b26fd~mv2.gif)

```hlsl
float distance = 1-length(uv - float2(x,y));
```





이렇게 하면 임의의 float2 데이터로 점을 원하는 좌표에 배치 할 수 있습니다.

다음은 점을 무작위로 배치하기 위해 랜덤한 float2 값을 반환하는 함수를 만들어야 합니다.

저희는 이전 포스트에서 다뤘던 노이즈 연산을 사용할 것입니다.
