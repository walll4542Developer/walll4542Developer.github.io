Shader "MMN/CH/NoiseAlphaTest"
{
    Properties
    {
        [Enum(Standard, 0, Monster, 1)] _ShadingType ("셰딩 타입", Float) = 0.0

        [Header(Texture)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        [Toggle] _IsDyable ("염색 마스크 포함?", Float) = 0.0

        [Header(Dye Color)]
        [Space(10)]
        _DyeColor1 ("염색 슬롯 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor2 ("염색 슬롯 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor3 ("염색 슬롯 3", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Silhouette)]
        [Space(10)]
        [Toggle] _SilhouetteOff ("실루엣 끄기", Float) = 0.0
        _SilhouetteTintColor ("실루엣 틴트", Color)  = (1.0, 1.0, 1.0, 1.0)

        [Header(Outline)]
        [Space(10)]
        [ToggleOff(_OUTLINE_FEATURE)] _OutlineOff ("아웃라인 끄기", Float) = 0.0
        _OutlineColor ("아웃라인 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        [Enum(Multiply, 0, Override, 1)] _OutlineColorMode ("아웃라인 색상 적용 방식", Float) = 0.0
        _OutlineWidth ("아웃라인 두께", Range(0, 3)) = 1.0

        [Header(AlphaTest Options)]
        [Space(10)]
        _NoiseTex ("노이즈 맵", 2D) = "black" {}
        _SecondTex ("세컨드 맵", 2D) = "black" {}
        _Cutoff ("노이즈 알파 컷오프", Range(0, 2)) = 0.0
        _SecondTexPower ("세컨드 맵 강도", Range(0, 1)) = 1.0

        [KeywordEnum(none, U, V)] _uvGradient ("알파 그라데이션 방향", Float) = 2.0
        _GradientRange ("그라데이션 범위", Range(-1, 1)) = 0
        _AlphaTestRange ("알파 테스트 범위", Range(0.0, 1)) = 0.1
        _BendRange ("벤딩 정도", Range(0, 0.1)) = 0.02
        [HDR]_ColorA ("색상 A", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR]_ColorB ("색상 B", Color) = (0.0, 0.0, 0.0, 1.0)

        // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들.
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

    Subshader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        HLSLINCLUDE
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // 기능 분류를 위한 디파인
            #undef _TRANSPARENCY
            #define _ALPHA_TEST
            #undef _IS_SKIN

            // Input 최적화를 위한 디파인
            #define _DYE_FEATURE
            #define _SILHOUETTE_FEATURE

            #include "MMN_CharacterFX_NoiseAlphaTest_Input.hlsl"
        ENDHLSL

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            ZWrite On
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _OUTLINE_FEATURE
            #pragma multi_compile _UVGRADIENT_NONE _UVGRADIENT_U _UVGRADIENT_V
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
            #pragma multi_compile_fragment _ DEBUG_OUTLINE_OFF

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #include "Includes/CharacterFXNoiseAlphaTestStandardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            //--------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/CharacterShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

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
            Name "ThiefHideWriteZ"
            Tags { "LightMode" = "ThiefHideWriteZ" }

            ZWrite On // NOTE: Depth를 쓰기 위해 무조건 On으로 한다.
            ColorMask 0

            HLSLPROGRAM
            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ThiefHide"
            Tags { "LightMode" = "ThiefHide" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
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
            #pragma multi_compile _UVGRADIENT_NONE _UVGRADIENT_U _UVGRADIENT_V

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

            #include "Includes/CharacterFXNoiseAlphaTestStandardPass.hlsl"
            ENDHLSL
        }
    }
}
