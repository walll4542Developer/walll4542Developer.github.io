Shader "MMN/CH/ArbalestMagazine"
{
    Properties
    {
        [HideInInspector] [Enum(Standard, 0, Monster, 1, Deep, 2)] _ShadingType ("셰딩 타입", Float) = 0.0
        [HideInInspector] [Enum(BackCull, 2, TwoSide, 0)] _CullType ("컬링 타입", Float) = 2.0

        [Header(Texture)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _TintColor ("틴트 색상", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Silhouette)]
        [Space(10)]
        [Toggle] _SilhouetteOff ("실루엣 끄기", Float) = 0.0
        _SilhouetteTintColor ("실루엣 틴트", Color)  = (1.0, 1.0, 1.0, 1.0)

        [Header(Outline)]
        [Space(10)]
        [ToggleOff(_OUTLINE_FEATURE)] _OutlineOff ("아웃라인 끄기", Float) = 0.0
        _OutlineColor ("아웃라인 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        [Enum(Multiply, 0, Override, 1)] _OutlineColorMode ("아웃라인 색상 적용 방식", Float) = 0.0
        // _OutlineWidth ("아웃라인 두께", Range(0, 3)) = 1.0

        [Header(Metal)]
        [Space(10)]
        [Toggle(_METAL_FEATURE)] _IsMetal ("메탈 재질?", Float) = 0.0
        [HDR] _MetalTintColor ("메탈 틴트 컬러", Color) = (1.0, 1.0, 1.0, 1.0)
        _Smoothness ("매끈한 정도", Range(0.01, 1.0)) = 1.0
        _SpecularStrength ("스펙큘러 세기", Range(0.0, 1.0)) = 0.5

        [Header(Emission)]
        [Space(10)]
        [NoScaleOffset] _EmissionMap ("이미션 맵", 2D) = "black" {}
        [HDR] _EmissionColor ("이미션 컬러", Color) = (0.0, 0.0, 0.0, 1.0)
        [Toggle] _IsApplyFogToEmission ("안개에 영향을 받나?", Float) = 1.0
        _ApplyFogToEmissionFactor ("안개에 영향을 받을 정도", Range(0.0, 1.0)) = 1.0
        [Toggle] _IsEnableEmissionAtNight ("밤에만 활성화?", Float) = 0.0
        [Toggle] _IsBreathingEmissionMode ("숨쉬기 모드 활성화?", Float) = 0.0
        _BreathingEmissionModePeriod ("숨쉬기 모드가 반복될 간격 (초)", Float) = 2.0

        [Header(Tool)]
        [Space(10)]
        [IntRange] _MagazineNumber ("n번 째 탄창", Range(1, 3)) = 1
        [IntRange] _RemainedMagazine ("남아있는 탄창 숫자", Range(0, 3)) = 3

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
        [HideInInspector] _StencilValue ("_StencilValue", Integer) = 0

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
        [HideInInspector] _CustomGIColor ("_CustomGIColor", Color) = (0.768, 0.827, 0.854, 1.0)

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
        #undef _ALPHA_TEST
        #undef _IS_SKIN

        // Input 최적화를 위한 디파인
        #undef _DYE_FEATURE
        #define _SILHOUETTE_FEATURE
        #define _TINTCOLOR_FEATURE
        #undef _TWO_SIDE_FEATURE
        #define _EMISSION_FEATURE
        #undef _FRESNEL_FEATURE
        #undef _ALPHA_OVERRIDE_FEATURE
        #undef _GRADIENT_ALPHA_FEATURE
        #define _ARBALEST_FEATURE

        // 셰딩 타입의 큰 카테고리
        #define _SHADINGTYPE_STANDARD

        #include "MMN_Character_Standard_Input.hlsl"
    ENDHLSL

    SubShader
    {
        LOD 300

        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
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
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            ZWrite On
            ZTest LEqual
            Cull back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _OUTLINE_FEATURE
            #pragma multi_compile_fragment _ _METAL_FEATURE
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR

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
            #pragma multi_compile_fragment _ DEBUG_OUTLINE_OFF

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            //--------------------------------------
            // Define
            #undef _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull back
            ColorMask 0

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE

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

            Cull back
            ColorMask 0

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
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
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            ZWrite On
            ZTest LEqual
            Cull back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _OUTLINE_FEATURE
            #pragma multi_compile_fragment _ _METAL_FEATURE
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR

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
            #pragma multi_compile_fragment _ DEBUG_OUTLINE_OFF

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            //--------------------------------------
            // Define
            #undef _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull back
            ColorMask 0

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE

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

            Cull back
            ColorMask 0

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_fragment _ _DISSOLVE_FEATURE
            #pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "MM.Client.Editor.ShaderGUI.CharacterCommonShaderGUI"
}
