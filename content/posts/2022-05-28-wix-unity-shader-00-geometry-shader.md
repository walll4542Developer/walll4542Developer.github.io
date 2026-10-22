---
title: "(Unity Shader) 00 Geometry shader"
date: "2022-05-28T07:48:02.621Z"
categories: ["HLSL", "Unity"]
tags: ["Shader"]
excerpt: "서론이번 포스트에서는 지오메트리(Geometry) 셰이더에 대한 내용을 다뤄보려고 합니다.버텍스(Vertex)와 프래그먼트(fragment = pixel) 셰이더 까지는 이해하고 있다고 가정 하고 작성합니다.지오메트리 셰이더에 입문하는 정석 코스는 삼각형을 이루는 버텍스 사이의 관계를 이해하는 것이 출발"
original_url: "https://walll4542.wixsite.com/watchthis/post/unity-shader-00-geometry-shader"
original_modified: "2022-12-24T17:49:22.647Z"
image: "/assets/images/wix/ca22d8a48f-ce7a39_d04d0010bfc24264a617598026f3abb9~mv2.gif"
---

## 서론

이번 포스트에서는 지오메트리(Geometry) 셰이더에 대한 내용을 다뤄보려고 합니다.

버텍스(Vertex)와 프래그먼트(fragment = pixel) 셰이더 까지는 이해하고 있다고 가정 하고 작성합니다.

지오메트리 셰이더에 입문하는 정석 코스는 삼각형을 이루는 버텍스 사이의 관계를 이해하는 것이 출발점입니다. 학습 흥미를 유지하기 위해서 쉽고 간단한 지오메트리 셰이더 예제를 준비 했습니다. 지오메트리 셰이더를 이용하여 **와이어 프레임**을 그려 볼 것입니다.

## 개요

기본적으로 버텍스 세개가 모여야 삼각형 폴리곤 메시 하나를 그릴 수 있습니다. 즉 폴리곤 **최소 단위가 삼각형**이라는 뜻입니다.

![](/assets/images/wix/b1ed793207-ce7a39_c41633d32ef34087952a8f66c5434dc8~mv2.png)

(렌더링 데이터 흐름)

삼각형 하나를 그리려면 버텍스 셰이더에서 픽셀 셰이더가 삼각형을 그릴 수 있도록 정보를 가공해서 넘겨줘야 합니다. 버텍스 정보를 오브젝트 좌표계(Object Space)에서 월드 좌표계(World Space)로 행렬 변환하고, 모니터에 출력 하려면 카메라로 촬영해야 하니 뷰 좌표계(View Space)으로 변환하고 마지막으로 화면에 담을 수 있는 만큼 잘라내는(Clip Space) 과정을 거칩니다.

이렇게 가공된 버텍스 포지션(Position)을 버텍스 인덱스(Index) 순서대로 3개 씩 가져와서 연결하면 삼각형이 되는데, 이 과정을 편집하는 도구가 바로 지오메트리 셰이더입니다.

### 사전 설정

![](/assets/images/wix/ff3abb307e-ce7a39_cc66757768fe4224a0e4871e9386bdd8~mv2.png)

([https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-sm4](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-sm4>))

지오메트리 셰이더는 Shader Model 4.0 이상 부터 지원하며,

모바일에서는 OpenGL es 3.1\+ AEP(Android Extension Pack) 이상 부터 지원합니다.

![](/assets/images/wix/1c2906137b-ce7a39_d72cdd9654944d48af89f2185aa1c551~mv2.png)

