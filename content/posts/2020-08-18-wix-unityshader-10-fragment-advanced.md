---
title: "(UnityShader) Procedural noise"
date: "2020-08-18T10:55:46.561Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(UnityShader) 10 Fragment Advanced : Procedural noise안녕하세요. 벌써 장마가 끝나고 무더위만 남았습니다. 저번 포스트에서는 어렵지만 꼭 짚고 넘어가야 했던 행렬을 다뤘었는데요. 너무 어려웠는지 조회수가 반토막이 났습니다... 그래서 완급조절을 위해 이번에는 비교"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-10-fragment-advanced"
original_modified: "2022-06-12T05:27:54.268Z"
image: "/assets/images/wix/242731606f-ce7a39_be0e0dc439824c7ab1505d111fd19b35~mv2.gif"
---

(UnityShader) 10 Fragment Advanced : Procedural noise

![](/assets/images/wix/0e6fa1ca76-ce7a39_41cf9f866016456ab09c09c8849a3f5e~mv2.gif)

안녕하세요. 벌써 장마가 끝나고 무더위만 남았습니다. 저번 포스트에서는 어렵지만 꼭 짚고 넘어가야 했던 행렬을 다뤘었는데요. 너무 어려웠는지 조회수가 반토막이 났습니다... 그래서 완급조절을 위해 이번에는 비교적 쉬운 **절차적 생성 노이즈**를 만들어 볼 것입니다.

![](/assets/images/wix/a14cb5231b-ce7a39_e9034d14cb4b4d56927aa4ff6cb24691~mv2.png)

![](/assets/images/wix/5ffdf387c2-ce7a39_5ab5037a9a3f46a2831157db222e6cfd~mv2.png)

## col.rgb = i.uv.x;

UV를 이용한 그라데이션 출력부터 시작해봅시다. 저희의 목표는 x축으로 0부터 1까지 작은수 부터 큰 수의 순서로 정렬 되어있는 그라데이션을 **불규칙적(Randomize)**으로 뒤섞는 일입니다.

그렇다고 난수(Random number) 생성 알고리즘을 쓰지는 않고 적당히 **'난수 처럼 보이는' 패턴**을 만들 것입니다.

패턴을 구성하기위해 완전히 새로운 방식을 쓰는게 아닌 이전 포스트들에서 사용했던 함수들의 조합으로 응용하는 것이라 어렵지 않을 것입니다.

## 삼각함수 응용하기

![](/assets/images/wix/9e0a5fbb2c-ce7a39_ca2d62018c0745218f38225b8bcd9be5~mv2.png)

(sine)

[지난 포스트(링크)](</posts/wix-unityshader-08-fragment-advanced/>)에서 다뤘던 **sin 함수**를 이용해봅시다. 사인 세타는 직각 삼각형의 c/a 값입니다. 이것을 y축이 결과 값, x축이 **세타(라디안)**이 결과 값인 그래프를 그리면 어떻게 될까요?

![](/assets/images/wix/17a77afb49-ce7a39_73cfeb9137c644c9bfdc8db117e588df~mv2.png)

(sine)

세타 값이 **0에서 2π까지** 대입시키면 위와 같은 결과가 나옵니다.

![](/assets/images/wix/95e66a8bd6-ce7a39_dbf2197c5f4846999931376f5eae43b7~mv2.gif)

