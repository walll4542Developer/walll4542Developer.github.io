---
title: "URP Shader Graph로 실시간 SSS 만들기"
date: "2020-07-10T07:41:56.909Z"
categories: ["Study"]
tags: []
excerpt: "URP Shader Graph로 실시간 SSS 만들기."
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-17-urp-shader-graph"
original_modified: "2020-07-10T07:43:29.163Z"
image: "/assets/images/wix/94fbc1ed2a-ce7a39_ad4cfc5370bd4e65a8f28fd738e95ff3~mv2.gif"
---

[https://blog.naver.com/mnpshino/221442188568](<https://blog.naver.com/mnpshino/221442188568>)

이 포스트는 마둠파 테크니컬 아트 연구소 블로그에 소개된 '실시간 SSS 쉐이더를 구현하는 세가지 방법' 포스트를 바탕으로 작성 되었습니다. 자세한 원리와 이론 소개를 참조하십시오.

\-

URP Shader Graph로 실시간 SSS 만들기.

![](/assets/images/wix/7541c18f5c-ce7a39_251a9d1b81e5466c9873f9c58ac82cf0~mv2.png)

라이트 벡터와 월드 노말 벡터의 중간 방향인 '하프벡터'를 계산합니다. Distortion 값으로 오브젝트 내부의 산란 강도를 결정합니다. 마음에 드는 결과물이 나오는 임의의 값으로 조절합시다.

![](/assets/images/wix/8f6c148040-ce7a39_ae2266efed77447996cfe0256a931a17~mv2.png)

카메라 벡터와 벡터 방향을 반전한 하프 벡터를 내적합니다. 방향을 반전하지 않는다면 산란이 오브젝트가 빛을 받는 정면에서도 일어나게 됩니다.

SSSPower 변수와 SSSscale 변수로 산란되는 양을 조절합니다. 여기에 임의의 값을 더하면 SSS가 일어나는 범위가 전체적으로 넓어집니다.

![](/assets/images/wix/6a1b15c0e7-ce7a39_e9681bf68eb942efb4f918d6189d0d94~mv2.png)

Atten 변수를 곱해서 감쇠를 만듭시다. SSSColor 변수로 내부산란에서 발생하는 색을 결정합니다.

두께(Thickness) 맵 혹은 앰비언트 오큘루전(Ambient Occulsion) 맵을 반전하여 내부 산란이 일어나지 않는 재질(금속 류나 너무 두꺼운 곳)이 위치한 부분을 마스킹합니다.

값을 반전 했기 때문에 1에 가까울 수록 산란이 일어나지 않습니다. 저는 두께 맵 대신 0.5를 넣었습니다.

NdotL으로 기본적인 하프 램버트를 만들어 줍시다.

![](/assets/images/wix/0d72b72f42-ce7a39_34839567575c43eda845bed440f492b6~mv2.png)

조명 색상을 SSS에 곱해서 색상의 영향을 받게 합니다.

하프 램버트에 MainTex를 곱해주고 SSS와 더합니다. 마지막으로 1을 넘는 색상(HDR)이 발생하지 않도록 Saturate 해주고 결과물로 내보냅시다.

![](/assets/images/wix/1e588c5602-ce7a39_c6dc5b0a8292468f9904828473f9e687~mv2.png)

모든 노드 스크린샷 입니다. 클릭하면 크게 볼 수 있습니다.

![](/assets/images/wix/94fbc1ed2a-ce7a39_ad4cfc5370bd4e65a8f28fd738e95ff3~mv2.gif)

완성입니다.
