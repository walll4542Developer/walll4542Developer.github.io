Shader "MMN/BG/WindowGlassAlphablend"
{
    Properties
    {
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
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON //글로벌이라서 로컬로 하면 곤란
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
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