([https://commons.wikimedia.org/wiki/File:Circle\_cos\_sin.gif](<https://commons.wikimedia.org/wiki/File:Circle_cos_sin.gif>))

![](/assets/images/wix/7b0e88708d-ce7a39_92210d20be4e4181a9111a04e2eb6c11~mv2.png)

더 큰 값을 세타에 대입해도 결과 값은 항상 **0에서 시작하여, \-1과 1사이**를 반복합니다. (코사인 그래프는 1에서 시작합니다)

따라서 사인 그래프를 일종의 **파동**이라고 생각 할 수 있습니다. 저희는 사인 그래프의 이러한 성질을 이용할 것입니다.

사인 함수에 세타 값에 uv의 x축 값(0\~1)을 대입하면 어떻게 될까요?

![](/assets/images/wix/c173b48dc4-ce7a39_6d188dc2c29b4d3097433beb4b6ac345~mv2.png)

### col.rgb = **sin**(i.uv.x);

대충 0 \~ 0.841470... 사이 값으로 이루어진 그라데이션이 됩니다. 하나의 파장을 이루기에는 세타에 대입된 uv.x 값이 너무 작기 때문입니다. 2π 주기로 진동하기 때문에 한 번의 파동을 완성하려면 적어도 세타에 **2π 이상의 값을 대입해야 합니다.**

![](/assets/images/wix/01348ed5b6-ce7a39_ca1299180c6b445d90f8c126c31ab5a7~mv2.gif)

### col.rgb = **sin**(i.uv.x \* \_randomize);

단순히 uv에 임의의 값을 곱해주는 것으로 해결 할 수 있습니다. 출력해보면 모니터는 음수의 색을 표현할 수 없기 때문에 검은색인 0으로만 나오지만 실제로는 \-1\~1 사이를 반복하고 있습니다.

![](/assets/images/wix/635c90a8c3-ce7a39_200128f7517e4c1bb3b90b0cedbd65f6~mv2.gif)

### col.rgb = frac(sin(i.uv.x \* \_randomize));

저희는 여기서 0 부터 1 미만의 값만 필요로 하기 때문에 [지난 포스트(링크)](</posts/wix-unityshader-07-fragment-advanced/>)에서 다뤘던 **frac 함수**로 소수점 부분만 잘라냅니다.

![](/assets/images/wix/513e6cca94-ce7a39_0b1abb0c08c44c9e82d2258c3f2e71a8~mv2.png)

그래프는 위와 같이 변형됩니다. 아직은 '난수 처럼 보이지 않고' 반복되는 부분이 눈에 보이기 때문에 좀 더 알아 볼 수 없도록 해봅시다.

![](/assets/images/wix/757cfd3c0d-ce7a39_98b30e859a284d189a391f911cbf7109~mv2.png)

### col.rgb = frac(sin(i.uv.x \* \_randomize) \* \_randomize);

적당히 큰 임의의 수를 sin 이후에 한 번 더 곱한 값을 frac으로 처리하게 했습니다. 이제는 반복되는 부분을 알아내기 쉽지 않은 패턴이 되었습니다.

한 축의 값이 무작위가 되었으니 이것을 **1차원 노이즈(1\-dimension noise)** 라고 합니다. 그렇다면 차원을 확장하려면 어떻게 해주어야 할까요?

## 노이즈 차원 확장하기

![](/assets/images/wix/afac645fd2-ce7a39_a74c7da9b85f431dbde2969a0626589e~mv2.png)

![](/assets/images/wix/10663eac06-ce7a39_a8c9ca18246c49919db99b416177298a~mv2.png)

노이즈 텍스처의 차원을 확장 하는 것은 간단합니다. x축과 y축 둘다 곱해주면 됩니다. 사용하기 편하게 함수로 만들었습니다.

- ![](/assets/images/wix/cb428652ff-ce7a39_61fe23c411b84f3eb62d0d9262af8096~mv2.gif)
- ![](/assets/images/wix/4b1cf3bdd3-ce7a39_0f62d489dc68466081c847127a05f923~mv2.gif)

```hlsl
좌측 frac(sin(Num.x * Num.y * _randomize + (_Time.y * speed)) * _randomize);
```



```hlsl
우측 frac(sin(Num.x * Num.y * _randomize) * _randomize + (_Time.y * speed));
```





위처럼 Time 함수를 더해서 응용 해줄 수도 있는데, 어디에 타임을 더하느냐에 따라 결과가 달라집니다.

## 노이즈 해상도 조절하기

![](/assets/images/wix/b1ca365e8b-ce7a39_f503e8d3da8c48779865a2691121809c~mv2.png)

### col.rgb = floor(float3(i.uv,0) \* 10);

**floor(내림)** 함수를 이용하여 해상도를 원하는 크기만큼 조절 할 수 있습니다.

내림 연산은 0.999…까지는 0의 값으로 내립니다. 1.999… 역시 1으로 내립니다. 1보다 작으면 무조건 0으로 반환합니다. 근본적으로 소수점 이하를 버리는 것과 같아서 frac 함수와 완전히 반대입니다.

## floor(1.n) = 1.n \- 0.n

## frac(n.1) = n.1 \- n.0

![](/assets/images/wix/689bc1358a-ce7a39_d122546c50984e1ba6cb4e13d2da0c9c~mv2.png)

![](/assets/images/wix/3702711b9c-ce7a39_b49737398cbd4966a8198365ecb98187~mv2.png)

10\*10 크기로 만들기 위해 uv를 10배 곱한 다음 내림 하였습니다. [이전 포스트(링크)](</posts/wix-unityshader-11-urp-shader-graph/>)의 카툰렌더링에서도 색을 끊어주기 위해 이러한 방식을 사용했었습니다.

다만 floor를 사용하게 되면 특정 난수에서 어느 정도 규칙성을 가진 형태로 패턴이 나타나는 경향이 있습니다. 그래서 floor 이후 곱한 만큼 다시 나누어 줬습니다.

## 노이즈 보간하기

![](/assets/images/wix/1b0c071e5b-ce7a39_78470cd6658c4b779d4cd1134b822e57~mv2.gif)

(보간 유무 비교)

저희는 해상도를 조절할 수 있게 되었으나, 내림 연산으로 인해 노이즈 픽셀들의 값이 딱딱 끊어졌습니다. 부드러운 값이 필요한 쉐이더에 사용할 수 있도록 값을 부드럽게 이어주는 **보간 작업**을 할 것입니다.

![](/assets/images/wix/e9e923975b-ce7a39_f68ed6c4107a4d478ef77581ff0ae4e8~mv2.png)

(3x3 uv)

### col.rgb = float3(frac(i.uv \* 3), 0);

frac 함수에 uv를 대입한 것으로 생각 해봅시다. 알아보기 쉽게 3x3 크기로 만들었는데 이미지를 보시면 어떻게 보간 해야할지 벌써 감이 오실 겁니다.

![](/assets/images/wix/af7fc6e2eb-ce7a39_6c638cbb017841089f9ba02579bb0b93~mv2.gif)

## **float2(1,0) ←**

![](/assets/images/wix/a2f735ff24-ce7a39_8750710695a54967a880e178eda110e1~mv2.png)

### col.rgb = NoiseRandom(floor(i.uv \* \_NoiseSize) \+ **float2****(1, 0)**);

위와 같이 코드를 짜게 되면 float2(1,0)을 더하는 것은 x축 방향으로 **한 칸** 만큼 움직이는 **오프셋** 이동이 됩니다.

![](/assets/images/wix/a189906094-ce7a39_fe3001e3c1ee4ca2bb55b4e1bef121d6~mv2.gif)

```hlsl

 float a = NoiseRandom(floor(i.uv * _NoiseSize) + float2(0, 0));
 float b = NoiseRandom(floor(i.uv * _NoiseSize) + float2(1, 0));

 float lerp_x = lerp(a, b, frac(i.uv.x * _NoiseSize) );

 col.rgb = lerp(a, lerpx, _Slider);
```





따라서 원본 노이즈 **a**와 한 칸 이동한 노이즈 **b**를 **frac(uv)을 x축(수평)으로 선형 보간** 해주면 위와 같은 결과를 얻을 수 있습니다.

![](/assets/images/wix/02053506de-ce7a39_8243fa92837f40ae8513778503b301fb~mv2.png)

### float ab = lerp(a, b, uv.x);
 float cd = lerp(c, d, uv.x);

아직 보간 해야 할 수직 축이 남아 있습니다. **한 칸 수직 이동**한 노이즈 c와 **한 칸 수직수평 이동**한 노이즈 d를 만들어야 합니다.

### float result = lerp(ab, cd, uv.y);

ab와 똑같은 방식으로 x축으로 선형 보간 해줍니다. 마지막으로 수평 보간한 결과물 ab와 cd를 합치기 위해 frac(uv)의 y축(수직)으로 보간 해주면 끝입니다.

![](/assets/images/wix/6fe73279f4-ce7a39_3314181b3a5e457c87bf2ebc5731361c~mv2.png)

![](/assets/images/wix/1b0c071e5b-ce7a39_78470cd6658c4b779d4cd1134b822e57~mv2.gif)

(완성)

다음 포스트에서는 Smoothstep 함수로 보간 방식을 변경했을 경우와 **3차원 노이즈, 프랙탈 방식 노이즈,** 그리고 **노이즈 응용 버텍스 애니메이션**으로 찾아뵙겠습니다.

끝까지 읽어주셔서 감사합니다.
