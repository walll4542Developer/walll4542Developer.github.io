// 인벤토리에서 캐릭터 뒤쪽에 스텐실을 활용하여 그림자같이 어둡게 처리하기 위한 셰이더
Shader "Hidden/MMN/CH/FX_OuterGlow"
{
    Properties
    {
        [Header(Outer Glow)]
        [Space(10)]
        _GlowColor ("Glow Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _GlowPower ("Glow Power", Range(0.0, 10.0)) = 5.0
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }
            
            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp NotEqual
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Front

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _GlowColor;
                float _GlowPower;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
                output.normalWS = normalWS;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {                           
                float3 normalWS = -normalize(input.normalWS);
                float3 cameraDirWS = -GetViewForwardDir();
                
                cameraDirWS.y = 0;
                cameraDirWS = normalize(cameraDirWS);

                float fresnel = saturate(dot(normalWS, cameraDirWS));
                fresnel = pow(fresnel, _GlowPower);
                fresnel = saturate(fresnel);

                float4 resultColor = _GlowColor * fresnel;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
