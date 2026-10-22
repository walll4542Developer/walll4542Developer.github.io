---
title: "(UnityShader) Flipbook Texture Sheet Animation"
date: "2020-10-21T08:12:57.965Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(Flipbook)이번 포스트에서는 플립북(Flipbook) 방식 애니메이션을 셰이더로 작성해보려고 합니다. 플립북이란? 책 모서리에 매 페이지마다 순서대로 그림을 그려서 빠르게 넘기면 마치 움직이는 것처럼 보이게 됩니다.(Example)목표는 아래와 같습니다.1. 원하는 텍스쳐 시트 크기를 지정 할 수"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-flipbook-texture-sheet-animation"
original_modified: "2022-12-25T03:39:56.318Z"
image: "/assets/images/wix/050ed8ecdd-ce7a39_a4262f864f334c55aef4d503a67e4e6e~mv2.gif"
---

![](/assets/images/wix/03df350fdc-ce7a39_e4ff45dc3e6d4bc38eec67b03c3ce45b~mv2.png)

(Flipbook)

이번 포스트에서는 플립북(Flipbook) 방식 애니메이션을 셰이더로 작성해보려고 합니다.

플립북이란? 책 모서리에 매 페이지마다 순서대로 그림을 그려서 빠르게 넘기면 마치 움직이는 것처럼 보이게 됩니다.

![](/assets/images/wix/050ed8ecdd-ce7a39_a4262f864f334c55aef4d503a67e4e6e~mv2.gif)

(Example)

목표는 아래와 같습니다.

1. 원하는 텍스쳐 시트 크기를 지정 할 수 있게 할 것. (예제는 4 by 4 크기)
2. 흐르는 속도를 조절 할 수 있게 할 것. (유니티 타임 함수 단위)
3. 흐르는 방향을 마음대로 바꿀수 있을 것. (기본 왼쪽 위에서 오른쪽 아래로. 그리고 역순)
4. 애니메이션이 왼쪽 위에서 부터 시작 할 것. (첫번째 프레임이 항상 '1'부터)
5. 원하는 프레임 까지만 재생하게 할 것. (n번째 프레임 이상은 재생하지 않고 다시 1번째로 순환)

![](/assets/images/wix/1c36e0fa49-ce7a39_4b12f4154a554b528d5d508d2106c2c1~mv2.png)

(Texture Sheet)

셰이더를 작성하면서 프레임 전환 순서를 알아보기 쉽도록 위의 텍스쳐를 사용 할 것입니다.

![](/assets/images/wix/f4346cc2b8-ce7a39_271cb0efcd754563a302a540044c32ad~mv2.png)

UV를 사용할 것이니 타일링(Tiling, multiply)이나 오프셋(offset, add)에도 문제 없도록 텍스쳐의 WrapMode는 **'Repeat'**로 해줍시다.

텍스쳐의 타일링 수치만 조절해서 텍스쳐 시트의 16개의 타일 중 딱 하나만 출력 되도록 해봅시다. 꼭 첫번째 타일이 아니라도 괜찮습니다.

![](/assets/images/wix/a6daa9c480-ce7a39_36d0fc7ca8484f9c9498b0b63a779b4a~mv2.gif)

타일링 수치를 0.25(1/4)로 하면 텍스쳐 역시 1/4만큼만 남습니다. 그런데 왜 하필이면 13번째 타일이 나왔을까요?

![](/assets/images/wix/4667d4d7ed-ce7a39_0160b94f15a14ea59194c2c0f1a74da1~mv2.png)

OpenGL은 왼쪽 아래가 원점(0,0)으로 설정 되어 있기 때문입니다. 따라서 uv의 V축을 뒤집어야할 필요가 있다는 것을 생각해두고, 일단 **'원하는 텍스쳐 시트 크기를 지정 할 수 있게 할 것'**부터 만들어봅시다.

![](/assets/images/wix/c62d1b3fa2-ce7a39_90884996111041d2996f3bf366b09fcd~mv2.gif)

