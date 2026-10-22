---
title: "(Programming) C# 숫자 데이터 형식 사용하기"
date: "2023-03-17T16:08:32.035Z"
categories: ["Study"]
tags: ["CSharp"]
excerpt: "숫자 데이터 형식 사용하기숫자 데이터 형식은 크게 정수 데이터 형식과 소수점이 있는 실수 데이터 형식으로 나누며, 다시 부호 있는 숫자(양수와 음수 모두 포함)와 부호 없는 숫자(양수 밖에 없음)로 나눕니다.정수 데이터 형식정수형 키워드에는 s와 u 접두사가 붙는데 이는 signed 와 unsigned의"
original_url: "https://walll4542.wixsite.com/watchthis/post/programming-c-숫자-데이터-형식-사용하기"
original_modified: "2023-03-17T16:10:26.778Z"
image: "/assets/images/wix/0a81071d40-ce7a39_d729a3f69bec49abbaaaa63e1e0498f1~mv2.png"
---

## 숫자 데이터 형식 사용하기

숫자 데이터 형식은 크게 정수 데이터 형식과 소수점이 있는 실수 데이터 형식으로 나누며, 다시 부호 있는 숫자(양수와 음수 모두 포함)와 부호 없는 숫자(양수 밖에 없음)로 나눕니다.

## 정수 데이터 형식

정수형 키워드에는 **s**와 **u** 접두사가 붙는데 이는 **signed** 와 **unsigned**의 약자로 부호를 붙이느냐 붙이지 않느냐 하는 차이가 있습니다. 정수형에는 8가지 키워드가 있습니다.

- 8비트 : sbyte / byte
- 16비트 : short / ushort
- 32비트 : int / uint
- 64비트 : long / ulong

![](/assets/images/wix/0a81071d40-ce7a39_d729a3f69bec49abbaaaa63e1e0498f1~mv2.png)

```csharp
static void Main(string[] args)
        {
            int min = -2147483648;
            int max = +2147483647;
            Console.WriteLine(min);
            Console.WriteLine(max);
        }
```





변수를 공부할 때 이미 int 키워드로 정수형 변수를 선언하는 방법을 사용했습니다. 정수형 변수가 가질 수 있는 최솟값과 최댓값을 저장한 후 출력해보겠습니다.

![](/assets/images/wix/a0adc753ef-ce7a39_8571ab6f12384cf19822dda55c55c8f9~mv2.png)

예를 들어 int 키워드를 사용한 정수형은 최소 \-21억\~\+21억 까지 데이터를 저장합니다.

![](/assets/images/wix/5b2c5e9c2b-ce7a39_a53b124913eb48e39841159328fc8d89~mv2.png)

```csharp
static void Main(string[] args)
        {
            sbyte int8 = 127;
            short int16 = 32767;
            int int32 = 2147483647;
            long int64 = 9223372036854775807;

            Console.WriteLine("sbyte : {0}", int8);
            Console.WriteLine("short : {0}", int16);
            Console.WriteLine("int : {0}", int32);
            Console.WriteLine("long : {0}", int64);
        }
```





![](/assets/images/wix/2819a56e7c-ce7a39_d528b5b94342417d9d0cbb56e7895848~mv2.png)

부호가 있는 정수 데이터 형식의 네 가지 키워드를 사용해서 작성했습니다.

정수 데이터 형식의 범위를 넘는 숫자를 넣으면 어떻게 될까요?

![](/assets/images/wix/ab3371efcf-ce7a39_00e4079ccc5148129ff6da1176a2cf5d~mv2.png)

코드가 실행되지 않고 바로 에러가 발생합니다. sbyte 형식 변수는 \-127 \~ \+127 까지 정수를 저장할 수 있어 그보다 큰 \+128은 저장할 수 없습니다.

```csharp
static void Main(string[] args)
        {
            byte uint8 = 255;
            ushort uint16 = 65535;
            uint uint32 = 4294967295;
            ulong uint64 = 18446744073709551615;

            Console.WriteLine("byte : {0}", uint8);
            Console.WriteLine("ushort : {0}", uint16);
            Console.WriteLine("uint : {0}", uint32);
            Console.WriteLine("ulong : {0}", uint64);
        }
```



![](/assets/images/wix/17c12ab193-ce7a39_eeaf9b90d3f842c3bdba65d0bd257774~mv2.png)

부호가 없는 정수 데이터는 음수의 값을 사용할 수 없는 대신 양수의 값을 2배 크기로 사용할 수 있습니다.

![](/assets/images/wix/5614789eeb-ce7a39_b724cd25f2dc4f9eac9c774910f683a1~mv2.png)

```csharp
            Console.WriteLine("int의 최댓값 : {0}", int.MaxValue);
            Console.WriteLine("int의 최솟값 : {0}", int.MinValue);
```



![](/assets/images/wix/380b2ad603-ce7a39_77d7db7699d94772b8e2bc16788ffeb2~mv2.png)

또한 정수형 데이터의 최솟값과 최댓값은 위와 같이 **MinValue와 MaxValue** 속성으로 출력할 수 있습니다.

## 실수 데이터 형식

소수점 이하의 숫자를 다루는 실수 데이터 형식(부동소수점 데이터 형식)을 살펴보겠습니다. 부동 소수점 데이터 형식으로 표현되는 실수를 컴퓨터에서 표현하는 방법은 복잡합니다.

