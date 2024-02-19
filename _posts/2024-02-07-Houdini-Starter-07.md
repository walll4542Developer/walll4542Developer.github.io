---
title: "후디니 입문 07 - Vex 언어 : 데이터 타입과 입력"
excerpt: ""
date: 2024-02-07 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-06.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## Vex 언어
Vex 언어는 후디니에서 사용하는 언어입니다.

### Vex 데이터 타입
자주 사용하게 될 데이터(Data) 타입은 다음과 같습니다.

- float
- int
- vector
- string

Vex 언어의 데이터는 **변수(variable)와 어트리뷰트(Attribute)**로 구분합니다. \\
Vex 에서 정보를 담는 변수 a를 선언한다면 다음과 같이 작성할 수 있습니다.

```hlsl
float a
int a
vector a
string a
```

어트리뷰트 a를 선언한다면 다음과 같이 작성할 수 있습니다.

```hlsl
f@a
i@a
v@a
s@a
```

어트리뷰트를 선언할 때 데이터 타입을 작성하기 떄문에, 어트리뷰트를 사용하여 계산할 때는 다음과 같이 데이터 타입을 생략할 수 있습니다.

```hlsl
i@a = 3;
i@b = 5;
float x = @a + @b;
```

### Vex 코드 입력하기

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/000.png){: .align-center}

Vex 코드는 **어트리뷰트 랭글(Attribute Wrangle) 노드**에서 입력하고 사용합니다.

어트리뷰트 랭글이 노드라는 점에 주목하세요. Vex 코드를 입력할 수 있을 뿐, 다른 노드와 동일하게 인풋(input)과 아웃풋(output)이 존재합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/000.png){: .align-center}

파라미터 중에서 'Run Over'는 인풋으로 들어온 노드 데이터 중에서 어떤 인풋을 대상으로 Vex 코드가 실행되게 할 것인지 결정할 수 있습니다.

만약 인풋으로 포인트(Point) 데이터만 들어왔는데 프리미티브(primitive) 데이터를 런오버(Run Over)로 설정하면 노드는 아무 동작을 하지 않습니다.



## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))