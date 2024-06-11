Shader "MMN/FX/FX_TargetCursorShadow"
{
    Properties
    {
        _BaseColor ("Ring Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Scale ("Ring Scale", Range(0.0, 1.0)) = 0.5 
        _InnerRadius ("Ring Inner Radius", range(0.0, 0.5)) = 10.0
        _OutterRadius ("Ring Outter Radius", range(1.0, 10.0)) = 3.0
        _Soften ("Ring Soft Edge", Range(0.0, 0.05)) = 0.1

        [HideInInspector] _BaseMap ("Texture", 2D) = "white" {}
        [HideInInspector] _IsEnding ("Ending", Float) = 0.0
        [HideInInspector] _StartTime ("StartTime", Float) = 0.0
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest On
        ZWrite Off
        ColorMask RGBA

        Pass
        {
            Name "Loop"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
           
            #define SCALE_START 0.37
            #define SCALE_END 0.25
            #define ALPHA_START 0.15

            float4 _BaseMap_ST;
            float4 _BaseColor;
            float _Scale;
            float _InnerRadius;
            float _OutterRadius;
            float _Soften;

            float _IsEnding;
            float _StartTime;
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };
            
            float CalcRing(float2 uv)
            {
                float dist = length(uv);
                float radiusDist = dist * _InnerRadius;
                float radiusResult = smoothstep(radiusDist * _OutterRadius, radiusDist - _Soften, abs(dist - _Scale));

                return radiusResult;
            }

            float CalcAlpha()
            {
                float startEndAlphaTime = ALPHA_START;
                float alphaTime = (_Time.y - _StartTime) / startEndAlphaTime;

                float alphaStart = saturate(pow(1.0 - alphaTime, 2.0) * 0.1);
                float alphaEnd = pow(1.0 - alphaTime, 3.0);
                float alphaResult = lerp(alphaStart, alphaEnd, _IsEnding);

                return saturate(alphaResult);
            }

            float CalcScale()
            {
                float startEndScaleTime = lerp(SCALE_START, SCALE_END, _IsEnding);
                float scaleTime = (_Time.y - _StartTime) / startEndScaleTime;

                float scaleStart = saturate(pow(scaleTime, 2.0)) * 1.5;
                float scaleEnd = 2.0 - (1.0 - pow(scaleTime, 2.0)) * 0.5;
                float scaleResult = lerp(scaleStart, scaleEnd, _IsEnding);

                return scaleResult;
            }

            void BillboardVert(inout Attributes input)
            {
                float4x4 objectToWorld = GetObjectToWorldMatrix();
                float4x4 worldToView = GetWorldToViewMatrix();

                input.positionOS.xy *= float2(length(objectToWorld._m00_m10_m20), length(objectToWorld._m01_m11_m21));

                float3 right = normalize(worldToView._m00_m01_m02);
                float3 up = float3(0.0, 1.0, 0.0);
                up = normalize(worldToView._m10_m11_m12);
                float3 forward = -normalize(worldToView._m20_m21_m22);

                float4x4 rotationMatrix;
                rotationMatrix = float4x4(
                    right,         0.0,
                    up,            0.0,
                    forward,       0.0,
                    0.0, 0.0, 0.0, 1.0);

                input.positionOS = mul(input.positionOS, rotationMatrix);
                input.positionOS.xyz = mul((float3x3)GetWorldToObjectMatrix(), input.positionOS.xyz);
            }        

            Varyings UnlitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

				// 빌보드 적용
                BillboardVert(input);
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);

                return output;
            }

            float4 UnlitPassFragment(Varyings input) : SV_Target
            {                
                float2 uv = input.uv - 0.5;
                
                float scale = CalcScale();
                uv *= scale;

                float ring = CalcRing(uv);
                float4 resultColor = _BaseColor * ring;
                
                float resultAlpha = CalcAlpha();
                resultColor.a *= resultAlpha;

                return resultColor;
            }
            ENDHLSL
        }
    }
    Fallback Off
}