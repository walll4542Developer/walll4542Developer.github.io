---
title: "후디니 입문 07 - Vex 언어 : 데이터 타입과 입력"
excerpt: "Vex 언어는 후디니에서 커스텀 노드와 셰이더를 작성하기 위해 설계된 고성능 표현 언어(high-performance expression language)입니다. "
date: 2024-02-07 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-07.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## Vex 언어
Vex 언어는 후디니에서 커스텀 노드와 셰이더를 작성하기 위해 설계된 고성능 표현 언어(high-performance expression language)입니다.

Vex 는 C언어를 기반으로 동작 하지만 C++ 과 RenderMan 셰이딩 언어에서도 영감을 받아 제작되었습니다. *의역입니다.*

- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)

### Vex 데이터 타입
자주 사용하게 될 데이터(Data) 타입은 다음과 같습니다.

- `float`
- `int`
- `vector`
- `string`

Vex 언어의 데이터는 **변수(variable)와 어트리뷰트(Attribute)**로 구분합니다. \\
Vex 에서 정보를 담는 변수 `a`를 선언한다면 다음과 같이 작성할 수 있습니다.

```hlsl
float a;
int a;
vector a;
string a;
```

어트리뷰트 a를 선언한다면 다음과 같이 작성할 수 있습니다.

```hlsl
f@a;
i@a;
v@a;
s@a;
```

어트리뷰트나 변수를 선언할 때 데이터 타입을 작성하기 떄문에, 계산할 때는 다음과 같이 `@a`와 `@b`의 데이터 타입을 생략할 수 있습니다.

```hlsl
i@a = 3;
i@b = 5;
i@c = @a + @b;
```
### Vex 코드 입력하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/086.png)

Vex 코드는 **어트리뷰트 랭글(Attribute Wrangle) 노드**에서 입력하고 사용합니다.

어트리뷰트 랭글이 **노드**라는 점에 주목하세요. Vex 코드를 입력할 수 있을 뿐, 다른 노드와 동일하게 인풋(input)과 아웃풋(output)이 존재합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/087.png)

파라미터 중에서 **Run Over**는 인풋으로 들어온 노드 데이터 중에서 어떤 인풋을 대상으로 Vex 코드가 실행되게 할 것인지 결정할 수 있습니다.

만약 인풋으로 포인트(Point) 데이터만 들어왔는데 프리미티브(primitive) 데이터를 런오버(Run Over)로 설정하면 노드는 아무 동작을 하지 않습니다.


#### 어트리뷰트 선언하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/088.png)

```hlsl
f@a = 0.1;
f@b = 0.2;
```

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/089.png)

어트리뷰트 랭글 노드의 인포(info)와 지오메트리 스프레드 시트(Geomatry Spread Sheet)를 확인하면 위와 같이 `float` 데이터 타입 `a` 와 `b` 변수가 추가된 것을 확인하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/090.png)

```hlsl
f@a;
f@b;
```

초기값을 설정하지 않으면 값은 자동으로 ${0.0}$이 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/091.png)


#### 변수 선언하기

```hlsl
float a = 0.0;
float b = 1.0;
```

변수의 경우 Vex 에서 선언하더라도 지오메트리 스프레드 시트에서 값을 볼 수 없습니다.

즉 아웃풋으로 사용하고자 하는 값은 반드시 어트리뷰트로 선언해야 합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/094.png)

```hlsl
float a,b;

a = 0.0;
b = 1.0;
```

콤마 '${,}$' 기호를 사용해서 동시에 여러 변수를 선언 할 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/050.gif)

```
float a,b = 0.0;

a,b = 1.0;
```

그러나 동시에 변수를 정의 할 수는 없으며 변수에 값을 대입하는 것 또한 불가합니다. 

위와 같이 Vex 문법이 틀려서 구문 오류가 발생할 경우 어디서 틀렸는지, 왜 틀렸는지가 표시됩니다.

에러가 발생할 경우 지오메트리 스프레드 시트에도 결과물이 출력되지 않습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/092.png)

```hlsl
int a = 1;
int b = 2;

i@c = a + b;
```

`attributewrangle1` 노드의 `i@c` 값은 ${3}$ 입니다. 

그럼 이 값을 `attributewrangle2` 의 인풋으로 받은 다음 다시 연산을 해주면 어떻게 될까요?

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/093.png)

```hlsl
int a = -3;

i@c = @c + a;
```

지오메트리 스프레드 시트의 값을 보니 `i@c` 값이 ${0}$ 이 되었습니다.

