Shader "MMN/CH/Legacy/Face: Eye"
{
    Properties
    {
        _EyeballTexture ("Eyeball", 2D) = "white" {}
        _Alpha ("Override Alpha", Float) = 1.0
        _PupilMaskThresholdMin ("Pupil Mask Threshold Min", Range(0.1, 0.8)) = 0.6
        _PupilMaskThresholdMax ("Pupil Mask Threshold Max", Range(0.2, 0.9)) = 0.7
        [MaterialToggle(_MASK_ON)] _EyeballPupilMaskTexture_Enable ("Use Eyeball Pupil Mask?", float) = 0
        _EyeballPupilMaskTexture ("Eyeball Pupil Mask", 2D) = "white" {}
        _EyeballTextureRowNum ("Eyeball Texture Total Row #", int) = 1
        _EyeballTextureColNum ("Eyeball Texture Total Column #", int) = 1
        _EyeballIndexFromOne ("Eyeball Texture # to be used (row major)", int) = 1
        _LeftEyeball_TS ("Left Eyeball Position and Scale", vector) = (0.0, 0.0, 1.0, 1.0)
        _RightEyeball_TS ("Right Eyeball Position and Scale", vector) = (0.0, 0.0, 1.0, 1.0)
        _PupilTexture ("Pupil", 2D) = "white" {}
        _PupilTextureRowNum ("Pupil Texture Total Row #", int) = 1
        _PupilTextureColNum ("Pupil Texture Total Column #", int) = 1
        _PupilIndexFromOne ("Pupil Texture # to be used (row major)", int) = 1
        _LeftPupil_TS ("Left Pupil Position and Scale", vector) = (0.0, 0.0, 1.0, 1.0)
        _RightPupil_TS ("Right Pupil Position and Scale", vector) = (0.0, 0.0, 1.0, 1.0)
        [Toggle] _LeftPupil_Enable ("Show Left Pupil?", float) = 1
        [Toggle] _RightPupil_Enable ("Show Right Pupil?", float) = 1
        [Toggle] _Pupil_Position_Debug ("Display Pupil L/R (Debug)", float) = 0

        [Toggle] _IsDyable ("Is this dyable?", float) = 0
        _DyeColor1 ("Dye Color", Color) = (1.0, 1.0, 1.0, 1.0)

        _EyePositionOffset ("Eye UV Position Offset", vector) = (0.0, 0.0, 0.0, 0.0)
        _EyeRotationOffset ("Eye UV Rotation Offset", float) = 0.0

        _PupilPositionOffset("Pupil UV Position Offset", vector) = (0.0, 0.0, 1.0, 1.0)

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
    }

    Subshader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
            "PreviewType" = "Plane"
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

            #include "MM_Character_Face_Eye_Input.hlsl"
        ENDHLSL

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _MASK_ON
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
            #pragma vertex vert
            #pragma fragment frag

            #include "Includes/CharacterLegacyFaceEyePass.hlsl"
            ENDHLSL
        }
    }

    CustomEditor "MM.Client.Editor.ShaderGUI.FaceEyeShaderGUI"
}
