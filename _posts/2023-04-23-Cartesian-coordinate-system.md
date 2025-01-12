---
title: "게임 수학 입문 03 - 데카르트 좌표계(Cartesian coordinate system)"
excerpt: 실수와 실수의 곱집합을 사용하여 직선으로 표현되는 영역을 평면으로 확장해 표현할 수 있었습니다. 이렇게 직선의 수 집합을 수직으로 배치해 평면을 표기하는 방식을 데카르트 좌표계(Cartesian coordinate system)라고 부릅니다.
date: 2023-04-23 00:00:00 -0000
categories: Math
tag: Algebra

header:
  teaser: /assets/images/Docs/Thumbnails/GameMath-03.png
  overlay_image: /assets/images/Docs/Thumbnails/math.png
  overlay_filter: 0.5

# table of contents
toc: true
toc_label: "목차"
toc_icon: "bars"
toc_sticky: true
---

## 데카르트 좌표계 (Cartesian coordinate system)

이전 포스트에서 함수에 대해서 알아봤을 때, 실수와 실수의 곱집합을 사용하여 직선으로 표현되는 영역을 평면으로 확장해 표현할 수 있었습니다. \\
이렇게 직선의 수 집합을 수직으로 배치해 평면을 표기하는 방식을 **데카르트 좌표계(Cartesian coordinate system)**라고 부릅니다. \\
곱집합의 원어가 데카르트 곱(Cartesian Product)임을 생각해본다면 이 둘은 동일한 개념임을 알 수 있습니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(1).png){: .align-center}

(데카르트 좌표계)
{: .text-center}

데카르트 좌표계는 위 이미지와 같이 수평으로 배치한 첫 번째 실수 집합의 미지수를 ${x}$, 수직으로 배치한 두 번째 실수 집합의 미지수를 ${y}$로 표기하고 원점을 기준으로 x축의 오른편, y축의 위편은 양의 영역을 나타냅니다. \\
이렇게 배치된 두 실수 집합으로 평면을 가르면 평면의 영역은 총 4개의 **사분면(quadrant)**으로 나뉘는데 오른쪽 상단에서 부터 반시계 방향으로 위와 같이 이름을 붙입니다.

$$
(x, y)
$$

데카르트 좌표계의 한 원소는 곱집합과 동일하게 위와 같은 순서쌍으로 표현하며 좌표(Coordinate)라고 부릅니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png){: .align-center}

(좌표의 시각화)
{: .text-center}

일반적으로 좌표는 수와 동일하게 점 또는 원점으로부터의 화살표로 표현합니다. 좌표는 **크기와 방향** 두 가지 속성을 가집니다.

좌표를 다루는 작업은 직선에서 평면으로 무대만 넓어졌을 뿐, 수직선에서 수를 다루는 방식과 매우 유사합니다. 하지만 평면에서 점이 움직이는 것 처럼 보이게 하려면 평면에서 이뤄지는 새로운 연산을 고안해야 할 것입니다.

## 벡터 공간과 벡터
### 스칼라(Scalar)와 벡터(Vector)

평면의 좌표${(x,y)}$는 두 실수 ${x}$와 ${y}$를 결합해서 만들어집니다. \\
그렇기 때문에 좌표의 연산은 실수가 지니는 연산의 성질을 바탕으로 설계되어야 합니다. \\

실수의 연산 성질은 체의 구조를 가진다는 사실을 확인했습니다. \\
이를 기반으로 새로운 공리를 덧붙여서 평면을 대표하는 집합을 규정하고, 해당 집합에서 이뤄지는 덧셈과 곱셈 연산 체계를 만들어야 평면에서의 움직임을 표현 할 수 있습니다.

두 개 이상의 실수를 곱집합으로 묶어 형성된 집합을 공리적 집합론의 관점에서 규정한 것을 **벡터 공간(Vector Space)**라고 부르며, 벡터 공간의 원소를 **벡터(Vector)**라고 합니다. 

공리적 집합론의 관점에서는 특정한 수 집합을 지칭하지 않고 연산이 갖는 성질만 다루기 때문에 좌푯값으로 사용하는 ${x}$와 ${y}$를 실수로 규정하기 보다는 체(Field)의 구조를 지니는 집합, 즉 체 집합의 원소로 규정합니다.

이렇게 체의 구조를 가지는 수 집합의 원소를 **스칼라(Scalar)**라고 부릅니다. \\
우리가 좌표로 사용하는 실수 ${x}$와 ${y}$는 모두 공리적 집합론의 관점에서는 스칼라인 것입니다. 

$$
\vec{v} = (x,y)
$$

집합의 개념인 벡터 공간을 표기할 때는 주로 대문자 ${V}$를 사용하고, 이의 원소인 벡터는 소문자 ${\vec{v}}$로 표기합니다. 벡터는 위와 같이 좌표와 동일한 방법으로 표기합니다.

### 벡터 공간의 연산
공리적 집합론의 관점에서 정의된 벡터 공간은 두 가지 기본 연산이 존재합니다. 다음의 수식에서 사용되는 수 ${a, x, y}$는 모두 체 집합의 원소인 스칼라입니다.

#### 벡터와 벡터의 덧셈 (벡터의 합)

$$
\vec{v_{1}} + \vec{v_{2}} = (x_{1}, y_{1}) + (x_{2}, y_{2}) = (x_{1} + x_{2}, y_{1} + y_{2})
$$

#### 스칼라와 벡터의 곱셈 (스칼라 곱셈)

$$
a * \vec{v} = a * (x, y) = (a * x, a * y)
$$

