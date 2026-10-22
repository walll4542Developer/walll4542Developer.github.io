---
title: "(UnityShader) 16 URP Shader Graph"
date: "2020-02-18T05:20:26.000Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "Refraction이번 포스트에서는 물 아래 강 바닥 표면의 굴절을 표현 해보도록 하겠습니다.노드 작성 이전에 준비해야 할 과정이 있습니다. Project settings - Graphics 에서 파이프라인 에셋을 클릭하여 세부정보를 변경합니다.Opaque Texture에 체크 합니다.쉐이더 그래프로 가"
original_url: "https://walll4542.wixsite.com/watchthis/post/unityshader-16-urp-shader-graph"
original_modified: "2020-04-03T01:00:14.723Z"
image: "/assets/images/wix/b05a72e8fa-ce7a39_ca8971af0a1e4dd78901486decc52868~mv2.gif"
---

## **Refraction**

이번 포스트에서는 물 아래 강 바닥 표면의 굴절을 표현 해보도록 하겠습니다.

![](/assets/images/wix/af3be87d96-ce7a39_7fab0b11d3b640acb16268cf72a54a2e~mv2.png)

노드 작성 이전에 준비해야 할 과정이 있습니다. Project settings \- Graphics 에서 파이프라인 에셋을 클릭하여 세부정보를 변경합니다.

![](/assets/images/wix/5badac2a6d-ce7a39_661af571b6e14ddab628c1fa4e3c9849~mv2.png)

Opaque Texture에 체크 합니다.

![](/assets/images/wix/abbe63d609-ce7a39_9b86d1a02bbd4597bd949d384c96b1b2~mv2.png)

쉐이더 그래프로 가서 Texture 2d asset 노드를 생성하고 Property로 변환합니다.

![](/assets/images/wix/1be6a03be9-ce7a39_d09d360120814f0aacacae11e56af7e4~mv2.png)

쉐이더 그래프로 굴절을 구현하는데 가장 중요한 부분입니다. 블랙보드에 가서 Reference를 **\_CameraOpaqueTexture** 라고 써줍니다. 대소문자 구분합니다.

![](/assets/images/wix/cc4883da8e-ce7a39_7c3a9d71637a47c49953fbcd607ce5f4~mv2.png)

Sample Texture 2d에 위와 같이 연결하고 RGBA를 Unlit 마스터의 color에 연결합니다.

![](/assets/images/wix/7cec49be4e-ce7a39_074fe5339fc346fc99cc6bb4c715bad7~mv2.png)

이렇게하면 카메라로 보는 스크린의 이미지를 Plane에 매핑되었다는걸 알 수 있습니다.

그리고 당연히 스크린 이미지에도 UV 좌표가 존재합니다.

![](/assets/images/wix/5c15738d9f-ce7a39_91db314e970f4107afe6c224b2089c87~mv2.png)

스크린 UV라고 부릅니다. 쉐이더 그래프에서는 스크린 ‘포지션’ 노드입니다.

![](/assets/images/wix/0288528cb8-ce7a39_e98efa90b775482381e6685bbf653024~mv2.png)

스크린 UV를 그대로 출력하면 어떻게 될까요?

![](/assets/images/wix/ce6029d8f0-ce7a39_ccbddd8fd14947e2850c678baf82a0ac~mv2.gif)

위 아래로 화면을 움직였더니 Plane의 색이 변화합니다.

![](/assets/images/wix/1349ea3376-ce7a39_f437f0ac2024463ea80212a170a6c20a~mv2.png)

카메라를 좀 더 가까이 갔더니 이런 형태가 되었습니다.

OpenGL 방식과 똑같이 왼쪽 아래는 0,0 오른쪽 위는 1,1인 화면에 고정된 UV 라는 것입니다.

![](/assets/images/wix/64651102bf-ce7a39_8c01dcf771174af08296fc4e2dce550c~mv2.png)

