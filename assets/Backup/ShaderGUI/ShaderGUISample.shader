Shader "Sample/ShaderGUI"
{
    Properties
    {
        _Texture1 ("Texture 1", 2D) = "white" {}
        _Texture2 ("Texture 2", 2D) = "white" {}

        [Normal] _BumpTexture ("Bump Texture", 2D) = "bump" {}
        _BumpMapScale ("Bump Scale", Float) = 1.0

        _FloatValue1 ("Float Value 1", Float) = 0.0
        _FloatValue2 ("Float Value 2", Float) = 0.0

        _ToggleValue ("Toggle Value", Float) = 0.0

        _VectorValue1 ("Vector Value 1", Vector) = (0.0, 0.0, 0.0, 0.0)
        _VectorValue2 ("Vector Value 2", Vector) = (0.0, 0.0, 0.0, 0.0)

        _ColorValue1 ("Color Value 1", Color) = (0.0, 0.0, 0.0, 0.0)
        [HDR] _ColorValue2 ("Color Value 2", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _ColorMode ("Color Mode", Float) = 0

        [Enum(Assets.TestDummies.Shaders.ShaderGUISample.Editor.BlendMode)] _BlendMode ("Blend Mode", Float) = 0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]

            HLSLPROGRAM

            #pragma multi_compile _ _GREEN _RED
            // #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };


            half4 _ColorValue1;
            half4 _ColorValue2;


            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);

                return output;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 color = _ColorValue1 + _ColorValue2;

                #ifdef _GREEN
                    color = half4(0.0, 1.0, 0.0, 0.5);
                #elif defined(_RED)
                    color = half4(1.0, 0.0, 0.0, 0.5);
                #endif

                return color;
            }

            ENDHLSL
        }
    }

    // 불러올 커스텀 에디터가 네임스페이스를 가지고 있을 경우 네임스페이스를 포함한 풀 네임을 써줘야 한다.
    CustomEditor "Assets.TestDummies.Shaders.ShaderGUISample.Editor.ShaderGUISample"
}
