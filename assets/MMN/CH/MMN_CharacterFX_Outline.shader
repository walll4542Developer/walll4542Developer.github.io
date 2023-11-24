// 오브젝트를 선택했을 때 스텐실을 활용하여 외곽에만 아웃라인을 그려주는 셰이더.
Shader "Hidden/MMN/CH/FX_Outline"
{
    Properties
    {
        
        [HideInInspector] _StencilValue("_StencilValue", Integer) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "SelectionOutline" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp NotEqual
                Pass [_StencilOp]
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Front

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            #include "../Includes/BendingVertex.hlsl"

            //--------------------------------------
            // from Script
            int _StencilValue;
            int _StencilOp;

            float4 _SelectionOutlineColor;
            float _SelectionOutlineWidth;
            //--------------------------------------

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionOS = input.positionOS.xyz;
                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);
                output.positionCS = vertexInput.positionCS;

                float2 normalCS = mul((float3x3)GetViewToHClipMatrix(), mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS).xyz).xy;
                float2 offset = _SelectionOutlineWidth * output.positionCS.w * max(_ScreenParams.x, _ScreenParams.y) * 0.0036 * normalize(normalCS) / _ScreenParams.xy;
                output.positionCS.xy += offset;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                return _SelectionOutlineColor;
            }

            ENDHLSL
        }
    }
}