```hlsl
fixed4 frag (v2f i) : SV_Target
            {
 fixed4 col = tex2D(_MainTex, float2(i.uv.x * (1/_Width), i.uv.y * (1/_Height)));

 return col;
            }
```





가로와 세로의 길이를 파라미터로 만들어서 n by n 정사각형 텍스쳐 시트 뿐만 아니라 가로 혹은 세로가 더 긴 직사각형 텍스쳐 시트(예를 들어 2x3 크기 같은)에도 타일링을 적용 할 수 있도록 만들었습니다. '**원하는 텍스쳐 시트 크기를 지정 할 수 있게 할 것'은 달성입니다.**

그럼 이제 오프셋에는 얼마 만큼 더해야 타일 하나의 단위로 움직이게 될까요?

```hlsl
fixed4 frag (v2f i) : SV_Target
            {
 fixed4 col = tex2D(_MainTex, i.uv * float2(1/_Width , 1/_Height) 
                + float2(_Offset * 1/_Width , 0) );

 return col;
            }
```





타일링 했던 값을 오프셋 값과 곱하여 써주면 됩니다. 문제는 바로 다음의 **'흐르는 방향을 마음대로 바꿀수 있을 것.'** 입니다.

세로는 냅두고 일단 가로만 왼쪽에서 오른쪽으로 흐르게 해봅시다. 13\~16번째 타일을 자동으로 반복하게 말이죠.

![](/assets/images/wix/fbfeea8420-ce7a39_8a8b7f15e19f4c22acb4bcfa07a0009a~mv2.png)

함수는 위와 같이 작성합니다. 시간의 흐름에 따라서 자동으로 애니메이션이 움직여야 하니 유니티 내장 타임(\_Time) 함수를 사용합시다.

하지만 타임 함수의 값은 빌드가 실행된 순간부터 무한히 증가하는 값입니다. 지금 저희는 4x4 크기의 텍스쳐 시트를 사용하는데 오프셋에 들어갈 타임 값이 4를 초과하여 커지게 됩니다.

그래서 저희는 타임 함수의 값이 **0\~3.999** 사이를 반복하도록 **Modulo 함수**와 연결하여 사용할 것입니다.

## fmod(A,B);

Modulo(혹은 Modulus, Mod) 함수는 A를 B로 나누고 남은 나머지 값을 반환합니다. 예를 들어 fmod(1,4) = 1입니다. 4로는 1을 나누지 못하니까요.

연산기호로 하면 '%'로 표현됩니다.

![](/assets/images/wix/d111e11483-ce7a39_0c1f0ee6c7a249e1b442fc21d53ed891~mv2.gif)

B값의 배수가 될 때 마다 0으로 돌아가게 되는 것이죠. 그러니 타임 함수를 A에 놓고 가로 길이를 B에 넣으면 아래와 같이 코딩할 수 있습니다.

```hlsl
float _FrameSpeed = fmod(_Time.y , _Width);
```





위 처럼 하면 소숫점 값이 들어가버리니까 **floor 함수로 내림**하여 나머지 값의 소수점을 버립시다.

```hlsl
float _FrameSpeed = floor(fmod(_Time.y , _Width));
```





![](/assets/images/wix/95586c107e-ce7a39_e175adad827f455abd70d93dac2f7b0b~mv2.gif)

```hlsl
float2 Flipbook (float2 UV, float Width, float Height, float Offset)
            {
 float _FrameSpeed = floor(fmod(_Time.y * Offset, Width));

 float2 tileCount = float2(1,1) / float2(Width, Height);
 float2 tileOffset = tileCount * float2(_FrameSpeed, 0);
 
 return UV * tileCount + tileOffset;
            }

 fixed4 frag (v2f i) : SV_Target
            {
 fixed4 col = tex2D(_MainTex, Flipbook(i.uv, _Width, _Height, _Offset));

 return col;
            }
```





왼쪽에서 오른쪽으로 움직입니다. 타임 함수에 임의의 값을 곱하여 속도를 조절해 줄 수도 있습니다. **'흐르는 속도를 조절 할 수 있게 할 것.'** 은 달성 했습니다.

