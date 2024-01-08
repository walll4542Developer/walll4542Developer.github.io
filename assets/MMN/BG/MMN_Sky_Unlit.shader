Shader "MMN/BG/Sky_Unlit"
{
    Properties
    {
        [KeywordEnum(Unlit1, Unlit2)] _UnlitMember ("Unlit Member", Float) = 0
        
        [Header(Distortion)]
        _MaskMap ("디스토션을 위한 마스크맵", 2D) = "black" { }
        _DistortionSpeedMultix ("스피드 멀티플라이x. 로컬값 ", float) = 0
        _DistortionSpeedMultiy ("스피드 멀티플라이y. 로컬값", float) = 0
        _Distortion ("디스토션 적용값", float) = 0.0
        [Space(30)]
        [Header(Texture)]
        _EmissionMap ("Emission Map.", 2D) = "white" { }
        _EmissionSpeedMultix ("스피드 멀티플라이x. 글로벌 볼륨값에 곱해짐", float) = 0
        _EmissionSpeedMultiy ("스피드 멀티플라이y. 글로벌 볼륨값에 곱해짐", float) = 0
        [HDR]_EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)

        [HideInInspector] _Blend ("__blend", Float) = 0.0
        // [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        // [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0

        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend mode", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend mode", Float) = 1
    }

    SubShader
    {
        Tags { "Queue" = "Transparent-400" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Unlit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300
        ZClip False

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "SkyLit" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            
            // Blend SrcAlpha One
            // ZWrite[_ZWrite]
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            
            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _EmissionMap_ST;
                float4 _MaskMap_ST;
                half4 _EmissionColor;
                float _Distortion;
                float _DistortionSpeedMultix;
                float _DistortionSpeedMultiy;
                float _EmissionSpeedMultix;
                float _EmissionSpeedMultiy;
                float _UnlitMember;
            CBUFFER_END

            TEXTURE2D(_EmissionMap);       SAMPLER(sampler_EmissionMap);
            TEXTURE2D(_MaskMap);           SAMPLER(sampler_MaskMap);

            //Global Property
            float4 _GlobalSkyUnlitColor;
            float _GlobalSkyUnlitScrollSpeed;
            float4 _GlobalSkyUnlitColor2;
            float _GlobalSkyUnlitScrollSpeed2;
            // float _Global_WindUV;

            // half _Global_CloudDensity;
            // half _Global_CloudSpeed;
            // half _Global_CloudScale;
            // half _Global_CloudEdgeHardness;
            half _Global_Night2Day;


            #include "../Includes/bendingVertex.hlsl"


            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;
                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                half3 normalWS : TEXCOORD2;
                half4 color : COLOR;
                float4 positionCS : SV_POSITION;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_TRANSFER_INSTANCE_ID(input, output);
                // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수
                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);//카메라 상하 가중치
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = input.texcoord ; //TRANSFORM_TEX(input.texcoord, _EmissionMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                return output;
            }

            // Used for StandardSimpleLighting shader
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                if (_UnlitMember == 1)
                {
                    _GlobalSkyUnlitColor = _GlobalSkyUnlitColor2;
                    _GlobalSkyUnlitScrollSpeed = _GlobalSkyUnlitScrollSpeed2;
                }
                else
                {

                }
                
                float2 uv = input.uv;
                half4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, TRANSFORM_TEX(uv + frac(_Time.x * float2(_DistortionSpeedMultix, _DistortionSpeedMultiy)), _MaskMap));
                half4 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, TRANSFORM_TEX(uv + frac(_Time.x * float2(_EmissionSpeedMultix, _EmissionSpeedMultiy) * _GlobalSkyUnlitScrollSpeed), _EmissionMap) + maskMap.r * _Distortion) * _EmissionColor * _GlobalSkyUnlitColor;
                half4 color;
                color.rgb = emission.rgb ;
                color.a = emission.a ;

                if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
                return 0;
                else
                    return color;
            };
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"

}