- 32비트 : float
- 64비트 : double
- 128비트 : decimal

32비트를 사용하는 실수 체계는 float이며 이를 '단일 정밀도' 라고 부릅니다. 두 배인 64비트를 사용하면 이를 double. 128비트가 되면 decimal 이라고 합니다.

한정된 비트 크기로 실수 체계를 전체를 표현하려다 보니 정수 데이터 형식처럼 범위내의 해당하는 숫자와 일대일 대응하는 방식이 아닙니다. 그렇기 때문에 '오차'가 있습니다. 따라서 실수를 표현하는 비트가 커지면 커질수록 정밀도가 늘어나는 것입니다.

정밀한 계산이 요구되는 과학, 수학 영역에서는 double을 사용하는 것이 일반적이지만 저희가 주로 다루는 게임 그래픽에서는 float(32비트)를 주로 사용하며 특히 셰이더는 **half(16비트)**나 **fixed(11비트)** 까지 더욱 줄여서 사용합니다.

32비트 초과의 정밀도를 사용해 실시간으로 게임을 동작하기에는 메모리에 올라가는 데이터들이 너무 방대해지고 필요한 연산도 많아지기 때문입니다.

![](/assets/images/wix/507f042231-ce7a39_90955671099b402bad5f7d253f19fbab~mv2.png)

![](/assets/images/wix/596545eb43-ce7a39_6592f85f88804fb4af70e4cee2550804~mv2.png)

float의 최댓값과 최솟값을 출력하라고 명령해보면 **E\+**로 시작하는 숫자가 아닌 부분이 있습니다.

아주 크거나 작은 숫자를 표현할 때 사용하는 지수 표기법(Exponential notation)입니다. E 뒤의 숫자는 10의 거듭제곱 만큼 곱하라는 뜻입니다.

예를 들어 위의 float 최댓값인 3.4028235**E\+38**은 **3.4028235 곱하기 10의 38승** 입니다.

![](/assets/images/wix/9dd8d5291f-ce7a39_f44e281d07be4f7f8edd333897252d21~mv2.png)

float을 구성하는 32비트는 각각 음수 양수 부호를 표현하는 1비트, 지수부(부호가 있는 정수) 8비트, 가수부(부호가 없는 정수) 23비트로 이루어져 있습니다.

![](/assets/images/wix/f8255b70c9-ce7a39_968559bd54a84d82bcfdd2f8e62be7bc~mv2.png)

실수 데이터 형식에서는 부호에 1비트를 쓰기 때문에 \+0과 \-0이 공존합니다. 또한 무한대와 NaN(숫자가 아닌 데이터)을 표시할 수 있습니다.

![](/assets/images/wix/7c969bdcca-ce7a39_49b60124379f40078e741d5920b09e4b~mv2.png)

float에서 표현할 수 있는 가장 큰 수를 비트로 표현하면 이렇습니다.

float의 정밀도에서 0에서 가장 가까운 작은 수는 1.17549435E\-38 입니다. float에서 **이것보다 작은 실수는 표현 할 수 없습니다.** 이렇게 제한되어 있는 비트로 실수를 표현하기 때문에 오차가 발생하고 듬성듬성 구멍이 생깁니다.

**Decimal** 키워드는 float이나 double과는 다른 방식으로, 10진수로 표현하는 실수 데이터입니다. float이나 double보다는 범위가 작지만 정밀도가 가장 높습니다. 소수점 28자리까지는 신뢰할 수 있어서 정확한 계산이 필요한 프로그램에서 많이 사용합니다.

## 리터럴 접미사 붙이기

실수형 데이터를 표현하는 리터럴을 만들 때 접미사를 사용해야 합니다. float에는 F 또는 f를 붙이고, double에는 D또는 d, decimal은 M또는 m입니다.

```csharp
        static void Main(string[] args)
        {
            float num = 3.14;
            Console.WriteLine(num);
        }
```



![](/assets/images/wix/57298deff2-ce7a39_2e410c23fc8d4fb9a47becffbbe64703~mv2.png)

(오류 메시지)

접미사를 붙이지 않으면  리터럴으로 쓸 수 없습니다.

```csharp
static void Main(string[] args)
        {

            float floatNumber = 3.14f;
            double doubleNumber = 3.14d;
            decimal decimalNumber = 3.14m;

            Console.WriteLine("{0},{1},{2}", floatNumber, doubleNumber, decimalNumber);
        }
```



![](/assets/images/wix/f567d5a3f4-ce7a39_2b7fdc33ea974fc7a9309a8695258614~mv2.png)

## Null

숫자 형식의 변수를 선언할 때 int? double? 의 형태로 물음표 '?' 기호를 붙이면 null 가능 형식으로 변경됩니다. 이러한 null 가능 형식에는 아무런 값도 없음을 의미하는 'null'을 대입할 수 있습니다.

```csharp
static void Main(string[] args)
        {
            int? x = null;

            Console.WriteLine("{0}", x);
        }
```



![](/assets/images/wix/2e11a43cc0-ce7a39_76711db174c64863a4be649974301aae~mv2.png)

(아무것도 표시하지 않는 콘솔)

분명 변수 x를 출력하라고 명령했지만 값이 null이라서 아무것도 나오지 않습니다.
