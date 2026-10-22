---
title: "(UnityShader) Fragment Advanced"
date: "2020-08-01T14:22:18.809Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "(UnityShader) 06 Fragment Advanced버텍스/프래그먼트 쉐이더로 위의 예제를 구현해야 합니다. 쉐이더를 관찰하면서 기능을 파악 해봅시다. 제가 보기에는 크게 다섯가지로 구성 되어 있습니다.1. Vertex/Fragment 쉐이더 방식으로만 구현 할 것.2. 배경과 자연스레 섞이게 "
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-06-fragment-advanced"
original_modified: "2022-06-12T05:33:59.084Z"
image: "/assets/images/wix/c32da42594-ce7a39_eb7e8d62839c47d19db8572386c7ae85~mv2.gif"
---

(UnityShader) 06 Fragment Advanced

![](/assets/images/wix/68aba18093-ce7a39_40d5ef13d5e5422bbfc812eb86835d4c~mv2.png)

**버텍스/프래그먼트 쉐이더로 위의 예제를 구현**해야 합니다. 쉐이더를 관찰하면서 기능을 파악 해봅시다. 제가 보기에는 크게 다섯가지로 구성 되어 있습니다.

1. Vertex/Fragment 쉐이더 방식으로만 구현 할 것.
2. 배경과 자연스레 섞이게 만들 것. (alpha\-sorting 해결 할 것)
3. 알파 값을 조절 가능하게 하여 사라졌다가 다시 나타날 수도 있게 만들 것.
4. 불규칙적인 모양으로 사라지게 할 것. (텍스처 사용)
5. 사라져 없어지는 부분이 빛나게 만들 것. (HDR Color 사용)

![](/assets/images/wix/ac1c95aba8-ce7a39_0df8c7c0385b4d90bc39993cec643dd4~mv2.png)

