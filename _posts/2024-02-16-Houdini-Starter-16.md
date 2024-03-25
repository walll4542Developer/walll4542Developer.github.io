---
title: "후디니 입문 16 - 라인(line) 애니메이션 기초"
excerpt: "지금까지 공부한 여러 함수들을 응용하여 위와 같은 간단한 라인 애니메이션을 제작해보고자 합니다."
date: 2024-02-16 00:00:00 -0000
categories: Houdini
tag: Research

header:
  teaser: /assets/images/Docs/Houdini%20Starter/thumbnail-16.gif
  overlay_image: /assets/images/Docs/Houdini%20Starter/sidefx-houdini-hd-logo-01.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 개요


![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/101.gif){: .align-center}

```hlsl
i@start = chi("start");
i@totalPlay = chi("totalPlay");
i@end = @start + @totalPlay;

f@play = clamp((@Frame - @start) / @totalPlay, 0, 1); // saturate

@play = chramp("play", @play);

f@follow = chramp("follow", @play);
```

지금까지 공부한 여러 함수들을 응용하여 위와 같은 간단한 라인 애니메이션을 제작해보고자 합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/102.gif){: .align-center}

먼저 라인이 애니메이션될 경로를 서클(circle) 노드를 여러개 만들어줍니다. 

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/105.gif){: .align-center}

블라스트(blast) 노드로 라인의 시작과 끝을 지정할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/104.gif){: .align-center}

애니메이션이 끊기지 않도록 트랜스폼(transform) 노드를 사용하여 회전과 위치를 이동하여 시작점과 끝점을 잘 잡아줍시다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/103.gif){: .align-center}

머지(merge) 노드로 여러 라인들을 순서가 맞게 잘 배열합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/106.gif){: .align-center}

결과물을 'by Group'을 사용하여 라인으로 이어줍니다. 이어준 라인을 서브디바이드(subdivide) 노드와 리샘플(resample) 노드를 사용하여 일정한 간격을 유지하도록 재배열합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/149.png){: .align-center}

리샘플(resample) 노드에서 'curve U Attribute'를 체크하면 `@curveU` 어트리뷰트를 만들수 있습니다.

`@curveU`는 커브의 시작과 끝 길이를 ${0}$과 ${1}$사이로 정규화한 값을 반환합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/150.png){: .align-center}

'Edit parameter interface' 메뉴에서 'Ramp Type' 값을 **'Color'**로 설정하면 컬러 램프를 사용할 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/100.gif){: .align-center}

```
v@Cd = chramp("color", @curveu);
```

`@curveU` 값을 컬러 램프의 값으로 지정하고 이를 포인트 컬러 `@Cd` 로 사용하면 라인에 색상을 입힐 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/108.gif){: .align-center}

'Play' 그래프를 베지어(Bezier) 커브로 조절하여 적절하게 속도를 제어합니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/107.gif){: .align-center}

```hlsl
@P.z = chf("length") * @ptnum;
```

라인 애니메이션에 ${z}$축을 추가하고, 애니메이션이 재생되는 동안 포인트가 ${z}$ 방향으로 이동하게 합니다.

이는 `@ptnum` 값으로 애니메이션의 시작과 끝에 비례하게 이동시킬 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/110.gif){: .align-center}

동일한 패턴을 복제하고 머지 노드로 다시 합친다면 애니메이션 길이를 두 배로 늘릴 수 있습니다.

![Houdini-Starter](/assets/images/Docs/Houdini%20Starter/109.gif){: .align-center}

라인 애니메이션의 완성입니다. 끝까지 읽어주셔서 감사합니다. 여러분의 관심이 제게 큰 도움이 됩니다.

## 레퍼런스(Reference)
- TWA 후디니의 정석 : [https://www.youtube.com/@TWAHOUDINI](https://www.youtube.com/@TWAHOUDINI)
