---
title: "비트 단위 연산자(Bitwise Operator)"
excerpt: 비트 단위 연산자(Bitwise Operator)는 컴퓨터에서 비트(bit) 단위로 데이터를 처리할 때 사용되는 연산자입니다. 비트는 컴퓨터에서 정보의 최소 단위이며, 2진수이기 때문에 0 또는 1의 값을 가집니다. 이러한 비트를 조작하는 연산을 비트 연산이라고 합니다.
date: 2023-04-07 00:00:00 -0000
categories: Research
tag: Script CSharp Unity

header:
  teaser: /assets/images/Docs/Thumbnails/Programming-01.png
  overlay_image: /assets/images/Docs/Thumbnails/code.png
  overlay_filter: 0.8

# table of contents
toc: true # 오른쪽 부분에 목차를 자동 생성해준다.
toc_label: "목차" # toc 이름 설정
toc_icon: "bars" # 아이콘 설정
toc_sticky: true # 마우스 스크롤과 함께 내려갈 것인지 설정

---

![6](/assets/images/Docs/Bitwise%20Operator/image%20(6).png)

비트 단위 연산자(Bitwise Operator)는 컴퓨터에서 비트(bit) 단위로 데이터를 처리할 때 사용되는 연산자입니다. 

비트는 컴퓨터에서 정보의 최소 단위이며, ${2}$진수이기 때문에 ${0}$ 또는 ${1}$의 값을 가집니다.

이러한 비트를 조작하는 연산을 비트 연산이라고 합니다. 대표적으로 다음과 같은 비트 연산자가 있습니다.

## 비트 단위 연산자의 종류

### AND (&)
두 개의 비트가 모두 ${1}$일 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환합니다.

```csharp
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BitwiseOperator : MonoBehaviour
{
    int n = new();
    void Start()
    {
        n = 5 & 3;
        Debug.Log(n);
        // 5(101), 3(011)을 AND 연산하여 1(001)을 반환합니다.
        // 따라서 n는 1이 됩니다.
    }
}
```

![7](/assets/images/Docs/Bitwise%20Operator/image%20(7).png)

### OR (${\mid}$)
두 개의 비트 중 하나 이상이 ${1}$일 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환합니다.

```csharp
n = 5 | 3;
// 5(101), 3(011)을 OR 연산하여 7(111)을 반환합니다.
// 따라서 n는 7이 됩니다.

```

![1](/assets/images/Docs/Bitwise%20Operator/image%20(1).png)

### XOR (^)
두 개의 비트가 서로 다른 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환합니다.

```csharp
n = 5 ^ 3;
// 5(101), 3(011)을 XOR 연산하여 6(110)을 반환합니다.
// 따라서 n는 6이 됩니다.

```

![9](/assets/images/Docs/Bitwise%20Operator/image%20(9).png)

### NOT (~)
비트를 반전시키는 연산자입니다. ${1}$은 ${0}$으로, ${0}$은 ${1}$로 바꿉니다. 

이 연산자는 부호 비트도 반전시켜 양수를 음수로, 음수를 양수로 만듭니다. 

음수부를 가지고 있지 않은 자료형에서는 당연히 음수가 되지 않습니다.

```csharp
n = ~5;
// 5(101)의 비트를 반전시켜 -6(111...1010)을 반환합니다.
// 따라서 n는 -6이 됩니다.
```

![3](/assets/images/Docs/Bitwise%20Operator/image%20(3).png)

### Shift (<<, >>)
비트를 왼쪽이나 오른쪽으로 이동시키는 연산자입니다. 

이 연산자는 주로 ${2}$의 거듭제곱 수를 곱하거나 나눌 때 사용됩니다. 

이동한 오른쪽 비트는 ${0}$으로 채워지며, 왼쪽 끝 비트는 잘리게 됩니다.

```csharp
n = 5 << 2;
// 5(101)의 비트를 왼쪽으로 2칸 이동시켜 20(10100)을 반환합니다.
// 따라서 n는 20이 됩니다.
```

![5](/assets/images/Docs/Bitwise%20Operator/image%20(5).png)

이동한 왼쪽 비트는 ${0}$으로 채워지며, 오른쪽 끝 비트는 잘리게 됩니다.

```csharp
n = 5 >> 1;
// 5(101)의 비트를 오른쪽으로 1칸 이동시켜 2(10)를 반환합니다.
// 따라서 n는 2가 됩니다.
```

