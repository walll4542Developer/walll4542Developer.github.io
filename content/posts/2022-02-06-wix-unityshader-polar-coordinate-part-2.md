---
title: "(UnityShader) Polar Coordinate Part 2"
date: "2022-02-06T17:00:48.148Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "직교좌표계를 극좌표계로 변환하기이제 셰이더 코딩 시간입니다.float2 uv = input.uv - 0.5;일단 원점을 중앙으로 이동 시킨 UV를 준비합니다. 먼저 x 값으로 사용 할 극축과의 각도를 구해봅시다. 역삼각함수인 arctan을 사용하면 각도를 알 수 있다고 했었습니다.arctan은 hlsl "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-polar-coordinate-part-2"
original_modified: "2023-02-25T02:58:32.931Z"
image: "/assets/images/wix/b5bc6e94b6-ce7a39_7fce21d1c2cf4a66b3ce21129c4205b7~mv2.gif"
---

## 직교좌표계를 극좌표계로 변환하기

이제 셰이더 코딩 시간입니다.

![](/assets/images/wix/5e5ff03e97-ce7a39_02bd462ca1dd4f1f97a711697bd104ba~mv2.png)

```hlsl
float2 uv = input.uv - 0.5;
```



일단 원점을 중앙으로 이동 시킨 UV를 준비합니다. 먼저 x 값으로 사용 할 **극축과의 각도**를 구해봅시다. 역삼각함수인 arctan을 사용하면 각도를 알 수 있다고 했었습니다.

arctan은 hlsl 셰이더 코드로 atan(x)으로 사용합니다. 기울기(y/x)는 uv.y / uv.x로 계산하면 모든 직교좌표계의 기울기 값을 구할 수 있습니다.

![](/assets/images/wix/70128e89d5-ce7a39_1dd6d23899ac420e8202247e1a57dafb~mv2.png)

```hlsl
float2 uv = input.uv - 0.5;
float result = atan(uv.y / uv.x);
```



결과가 나왔는데 뭔가 이상합니다.

![](/assets/images/wix/c31d7cb9f6-ce7a39_7a3982dc865c46708c2527fafb1ce174~mv2.png)

(atan(x)의 라디안 표현)

사실 검은색으로 보이는 부분은 정상입니다. 음수의 각도 값이 반환 되기 때문에 음수의 색상을 표현 할 수 없으니 검은색으로 보이는 것이죠. arctan은 정의역을 제한 했기 때문에 표현 할 수 있는 각도 값 역시 (\-π/2 \~ π/2)로 제한 되어 있고 따라서 음수가 포함되어 있는 각도입니다.

π/2 구간에서 부호가 바뀌는데, 탄젠트의 역함수니까 당연합니다. 각도 값이 π/2에 도달하면 기울기가 무한이라는 뜻이니까요. atan(x) 함수를 그대로 사용 할 수는 없겠습니다.

![](/assets/images/wix/d8e7e2bc6d-ce7a39_468593454cce440aa513c75910759bc4~mv2.png)

(극좌표계)

저희가 필요한 건 극축으로 부터의 각도입니다. 극축에 대한 0 \~ 2π, 360도를 얻어야 제대로 된 극좌표를 만들 수 있습니다.

저희와 같은 문제를 겪은 개발자들이 극좌표로 좀 더 쉽게 변환할 수 있도록 만들어둔 **atan2(y, x)** 함수를 사용 할 것입니다. atan2(y, x) 함수는 직교좌표계의 임의의 점 (x, y)의 값을 대입(y, x)하면 극축과 이루는 각도 θ를 (\-π \~ π)의 범위로 반환합니다.

![](/assets/images/wix/5f7cda532a-ce7a39_7c71b8fd359b48369237738a0c4e3799~mv2.png)

```hlsl
float polarCoord = atan2(uv.y, uv.x);
```



UV의 x축과 y축을 함수 인자로 대입하면 전체 직교좌표가 극축과 이루는 모든 각도 값을 얻게 됩니다.

![](/assets/images/wix/39403655e2-ce7a39_9b6459a30ce740848afbe33738698ec9~mv2.png)

(atan2(y,x)의 라디안 표현)

반직선인 극축을 기준으로 각도를 재고 있습니다. 이제 각도 값을 정규화 해야 합니다.

왜냐하면 라디안은 π로 표현하는 각도 값이고 π는 대략 3.14 정도의 값이니까 그대로 사용하면 3배 타일링이 되버리니까요.

(\-π \~ π)를 최종적으로 (0 \~ 1)로 정규화 하는 작업을 해봅시다.

![](/assets/images/wix/2994ecb11f-ce7a39_499863e8dcec45aa890700413007af47~mv2.png)

```hlsl
float polarCoord = atan2(uv.y, uv.x) / UNITY_PI;
```



먼저 π를 나눠서 라디안으로 표현되는 각도에서 π를 제거합니다.

![](/assets/images/wix/2c5417e8eb-ce7a39_6af184f0647040ada048fdb71ab888bd~mv2.png)

(π가 제거된 상태의 각도)

이제 각도 값은 (\-1 \~ 1)입니다.

![](/assets/images/wix/b523fa4e09-ce7a39_6d52d221d8034e92b0be7c9b0b319d18~mv2.png)

```hlsl
float polarCoord = float(atan2(uv.y, uv.x) / UNITY_PI) * 0.5 + 0.5;
```





(\-1 \~ 1)에 하프램버트(Half\-Lambert) 공식처럼 0.5를 곱하고 0.5를 더해주면 극축 기준의 각도는 완성됩니다. 다음은 벡터와 원점과의 거리인데 제일 쉬운 부분입니다. (진짜임)

![](/assets/images/wix/ad22167aa2-ce7a39_5df74128d3cc42b98e1d4b5b2c62460b~mv2.png)

```hlsl
float2 polarCoord;
polarCoord.y = length(uv);
```



length() 함수는 원점(0,0)으로 부터의 거리 값을 출력합니다. 이거 하나면 끝입니다.

극축과 이루는 **각도**(Radian) **θ**와 원점과의 **거리 값 r**을 순서쌍으로 나타내는 좌표계니까 UV의 x축에 정규화 한 각도를 집어넣고, y축에는 거리 값을 넣어서 출력해봅시다.

![](/assets/images/wix/b5bc6e94b6-ce7a39_7fce21d1c2cf4a66b3ce21129c4205b7~mv2.gif)

```hlsl
float2 polarCoord = float2(float(atan2(uv.x, uv.y) / UNITY_PI) * 0.5 + 0.5, length(uv));
```





직교좌표계를 극좌표계로 전환했습니다. 극좌표계는 이것으로 완성입니다. 이제는 응용을 해볼 차례인데요, 극좌표 UV에 텍스쳐를 얹어보겠습니다.

(작성중 입니다)
