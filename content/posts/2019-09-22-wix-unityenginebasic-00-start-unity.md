---
title: "(UnityEngineBasic) 00 Start Unity"
date: "2019-09-22T04:31:36.115Z"
categories: ["Unity"]
tags: ["Study"]
excerpt: "유니티 엔진 기초 00 유니티 시작하기이 포스트는 2019년 9월에 작성되었습니다. 현재의 유니티 버전과는 다를 수 있습니다.유니티 공식 홈페이지로 가서 Unity Hub를 설치합니다.https://unity3d.com/get-unity/download유니티 허브를 실행하면 나오는 화면입니다. 이제 엔진"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityenginebasic-00-start-unity"
original_modified: "2019-10-31T01:48:12.730Z"
image: "/assets/images/wix/98e5b87ade-ce7a39_97456eff180046ec91c8feac221241b7~mv2.png"
---

유니티 엔진 기초 00 유니티 시작하기

이 포스트는 2019년 9월에 작성되었습니다. 현재의 유니티 버전과는 다를 수 있습니다.

![](/assets/images/wix/98e5b87ade-ce7a39_97456eff180046ec91c8feac221241b7~mv2.png)

유니티 공식 홈페이지로 가서 Unity Hub를 설치합니다.

[https://unity3d.com/get\-unity/download](<https://unity3d.com/get-unity/download>)

![](/assets/images/wix/28aaa53776-ce7a39_f5612a9b5483484d88994eb840cd826e~mv2.png)

유니티 허브를 실행하면 나오는 화면입니다. 이제 엔진을 구동하기 위해 컴퓨터에 설치해야 하는데 우리에게 쓸만한 버전을 선택해야 합니다.

![](/assets/images/wix/aa26bb029c-ce7a39_2fbc5b4c7fc94600916e933d22baf426~mv2.png)

2018.4.9.f1(LTS)를 예로 들겠습니다.

2018\. 앞의 네자리는 버전이 출시된 연도

4.9는 버전 업데이트 횟수

f와 1은 Final 즉 2018.4.9 버전의 안정성을 잡고 검수가 끝난 최종 버전의 첫번째 판 이라는 뜻이며

(LTS)는 Long Time Support의 약자로 오랫동안 책임지고 사후 관리를 해주겠다는 뜻입니다.

![](/assets/images/wix/739babe0cc-ce7a39_9b61f137986b42ea9d6ad2f36ab95759~mv2.png)

최신출시 알파/베타는 안정성이 현저히 떨어지므로 못본 척 하시면 됩니다.

![](/assets/images/wix/c4b253b8f6-ce7a39_d95979ef3c4d41649b08833faec67274~mv2.png)

원하는 버전을 고르고 설치가 끝났으면 프로젝트 메뉴로 돌아가서 프로젝트 새로 생성 버튼을 누릅니다.

![](/assets/images/wix/93b8e3c654-ce7a39_8d0d450a88f8449087fe2c3ff2e1280d~mv2.png)

새로 생성 버튼을 누르면 템플릿 선택창이 뜨게 됩니다.

![](/assets/images/wix/4e730b66b4-ce7a39_b54e63c5b4b243a9b9b42978dd1a1d56~mv2.png)

2D

2D그래픽만 사용되는 게임을 제작 할 때 고르는 템플릿입니다. 다만 3D 템플릿과 기술적으로 아무런 차이가 없으며 세부 설정이 다른 것입니다. 프로젝트를 처음 시작 할 때 카메라가 Perspective(원근법)이 적용되지 않는 Orthograph(정사영)로 맞춰져 있는 점이 큰 차이입니다.

![](/assets/images/wix/2a05c7ebce-ce7a39_5ca9d95ed38e4183892f2997dac3ff8f~mv2.png)

3D

3D 그래픽만 사용되는 게임을 제작 할 때 고르는 템플릿입니다. 2D 템플릿과 본질적으로 같으며 세부 설정을 변경하고 카메라 뷰를 2D로 바꾸면 2D 템플릿과 완전히 같습니다.

![](/assets/images/wix/87847f1ac4-ce7a39_6130357f08024aa5b87a5a2b18293573~mv2.png)

3D with Extras

3D 템플릿에 추가적으로 유니티에서 기본 제공되는 예제 파일들이 포함 된 상태로 프로젝트를 시작 할 수 있습니다.

![](/assets/images/wix/b893f664f7-ce7a39_ff82a25f29204c0c9e807337d12afe18~mv2.png)

High\-Definition Rendering Pipeline

줄여서 HDRP라고 부르며 이 템플릿으로 제작된 영화도 있을 만큼 유니티 엔진에서 최대한 높은 퀄리티를 뽑아내기 위해 존재하는 템플릿 입니다. 포스트를 작성하는 19년 하반기인 지금은 아직 연구개발 단계(프리뷰)이기 때문에 업계 실사용 수준은 아닙니다.

![](/assets/images/wix/9b1cd3b2cf-ce7a39_7aabdce1d00949c285b61d2bfd03ca86~mv2.png)

Light\-Weight Rendering Pipeline

줄여서 LWRP라고 부르며 이름 그대로 HDRP보다는 경량화된 템플릿입니다. 가까운 미래에 기존의 2D/3D 템플릿이 HDRP와 LWRP로 통합되며 사라지게 될 것입니다.

![](/assets/images/wix/4a8a8ad6a5-ce7a39_d54e4025bfef46169f7feb5704c114d9~mv2.png)

Virtual Reality Light\-Weight Rendering Pipeline

VR게임에 최적화된 템플릿 입니다.

![](/assets/images/wix/a36e49f401-ce7a39_c6bfb94f5a7f41f9a6dd834186008aa9~mv2.png)

유니티 인터페이스 (Default Layout) 기준

Hierarchy

계통도를 의미합니다. 씬 내부에 있는 오브젝트를 표시해줍니다. 오브젝트를 다른 오브젝트 아래에 드래그드랍해서 종속시키거나 그 반대로 할 수 있습니다. Max의 Scene Exporter, Maya의 Outliner와 같은 기능을 수행합니다.

Inspector

오브젝트의 여러가지 파라미터와 속성을 제어할 수 있는 창입니다. 언리얼 엔진의 Detail과 같은 기능을 수행합니다. 유니티 엔진은 기본적으로 비어있는 깡통에 필요한 Component를 채워 넣어서 원하는 기능을 작동하게 합니다. 마치 레고 처럼 쌓아 올려서 오브젝트를 만드는 구조입니다. 이 부분이 언리얼 엔진과 가장 큰 차이 입니다. 언리얼의 경우 반대로 이미 모든게 추가 되어 있는 무거운 오브젝트에서 필요 없는 것을 빼내는 형식입니다.

Scene View

3D툴의 viewport와 같은 기능을 수행합니다. 씬을 시각적으로 탐색하고 편집 할 수 있습니다. 작업중인 프로젝트 유형에 따라 3D 또는 2D로 표시 될 수 있습니다.

Project

유니티 프로젝트에서 사용할 수있는 에셋 라이브러리가 표시됩니다. 에셋을 프로젝트로 가져 오면 여기에 나타납니다. 여기에 업로드된 에셋들은 Hierarchy와 달리 씬 배치 유무와 전혀 상관없습니다. 이곳의 데이터는 빌드 파일에 포함됩니다.
