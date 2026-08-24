---
title: "후디니 입문 18 - Forloop 반복문"
excerpt: "후디니에서 forloop 반복문 노드를 사용하는 방법에 대해서 알아보겠습니다."
date: 2024-02-18 00:00:00 -0000
categories: Houdini
tag: Study

header:
  teaser: /assets/images/Docs/Houdini%20Beginner/thumbnail-18.gif
  overlay_image: /assets/images/Docs/Houdini%20Beginner/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/163.png)

후디니에서 `forloop` 반복문 노드를 사용하는 방법에 대해서 알아보겠습니다. 위와 같이 노드를 준비해주세요.

### forloop 반복문

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/164.png)

`foreach` 반복문은 여러 프리셋이 있지만, `forloop`는 없는 것이 특징입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/165.png)

`foreach input`은 모든 `input`을 분해(blast)한 뒤, `foreach` 블록(block)의 내부 작업을 수행하고 나서 하나의 결과로 묶어(merge)줍니다.

그러나 `forloop`는 분해 하지 않습니다. 그저 `forloop` 블록 내부의 내용을 이터레이션(iteration) 횟수 만큼 반복할 뿐입니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/124.gif)

그리고 결과를 **'Feedback each iteration'** 또는 **'Merge each iteration'** 으로 사용할 수 있습니다.

- 'Feedback each iteration'은 모든 이터레이션이 반복된 최종 결과만 반환합니다.
- 'Merge each iteration'은 개별 이터레이션의 결과를 모두 합쳐서 반환합니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/125.gif)

hscript의 `$F` 구문을 사용하여 현재 프레임 값을 이터레이션으로 넣어주면 위와 같이 프레임에 따라 애니메이션 됩니다.

![Houdini-Beginner](/assets/images/Docs/Houdini%20Beginner/126.gif)

```hlsl
f@Alpha -= 0.05;
@Alpha = clamp(@Alpha, 0, 1);
```

`@Alpha`는 오브젝트의 컬러 알파 값입니다. 

어트리뷰트 랭글 노드를 `forloop` 블록 내부에 넣으면 이터레이션 될 때 마다 알파 값이 ${0.05}$만큼 감소한 상태가 저장됩니다.

- 'Feedback each iteration' 은 알파값이 ${0.05 *}$`$F` 만큼 줄어들고 난 이후의 최종 결과만 반환하고 있습니다.
- 'Merge each iteration' 은 알파값이 ${0.05}$만큼 줄어드는 개별 이터레이션을 모두 합쳐서 반환하는 것을 확인할 수 있습니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
