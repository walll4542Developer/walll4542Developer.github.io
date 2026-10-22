---
title: "(UnityShader) 06 URP Shader Graph"
date: "2020-01-12T12:19:57.474Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: " 이번 포스트는 Linear interpolation 줄여서 Lerp 함수에 대해 알아봅시다.lerp의 대표적인 예로 그라디언트를 떠올리시면 됩니다. 누누히 강조하듯이 색은 숫자이며, 흑백 그라디언트가 바로 0과 1 사이의 값을 선형으로 쭉 나열해 둔 것입니다.lerp는 A,B,T 세 변수로 구성되는 함"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-06-urp-shader-graph"
original_modified: "2020-01-16T07:29:41.943Z"
image: "/assets/images/wix/cb86993563-ce7a39_ed7bc746d3804a54a83ec53cf423a408~mv2.gif"
---

이번 포스트는 **L**inear int**erp**olation 줄여서 Lerp 함수에 대해 알아봅시다.

![](/assets/images/wix/bc48d50e60-ce7a39_6a3d3ab57a47424899eec8c304354fc4~mv2.png)

![](/assets/images/wix/e8485c5725-ce7a39_f887fb07e70e4c48a5f08dfcf1cb1322~mv2.png)

lerp의 대표적인 예로 그라디언트를 떠올리시면 됩니다. 누누히 강조하듯이 **색은 숫자**이며, 흑백 그라디언트가 바로 0과 1 사이의 값을 선형으로 쭉 나열해 둔 것입니다.

![](/assets/images/wix/3dc8305f5f-ce7a39_93912b8f6f204c07bc7333015ef639a1~mv2.png)

lerp는 A,B,T 세 변수로 구성되는 함수고 두 끝점 사이의 값을 선형으로 계산하는 것이기 때문에 반드시 A와 B의 정보량이 같아야 합니다. 예를들어 A가 벡터4 라면 B역시 벡터4여야 합니다. 그리고 T 변수는 벡터1이어야 합니다.

![](/assets/images/wix/37739ccf22-ce7a39_f3a9c8b0c5c045b8ba002d754e948ac4~mv2.png)

간단한 예시로 불 텍스처를 A 나무 텍스처를 B, T값을 0.5로 하면 두 텍스처가 50%의 반투명으로 합쳐집니다.

![](/assets/images/wix/f597ad8e9a-ce7a39_362343bf602e440dafd345cf383b78da~mv2.png)

T 값에 불꽃 이미지의 알파채널을 넣으면 이렇게 말끔하게 텍스처가 합쳐집니다. 선형 보간 함수에 의해 T에서 흰색(1)이 들어간 픽셀은 불꽃 이미지가 그대로 나오고 검은 픽셀(0)은 출력 되지 않기 때문입니다.

## **Vertex Color**

![](/assets/images/wix/705062810d-ce7a39_81084ee992ba45d2adceb541fb64585f~mv2.png)

Vertex color는 이전의 렌더링 파이프라인 포스트에서 서술했듯이 오브젝트의 정점이 가지고 있는 고유의 색 정보입니다. 쉐이더에서 이 정보를 가져와서 사용할 수 있습니다.

Vertex color를 사용하기 위해 Package manager에서 Polybrush를 설치합니다.

![](/assets/images/wix/8faf65265f-ce7a39_8eeb4df45176463a8cc8a71af64cfa5e~mv2.png)

위와 같이 Vertex Color 노드를 연결하고 메테리얼에 적용하면 버텍스 컬러가 아래 사진과 같이 보입니다.

![](/assets/images/wix/f2bd97d7ec-ce7a39_dc98c1fb694a4a258ec6feb54da0d442~mv2.png)

적당히 RGB 컬러로 칠합니다.

![](/assets/images/wix/cb86993563-ce7a39_ed7bc746d3804a54a83ec53cf423a408~mv2.gif)

RGB 채널별로 나눠보면 이렇습니다.

![](/assets/images/wix/f7bd951965-ce7a39_bf603a13f8514d1393dbcf62b00bca0d~mv2.png)

앞서 배운 Lerp 함수로 텍스쳐 두개를 선형 보간하고 t값으로 버텍스 컬러 채널 R,G,B를 적용합니다.

![](/assets/images/wix/d8a9c5343f-ce7a39_e62a5273de2e49bb801224370295aa17~mv2.png)

위 방식으로 최대 다섯개 까지 텍스쳐를 섞을 수 있습니다. 참고로 이 방식이 유니티 터레인 툴에서 지형에 텍스쳐를 입히는 것과 같은 원리로 작동합니다.
