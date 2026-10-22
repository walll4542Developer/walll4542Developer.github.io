---
title: "(UnityShader) Koch Snowflake Part 1"
date: "2020-12-06T06:20:11.723Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "이번 포스트에서는 코흐의 눈송이 곡선(Koch Snowflake)을 만들어 볼 것입니다. 스웨덴의 수학자 헬게 폰 코흐(Helge von Koch)가 고안한 프랙탈 도형이라서 이런 이름이 붙었습니다.프랙탈 속성에 대해서는 이전 포스트(링크)에서 한 번 다룬 적이 있었습니다. 이 도형의 특징은 정삼각형에서"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-koch-snowflake"
original_modified: "2022-12-25T03:02:32.161Z"
image: "/assets/images/wix/345a0ddc41-ce7a39_435f6e2611b942d895e215b7afee99a3~mv2.gif"
---

![](/assets/images/wix/57d903d0e5-ce7a39_1bac050f96184a17aca6c98736870bc3~mv2.png)

이번 포스트에서는 **코흐의 눈송이 곡선**(Koch Snowflake)을 만들어 볼 것입니다.

스웨덴의 [수학자](<https://namu.wiki/w/%EC%88%98%ED%95%99%EC%9E%90>) 헬게 폰 코흐(Helge von Koch)가 고안한 프랙탈 도형이라서 이런 이름이 붙었습니다.

**프랙탈 속성**에 대해서는 [이전 포스트(링크)](</posts/wix-unityshader-11-fragment-advanced/>)에서 한 번 다룬 적이 있었습니다. 이 도형의 특징은 정삼각형에서 시작해서 **각 변을 삼등분 한 길이의 삼각형**을 바깥에 그립니다. 똑같은 과정을 무한히 반복 할 수 있습니다. 도형의 모양이 눈송이 같아서 이런 이름이 붙었습니다.

![](/assets/images/wix/b365412357-ce7a39_0c68474c6e4c4df9ae601c565947c2f5~mv2.png)

선분 하나로 시작해서 문제를 단순하게 풀어 나가 봅시다. uv 데이터를 가지고 선분을 그릴 것 입니다.

![](/assets/images/wix/ae276aba0d-ce7a39_05966788c4464beab1b62c82fa303f6c~mv2.gif)

```hlsl
float4 frag (v2f i) : SV_Target
{
 float4 col;
 float4 MainTex = tex2D(_MainTex, i.uv);

 col.rgb = step( 0.01 , abs(i.uv.y - _var) );
 col.a = 1;
 
 return col;
}
```





uv에서 절대값 함수로 음수 부분을 없앤 뒤 step 함수로 두께 0.01 크기의 선분을 그렸습니다. 하지만 이 상태면 선분의 길이를 조절 할 수 없으니 uv의 x축으로 조절 해봅시다.

![](/assets/images/wix/f1e94c6679-ce7a39_bc488305cf8a49cb8716370076033bdb~mv2.gif)

```hlsl
float4 frag (v2f i) : SV_Target
{
 float4 col;
 float4 MainTex = tex2D(_MainTex, i.uv);

 float m = 1-min( step(_var1, i.uv.x) , step(_var1, 1-i.uv.x) );

 col.rgb = saturate( step( 0.01 , abs(i.uv.y - _var) ) + m );
 col.a = 1;

 return col;
}
```





이제 길이 조절이 되긴 하지만, x 축으로 길이 값을 더하고 saturate 함수를 써서 0\~1 사이로 자르는 과정에서 코드가 번잡해지고 비효율적입니다. 가로와 세로를 한 번에 조절 할 수 있는 좀 더 직관적인 함수를 사용해서 처리 해봅시다.

## **length(x);**

Returns the length of the vector x.

[(https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-length)](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-length>)

![](/assets/images/wix/d9aa69fa81-ce7a39_c4907f8c17a84ace8c2c30899160787f~mv2.png)

```hlsl
col.rgb = length(i.uv);
col.rgb = distance(i.uv, float2(0,0));
```





length 함수는 원점(0,0)에서 부터 벡터의 길이를 표현합니다. OpenGl을 사용하는 유니티의 uv는 좌측 하단이 (0,0)이니 거리 값 0을 반환하고 방사형으로 원점에서 멀어질 수록 1에 가까워지는 것을 볼 수 있습니다.

distance() 함수도 똑같이 벡터의 거리를 반환합니다. 대신 원점이 아닌 다른 벡터를 집어넣을 수 있습니다.

![](/assets/images/wix/4747a8ee1d-ce7a39_197fe0f2fdd74879be692b2454b32ed1~mv2.gif)

```hlsl
col.rgb = length(i.uv - _var);
```





따라서 원점(0,0)을 오프셋으로 이동시키면 위 처럼 움직이게 됩니다. 타일링도 당연히 적용이 됩니다.

![](/assets/images/wix/fc6423dfad-ce7a39_ba871f3b3cc04866b5fd36182fd43b2a~mv2.png)

```hlsl
col.rgb = i.uv.y - 0.5;
```





원점과의 거리 값을 색으로 표현한 것이니 이렇게 0.5만큼 오프셋 이동한 uv의 x축 만을 length() 함수로 처리할 수 있을 것입니다.

![](/assets/images/wix/62aeb331bc-ce7a39_c87eca0d0666417cbf44851958ab5922~mv2.png)

```hlsl
col.rgb = length(i.uv.y - 0.5);
col.rgb = length(i.uv - float2(i.uv.x, 0.5) );
```





뺄셈으로 x축 값을 제거 해버리면 항상 벡터(x,y)의 x값은 0이고 y값에 의해 거리가 결정됩니다.

**거리 값은 '절대값'**이기 때문에 uv에서 음수로 넘어간 부분의 절댓값을 반환합니다. 예를 들어 float2(0,\-0.5)와 원점 과의 거리는 0.5입니다. 따라서 y축 자체가 원점이 되어 길쭉한 모양이 됩니다.

그렇다면 축의 길이는 어떻게 조절해야 할까요?

생각해봅시다. y축은 0.5로 고정이고, float2(x,0.5) 좌표에 있는 x 값은 항상 0인 동시에 0\~1 그라데이션(gradation)이 유지되어야 합니다.

## **clamp(x, min, max);**

Clamps x to the range \[min, max\].

[(https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-clamp)](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-clamp>)

![](/assets/images/wix/b881bf7f01-ce7a39_2b5b56445d4a4a5ab4d22fd49c37bf68~mv2.gif)

```hlsl
col.rgb = clamp(i.uv.x, _var, 1 - _var);
```





clamp 함수는 최솟값 min과 최댓값 max 사이로 값을 잘라냅니다. saturate 함수가 0과 1 사이의 값으로 잘라내는 것과 같습니다.

그래서 위 이미지 처럼 min값이 max 값의 반전이면 그라데이션이 유지되면서 x축의 양쪽 끝 값만 영향을 받습니다.

![](/assets/images/wix/bc178af042-ce7a39_7c58c6aa057c469fb10ceb0a1f211041~mv2.png)

(i.uv.x)

그렇다면 clamp한 값을 uv.x값에서 뺄셈 한다면 어떻게 될까요?

![](/assets/images/wix/bdd6d9b956-ce7a39_69a5172177cf4901925d14cb0561833b~mv2.gif)

```hlsl
col.rgb = i.uv.x - clamp(i.uv.x, _var, 1 - _var);
```





var 값이 0이라면 clamp(x,0,1) 이고 그러면 원래 uv.x 값과 똑같으니까 전체에서 전체를 뺄셈한 것이니 모든 픽셀의 값은 0입니다.

![](/assets/images/wix/c24722d02a-ce7a39_99d491023cd04b8da206e0aa0c1bf29e~mv2.gif)

```hlsl
col.rgb = abs(i.uv.x - clamp(i.uv.x, _var, 1 - _var) );
```





var 값이 0.5이라면 clamp(x,0.5,0.5) 라서 전체에서 0.5 만큼 오프셋 이동하게 됩니다. 그리고 검은색 부분에는 \-0.5의 값을 가지게 됩니다. (알기 쉽게 절대값 abs 함수를 사용했습니다.)

![](/assets/images/wix/a0b5ebf706-ce7a39_08c03425d18e45928c9cfa113a22a317~mv2.gif)

```hlsl
col.rgb = length(i.uv - float2( clamp(i.uv.x, _var, 1 - _var), 0.5) );
```





코드가 깔끔하게 한 줄로 정리됩니다. 이것으로 우리는 원하는 길이와 두께의 선분을 그릴 수 있게 되었습니다.

![](/assets/images/wix/75b82dd00a-ce7a39_94d176fe2a954716b53aa20b037ad7ea~mv2.gif)

```hlsl
float4 frag (v2f i) : SV_Target
{
 float4 col;
 float4 MainTex = tex2D(_MainTex, i.uv);

 float segment = length(i.uv - float2( clamp(i.uv.x, _var, 1 - _var), 0.5) );
 
 col.rgb = step(0.05, segment);
 col.a = 1;

 return col;
}
```





여기까지해서 선분 하나를 그렸습니다. 다음은 선분을 삼등분 하는 과정인데, UV의 특성을 생각해봅시다.

![](/assets/images/wix/58e7a98ab3-ce7a39_14b3036e77914f58a1735025511337e0~mv2.gif)

```hlsl
float2 uv = i.uv;
float segment = length(uv - float2( clamp(uv.x, _var, 1 - _var), 0.5) );
col.rgb = step(0.05, segment) * float3(uv,0);
```





UV를 출력 해서 선분과 곱하여 uv가 보이게 하는 것이 이해에 도움이 될 것입니다.

![](/assets/images/wix/e1359e3608-ce7a39_60cab81399fe4de08d54236b204e1a40~mv2.png)

선분을 삼등분 하고 같은 길이로 삼각형을 그린다는 것은 다르게 생각하면 **대칭되는 꺾인 선분입니다.**

지금까지 uv의 양수 부분에서 선분을 그렸지만 음수 부분에서 똑같이 선분을 그리고 원점을 기준으로 가로 대칭 시키면 될 것 같습니다.

![](/assets/images/wix/1ffeee2921-ce7a39_ed185de0af05418ebdab9f39b1fde07d~mv2.png)

```hlsl
float2 uv = float2(i.uv - 0.5) * 1;
uv.x = abs(uv.x);
col.rgb = float3(uv,0);
```





0.5를 뺄셈 해서 원점(0,0)을 중앙으로 옮기고, 절대값 abs 함수를 사용해서 uv.x를 가로로 대칭 했습니다.

![](/assets/images/wix/f941e9cb93-ce7a39_7615501932c24861a53f3e16efa0c917~mv2.gif)

```hlsl
float segment = length(uv - float2( clamp(uv.x, _var, 1-_var), 0) );
col.rgb = step(0.05, segment) * float3(uv,0);
```





짜잔. 선분이 두개가 됬습니다. 다만 지금 선분을 그리는 공식으로는 위 이미지 처럼 0.5 값에서 오프셋이 되기 때문에 수정해줍시다.

![](/assets/images/wix/f008dcb22e-ce7a39_ca1e590493d34ec3a1ebab110d929110~mv2.gif)

```hlsl
float segment = length(uv - float2( clamp(uv.x, -_var, _var), 0) );
col.rgb = step(0.05, segment) * float3(uv,0);
```





선분은 여전히 하나인 것 처럼 보입니다. 사실 두 개의 선분이 그려지는 영역이 완전히 겹쳐 있어서 그렇습니다.  x축 값이 0이 되는 부분을 늘려서 선분을 양쪽으로 분리시켜 봅시다.

![](/assets/images/wix/e13b7e6149-ce7a39_349ef979617e4a2a8d4c5024b136b4b8~mv2.png)

```hlsl
float2 uv = float2(i.uv - 0.5) * 2;
uv.x = abs(uv.x) - 0.5;
float segment = length(uv - float2( clamp(uv.x, -0.25, 0.25), 0) );
col.rgb = 1-step(0.05, segment) + float3(uv,0);
```



간단히 x축에서 0.5 길이 만큼 0이 들어가는 영역을 늘렸습니다. 그리고 선분이 잘 보이도록 흰색으로 변경했습니다.

이제 선분을 회전시키는 함수를 만듭시다.

앞서 우리는 uv로 선분을 만들었습니다. 따라서 선분을 회전시킨다는 것은 **uv를 회전**시키는 것과 같습니다. 이전 포스트에서 [회전 행렬(링크)](</posts/wix-unityshader-09-fragment-advanced/>)에 대해 다룬 적이 있었습니다.

![](/assets/images/wix/dfccc076a5-ce7a39_1a22f0700523489eb2b1bcf7ccb0d965~mv2.png)

![](/assets/images/wix/796a1568b0-ce7a39_d9963c68b0384a52bfe7de3e716e2255~mv2.gif)

```hlsl
col.rgb = float3(RotateUV(i.uv, _var1), 0);
```





하지만 저희가 원하는 것은 uv 전체가 회전 하는 것이 아닌 특정 위치에서 uv를 꺾어서 원하는 각도를 만드는 것입니다. 회전 행렬을 그대로 쓰지 않고 응용 해봅시다.

```hlsl
float ReflectUV(float2 uv, float degrees)
            {
 float Degrees2Rad = UNITY_PI * 2 / 360;
 float Radians = degrees * Degrees2Rad;
 float c = cos(Radians);
 float s = sin(Radians);
 float2 rotateMatrix = float2(s,c);
 float result = dot(uv - 0.5, rotateMatrix);

 return result;
            }
```





먼저 각도 변수를 사용하기 쉽게 라디안으로 변환하는 것 까지는 기존 코드와 같지만 회전 행렬을 간소화 했습니다.

![](/assets/images/wix/95e66a8bd6-ce7a39_dbf2197c5f4846999931376f5eae43b7~mv2.gif)

```hlsl
float c = cos(Radians);
float s = sin(Radians);
float2 rotateMatrix = float2(s,c);
```



저희같은 아티스트에게는 호도법 보다는 60분법으로 설명하는 것이 친화적이고 직관적이라 각도로 치환해서 써보겠습니다.

```hlsl
float result = dot(uv - 0.5, rotateMatrix);
```



uv와 내적 연산을 하면 x \* s \+ y \* c 입니다.

sin(0) = 0이고, cos(o) = 1입니다. float2(0, y)

sin(90) = 1이고, cos(90) = 0입니다. float2(x, 0)

sin(180) = 0이고, cos(180) = \-1입니다. float2(0, \-y)

sin(270) = \-1이고, cos(270) = 0입니다. float2(\-x, 0)

uv의 x와 y를 따로 보면 이해가 쉬울 것입니다.

![](/assets/images/wix/ffb04592fd-ce7a39_6bb21b735845497b800b4aaf52a89982~mv2.gif)

(i.uv.x \-0.5)

0, 1, 0, \-1, 0

![](/assets/images/wix/4933de7d6e-ce7a39_456d277018174c6281e06c50802aacb9~mv2.gif)

(i.uv.y \-0.5)

1, 0, \-1, 0, 1

![](/assets/images/wix/6cf207f447-ce7a39_bc4968f4db634ca089ca040e9986f7ac~mv2.gif)

```hlsl
col.rgb = abs( ReflectUV(i.uv, _var1) );
```





**내적 연산으로 x와 y의 비율을 결정**하여 회전을 구현한 아이디어 입니다. 삼각함수가 \-1\~1의 값을 순환하기 때문에 회전 행렬과 똑같이 동작합니다.

![](/assets/images/wix/75e98e3ce2-ce7a39_4795f731cfc5426f99c725e43832cfbe~mv2.png)

```hlsl
float Degrees2Rad = UNITY_PI * 2 / 360;
float Radians = _var1 * Degrees2Rad;
float c = cos(Radians);
float s = sin(Radians);
float2 rotateMatrix = float2(s,c);
float distance = dot(i.uv - 0.5, rotateMatrix);
col.rgb = distance;
```





저희는 굴절 되는 **각도 값**(rotateMatrix)도 알고 있고, 원점에서의 **거리 값**(distance)도 알고 있습니다. 절대값 함수를 빼면 한 쪽은 음수라서 전부 검은 색으로 출력됩니다.

![](/assets/images/wix/9729467497-ce7a39_feabf800f3704d57a985b5ba0927b3ae~mv2.png)

세타 값 만큼 선분이 기울어지려면 음수 혹은 양수 중 한 부분을 제외하고 회전해야합니다. 위 이미지 대로 동작하려면 음수 부분의 uv는 그대로여야 한다는 뜻입니다.

![](/assets/images/wix/cacaf7a7bc-ce7a39_9fb31ccb551b42dcaedc10ae9731c48b~mv2.gif)

```hlsl
float2 result = (rotateMatrix * distance);
col.rgb = 1-step(0.01, abs(distance) ) + float3(result, 0);
```



알아보기 쉽게 선분을 따로 출력해서 표현 했습니다. 현재는 전체 uv가 다 같이 회전합니다. 저희는 uv를 굴절 시켜야 하죠.

각도 값은  x \* s \+ y \* c 였습니다.  각도 값에 거리 값을 곱하고 출력하면 위 자료 처럼 되죠. 이 값을 uv에서 뺄셈하면 uv가 회전 할 것입니다.

![](/assets/images/wix/c24601b192-ce7a39_4d2bb3cf6cc14b61adf01b894798d15a~mv2.png)

(i.uv \- 0.5)

조금 혼란이 오는 부분이라 천천히 설명하겠습니다. uv가 회전하는 원리는 다음과 같습니다.

uv에서 0.5만큼 뺄셈 하면 x와 y 값이 모두 오프셋 되어 0,0이 중심이 됩니다.

![](/assets/images/wix/a698d96582-ce7a39_f7096c28839243b8b5bd065942c5796c~mv2.png)

```hlsl
col.rgb = float3(rotateMatrix * distance * 1,0);
```



rotateMatrix \* distance 을 봅시다. 중심이 (0,0)이기 때문에 \-0.5 \~ \+0.5 범위를 가지고 있습니다.

2를 곱하면 \-0.5 \~ 0.5였던 값이 \-1 \~ 1이 됩니다.

따라서 \-0.5 \~ 0.5의 uv에서 (rotateMatrix \* distance \* 2)를 뺄셈하면?

![](/assets/images/wix/8e66840d23-ce7a39_9eea4832b748406494841d9894f4e5ac~mv2.png)

0.5에서 \-1 하여 \-0.5가 되고, \-0.5에서 \-(\-1) 하여 0.5가 됩니다. 부호가 반전 되어 회전 합니다. 위에서 본 삼각함수와 똑같습니다.

![](/assets/images/wix/828159d171-ce7a39_2349399d07244b9fb5b360ce4920a625~mv2.gif)

```hlsl
float2 result = (i.uv - 0.5) - (rotateMatrix * distance * 2);
col.rgb =  float3( result, 0);
```





이렇게 됩니다. 이제 음수와 양수 부분중 한 쪽만 회전시켜 봅시다.

## **min(x, y);**

Selects the lesser of x and y.

[(https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-min)](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-min>)

## **max(x, y);**

Selects the greater of x and y.

[(https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-max)](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-max>)

![](/assets/images/wix/3fec36ab0a-ce7a39_8459f5a7a3884467a529ea1ba3f0213c~mv2.gif)

```hlsl
col.rgb = float3( (rotateMatrix * min(0,distance) * 2) , 0);
```



min(x,y) 함수는 x와 y중 작은 값을 반환합니다. 따라서 거리 값에서 음수 부분인 \-1 \~ 0만 남습니다.

max(x,y) 함수는 x와 y중 큰 값을 반환합니다. 따라서 거리 값에서 양수 부분인 \+1 \~ 0 만 남습니다.

![](/assets/images/wix/8fed7eba77-ce7a39_6ac3deb613a14408bcb9c1b9e062e149~mv2.gif)

![](/assets/images/wix/8de2bf591f-ce7a39_6b21dc9f9a964daab03aa94b33c4fad0~mv2.gif)

```hlsl
float2 result = (i.uv - 0.5) - (rotateMatrix * min(0,distance) * 2);
col.rgb = 1-step(0.01, abs(distance)) + float3( frac(result * 10) ,0);
```





이렇게 양수와 음수 부분중 원하는 부분을 굴절 할 수 있습니다.

과정이 길어지기 때문에 2부로 나눠서 작성하겠습니다.

다음 포스트에서는 for 구문으로 선분에 프랙탈을 적용하고, uv에 텍스쳐를 입혀 결과물을 완성 하는 것 까지 하겠습니다.
