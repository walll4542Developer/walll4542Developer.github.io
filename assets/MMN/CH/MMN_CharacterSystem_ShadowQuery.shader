Shader "MMN/CH/System_ShadowQuery"
{
    SubShader
    {
        LOD 100

        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionWS : POSITION;
                float2 vertex : TEXCOORD;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 shadowCoord : TEXCOORD0;
                float pointSize : PSIZE;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = float4(input.vertex, 0, 1);
            #if UNITY_UV_STARTS_AT_TOP
                output.positionCS.y = -output.positionCS.y;
            #endif

                output.shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
                output.pointSize = 1;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float attenuation = float(SAMPLE_TEXTURE2D_SHADOW(_MainLightShadowmapTexture, sampler_MainLightShadowmapTexture, input.shadowCoord.xyz));
                return float4(attenuation.xxx, 1.0);
            }

            ENDHLSL
        }
    }
}
