---
title: "후디니 입문 11 - Vex 함수 : 삼각함수"
excerpt: "후디니에서 삼각함수를 사용하는 방법에 대해 소개합니다."
date: 2024-02-11 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-11.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

후디니에서 삼각함수를 사용하는 방법에 대해 소개합니다. 함수를 소개하기 위한 예제를 준비 할 것입니다.

### addpoint 함수

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/140.png){: .align-center}

```hlsl
addpoint(0, {0, 0, 0});
```

```hlsl
vector pos = {2, 0, 0};
addpoint(0, pos);
```

### for 함수

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/139.png){: .align-center}

```hlsl
for(int i = 0; i < 11; i++)
{
  addpoint(0, set(i, 0, 0));
}
```

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/067.gif){: .align-center}

```hlsl
int k = int(@Frame);
for(int i = 0; i < k; i++)
{
  vector pos = set(i, 0, 0);
  addpoint(0, pos);
}
```

`@Frame` 을 사용하여 애니메이션 시킬 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/141.png){: .align-center}

포인트들을 더하기(Add) 노드를 사용해서 'By Group' 으로 지정해주면 선분이 됩니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/068.gif){: .align-center}

다음은 선분이 늘어나는 길이를 제어하고 싶습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/069.gif){: .align-center}


```hlsl
int k = int(@Frame);
for(int i = 0; i < k; i++)
{
  vector pos = set(chf("Length") * i, 0, 0);
  addpoint(0, pos);
}
```

`Length` 파라미터를 추가하여 길이를 조절 했습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : ([https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI))
- Vex : [https://www.sidefx.com/docs/houdini/vex/index.html](https://www.sidefx.com/docs/houdini/vex/index.html)
