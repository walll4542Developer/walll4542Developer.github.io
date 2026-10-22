---
title: "포스트 프로세스 외곽선 검출"
date: "2020-06-22T06:07:12.776Z"
categories: ["Study"]
tags: []
excerpt: "https://darkcatgame.tistory.com/28?category=795581https://blog.naver.com/plasticbag0/221469059991이 포스트는 위 블로그들의 지식 공유와 재능 기부에 의해 작성 될 수 있었습니다.-서론이전 포스트에서 저희는 포스트 프로세스 메테리"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-01-post-process-shader"
original_modified: "2020-07-01T04:46:55.374Z"
image: "/assets/images/wix/c40f64eb7c-ce7a39_9ae80be129114a188db7f7cfc3a50e1a~mv2.gif"
---

[https://darkcatgame.tistory.com/28?category=795581](<https://darkcatgame.tistory.com/28?category=795581>)

[https://blog.naver.com/plasticbag0/221469059991](<https://blog.naver.com/plasticbag0/221469059991>)

이 포스트는 위 블로그들의 지식 공유와 재능 기부에 의해 작성 될 수 있었습니다.

\-

![](/assets/images/wix/c40f64eb7c-ce7a39_9ae80be129114a188db7f7cfc3a50e1a~mv2.gif)

## **서론**

이전 포스트에서 저희는 포스트 프로세스 메테리얼(쉐이더)에 대한 기본적인 구조를 이해하였습니다. 기본기를 복습하고 탄탄히 다진다는 생각으로 이전포스트의 중점을 요약해서 서술 하겠습니다.

후처리 쉐이더는 최소 세가지 구성요소로 이루어집니다. *쉐이더 코드*, 쉐이더 코드가 적용될 *메테리얼*, 그리고 *C\# 스크립트 파일* 입니다.

C\# 스크립트 파일은 반드시 Scene 어딘가에 배치되어 있어야만 합니다. 보통 직관적인 이해를 위해 '메인 카메라'에 Add component로 추가합니다만 empty object를 하나 만들어서 적용해도 문제 없습니다. 컴포넌트 순서를 '유니티 포스트 프로세스 레이어' 이후에 넣으면 당연히 유니티 포스트 프로세스 이후에 적용이 됩니다.

스크립트에서 OnRenderImage 함수가 Source(원본)와 Destination(결과)을 카메라 버퍼에 저장하고 포스트 프로세스 메테리얼에 적용된 쉐이더 코드의 연산 대로 Source를 처리하여 Destination을 출력합니다.

이번 포스트에서 다룰 후처리 쉐이더는 바로 **외곽선 검출**입니다. 툰 쉐이더에서 자주 활용되는 방식으로 [2\-pass 방식(링크)](</posts/wix-unityshader-14-urp-shader-graph/>)은 URP 포스트에서 한 번 다룬 적이 있었습니다.

하지만 하나의 외곽선 표현/검출 방식만으로는 외곽선의 디테일과 퀄리티가 떨어지기 때문에 여러가지 방식을 혼합하여 사용합니다. (물론 모바일이나 PC, 콘솔 등의 플랫폼에 따라서 정해진 최소 사양에 의해 여부가 갈립니다)

후처리를 통해 모니터에 출력 되기 이전의 **노말과 뎁스** **버퍼 텍스처를 이용해 외곽선을 검출**하고 결과물로 출력 할 것입니다.

## **C\# 스크립트 작성**

![](/assets/images/wix/92f4e82578-ce7a39_43ca90272d9747df832f4b1aaf0f95d6~mv2.png)

이번 포스트 프로세스 쉐이더에서 C\# 스크립트는 두가지 기능을 수행합니다.

OnRenderImage함수에서 후처리 결과를 출력하는 것은 물론이고 메인 카메라를 가져와 **뎁스 버퍼(Depth Buffer)와 노말 버퍼(Normal Buffer)**를 촬영합니다.

버퍼 데이터를 스크린 UV를 이용해 텍스처로 변형해야만 저희가 쉐이더 코드에서 접근할 수 있게 됩니다.

```hlsl
private Camera cam;
```





8번째 줄의 카메라를 받아오는 부분부터 천천히 분석해봅시다. 먼저 카메라를 저장할 변수를 지정합니다. 이름을 cam이라고 했으나 변수 명은 무엇이든 상관없습니다.

카메라에 접근하기 위해선 C\# 스크립트 파일을 add component로 메인 카메라에 추가해야 합니다.

![](/assets/images/wix/9c44502e6e-ce7a39_613b416347784c6ea8abffde8fdde2e6~mv2.png)

이전 포스트에서는 Scene에 배치되어 있으면 상관없다고 했지만 카메라 관련 함수를 이용해야 한다면 이야기가 다릅니다. 스크립트를 아무 오브젝트에나 넣었더니 카메라가 존재하지 않는다는 오류가 뜹니다. 얌전히 카메라에 스크립트를 꽂아줍시다.

```hlsl

cam = GetComponent<Camera>();
```



```hlsl
cam.depthTextureMode = DepthTextureMode.DepthNormals;
```





스크립트에서 가장 중요한 부분입니다. 스크립트가 붙어있는 카메라의 정보를 Cam이라는 변수에 저장합니다. 그리고 depthTextureMode명령을 이용해 카메라가 바라보고 있는 화면의 뎁스 버퍼와 노말 버퍼를 샘플러2D형태로 저장합니다.

```hlsl
void OnRenderImage(RenderTexture src, RenderTexture dest)
```



```hlsl
{
```



```hlsl
Graphics.Blit(src, dest, mat);
```



```hlsl
return;
```



```hlsl
}
```





OnRenderImage 함수와 Graphics.Bilt 명령으로 후처리가 출력되도록 합니다. 스크립트에서 우리가 원하는 버퍼 텍스처를 모두 얻었으니 이제 쉐이더 코드를 작성해봅시다.

## **쉐이더 코드 작성**

![](/assets/images/wix/0ddc6a031a-ce7a39_0d6c1eb03be9480588c143504d5d03d0~mv2.png)

```hlsl

 sampler2D _MainTex;
 float4 _MainTex_ST;
 //Post Process Source
```





먼저 sampler 2D \_MainTex에 Source가 저장됩니다. 그러니 오류가 일어나지 않도록 Maintex 프로퍼티를 지워주시면 됩니다.

```hlsl

 sampler2D _CameraDepthNormalsTexture;
 //카메라 뎁스 노말 텍스쳐
```





그리고 **sampler 2D \_CameraDepthNormalsTexture**에는 저희가 스크립트에서 작성한 depthTextureMode 명령으로 저장된 뎁스와 노말 데이터가 들어있습니다.

참고로 \_CameraDepthNormalsTexture 변수 명은 유니티 엔진 내부에 이미 존재하는 변수로 고정 되어 있습니다.

```hlsl
float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
```





이것을 **i.uv 즉 ‘스크린 스페이스 UV’**로 맵핑하고 제대로 작동하는지 return으로 결과를 확인합시다. 노말은 float3라서 RGB채널에 들어 있고 뎁스는 float이라 알파 채널에 들어있습니다.

![](/assets/images/wix/7537239805-ce7a39_68ad4218ba3146d79eb8c767cd525629~mv2.png)

(Source 이미지)

![](/assets/images/wix/88807ac960-ce7a39_94c1205efc8d4455ad2b722de64ad316~mv2.png)

(float3 \_CameraDepthNormalsTexture.rgb 노말 텍스쳐)

![](/assets/images/wix/09d68f6f26-ce7a39_c6ea96f64eb442d981ee39ec3cc0de7c~mv2.png)

(float \_CameraDepthNormalsTexture.a 뎁스 텍스쳐)

실제로 확인해보면 지금 상태로 사용하기에는 뎁스와 노말 데이터가 이상합니다. 노말 데이터는 월드 노말도 탄젠트 노말도 아닌 무언가가 나왔고 뎁스 데이터는 중간 깊이 값이 끊어져 있는 듯 보입니다.

그래서 저희는 \_CameraDepthNormalsTexture를 우리가 사용할 수 있는 상태로 변형하기 위해 **DecodeDepthNormal 함수**를 이용해 다시 나눠줄 것 입니다.

```hlsl

 float3 cameraNormal;
 float cameraDepth;

 DecodeDepthNormal(depthNormal, cameraDepth, cameraNormal);
```





이렇게 코드를 작성하면 float cameraDepth에는 뎁스 텍스쳐가, float3 cameraNormal에 노말 텍스쳐가 들어갑니다.

![](/assets/images/wix/cfe5589754-ce7a39_7e31721aff7444cf8912a6af2caffe71~mv2.png)

(float3 cameraNormal 노말 텍스쳐)

![](/assets/images/wix/ddab84d34d-ce7a39_3900f3e9d7ad4e58ab36bbd405ca8f36~mv2.png)

(float cameraDepth 뎁스 텍스쳐)

노말 텍스쳐는 월드 노말이 잘 뽑혀져 나왔습니다. 하지만 뎁스 텍스쳐는 아직 데이터가 부정확해보입니다. 카메라에서 먼 오브젝트나 가까운 오브젝트나 0에 가까운 색으로만 처리되어 있습니다.

이렇게 되면 오브젝트 끼리의 깊이 차이를 감지하기 힘들어집니다. 좀 더 세심한 깊이 값 비교를 위해서는 풍부한 데이터가 필요합니다.

```hlsl
cameraDepth = cameraDepth * _ProjectionParams.z;
```





그래서 카메라 뎁스에  **\_ProjectionParams.z** 값을 곱해줍니다.

![](/assets/images/wix/20e1ac4709-ce7a39_a6f5140bc1694ba2a63f6b57a7a45124~mv2.png)

[(유니티 메뉴얼 링크)](<https://docs.unity3d.com/2019.3/Documentation/Manual/SL-UnityShaderVariables.html>)

**x** is 1.0 (or –1.0 if currently rendering with a [flipped projection matrix](<https://docs.unity3d.com/2019.3/Documentation/Manual/SL-PlatformDifferences.html>)), **y** is the camera’s near plane, **z** is the camera’s far plane and **w** is 1/FarPlane.

![](/assets/images/wix/98a925a4ce-ce7a39_32dd0131737e4d079d90329f8f87d95a~mv2.png)

(카메라 세팅)

\_ProjectionParams의 z 값은 Camera의 **Far** 값 입니다.

far plane 이란 카메라가 촬영하는 가장 먼 거리 값이고 유니티 2019.3.0 버전 기준 디폴트값이 1000으로 설정 되어 있습니다.

값을 조절하면 far 값을 초과한 멀리있는 오브젝트는 렌더링 되지 않습니다.

물론 \_CameraDepthNormalsTexture도 카메라로 촬영 하는 것이기 때문에 far 값에 영향을 받습니다.

![](/assets/images/wix/14317094a1-ce7a39_db8475f6f92244dd8021eb9945eda207~mv2.png)

(???)

ProjectionParams.z를 곱하고 나서 뎁스 텍스쳐를 출력하면 화면이 하얗게 나오는데 오류가 생긴 것이 아닙니다.

![](/assets/images/wix/5a8dfe224c-ce7a39_81fa04104b4e48dab90fb09e124481d4~mv2.png)

1을 초과한 값이 곱해져서 모니터 상으로 표현할 수 없기에 1이상의 값은 다 흰색이 되어버린 것이고 실제로 오브젝트에 카메라를 가까이 하면 깊이 값을 확인 할 수 있습니다.

이렇게 원하는 버퍼 텍스처를 모두 얻는데 성공했으니 준비는 끝났습니다. 다음은 깊이 텍스쳐를 **‘미분’** 하여 외곽선을 검출하는 여러가지 **영상 처리 기술**과 원리를 분석하는 포스트로 찾아 뵙겠습니다.
