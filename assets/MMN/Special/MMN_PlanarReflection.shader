Shader "MMN/Special/PlanarReflection"
{
    Properties
    {
        [Header(BaseMap)]
        [Space(10)]
        [MainTexture] _BaseMap ("베이스 맵", 2D) = "white" {}
        [MainColor] _BaseColor ("베이스 맵 컬러", Color) = (0, 0, 0, 0)

        [Header(Reflection Options)]
        [Space(10)]
        [NoScaleOffset] _PlanarReflectionTexture ("리플렉션 텍스쳐(수정 금지)", 2D) = "Black" {}
        _ReflectionColor ("리플렉션 컬러", Color) = (1, 1, 1, 1)
        _Glossiness ("Glossiness", Range(0.01, 1)) = 1.0
        _ReflectionAmbient ("앰비언트 보정", Color) = (0.5, 0.5, 0.5)

        [Header(Quality Options)]
        [Toggle] _LowOptionEnable ("저사양 옵션 (자동 적용됨)", Float) = 0.0
        [NoScaleOffset] _LowOptionCubeTexture ("저사양 옵션용 큐브맵", Cube) = "" {}
        _LowOptionReflectionRatio ("저사양 큐브맵 반사도", Range(0.0, 1.0)) = 0.2
        _LowOptionAdjustColor ("저사양 큐브맵 컬러 보정", Color) = (0.5, 0.5, 0.5)

        [Header(Advanced Options)]
        [Space(10)]
        [Enum(off, 0, front, 1, back, 2)] _Cull ("BackfaceCull", Float) = 2.0

        // BlendMode
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__mode", Float) = 0.0
        [HideInInspector] _Cull ("__cull", Float) = 2.0
        [HideInInspector][ToggleUI] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _BlendOp ("__blendop", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color ("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI ("SampleGI", float) = 0.0 // needed from bakedlit
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "ShaderModel"="4.5"
        }

        Blend [_SrcBlend][_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]
        ZTest LEqual

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_PlanarReflectionInput.hlsl"
            #include "MMN_PlanarReflectionForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords

            #include "MMN_PlanarReflectionInput.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    FallBack Off
}