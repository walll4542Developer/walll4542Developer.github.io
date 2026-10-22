---
title: "(UnityShader) 04 Shader Programming"
date: "2020-05-10T10:53:26.943Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Vertex Color버텍스란 한글로 번역하면 '정점' 으로서 3D오브젝트를 표현 하기위한 3차원의 점,선,면 개념중 점에 해당하는 것입니다. 이전 렌더링 파이프라인 포스트에서 자세히 다뤘습니다.버텍스에는 여러가지 정보가 들어있습니다. 정점의 순서(index), 좌표(Position), 법선(Normal"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-04-shader-programming"
original_modified: "2020-06-03T10:10:17.058Z"
image: "/assets/images/wix/a80f860964-ce7a39_085a0e3756d04851af6537b49d7a587d~mv2.gif"
---

## Vertex Color

버텍스란 한글로 번역하면 '정점' 으로서 3D오브젝트를 표현 하기위한 3차원의 점,선,면 개념중 점에 해당하는 것입니다. 이전 [렌더링 파이프라인 포스트](</posts/wix-unityshader-01-렌더링-파이프라인/>)에서 자세히 다뤘습니다.

버텍스에는 여러가지 정보가 들어있습니다. 정점의 순서(index), 좌표(Position), 법선(Normal), UV(Texcoord) 그리고 색상(Color)입니다. 사실 더 있는데 지금 다룰만한 것은 아닙니다. 우리는 이들 중 버텍스 컬러를 다룰 것입니다. 버텍스 컬러를 유니티 엔진에서 우리가 볼 수 있게 시각화 하려면 몇가지 준비가 필요합니다.

![](/assets/images/wix/705062810d-ce7a39_81084ee992ba45d2adceb541fb64585f~mv2.png)

버텍스 컬러를 엔진에서 바로 편집하기 위해 Package manager에서 Polybrush라는 패키지를 설치합니다.

![](/assets/images/wix/cd966c868d-ce7a39_cb76202829c649ab87e910b64a07a87d~mv2.png)

```hlsl
float4 color:COLOR;
```





```hlsl
o.Emission = IN.color.rgb;
```





그리고 위와 같이 서피스 쉐이더를 작성합니다.

이제부터 곰곰히 생각해봅시다. 버텍스 데이터는 어디에 있을까요? 데이터가 어떻게 구성되어 있는지는 엔진을 뜯어보질 않았으니 모르지만 **이미 엔진 속에 분명히 어떤 형태로든 존재하고 있을 겁니다.** 그렇다면 원래 있던 데이터를 가져오는 방식으로 처리하면 된다는게 합리적인 생각입니다.

그래서 저희 생각대로 Input 구조체 속에 버텍스 데이터를 그대로 가져올 수 있습니다. 저희는 21번째 스트링의 color:COLOR와 같이 **콜론(:)**이 들어가는 형태의 코드를 처음 사용했습니다. 이것은 **시맨틱(Semantic)**이라고 하며 텅 비어있는 float4 변수인 color에 **:COLOR** 같은 이름표를 붙혀서 지정된 데이터를 받아올 수 있게 하는 것입니다.

그렇다면 컬러 데이터만 가져와도 되는 것일까? 버텍스를 구성하는 나머지 요소(인덱스, UV, 노말 등)는 가져오질 않았는데 쉐이더가 어떻게 처리하는가? 하고 의문이 듭니다.

사실 서피스 쉐이더에서는 디테일한 부분들이 생략되고 간소화 되어 있습니다. 예를 들어 Input 구조체 속의 uv\_MainTex도 뒤에 **:Texcoord** 라는 시맨틱이 생략되어 있는 것이지요.

물론 시맨틱을 붙인다고 해도 float4가 아닌 float2나 float의 경우에는 오류가 납니다. 버텍스컬러는 당연히 RGBA가 모두 들어가는 색상 정보기 때문에 float4로 받는 것입니다. 버텍스 좌표를 가져오고 싶다면 3차원 좌표값이니 float3로 받아오겠죠?

(버텍스 컬러는 엔진에서 예외처리를 해주기 때문에 알파채널을 제외한 float3으로 받는 것이 가능합니다)

Input 구조체 속의 color 속의 rgb 값을 이미션으로 출력하기 위해 IN.color.rgb를 써줍니다.

![](/assets/images/wix/a80f860964-ce7a39_085a0e3756d04851af6537b49d7a587d~mv2.gif)

Polybrush는 위와 같이 유니티 엔진 내부에서 오브젝트의 버텍스 컬러를 실시간으로 칠할 수 있어서 매우 유용하게 사용되는 툴입니다. 이제 준비는 끝났습니다.

![](/assets/images/wix/6859016b3e-ce7a39_386be7088fe3468285a8d4de8aa9791c~mv2.gif)

RGB 채널 별로 나눠서 출력하면 위와 같이 가산혼합을 통해 그레이스케일으로 표현 된다는 것을 알 수 있습니다. 그렇다면 각각의 채널들을 이용해 텍스쳐들을 선형 보간으로 섞을수 있지 않을까요?

![](/assets/images/wix/eb3a596bd2-ce7a39_7a220669a49846f9a4eeaf999dd287e4~mv2.png)

버텍스 컬러의 RGB 채널을 사용할 계획이니 기본 텍스처 하나와 각각 R,G,B에 대응하는 텍스처를 준비하여 총합 4개의 텍스처를 넣을 수 있게 쉐이더를 작성합니다.

![](/assets/images/wix/110ed7dcbf-ce7a39_039e6c6f8fd141ae9f324a20addb83bc~mv2.png)

![](/assets/images/wix/50b92db5c1-ce7a39_8838c0973bd144c68bb78e9a47432ea2~mv2.png)

