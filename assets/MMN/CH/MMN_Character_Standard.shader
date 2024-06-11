Shader "MMN/CH/Standard"
{
    Properties
    {
        [Enum(Standard, 0, Monster, 1, Deep, 2)] _ShadingType ("셰딩 타입", Float) = 0.0
        [Enum(BackCull, 2, TwoSide, 0)] _CullType ("컬링 타입", Float) = 2.0

        [Header(Texture)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _TintColor ("틴트 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        _AlphaOverride ("투명도", Range(0.0, 1.0)) = 1.0
        _AlphaScaleMin ("투명도 Min", Range(0.0, 1.0)) = 0.0
        _AlphaScaleMax ("투명도 Max", Range(0.0, 1.0)) = 1.0
        [Toggle] _IsGradientAlpha ("그라데이션 알파 모드", Float) = 0.0
        _GradientAlphaHeight ("그라데이션 알파 높이(0이면 자동)", Range(0.0, 10.0)) = 1.4
        _BackFaceDarkenAmount ("(TwoSide일 때) 뒷면의 밝기", Range(0.0, 1.0)) = 0.5
        [Toggle] _IsDyable ("염색 마스크 포함?", Float) = 0.0

        [Header(Dye Color)]
        [Space(10)]
        _DyeColor1 ("염색 슬롯 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor2 ("염색 슬롯 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _DyeColor3 ("염색 슬롯 3", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Shading)]
        [Space(10)]
        _FlatShadingAmountTop ("플랫함 정도 (상단) 0=볼륨, 1=플랫", Range(0.0, 1.0)) = 1.0
        _FlatShadingAmountBottom ("플랫함 정도 (하단) 0=볼륨, 1=플랫", Range(0.0, 1.0)) = 0.0

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

        [Header(Fresnel)]
        [Space(10)]
        _FresnelColor ("프레넬 컬러", Color) = (0.0, 0.0, 0.0, 1.0)
        [PowerSlider(2)] _FresnelRange ("프레넬 범위", Range(0.0, 10.0)) = 2.0
        [PowerSlider(2)] _FresnelPower ("프레넬 파워", Range(0.0, 20.0)) = 10.0

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

        [HideInInspector] _EffectAlphaValue("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength("_VertexBufferLength", Integer) = 0
        //--------------------------------------------------------------------------------
    }

    HLSLINCLUDE
        #pragma exclude_renderers gles gles3 glcore
        #pragma target 4.5

        // 기능 분류를 위한 디파인
        #undef _ALPHA_TEST
        #undef _IS_SKIN

        // Input 최적화를 위한 디파인
        #define _DYE_FEATURE
        #define _SILHOUETTE_FEATURE
        #define _TINTCOLOR_FEATURE
        #define _TWO_SIDE_FEATURE
        #define _EMISSION_FEATURE
        #define _FRESNEL_FEATURE
        #define _ALPHA_OVERRIDE_FEATURE
        #define _GRADIENT_ALPHA_FEATURE

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
            Cull [_CullType]

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

            #undef _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
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
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull [_CullType]

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

            #define _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull [_CullType]
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

            Cull [_CullType]
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

        //--------------------------------------
        // FX
        //--------------------------------------
        Pass
        {
            Name "ThiefHideWriteZ"
            Tags { "LightMode" = "ThiefHideWriteZ" }

            ZWrite On // NOTE: Depth를 쓰기 위해 무조건 On으로 한다.
            ZTest LEqual
            Cull [_CullType]
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
            Cull [_CullType]

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

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #define _THIEF_HIDE

            #include "Includes/CharacterStandardPass.hlsl"
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
            Cull [_CullType]

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

            #undef _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
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
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull [_CullType]

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

            #define _TRANSPARENCY

            #include "Includes/CharacterStandardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            Cull [_CullType]
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

            Cull [_CullType]
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

        //--------------------------------------
        // FX
        //--------------------------------------
        Pass
        {
            Name "ThiefHideWriteZ"
            Tags { "LightMode" = "ThiefHideWriteZ" }

            ZWrite On // NOTE: Depth를 쓰기 위해 무조건 On으로 한다.
            ZTest LEqual
            Cull [_CullType]
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
            Cull [_CullType]

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

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            #define _THIEF_HIDE

            #include "Includes/CharacterStandardPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "MM.Client.Editor.ShaderGUI.CharacterCommonShaderGUI"
}