그렇다면 스크린 포지션을 텍스처의 UV에 연결하면?

![](/assets/images/wix/df7021f5ce-ce7a39_e00542ceb20443a2b2bd574963b92e50~mv2.gif)

매우 이상한 결과가 되어 버렸습니다. 이렇게 되버린 이유를 파헤쳐 봅시다.

이전에는 카메라가 보는 스크린 이미지를 Plane에 매핑하였습니다. 하지만 지금은 **마치 거울을 마주보게 해놓은 것과 같습니다.**

현재 상황은 카메라가 보는 스크린 이미지를 스크린 포지션에 맞춰 매핑하였지만 ‘Plane 자기 자신’도 카메라에 촬영이 되는 상황이라 무한히 자기 자신을 반복해서 그리는 것입니다.

![](/assets/images/wix/1be6a03be9-ce7a39_d09d360120814f0aacacae11e56af7e4~mv2.png)

이전에 프로퍼티의 Reference를 \_CameraOpaqueTexture로 설정했습니다. 말 그대로 Opaque 만 텍스처로 그린다는 뜻입니다. 즉 Plane이 Opaque만 아니면 됩니다.

![](/assets/images/wix/76cef0f37b-ce7a39_34683cabe0094d0798bb7cfb1cefc4c1~mv2.png)

마스터 노드에서 표면을 Transparent로 바꿔주면 정상 작동합니다.

![](/assets/images/wix/8a9093b3d1-ce7a39_bd4d4042ae724d61ab7583dc1b5cb28d~mv2.png)

![](/assets/images/wix/e5c06781fd-ce7a39_1f55c3fe9557493693aff447e0faeac8~mv2.gif)

물 표면에 사용했던 노말맵을 굴절에도 똑같이 사용할 수 있습니다. 적당히 R,G 값의 강도를 조절한 후 스크린 포지션에 더해버리면 됩니다.

![](/assets/images/wix/e4c9efc574-ce7a39_70fe84d61ba24f57a0269cccbd60a78e~mv2.gif)

![](/assets/images/wix/080e4fbbbe-ce7a39_ba50b520feaf4987bc3510b1bb507fee~mv2.gif)

노말 맵의 UV 오프셋에 Time 함수를 더해주면 굴절도 흐르게 됩니다.

굴절을 얻었으니 이제 굴절과 반사를 더해주기만 하면 됩니다.

이전 포스트에서 프레넬 노드를 작성해서 큐브맵을 반사 하는 표면 아래로 땅바닥이 보이게 알파로 처리했다면

이제는 \_CameraOpaqueTexture 를 이용하여 표면 아래 **땅바닥에 대한 텍스처 자체**를 저희가 가지고 있기 때문에 알파를 사용하지 않아도 됩니다.

![](/assets/images/wix/88a205654c-ce7a39_eb0c127bc08140169270363de64e5700~mv2.png)

큐브맵 반사 \+ 퐁 리플렉션과 \_CameraOpaqueTexture를 프레넬 값을 이용하여 Lerp 함수로 섞어서 컬러로 반환합니다.

![](/assets/images/wix/b05a72e8fa-ce7a39_ca8971af0a1e4dd78901486decc52868~mv2.gif)

여기에 Depth 버퍼를 이용해서 물 표면이 다른 물체와 충돌할 때 파도와 거품이 생기도록 응용 할 수 있습니다.

물 쉐이더는 쉐이더 작성자의 실력과 요구하는 퀄리티에 따라 셀 수도 없을 만큼 많은 응용 방식들이 존재합니다. 쉐이더 그래프에서 다룰 수 있는 매우 기초적인 부분은 저희가 모두 살펴봤습니다.

더욱 공부하고 싶으신 분이라면 구글링을 해보면 관련 논문 자료들이 많이 있으니 시도해 보시길 바랍니다. 여기까지 잘 따라오셨다면 분명히 노드를 작성하는데 어려움이 없을 것입니다.
