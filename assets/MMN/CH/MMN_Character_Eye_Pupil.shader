Shader "MMN/CH/Eye_Pupil"
{
    Properties
    {
        [Header(Base Map)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _BaseMapAtlasSize ("아틀라스 행(X) 열(Y) 인덱스(Z) 회전(W)", Vector) = (1.0, 1.0, 1.0, 0.0)
        _BaseMapScalePosition ("크기(XY), 위치(ZW)", Vector) = (1.0, 1.0, 0.0, 0.0)
        _AlphaOverride ("투명도", Range(0.0, 1.0)) = 1.0
        [Toggle] _IsDyable ("염색 마스크 포함?", Float) = 0.0

        [Header(Dye Color)]
        [Space(10)]
        _DyeColor1 ("염색 슬롯 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor2 ("염색 슬롯 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor3 ("염색 슬롯 3", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Dissolve)]
        [Space(10)]
        [Toggle(_DISSOLVE_FEATURE)] _IsDissolve ("디졸브 켜기", Float) = 0.0
        _DissolveAmount ("진행도", Range(0.0, 2.0)) = 0.0
        _DissolveRange ("범위(xyz: 범위, w: 두께)", Vector) = (1.0, 1.0, 1.0, 6.0)
        [Toggle] _NotUseDirection ("방향 없이 디졸브 할까요?", Float) = 0.0
        _DissolveDirection ("진행 방향 벡터", Vector) = (0.0, -1.0, 0.0, 0.0)
        _DissolvePanningSpeed ("패닝 속도", Range(-1.0, 1.0)) = 0.0
        _DissolveMap ("디졸브 텍스쳐", 2D) = "white" { }
        [Toggle] _DissolveCutoff ("디졸브 컷오프를 켤까요?", Float) = 1.0
        [HDR] _DissolveColor ("디졸브 색상", Color) = (0.0, 0.0, 0.0, 0.0)
        _DissolveWidth ("디졸브 두께", Range(0.0, 1.0)) = 0.3
        [HDR] _DissolveEdgeColor ("디졸브 경계의 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        _DissolveEdgeWidth ("디졸브 경계의 두께", Range(0.0, 1.0)) = 0.05

        [HideInInspector] _RenderMode ("렌더링 모드", Float) = 0.0

        // NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (0.0, -1.0, 0.0, 0.0)
        [HideInInspector] _CharacterHeadDirection ("xyz: direction, w: height", Vector) = (0.0, 0.0, 1.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue ("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength ("_VertexBufferLength", Integer) = 0
        //--------------------------------------------------------------------------------
    }

    HLSLINCLUDE
        #pragma exclude_renderers gles gles3 glcore
        #pragma target 4.5

        // 기능 분류를 위한 디파인
        #undef _TRANSPARENCY
        #undef _ALPHA_TEST
        #undef _IS_SKIN

        // Input 최적화를 위한 디파인
        #undef _OUTLINE_FEATURE
        #define _DYE_FEATURE
        #undef _SILHOUETTE_FEATURE

        #include "MMN_Character_Eye_Pupil_Input.hlsl"
    ENDHLSL

    SubShader
    {
        LOD 300

        Tags
        {
            // NOTE @Wooyoung : 캐릭터 눈 셰이더는 Z를 쓰는 Transparent 이펙트와의 소팅 문제를 해결하기 위해서 AlphaTest 렌더큐를 사용합니다.
            // AlphaTest-9 인 이유는 모든 Opaque 오브젝트 보다는 나중에 렌더링 되어야 하고 AlphaTest 이펙트 보다는 먼저 렌더링 되어야 하기 때문입니다.
            // https://deskcat.io/d/Q02921/MM-미술-QA-캐릭터-눈알-알파-소팅-문제
            "RenderType" = "Opaque"
            "Queue" = "AlphaTest-9"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
            "PreviewType" = "Plane"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 눈을 위한 스텐실은 그 범위에서 가장 낮은 값을 사용한다.
                Ref 16
                Comp Equal
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS
            #define _LIGHT_LAYERS
            #define _LIGHT_COOKIES

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

            #include "Includes/CharacterEyePupilPass.hlsl"
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
                Comp Equal
                Pass Keep
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
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS
            #define _LIGHT_LAYERS
            #define _LIGHT_COOKIES

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

            #include "Includes/CharacterEyePupilPass.hlsl"
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
                Comp Equal
                Pass Keep
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
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS
            #define _LIGHT_LAYERS
            #define _LIGHT_COOKIES

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

            #include "Includes/CharacterEyePupilPass.hlsl"
            ENDHLSL
        }
    }

    SubShader
    {
        LOD 100

        Tags
        {
            // NOTE @Wooyoung : 캐릭터 눈 셰이더는 Z를 쓰는 Transparent 이펙트와의 소팅 문제를 해결하기 위해서 AlphaTest 렌더큐를 사용합니다.
            // AlphaTest-9 인 이유는 모든 Opaque 오브젝트 보다는 나중에 렌더링 되어야 하고 AlphaTest 이펙트 보다는 먼저 렌더링 되어야 하기 때문입니다.
            // https://deskcat.io/d/Q02921/MM-미술-QA-캐릭터-눈알-알파-소팅-문제
            "RenderType" = "Opaque"
            "Queue" = "AlphaTest-9"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
            "PreviewType" = "Plane"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // 눈을 위한 스텐실은 그 범위에서 가장 낮은 값을 사용한다.
                Ref 16
                Comp Equal
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS_VERTEX
            #define _LIGHT_LAYERS

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

            #include "Includes/CharacterEyePupilPass.hlsl"
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
                Comp Equal
                Pass Keep
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
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS_VERTEX
            #define _LIGHT_LAYERS

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

            #include "Includes/CharacterEyePupilPass.hlsl"
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
                Comp Equal
                Pass Keep
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
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #define _ADDITIONAL_LIGHTS_VERTEX
            #define _LIGHT_LAYERS

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

            #include "Includes/CharacterEyePupilPass.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "MM.Client.Editor.ShaderGUI.CharacterTransparentEyeShaderGUI"
}
