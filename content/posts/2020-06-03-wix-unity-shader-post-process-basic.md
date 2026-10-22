---
title: "(UnityShader) 00 Post process Shader"
date: "2020-06-03T09:53:07.479Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "안녕하세요 여러분~ 갑자기 이러려니까 쑥스럽네요 하하. 포스트에서 제 말투가 너무 딱딱하다는 평가가 많아서 앞으로는 분위기를 바꿔서 쓰려고 합니다.카툰 모델링을 해보려다 NPR 쉐이더까지 손을 대서 결국엔 포스트 프로세스를 위해 코딩까지 하는 수준까지 왔는데 정신을 차리고 뒤를 돌아보니 너무 멀리 와버렸"
original_url: "https://walll4542.wixsite.com/watchthis/post/unity-shader-post-process-basic"
original_modified: "2020-09-14T07:55:16.901Z"
image: "/assets/images/wix/b3e9be405f-ce7a39_f6e13f50358f4794bd52ba2ba4cd507e~mv2.gif"
---

안녕하세요 여러분\~ 갑자기 이러려니까 쑥스럽네요 하하. 포스트에서 제 말투가 너무 딱딱하다는 평가가 많아서 앞으로는 분위기를 바꿔서 쓰려고 합니다.

카툰 모델링을 해보려다 NPR 쉐이더까지 손을 대서 결국엔 포스트 프로세스를 위해 코딩까지 하는 수준까지 왔는데 정신을 차리고 뒤를 돌아보니 너무 멀리 와버렸다는 것을 깨닫고 절망했습니다... 여긴 어디? 나는 누구? (와하하 잡캐다! 우하하 팡파레\~)

근데 포스트\-프로세스가 뭐였죠...?

![](/assets/images/wix/af3af4d780-ce7a39_44e6f8f45d8248539dcf25f30d518208~mv2.png)

유니티에서 추가할 수 있는 위 친구 만을 뜻하는 것은 아닙니다.  한글로 직역하면 '후\-처리' 라는 뜻인데... 사실 렌더링 파이프라인 다 끝나고 나서 남은 데이터로 뭐라도 해보려고 하면 그게 전부 다 후처리라고 불러도 크게 틀린 말이 없습니다.

그래서 저희가 하려는 후처리는 버텍스, 픽셀이나 서피스 쉐이더에서 끝나는 수준이 아니라 아예 그래픽 카드 속 어딘가에 숨어있는 버퍼(buffer) 라는 새 친구를 건드려보려고 합니다. 유니티에서 C\# 스크립트가 없으면 건드리기 어려운 영역들 말이죠. (언리얼은 아예 따로 포스트 프로세스용 노드를 지원합니다)

![](/assets/images/wix/e4b4db8179-ce7a39_7f1ed19fc912479ea1c0670c09737077~mv2.gif)

(온 세상이 흑백이야\~\~)

참고로 인스펙터 창을 보시면 포스트 프로세스 레이어 보다 C\# 스크립트를 아래에 위치시키면 포스트 프로세스가 먼저 작동됩니다. 순서를 바꾸면 거꾸로 실행 됩니다. 제일 간단하고 기본이 되는 흑백 컬러 전환 후처리부터 해봅시다. 버텍스/픽셀 쉐이더로 아래와 같이 작성합니다.

![](/assets/images/wix/3b57c0fee3-ce7a39_47865466335343b0a8baf9d722663a69~mv2.png)

평소에 작성하던 버텍스/프래그먼트 쉐이더와 다른 점이 몇개 있습니다.

```hlsl
Shader "Hidden/NewImageEffectShader"
```





1번째 줄을 봅시다. 이것은 쉐이더의 위치를 나타내는 일종의 주소 입니다. 이 주소가 제대로 되어 있어야 C\#스크립트에서 쉐이더 코드를 참조 할 수 있습니다.

Cull Off ZWrite Off ZTest Always

SubShader의 첫 부분에 Cull Off ZWrite Off ZTest Always를 써줍니다.

Cull Off 란 폴리곤의 노말에 따른 앞뒷면 구분을 하지 않겠다는 뜻이고 (cull 기능을 off하겠다)

ZWrite Off 란 Z값을 기록하지 않겠다는 뜻이며