([https://docs.unity3d.com/2021.3/Documentation/Manual/SL\-ShaderCompileTargets.html](<https://docs.unity3d.com/2021.3/Documentation/Manual/SL-ShaderCompileTargets.html>))

```hlsl
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
```





Shader Model 4.0이상에서 동작하니 target 4.0 이상, 그리고 지오메트리를 사용하기 위해서 geometry geom 으로 전처리 해줍시다. 셰이더 언어는 ShaderLab/CG를 사용할 것인데 HLSL으로 작성해도 지오메트리 셰이더 부분의 문법은 똑같습니다.

## 작업 과정

```hlsl
            struct appdata
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2g
            {
                float4  positionCS : POSITION;
                float2  uv : TEXCOORD0;
            };

            struct g2f
            {
                float4  positionCS : POSITION;    
                float2  uv : TEXCOORD0;
            };
```



구조체들은 위와 같이 구성합니다. 기존의 버텍스/프래그먼트 셰이더에서는 버텍스에서 바로 프래그먼트로 정보를 넘겨주는 구조였으니 구조체 이름도 v2f(vertex to fragment)였지만, v2g(vertex to geometry)와 g2f(geometry to fragment)를 추가해줍시다.

```hlsl
            v2g vert(appdata input)
            {
                v2g output;
                output.positionCS = 
                UnityObjectToClipPos(input.positionOS);
                output.uv = TRANSFORM_TEX (input.texcoord, _MainTex);

                return output;
            }
```



개요에서 이야기 했던 대로, Clip Space로 변환을 마친 상태로 v2g에 반환해서 지오메트리 셰이더에 넘겨줍니다. (변환을 하지 않고 지오메트리로 넘겨서 처리하는 응용도 가능 하지만 지금은 다루지 않겠습니다)

```hlsl
[maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f output;
                
                output.positionCS = input[0].positionCS;
                output.uv = input[0].uv;
                triStream.Append(output);

                output.positionCS =  input[1].positionCS;
                output.uv = input[1].uv;
                triStream.Append(output);
                
                output.positionCS = input[2].positionCS;
                output.uv = input[2].uv;
                triStream.Append(output);
            }
```



지오메트리 셰이더의 가장 간단한 형태의 구조입니다. 한 줄 씩 코드를 뜯어보겠습니다.

```hlsl
[maxvertexcount(NumVerts)]
```



지오메트리에서 편집 할 최대 버텍스 숫자를 정의하는 부분입니다. 삼각형을 그려야 하니까 3입니다. 눈치 채셨겠지만 지오메트리 셰이더에서 없는 버텍스를 새로 만드는 등, 버텍스 숫자를 늘리고 줄이는 것이 가능합니다.

```hlsl
void ShaderName ( PrimitiveType DataType Name [ NumElements ], inout StreamOutputObject );
```



![](/assets/images/wix/5b31254d95-ce7a39_8ce101072945456893b7a81c32d9d968~mv2.png)

([https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-geometry\-shader](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-geometry-shader>))

위에서 말씀 드렸듯이 지오메트리 셰이더는 버텍스 숫자를 조절 할 수 있습니다. 여기서는 삼각형만 다룰 것이기 때문에 프리미티브 타입(PrimitiveType)을 triangle으로 선언 합니다.

받아오는 데이터 타입(DataType)은 v2g 구조체이며, input\[3\]은 삼각형을 그리기 위한 버텍스 세 개의 데이터로 이루어진 배열을 의미 합니다.

```hlsl
inout TriangleStream<g2f> triStream
```





![](/assets/images/wix/5b51dbb5dd-ce7a39_ccd09d70f6b342cebb3dad5c5ef817d9~mv2.png)

([https://docs.microsoft.com/en\-us/windows/win32/direct3dhlsl/dx\-graphics\-hlsl\-so\-type](<https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-so-type>))

이 부분이 조금 생소한데, 지오메트리 셰이더에서 처리가 끝난 정점 데이터 배열을 Stream\-Output 이라는 데이터 타입으로 스트리밍(Streaming) 합니다. 지오메트리에서만 사용하는 데이터 타입이며 지금은 자세히 알 필요가 없기 때문에 깊게 다루지 않겠습니다.

```hlsl
                g2f output;
                
                output.positionCS = input[0].positionCS;
                output.uv = input[0].uv;
                triStream.Append(output);

                output.positionCS =  input[1].positionCS;
                output.uv = input[1].uv;
                triStream.Append(output);
                
                output.positionCS = input[2].positionCS;
                output.uv = input[2].uv;
                triStream.Append(output);
```



![](/assets/images/wix/6aca92f377-ce7a39_8944bf5556374ad9a5b5c32a28882b36~mv2.png)

input\[0\~2\]으로 일일히 모든 버텍스 배열에 데이터를 넣어주는 과정입니다.

Append 함수는 triangleStream에 지오메트리 연산이 끝난 데이터를 추가하는 것입니다.

```hlsl
                for(int i = 0; i < 3; i++)
                {
                    output.positionCS = input[i].positionCS;
                    output.uv = input[i].uv;
                    triStream.Append(output);
                }
```



이런 단순한 반복 작업은 당연히 for문으로 수행 할 수 있습니다. 하지만 저희가 만들어야 하는 와이어 프레임은 버텍스마다 다른 값을 넘겨주는 구조기 때문에 이번에는 풀어서 작성 하겠습니다.

![](/assets/images/wix/3e6ed4feb6-ce7a39_f2aac1c0ad724d189feadf24333d2ed2~mv2.png)

```hlsl
            float4 frag (g2f input) : SV_Target
            {
                float4 finalColor = 1;
                return finalColor;
            }
```



그래서 frag에서 g2f를 인풋 해서 출력하면 기존의 버텍스/프래그먼트 셰이더와 똑같은 결과값이 나오는 것이 정상입니다.

이제 와이어 프레임을 그릴 수 있도록 함수를 제작해봅시다.

```hlsl
           float3 VertexDistance(float4 vertex0, float4 vertex1, float4 vertex2) 
            {
                float distance0 = length(vertex0);
                float distance1 = length(vertex1);
                float distance2 = length(vertex2);

                return float3(distance0, distance1, distance2);
            }
```





length 함수로 버텍스 포지션을 원점으로 하는 거리 값을 가져옵니다.

```hlsl
            struct g2f
            {
                float4  positionCS : POSITION;    
                float2  uv : TEXCOORD0;    
                float3  distance : TEXCOORD1;   
            };
```



```hlsl
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f output;

                float3 dist = VertexDistance(input[0].positionCS, input[1].positionCS, input[2].positionCS);
                
                output.positionCS = input[0].positionCS;
                output.uv = input[0].uv;
                output.distance = float3(dist.x, 0, 0);
                triStream.Append(output);

                output.positionCS =  input[1].positionCS;
                output.uv = input[1].uv;
                output.distance = float3(0, dist.y, 0);
                triStream.Append(output);
                
                output.positionCS = input[2].positionCS;
                output.uv = input[2].uv;
                output.distance = float3(0, 0, dist.z);
                triStream.Append(output);
            }
```





g2f 구조체에서 distance 값을 받을 수 있도록 만든 다음 버텍스에 distance 값을 넘겨줍시다.

![](/assets/images/wix/566aec3784-ce7a39_71adfc492b424da08f2c29c22622eedc~mv2.gif)

```hlsl
            float4 frag (g2f input) : SV_Target
            {
                float4 finalColor = 1;

                finalColor.rgb = input.distance.xyz;

                return finalColor;
            }
```



출력해보면 각 버텍스를 원점으로 한 거리 값을 반환합니다. 그러나 카메라가 가까워지면 값이 변합니다.

![](/assets/images/wix/580f355331-ce7a39_6bf8364139e949f3883cdea0238d1b6a~mv2.png)

(Clip Space 변환)

버텍스 위치를 Clip Space로 변환하면서 **버텍스와 카메라 사이의 원근 값 w**로 나누기 때문입니다. 따라서 카메라가 움직이면 length로 만든 거리 값이 변합니다.

해당 문제를 회피하기 위해서 버텍스 원점에서의 거리 값이 아닌 다른 데이터를 이용해보겠습니다.

```hlsl
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f output;

                output.positionCS = input[0].positionCS;
                output.uv = input[0].uv;
                output.distance = float3(1, 0, 0);
                triStream.Append(output);

                output.positionCS =  input[1].positionCS;
                output.uv = input[1].uv;
                output.distance = float3(0, 1, 0);
                triStream.Append(output);
                
                output.positionCS = input[2].positionCS;
                output.uv = input[2].uv;
                output.distance = float3(0, 0, 1);
                triStream.Append(output);
            }
```



세 버텍스가 각각 다른 색상 값을 가지게 설정했습니다.

![](/assets/images/wix/644698299d-ce7a39_1e2b158a46284755aa4a647f392b071b~mv2.gif)

이렇게 하면 버텍스가 어떤 좌표계에 있던 상관 없이, 한 쪽 버텍스의 값이 1일 때 다른 쪽 버텍스는 값이 0이기 때문에 항상 자연스러운 선형 그라데이션이 됩니다. 버텍스 컬러와 같습니다.

![](/assets/images/wix/e7e7437610-ce7a39_5155cf6e9eb2469293f29bcc1783a278~mv2.png)

(barycentric Coordinates)

그렇다면 항상 세 버텍스 사이의 거리 값이 똑같아지는 위치가 존재한다는 것을 직관적으로 알 수 있으며, 이를 원점으로 삼을 수 있는데요, 그것을 바로 삼각형의 무게 중심(barycentric) 좌표라고 합니다.

![](/assets/images/wix/3c8d7bf1e5-ce7a39_25b52722f71946ea9027115a90aa6c3d~mv2.png)

```hlsl
            float Wireframe(float3 dist, float thickness) 
            {
                float wireframe = min(dist.x, min(dist.y, dist.z));
                return wireframe;
            }
```



삼각형의 무게중심 좌표는 버텍스를 기준으로 축이 하나 더 있는 일종의 3차원 UV라고 생각하면 됩니다. 즉 선형 그라데이션이 세개를 min 함수로 합쳐서 그리면 모습이 디스턴스 필드(Distance Field)와 같아집니다.

![](/assets/images/wix/ae27c905d1-ce7a39_2601f0176f9e4213bc2b5522989cce6d~mv2.gif)

```hlsl
            float Wireframe(float3 dist, float thickness) 
            {
                float wireframe = min(dist.x, min(dist.y, dist.z));
		       wireframe = 1 - smoothstep(0, thickness, wireframe);
                return wireframe;
            }
```



SmoothStep 함수로 와이어 프레임을 만들고, 적당히 두께를 조절 할 수 있습니다.

- ![](/assets/images/wix/00a9ad407b-ce7a39_1ca2d62246a346dc87089ae6e1c49e89~mv2.png)
- ![](/assets/images/wix/b051ec53b7-ce7a39_0eeda7e0094844ccb4f41d43e56e1c98~mv2.png)

(무게중심 좌표 / 일반 와이어프레임)

![](/assets/images/wix/1f5a583882-ce7a39_1f31a3d329974d258dbb1a701cfd9ae7~mv2.png)

(확대해서 본 와이어프레임)

하지만 무게중심 좌표로 와이어프레임을 그리면 단점이 있습니다. 폴리곤의 크기에 비례해서 무게중심 좌표도 같이 늘어나기 때문에 폴리곤 삼각형의 면적마다 와이어프레임 굵기가 균일하지 않다는 점입니다.

와이어 프레임의 굵기를 균일하게 유지하여 그리는 방법은 다음 포스트에서 다뤄보도록 하겠습니다.

(파트2에 계속...)
