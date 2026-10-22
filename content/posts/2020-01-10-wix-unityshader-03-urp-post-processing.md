---
title: "(UnityShader) 부록 URP Post-processing"
date: "2020-01-10T07:25:12.698Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: " 유니티가 URP로 넘어오면서 더 이상 포스트 프로세스를 사용하기 위해 패키지 매니저에서 따로 다운로드를 받을 필요가 없어졌습니다.먼저 후처리가 적용될 카메라에 포스트 프로세싱 체크박스가 생겼습니다. 요거를 체크합시다.이전 유니티 버전과 같이 후처리에는 항상 볼륨이 필요합니다. 빈 컴포넌트를 하나 만듭니"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-03-urp-post-processing"
original_modified: "2020-01-16T07:35:57.342Z"
image: "/assets/images/wix/b79b763e32-ce7a39_79a6688231a1483e999dce542c3af83f~mv2.gif"
---

![](/assets/images/wix/2b2963db17-ce7a39_12661bdc97f7441f913cc0149b98e930~mv2.png)

유니티가 URP로 넘어오면서 더 이상 포스트 프로세스를 사용하기 위해 패키지 매니저에서 따로 다운로드를 받을 필요가 없어졌습니다.

![](/assets/images/wix/c33a891612-ce7a39_90e89994379142d9b45ec5d622985722~mv2.png)

먼저 후처리가 적용될 카메라에 포스트 프로세싱 체크박스가 생겼습니다. 요거를 체크합시다.

![](/assets/images/wix/128863475a-ce7a39_2c9d77d3d36448eaba15355637c7c2ed~mv2.png)

이전 유니티 버전과 같이 후처리에는 항상 볼륨이 필요합니다. 빈 컴포넌트를 하나 만듭니다.

![](/assets/images/wix/b3e84f66c4-ce7a39_10a115e656864b7fa53da5895e3a7d50~mv2.png)

먼저 볼륨을 추가해줍니다.

![](/assets/images/wix/52af382b56-ce7a39_ec9d0c7fb08148b28bae69928986e923~mv2.png)

볼륨의 설정은 특정한 범위에만 후처리를 적용하고 싶지 않다면 글로벌으로 설정합니다.

![](/assets/images/wix/9956519f3b-ce7a39_3ad49b92a7674d4eb647729ddac1fd0a~mv2.png)

프로필에서 포스트\-프로세스 볼륨 프로필을 선택합니다.

![](/assets/images/wix/f15925ffe7-ce7a39_95ce5ce8107941cd99b490ba8fea7eb2~mv2.png)

후처리가 잘 작동하는지 테스트용으로 블룸을 추가해줍니다.

![](/assets/images/wix/b79b763e32-ce7a39_79a6688231a1483e999dce542c3af83f~mv2.gif)

잘 작동합니다.
