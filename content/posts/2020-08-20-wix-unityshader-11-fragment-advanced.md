---
title: "(UnityShader) 3D Procedural Noise"
date: "2020-08-20T21:18:44.009Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(UnityShader) 11 Fragment Advanced : 3D Procedural Noise / Fractal Noise지난 포스트(링크)에서는 2차원 노이즈를 제작하였고, 결과를 선형 보간 했습니다. 오늘은 가장 유용한 보간 공식 중 하나인 Smoothstep 부터 알려드리겠습니다.Smooth"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-11-fragment-advanced"
original_modified: "2022-06-12T05:29:46.667Z"
image: "/assets/images/wix/d348ad85be-ce7a39_6511dce1feb4470693683f6c7d62a216~mv2.gif"
---

(UnityShader) 11 Fragment Advanced : 3D Procedural Noise / Fractal Noise

![](/assets/images/wix/553c6c0146-ce7a39_4bce768b004b48238d757e10828c82ff~mv2.gif)

[지난 포스트(링크)](</posts/wix-unityshader-10-fragment-advanced/>)에서는 2차원 노이즈를 제작하였고, 결과를 선형 보간 했습니다. 오늘은 가장 유용한 보간 공식 중 하나인 Smoothstep 부터 알려드리겠습니다.

## **Smoothstep 으로 보간하기**

