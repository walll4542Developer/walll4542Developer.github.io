Shader "MMN/FX/FX_Drone"
{
    Properties
    {
        _MyIndex ("MyIndex", Float) = 0

        [Header(Main Texture)][Space()] _MainTex("MainTex", 2D) = "white" {}
        [Header(Noise Texture)][Space()] _NoiseTex("NoiseTex", 2D) = "white" {}
        
        _TransformPositionStart ("TransformPositionStart", Vector) = (0, 0, 0, 0)
        _TransformPositionFinish ("TransformPositionFinish", Vector) = (0, 0, 0, 0)
        _TransformPositionStartTime ("TransformPositionStartTime", Float) = 0
        _TransformPositionDuration ("TransformPositionDuration", Float) = 0
        [Header(TransformPositionCurve Texture)][Space()] _TransformPositionCurveTex("TransformPositionCurveTex", 2D) = "white" {}

        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)

        _TransformColorOn ("TransformColorOn", Float) = 0
        [HDR] _TransformColorStart ("TransformColorStart", Color) = (1, 1, 1, 1)
        [HDR] _TransformColorFinish ("TransformColorFinish", Color) = (1, 1, 1, 1)
        _TransformColorStartTime ("TransformColorStartTime", Float) = 0
        _TransformColorDuration ("TransformColorDuration", Float) = 0
        [Header(TransformColorCurve Texture)][Space()] _TransformColorCurveTex("TransformColorCurveTex", 2D) = "white" {}

        _AlphaOn ("AlphaOn", Float) = 0
        _Alpha ("Alpha", Float) = 0

        _TransformAlphaOn ("TransformAlphaOn", Float) = 0
        _TransformAlpha ("TransformAlpha", Vector) = (0, 0, 0, 0)
        [Header(TransformAlphaCurve Texture)][Space()] _TransformAlphaCurveTex("TransformAlphaCurveTex", 2D) = "white" {}
        
        _BlinkOn ("BlinkOn", Float) = 0
        _BlinkStartTime ("BlinkStartTime", Float) = 0
        _BlinkSpeed ("BlinkSpeed", Float) = 0

        _BlinkNoiseOn ("BlinkNoiseOn", Float) = 0
        _BlinkNoiseUV ("BlinkNoiseUV", Vector) = (0, 0, 0, 0)
        _BlinkNoiseSpeed ("BlinkNoiseSpeed", Float) = 0

        _BlinkNoiseFadeOutStartTime ("BlinkNoiseFadeOutStartTime", Float) = 0
        _BlinkNoiseFadeOutOn ("BlinkNoiseFadeOutOn", Float) = 0
        _BlinkNoiseFadeOutDuration ("BlinkNoiseFadeOutDuration", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest LEqual
            ZWrite Off
            ColorMask RGBA

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float t : TEXCOORD1;
                float4 color : COLOR;
                float4 l : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);

            TEXTURE2D(_TransformAlphaCurveTex);
            SAMPLER(sampler_TransformAlphaCurveTex);

            TEXTURE2D(_TransformPositionCurveTex);
            SAMPLER(sampler_TransformPositionCurveTex);

            TEXTURE2D(_TransformColorCurveTex);
            SAMPLER(sampler_TransformColorCurveTex);

            CBUFFER_START(UnityPerMaterial)
                UNITY_DEFINE_INSTANCED_PROP(float, _MyIndex)

                UNITY_DEFINE_INSTANCED_PROP(float4, _TransformPositionStart)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TransformPositionFinish)
                UNITY_DEFINE_INSTANCED_PROP(float, _TransformPositionStartTime)
                UNITY_DEFINE_INSTANCED_PROP(float, _TransformPositionDuration)

                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)

                UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorOn)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TransformColorStart)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TransformColorFinish)
                UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorStartTime)
                UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorDuration)

                UNITY_DEFINE_INSTANCED_PROP(float, _AlphaOn)
                UNITY_DEFINE_INSTANCED_PROP(float, _Alpha)

                UNITY_DEFINE_INSTANCED_PROP(float, _TransformAlphaOn)
                UNITY_DEFINE_INSTANCED_PROP(float4, _TransformAlpha)

                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkOn)
                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkStartTime)
                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkSpeed)

                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseOn)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BlinkNoiseUV)
                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutStartTime)
                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseSpeed)

                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutOn)
                UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutDuration)
            CBUFFER_END

            // Instancing으로 최적화 할 때 사용하기.
            // UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _MyIndex)

            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TransformPositionStart)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TransformPositionFinish)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformPositionStartTime)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformPositionDuration)

            //     UNITY_DEFINE_INSTANCED_PROP(float4, _Color)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TransformColorStart)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TransformColorFinish)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorStartTime)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformColorDuration)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _AlphaOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _Alpha)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _TransformAlphaOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _TransformAlpha)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkStartTime)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkSpeed)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _BlinkNoiseUV)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutStartTime)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseSpeed)

            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutOn)
            //     UNITY_DEFINE_INSTANCED_PROP(float, _BlinkNoiseFadeOutDuration)
            // UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

            #define IS_TRUE(value) (value > 0.5)
            #define IS_FALSE(value) (value <= 0.5)

            void BillboardVert(inout float3 vertex)
            {
                float4x4 objectToWorld = UNITY_MATRIX_M;
                float4x4 worldToView = UNITY_MATRIX_V;

                // 오브젝트 스케일 적용
                vertex.xy *= float2(length(objectToWorld._m00_m10_m20), length(objectToWorld._m01_m11_m21));

                // 카메라 방향 가져오고
                float3 right = normalize(worldToView._m00_m01_m02);
                float3 up = float3(0.0, 1.0, 0.0);
                up = normalize(worldToView._m10_m11_m12);
                float3 forward = -normalize(worldToView._m20_m21_m22);

                // 카메라를 바라볼 수 있도록 회전행렬을 만들고
                float4x4 rotationMatrix = float4x4(
                    right,         0.0,
                    up,            0.0,
                    forward,       0.0,
                    0.0, 0.0, 0.0, 1.0);

                vertex = mul(vertex, rotationMatrix);

                vertex.xyz = mul((float3x3)UNITY_MATRIX_I_M, vertex.xyz);
            }

            float2 Hash(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }

            // Noise 텍스쳐로 바꾸기.
            float Noise( in float2 p )
            {
                const float K1 = 0.366025404; // (sqrt(3)-1)/2;
                const float K2 = 0.211324865; // (3-sqrt(3))/6;
                float2 i = floor(p + (p.x + p.y) * K1);   
                float2 a = p - i + (i.x + i.y) * K2;
                float2 o = (a.x > a.y) ? float2(1.0, 0.0) : float2(0.0,1.0); //float2 of = 0.5 + 0.5*float2(sign(a.x-a.y), sign(a.y-a.x));
                float2 b = a - o + K2;
                float2 c = a - 1.0 + 2.0*K2;
                float3 h = max(0.5-float3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
                float3 n = h*h*h*h*float3( dot(a,Hash(i+0.0)), dot(b,Hash(i+o)), dot(c,Hash(i+1.0)));
                return dot(n, float3(70.0, 70, 70));  
            }

            void EaseInQuad(inout float t)
            {
                t *= t;
            }

            void EaseOutQuad(inout float t)
            {
                t = 1 - (1 - t) * (1 - t);
            }

            void EaseProcess(in float easeType, inout float t)
            {
                if (1.5 < easeType)
                {
                    EaseOutQuad(t);
                }
                else if (0.5 < easeType)
                {
                    EaseInQuad(t);
                }
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.color = input.color;

                BillboardVert(input.vertex.xyz);

                float4 transformPositionStartInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformPositionStart);
                float4 transformPositionFinishInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformPositionFinish);
                float transformPositionStartAt = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformPositionStartTime);
                float transformPositionDuration = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformPositionDuration);

                float transformPositionProgress = saturate((_Time.y - transformPositionStartAt) / transformPositionDuration);
                float4 transformPositionCurveTextureColor = SAMPLE_TEXTURE2D_LOD(_TransformPositionCurveTex, sampler_TransformPositionCurveTex, float2(transformPositionProgress, 0.5), 0);
                transformPositionProgress *= transformPositionCurveTextureColor.r;

                float3 transformPositionOS = lerp(transformPositionStartInstanced.xyz, transformPositionFinishInstanced.xyz, transformPositionProgress);
                transformPositionOS *= 30.0;

                // 버텍스를 랜덤 방향으로 살짝 움직이기
                float myIndex = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MyIndex);
                float randomSeed = myIndex + 1;
                float3 randomDirection = float3(
                    Noise(frac(randomSeed * 8.5453) * _Time.x * 8),
                    Noise(frac(randomSeed * 2.453) * _Time.x * 8) * 0.4,
                    Noise(frac(randomSeed * 4.8846) * _Time.x * 8) * 1.5
                );

                float3 jitterPositionOS = randomDirection * 0.7 * max(0, abs(sin(frac(randomSeed * 7.1134) * _Time.x)) - 0.2);
                

                float3 positionOS = input.vertex.xyz + transformPositionOS + jitterPositionOS;

                output.pos = TransformObjectToHClip(positionOS);
                output.uv = input.uv;
                
                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 colorInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);

                float transformColorOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformColorOn);
                float4 transformColorStartInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformColorStart);
                float4 transformColorFinishInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformColorFinish);
                float transformColorStartAt = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformColorStartTime);
                float transformColorDuration = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformColorDuration);

                float alphaOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AlphaOn);
                float alphaInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Alpha);

                float transformAlphaOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformAlphaOn);
                float4 transformAlphaInstanced = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _TransformAlpha);

                float blinkOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkOn);
                float blinkStartTime = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkStartTime);
                float blinkSpeed = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkSpeed);

                float blinkNoiseOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseOn);
                float4 blinkNoiseUV = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseUV);
                float blinkNoiseFadeOutStartTime = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseFadeOutStartTime);
                float blinkNoiseSpeed = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseSpeed);

                float blinkNoiseFadeOutOn = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseFadeOutOn);
                float blinkNoiseFadeOutDuration = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _BlinkNoiseFadeOutDuration);

                float2 mainTextureUV = input.uv.xy;
                float4 mainTextureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainTextureUV);

                float2 noiseTextureUV = float2(blinkNoiseUV.x, blinkNoiseUV.y);
                float4 noiseTextureColor = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseTextureUV);

                float alpha = mainTextureColor.a * input.color.a;

                float transformAlphaStartTime = transformAlphaInstanced.x;
                float transformAlphaDuration = transformAlphaInstanced.y;
                float transformAlphaStart = transformAlphaInstanced.z;
                float transformAlphaFinish = transformAlphaInstanced.w;
                float transformAlphaProgress = saturate((_Time.y - transformAlphaStartTime) / max(0.001, transformAlphaDuration));
                float4 transformAlphaCurveTextureColor = SAMPLE_TEXTURE2D(_TransformAlphaCurveTex, sampler_TransformAlphaCurveTex, float2(transformAlphaProgress, 0.5));
                transformAlphaProgress *= transformAlphaCurveTextureColor.r;

                float transformAlpha = saturate(lerp(transformAlphaStart, transformAlphaFinish, transformAlphaProgress));

                float blinkAlpha = (sin((_Time.y - blinkStartTime) * blinkSpeed) + 1) * 0.5;

                float blinkNoiseTime = lerp(_Time.y, blinkNoiseFadeOutStartTime, blinkNoiseFadeOutOn);
                float blinkNoiseAlpha = (sin((blinkNoiseTime + noiseTextureColor.r * 10) * blinkNoiseSpeed)  + 1) * 0.5;

                float blinkNoiseFadeOutProgress = saturate((_Time.y - blinkNoiseFadeOutStartTime) / max(0.001, blinkNoiseFadeOutDuration));
                float blinkNoiseFadeOutAlpha = saturate(lerp(blinkNoiseAlpha, 0, blinkNoiseFadeOutProgress));

                if (IS_TRUE(transformAlphaOn))
                {
                    alpha *= transformAlpha;
                }
                else if (IS_TRUE(blinkOn))
                {
                    alpha *= blinkAlpha;
                }
                else if (IS_TRUE(blinkNoiseOn))
                {
                    alpha *= blinkNoiseAlpha;
                }
                else if (IS_TRUE(blinkNoiseFadeOutOn))
                {
                    alpha *= blinkNoiseFadeOutAlpha;
                }
                else if (IS_TRUE(alphaOn))
                {
                    alpha *= alphaInstanced;
                }

                float transitionColorProgress = saturate((_Time.y - transformColorStartAt) / max(0.001, transformColorDuration));
                float4 transformColorCurveTextureColor = SAMPLE_TEXTURE2D(_TransformColorCurveTex, sampler_TransformColorCurveTex, float2(transitionColorProgress, 0.5));
                transitionColorProgress *= transformColorCurveTextureColor.r;

                float3 color = colorInstanced.rgb;
                float3 transitionColor = lerp(transformColorStartInstanced, transformColorFinishInstanced, transitionColorProgress);
                if (IS_TRUE(transformColorOn))
                {
                    color = transitionColor;
                }

                return float4(color, alpha);
            }            
            ENDHLSL
        }
    }
}