배경과 자연스레 섞이게 하는 것부터 시작해봅시다. 투명(transparent)로 구현을 할 건데 서피스 쉐이더였다면 알파\-블렌드(Alpha\-Blend)하기 위해 [\#pragma](<https://walll4542.wixsite.com/watchthis/watchthis/hashtags/pragma>) surface surf (커스텀 라이트 모델) **alpha:blend** 만 써주면 됩니다.

프래그먼트 쉐이더에서는 **블렌드(blend) 명령**으로 알파 연산 공식을 수동 제어 해줄 수 있습니다. (서피스도 됨) 서피스보다 손이 많이 가지만 원하는대로 알파 연산을 세부조정 해 줄 수 있는 것이 큰 장점 입니다. 블렌드 명령은 아래와 같이 표기 합니다.

![](/assets/images/wix/14708a0651-ce7a39_acece5a00081422195f87ae0afd31f4d~mv2.png)

## blend (Source) \* \[SrcBlend\] \+ (Destination) \* \[DstBlend\]

이것이 블렌드 공식의 형태입니다. 이전에 [포스트\-프로세스 쉐이더(링크)](</posts/wix-unityshader-01-post-process-shader/>)를 다룬 포스트에서 **Scr은 원본**, 소스(Soruce)의 약어라고 말씀 드렸고 **Dst는 배경**, 데스티네이션(Destination)의 약어라고 말씀 드렸었습니다.

원본에 \[SrcBlend\]을 곱하고 배경에 \[DstBlend\]를 곱한 뒤 더해서 합치는 방식인 것이죠.

- ![](/assets/images/wix/dd8e079f6e-ce7a39_98fcc11e40184ec28a8a1f3b24c736c7~mv2.png)
- ![](/assets/images/wix/6bfca54217-ce7a39_3dec14f8caa64af1ad90da9b9a80d54d~mv2.png)
- ![](/assets/images/wix/4ce164b79b-ce7a39_a742af07855e4e23a434be3bee531a0a~mv2.png)

원본(Source), 배경(Destination), 블렌드(blend)

원본이란 **알파 연산에 사용할 텍스쳐**를 말합니다. 배경은 **소스 텍스처를 제외한 '씬 전부'를 렌더링 한 텍스쳐**라고 생각하시면 됩니다.

![](/assets/images/wix/ad244c7414-ce7a39_93c5d09a51284e3d9d82129240dafe5a~mv2.gif)

소스컬러(SrcColor) RGB와 소스알파(SrcAlpha) A

블렌드 명령에는 다음과 같은 블렌드 옵션(Option)들이 존재합니다. \[SrcBlend\]와 \[DstBlend\] 자리에 기입할 수 있습니다.

- One : 1입니다. 1을 곱하면 데이터는 그대로입니다.
- Zero : 0입니다. 0을 곱하면 데이터는 무조건 0이 됩니다.
- SrcColor : 텍스쳐의 RGB 값을 말합니다.
- SrcAlpha : 텍스쳐의 A 값을 말합니다.
- DstColor : 배경의 RGB 값을 말합니다.
- DstAlpha : 배경의 A 값을 말합니다.
- OneMinusSrcColor : 원 마이너스(1\-), **반전**된 텍스쳐의 RGB 값을 말합니다.
- OneMinusSrcAlpha  : 반전된 텍스쳐의 A 값을 말합니다.
- OneMinusDstColor : 반전된 배경의 RGB 값을 말합니다.
- OneMinusDstAlpha : 반전된 배경의 A 값을 말합니다.

![](/assets/images/wix/fba056bfea-ce7a39_67b11a48c1564ac99479e4dc0ff341b9~mv2.png)

### blend (Source) \* \[SrcBlend\] \+ (Destination) \* \[DstBlend\] = result

## (Src) \* SrcAlpha \+ (Dst) \* OneminusSrcAlpha = Alpha\-blend

따라서 알파\-블렌드 공식은 위와 같이 정의할 수 있습니다.

원본에 소스알파를 곱하면 알파 채널 값 만큼 데이터가 제거됩니다.

배경에 소스알파를 반전한 값을 곱하면 알파 채널 만큼의 데이터만 남게 됩니다.

이렇게 만들어진 결과 둘을 더해서 합치면 완벽하게 블렌드 되는 것입니다.

![](/assets/images/wix/fbb58b7ccc-ce7a39_7bf69225a7c34553a7ac1fa6d043903a~mv2.png)

- ![](/assets/images/wix/c5d3163b77-ce7a39_4e9783f9d8e64f44b7bbd86cf9374054~mv2.png)
- ![](/assets/images/wix/d273a118af-ce7a39_0883d7e385f444778ddb1256acbd55f2~mv2.png)

(노이즈 SubTex)

지금까지의 코드입니다. '불규칙적인 모양으로 사라지게 할 것.' 을 만족 시키기 위해 노이즈 텍스처를 하나 만들어줬습니다.

샘플러 변수 \_SubTex로 받아주고 노이즈 텍스처를 알파 채널으로 넣어줍시다. float1만 쓰면 되니까 R 8으로 압축해주는 센스가 필요합니다.

![](/assets/images/wix/f82b5e950c-ce7a39_a11787e1a867499796fa3b572203a852~mv2.png)

![](/assets/images/wix/292e1d58d7-ce7a39_dd31641960744293b51525378d9c6982~mv2.png)

![](/assets/images/wix/743123d3fb-ce7a39_f4abab8cc6b5480193cec4c3f09c1be9~mv2.png)

\[HDR\]\_HDRColor ("HDR Color", Color) = (1,1,1,1)

프로퍼티에서 컬러 변수 앞에 \[HDR\]을 쓰면 HDR 컬러를 사용할 수 있습니다. 현재 상태는 이렇게 됩니다. 알파 소팅(alpha\-sorting) 문제를 해결 해봅시다.

![](/assets/images/wix/352341fa8e-ce7a39_c04141ad2b8a4accaeed2ffd7ee61686~mv2.gif)

반투명의 알파\-블렌드가 적용된 경우에, 두 오브젝트가 겹쳐 있을 경우 **오브젝트와 카메라의 거리인 깊이 버퍼(Z\-buffer)**에 따라 어떤 오브젝트가 앞에 있는지를 판단하고 **뒤에 있는 것 부터 먼저 렌더**하게 됩니다.

하지만 오브젝트의 피벗 위치를 위와 같이 움직이게 되면 깊이 버퍼로 비교하면 뒤에 있는데, 오브젝트의 피벗은 카메라에 더 가까우니 **해당 부분을 렌더하지 않게** 되는 것입니다.

알파 소팅 문제는 2020년인 아직까지도 완벽한 해결 방법이 없는 난제이며, 크게 세 가지 완화 방법과 각각 장단점이 있습니다.

1. 오브젝트의 피벗을 여러개로 나눈다. (드로우 콜이 늘어남)
2. 아예 Z버퍼를 그리지 않는다. (오버드로우가 발생함)
3. Z버퍼만 따로 작성하는 패스를 만든다. (패스를 하나 더 써야됨)

![](/assets/images/wix/8d556defe9-ce7a39_42db57280d524fe686dd009275875840~mv2.png)

Zwrite off

저희는 가장 간단하지만 가장 무거운 방법인 2번으로 해결하겠습니다. Z\-버퍼를 그리지 않으려면 'Zwrite off' 딱 한줄만 써주면 됩니다. 지금같이 오브젝트가 한\~두개인 경우에는 상관없지만,

이렇게 반투명을 처리해버리면 실제 게임 클라이언트에서는 엄청난 수준의 오버드로우를 일으키기 때문에 추천되지 않는 방식입니다. 나중에 알파 관련 포스트에서 3번 방식을 작성해보겠습니다.

![](/assets/images/wix/fbfc7eaf89-ce7a39_f4d5d7d5c3204a27a72c114017c83c94~mv2.png)

(step)

'알파 값을 조절 가능하게 하여 사라졌다가 다시 나타날 수도 있게 만들 것'을 충족하기 위해 저희는 스텝 **step(x,y)**함수를 사용할 것입니다.

![](/assets/images/wix/91a417a1ef-ce7a39_16b535b039cf4aa69f33db179b85f78c~mv2.gif)

![](/assets/images/wix/c5d3163b77-ce7a39_4e9783f9d8e64f44b7bbd86cf9374054~mv2.png)

step**(SubTex.r, \_Slider)**

step 함수는 x 보다 y가 크거나 같을 경우, 1을 반환하고 작으면 0을 반환합니다. 매우 가볍고 널리 유용하게 자주 쓰이는 함수입니다.

따라서 0\~1으로 이루어진 노이즈 텍스쳐의 검은색(0) 부분이 가장 먼저 1으로 반환 됩니다.

![](/assets/images/wix/2024ed4298-ce7a39_288e77c322394d848a4956dbc120a32e~mv2.gif)

(result)

step으로 노이즈 텍스쳐와 변수를 비교하여 알파 값을 불규칙 적인 모양으로 만드는데 성공했습니다.

다음은 '사라져 없어지는 부분이 빛나게 만들 것.' 입니다.

자 생각해볼 시간입니다. 저희는 위에서 **알파\-블렌드에서 반전 연산으로 원하는 데이터를 원하는 영역만큼 마스킹 하는 것을** 배웠습니다. 노이즈 텍스쳐에서도 이것을 응용할 수 있을 것입니다.

![](/assets/images/wix/1d43da7caf-ce7a39_105cde9088b44d58adb051212c0a2dc7~mv2.png)

위 이미지를 보시면 바로 감이 오셔야 합니다. step(SubTex.r, \_Slider)와 반전한 값입니다. **둘을 곱하되, 어느 한 쪽의 값이 살짝 더 크다면..?**

![](/assets/images/wix/296a325961-ce7a39_053fca9daa4f4b1ba400a50bc2565972~mv2.png)

```hlsl

 float stepvalue = step(SubTex.r, _Slider) * (1 - step(saturate(SubTex.r + _Range), _Slider));
 //stepvalue
```







![](/assets/images/wix/757ec20ebd-ce7a39_5605750bba5a43dd85b65bf86bfcd6dc~mv2.png)

![](/assets/images/wix/f8e51c09c3-ce7a39_9525db05212d479598f39445b94e062f~mv2.gif)

짜잔. 이렇게 원하는 경계 값을 원하는 두께만큼 마스킹 할 수 있습니다. 여기에 HDR 컬러를 곱해주면 끝납니다.

![](/assets/images/wix/de18f02b00-ce7a39_1ef31278dec849ce8606408191645944~mv2.png)

![](/assets/images/wix/c32da42594-ce7a39_eb7e8d62839c47d19db8572386c7ae85~mv2.gif)

완성입니다. 읽어주셔서 감사합니다.
