---
title: "벡터의 결합과 생성(Vector Combination)"
excerpt: 벡터 공간의 기본 연산을 사용해 벡터를 움직이는 방법에 대해서 알아봤습니다. 이번에는 벡터의 기본 연산을 사용해 벡터 공간의 구조를 분석하고 이로부터 벡터 공간이 가진 다양한 성질을 추출해보겠습니다.
date: 2023-04-27 00:00:00 -0000
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

## 벡터의 결합과 생성
벡터 공간의 기본 연산을 사용해 벡터를 움직이는 방법에 대해서 알아봤습니다. 이번에는 벡터의 기본 연산을 사용해 벡터 공간의 구조를 분석하고 이로부터 벡터 공간이 가진 다양한 성질을 추출해보겠습니다.

$$
a_{1}\vec{v_{1}} + a_{2}\vec{v_{2}} + a_{3}\vec{v_{3}} ... + a_{n}\vec{v_{n}} = \vec{v`}
$$

벡터 공간의 벡터의 합과 스칼라 곱셈 연산은 선형성이 있어 선형 연산이라고도 합니다. 선형 연산을 사용해 ${n}$ 개의 스칼라 {a_{1}, ..., a_{n}}와 ${n}$ 개의 벡터 ${\vec{v_{1}}, ..., \vec{v_{n}}}$ 를 결합해 새로운 벡터 를 생성하는 수식을 선형결합이라고 합니다. 선형 결합의 수식은 위와 같습니다.

$$
a_{1}\vec{v_{1}} + a_{2}\vec{v_{2}} + a_{3}\vec{v_{3}} ... + a_{n}\vec{v_{n}} = \vec{0}
$$

여기서 위와 같은 벡터의 모든 원소가 0으로 구성된 영벡터 ${\vec{0}}$를 생각했을때 선형결합의 결과가 ${\vec{0}}$이 나오는 수식을 생각해봅시다.

벡터에 곱하는 모든 스칼라 값이 0이면 선형 결합의 결과는 항상 영벡터가 됩니다. 그런데 a값이 0이 아닌 경우에도 영벡터는 나올 수 있습니다. 간단한 예를 들어봅시다.

$$
2 * (1,1) + (-1) * (2,2) = (0,0)
$$

위의 계산식과 같이 모든 스칼라 값이 0이 아님에도 영벡터를 만들 수 있다면, 선형 결합에 사용된 벡터는 서로 '선형 종속의 관계'를 가진다고 표현합니다. 따라서 (1,1)과 (2,2)의 두 벡터는 선형 종속인 관계를 갖습니다.

$$
0 * (1,2) + 0 * (2,1) = (0,0)
$$

반면 영벡터가 나오기 위해서 모든 스칼라 값이 0이어야 한다면 선형 결합에 사용된 벡터들은 서로 '선형 독립의 관계'를 갖는다고 푠현합니다. 위 수식에서 (1,2)와 (2,1)두벡터가 결합할 때 영벡터가 나오려면 모든 스칼라 a의 값은 0이어야 합니다. 따라서 (1,2)와 (2,1)의 두 벡터는 선형독립의 관계를 갖습니다.

벡터간의 선형적 관계는 벡터 공간을 다룰 때 중요하게 사용됩니다. 선형 독립의 관계를 가지는 벡터를 선형 결합하면 벡터 공간에 속한 모든 벡터를 생성할 수 있기 때문입니다. 선형 독립의 관계를 가지는 벡터를 결합해 어떻게 벡터 공간의 모든 벡터를 생성하는지 2차원 평면의 예제를 통해 살펴 볼 수 있습니다. 

$$
\vec{w} = a * \vec{u} + b * \vec{v}
$$

두 벡터 ${\vec{u}}, \vec{v}$와 두 스칼라 ${a,b}$를 결합해서 새로운 벡터 ${\vec{w}}$를 생성하는 수식은 위와 같이 나타낼 수 있습니다.
두 벡터가 선형 독립의 관계를 가진다면 이 선형 결합식으로 2차원 벡터 공간에 속한 모든 벡터를 생성할 수 있습니다. 그 원리를 알아봅시다. 

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png){: .align-center}

(두 단위 벡터의 선형 결합으로 벡터를 생성한 예시)
{: .text-center}

$$
(5,5) = 5 * (1,0) + 5 * (0,1)
$$

예를 들어 벡터 ${\vec{w}}$ 값이 (5,5)라고 가정한다면, 이 벡터를 생성하는 두 벡터의 결합으로는 x축과 y축에 일치하는 두 단위 벡터 (1,0)과 (0,1)를 사용한 위와 같은 선형 결합식을 생각할 수 있습니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png){: .align-center}

위 이미지와 같이 벡터 (5,5)를 생성할 수 있는 선형 결합식은 이 밖에도 얼마든지 다양하게 존재합니다.

$$
(w_{x}, w_{y}) = a * (2,1) + b * (1,3)
$$

그렇다면 벡터(2,1)과 벡터 (1,3)을 결합했을 때 (5,5)가 아닌 다른 벡터도 생성할 수 있을까요? 이를 사용해 순서쌍 ${(w_{x}, w_{y})}$로 구성된 임의의 벡터 ${\vec{w}}$를 생성하는 수식은 위와 같습니다.

$$
2a + b = w_{x} \\
a + 3b = w_{y}
$$

그리고 x값과 y값을 분리해 위 식을 전개하면 위와 같습니다.

$$
a = \frac{3w_{x} - w_{y}}{5}, b = \frac{2w_{y}-w_{x}}{5}
$$

두 식을 a와 b에 대한 연립방정식으로 보고 풀어보면 그 값은 벡터 ${\vec{w}}$의 좌푯값인 ${(w_{x}, w_{y})}$값에 따라 결정되며, 언제나 해가 존재함을 알 수 있습니다.

$$
a = \frac{3 * 0 - 0}{5}, b = \frac{2 * 0 - 0}{5}
$$

따라서 벡터 (2,1)과 벡터 (1,3)을 결합해 평면에 속한 모든 벡터를 생성할 수 있음을 알 수 있습니다. 그리고 벡터 ${\vec{w}}$값이 영벡터가 되는 a와 b의 해는 모두 0인 경우 뿐입니다. 

$$
a_{1}\vec{v_{1}} + a_{2}\vec{v_{2}} + a_{3}\vec{v_{3}} ... + a_{n}\vec{v_{n}} = \vec{0}
$$

벡터의 모든 원소가 0으로 구성된 영벡터 ${\vec{0}}$들의 선형결합의 결과가 ${\vec{0}}$이 나오는 수식 처럼, 벡터 (2,1)과 벡터 (1,3)은 서로 선형 독립의 관계를 가집니다.

$$
(5,5) = a * (1,2) + b * (2,4)
$$

이번에는 다른 두 벡터 (1,2)와 (2,4)를 결합 하였을때 벡터(5,5)를 생성할 수 있는지 알아보겠습니다.

$$
a + 2b = 5\\
2a + 4b = 5
$$

이 역시 a와 b의 연립방정식으로 보고 a와 b의 값을 구하는 문제로 귀결됩니다.

$$
2a + 4b = 10 \\
2a + 4b = 5
$$

그런데 이를 만족하는 a와 b의 값을 구할 수가 없습니다.

![Cartesian coordinate system](/assets/images/Docs/Cartesian%20coordinate%20system/image%20(0).png){: .align-center}

(선형결합 결과)
{: .text-center}

어째서 이 값을 구할 수 없는지 좌표 평면으로 확인 해볼 수 있습니다. 두 벡터 (1,2)와 (2,4)는 평행하지만, (5,5)와는 평행하지 않다는 것을 알 수 있습니다.

$$
(x,y) = a(1,2) + b(2,4) = a(1,2) + 2b(1,2) = (a + 2b) * (1,2)
$$

위 식에서도 알 수 있듯이, 평행한 두 벡터를 결합한 결과는 두 개의 벡터 결합이 아닌 하나의 벡터 (1,2)에 스칼라 곱을 적용한 결과에 불과합니다.
따라서 a와 b에 어떤 스칼라 값을 대입하더라도 선형 결합의 결과는 벡터 (1,2)와 평행한 벡터만 생성될 뿐이고, 이와 평행하지 않은 벡터 (5,5)를 생성하는 것은 불가능합니다.

$$
2 * (1,2) + (-1) * (2,4) = (0,0)
$$

(1,2)와 (2,4)의 관계를 선형 결합식으로 나타내면 위와 같습니다.
0이 아닌 임의의 계수를 사용해 영벡터를 만들수 있으므로 두 벡터는 선형 종속의 관계를 가집니다. 벡터와 스칼라 곱의 결과는 이들과 평행한 벡터를 생성하므로 결국에는 붉은 선상에 위치한 벡터만 생성할 수 있습니다. 
이로써 평면의 모든 점을 생성하기 위한 선형 결합식에는 서로 평행하지 않은 2개의 벡터가 필요함을 알 수 있으며 두 벡터는 서로 선형 독립의 관계를 가져야 함을 확인 할 수 있었습니다.

이번에는 벡터 3개의 선형결합으로 평면의 모든 벡터를 만들어낼 수 있는지 생각해봅시다. 
앞서 우리는 평행하지 않은 두 벡터를 결합해서 이미 평면의 모든 벡터를 만들어 낼 수 있음을 확인 했습니다. 
그렇기에 세 번째 벡터는 없어도 될 것입니다. 그런데 이를 어떻게 수식으로 확인할 수 있을까요?

$$
0 * (2,1) + 0 * (1,3) = (0,0)
$$

앞서 설명한 선형 종속과 선형 독립의 관점에서 이를 분석해봅시다. 두 벡터는 선형 독립의 관계를 지니고 있습니다.

$$
a * (2,1) + b * (1,3) + c * (x,y) = (0,0)
$$

선형 독립인 두 벡터에 스칼라 a와 b를 곱하고 새로운 스칼라 c와 임의의 벡터 ${(x,y)}$를 추가해 위와 같이 세 개의 벡터로 구성된 선형 결합식을 만든다고 해봅시다. 세 벡터가 모두 선형 독립의 관계를 가지려면 위 식을 만족하는 모든 스칼라 ab,c의 값은 0이어야 합니다. 그런데 앞에서 선형독립인 두 벡터 (2,1)과 (1,3)을 결합해 평면의 모든 벡터를 생성할 수 있었으므로, 두 벡터를 결합해 임의의 벡터(x,y)에 -c를 곱한 -c(x,y)를 생성하는 것도 가능합니다.

$$
-c(x,y) + c(x,y) = (0,0)
$$

그렇다면 위와 같이 0이 아닌 스칼라 c를 사용해 영벡터를 만들 수 있으므로 선형 독립의 관계를 더 이상 만족하지 못합니다. 따라서 선형 독립의 관계가 유지되려면 2개의 벡터만 사용되어야 함을 알 수 있습니다.

이러한 벡터의 선형적 관계를 사용해서 벡터 공간에 관련된 몇 가지 새로운 용어를 학습해봅시다. 위의 예제에서 살펴본 두 벡터 ${(2,1), (1,3)}$같이 벡터 공간내 모든 벡터를 생성할 수 있는 선형 독립관 계를 가지는 벡터의 집합을 기저(Basis)라고 합니다. 
두 벡터${(0,1), (1,0)}$도 선형 독립관계를 가지므로 기저입니다. 집합의 개념인 기저에 속한 원소를 기저 벡터(Basis Vector)라고 합니다.벡터${(2,1)}$은 기저 ${B = {(2,1), (1,3)}}$ 에 속한 기저 벡터 입니다.

기저 벡터를 다른 값으로 변경하면 기저 벡터로 부터 세워진 벡터 공간의 모든 원소가 바뀐다고 볼 수 있는데, 이는 선형변환의 기본 원리가 됩니다. 또한 기저의 개념은 차원(Demension) 이라는 새로운 용어를 정의하는데 사용됩니다.

평면으로 구성된 벡터 공간을 생성하기 위한 기저 벡터는 수많은 경우의 수가 존재하지만, 기저 집합의 원소 수는 언제나 2개 뿐입니다. 따라서 명확한 정의에 의해 평면에 대응하는 벡터 공간을 비로소 2차원으로 정의할 수 있게 되었습니다.

$$
e_{1} = (1,0) \\
e_{2} = (0,1)
$$

지금까지 설명한 벡터 공간은 두 개의 실수 집합을 결합해서 생성한 벡터 공간입니다. 좀 더 구체적으로 구성된 집합을 특별히 표준 기저 벡터(Standard Basis Vector)라고 부릅니다. 표준 기저 벡터는 순서대로 ${e_{1}, e_{2}}$로 표기합니다.

$$
e_{1} = (1,0,0) \\
e_{2} = (0,1,0) \\
e_{3} = (0,0,1) 
$$

벡터 공간의 차원에는 제약이 없기 때문에 ${R^{3}, R^{4}, ..., R^{n}}$ 으로 무한 확장이 가능합니다. 3차원 실 벡터 공간의 표준 기저는 늘어난 차원 만큼 위와 같이 구성됩니다. 


## 레퍼런스(Reference)
- 이득우의 게임수학 : ([http://www.yes24.com/Product/Goods/107025224](http://www.yes24.com/Product/Goods/107025224))
