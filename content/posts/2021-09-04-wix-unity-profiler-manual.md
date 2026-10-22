---
title: "(UnityEngine) Unity Profiler Manual"
date: "2021-09-04T04:12:01.720Z"
categories: ["Unity"]
tags: ["Study"]
excerpt: "유니티 내장 프로파일러를 실사용 해보고 얻은 경험을 토대로 작성한 메뉴얼을 들고왔습니다. 누구나 따라할 수 있을 만큼 정말 쉽고 간단합니다.Unity 2020.3.17f1 / Galaxy S8 / Android Build 기준으로 작성되었습니다.\n개인 PC (Local)에서 빌드 하는 경우를 다룹니다.사"
original_url: "https://walll4542.wixsite.com/watchthis/post/unity-profiler-manual"
original_modified: "2022-12-25T03:00:05.181Z"
image: "/assets/images/wix/023efc23ff-ce7a39_c891cbbfb3504cc2ab39c1971fce48c2~mv2.png"
---

![](/assets/images/wix/15046946bb-ce7a39_2fedad6f26e94b59a4a4909dfa306cc9~mv2.png)

유니티 내장 프로파일러를 실사용 해보고 얻은 경험을 토대로 작성한 메뉴얼을 들고왔습니다. 누구나 따라할 수 있을 만큼 정말 쉽고 간단합니다.

**Unity 2020.3.17f1 / Galaxy S8 / Android Build** 기준으로 작성되었습니다.
개인 PC (Local)에서 빌드 하는 경우를 다룹니다.

## 사전 준비물

### Android Bulid Support

![](/assets/images/wix/99c41991ed-ce7a39_c43192b8faba41189a80b1db16aa73d8~mv2.png)

(빌드 서포트)

유니티를 다운로드 받을 때 유니티 허브(Unity Hub)에서 Android Bulid Support 모듈을 추가하여 SDK, NDK, JDK를 같이 설치합시다.

### 주의사항

![](/assets/images/wix/253aad1c6f-ce7a39_2e927fd9e5ef4d50b552706f578b78b4~mv2.png)

(삼성 매장에서 직접 판매하는 정품 케이블)

로컬에서 USB 포트에 유선으로 연결하는 방식을 권장합니다.

와이파이(Wi\-Fi) 무선 연결로도 인식이 가능하지만, 유선보다는 안정성이 떨어집니다.

**반드시 ‘정품’ 케이블**을 사용해야 인식이 잘 됩니다.

## 테스트 기기 설정하기

![](/assets/images/wix/d686b3bf47-ce7a39_1f7f6d8de823408d9fe6307278f27c7b~mv2.png)

(갤럭시 S8)

테스트 기기마다 유니티 원격 프로파일러가 인식하는 조건이 다릅니다.

예를 들어 갤럭시 S5로 테스트할 때는 '충전 모드'로 설정 해야합니다.

본 포스트는 **갤럭시 S8**으로 진행했습니다.

![](/assets/images/wix/0abaa908b1-ce7a39_375de97ded8c4d32b78c31cfe95c6027~mv2.png)

(메인 화면)

설정으로 들어갑시다.

![](/assets/images/wix/023efc23ff-ce7a39_c891cbbfb3504cc2ab39c1971fce48c2~mv2.png)

(개발자 옵션)

개발자 옵션으로 들어가서 USB 디버깅을 켜줍시다.

![](/assets/images/wix/8728d174d5-ce7a39_d0ce7d62a3be477a95ad7ed11c0f3447~mv2.png)

(휴대전화 데이터에 접근 허용)

데이터 접근을 허용 하면 준비 완료입니다.

## 프로파일러 연결하기

![](/assets/images/wix/c0e2bacd7e-ce7a39_f94c84905b664a4f9427a018339d81c3~mv2.png)

(platform\-tools)

SDK를 설치했던 경로로 찾아갑시다. adb 파일이 있는지 확인합니다.

ADB란? 안드로이드 디버그 브릿지(Android Debug Bridge)의 줄임말 입니다.

**C:\\Program Files\\Unity\\Editor\\Data\\PlaybackEngines\\AndroidPlayer\\SDK\\platform\-tools**

보통 유니티 에디터와 같은 경로에 설치되어 있을 것입니다.

![](/assets/images/wix/24338e4e13-ce7a39_7182fcaacefe47bca14bc083246d4c4f~mv2.png)

폴더에서 ‘파일’을 누르고 ‘Windows PowerShell 열기’를 선택합시다.

![](/assets/images/wix/01937b0a71-ce7a39_9908211f7901426690c59d792e0578c5~mv2.png)

이런 파란 Dos 창이 나옵니다.

