Shader "MMN/BG/Unlit"
{
    Properties
    {
        [MainTexture] _BaseMap ("Texture", 2D) = "white" { }
        [MainColor] _BaseColor ("Color", Color) = (0, 0, 0, 0)
        [Toggle] _FogOff ("포그 켜기", float) = 0
        [HideInInspector]_Cutoff ("AlphaCutout", Range(0.0, 1.0)) = 0.5
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0

        // BlendMode
        [HideInInspector]_Surface ("__surface", Float) = 0.0
        [HideInInspector]_Blend ("__mode", Float) = 0.0
        [HideInInspector]_Cull ("__cull", Float) = 2.0
        [HideInInspector][ToggleUI] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _BlendOp ("__blendop", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI ("SampleGI", float) = 0.0 // needed from bakedlit

    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" "ShaderModel" = "4.5" }
        LOD 100

        Blend [_SrcBlend][_DstBlend]
        ZWrite [_ZWrite]
        Cull [_Cull]

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment

            #include "MMN_UnlitInput.hlsl"
            #include "MMN_UnlitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_UnlitInput.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    Fallback off
}
