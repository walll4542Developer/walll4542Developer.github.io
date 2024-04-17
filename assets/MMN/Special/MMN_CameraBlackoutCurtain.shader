Shader "MMN/Special/CameraBlackoutCurtain"
{
    Properties
    {
        [MainTexture] _BaseMap ("Base Map (RGB)", 2D) = "white" {}
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        LOD 100

        Tags {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Background"
        }

        HLSLINCLUDE
        #pragma target 4.5
        ENDHLSL

        Pass
        {
            Name "Unlit"

            Cull back
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Less
            ZWrite On
            ColorMask RGBA

            HLSLPROGRAM
            #pragma exclude_renderers glcore gles gles3

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _BaseMap;

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float4 color        : COLOR;
                float4 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float4 color         : COLOR;
                float4 uv           : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.color = input.color;
                output.uv = input.uv;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 color = tex2D(_BaseMap, input.uv);
                float alpha = saturate(_BaseColor.a * color.a);
                return float4(color.rgb, alpha);
            }
            ENDHLSL
        }
    }
    FallBack off
}
