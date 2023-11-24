Shader "MMN/CH/Eye_Base"
{
    Properties
    {
        [Header(Texture)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _AlphaOverride ("투명도", Range(0.0, 1.0)) = 1.0

        [HideInInspector] _RenderMode ("렌더링 모드", Float) = 0.0

        // NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (1.0, 0.0, 0.0, 0.0)
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
        [HideInInspector] _MotionBlurLerpValue("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength("_VertexBufferLength", Integer) = 0
        
        [HideInInspector] _StencilValue("_StencilValue", Integer) = 0
    }

    SubShader
    {
        Tags
        {
            // NOTE @Wooyoung : 캐릭터 눈 셰이더는 Z를 쓰는 Transparent 이펙트와의 소팅 문제를 해결하기 위해서 AlphaTest 렌더큐를 사용합니다.
            // AlphaTest-10 인 이유는 모든 Opaque 오브젝트 보다는 나중에 렌더링 되어야 하고 AlphaTest 이펙트 보다는 먼저 렌더링 되어야 하기 때문입니다.
            // https://deskcat.io/d/Q02921/MM-미술-QA-캐릭터-눈알-알파-소팅-문제
            "RenderType" = "Opaque"
            "Queue" = "AlphaTest-10"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
            "PreviewType" = "Plane"
        }

        HLSLINCLUDE
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // 기능 분류를 위한 디파인
            #undef _ALPHA_TEST
            #undef _IS_SKIN

            // Input 최적화를 위한 디파인
            #undef _OUTLINE_FEATURE
            #define _DYE_FEATURE
            #undef _SILHOUETTE_FEATURE

            #include "MMN_Character_Eye_Base_Input.hlsl"
        ENDHLSL

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 눈을 위한 스텐실은 그 범위에서 가장 낮은 값을 사용한다.
                Ref 16
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ DEBUG_SHADING_OFF

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #undef _TRANSPARENCY

            #include "Includes/CharacterEyeBasePass.hlsl"
            ENDHLSL
        }

        // NOTE @jihun.song : 이 패스는 ShaderGUI에 의해 자동으로 켜지고 꺼진다.
        // 반투명 캐릭터에서만 사용하는 패스이고 BeforeRenderingTransparents 이벤트게 그려야한다.
        Pass
        {
            Name "Base_TransparentRenderObject"
            Tags { "LightMode" = "TransparentRenderObject" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 눈을 위한 스텐실은 그 범위에서 가장 낮은 값을 사용한다.
                Ref 16
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ DEBUG_SHADING_OFF

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #define _TRANSPARENCY

            #include "Includes/CharacterEyeBasePass.hlsl"
            ENDHLSL
        }

        // NOTE @jihun.song : 이 패스는 눈 영역에 배틀(선택) 아웃라인이 그려지지 않도록 스텐실을 쓰기 위한 용도임.
        Pass
        {
            Name "WriteStencilBeforeOutline"
            Tags { "LightMode" = "WriteStencilBeforeOutline" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 배틀(선택) 아웃라인이 그려지지 않도록 바디와 같은 스텐실로 그린다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Replace // 그려야 하는 면이 겹쳐서 ZFail이 일어날 수 있으므로 이 때도 아웃라인이 그려지지 않도록 Replace 해준다.
            }

            ZWrite Off
            ZTest LEqual
            Cull Back
            ColorMask 0

            HLSLPROGRAM
            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }

        //--------------------------------------
        // FX
        //--------------------------------------
        Pass
        {
            Name "ThiefHide"
            Tags { "LightMode" = "ThiefHide" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 눈을 위한 스텐실은 그 범위에서 가장 낮은 값을 사용한다.
                Ref 16
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #define _THIEF_HIDE

            #include "Includes/CharacterEyeBasePass.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "MM.Client.Editor.ShaderGUI.CharacterTransparentEyeShaderGUI"
}
