---
title: "(UnityShader) 07 Fragment Advanced : Flowmap"
date: "2020-08-03T16:49:17.615Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(UnityShader) 07 Fragment Advanced : Flowmap(Hurricane)FlowMap저희는 기나긴 폭풍과 장마의 시련을 겪고 있습니다. Advanced 포스팅 이지만 오늘은 좀 쉽고, 멋진 걸 해볼겁니다. 플로우맵을 써서 위 이미지 처럼 텍스쳐가 원하는 방향으로 영원히 흐르게 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-07-fragment-advanced"
original_modified: "2022-06-12T05:32:31.221Z"
image: "/assets/images/wix/07ed9fff2b-ce7a39_55d3a1c9bc424e0c8414202d95a88d13~mv2.gif"
---

## (UnityShader) 07 Fragment Advanced : Flowmap

![](/assets/images/wix/a4e137081c-ce7a39_a2d174f70ad548ef8cddde3d53ff8cd6~mv2.gif)

(Hurricane)

## **FlowMap**

저희는 기나긴 폭풍과 장마의 시련을 겪고 있습니다. *Advanced* 포스팅 이지만 오늘은 좀 쉽고, 멋진 걸 해볼겁니다. **플로우맵**을 써서 위 이미지 처럼 텍스쳐가 원하는 방향으로 영원히 흐르게 해봅시다.

