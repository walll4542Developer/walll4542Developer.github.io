---
title: "(CK VFX) Unreal Cascade Midterm"
date: "2020-05-27T03:19:31.606Z"
categories: ["Study"]
tags: ["VFX"]
excerpt: "언리얼 캐스케이드 수업 중간고사입니다. 캐스트(Cast) - 프로젝타일(Projectile) - 익스플로전(Explosion) 으로 구성된 같은 스타일의 하나의 이펙트 세트를 제작하는 것이 과제였습니다. 작업시간은 20시간 정도 걸렸습니다.이펙트들의 메쉬 형태입니다.  메쉬를 보시면 바로 눈치 채셨겟지만"
original_url: "https://walll4542.wixsite.com/watchthis/post/ck-vfx-midterm"
original_modified: "2020-06-15T12:23:48.271Z"
image: "/assets/images/wix/77b357206e-ce7a39_68ec6f8da37a4e6d932087b78c34c6f7~mv2.gif"
---

![](/assets/images/wix/77b357206e-ce7a39_68ec6f8da37a4e6d932087b78c34c6f7~mv2.gif)

언리얼 캐스케이드 수업 중간고사입니다. 캐스트(Cast) \- 프로젝타일(Projectile) \- 익스플로전(Explosion) 으로 구성된 같은 스타일의 하나의 이펙트 세트를 제작하는 것이 과제였습니다. 작업시간은 20시간 정도 걸렸습니다.

![](/assets/images/wix/cf783354b8-ce7a39_60daadb80b6643fe850549823d344a1d~mv2.png)

이펙트들의 메쉬 형태입니다.  메쉬를 보시면 바로 눈치 채셨겟지만 시퀀스(Sequence) 이미지처럼 보이는  UV 스크롤링을 응용한 결과물입니다.

![](/assets/images/wix/af1598a104-ce7a39_0de7a38e83684484a31ebb56e209ecc7~mv2.png)

이 메테리얼은 익스플로전 이펙트에 사용되었습니다. 원형 메쉬의 UV를 극좌표 모양으로 펴서 y축으로 스크롤링 한 것입니다.

대부분의 텍스쳐 소스는 AE에서 직접 렌더링 한 뒤 포토샵에서 수정하였습니다. 매우 유용한 float4 다이나믹 파라미터를 이용해 캐스케이드 내부의 그래프로 변수를 직접 컨트롤 합니다.

![](/assets/images/wix/1c81a40d7e-ce7a39_a2620f8f0b864cb0b4ce54513c2db605~mv2.png)

같은 방식의 메쉬와 uv 스크롤링으로 캐스팅 이펙트도 제작 할 수 있었습니다.

![](/assets/images/wix/5b8e401c85-ce7a39_54b9ca781aa84e35b8d6f987f18f9b90~mv2.png)

Sphere 메쉬를 이용해 폭발시에 생기는 굴절을 만듭니다. 안타깝게도 이런식으로 굴절을 작성하면 배경(Destination)에는 굴절이 작동하나 이펙트 소스(Source)에는 굴절이 적용되지 않습니다.

이유는 언리얼 엔진의 렌더링 파이프라인을 보면 **불투명 패스(****Opaque Pass)** 이후에 **그랩 패스(grab pass)** 방식으로 굴절이 적용되고 다음 순서로 **반투명** **패스(Translucent pass)**가 들어가서 렌더 되기 때문입니다.

따라서 언리얼에서 반투명 이펙트에 굴절을 넣으려면 **유니티 엔진처럼 블루프린트에서 화면을 캡쳐해서 렌더 타겟으로 그릴 수 밖에 없다**고 합니다.

![](/assets/images/wix/aae09dd63b-ce7a39_125a59800b4a47f9a00c3a2884321ece~mv2.png)

시퀀스 이미지 처럼 보이게 하는 핵심 방법입니다. 다이나믹 파라미터를 이용해 제곱 연산으로 텍스쳐의 어두운 부분 부터 천천히 사라지게 합니다.

Depth Fade 노드를 이용하면 유니티의 소프트 파티클과 같은 효과로 빌보드(Billboard)가 다른 메쉬에 가까울 때를 깊이 버퍼(Depth)로 계산하여 소스가 잘리지 않고 부드럽게 사라지도록 처리됩니다.
