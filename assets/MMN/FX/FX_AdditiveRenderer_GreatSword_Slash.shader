Shader "MMN/FX/FX_AdditiveRenderer_GreatSword_Slash"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("HDR Color", Color) = (1,1,1,1)
        _Intensity_Color ("Intensity_Color", Float) = 1
        _Intensity_Alpha ("Intensity_Alpha", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
        [HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4 // LEqual

        // NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (0.0, -1.0, 0.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InflateWidth ("_InflateWidth", Float) = 0.0
        [HideInInspector] _InflateColor ("_InflateColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue ("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength ("_VertexBufferLength", Integer) = 0
        //--------------------------------------------------------------------------------
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        HLSLINCLUDE
        #pragma target 4.5
        ENDHLSL

        Pass
        {
            Cull [_CullMode]
            Blend [_BlendSrc] [_BlendDst]
            ZTest LEqual
            Zwrite Off
            HLSLPROGRAM

            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR
            #pragma exclude_renderers glcore gles gles3

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/MMN_Character_Global_Input.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                half4 color : COLOR;
                uint id : SV_VertexID;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;              // xy : uv0, zw : uv1
                half4 fogCoord : TEXCOORD1;         // x : fogcoord
                half3 positionWS : TEXCOORD11;
                float4 positionOS : TEXCOORD12;
                float3 normalWS : TEXCOORD13;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float _Intensity_Color;
                float _Intensity_Alpha;
                float4 _Color;
                MM_DECLARE_PROPERTIES_FROM_SCRIPT
            CBUFFER_END

            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterMotionBlurPass.hlsl"

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

#ifdef _VERTEX_OBJECT_MOTION_BLUR
                // 오브젝트 모션블러(버텍스)를 적용한다
                float4 positionOS = float4(CaculateMotionBlurVertexPositionOS(input.positionOS.xyz, input.normalOS, input.id), input.positionOS.w);
                positionOS.xyz += input.normalOS.xyz * 0.001;
#else
                float4 positionOS = float4(input.positionOS.xyz + input.normalOS.xyz * 0.001, input.positionOS.w);
#endif

                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);

                input.normalOS = input.normalOS;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInput.normalWS;

                output.uv.xy = input.texcoord0.xy;
                output.uv.zw = input.texcoord1.xy;

                output.positionWS = TransformObjectToWorld(positionOS);
                output.positionOS = positionOS;
                output.positionCS = vertexInput.positionCS;
                output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float2 uv = TRANSFORM_TEX(input.uv.zw, _MainTex); // 대검 이펙트는 uv 1번 사용
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                col.rgb *= (_Color.rgb * _Intensity_Color);
                col.a *= saturate(_Color.a * _Intensity_Alpha);
                return col;
            }
            ENDHLSL
        }
    }
}