![](/assets/images/wix/d0452e84a2-ce7a39_5f18316fa52c452d88946f39d72b21aa~mv2.png)

먼저 **.\\adb devices** 명령어를 입력합니다.

해당 명령어는 adb에 붙어(Attached)있는 장치들을 쭉 알려줍니다.

현재는 연결이 되어있지 않기 때문에 아무것도 나오지 않는 것이 정상입니다.

![](/assets/images/wix/e2e3806c44-ce7a39_d1e29220563a4cfe853172025577ed8e~mv2.png)

만약 장치가 붙어있으면 위와 같이 ce031713b22e58600d device 라는 이름으로 출력됩니다.

![](/assets/images/wix/009972f422-ce7a39_ad96e083a9ae4e77b16ceb2a887b3c22~mv2.png)

**.\\adb forward tcp:34999 localabstract:Unity\-(패키지 이름)** 명령어를 입력합니다.

![](/assets/images/wix/37c3433c88-ce7a39_b63870c3221f4c558a8375f9ee50e22c~mv2.png)

위와 같이 출력 되거나, 혹은 아무것도 출력되지 않으면 이미 연결이 되어있거나 정상적으로 동작한 것입니다.

패키지 이름은 무엇일까요?

![](/assets/images/wix/234fba9bca-ce7a39_e40a133d6334455694c9ce7284fdb5ec~mv2.png)

(Identification)

유니티의 프로젝트 세팅(Project Settings)의 플레이어(Player) 탭, Identification 옵션에 있습니다.

패키지 이름(Package Name)의 ‘com.’\~ 를 입력해줍시다. 다른 프로젝트를 빌드하고 싶으면 해당 프로젝트의 패키지 이름을 사용하면 됩니다.

## 버그 리포팅

테스트가 끝나서 다른 테스트 기기를 USB 포트에 꽂았더니 안 붙는 경우가 간혹 있습니다.

**.\\adb kill\-server** 명령어를 입력하고,

**.\\adb start\-server** 바로 명령어를 입력하면 server를 재시작 합니다.

## 빌드 설정

![](/assets/images/wix/81a4c5b746-ce7a39_085a201e642e45f1961d6e98ecb3fc74~mv2.png)

(빌드 설정)

프로파일링을 위해 설정하는 옵션들은 인게임 퍼포먼스에 영향을 끼칩니다. 실제 배포용 빌드의 성능과 다소 차이가 있을 수 있다는 점을 감안하여 프로파일링 해야 합니다.

- Development Build

지금 같이 개발자 빌드인 경우에는 해당 설정을 활성화 해줍시다.

- Autoconnect Profiler

해당 설정을 활성화 하고 Build And Run을 하면 자동으로 연결된 기기에 APK를 설치하고 실행하고 프로파일러를 붙혀줍니다.

![](/assets/images/wix/f222a7949a-ce7a39_271db1b0a7854c749420a309f5b40a58~mv2.svg)

(Deep Profile)

- Deep Profiling Support

이 설정을 활성화하면 모든 C\# 메서드를 프로파일링하며, Unity는 모든 모노 호출에 계측을 추가하므로 스크립트를 더욱 자세히 조사할 수 있습니다.

![](/assets/images/wix/79df7ccc2e-ce7a39_0686b75c9dc3497fa5694679ec5bbf23~mv2.png)

(Build / Build And Run)

마지막으로 **Build And Run**을 눌러줍시다. 빌드가 끝나면 자동으로 실행되고 프로파일러가 붙을 것입니다.

![](/assets/images/wix/3937a6b733-ce7a39_c12d413376394b6fb5095e16d0c40e3c~mv2.gif)

> 프로파일링의 첫 시작을 환영합니다! 시작이 절반입니다.

개발 환경이 잘 되어있는 게임 회사에서는 빌드 파일(APK)를 동시에 여러 테스트 기기들에 뿌려주는(자동으로 다운로드, 설치, 실행) 과정을 젠킨스(Jenkins)를 사용하여 자동화 해놓습니다.

온라인(Appbox 같은 클라우드 서비스를 통해)또는 오프라인 저장소(NAS 혹은 인트라넷을 통해)에 자동으로 빌드를 공유하게 설정한 후 개발자가 수동으로 다운로드 받는 식으로 처리 해둡니다.

참고로 Windows PowerShell 켜서 테스트 기기를 붙이는 과정 정도는 로컬 환경에서도 배치(Batch) 파일을 제작해서 자동화 하실 수 있습니다. (나중에 따로 다뤄보도록 하겠습니다)

읽어주셔서 감사합니다. 여러분들의 관심이 제게 큰 도움이 됩니다.