ZTest Always는 Z값을 무시하고 무조건 그리겠다는 뜻입니다.

간단하게 설명하면 그렇습니다. 나중에 언젠가 자세히 다룰 기회가 올 것입니다.

```hlsl
uniform float _bwBlend;
```





uniform float "변수"

변수에 uniform 키워드를 접두어로 붙이면 변수가 쉐이더 외부, 예를 들어 C\# 어플리케이션에서 초기화 되어 쉐이더에 입력됨을 의미합니다.

이렇게 설정 해주어야 C\#스크립트에서 변수를 조절 할 수 있게 됩니다.

![](/assets/images/wix/c3ca2098f9-ce7a39_625d52d659ad470194c0b625db6e6afd~mv2.png)

저희 같은 그래픽 아티스트를 위한 C\# 스크립트 만드는 법입니다. ㅎㅎ

프로젝트 창에서 우클릭 \- Creat \- C\# Script 를 누르고 만들어진 스크립트 파일을 더블클릭해서 개발자 도구로 열면 됩니다.

![](/assets/images/wix/6a2d9a36f5-ce7a39_56bef9fe090c4a1bbb695506080ec675~mv2.png)

(다 지운다음 위와 같이 작성해줍시다)

따라쓰고 보니 뭔가 기존의 쉐이더 코드와 느낌이 다르지 않습니다...? 다른 분들에게 여쭤보니 C\#과 HLSL 둘다 C언어 기반이기 때문이라고 합니다. (자네 우리 집안 사람이었구만..)

\[ExecuteInEditMode\]

![](/assets/images/wix/991b5a2e73-ce7a39_9adb1bbe525b4f98b1adf152c711343d~mv2.png)

5번째 줄의 \[ExecuteInEditMode\]는 스크립트가 씬에 배치만 되어있다면 유니티의 Play 버튼을 눌러서 게임을 실행하지 않아도 에디터 모드에서 작동 할 수 있게 해준다는 뜻입니다. (사실 플레이 하시는게 더 잘 작동 될 겁니다)

public class test : MonoBehaviour

6번째 줄에는 뭔가 이상하게 생긴 친구가 보입니다..

*클래스는 C\#의 가장 기본적인 형식입니다. 클래스는 상태(필드)와 작업(메서드 및 기타 함수 멤버)을 하나의 단위로 결합하는 데이터 구조입니다. 클래스는 해당 클래스의 동적으로 생성된 인스턴스(개체라고도 함)에 대한 정의를 제공합니다. 클래스는 상속및 다형성과 파생된 클래스가기본 클래스를 확장하고 특수화 할 수 있는 메커니즘을 지원합니다.*

마이크로소프트 홈페이지에서 긁은건데 정말 어렵게 써놨습니다. 클래스란 HLSL의 **Pass{}** 내부 에서 커스텀 라이팅이나 커스텀 펑션을 만들 수 있는 것 처럼 데이터를 담는 그릇이라고 대충 이해하시면 됩니다.

퍼블릭(Public)은 이 클래스(Class)를 프로그램 어디서든 접근하기 쉽게 둔다는 뜻인거 같습니다. 클래스 앞에 붙는 이 녀석은 **접근 제어 지시자**라는 것이니 검색 해보시는게 좋을듯 합니다.

![](/assets/images/wix/2e55513936-ce7a39_11a2209e207340fd9448c6e5496c5db7~mv2.png)

그리고 클래스의 이름은 test 입니다. 쉐이더랩 스크립트와는 다르게 무조건 클래스 이름을 실제 C\# 스크립트 파일 이름과 똑같이 맞춰야 오류가 안납니다. 그러니 test.cs로 하시면 됩니다.

오른쪽에 ' : MonoBehaviour ' 시맨틱? 같은 것도 보입니다만 조금 다릅니다.

![](/assets/images/wix/73e49e47f0-ce7a39_bd740b1c3a7b4129817a2b04bb87aefe~mv2.png)

C\#에서는 명시적으로 MonoBehaviour를 써줘야 하는 모양입니다만 계속 파고들면 프로그래밍 강의가 되어버리기 때문에 군말 없이 써줍시다... 언젠가는 다시 짚어볼 날이 오겠죠 하하!

```hlsl
 public float intensity;
 public Material material;
```





