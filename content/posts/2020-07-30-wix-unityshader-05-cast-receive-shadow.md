---
title: "(UnityShader) 05 Cast & Receive Shadow"
date: "2020-07-30T14:08:45.627Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(Frag / Surf Half-lambert)딱 하프-램버트만 있는 커스텀 쉐이더입니다. 왼쪽은 프래그먼트로 작성한 것이며 오른쪽은 서피스로 작성한 것입니다. 차이가 있다면 서피스에는 'atten' 감쇠(attenuation) 인자를 곱해줘서 쉐도우 리시브와 캐스트가 제대로 동작하고 있습니다. 참고로 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-05-cast-receive-shadow"
original_modified: "2020-08-18T04:09:14.781Z"
image: "/assets/images/wix/7c3cec542c-ce7a39_0532c1b6c36c46c9ba8f07c332b69bb4~mv2.gif"
---

- ![](/assets/images/wix/4577275072-ce7a39_04c17a0ce5e44cc0bc5462e03a246f5b~mv2.png)
- ![](/assets/images/wix/c491867a82-ce7a39_a2be5b4e30d54d7b924074fdd814823f~mv2.png)

![](/assets/images/wix/b3c557e384-ce7a39_0e63245c36374a2ba089c85690648a75~mv2.png)

(Frag / Surf Half\-lambert)

딱 하프\-램버트만 있는 커스텀 쉐이더입니다. 왼쪽은 프래그먼트로 작성한 것이며 오른쪽은 서피스로 작성한 것입니다. 차이가 있다면 서피스에는 'atten' 감쇠(attenuation) 인자를 곱해줘서 쉐도우 리시브와 캐스트가 제대로 동작하고 있습니다.

![](/assets/images/wix/37be36c2e9-ce7a39_a5a0c7e96f47453a8459437a575c1d03~mv2.png)

참고로 서피스에서는 자동으로 리시브 쉐도우가 들어가기 때문에, 리시브 쉐도우를 없애려면 전처리(snippet)에서 프래그마(Pragma) 에 'noshadow' 를 써주면 됩니다.

포워드 렌더링 기준으로 서피스의 결과와 비슷하게 프래그먼트에도 그림자를 생성해 볼 것입니다.

![](/assets/images/wix/c3010c21e5-ce7a39_21a890601b064c00a8e638bc2952cfed~mv2.png)

먼저 캐스트 쉐도우를 위한 패스를 하나 더 쓸 것이기 때문에 다른 패스에 영향을 미치지 않도록 태그(Tags)를 첫번째 패스 안쪽에 넣어줍니다.

```hlsl
Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" "Queue" = "Opaque" }
```





다음은 태그에 **라이트모드(LightMode)**를 추가해 줍시다.

![](/assets/images/wix/eb1d8831ad-ce7a39_50f88fd1304f433b93127c15ff7e1e54~mv2.png)

