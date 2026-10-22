---
title: "(UnityShader) 01 Shader Programming"
date: "2020-04-12T02:49:55.458Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "머릿말쉐이더는 본래 비주얼 스튜디오같은 개발자 도구에서 직접 타이핑하여 코딩하는 방식이 유일 하였습니다. 이유는 단순합니다. 아티스트가 아닌 프로그래머가 개발 했기 때문입니다. Shader Graph 같은 노드 에디터 방식은 아티스트 입장에서 직관적으로 이해할 수 있도록 쉐이더 코드를 이미지와 노드 연결"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-01-shader-programming"
original_modified: "2020-06-03T10:08:38.598Z"
image: "/assets/images/wix/500307cdc0-ce7a39_b9d798de937f4c6e8fc6059ae9913ddd~mv2.jpg"
---

![](/assets/images/wix/500307cdc0-ce7a39_b9d798de937f4c6e8fc6059ae9913ddd~mv2.jpg)

## 머릿말

쉐이더는 본래 비주얼 스튜디오같은 개발자 도구에서 직접 타이핑하여 코딩하는 방식이 유일 하였습니다. 이유는 단순합니다. 아티스트가 아닌 프로그래머가 개발 했기 때문입니다. Shader Graph 같은 노드 에디터 방식은 아티스트 입장에서 직관적으로 이해할 수 있도록 쉐이더 코드를 이미지와 노드 연결로 표현 해주었습니다. (사실 코드가 읽기 편하다는 사람도 많은데, 그 이유는 프로그래머는 수학을, 아티스트는 미학을 전공했기 때문에 서로가 가진 직관과 경험이 다르기 때문입니다) 하지만 개발자 도구로 쉐이더 파일을 열어보면 실제로는 코드 단 한 줄만으로 작동할 기능을 노드를 구성하기 위해 몇 십 스트링 이상으로 분해하고 있다는 것을 볼 수 있습니다.

개발자 도구를 이용한 쉐이더 프로그래밍은 노드 에디터보다 최적화 측면에서 합리적입니다. 게다가 쉐이더 그래프는 아직 개발중이라 노드로 지원되지 않는 코드들이 매우 많습니다. 고급기능을 사용해야하고, 소스코드를 뜯어 보며 연구 개발하려면 결국 노드에 블랙박스로 숨겨져 있는 Low level 로 내려가야 합니다. 당신이 해변에 서있다면 깊은 바다 속 저 아래를 볼 수 없습니다. 심해를 알고 싶다면 수면 아래로 침잠해야 합니다.

## 디지털 가산혼합

[게임 텍스처 이론](</posts/wix-unity-shader-00-game-texture-theory/>) 포스트에서 기술 발전의 역사에 따라 수많은 텍스쳐 포맷이 개발되고 정보량도 다르고 압축 방식도 다르다는 것을 배웠습니다. 예를 들어 PC 게임을 모바일로 이식하자고 해서 DXT5 포맷으로 압축된 RGB24bit 이미지를 ASTC 포맷으로 바꾸면 모든 쉐이더 코딩을 다시 해주어야 할까요? RGB24bit 이미지와 RGB16bit 이미지를 다루는 코드가 달라야 할까요?

![](/assets/images/wix/63e0ee7158-ce7a39_e88ad2e16543441081def5649f115d3d~mv2.png)

이 문제는 가산혼합의 비율으로 쉽게 해결 할 수 있습니다. 여기 RGB 16bit가 있습니다. 채널당 5/6/5 bit입니다. 그래서 64/128/64 단계의 정보를 가지고 있습니다. 모든 RGB 단계가 최대치인 100%라면 결과는 가산 혼합에 따라 흰색입니다. 값을 절반인 50% 으로 줄이면 가산 혼합에 따라 회색입니다. 따라서 RGB 채널이 몇 단계라 하더라도 비율만 같으면 같은 색이라고 판단하는 것 입니다. (물론 정보량의 차이에 따라 정확도의 차이가 있지만)