8\~9번째 줄을 봅시다. 클래스처럼 변수도 **지시자**가 붙을 수 있다는 걸 알 수 있고  float은 자주 썻지만 변수 이름이 아예 **메테리얼(Material)** 입니다! 그렇습니다, 빈 깡통 메테리얼 자료형을 만들고 거기에 다른 메테리얼 자료형을 집어 넣어 갖고 놀 수 있습니다.. 헐..(1차 충격 받음)

```hlsl
void Awake ()
    {
 material = new Material (Shader.Find ("Hidden/NewImageEffectShader"));
    }
```





11\~14번째 줄의 void Awake() 함수는 유니티의 플레이 버튼을 누르기 전 부터 시작 되는 함수입니다. 위에서 미리 선언한 material 변수에 **Shader.Find**라는 명령을 통해 쉐이더랩 스크립트 파일의 주소를 써두면 쉐이더가 메테리얼에 적용됩니다..... 헐....(2차 충격 받음)

![](/assets/images/wix/13974612f7-ce7a39_cd4902fdc74944b3810c71dc06f0c287~mv2.png)

참고로 **void**는 return이 없어도 되는 함수에 붙는 **키워드**입니다.

([https://docs.microsoft.com/ko\-kr/dotnet/csharp/language\-reference/keywords/](<https://docs.microsoft.com/ko-kr/dotnet/csharp/language-reference/keywords/>))

```hlsl
void OnRenderImage (RenderTexture source , RenderTexture destination)
```





![](/assets/images/wix/554a05bbd7-ce7a39_1e378509e9b846679e2190c5d79a7f38~mv2.png)

17번째 줄입니다. 다음은 OnRenderImage(source,destination) 함수입니다. 유니티 메뉴얼 설명대로 포스트 프로세싱에 필수적으로 사용되는 저희가 앞으로 친해져야 할 함수입니다.

source란 후처리 이전의 **원본**을 뜻합니다. 약어로 *src*로 쓰기도 합니다.

> 엄청나게 중요한 점. 원본 이미지는 쉐이더 코드 변수인 **Sampler2D Maintex**에 저장됩니다.

destination이란 후처리 이후의 **수정본**을 뜻합니다.  약어로 *dest*로 쓰기도 합니다.

```hlsl
Graphics.Blit (source, destination);
```



![](/assets/images/wix/d67e606809-ce7a39_7735ff6c18d24986a1b100023129e300~mv2.png)

19\~23번째 줄을 봅시다. **Bilt** 명령입니다. 이것이 사실상의 결과를 출력하는 함수입니다. if문은 어떻게 생긴 놈인지 다들 아시니까 생략하고 내용물만 봅시다.

저희는 intensity라는 float 변수로 포스트\-프로세싱의 on/off를 제어할 것입니다. 0인 경우(꺼진 경우)에 아무 연산도 하지 않고 src, dest 그대로 내보냅니다.

하지만 0이 아니라면? (켜져 있다면?)

```hlsl
material.SetFloat("_bwBlend",intensity);
```





그렇습니다. 놀랍게도 변수 조차 C\# 스크립트로 직접 제어할 수 있습니다. 프로그래머들은 못건드리는게 없었던 겁니다.. 헐... (3차 충격 받음)

변수명**.SetFloat** 명령으로 intensity 값을 쉐이더랩의 \_bwBlend에 집어 넣습니다.

```hlsl
Graphics.Blit (source, destination, material);
 return;
```





다음에는 포스트 프로세스에 사용할 메테리얼을 지정해서 메테리얼에 적용 되어있는 쉐이더에 따라서 처리합니다. 픽셀 쉐이더의 **연산**이 그대로 화면에 출력되는 것입니다.

![](/assets/images/wix/a48662c22a-ce7a39_e58a0f02a198402282d3d4f0b303f883~mv2.png)

마지막으로 씬 어디든지 배치되어 있는 빈 오브젝트 혹은 카메라에 Add component로 넣어줍시다.

![](/assets/images/wix/b3e9be405f-ce7a39_f6e13f50358f4794bd52ba2ba4cd507e~mv2.gif)

(완전 새까매\~\~)

완성입니다. 다음에는 **포스트 프로세스를 이용한 외곽선 검출 방법**으로 찾아뵙겠습니다.