이제 UV의 세로축과 대응해야 하니 텍스쳐 시트의 크기를 행렬 개념으로 생각해봅시다. 가로가 행(Raw)이고 세로가 열(Column)입니다. 4 by 4 텍스쳐 시트는 4\*4 행렬과 같습니다.

이제 1행을 한바퀴 돌면 원래 1행의 시작점으로 돌아오는 것이 아닌 다음 2행에서 시작하게 해야합니다. 다음 행으로 넘어가는 방법은 똑같이 1/세로 길이 만큼 오프셋 하면 된다는 것은 알고 있습니다.

그러니 오프셋 값이 1행의 4열을 넘어서 1행의 5열 인 것을 인식해서 2행 1열으로 오프셋 해야하는 거죠.

![](/assets/images/wix/eb4fa08524-ce7a39_57469419d614405392e3062bbd813194~mv2.png)

**행렬의 크기(m\*n)**가 곧 텍스쳐 시트에 들어있는 타일의 숫자와 똑같습니다.

```hlsl
float MatrixSize = floor(fmod(_Time.y, Width * Height));
```





그렇다면 4x4 행렬의 크기 값인 16에 아까와 똑같이 floor()와 fmod() 함수를 쓰면 0\~15 만큼 반복됩니다.

그리고 가로 길이의 배수를 인식해야 하니 가로 길이로 '%' 연산 하면? 그대로 풀어쓰면 이렇습니다.

![](/assets/images/wix/ada8c10409-ce7a39_3b61176bc2314b93ae885e7409790a33~mv2.gif)

크기가 0 이고 가로 길이가 4일 때, 오프셋 값은 (0, 0)

크기가 1 이고 가로 길이가 4일 때, 오프셋 값은 (1/4, 0)

크기가 2 이고 가로 길이가 4일 때, 오프셋 값은 (2/4, 0)

크기가 3 이고 가로 길이가 4일 때, 오프셋 값은 (3/4, 0)

크기가 4 이고 가로 길이가 4일 때, 오프셋 값은 (0, 1/4)

크기가 5 이고 가로 길이가 4일 때, 오프셋 값은 (1/4, 1/4)

크기가 6 이고 가로 길이가 4일 때, 오프셋 값은 (2/4, 1/4)

크기가 7 이고 가로 길이가 4일 때, 오프셋 값은 (3/4, 1/4)

크기가 8 이고 가로 길이가 4일 때, 오프셋 값은 (0, 2/4)

크기가 9 이고 가로 길이가 4일 때, 오프셋 값은 (1/4, 2/4)

크기가 10 이고 가로 길이가 4일 때, 오프셋 값은 (2/4, 2/4)

크기가 11 이고 가로 길이가 4일 때, 오프셋 값은 (3/4, 2/4)

크기가 12 이고 가로 길이가 4일 때, 오프셋 값은 (0, 3/4)

크기가 13 이고 가로 길이가 4일 때, 오프셋 값은 (1/4, 3/4)

크기가 14 이고 가로 길이가 4일 때, 오프셋 값은 (2/4, 3/4)

크기가 15 이고 가로 길이가 4일 때, 오프셋 값은 (3/4, 3/4)

바로 셰이더 코딩으로 변환 해봅시다.

```hlsl
float MatrixSize = floor(fmod(_Time.y * Offset, Width * Height));
float U = fmod(MatrixSize, Width);
float2 tileCount = float2(1,1) / float2(Width, Height);
float2 tileOffset = float2(tileCount.x * U, tileCount.y);
```





따라서 U는 **fmod(MatrixSize,Width) \* 1/Width**로 처리하면 **0\~3/4**를 순환하게 되겠죠?

그럼 V는 **floor(****MatrixSize/Width****) \* 1/Height** 로 처리하면 **0\~3/4**로 순환하겠네요.

![](/assets/images/wix/2a4886f854-ce7a39_6967cbcde67344648eba6fd0a4c16796~mv2.gif)

floor(0/4) = 0		floor(4/4) = 1		floor(8/4) = 2		floor(12/4) = 3

floor(1/4) = 0		floor(5/4) = 1		floor(9/4) = 2		floor(13/4) = 3