![8](/assets/images/Docs/Bitwise%20Operator/image%20(8).png)

이러한 비트 연산자를 응용하면 같은 기능을 수행하더라도 메모리를 훨씬 더 절약할 수 있습니다. 

**메모리의 최소 크기 단위는 1바이트**이므로 변수의 크기는 적어도 ${1}$바이트 이상입니다. ${1}$바이트는 ${8}$비트이므로 ${8}$가지 상태를 저장할 수 있습니다.

`bool` 자료형도 ${1}$바이트를 사용하지만 그 중에서 ${1}$비트만 사용하고 ${7}$비트를 낭비하게 되는데 비트 연산을 사용하면 메모리를 낭비하지 않고 훨씬 효율적으로 정보를 처리할 수 있습니다.

## 비트 플래그(Bit Flag)

![2](/assets/images/Docs/Bitwise%20Operator/image%20(2).png)

비트 플래그라는 용어의 어원은 깃발입니다. 깃발을 위로 올리면 켜지고 아래로 내리면 꺼짐을 의미합니다. 

깃발의 개념을 정수의 비트로 치환하여 비트가 ${1}$이면 켜진 상태, ${0}$이면 꺼진 상태를 나타내는 것입니다. 여기서 바이트의 개별 비트를 **비트 플래그(bit flag)**라고 합니다.

플래그의 순서를 읽을 때는 오른쪽에서 왼쪽으로 셉니다. 아래의 ${1}$바이트는 첫 번째, 네 번째 그리고 여덟 번째 비트가 켜진 상태입니다.

```csharp
1000 1001
```

메모리의 최소 크기인 ${1}$바이트는 8비트이며 이는 `0000 0000 ~ 1111 1111`의 범위를 갖고 있어서 ${2^8 = 256}$ 개의 조합을 표현 할 수 있습니다.

이 조합에 대응하는 수 체계로 ${16}$진수를 사용합니다. 이는 `0000 (0x0) ~ 1111 (0xF)` 의 범위를 갖고 있어서 ${2^4 = 16}$ 개의 조합을 표현 할 수 있습니다.

${16 * 16 = 2^8}$ 이기 때문에 ${16}$진수 숫자 두 개로 ${1}$바이트를 완벽히 표현할 수 있습니다.

${1}$바이트는 ${17}$진수로 `0x00 ~ 0xFF`의 범위를 갖습니다.

```csharp
0x01 // 0000 0001
0x02 // 0000 0010
0x04 // 0000 0100
0x08 // 0000 1000
0x10 // 0001 0000
0x20 // 0010 0000
0x40 // 0100 0000
0x80 // 1000 0000
```

${1}$바이트는 ${8}$개의 플래그를 가지고 있으니 ${2^8}$개의 조합을 표현 할 수 있으며 그것보다 더 많은 조합이 필요할 경우 비트 숫자를 늘려서 ${16}$비트, ${32}$비트 등등을 사용하면 됩니다.

## 비트 마스크(Bit Mask)
이렇게 만든 비트 플래그를 위에서 배운 비트 단위 연산자를 응용하여 플래그를 제어하는 것이 가능하며 이러한 방식을 **비트 마스크**라고 합니다.

예를 들어 `UnityEngine.Rendering`의 이넘(enum) 중에는 `ColorWriteMask` 라는 이넘이 있습니다.

```csharp
namespace UnityEngine.Rendering
{
    //
    // 요약:
    //     Specifies which color components will get written into the target framebuffer.
    [Flags]
    public enum ColorWriteMask
    {
        //
        // 요약:
        //     Write alpha component.
        Alpha = 0x01,
        //
        // 요약:
        //     Write blue component.
        Blue = 0x02,
        //
        // 요약:
        //     Write green component.
        Green = 0x04,
        //
        // 요약:
        //     Write red component.
        Red = 0x08,
        //
        // 요약:
        //     Write all components (R, G, B and Alpha).
        All = 0x0F
    }
}
```

