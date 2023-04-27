---
title: "삼각함수(Trigonometric function)"
excerpt: 직각 삼각형을 데카르트 좌표계 상에 배치하고 사잇각의 범위를 실수 전체로 확장한 대응 관계를 삼각함수(Trigonometric function)라고 합니다.
date: 2023-04-25 00:00:00 -0000
categories: Math
tag: Algebra

header:
  teaser: /assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png
  overlay_image: /assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png){: .align-center}

한 각이 직각(90도)인 직각삼각형을 이루는 세 변은 각 위치에 따라 빗변, 밑변, 높이 라고 부릅니다. 한 각이 직각이므로 나머지 두 각의 합이 90도가 되어야 합니다. 따라서 두 각은 모두 90도 보다 작은 예각입니다. 빗변과 밑변의 사잇각은 기호 (${\theta}$)를 이용해 나타냅니다.

직각삼각형을 구성하는 세 변에서 두 변을 뽑아 각각의 비례 관계를 나타낸 것을 **삼각비(trigonometric Ratio)**라고 합니다. 삼각비에는 여러 종류가 있지만 **사인(Sine), 코사인(Cosine), 탄젠트(Tangent)** 세 가지가 가장 대표적입니다.

$$
sin \theta = \frac{b}{c} \\
cos \theta = \frac{a}{c} \\
tan \theta = \frac{b}{a}
$$

밑변의 길이를 a, 높이를 b, 빗변의 길이를 c, 빗변과 밑변과의 사잇 각을 ${\theta}$라고 할 때, 각 삼각비의 관계는 위와 같이 분수식으로 표현할 수 있습니다.

직각 삼각형에서 측정할 수 있는 사잇각은 0도 보다 크거나 90도 보다 작아야 합니다. 이때 위 이미지와 같이 직각 삼각형을 데카르트 좌표계 상에 배치하고 사잇각의 범위를 실수 전체로 확장한 대응 관계를 **삼각함수(Trigonometric function)**라고 합니다.

가장 많이 사용하는 삼각함수인 sin() 함수와 cos() 함수의 개념은 직각삼각형에서 출발했지만 원점을 중심으로 반지름이 1인 평면 위의 **단위 원(Unit circle)**을 사용해 나타내면 좀 더 쉽게 파악할 수 있습니다. 데카르트 좌표계에서 원점에서부터 제 1 사분면의 단위 원의 원주 위에 있는 임의의 점을 이어 빗변을 그었습니다.

원의 반지름의 길이는 1이므로 이 빗변의 길이는 항상 1입니다. 그리고 x축과 해당 빗변이 이루는 각을 사잇각으로 지정합니다.

그런 다음에는 빗변에서 x축으로 수직선을 내려 직각 삼각형을 그려봅시다. 직각삼각형으로 부터 삼각비를 계산 할 수 있을 것입니다.

$$
sin \theta = frac{b}{1} = b
cos \theta = frac{a}{1} = a
$$

빗변 c의 길이가 1이므로 삼각비 ${sin\theta}$의 값은 높이 b와 같고, ${cos\theta}$의 값은 밑변 a와 같습니다. 따라서 데카르트 좌표계에서 빗변이 가리키는 단위 원의 좌표는 ${(sin\theta, cos\theta)}$로 표현할 수 있는데, 이를 삼각함수로 확장하면 원주 위의 모든 좌표는 ${(sin\theta, cos\theta)}$에 대응한다고 할 수 있습니다.

$$
cos^{2}\theta + sin^{2}\theta = 1
$$

그렇다면 밑변 a의 x좌표는 ${cos\theta}$가 되고, 높이 b의 좌표는 ${sin\theta}$가 되는데 이를 피타고라스 정리 ${a^{2} + b^{2} = c^{2}}$에 대입하면 위와 같은 공식을 얻을 수 있습니다.

단위 원의 반지름 길이를 r으로 일반화 시켜서 생각해봅시다. 
반지름이 r인 원에서의 빗변은 벡터의 개념으로 보았을 때 길이가 1인 벡터와 평행하고 길이는 r배 만큼 증가 했으므로 스칼라 곱셈에 의해 ${r * (cos\theta, sin\theta)}$라는 좌표를 갖게 됩니다. 
이로써 빗변의 길이가 r인 직각삼각형의 밑변의 길이는 ${r * cos\theta}$가 되고, 높이의 길이는 ${r * sin\theta}$가 됨을 알 수 있습니다.

$$
r^{2}(cos^{2}\theta + sin^{2}\theta) = r^{2}
cos^{2}\theta + sin^{2}\theta = 1
$$

앞서 구한 식은 반지름의 길이와 무관하게 동일하게 성립함을 알 수 있습니다.

이 식은 삼각함수의 기본을 이루는 중요한 공식으로, 이후 회전과 관련된 계산에 유용하게 사용되므로 암기해 두는 것을 권장합니다.
{: .notice--info}

### 삼각함수의 성질

$$
\vec{v} = (v_{x}, v_{y}) = (cos0, sin0) = (1,0)
sin0 = 0, cos0 = 1
$$

데카르트 좌표계에서 각도(angle)는 x축에서 원의 궤적을 따라 반시계 방향으로 회전한 크기를 의미합니다. 반지름이 1인 단위 원에서 반시계 방향의 회전을 생각해봅시다.
아직 회전하지 않아서 x축 상에 위치한 빗변 ${\vec{v}}$와의 좌표는 (1,0)인데, 이 각도는 0도에 대응한다고 할 수 있습니다. 따라서 각도에 대한 sin 함수와 cos함수의 값은 위와 같습니다.






## 레퍼런스(Reference)
- 이득우의 게임수학 : ([http://www.yes24.com/Product/Goods/107025224](http://www.yes24.com/Product/Goods/107025224))