floor(2/4) = 0		floor(6/4) = 1		floor(10/4) = 2	floor(14/4) = 3

floor(3/4) = 0		floor(7/4) = 1		floor(11/4) = 2	floor(15/4) = 3

```hlsl
float U = fmod(MatrixSize, Width) * tileOffset.x ;
float V = floor(MatrixSize / Width) * tileOffset.y ;
```





이렇게하면 유니티는 OpenGL이니까 세로 방향이 거꾸로 흐릅니다. 그럼 **1\-**로 값을 반전하면 되지 않을까요?

**\[1 \- U\]**

1 \- (fmod(MatrixSize, Width) \* tileOffset.x) = ?

1 \- ( (0%4) \* 1/4) = 1

1 \- ( (1%4) \* 1/4) = 3/4

1 \- ( (2%4) \* 1/4) = 2/4

1 \- ( (3%4) \* 1/4) = 1/4

1 \- ( (4%4) \* 1/4) = 1

1 \- ( (5%4) \* 1/4) = 3/4

...

**\[1 \- V\]**

1 \- (floor(MatrixSize / Width) \* tileOffset.y) = ?

1 \- ( floor(0/4) \* 1/4) = 0

1 \- ( floor(1/4) \* 1/4) = 0

1 \- ( floor(2/4) \* 1/4) = 0

1 \- ( floor(3/4) \* 1/4) = 0

1 \- ( floor(4/4) \* 1/4) = 3/4

1 \- ( floor(5/4) \* 1/4) = 3/4

...

일단 코딩으로 구현해봅시다.

**\[****Toggle****\]** **\_Inverse (****"Invert Direction"****,** **float****) =** **0**

```hlsl
#pragma shader_feature_local _INVERSE_OFF _INVERSE_ON
```





멀티컴파일으로 토글 체크박스를 하나 만듭시다.

```hlsl
float2 _Invert = float2(0,1); // 정방향
#if _INVERSE_ON
_Invert = float2(1,0); // 역방향
#endif

float4 col = tex2D(_MainTex, Flipbook(i.uv, _Width, _Height, _Speed, _Invert));
```





float2를 써서 x,y값으로 각각 u와 v의 방향을 컨트롤 할 것입니다.

float2 Invert가 (1,0)인경우와 (0,1)인 경우가 있습니다. 정방향과 역방향이지요.

```hlsl
float2 Flipbook (float2 UV, float Width, float Height, float Speed, float2 Invert)
            {
 float MatrixSize = floor(fmod(_Time.y * Speed, Width * Height));
 
 float2 tileCount = float2(1,1) / float2(Width, Height);

 float V = abs(Invert.y - (tileCount.y * floor(MatrixSize / Width) ) );
 float U = abs(Invert.x - (tileCount.x * fmod(MatrixSize, Width) ) );
 
 float2 tileOffset = float2(U,V);
 return UV * tileCount + tileOffset;
            }
```





float2 Invert에 의해 값이 1 \- x 가 아니라 '0 \- x' 가 됬을 때는 abs() 함수로 절댓값을 반환하게 합니다. 이렇게 하면 값이 음수로 넘어가지 않습니다.

사족으로 **fmod(MatrixSize, Width)**를

```hlsl
(MatrixSize - floor(MatrixSize * tileCount.y) * Width)
```



로 바꿔도 됩니다. 하지만 원래 코드가 읽기 더 쉬우니까 그냥 이대로 합시다. 성능보다 가독성이 더 중요한 경우가 있습니다.

결과를 봅시다.

![](/assets/images/wix/606ed4588c-ce7a39_af12099dab3b4783923e7a50c0b528ba~mv2.gif)

(!?)

역방향이 제대로 안 돌아가고 이상합니다. 문제의 원인을 거꾸로 추적해봅시다.

![](/assets/images/wix/6ae9dc8f0d-ce7a39_b6f4cb86de80406bab82ed4dbc262794~mv2.gif)

1 \- V와 V는 정상적으로 작동 하지만 1 \- U는 안됩니다.

그리고 **'애니메이션이 왼쪽 위에서부터 시작 할 것.'**도 만족하지 못합니다.

