---
title: "(UnityShader) 03 Post process Shader"
date: "2020-06-28T09:47:27.739Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "서론이번 포스트에서는 소벨 필터를 통한 후처리 쉐이더 코드 작성을 합니다.이번엔 작성할 코드가 많기 때문에 처음으로 저희는 자체제작 함수(Custom Function)를 만들어서 모듈화 시킬 것입니다. 커스텀 펑션으로 데이터를 다루는 것은객체지향 프로그래밍(Object-Oriented Programmin"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-03-post-process-shader"
original_modified: "2020-09-14T07:49:22.327Z"
image: "/assets/images/wix/7f9e4ecd4a-ce7a39_8088b054450e4c81aead4198c75f554e~mv2.gif"
---

## **서론**

이번 포스트에서는 소벨 필터를 통한 후처리 쉐이더 코드 작성을 합니다.

이번엔 작성할 코드가 많기 때문에 처음으로 저희는 자체제작 함수(Custom Function)를 만들어서 **모듈화** 시킬 것입니다.

커스텀 펑션으로 데이터를 다루는 것은*객체지향 프로그래밍*(Object\-Oriented Programming)이라는 개념인데, 저희같은 초보 아티스트가 이해하기 쉽게 3D 배경 모델러의 업무를 비유로 들어보겠습니다.

대뜸 하늘 같으신 AD님이 모델러에게 아래와 같은 건물 오브젝트를 원화를 보여주며 "내일까지 만들어라!" 라고 살벌한 오더를 내려주셨습니다.

![](/assets/images/wix/c002434025-ce7a39_74293e4f19674145874da71f785a098f~mv2.jpg)

[(아트스테이션에서 아무거나 집어온 원화 링크)](<https://www.artstation.com/artwork/3r2rv?utm_campaign=digest&utm_medium=email&utm_source=email_digest_mailer>)

이제 모델러가 가장 먼저 할 일은 프로젝트가 어떤 아트 스타일을 지향하고 있는지 숙지하고, 여유가 좀 있다면 관련 건축 양식 자료도 찾아보고, 해서 원화 속 오브젝트들의 형태를 분석합니다. 다음은 가장 자연스럽게 표현할 수 있는 최적의 폴리곤 구조를 머릿속에서 재구성합니다.

그런데 원화 속에서 반복되는 부분들이 있습니다. 잘 설계한다면 리소스에 들이는 노력을 줄일 수 있을 것 같기도 하고 작업 시간도 단축되고, 수정하기도 용이하고, 그리고 따로 몇조각을 떼어내서 여차하면 나중에 다른 오브젝트에 재사용 할 수 도 있을 것 같습니다!

![](/assets/images/wix/249f237291-ce7a39_b9c6092157c24c3da5d3430ceb21e62f~mv2.jpg)

(반복 구조와 분리 가능한 부분 찾아내기)

쉐이더 코드에서도 이러한 반복되는 부분이나 나중에 재사용할 수 있을 부분을 캐치해서 재사용이 가능하게 하고 가독성 좋게 코드를 작성 할 수 있는 것입니다.

## **커스텀 펑션 제작하기**

![](/assets/images/wix/0ddc6a031a-ce7a39_0d6c1eb03be9480588c143504d5d03d0~mv2.png)

(뎁스 버퍼와 노말 버퍼 코드)

이전 포스트에서 카메라를 통해 깊이 값과 노말 값을 가진 뎁스, 노말 버퍼 텍스쳐를 얻는 코드를 작성했었습니다. 저희는 이 부분을 함수로 만들어서 재사용 하고자 합니다.

![](/assets/images/wix/df856999cd-ce7a39_a82877c36f2b4b68878df10857d7be0c~mv2.png)

(*ExtractDepthMap*)

```hlsl
float ExtractDepthMap (float2 DepthUV)
            {
 float result;

 float4 depthNormal = tex2D(_CameraDepthNormalsTexture, DepthUV);
 //뎁스 노말 텍스쳐 맵핑
 DecodeDepthNormal(depthNormal, cameraDepth, cameraNormal);
                cameraDepth = cameraDepth * _ProjectionParams.z;
 //_ProjectionParam.z는 카메라의 Clipping planes의 0 ~ far 값 리니어 데이터

                result = cameraDepth;

 return result;
            }
```





함수의 형태는 위와 같습니다. 첫번째 줄부터 차근차근 봅시다. *ExtractDepthMap*이 바로 **함수의 이름**(함수명)이고 함수의 이름 앞에 계산이 다 끝난 자료의 크기가 float 이라고 미리 정의하는 것입니다.

```hlsl
return result;
```





버텍스/프래그먼트 쉐이더의 frag 함수와 똑같이 함수의 결과물 역시 *return*으로 정의됩니다. 이것을 함수가 계산한 결과물을 **반환(return)** 한다고 부릅니다. (*Void* 키워드를 사용하여 *return*이 없게 함수를 짜는 것도 가능합니다)

(float2 DepthUV)

함수명 뒤에 *(float2 DepthUV)*라고 쓰인 부분은 함수 밖에서 계산을 위해 필요한 변수를 받아올 수 있는 입구를 만들어준 것입니다. 이것을 **인풋(Input)**이라고 부릅니다. 자연스레 return은 출구인 셈입니다. 이렇게 작성하면 float2 DepthUV에는 무엇이든지 float2 라면 인풋으로 들어올 수 있는 것입니다.

하지만 주의할 점이 있습니다. 인풋으로 선언된 변수명이 이미 함수 밖에 선언(전역 변수) 되어 있을 경우(DepthUV라는 이름이 이미 어디선가 다른곳에서 쓰이고 있을 경우) 기본값(default)이 됩니다.

```hlsl
float result;
```





함수 내부에 변수를 선언해 줄 수도 있습니다. 여기서 선언된 변수는 함수 내부에서만 존재하고 동작합니다. 이것을 **'지역 변수'** 라고 합니다.

지역 변수는 함수 내부에서 선언된 변수로, 함수가 실행되면 만들어지고 함수가 종료되면 소멸하는 변수입니다. 전역 변수는 함수 외부에서 선언된 변수로, 쉐이더 코드 전체에서 접근 할 수 있는 변수입니다.

이전 포스트에서는 인풋으로 스크린 스페이스 UV를 넣었습니다. 하지만 저희는 미분으로 변화량을 측정하기 위해서, 뎁스 버퍼 텍스쳐를 1픽셀씩 상하,좌우,대각선(3x3)으로 움직인 버퍼 텍스처 UV를 만들 것입니다.

그래서 자기자신인 원본 UV(0,0)을 제외한 여덟번의 연산 반복이 필요하기 때문에 함수로 만들어 주었습니다. 다음은 버퍼 텍스처에서 픽셀 하나만큼 움직인 UV 데이터를 추출해내는 과정이 필요합니다. 역시 여덟번 반복해야 하기 때문에 함수로 작성해줍시다.

![](/assets/images/wix/b13b95f133-ce7a39_07ddddba7045421186b71ea3cf044cff~mv2.png)

(*GetOffsetPixel*)

```hlsl
float2 GetOffsetPixel (float2 OffsetDirection, float _LineWidth, float2 InvSize)
            {
 float2 result =  _uv + OffsetDirection * _LineWidth * InvSize;

 return result;
            }
```





![](/assets/images/wix/f46adc3875-ce7a39_e78287613b184e3f93ea850a8b6b73cf~mv2.png)

(3x3 UV Offset Pixel)

함수의 이름은 GetOffsetPixel 입니다. 상하, 좌우, 대각으로 1픽셀 씩 움직인 UV데이터를 얻기위해 float2 OffsetDirection에는 위 자료와 같은 UV 좌표 이동이 필요합니다.

여기에 \_LineWidth라는 임의의 변수를 곱해줌으로서 외곽선의 굵기를 조절할 수 있습니다.

invSize 변수는 버퍼 텍스쳐의 해상도 값(역수)이 들어갈 것입니다.

```hlsl

 float4 _CameraDepthNormalsTexture_TexelSize;
```





```hlsl
InvSize = float2(_CameraDepthNormalsTexture_TexelSize.x, _CameraDepthNormalsTexture_TexelSize.y);
```





**정말 신기하게도 float4 (텍스쳐 변수명)\_TexelSize**로 변수를 선언하면 다음과 같은 값이 자동적으로 float4로 들어옵니다. 유니티 엔진에서 자체적으로 지원해 주는 기능인지, HLSL에 내장된 기능인지, include된 UnityCG.cginc에 들어있는 기능중 하나인지는 모르겠지만 어떤 텍스처에 사용해도 문제없이 동작합니다.

- **x** = 1/Width (텍스쳐 해상도 너비의 역수)
- **y** = 1/Height (텍스쳐 해상도 높이의 역수)
- **z** = Width (텍스쳐 해상도 너비)
- **w** = Height (텍스쳐 해상도 높이)

우리가 받아온 뎁스, 노말 버퍼 텍스쳐는 실시간으로 카메라에 의해 촬영되고 있습니다. 따라서 실제 게임 플레이 화면 해상도와 다르지 않습니다. 변수명 이름 그대로 텍셀의 사이즈, 즉 화면 해상도인 것입니다.

따라서 텍셀사이즈.xy는 float2(1/Width, 1/Height)입니다. 그리고 \_uv 변수는 **실제 화면 해상도와 똑같은 크기의 Source인 \_Maintex의 '스크린 스페이스 UV'(i.uv)** 입니다.

잠깐 멈춰봅시다. 아무 변화없는 원본(0,0)인 스크린 스페이스 UV에 해상도의 역수를 더하면 어떻게 될까요? 쉐이더 기본기를 다시 생각 해볼 때가 왔습니다.

UV에 임의의 값을 (\*)곱하면? UV가 임의의 값 만큼 확장되서 타일링이 됩니다.

UV에 임의의 값을 (\+)더하면? UV가 임의의 값 만큼 이동해서 오프셋이 됩니다!

![](/assets/images/wix/e43d13b1be-ce7a39_19ecee8338cd40358b0163ac6d42bfbf~mv2.gif)

쉐이더 프로그래밍 03 포스트

([https://walll4542.wixsite.com/watchthis/post/unityshader\-03\-shader\-programming](</posts/wix-unityshader-03-shader-programming/>))

> 따라서 텍스쳐 전체가 같은 비율 그대로 움직이게 됩니다. 이것을 오프셋(Offset)이라고 합니다.

비율로 따져서 1/Width 만큼의 값이 U에 더해지고 1/Height 만큼의 값이 V에 더해지면 1px(픽셀)만큼 오프셋 이동하는 것이 됩니다. 거기에 float2(x,y)만큼 곱해서 움직일 방향을 정해줄 수 있습니다.

그러기 위해 곱해주는 변수가 바로 float2 OffsetDirection입니다. 예를 들어 OffsetDirection값이 (\-1,0)이라면 왼쪽으로 1픽셀 이동한 UV를 얻게 됩니다.

이렇게 우리가 필요했던 UV 데이터의 원본을 제외하고 여덟개를 얻어냈습니다. 다음은 8개의 UV를 성분으로 가상의 3x3 행렬을 만들어 합쳐줍시다.

![](/assets/images/wix/0b34b4884c-ce7a39_3f35fae9e1484c12bf25fc986b7d50fa~mv2.png)

(CombineMap)

```hlsl

 float3 CombineMap (float3 Row0, float3 Row1, float3 Row2, 
 float3 TopLeft, float3 TopCenter, float3 TopRight, 
 float3 MidLeft, float3 MidCenter, float3 MidRight, 
 float3 BotLeft, float3 BotCenter, float3 BotRight)
            {
 float3 result =
                Row0.r * TopLeft +
                Row0.g * TopCenter +
                Row0.b * TopRight +

                Row1.r * MidLeft +
                Row1.g * MidCenter +
                Row1.b * MidRight +

                Row2.r * BotLeft +
                Row2.g * BotCenter +
                Row2.b * BotRight;

 return result;
            }
```





먼저 각각의 UV 데이터를 저장할 3x3 = 9개의 변수가 필요합니다. 코드를 읽기 힘든 저희 아티스트들의 '시각적 직관성'을 위해서 저는 전역 변수로 선언했습니다.

float3 Row0,1,2는 또 다른 9개의 데이터를 담기 위한 변수입니다. 바로 **소벨 필터(Sobel Filter)**입니다. 함수 이름이 *CombineMap*인 이유 입니다. 여기서 소벨 필터 값만큼 수직으로 한번 수평으로 한 번 가중치를 줘서 필터링을 한 뒤 변화량을 측정할 것입니다.

![](/assets/images/wix/4e8c341b1f-ce7a39_7da05a8d08664fe5b68a34f59c2e6b32~mv2.png)

(Sobel filter를 위해 가상으로 만든 행렬 구조, 
행과 열이 뒤바뀌어도 순서만 맞으면 상관 없습니다)

필터를 3x3보다 더 확장하고 싶다면 변수 숫자를 수정하면 됩니다. 5x5 = 25개의 변수가 필요하고 7x7 = 49개가 필요하겠죠?

이제 지금까지 작성한 커스텀 펑션들을 사용하여 더 큰 커스텀 펑션으로 묶어 하나로 만듭시다!

![](/assets/images/wix/077197126e-ce7a39_8a2a525a8b7a447ba19206107bcd9c64~mv2.png)

```hlsl

 /////////////////////////////////////////////////////////////////////////////////////
 //SOBEL Operation
 float SobelDepthOperation (float _LineWidth, float _Maxwidth)
            {
 float result;
 // 3x3 Top Mid Bot * Left Center Right
 float2 TL = GetOffsetPixel(float2(-1,-1), _LineWidth, InvSize);
 float2 TC = GetOffsetPixel(float2(-1,0), _LineWidth, InvSize);
 float2 TR = GetOffsetPixel(float2(-1,1), _LineWidth, InvSize);

 float2 ML = GetOffsetPixel(float2(0,-1), _LineWidth, InvSize);
 float2 MC = GetOffsetPixel(float2(0,0), _LineWidth, InvSize);
 float2 MR = GetOffsetPixel(float2(0,1), _LineWidth, InvSize);

 float2 BL = GetOffsetPixel(float2(1,-1), _LineWidth, InvSize);
 float2 BC = GetOffsetPixel(float2(1,0), _LineWidth, InvSize);
 float2 BR = GetOffsetPixel(float2(1,1), _LineWidth, InvSize);

 //Coordinated Depth Map to Pixel
 float3 TopLeft = ExtractDepthMap(TL);
 float3 TopCenter = ExtractDepthMap(TC);
 float3 TopRight = ExtractDepthMap(TR);

 float3 MidLeft = ExtractDepthMap(ML);
 float3 MidCenter = ExtractDepthMap(MC);
 float3 MidRight = ExtractDepthMap(MR);

 float3 BotLeft = ExtractDepthMap(BL);
 float3 BotCenter = ExtractDepthMap(BC);
 float3 BotRight = ExtractDepthMap(BR);
 
 //Horizontal
 float3 Horizontal = CombineMap(float3(1,2,1), float3(0,0,0), float3(-1,-2,-1),
                TopLeft, TopCenter, TopRight, 
                MidLeft, MidCenter, MidRight, 
                BotLeft, BotCenter, BotRight);

 //Vertical
 float3 Vertical = CombineMap(float3(1,0,-1), float3(2,0,-2), float3(1,0,-1),
                TopLeft, TopCenter, TopRight, 
                MidLeft, MidCenter, MidRight, 
                BotLeft, BotCenter, BotRight);

                result = saturate(distance(float2(Horizontal.x, Vertical.x), float2(0,0)));
                result = pow(saturate(result * _DepthDistance), _Maxwidth);
 return result;
            }
 /////////////////////////////////////////////////////////////////////////////////////
```





```hlsl
SobelDepthOperation (float _LineWidth, float _Maxwidth);
```





커스텀 펑션을 사용 하는 방법은 다른 함수들과 똑같습니다. **함수이름();**과 괄호안에 들어갈 인풋에 적절한 값을 입력해 주는 것으로 결과 값을 얻을 수 있습니다.

```hlsl
result = pow(saturate(result * _DepthDistance), _Maxwidth);
```





*CombineMap* 커스텀 펑션을 통해 수평으로 한 번, 수직으로 한 번 소벨 필터링하고 이렇게 나온 결과물을 **distance 함수**로 vector2(0,0) 원점으로 부터의 거리를 재서 변화량을 측정(미분)합니다.

이렇게 나온 결과 값을 임의의 변수로 제곱해서 아주 약한 외곽선이 마치 노이즈 처럼 나오는 것을 조절할 수 있게 프로퍼티로 빼줍시다.

![](/assets/images/wix/ef0d6ed90b-ce7a39_6f4497455eb04a04863f74f9c4303ed7~mv2.png)

(frag)

```hlsl
_uv = i.uv;
```



```hlsl
InvSize = float2(_CameraDepthNormalsTexture_TexelSize.x, _CameraDepthNormalsTexture_TexelSize.y);
```



//텍셀 사이즈 (스크린 사이즈) 역수 값

frag{}에는 다음과 같이 써줍시다. *GetOffsetPixel*에 i.uv를 넣어주고 InvSize 변수를 정의해줍시다.

위에서 했던 것과 같은 방식으로 노말 버퍼 텍스쳐로도 커스텀 펑션을 만들고 똑같이 소벨필터로 외곽선을 검출합니다.

```hlsl
float4 Source = tex2D(_MainTex, i.uv);
```



//Source

```hlsl
col.rgb = lerp(Source.rgb, 0, saturate(DepthOutline + NormalOutline));
```



```hlsl
col.a = 1;
```





**Source \_MainTex에 외곽선을 적용하기 위해서 외곽선으로 검출된 픽셀을 마스킹으로 써서 lerp 함수로 합쳐줍시다.**

저는 0을 써서 외곽선을 검은색으로 했는데, 당연히 응용 가능하며 다른 색을 넣을 수도 있고 Source에서 채도나 색조를 변경하여 넣어줄 수도 있습니다.

![](/assets/images/wix/b91c64d25b-ce7a39_1d3c2d1fa4f1444fb31e7da51f23072b~mv2.png)

유니티 엔진에서 play 버튼을 누르거나 game 뷰로 결과물을 확인 가능합니다. 마음에 드는 결과물을 얻기 위해 세부 수치를 조절하려면 위와 같이 C\#스크립트에서 프로퍼티를 빼줘야 합니다.

![](/assets/images/wix/7f9e4ecd4a-ce7a39_8088b054450e4c81aead4198c75f554e~mv2.gif)

완성입니다. 읽어주셔서 감사합니다.
