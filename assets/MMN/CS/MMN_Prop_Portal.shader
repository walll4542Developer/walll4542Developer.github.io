Shader "MMN/CutScene/Prop_Portal"
{
    Properties
    {
        [Header(Stencil Options)]
        [Space]
        _StencilRef("Stencil Ref", Int) = 1
        [MaterialEnum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comp", Int) = 8
        [MaterialEnum(UnityEngine.Rendering.StencilOp)] _StencilPass("Stencil Pass", Int) = 2

        [Header(Rendering Options)]
        [Space]
        [MaterialEnum(Off, 0, On, 1)] _ZWrite ("ZWrite", Int) = 0
        [MaterialEnum(Off, 0, Front, 1, Back, 2)] _Cull("Cull", Int) = 2
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Geometry+1"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "BG" }

            Stencil
            {
                // NOTE @wooyoung : https://deskcat.io/d/N28009/MM-미술-검은-나오존-흰-나오존-로딩없는-전환처리-연구
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

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

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(0, 0, 0, 0);
            }

            ENDHLSL
        }
    }
}