```hlsl
float U = abs(Invert.x - (tileCount.x * fmod(MatrixSize, Width) ) );
```





U부터 먼저 코드를 고쳐봅시다. 처음 순서는 U가 **0**으로 시작해야 합니다. 순서를 반전 할 경우에는 끝부터 시작해야 하니 **3/4** 입니다.

그러면 **반전 하지 않을 때는 0을 더하고 값을 반전 했을 때는 1을 더해주면** 될 것 같습니다.

### Invert.x \- (tileCount.x \* (fmod(MatrixSize, Width) \+ Invert.x)) =

반전 하지 않을 경우,

- 0 \- 1/4 \* ((0%4) \+0)) = 0
- 0 \- 1/4 \* ((5%4) \+0)) = 1/4
- 0 \- 1/4 \* ((14%4) \+0)) = 2/4
- 0 \- 1/4 \* ((19%4) \+0)) = 3/4

반전 할 경우,

- 1 \- 1/4 \* ((0%4) \+1)) = 3/4
- 1 \- 1/4 \* ((5%4) \+1)) = 2/4
- 1 \- 1/4 \* ((14%4) \+1)) = 1/4
- 1 \- 1/4 \* ((19%4) \+1)) = 0

U는 된 것 같습니다. V에도 똑같이 해봅시다. 그리고 행의 전환을 인식해야 하니 가로 값도 다르게 해야합니다.

### Invert.y \- (tileCount.y \* (floor(MatrixSize / Width) \+ Invert.y)) =

반전 하지 않을 경우,

- 0 \- 1/4 \* (f(0/5) \+0)) = 0
- 0 \- 1/4 \* (f(6/5) \+0)) = 1/4
- 0 \- 1/4 \* (f(12/5) \+0)) = 2/4
- 0 \- 1/4 \* (f(18/5) \+0)) = 3/4

반전 할 경우,

- 1 \- 1/4 \* (f(0/5) \+1)) = 3/4
- 1 \- 1/4 \* (f(6/5) \+1)) = 2/4
- 1 \- 1/4 \* (f(12/5) \+1)) = 1/4
- 1 \- 1/4 \* (f(18/5) \+1)) = 0

```hlsl
float U = abs(Invert.x - (tileCount.x * (fmod(MatrixSize, Width) + Invert.x) ) );
float V = abs(Invert.y - (tileCount.y * (floor(MatrixSize/ Width) + Invert.y) ) );
```





**\[0 \- U\]** (abs 함수는 표기 생략) 정방향

Invert.x \- (tileCount.x \* (fmod(MatrixSize, Width) \+ Invert.x)) = ?

0 \- (1/4 \* ((0%4) \+0)) = 0

0 \- (1/4 \* ((1%4) \+0)) = 1/4

0 \- (1/4 \* ((2%4) \+0)) = 2/4

0 \- (1/4 \* ((3%4) \+0)) = 3/4

0 \- (1/4 \* ((4%4) \+0)) = 0

0 \- (1/4 \* ((5%4) \+0)) = 1/4

0 \- (1/4 \* ((6%4) \+0)) = 2/4

0 \- (1/4 \* ((7%4) \+0)) = 3/4

...

**\[1 \- U\]** 역방향

Invert.x \- (tileCount.x \* (fmod(MatrixSize, Width) \+ Invert.x)) = ?

1 \- (1/4 \* ((0%4) \+1)) = 3/4

1 \- (1/4 \* ((1%4) \+1)) = 2/4

1 \- (1/4 \* ((2%4) \+1)) = 1/4

1 \- (1/4 \* ((3%4) \+1)) = 0

1 \- (1/4 \* ((4%4) \+1)) = 3/4

1 \- (1/4 \* ((5%4) \+1)) = 2/4

1 \- (1/4 \* ((6%4) \+1)) = 1/4

1 \- (1/4 \* ((7%4) \+1)) = 0

...

**\[0 \- V\]** 역방향

Height \* Invert.y \- (tileCount.y \* (floor(MatrixSize/ Width) \+ Invert.y)) = ?

