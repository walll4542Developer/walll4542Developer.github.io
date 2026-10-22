---
title: "(CK VFX) 04 Effect with 3D Mesh"
date: "2019-10-14T08:59:54.644Z"
categories: ["Study"]
tags: ["VFX"]
excerpt: "Effect With 3D Mesh 2계획단계기하학적 형태를 지닌 Sci-fi 스러운 구체 이펙트를 만들어보자.이펙트의 주제와 부제를 설정한다.주제로 중심에 정다면체 혹은 구체에 가까운 근사치의 다면체 도형이 회전하며 은은한 빛을 냄과 동시에 표면이 움직임으로서 구체에 잠재되어 있는 힘과 역동성을 표현한"
original_url: "https://walll4542.wixsite.com/watchthis/post/ck-vfx-04-effect-with-3d-mesh"
original_modified: "2020-06-30T02:21:04.780Z"
image: "/assets/images/wix/ad71480542-ce7a39_7e8d14d43e6e4aa39b8ecb46f9346b2f~mv2.gif"
---

[동영상 보기](https://www.youtube.com/watch?v=hdRZaVGBzgw)

계획단계

기하학적 형태를 지닌 Sci\-fi 스러운 구체 이펙트를 만들어보자.

이펙트의 주제와 부제를 설정한다.

![](/assets/images/wix/ad71480542-ce7a39_7e8d14d43e6e4aa39b8ecb46f9346b2f~mv2.gif)

주제로 중심에 정다면체 혹은 구체에 가까운 근사치의 다면체 도형이 회전하며 은은한 빛을 냄과 동시에 표면이 움직임으로서 구체에 잠재되어 있는 힘과 역동성을 표현한다.

부제로 표면을 타고 빛이 흐르는 연출과 전자 무늬들이 있으면 수려하게 어울릴 것 같다.

![](/assets/images/wix/96caf09968-ce7a39_b8a47598ed4842289c85f9e1b1a1d2d8~mv2.png)

주제에 사용할 색과 부제에 사용할 색을 적절히 분배한다.

주제로 대표되는 형태과 색의 화면상에서 차지하는 면적이 부제보다 좁으면 안된다.

제작단계

![](/assets/images/wix/6ca8daa4ee-ce7a39_ff100db7f2914fba86d2e8d0f08586fb~mv2.png)

모델링 툴(맥스, 마야)에서 icosahedron 을 하나 만들고 적당한 숫자로 divide 한다.

![](/assets/images/wix/3b961ba871-ce7a39_7f37a9c521ef4bc890ba6ef402821984~mv2.png)

어느 한 축으로 UV Scrolling이 가능하도록 UV를 펴준다.

![](/assets/images/wix/832dd9bde9-ce7a39_8d4970f0ea884aa0b61cf5685b3adae7~mv2.gif)

Z\-fighting이 발생하지 않도록 더 큰 크기로 icosahedron를 복제한 뒤 표면의 움직임을 표현하기 위해 각 Tris를 분리 시켜 몇개의 그룹으로 묶는다. 이 과정에서 UV 크기는 유지되어야 한다.

![](/assets/images/wix/b637529ecc-ce7a39_2ca18f94135a4d0292268ff57733cd43~mv2.png)

두 메쉬를 엔진에 올려서 겹치면 이런 형태가 된다.

모든 방향에서 일정하게 퀄리티가 유지되어야 하기 때문에 Additive 리소스 들이 Alpha sorting이 일어나지 않도록 Unlit shader를 사용한다.

![](/assets/images/wix/c2b3f5984d-ce7a39_04526004f5074970aa150f066c3e754c~mv2.png)

Scale 애니메이션을 이용해 표면이 움직이도록 할 것이다.

모든 오브젝트의 Pivot 을 local(0,0,0)에 두고 Scale 값을 조절하여 표면이 파도처럼 움직이도록 애니메이션 키를 삽입한다

![](/assets/images/wix/550b5c3bde-ce7a39_0c18cf3ad96e4758aea44dcbbb92a554~mv2.png)

![](/assets/images/wix/2a4fb956ee-ce7a39_7e821cd26a214c5ab9ca9b723770df7e~mv2.png)

Edge를 Extrude로 뽑아낸 다음 구체 안쪽 엣지가 (0,0)에 오게 UV를 펴고 구체에서 모든 방향으로 빛이 새어나오는걸 표현하기 위해 단순한 그라디언트 맵을 하나 넣는다.

![](/assets/images/wix/af62d2e55a-ce7a39_9749b78d384e4ddb8062616a252c24b7~mv2.png)

같은 방식으로 Edge를 선택하고 Bevel(맥스에서는 Champer)로 적당한 크기의 face를 만든다.

![](/assets/images/wix/677557b885-ce7a39_e706fc7f6686476e9eae0670c3a285ab~mv2.png)

위와 같은 선형 이미지를 리소스로 UV Scrolling을 이용해 구체 외곽에서 빛이 흐르는 것을 표현한다.

==========================================================

피드백

![](/assets/images/wix/61ce6d3c28-ce7a39_dcf756da1e124e38986e9f93f98abf9c~mv2.png)

교수님 말씀대로 쉐이더로 작동할 수 있는걸 머릿속에 그렸다가 혹시 노가다로 구현할 수 있지 않을까 해서

머리 굴려서 만들었던건데 교수님께선 정확하게 꿰뚫어보고 계셨습니다. 20년동안 게임 만들면 다 보이나 봅니다...

![](/assets/images/wix/caeb8609f6-ce7a39_17f3a836fe984a53b18267fdd8cd753b~mv2.png)

![](/assets/images/wix/515b6121be-ce7a39_f63d57c84c894df4a914c9a7ef73b91e~mv2.png)

피드백 대로 부제의 면적과 두께, 다른 방향을 추가하고 빌보드가 사용 불가한 만큼 전부 메쉬로 만들었습니다.

![](/assets/images/wix/78da569f27-ce7a39_6b0156c4217947e9a635d25582e07443~mv2.png)

너무 부제가 화면에서 강하게 들어오는 느낌을 받아서 외곽에서 도는 원의 Tint color를 감소 시켰다.

메쉬에 Additive를 적용하면 메쉬가 겹칠때 빛이 이런식으로 난다.

주제를 향해서 빛이 중앙으로 흘러들어가는 부제도 넣을까 했는데 이미 두껍기 때문에 그만뒀다.

완성.
