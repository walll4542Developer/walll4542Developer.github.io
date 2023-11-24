Shader "MMN/BG/WindowGlassAlphablend"
{
    Properties
    {
        // [Toggle]_NEARHALFTONECLIP ("니어 클립", float) = 0
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [HideInInspector][PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [HideInInspector] [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { } //SRP배쳐를 위해
        _Gloss ("Glossiness", Range(0.01, 5)) = 1
        [HDR]_EmissionColorBright ("반사 색과 강도", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Simplelit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON //글로벌이라서 로컬로 하면 곤란
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_WindowGrassInput.hlsl"
            #include "MMN_WindowGrassAlphablendForwardPass.hlsl"
            ENDHLSL
        }

    }
    Fallback off
}