[동영상 보기](https://www.youtube.com/watch?v=60VoL-F-jIQ)

[(The Art of Code : https://youtu.be/60VoL\-F\-jIQ)](<https://youtu.be/60VoL-F-jIQ>)

**smoothstep(min,max,n)** : n이 \[min, max\] 사이의 값인 경우에 대해서 \[0, 1\] 사이에서 부드럽게 변하는 **Hermite** 보간법을 리턴합니다. n 값이 min보다 작다면 0을 리턴하고, max보다 크다면 1을 리턴합니다.

![](/assets/images/wix/fe9ac52193-ce7a39_311cfff68c29438691bcde4a36f85d98~mv2.png)

스무스 스텝 함수는 보간 방식에서 가장 자주 사용되고 매우 유용한 함수 중 하나입니다. 위의 사전적 정의가 알아듣기에 너무 딱딱한 감이 있습니다. 저희의 직관적인 이해를 돕기 위하여 실제 사용 예시를 보도록 합시다.

![](/assets/images/wix/d8b84a9f02-ce7a39_7f5aafeb2d1b4e5e8a3f934cb53f8fb7~mv2.gif)

![](/assets/images/wix/89c462341d-ce7a39_66fe243785cb47939ddee7d0c592e8fb~mv2.png)

smoothstep 함수로 uv.x 그라데이션을 보간하면 min, max 값에 따라 위와 같이 동작합니다. 위 그래프의 value 값을 색으로 볼 수 있게 만들었습니다. 이것을 **눈으로 디버깅** 한다고 표현합니다.

그라데이션의 부드러운 정도, 다시 말해서 **그래프로 해석하면 기울기**를 조절할 수 있기 때문에  정렬 되어있는 리니어(Linear) 데이터라면 뭐든지 보간이 가능합니다.

예를들어 카툰쉐이더를 작성할 때 램프 텍스처의 부드러운 정도를 조절 가능한 기능을 포함 할 경우 매우 유용하게 사용됩니다. 이 부분은 따로 다른 포스트로 다루도록 하겠습니다.

![](/assets/images/wix/d3c30785bf-ce7a39_8935ee82a3a34232b0fb1f07b1bc52c8~mv2.gif)

![](/assets/images/wix/bb97b9160f-ce7a39_e4b9bc4ac09242b98f0e3f7f2b69c992~mv2.png)

이렇게 부드럽게 보간한 UV 데이터를 가지고 선형 보간 인자로 재사용 할 수 있습니다.

![](/assets/images/wix/35d7c43247-ce7a39_198bc1b6c617457daa5a2b8f23008d83~mv2.png)

![](/assets/images/wix/ed07d80eb3-ce7a39_9f96a4235c8b44d587db01ebdb823487~mv2.png)

(좌측 : 보간 이후 / 우측 : 보간 이전)

```hlsl
float2 uv = smoothstep(_min, _max, frac(Num * _NoiseSize));
```





보간 이전 데이터는 날카로운 느낌이 있지만 보간 이후 데이터는 부드러움에서 차이가 납니다.

## **3차원 노이즈 만들기**

![](/assets/images/wix/f9c1922f71-ce7a39_3364909beaee4020a85f03102545508b~mv2.gif)

(3\-dimension noise)

이번 포스트의 본론입니다. 3차원 노이즈 데이터는 불규칙적인 값이 필요한 3d 오브젝트를 위해 사용됩니다. 주로 메쉬 이펙트 계열에서 많이 응용됩니다.

저희는 3d 노이즈로 랜덤한 버텍스 좌표 변화로 버텍스 애니메이션을 만들어 볼 것입니다. 그러기 위해서는 2차원 벡터인 UV 좌표 대신 **3차원 벡터인 월드 포지션**을 사용할 것입니다.

![](/assets/images/wix/ee22f02c3f-ce7a39_d949410f891949e8847b373e594b6ed9~mv2.png)

(WorldPos.xyz)

![](/assets/images/wix/a0de5d5b2d-ce7a39_c78689cde08845c49e973223d25aa38c~mv2.gif)

frac(WorldPos.xyz)

**월드 포지션(World Position)**이란 유니티 씬의 원점(0,0,0)을 기준으로 하는 월드 좌표계에서의 '미터 단위'(유니티 엔진은 미터 기준) **좌표 값**을 말합니다.

![](/assets/images/wix/c1d4958764-ce7a39_b383014aa60f4e7e9dd9b64099a0df40~mv2.png)

### float3 WorldSpacePosition = mul(unity\_ObjectToWorld,v.vertex).xyz;
o.worldPos = WorldSpacePosition;

유니티 내장 월드 변환 행렬인 unity\_ObjectToWorld와 로컬 좌표계의 좌표 값(Local Position)의 순서로 행렬곱(mul) 하여 계산 할 수 있습니다. OpenGL 렌더링 파이프라인의 과정중 일부와 같습니다.

![](/assets/images/wix/c6ac8ce8d7-ce7a39_ee45c73a1266404da051f3d3a5e993f8~mv2.gif)

### col.rgb = NoiseTexel(i.worldPos.xy);

아직 NoiseTexel 함수는 float2 밖에 인풋을 못합니다. 월드 포지션의 xy 좌표만 사용했기 때문에 노이즈가 한 쪽 면에만 출력되고 나머지는 정상적으로 출력 되지 않습니다. 이전 포스트와 같은 보간 방식으로 **float3 데이터를 받을수 있도록** 함수를 바꿔줍시다.

![](/assets/images/wix/3b8e944f07-ce7a39_025ac00f11e74ece9f834c77c8270708~mv2.png)

전혀 어려울 것 없습니다. 차원이 하나 더 늘어나서 이제 Z축이 생겼으니 보간도 z축으로 한 번 더 해주면 되는 것입니다. float2 였던 변수도 전부 float3으로 늘려줍시다.

![](/assets/images/wix/10d9a9259e-ce7a39_1ef5f7b799944605bd0b6a426948376a~mv2.gif)

이렇게 만들어진 3D 노이즈 데이터를 버텍스 쉐이더로 가져가서 버텍스 좌표에 사용할 것입니다.

![](/assets/images/wix/553c6c0146-ce7a39_4bce768b004b48238d757e10828c82ff~mv2.gif)

(색으로 출력된 오브젝트 노말)

오브젝트 노말 방향으로 버텍스 좌표를 이동(displacement) 하기 위해서 모든 방향으로 균일한 밀도의 폴리곤을 가진 메쉬를 사용해야 합니다. 저는 삼각형으로 이루어진 정20면체(Icosahedron) 도형을 사용하였습니다. 외부 3d 모델링 툴에서 제공되기 때문에 간단히 만들 수 있습니다.

![](/assets/images/wix/2a87cee4ed-ce7a39_3d8b2a6e343d497999ce4d7cadaff0d7~mv2.png)

요령은 버텍스 쉐이더로 넘어오기 전 appdata의 버텍스 좌표(vertex Position)에 접근하여 클립공간(ClipPos)으로 행렬곱 하기 전에 버텍스 데이터를 조작하는 것입니다.

### v.vertex.xyz \+= v.normal \* NoiseTexel(o.worldPos) \* \_Power;

버텍스를 노말 방향으로 움직이게 하려면 이동하길 원하는 값 만큼 **오브젝트 노말**과 곱해주고, 버텍스 좌표에 더해주면 된다고 [이전 URP 포스트(링크)](</posts/wix-unityshader-13-urp-shader-graph/>)에서 다뤘습니다.

## **프랙탈 노이즈 만들기**

- ![](/assets/images/wix/4adf4f2b5d-ce7a39_a1027ad718e44e2bb824b1590e24eab2~mv2.png)
- ![](/assets/images/wix/49a946ea75-ce7a39_f692cf47fa744a67b8aa0ea9fcf549af~mv2.png)

(가장 유명한 프랙탈 구조인 망델브로 집합, 자연물에서도 쉽게 발견 할 수 있습니다)

**프랙탈**(Fractal) 이란 일부 작은 조각이 전체와 비슷한 기하학적 형태를 말합니다. 이런 특징을 **자기 유사성**이라고 하며, 다시 말해 자기 유사성을 갖는 기하학적 구조를 프랙탈 구조라고 합니다.

저희가 구현할 부분은 프랙탈 원리 대로 **함수 자신을 변수로 삼아 반복되는 구조**를 만드는 것입니다.

반복기능 구현을 위해 저희는 **for 구문**을 사용하여 원하는 만큼 반복할 수 있도록 코드를 작성할 것입니다.

![](/assets/images/wix/a77367fa63-ce7a39_1f542d531db74fd0b8446f2649a7906f~mv2.png)

int 변수는 **정수**로만 이루어진 변수를 뜻합니다. Iteration 횟수 만큼 반복합니다.

위와 같이 for 구문을 작성하면 반복할 때 마다 노이즈 해상도는 2배로 커지고, 버텍스 강도는 0.5배(1/2)가 됩니다.

![](/assets/images/wix/d348ad85be-ce7a39_6511dce1feb4470693683f6c7d62a216~mv2.gif)

적당히 색을 넣어서 용암이 흐르는 구체 느낌으로 완성 했습니다.

끝까지 읽어주셔서 감사합니다.
