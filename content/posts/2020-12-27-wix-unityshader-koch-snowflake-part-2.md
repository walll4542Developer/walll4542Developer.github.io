---
title: "(UnityShader) Koch Snowflake Part 2"
date: "2020-12-27T15:28:59.189Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "float2 uv = float2(i.uv - 0.5)*2; \nuv.x = abs(uv.x) - 0.5; \nfloat segment = length(uv - float2(clamp(uv.x, - 0.25, 0.25),0)); \ncol.rgb = 1 - step(0.05, segment) + float3("
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-koch-snowflake-part-2"
original_modified: "2021-01-05T08:15:11.125Z"
image: "/assets/images/wix/fb0d9a7fd7-ce7a39_f14f8d1b31744b6e8c5714a14c9e0d77~mv2.gif"
---

![](/assets/images/wix/e13b7e6149-ce7a39_349ef979617e4a2a8d4c5024b136b4b8~mv2.png)

```hlsl
float2 uv = float2(i.uv - 0.5)*2; 
uv.x = abs(uv.x) - 0.5; 
float segment = length(uv - float2(clamp(uv.x, - 0.25, 0.25),0)); 
col.rgb = 1 - step(0.05, segment) + float3(uv,0);
```





이전 포스트에서 저희는 UV를 굴절시키는 함수를 구현 했습니다. 이제 기존 쉐이더에 추가해봅시다.

![](/assets/images/wix/8fed7eba77-ce7a39_6ac3deb613a14408bcb9c1b9e062e149~mv2.gif)

```hlsl
float2 result = uv - (rotateMatrix * min(0,distance) * 2);
```





절대값 함수로 UV를 대칭시켰으니 굴절 또한 대칭 될 것입니다.

![](/assets/images/wix/35a38fea4e-ce7a39_a03da75150444933936389f7434daf0e~mv2.gif)

```hlsl
uv -= (rotateMatrix * min(0, dot(uv, rotateMatrix) ) * 2);
float segment = length(uv - float2( clamp(uv.x, -_var, _var), 0) );
```





![](/assets/images/wix/59379e5512-ce7a39_1efe35ff2f2647e69e1058983e2173d3~mv2.gif)

```hlsl
uv -= (rotateMatrix * max(0, dot(uv, rotateMatrix) ) * 2);
float segment = length(uv - float2( clamp(uv.x, -_var, _var), 0) );
```





원하던 모양대로 작동합니다. min이 아니라 max로 바꾸면 양수 방향으로 굴절 하는 것을  수 있습니다.

![](/assets/images/wix/b365412357-ce7a39_0c68474c6e4c4df9ae601c565947c2f5~mv2.png)

저희가 원하던 모양이 나왔습니다. 이제 프랙탈 도형으로서 지금까지의 과정을 원하는 만큼 반복할 수 있게 해봅시다.