([https://docs.unity3d.com/ScriptReference/Rendering.ColorWriteMask.html](https://docs.unity3d.com/ScriptReference/Rendering.ColorWriteMask.html))
{: .text-center}

![4](/assets/images/Docs/Bitwise%20Operator/image%20(4).png)

([https://docs.unity3d.com/kr/2021.3/Manual/SL-ColorMask.html](https://docs.unity3d.com/kr/2021.3/Manual/SL-ColorMask.html))
{: .text-center}

`ColorWriteMask` 이넘은 유니티의 'ShaderLab'에서 `ColorMask` 를 정의 해줄 때 사용하는 이넘 값으로서, 셰이더의 특정 컬러 채널의 렌더링을 활성화 또는 비활성화 하여 채널 별로 아웃풋(Output)을 제어하는 커맨드입니다.

- A = `0x01`
- R = `0x02`
- G = `0x04`
- B = `0x08`

채널 별로 제어가 가능해야 하기 때문에 'RGBA' 네 가지 채널의 조합이 모두 가능해야 합니다. 

그래서 `ColorWriteMask` 이넘은 비트 플래그 방식으로 만들어져 있습니다.

```csharp
R = 0x02      // 0000 0010
RG = 0x06     // 0000 0110
RGB = 0x07    // 0000 1110
ARGB = 0x0F   // 0000 1111
```

위와 같이 비트 플래그를 조합해서 여러가지 상태를 표현할 수 있습니다.

### 비트 켜기

`OR(|)`을 사용해 비트를 켤 수 있습니다.

```csharp
private static int BitMask()
{
    var result = 0x00; // 0000 0000
    var option = 0x10; // 0001 0000
    result |= option;
    return result; // 0001 0000 10
}
```

`OR(|)` 연산은 두 개의 비트 중 하나 이상이 ${1}$일 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환하기 때문에 다섯 번째 비트 플래그가 켜집니다.

### 비트 끄기

`AND(&)`와 `NOT(~)`를 이용해서 비트를 끌 수 있습니다.

```csharp
private static int BitMask()
{
    var result = 0x1C; // 0001 1100
    var option = 0x10; // 0001 0000
    result &= ~option;
    return result; // 0000 1100 12
}
```

`NOT(~)`은 비트를 반전하고 `AND(&)`는 두 개의 비트가 모두 ${1}$일 경우 ${1}$을 반환하며, 그 외의 경우에는 ${0}$을 반환합니다.

`~option` 은 `0xEF (1110 1111)` 니까 결과(result)인 `0x1C (0001 1100)` 와 `AND(&)` 하면 `0x0C (0000 1100)` 가 됩니다. 따라서 네 번째 비트를 끈 것과 같습니다.

```csharp
private static int BitMask()
{
    var result = 0x1C; // 0001 1100
    var option0 = 0x10; // 0001 0000
    var option1 = 0x08; // 0000 1000
    result &= ~(option0 | option1);
    return result; // 0000 0100 4
}
```

`OR(|)`을 사용해서 옵션을 하나로 묶은 다음 여러 비트를 동시에 끌 수도 있습니다.

### 비트 토글하기

`XOR(^)`을 이용해서 비트를 토글(toggle)할 수 있습니다.

```csharp
private static int BitMask()
{
    var result = 0x1C; // 0001 1100
    var option = 0x10; // 0001 0000
    result ^= option;
    return result; // 0000 1100 12
}
```

`XOR(^)`은 두 개의 비트가 서로 다른 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환합니다. 따라서 다섯 번째 비트를 반전하는 것과 같습니다.

```csharp
private static int BitMask()
{
    var result = 0x1C; // 0001 1100
    var option0 = 0x10; // 0001 0000
    var option1 = 0x08; // 0000 1000
    result ^= (option0 | option1);
    return result; // 0000 0100 4
}
```

`XOR(^)`도 `OR(|)`을 사용해서 옵션을 하나로 묶은 다음 여러 비트를 동시에 반전 할 수도 있습니다.

### 비트 확인하기

`AND(&)`를 이용해서 플래그의 상태를 알 수 있습니다.

```csharp
private static int BitMask()
{
    var result = 0x1C; // 0001 1100
    var option = 0x10; // 0001 0000
    result &= option;
    return result; // 0001 0000 10
}
```

`AND(&)`는 두 개의 비트가 모두 ${1}$일 경우 ${1}$을 반환하고, 그 외의 경우에는 ${0}$을 반환합니다. 따라서 다섯 번째 비트가 켜져있음을 알 수 있습니다.

## 레퍼런스(Reference)
- ColorWriteMask Enum : ([https://docs.unity3d.com/ScriptReference/Rendering.ColorWriteMask.html](https://docs.unity3d.com/ScriptReference/Rendering.ColorWriteMask.html))
- ColorMask : ([https://docs.unity3d.com/kr/2021.3/Manual/SL-ColorMask.html](https://docs.unity3d.com/kr/2021.3/Manual/SL-ColorMask.html))