Vex 문법에서 이전의 이전 노드에서 `i@c`로 데이터 타입을 선언을 했더라도 다음 노드에서 인풋 값을 최초로 받아올 때는 `@c`가 아닌 `i@c`로 데이터 타입을 표기 하는 것이 권장됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/095.png)

```hlsl
int a = -3;

i@c += a;
```

'${+=}$' 로 한 번에 계산하는 것이 가능합니다. 이를 *업데이트* 라고 표현하기도 합니다.

### 벡터(Vector) 데이터 타입

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/095.png)

```hlsl
v@a = {1, 2, 3};
vector b = {4, 5, 6};
```

#### 괄호(Braket) 표기하기
- 소괄호(Parentheses) ${()}$
- 중괄호(Curly Braket) {}
- 대괄호(Square Braket) ${[]}$

벡터(Vector)는 우리가 익히 알던 HLSL 또는 C 계열 언어와 규칙이 같으면서도 살짝 다릅니다. Vex 언어에서 벡터를 표기할 때는 소괄호 ${()}$ 가 아닌 중괄호 {} 를 사용해야 합니다.

벡터는 항상 ${(x, y, z)}$ 값이 필요하며 ${(x, y, z)}$ 의 각 성분은 모두 `float` 입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/097.png)

지오메트리 스프레드 시트에서 더하기(add) 노드로 생성한 포인트의 어트리뷰트(Attribute) `P` 정보를 보면 ${(0, 0, 0)}$ 에 위치 하고 있는 것을 알 수 있습니다. 

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/051.gif)

어트리뷰트 `P` 는 포인트의 벡터3 좌표 값으로 인포(info)에서 확인한 정보는 **P 3 flt (Pos)**라고 표기하고 있습니다. 이때 `Pos`는 포지션의 약어입니다.

이 벡터를 가지고 더하기(add) 노드로 생성한 포인트의 위치를 이동시킬 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/098.png)

```hlsl
vector move = {1, 0, 0};

@P += move;
```

어트리뷰트 `P` 는 이미 인풋으로 들어와 있기에 `@P` 로 사용할 수 있습니다.

`move` 값을 더해서 ${x}$축 방향으로 ${1}$만큼 이동하도록 업데이트 했더니 실제로 포인트의 위치가 ${(1, 0, 0)}$ 으로 이동한 것을 확인하실 수 있습니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/099.png)

```hlsl
float a = 0.1;
float b = 0.2;
float c = 0.3;

vector move = {a, b, c};

@P += move;
```

벡터의 각 성분들은 분명히 `float`입니다. 그러나 벡터의 중괄호 {} 안에 `float` 변수를 넣어주는 것은 틀린 문법입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/100.png)

```hlsl
float a = 0.1;
float b = 0.2;
float c = 0.3;

vector move = set(a, b, c);

@P += move;
```

대신 위와 같이 `set(,,)` 이라는 함수를 사용해서 벡터에 값을 대입해줄 수 있습니다. `@P` 의 값이 ${(0.1, 0.2, 0.3)}$ 으로 변경 되었습니다.

#### 컬러 정보(Cd) 사용하기

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/101.png)

```hlsl
v@Cd = {1, 0, 0};
```

`@Cd` 는 포인트의 컬러 값입니다. ${(1, 0, 0)}$ 이면 빨강색이기 때문에, 씬 뷰(씬 뷰)에서도 포인트가 빨강색으로 변했습니다.

이처럼 `@Cd` 와 `@P` 등 후디니에 의해서 미리 예약된 어트리뷰트들이 여러가지가 있어서 이를 피해서 사용해야 합니다.

### 스트링(String) 데이터 타입

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/102.png)

```hlsl
s@a = "Developer";
```

스트링(String) 또는 문자열 데이터 타입은 위와 같이 큰 따옴표 ${""}$ 기호를 사용합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/103.png)

```hlsl
s@a = "Developer";
s@b = "Game";

s@c = @b + @a;
```

Vex 언어는 C 계열 언어 처럼 문자열 데이터 끼리 연산할 수도 있습니다.

'${+}$' 연산을 해서 `@a` 와 `@b` 를 더하면 두 문자열이 하나로 합쳐진 결과 `@c`를 확인 할 수 있습니다. \\
물론 연산 순서를 바꾸면 계산 결과도 달라집니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/104.png)

```hlsl
string a = "Developer";
string b = "Game";

s@c = b + "_" + a;
```

연산 사이에 큰 따옴표 ${""}$ 기호를 직접 입력하여 문자열을 수정할 수도 있습니다.


## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