0\~100%의 비율을 0과 1사이의 소수점으로 표현할 수 있습니다. 그래서 쉐이더에서는 소수점아래 6번째 자리 까지 사용 가능한 실수 부분 표현 체계인 32비트 짜리 **Float**을 사용합니다. 자세한 정보는 [블로그 링크](<http://blog.naver.com/destiny9720/221401558227>) 를 참고하세요.

![](/assets/images/wix/403c7fcbd1-ce7a39_b0ff1060f0de4721bbbc93a26c35b1a6~mv2.png)

float으로 가산혼합의 비율을 표현하고자 한다면 위와 같이 써야 합니다. 채널 하나당 float을 하나씩 배정하기 때문에 float이 세개라는 의미에서 float**3**입니다. 유니티에서는 float은 32비트라 너무 크기 때문에 그보다 작은 수 체계인 **half와 fixed**를 제공합니다. half는 영단어 뜻 그대로 32비트의 절반인 16비트이며 fixed는 11비트입니다.

개발자 도구로 쉐이더 프로그래밍 할 때에도 위와 같은 방식으로 *float3(0,0,0)* 똑같이 타이핑 합니다. 여러분들은 이미 쉐이더 코딩의 첫 발걸음을 뗀 것입니다. 이제는 유니티 엔진에서 사용할 쉐이더 언어에 대해 알아볼 시간입니다.

## 쉐이더 언어 분석

쉐이더 언어의 종류는 크게 세가지로 **HLSL** / **GLSL** / **CG** 입니다. 유니티는 이 세가지를 다 섞어 사용합니다. 더해서, 유니티는 자체 문법인 *ShaderLab* 을 추가하여 프로그래머들이 아티스트가 쉽게 사용할 수 있을 정도로 개발한 스크립트를 포함 시켰습니다. 하지만 배워야할 문법과 언어가 많다고 걱정할 필요 없습니다. 하나만 공부하면 나머지는 다 비슷합니다. 마치 유럽인들이 문화적 언어적 유사성으로 공용어가 2개국어 이상을 기본으로 하는 것과 같습니다.

![](/assets/images/wix/ebd09ff083-ce7a39_cbceaca7e08b46b4b8258a0aa51a4854~mv2.png)

이제 유니티에서 실습을 해봅시다. 유니티 버전은 2019.3.0f3 를 사용했습니다. 프로젝트 창에서 우클릭을 하고 Create \- Shader \- Standard Surface Shader를 클릭합니다.

![](/assets/images/wix/c97a5fcd3e-ce7a39_4bdce5c83c064387ba7c94042f9996fc~mv2.png)

프로젝트창에 이렇게 생긴 아이콘이 생성될 것입니다. 개발자 도구가 설치되어 있다면 아이콘을 더블 클릭 할 시 지정된 개발자 도구로 연결될 것입니다. 저는 VS CODE를 사용했습니다.

![](/assets/images/wix/6a6ccb9e4a-ce7a39_58a18c2cbb254103ae7917116e510239~mv2.png)

50줄 짜리 알록달록한 스트링들이 가득 들어있습니다. 우리 아티스트들은 혼란함을 느낍니다. 영어시간에 잠을 잤던게 후회되는 순간입니다. 하지만 괜찮습니다. 전체를 한번 보면 크게 세부분으로 나눠집니다. 가장 위의 첫번째 줄부터 차근차근 분석해보도록 합시다.

![](/assets/images/wix/c2a44bf7b0-ce7a39_a8956fcc5cac448cab643dd00f956dd8~mv2.png)

```hlsl
Shader "Custom/NewSurfaceShader"
```





먼저 **Shader** 라고 적혀있습니다. 이 문단은 쉐이더가 시작한다는 것을 알립니다. 그 뒤의 "Custom/NewSurfaceShader"는 쉐이더를 부를 이름과 경로를 분류하는 것입니다.

그리고 둘째 줄에 **대괄호 {}** 가 보이는데, 괄호 내부에 있는 코드 들이 모두 쉐이더의 구성 내용인 것입니다.

- ![](/assets/images/wix/44b466280d-ce7a39_3b32ff7f9388485ea3d4f01df6d7d682~mv2.png)
- ![](/assets/images/wix/da385574fb-ce7a39_b88e41cd67434657b91696b331903190~mv2.png)

메테리얼에서 어떤 쉐이더를 사용할 것인지 선택할 수 있는 박스 부분이 존재하는데, 여기서 Custom 안에 NewSurfaceShader가 들어있는 것을 볼 수 있습니다.

![](/assets/images/wix/0be3147415-ce7a39_98e40c38c81d4dbebf2b6b68289a15cb~mv2.png)

참고로 실제 쉐이더 파일 이름과는 다릅니다. 프로젝트 창에서 asdf로 쉐이더 파일 이름을 변경해도 코드 부분에서 지정된 NewSurfaceShader로 분류된 것은 그대로 입니다.

![](/assets/images/wix/45f7d78b66-ce7a39_05a281c22d834abaadab15201bb9357a~mv2.png)

qwer/asdf/Shader 라고 써보면 어떻게 될까요?

![](/assets/images/wix/10591d88df-ce7a39_64ae416992ac451ab04a3ad0343a8aa6~mv2.png)

![](/assets/images/wix/b12fece5b5-ce7a39_6ba125c9f0804f84a9b46be07c6dcbd3~mv2.png)

인스펙터 창에서 이름이 수정된 것은 물론이며 분류도 qwer/asdf 항목이 새로 생성 된 것을 확인 할 수 있습니다.

![](/assets/images/wix/329cfe59e6-ce7a39_db550fcfaad64d328de5c8fcdc0a186f~mv2.png)

다음 문단은 프로퍼티(Property)입니다. 개발자 도구를 사용하지 않고 유니티 내부에서 변수들을 조작할 수 있게 인터페이스를 만들어 주는 부분입니다. 유니티 쉐이더 그래프에서 블랙보드에 변수들을 등록하던 것과 같은 작업입니다.

괄호 안의 첫 줄을 봅시다. \_Color 로 변수 이름을 선언하고 "Color" 로 프로퍼티의 이름을 붙힙니다. 변수에 사용할 자료형 Color를 쓰고 = (1,1,1,1) 으로 디폴트 값을 정해준다는 의미입니다. 기본으로 들어있는 변수명들이 PBR을 공부했다면 익숙할 것입니다.

변수 이름은 underbar '\_' 로 시작하는 것이 정석이며 이미 존재하는 변수명을 사용하면 안 됩니다. 숫자로 시작할 수 없고 특수문자를 쓸 수 없으며 대소문자를 구분하고 같은 이름을 중복 사용 할 수도 없으며 유니티에서 미리 정해둔 변수 이름도 사용하지 못합니다. 이 부분은 유니티 메뉴얼을 참고 하십시오.

\_Color는 말 그대로 색 값이고 \_MainTex는 2D 자료형으로 텍스처 정보를 받아오는 변수입니다. 자세한 자료형 정보는 대부분 유니티 메뉴얼에 존재합니다.

![](/assets/images/wix/d91f0c6c6c-ce7a39_a4d614d25bc149c8a0d63e572162810c~mv2.png)

드디어 SubShader 문단 까지 왔습니다. 여기가 Standard Surface 쉐이더의 내용을 결정하는 부분입니다. **CGPROGRAM** 이라고 써있는 부분 부터 **ENDCG**까지 **CG** 언어로 작성 되어 있습니다. 이제부터는 직접 쉐이더를 편집하여 코드를 써가면서 배워봅시다.

![](/assets/images/wix/5120163498-ce7a39_cf67a13e70ac4943b88941d7aa0e38c1~mv2.png)

//로 시작하는 초록색 스트링은 모두 코멘트(주석) 입니다. 코드 작성자가 코드를 설명하기 위한 낙서 같은 것이지요. 저 부분은 코딩에는 아무런 영향이 없습니다. 그러니 깔끔하게 지워줍시다.

![](/assets/images/wix/d29579130f-ce7a39_0d72592a0a014653b5d54c1a9330f3fb~mv2.png)

다 지우고 나면 이렇게 깔끔하게 남습니다. SubShader 문단은 크게 세가지로 다시 분류됩니다.

빨간색 네모의 Pragma 부분은 설정입니다. 전처리(Pre\-Processing)라고 부르는 영역이며 쉐이더의 조명계산 설정과 기타 세부 분기를 정합니다.

초록색 네모의 struct Input 부분은 'Input' 이라는 이름을 가진 구조체(Structure) 입니다. 엔진에서 받아올 데이터들이 들어갑니다. 대괄호를 사용하고 대괄호 끝에 세미콜론(**;**)이 있다는 것을 주의하면 됩니다.

파란색 네모의 void surf는 *surf*라는 이름의 **'함수'** 입니다. 색상이나 이미지를 출력하도록 하는 부분입니다. 구조체와는 달리 세미콜론으로 끝나지 않습니다.

```hlsl
sampler2D _MainTex;
```





어디에도 속하지 않는 나머지 부분들중 20번 스트링을 봅시다. 우리는 위 문단의 프로퍼티 부분에서 \_MainTex 변수를 받도록 되어 있다는걸 아까 확인 했습니다.

SubShader 문단 중 이 나머지 부분에서 변수가 선언 된다는 점과 \_MainTex의 자료형도 **Sampler2D**이며 프로퍼티의 \_MainTex 또한 **2D**로 일치하는 것을 볼 수 있습니다. 그리고 한 줄이 끝날때 마다 세미콜론을 붙힌다는 점도 있지요.

```hlsl
float2 uv_MainTex;
```



```hlsl
half _Glossiness;
```



```hlsl
half _Metallic;
```



```hlsl
fixed4 _Color;
```



아래 줄의 변수명도 모두 프로퍼티와 이름과 자료형이 같습니다. UNITY\_INSTANCING 부분은 지금은 무시해도 좋습니다.

![](/assets/images/wix/ef576e7e26-ce7a39_345b0602ed2a41c28c35775e317ba681~mv2.png)

```hlsl
void surf (Input IN, inout SurfaceOutputStandard o) {}
```



```hlsl
형식 함수명 ( 입력값 ) {}
```





34번 스트링의 함수 구조를 분석 해 볼 시간입니다. 일반적인 함수의 구조는 위와 같습니다.

void란 return 값이 없는 함수 형식을 말합니다. 출력을 안 한다는 뜻입니다.

surf는 함수의 이름입니다. 이후에 함수를 새로 만들 때 이름을 바꿀 수 있습니다.

input IN \~ o 는 Input 구조체를 IN 이라는 이름으로 함수에 입력(input)받고, SurfaceOutputStandard 라는 구조체를 o 라는 이름으로 입출력(inout) 하겠다는 뜻입니다.

SurfaceOutputStandard 구조체는 여기서 처음 등장하는데, 이 구조체는 유니티 내부에서 자체적으로 정의되어 있는 구조체입니다. 이런 식으로 이미 정해진 변수나 구조체들이 여럿 있습니다.

구조체의 구성은 아래와 같습니다 :

struct SurfaceOutputStandard

{

fixed3 Albedo;

fixed3 Normal;

fixed3 Emission;

half Metallic;

half Smoothness;

half Occlusion;

half Alpha;

}

## 쉐이더 작성하기

목록을 보면 눈치 채겠지만 **PBR**에 필요한 값들로 이루어져 있는 것을 확인 할 수 있습니다. 이제 전부 살펴 봤으니 직접 코드를 써봅시다. 과감하게 대괄호 안쪽 내용을 전부 지웁시다.

![](/assets/images/wix/59e143e734-ce7a39_b51d77ec62924b9eb67c22d57a06e4ad~mv2.png)

이것은 알베도 값이 빨간색으로 출력 되도록 코드를 작성한 것입니다. o**.**Albedo의 마침표 ' . ' 가 궁금하실텐데 SurfaceOutputStandard가 o 라는 것은 위에서 설명하였고, **o의 내부에 있는 Albedo** 값에 접근한다는 뜻 입니다.

![](/assets/images/wix/a37d4547a3-ce7a39_f72c602f1a324726b24c5065208a19c0~mv2.png)

쉐이더를 메테리얼에 연결하고 Sphere에 적용시킨 결과입니다. 그림자를 보니 조명 연산이 들어가 있습니다. 순수한 빨간색을 보려면 어떻게 해야 할까요?

![](/assets/images/wix/cb8b8955d3-ce7a39_3281200cc3b34610addfdd65a85cc482~mv2.png)

![](/assets/images/wix/200fe682aa-ce7a39_b5cb5689a9b5444cb6b49b034291e631~mv2.png)

값을 Emission으로 넣으면 됩니다. Emission은 조명 연산을 하지 않는 Unlit 입니다. 순수한 색만 결과로 나오니 확인하기 편합니다. 이제 응용을 해볼 차례입니다.

```hlsl
o.Emission = float3(1,0,0) + float3(0,1,0);
```





위와 같이 코드를 작성하여 같은 float3 끼리 더해주면 어떻게 될까요?

![](/assets/images/wix/e7ec9db7b9-ce7a39_4d0b093c32b54dd3844f932866904a70~mv2.png)

float3(1,1,0)이 되어 노란색이 나옵니다. 곱셈 덧셈 뺄셈 나눗셈 등의 사칙연산은 모두 적용이 된다는 것을 확인 할 수 있습니다. 1이상의 값이나 음수의 값을 가진 HDR 컬러 역시 제대로 적용됩니다.

![](/assets/images/wix/ab3332311a-ce7a39_61b9de36e52c4572a65219e82cefda64~mv2.png)

변수를 선언하고 마지막에 더하는 식으로 표현하는 것도 가능할까요?

![](/assets/images/wix/dc0dbd4334-ce7a39_ef5a9aaf50f948a2bc2628121acaefdd~mv2.png)

float3(1,1,1)이 되어 흰색이 나옵니다. 정상적으로 작동합니다.

![](/assets/images/wix/2cabbe1635-ce7a39_a6d7b4f1938f4219a4d1ceb6f6a479d7~mv2.png)

마침표를 써서 A라는 float3 변수 속의 r,g,b 값을 가져오라고 코딩 해봅시다.

![](/assets/images/wix/200fe682aa-ce7a39_b5cb5689a9b5444cb6b49b034291e631~mv2.png)

빨간색이 그대로 나옵니다. 그렇다면 .rgb가 아니라 **.grb**라고 쓰면 어떻게 될까요?

![](/assets/images/wix/6ecc191b3c-ce7a39_e6bd8445054249eea70fbc2eb3ed05cb~mv2.png)

![](/assets/images/wix/baf84b649f-ce7a39_8e0fc1afcf4848b2807bb4a599c71a06~mv2.png)

R채널과 G채널이 서로 스위즐링 되어 초록색이 되어 버렸습니다. 따라서 .bbb는 검은색, .rrr은 흰색이 나온다는 결과를 예상 할 수 있습니다.