선형 보간 함수를 사용하여 기본 텍스쳐와 첫번째 텍스쳐를 선형 보간하고, **결과물인 o.Albedo와** 두번째 텍스쳐를 다시 선형 보간하는 식으로 합쳐줄 수 있습니다.

그런데 선형 보간 함수를 쓰지 않고 동일한 결과를 내려면 어떻게 해야 될까요?

![](/assets/images/wix/118c81ba65-ce7a39_33de4587e14c42cda9212d3e0dbf2281~mv2.png)

저희에게는 채널 당 0\~1 사이의 데이터가 있습니다. 즉 채널과 텍스처를 곱셈 하면 검은색 부분은 보이지 않고 흰색 부분은 보이게 됩니다. 포토샵 마스킹의 원리와 선형 보간은 본질적으로 같은 것입니다.

하지만 이렇게 하면 기본 텍스쳐의 색에 나머지 텍스쳐의 색이 더해져서 **1 이상의 색상 값**이 생기게 됩니다. r값도 1, g값도 1, b값도 1인 버텍스가 있다면 그 부분의 색상 값은 무려 네개의 텍스처가 겹쳐진 값입니다.

이 문제를 해결하려면 1이상의 값이 생긴 만큼 기본 텍스처를 색에서 빼줘야 합니다.

![](/assets/images/wix/a7447dbb3e-ce7a39_5b9c91ff0d8243e28c001a4ba91c6789~mv2.png)

위와 같이 쉐이더 코드를 작성하면 lerp 함수를 쓰지 않아도 선형 보간 함수 공식과 같은 결과가 출력됩니다.

다음은 노말맵을 넣어봅시다.

![](/assets/images/wix/f04293c42c-ce7a39_03bf93c83d524fd39f581c126a2a74c6~mv2.png)

```hlsl
fixed3 N = UnpackNormal(tex2D(_Normalmap, IN.uv_Normalmap));
```





노말맵의 코드는 일반적인 텍스처를 받아오는 코드와 조금 차이가 있습니다. 프로퍼티에서 "bump"를 써야 하는데 노말맵도 이미지니까 샘플러와 uv도 있어야 합니다. 알파 채널을 사용하지 않기 때문에 float3로 받아오고 **UnpackNormal();** 이라는 특이한 함수를 사용합니다. 자세한 내용은 [노말맵의 원리와 처리에 관한 포스트](</posts/wix-unityshader-부록-urp-normal-map/>)에서 다루겠습니다.

![](/assets/images/wix/0bfdf64621-ce7a39_a1752431e1664703b848e1631fba3692~mv2.png)

넣어줄 노말맵의 텍스처 타입을 'Normal map'으로 설정 해줍시다.

![](/assets/images/wix/c59aebac87-ce7a39_ab305c1aaa8f46a3864c2288176bd4bc~mv2.png)

노말맵이 적용된 모습인데 영 시원찮습니다. 노말맵이 더 강력하게 적용되도록 노말맵의 세기를 강하게 만들어 봅시다.

![](/assets/images/wix/eebbb5b442-ce7a39_3a0ba47ca620401296eb4f78f4cb7263~mv2.png)

노말맵의 원리는 각 픽셀마다 반사 되는 빛의 방향(벡터)를 인위적으로 수정하는 것입니다. 3차원 '단위 벡터' 데이터를 텍스처로 조절하기 위해 r채널과 g채널의 색상 데이터를 벡터로 사용합니다. 따라서 R채널과 G채널 값만 있으면 된다는 것이죠.

그래서 위와 같이 노말맵을 float3로 각 채널별로 분해 해주는 과정이 필요합니다. \_Normalstrength 라는 변수를 하나 만들고 프로퍼티로 선언해줍시다.

![](/assets/images/wix/e369842cbc-ce7a39_4a4596034ae84a1d8eba768d2236b920~mv2.gif)

이제 노말이 아주 과장 되었습니다. 사실 위 자료화면의 노말맵의 강도는 제대로 된 수치가 아닙니다. 노말 벡터가 \-1\~1 사이의 값이어야만 정상적으로 작동하는데 그 이상으로 값이 커지면 노말 벡터가 폴리곤 반대 쪽으로 뒤집혀 버려서 검은색만 나오게 됩니다.

PBR의 러프니스 값을 적용하여 노말이 잘 보이게 해봅시다.

![](/assets/images/wix/e916c08978-ce7a39_049afe1bb56c4581948d7f51e1021d90~mv2.gif)

![](/assets/images/wix/a8444e0694-ce7a39_56f1c3992d474e11bbccb02a10a5ffd5~mv2.png)

```hlsl
o.Smoothness = 1 - _Roughness;
```





PBR의 Roughness(거침)는 유니티에서는 완전 반대의 개념인 Smoothness(부드러움) 입니다. 그래서 스무스니스는 러프니스의 값을 반전한 1 \- Roughness 랑 똑같습니다.

![](/assets/images/wix/40743ac97d-ce7a39_9572a7b4214944e2b8af7c6ecf10359e~mv2.gif)

```hlsl
fixed3 N = UnpackNormal(tex2D(_Normalmap, IN.uv_Normalmap + _Time.y * _Timespeed));
```





타임 함수를 넣어서 노말맵이 움직이게 응용 할 수 있습니다.

![](/assets/images/wix/bbb077f655-ce7a39_a2bb804b887642e09c0f21bf3c3cd371~mv2.gif)

![](/assets/images/wix/9302e7e0ae-ce7a39_9c3c4a9d95b441528b157f14001620f1~mv2.png)

위와 같이 노말맵을 두개 이상 사용하는 것도 가능하며, 선형보간을 사용하여 특정 노말맵만 움직이게 하는 것과 특정 채널에만 노말맵이 나오도록 마스킹 하는 것도 가능합니다.