([https://docs.unity3d.com/kr/current/Manual/SL\-PassTags.html](<https://docs.unity3d.com/kr/current/Manual/SL-PassTags.html>))

**포워드베이스(ForwardBase) 태그**를 붙혀주면, 이름 그대로 포워드 렌더링에서 동작하며 앰비언트 라이트, 메인 디렉셔널 라이트와 버텍스 라이트와 SH 라이트(Spherical Harmonic Lighting)를 빛으로 받을 수 있으며 라이트맵 기능이 정상적으로 적용됩니다.

![](/assets/images/wix/79163b8dea-ce7a39_5fab5d8d63454d668b9bdd3a37da94be~mv2.png)

전처리(Snippet)

![](/assets/images/wix/d17fbf04f0-ce7a39_57c84d7ca45c4968a30fc8ef71c45593~mv2.png)

```hlsl
#pragma multi_compile_fwdbase
```





포워드 렌더링에서 작동하기 위한 배리언트(varient) 생성을 위해 멀티 컴파일 합니다. 이것이 있어야만 리시브 쉐도우가 제대로 작동합니다.

따로 *'nolightmap' 'nodirlightmap' 'nodynlightmap' 'novertexlight'* 등으로 라이트맵과 버텍스 라이트를 받지 않도록 설정 해 줄 수 있습니다.

```hlsl
#include "Lighting.cginc"
#include "AutoLight.cginc"
```





인클루드로 cginc를 받아옵니다. 저희는 AutoLight.cginc 속에 존재하는 내장 그림자 매크로(Macro)인 SSSM(Screen Space Shadow Map)의 리시브 쉐도우를 그대로 사용할 것입니다.

![](/assets/images/wix/e9b4c9a6ed-ce7a39_0b01f5d083f344ee9ae3aa6a3641a1f7~mv2.png)

(AutoLight.cginc)

[\#if](<https://walll4542.wixsite.com/watchthis/watchthis/hashtags/if>) !defined(POINT) &amp;&amp; !defined(SPOT) &amp;&amp; !defined(DIRECTIONAL) &amp;&amp; !defined(POINT\_COOKIE) &amp;&amp; !defined(DIRECTIONAL\_COOKIE)

열어보면 금방 HLSL으로 작성된 SSSM을 찾을 수 있습니다. 포인트 / 스팟 / 디렉셔널 / 조명 쿠키 등등 라이트가 무엇이냐에 따라 엄청나게 분기가 많은데요. 디렉셔널과 유니티 모든 버전에서 동작하는 기준으로 작성하겠습니다.

이전 포스트에서 유니티 쉐도우의 원리를 공부했을때 배웠듯이 그림자는 곧 뎁스 맵 입니다. 화면에 보이는 공간(스크린 스페이스)을 기준으로 처리하고 쉐도우 맵을 이용하여 그림자를 표현합니다. 이제 필요한 변수들을 생각해봅시다.

```hlsl
UNITY_DECLARE_SHADOWMAP(_ShadowMapTexture);
```





위와 같이 광원 기준과 카메라 기준 뎁스 맵 데이터는 매크로를 통해 이미 *\_ShadowMapTexture* 변수에 기록 되어있습니다. 이 부분은 예약어인 것 같습니다.

저희는 뎁스 맵을 맵핑할 UV데이터가 들어갈 공간을 확보하고 **매크로가 필요로 하는 조건을 만족시키기만 하면 나머지는 알아서 유니티 내부에서 돌아갈 것입니다.**

```hlsl
#define TRANSFER_SHADOW(a) a._ShadowCoord = mul( unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );
```





다음 줄을 봅시다. *TRANSFER\_SHADOW(a)* 매크로가 정의되어 있습니다. 괄호 사이의 a값을 만족시키려면 '\_ShadowCoord'라는 UV가 필요하고, v.vertex(appdata 구조체의 포지션)이 필요합니다.

v(appdata)와 Texcoord를 동시에 가진 a를 만족하는 변수는 아무리 생각해봐도 구조체 밖에 없습니다. **v2f 구조체를 통째로 a에 박아넣고 변수 이름만 맞춰주면 작동**할 것 같습니다.

![](/assets/images/wix/fc79744d94-ce7a39_1d22ec5c5ebe4b77884c7dc6550ddd3a~mv2.png)

매크로가 직접 스크린 스페이스를 계산하기 위해 ComputeScreenPos**(a.pos)**로 포지션 값을 요구합니다.

![](/assets/images/wix/f58be28a13-ce7a39_ecb56391613b407697d38a52f50df676~mv2.png)

```hlsl

    #define SHADOW_COORDS(idx1) unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
```





SHADOW\_COORDS 매크로가 그림자의 UV를 몇번째 Texcoord를 쓸 것인지 정의하고, SHADOW\_ATTENUATION으로 감쇠된 그림자를 반환합니다. 이제 저희가 필요한 부분은 다 알아냈습니다.

![](/assets/images/wix/d5a5268de9-ce7a39_139ca6fea05c42feaeef186ccc7bc336~mv2.png)

(구조체 구성)

UV와 버텍스 데이터를 매크로의 조건에 맞춰서 위와 같이 구조체를 작성해줍시다.

cginc 속의 매크로를 사용하여 쉐도우 맵이 사용할 UV 공간을 정해줍시다. 괄호 속의 값은 2번째 uv인 TEXCOORD2를 쉐도우 맵을 매핑할 UV로 사용하겠다는 뜻입니다. 그러니 texcoord2에 다른걸 넣으면 절대 안되겠죠?

LIGHTING\_COORDS(1,2) 매크로를 이용해 1번 UV에는 라이트맵, 2번 UV에는 쉐도우맵이 들어가게 할 수도 있습니다. 다른 데이터와 겹치지 않으면 문제 없이 작동합니다.

![](/assets/images/wix/4d8dcc9939-ce7a39_39a77712f5884720a2a987e01c5c054e~mv2.png)

TRANSFER\_SHADOW(o)

v2f의 a.pos에 필요한 포지션 값을 넣어줍니다. 매크로가 자동으로 스크린 스페이스를 계산할 것입니다.

![](/assets/images/wix/462c2cbea7-ce7a39_8b3b588a8bb1488197694604f1f817c5~mv2.png)

*SHADOW\_ATTENUATION(i)* 매크로로 계산한 감쇠를 출력해봅시다. lerp로 그림자의 세기를 조절할 수 있게 만들었습니다.

![](/assets/images/wix/d4699ebf1f-ce7a39_6e40e4b4a6814c20bc785c732217a92f~mv2.png)

왼쪽은 프래그먼트 쉐이더이고 오른쪽은 유니티 빌트\-인 스탠다드 쉐이더 입니다. 그림자가 성공적으로 적용되었습니다. 예상대로 **그림자는 0\~1 리니어 데이터**로 존재하고 있습니다.

![](/assets/images/wix/1720c1a375-ce7a39_11b1cdb076334ccabac0479bee83d495~mv2.png)

```hlsl

 float NdotL = dot(i.normal, worldSpaceLightDir);
 float Halflambert = NdotL * 0.5 + 0.5;
                Halflambert *= Shadow;
 
                col.rgb = MainTex * Halflambert * _Color;
                col.a = 1;
```





그림자가 없으면 '1'이고 그림자가 존재하면 '0'인 것이지요. 따라서 그림자를 적용하는 일은 매우 간단합니다. **단순히 하프 램버트와 곱하면 바로 사용 가능합니다.** 램버트에서 밝은 부분은 데이터의 변화가 없고, 어두운 부분은 그림자의 영향으로 더욱 어두워질 것입니다.

다음은 캐스트 쉐도우를 작성하겠습니다. 그림자를 렌더링하기 위한 패스가 하나 더 필요합니다.

![](/assets/images/wix/f7932f5b48-ce7a39_0944db69ac2d4bee9c47736b2cdaea20~mv2.png)

태그는 쉐도우캐스터(ShadowCaster)로 맞춰줍시다. 큐(Queue)와 렌더타입(RenderType)은 명시하지 않아도 상관없습니다. 애초에 그림자는 Alpha\-test(2450\~2500) 까지의 큐 **2500번** 까지만 적용되기 때문입니다.

```hlsl

           #pragma vertex vertShadowCaster
           #pragma fragment fragShadowCaster
           #pragma multi_compile_shadowcaster
```





전처리에서 vert/fragShadowCaster를 써주고 멀티 컴파일 해줍니다.

```hlsl
#pragma multi_compile_instancing
```





**인스턴싱(Instancing)**은 완전히 같은 오브젝트 여러 개를 렌더링 시킬 경우에 한번의 드로우 콜(DP call)로 처리하게 해주는 유용한 기능입니다. 배경 씬에서 지형이나 식생같이 반복사용되는 오브젝트에 사용하면 좋은 전처리입니다.

```hlsl
#pragma fragmentoption ARB_precision_hint_fastest
```





쉐이더 연산은 샘플링 데이터가 얼마 만큼의 정밀도를 가지고 있느냐에 결과가 달라집니다. 그림자 연산의 경우를 포함해서 여러가지 그래픽 렌더링 연산들은 여러가지의 정밀도로 다른 결과 값을 가질 수 있습니다.

v\-ray나 Redshift 같은 시네마틱 렌더러를 돌릴때 샘플링 값을 얼마로 두느냐에 따라 렌더링 결과가 달라지는 것 처럼요. 그래서 데이터 정밀도를 아티스트가 절충해서 높은 프레임을 잡을 것이냐 혹은 높은 퀄리티를 얻을 것이냐를 정할 수 있습니다.

ARB\_precision\_hint\_**fastest**로 프래그먼트 옵션을 정해주면 계산 시간을 최소화하기 위해 정밀도를 낮추는 것이며, hint\_**nicest**로 프래그먼트 옵션을 정해주면 정밀도를 높히기 위해 계산 시간은 최대화 됩니다. 두 옵션을 다 써주면 오류가 나니까 주의하세요.

![](/assets/images/wix/7bd147fe93-ce7a39_40cd8fa20ea345de8755f2a5970b5fdc~mv2.png)

(UnityCG.cginc)

```hlsl
V2F_SHADOW_CASTER;
```



```hlsl
TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
```



```hlsl
SHADOW_CASTER_FRAGMENT(i);
```





캐스트 쉐도우 패스에서 사용하는 매크로들은 *UnityCG.cginc* 내부에 들어있습니다. 이번 포스트는 유니티 엔진의 라이트, 쉐도우의 모든 기능들과 호환 가능하게 작성하기 위해서 거의 대부분을 매크로로만 짜게 되었습니다.

***(드라이브):\\(UNITY설치폴더)\\(버전)\\Editor\\Data\\CGIncludes***

이러한 cginc 파일들은 위와 같은 경로에 들어있으니 관심있는 분들은 직접 열어보면서 자주 쓰던 함수들이 어떻게 작동되는지 직접 뜯어보면서 연구 해보시는것을 추천드립니다.

![](/assets/images/wix/c03e44f620-ce7a39_ed1d646146b34d158f482c3efb863f7f~mv2.gif)

왼쪽은 유니티 스탠다드 쉐이더, 오른쪽이 프래그먼트 쉐이더 결과물입니다.

![](/assets/images/wix/7c3cec542c-ce7a39_0532c1b6c36c46c9ba8f07c332b69bb4~mv2.gif)

서피스에 작성하면 신경쓰지 않아도 자동으로 생성되는 그림자를 굳이 이렇게 새로 만들 필요가 있는가? 의문점이 드실 텐데, 이렇게 따로 작성하면 **하프램버트를 이용하는 모든 종류의 프래그먼트 쉐이더**가 **그림자를 마음대로 세부 조정** 할 수 있다는 것이 가장 큰 장점입니다.

끝까지 읽어주셔서 감사합니다.