체가 갖는 연산의 성질에 기반해서 벡터 공간의 연산이 갖는 성질은 다음과 같이 8가지로 정리됩니다. 이를 **벡터 공간의 공리**라고 합니다.

- 벡터의 합
  - 벡터의 합의 결합법칙        
    - ${\vec{u} + (\vec{v} + \vec{w}) = (\vec{u} + \vec{v}) + \vec{w}}$
  - 벡터의 합의 교환법칙        
    - ${\vec{u} + \vec{v} = \vec{v} + \vec{u}}$
  - 벡터의 합의 항등원          
    - ${\vec{v} + \vec{0} = \vec{v}}$
  - 벡터의 합의 역원            
    - ${\vec{v} + (-\vec{v}) = \vec{0}}$
- 스칼라 곱셈
  - 스칼라 곱셈의 호환성         
    - ${a(b\vec{v}) = (ab)\vec{u}}$
  - 스칼라 곱셈의 항등원         
    - ${1 * \vec{v} = \vec{v}}$
  - 벡터의 합에 대한 분배법칙    
    - ${a(\vec{u} + \vec{v}) = a\vec{u} + a\vec{v}}$
  - 스칼라 합에 대한 분배법칙    
    - ${(a + b)\vec{v} = a\vec{v} + b\vec{v}}$

위와 같은 벡터 공간의 공리는 모두 체의 공리를 기반으로 하기 때문에 해당 공리가 참임을 바로 파악할 수 있습니다. \\
예를 들어서 벡터의 합이 교환법칙을 만족하는 까닭은 두 스칼라의 덧셈이 교환법칙을 만족하기 때문입니다.

$$
\vec{v_{1}} + \vec{v_{2}} = (x_{1}, y_{1}) + (x_{2}, y_{2}) = (x_{1} + x_{2}, y_{1} + y_{2}) \\
\vec{v_{2}} + \vec{v_{1}} = (x_{2}, y_{2}) + (x_{1}, y_{1}) = (x_{2} + x_{1}, y_{2} + y_{1}) \\
\therefore \vec{v_{1}} + \vec{v_{2}} = \vec{v_{2}} + \vec{v_{1}}
$$

벡터 공간에서 벡터의 합과 스칼라 곱셈에 따라 점의 움직임이 어떻게 달라지는지 시각화 하여 확인해봅시다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(2).png){: .align-center}

(벡터의 합 연산)
{: .text-center}

벡터의 합은 위 이미지와 같이 평면의 점을 각 축에 대해 독립적으로 평행이동 시키는 작업으로 해석할 수 있습니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(3).png){: .align-center}

(스칼라 곱셈)
{: .text-center}

위와 같이 스칼라 곱셈을 시각화 해봤습니다. \\
벡터 ${\vec{v}}$에 스칼라 곱셈을 하여 생성된 벡터는 원점을 지나고 벡터와 평행한 직선상에 위치합니다. \\ 
따라서 스칼라 곱셈의 결과는 항상 검은색 점선으로 표현한 원점을 지나는 직선상의 벡터를 만들어냅니다.

### 벡터의 크기와 이동
벡터 ${\vec{v}}$의 크기는 원점으로 부터의 거리를 의미하며 절댓값 기호 ${\mid\vec{v}\mid}$ 를 사용해 구할 수 있습니다. \\
벡터의 크기도 동일하게 원점으로부터의 최단거리를 의미합니다. 

수학에서 일반적인 표기법으로 벡터의 크기는 절댓값 기호를 두 번 사용하여 표기하지만 이 포스트에서는 하나만 사용합니다.
{: .notice--info}

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(4).png){: .align-center}

(피타고라스 정리로 벡터의 크기를 측정)
{: .text-center}

이를 측정하려면 원점과 벡터를 연결해 직각 삼각형을 그린 후, 피타고라스 정리를 사용해 거리를 측정 할 수 있습니다.

$$
|\vec{v}| = \sqrt{x^{2} + y^{2}}
$$

이렇게 측정된 벡터의 크기 역시 절댓값 기호와 동일한 것을 사용합니다. 벡터${(x,y)}$의 크기를 구하는 공식은 위와 같습니다.

벡터의 크기는 노름(Norm)이라는 용어로 부르기도 합니다.
{: .notice--info}

벡터의 크기에 관련된 유용한 표기방법과 수식을 알아봅시다. \\
먼저 크기가 ${1}$인 벡터를 **단위 벡터(unit vector)**라고 합니다. \\
단위 벡터는 벡터의 크기를 측정하는 기준이 되며, 앞으로 벡터와 관련된 다양한 응용식을 전개하는데 자주 사용될 것입니다. \\
단위 벡터는 다음과 같이 모자 기호(Hat)을 씌워 ${\hat{v}}$의 형태로 표시합니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(5).png){: .align-center}

(벡터의 정규화)
{: .text-center}

스칼라 곱셈의 성질을 이용해서 
임의의 벡터 ${\vec{v}}$ 를 
크기인 ${|\vec{v}|}$로 나누면 
단위 벡터 ${\hat{v}}$를 얻을 수 있습니다.

$$
\hat{v} = \frac {\vec{v}} {|\vec{v}|}
$$

임의의 벡터 ${\vec{v}}$를 크기가 1인 단위벡터 ${\hat{v}}$로 다듬는 작업을 정규화(Normalize)한다 라고 부르며 수식은 위와 같습니다.

TMI : 위 계산은 HLSL에서 x / length(x) 연산과 같으며, normalize() 라는 이름의 함수로 만들어져있습니다. 
{: .notice--info}


## 레퍼런스(Reference)
- 이득우의 게임수학 : ([http://www.yes24.com/Product/Goods/107025224](http://www.yes24.com/Product/Goods/107025224))