0 \- (1/4 \* (f(0/4) \+ 0)) = 0

0 \- (1/4 \* (f(1/4) \+ 0)) = 0

0 \- (1/4 \* (f(2/4) \+ 0)) = 0

0 \- (1/4 \* (f(3/4) \+ 0)) = 0

0 \- (1/4 \* (f(4/4) \+ 0)) = 1/4

0 \- (1/4 \* (f(5/4) \+ 0)) = 1/4

0 \- (1/4 \* (f(6/4) \+ 0)) = 1/4

0 \- (1/4 \* (f(7/4) \+ 0)) = 1/4

...

**\[1 \- V\]** 정방향

Height \* Invert.y \- (tileCount.y \* (floor(MatrixSize/ Width) \+ Invert.y)) = ?

1 \- (1/4 \* (f(0/4) \+ 1)) = 3/4

1 \- (1/4 \* (f(1/4) \+ 1)) = 3/4

1 \- (1/4 \* (f(2/4) \+ 1)) = 3/4

1 \- (1/4 \* (f(3/4) \+ 1)) = 3/4

1 \- (1/4 \* (f(4/4) \+ 1)) = 2/4

1 \- (1/4 \* (f(5/4) \+ 1)) = 2/4

1 \- (1/4 \* (f(6/4) \+ 1)) = 2/4

1 \- (1/4 \* (f(7/4) \+ 1)) = 2/4

...

된 것 같은데요?

![](/assets/images/wix/aa29433a40-ce7a39_5efa7cc4e7bb46548c0418dddbd5678a~mv2.gif)

![](/assets/images/wix/4cd08c1776-ce7a39_e31d17d4019549d2b16cd8cba93d0f71~mv2.gif)

(깔끔)

이렇게 하면 역방향으로 재생할 때는 UV(3/4, 0)기 때문에 16번 타일부터, 정방향으로 재생할 때는 UV(0, 3/4)이기 때문에 1부터 나옵니다. 이걸로 **'애니메이션이 왼쪽 위에서부터 시작 할 것.'** 도 만족했습니다.

이제 '**원하는 프레임 까지만 재생하게 할 것.'** 을 해봅시다.

```hlsl
 float2 Flipbook (float2 UV, float Width, float Height, float Speed, float2 Invert)
            {
                Speed = fmod(Speed, Width * Height);

 float2 tileCount = float2(1,1) / float2(Width, Height);

 float U = abs(Invert.x - (tileCount.x * (fmod(Speed, Width) + Invert.x) ) );
 float V = abs(Invert.y - (tileCount.y * (floor(Speed / Width) + Invert.y) ) );
 
 float2 tileOffset = float2(U,V);
 return UV * tileCount + tileOffset;
            }

float4 frag (v2f i) : SV_Target
            {
                _Invert = float2(0,1); // 정방향
                #if _INVERSE_ON
                _Invert = float2(1,0); // 역방향
                #endif

 float Frame = floor(fmod(_Time.y * _Speed, _Maxframe));
 float4 col = tex2D(_MainTex, Flipbook(i.uv, _Width, _Height, Frame, _Invert));

 return col;
            }
```





```hlsl
float Frame = floor(fmod(_Time.y * _Speed, _Maxframe));
```





이렇게 하면 원하는 프레임(\_Maxframe)만큼만 재생되게 할 수 있습니다.

```hlsl
Speed = fmod(Speed, Width * Height);
```





지정한 프레임이 행렬의 최대 크기를 넘지 않도록 % 연산 해줍시다.

```hlsl
float4 col = tex2D(_MainTex, Flipbook(i.uv, _Width, _Height, _int, _Invert));
```





타임 함수를 사용하는 Frame 대신 **임의의 int값**을 집어 넣어서 원하는 번호의 타일만 보여줄 수 도 있습니다. **'원하는 프레임 까지만 재생하게 할 것.'** 까지 모든 목표를 달성 했습니다.

![](/assets/images/wix/050ed8ecdd-ce7a39_a4262f864f334c55aef4d503a67e4e6e~mv2.gif)

완성입니다. 읽어주셔서 감사합니다.