시작하기 전에 몇 가지 준비물이 필요합니다. 흐르게 할 메인 텍스쳐를 정하시고, 플로우맵을 직관적으로 그릴 수 있게 해주는 [플로우맵 페인터(링크)](<http://teckartist.com/?page_id=107>)을 다운 받습니다.

자세한 플로우맵 페인터 사용법은 마둠파님 블로그를 참고하십시오.

([https://blog.naver.com/mnpshino/221456311217](<https://blog.naver.com/mnpshino/221456311217>))

![](/assets/images/wix/e144a9af27-ce7a39_51ea7715342f40538707a1cd7f670165~mv2.png)

FlowMapPainter.exe를 더블클릭하여 실행합시다. Configuration 창이 뜨는데, 여기서 프로그램 윈도우의 크기를 정해줍시다. (텍스쳐 해상도 아님) 그래픽 퀄리티는 제일 높은 fantastic으로 해주고 \[play!\]를 눌러서 시작합니다.

![](/assets/images/wix/f694e776ca-ce7a39_6d94928b7a6c4dbc86df3e090bc00e00~mv2.png)

기본적으로 빨간 네모처럼 R,G채널을 뒤집어(Flip) 줘야 합니다.

Custom Texture Path: 에 메인 텍스쳐의 경로를 직접 입력합시다. 그 다음 \[*Load Custum Tiling Texture\]*를 눌러 이미지를 가져옵니다. 메인 텍스쳐에 플로우맵이 어떻게 적용될지 미리보는 용도입니다. 이미지가 180도 뒤집어져 있을 건데 포토샵으로 편집해서 방향을 맞춰줍시다.

참고로 커스텀 텍스쳐는 png로 저장해야 로드 오류가 없습니다. 유니티 엔진에서는 targa 포맷으로 할 거지만 말이죠.

![](/assets/images/wix/0482243f2f-ce7a39_f919557bea8c4e4ab51e94f19cdea3af~mv2.png)

적당히 동그랗게 그려준 뒤 *Save to:* 경로를 입력하고 \[*Bake to Texture\]*를 눌러 플로우 맵을 구워(Bake) 줍시다.

- ![](/assets/images/wix/fbfab34c05-ce7a39_5f7efd943c684fc89e0b6d9bf3b79e1c~mv2.svg)
- ![](/assets/images/wix/1b39f09fe3-ce7a39_7d95f9f6e849473db11dd7940433bb2a~mv2.png)
- ![](/assets/images/wix/267c050665-ce7a39_61c35e11f1904c3f94e82705f008f095~mv2.png)

**플로우맵은 R,G채널만 사용하는 float3 데이터 텍스쳐**입니다. 그러니 **sRGB 체크 해제**하고 사용하며 압축도 하지 않습니다. 맵 사이즈는 작을수록 아티팩트(픽셀 찌꺼기)가 적게 생깁니다.

![](/assets/images/wix/e9acf33a5a-ce7a39_765e66417e6f46078bf9e4a38880a606~mv2.png)

플로우맵 텍스쳐를 보면서 색을 숫자로 생각해봅시다. RGB 값이 (128,128,0) 입니다. 그래서 그리지 않아서 UV가 변동이 없는 부분(디폴트)도 짙은 노란색으로 나옵니다. 따라서 코딩으로 플로우맵을 적용 할 때 **0.5만큼 값을 빼주면** 될 것 같습니다.

![](/assets/images/wix/591d5bfb27-ce7a39_3fba1f1d8c5f415c937a7cac6568b0b1~mv2.png)

```hlsl

 sampler2D _MainTex;
 float4 _MainTex_ST;

 sampler2D _FlowTex;
 float4 _FlowTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _FlowTex);
 return o;
            }
```





메인 텍스쳐와 플로우 텍스쳐를 샘플러 변수로 받아 줍시다. 버텍스 쉐이더에서 TRANSFORM\_TEX(uv, tex); 매크로로 프래그먼트 쉐이더에서 tex2D를 사용할 수 있게 해줍시다.

![](/assets/images/wix/a6650e3d32-ce7a39_1eee7e6b107943349650fc137ff51967~mv2.png)

```hlsl

 float4 FlowTex = tex2D(_FlowTex, i.uv1);
 float4 MainTex = tex2D(_MainTex, i.uv + float2(FlowTex.rg) - 0.5);
 
                col.rgb = MainTex.rgb;
                col.a = 1;

 return col;
```





플로우맵을 Maintex의 UV에 더해서 오프셋 이동합니다. 그리지 않은 부분에 오프셋이 적용되지 않도록 FlowTex.rg에서 **0.5만큼 값을 뺍니다.**

![](/assets/images/wix/0bbb855bde-ce7a39_78d80b0454044aec99b5670ec71723b4~mv2.png)

(result)

제대로 적용되었습니다. 다음은 UV가 반복해서 흐르도록 만들어줄 차례입니다. 그러려면 uv에 **타임 함수**를 사용해야 할 것입니다.

![](/assets/images/wix/3d5db32339-ce7a39_ab23713e476542a69ec07980aa21b011~mv2.png)

```hlsl

                _TimeSpeed = _Time.y * _TimeSpeed;

 float4 FlowTex = tex2D(_FlowTex, i.uv1);
 float4 MainTex = tex2D(_MainTex, i.uv + (float2(FlowTex.rg) - 0.5) * frac(_TimeSpeed));
 
                col.rgb = MainTex.rgb;
                col.a = 1;

 return col;
```





## **frac(\_Time.y);**

frac(); 함수는 변수의 *소수점 부분만 반환*하는 단순한 함수입니다. 하지만 \_Time 함수 처럼 영원히 값이 증가하는 함수에 쓰이게 된다면 **0 =&lt; n =&lt; 0.999... n값**을 계속 반환하게 됩니다.

![](/assets/images/wix/a99efbab1e-ce7a39_8ccc81de74254a668079ad37f74064ea~mv2.png)

(세로축은 값, 가로축은 시간. 0\~0.999...를 무한히 반복함)

![](/assets/images/wix/3deca0aa24-ce7a39_6b7a74dec3fa4b49aca734d056b05328~mv2.gif)

(result)

무한히 흐르게 만드는건 성공했지만 시작과 끝이 연결되지 않고 끊어집니다. frac으로 \_Time 함수가 0.999,,,가 다시 0에서 시작하기 때문입니다.

![](/assets/images/wix/46bf61c919-ce7a39_a094b92c09d741b487e9d48561cb1d3e~mv2.png)

## *y = Sin(θ\*|β|\+γ)\*α\+δ*

이것을 해결 하려면 삼각함수의 **Sine 그래프**처럼 루프의 시작점과 끝점의 값이 똑같아야 합니다.

![](/assets/images/wix/897d91c4bd-ce7a39_04bc569a0dc74736829d64d0f6a0e5f1~mv2.png)

```hlsl

 float4 MainTex = tex2D(_MainTex, i.uv + (float2(FlowTex.rg) - 0.5) * frac(_TimeSpeed));
 float4 MainTex_loop = tex2D(_MainTex, i.uv + (float2(FlowTex.rg) - 0.5) * frac(_TimeSpeed + 0.5));
```





중학교 수학시간에 배웠던 대로 함수 그래프에 상수를 더하면 원하는 값 만큼 그래프를 **수평이동** 시킬 수 있습니다. 저희는 0.5만큼 수평이동한 \_Time.y 함수로 플로우맵이 0.5초 만큼 빠르게 진행되는 메인 텍스쳐를 하나 더 만들 것입니다.

![](/assets/images/wix/43796ef023-ce7a39_ede57150d9b04d8998fa05df581a6e1e~mv2.png)

## **lerp****(MainTex, MainTex\_loop, lerpvalue);**

두가지의 메인 텍스쳐를 합치면 위와 같은 모양이 됩니다. 저희는 **선형보간을 통해 메인텍스쳐가 끊어지지 않는 부분을 검출** 해낼 것입니다. 보간에 사용할 인자인 *lerpvalue*의 값은 아래와 같습니다.

![](/assets/images/wix/efa3872e3c-ce7a39_adb1c351391349e899470c6d4f301543~mv2.png)

먼저 frac(\_Time.y)로 똑같이 씁니다.

![](/assets/images/wix/d902190bd2-ce7a39_4fb2af4f80a442e9923e87bf2610da3c~mv2.png)

2를 곱하면 그래프의 **높이가 2배 증가**합니다. 0\~0.999...는 **0\~1.999...**가 됩니다.

![](/assets/images/wix/8c90701387-ce7a39_5c15d9aa66ae4d9191c13441f35264f4~mv2.png)

\-1을 하면 그래프는 **수직이동**합니다. 이제 그래프의 범위는 **음수를 포함하여 \-0.999... =&lt; n =&lt; 0.999...** 입니다.

![](/assets/images/wix/4b2ff3fe25-ce7a39_c32e3ffc837647b69f2dbf57c31cfacb~mv2.png)

```hlsl
float lerpvalue = abs(frac(_TimeSpeed) * 2 - 1);
```





절대값을 반환하는 **abs 함수**를 사용해 음수 부분을 양수 부분으로 꺾어줍니다. 이제 그래프는 0과 0.999... 사이를 왕복하게 됩니다.

![](/assets/images/wix/48bc4b9134-ce7a39_add21fb21a9245719dd5ebd392260566~mv2.png)

![](/assets/images/wix/13792dcca8-ce7a39_f419666c3d0e42bdaa401ba96880261b~mv2.png)

![](/assets/images/wix/07ed9fff2b-ce7a39_55d3a1c9bc424e0c8414202d95a88d13~mv2.gif)

완성입니다. 읽어주셔서 감사합니다.
