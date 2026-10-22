---
title: "(UnityEngineBasic) 01 Midterm"
date: "2019-12-01T14:16:51.025Z"
categories: ["Unity"]
tags: ["Study"]
excerpt: "[청강게임][ChunKangGame] UnityEngineBasic Midterm프로젝트를 진행할 당시는 추운 겨울이었습니다. 3D 모델러를 지망한 이후 항상 오픈월드 배경을 만들어 보고 싶었는데, 이번 중간과제가 기회다 싶었습니다.딱 맞는 레퍼런스 게임으로 <스카이림>이 있습니다.언리얼 마켓의 무료 에"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityenginebasic-midterm"
original_modified: "2020-01-23T08:32:12.059Z"
image: "/assets/images/wix/62f886567f-ce7a39_04c9d09776c146218c41e37b0c50e268~mv2.png"
---

![](/assets/images/wix/62f886567f-ce7a39_04c9d09776c146218c41e37b0c50e268~mv2.png)

![](/assets/images/wix/09f1ece1c2-ce7a39_25d2ca24a62c48ac880ff6140eb77b5f~mv2.png)

![](/assets/images/wix/34d649b9c0-ce7a39_ad853748bda94c058f603602cb9c0db7~mv2.png)

![](/assets/images/wix/fff10d1e29-ce7a39_69516a62271946909679a5b0cae2165d~mv2.png)

![](/assets/images/wix/eea365157f-ce7a39_e0ea3a595081471ca4b9911297b84ddc~mv2.png)

![](/assets/images/wix/2998e8d428-ce7a39_d25699f777184d9080f30760cd1bb706~mv2.png)

![](/assets/images/wix/d2a55a537e-ce7a39_551ad3f810924aee86e44dd5de5ca78c~mv2.png)

![](/assets/images/wix/c381d5ceea-ce7a39_ecbc3a18c51d4ba7983c3a704d04573b~mv2.png)

![](/assets/images/wix/cc18e4f64a-ce7a39_63445c84466e4c949d879e24836670ea~mv2.png)

![](/assets/images/wix/258a1257f1-ce7a39_059d2746484f43cd994224f3c1bff8cc~mv2.png)

[동영상 보기](https://www.youtube.com/watch?v=a3SUmKCHegA)

프로젝트를 진행할 당시는 추운 겨울이었습니다. 3D 모델러를 지망한 이후 항상 오픈월드 배경을 만들어 보고 싶었는데, 이번 중간과제가 기회다 싶었습니다.

![](/assets/images/wix/35f2c25339-ce7a39_25d9c26a37f1416683c1608d5fa31b69~mv2.png)

딱 맞는 레퍼런스 게임으로 &lt;스카이림&gt;이 있습니다.

언리얼 마켓의 무료 에셋을 임포트해서 사용했습니다.

![](/assets/images/wix/0d59774a11-ce7a39_f52ce6b9209c42119bd1637eda6b1683~mv2.png)

렌더링 파이프라인은 조명이 자연광인 태양뿐이며, 무거운 연산이 필요하지 않기 때문에 Forward로 설정했습니다.

리얼타임이다 보니 GI를 베이크에 가까운 근사치로 보이기 위해 앰비언트 컬러를 그라디언트로 미세조정했습니다.

이번 프로젝트는 모든 리소스가 Realtime으로 돌아가게 하는 것이 목표고 기말 프로젝트에는 Baked로 진행 할 것입니다.

![](/assets/images/wix/076b836bdb-ce7a39_69952bac0b7343d895abacb30dacf461~mv2.png)

프로젝트는 3주 남짓한 기간이었기 때문에 512 \* 512 정도의 작은 사이즈로 전체 씬의 청사진을 그렸습니다.

원래 목표는 오픈월드였기 때문에 플레이어에게 오픈월드라는 느낌을 주기 위해 맵 끄트머리가 아닌 웬만한 곳은 전부 지나다닐수 있게 box Collider 를 배치했습니다.

![](/assets/images/wix/c180d30c91-ce7a39_ea828654b5c6459ca2337f4c1fe002c9~mv2.png)

## 적용된 후처리 목록과 고민

당시에는 볼류메트릭 라이트에 대한 조예가 깊지 않아 사용을 꺼리고

ACES 톤 맵핑을 기본으로 깔아주고 겨울에 맞춰 영하의 색온도를 사용하였습니다.

아주 약간의 색수차와 비네트로 화면에 풍부함을 더했습니다.

GI가 없는 리얼타임이기 때문에 풍부한 그림자를 위해 스크린 스페이스 AO를 사용하였습니다.

Depth of Field를 사용해 씬 전체에 깔린 Fog가 선명하지 않고 부드럽고 자연스럽게 처리되도록 하였습니다.

새벽의 여명이 강조 되도록 태양이 지형에 높낮이를 주어 낮은 곳에 있다면 높은 곳의 장애물에 의해 태양이 가려지는 곳을 많이 나오게 하여 명순응 반응을 자주 경험하도록 레벨을 디자인 했습니다. 나무와 바위의 위치또한 같은 방식으로 의도 되었습니다.

포스트 프로세스 볼륨에 카메라가 들어있어야 후처리가 작동한다는 점에 착안하여 언리얼에서 모든 것을 Volume 으로 제어 하듯이 Collider 를 Volume 으로 사용하면 어떨까? 생각이 들었습니다.

![](/assets/images/wix/02d9362d71-ce7a39_8726f96b8009493c967e846e96fa754f~mv2.png)

특정 Collider 속으로 들어가면 Fog 수치를 조작하여 안개가 걷히고 원경이 보이는 연출을 넣었습니다. 동영상에서 확인 하실 수 있습니다.

![](/assets/images/wix/87688c95aa-ce7a39_e50cc3ea02e2432fa3de897480944aea~mv2.gif)

스카이림 UI 도 직접 따라 만들었습니다.

NEWS 나침반 이미지를 만들고 UV스크롤링이 가능하게 Repeat 로 설정해서 방위각을 표현했습니다.

스크립트 작성은 다른 프로그래머의 도움을 받았습니다.

## 최적화

![](/assets/images/wix/4fd22a39ce-ce7a39_98ba3e80849143549b00083b56a3d5f0~mv2.png)

빌드파일을 보는 교수님도(클라이언트) 144hz 모니터를 쓰시니 144 프레임을 최소 기준으로 삼았습니다.

Batches 는 최대 3k는 안넘도록 신경을 썼습니다.

## 권장사항

Geforce GTX 1660 ti 이상

Radeon RX 570 이상

**1920 \* 1080 해상도**

(2560 \* 1440 QHD 해상도도 지원가능하지만 UI 가 이상해집니다..)

## 빌드파일

[https://drive.google.com/file/d/1p10DH3gHllMBxoT4SQT1LBuIKizyyVQq/view?usp=sharing](<https://drive.google.com/file/d/1p10DH3gHllMBxoT4SQT1LBuIKizyyVQq/view?usp=sharing>)
