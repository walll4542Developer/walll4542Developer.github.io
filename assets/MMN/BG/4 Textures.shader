// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "VacuumShaders/Terrain To Mesh/Universal Render Pipeline/Lit/4 Textures"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] [NoScaleOffset] _V_T2M_Control ("Control Map #1", 2D) = "black" { }
        // [Header(____________________________________________________________________)]
        // [Space(5)]
        _V_T2M_Splat1_uvScale ("Layer 1 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat1 ("Layer 1 (RGB) ", 2D) = "white" { }
        // [NoScaleOffset]  _V_T2M_Splat1_bumpMap ("Layer 1 Normal Map", 2D) = "bump" { }
        // [NoScaleOffset]  _V_T2M_Splat1_mask ("SpecMasking", 2D) = "black" { }
        //_V_T2M_Splat1_Vector ("Vector", vector) = (1,1,1,1)
        // [Header(____________________________________________________________________)]
        // [Space(5)]
        _V_T2M_Splat2_uvScale ("Layer 2 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat2 ("Layer 2 (RGB) BlendMasking (A)", 2D) = "white" { }
        // [NoScaleOffset]  _V_T2M_Splat2_bumpMap ("Layer 2 Normal Map", 2D) = "bump" { }
        // [NoScaleOffset]  _V_T2M_Splat2_mask ("SpecMasking", 2D) = "black" { }
        _V_T2M_Splat2_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat2_Vector1 ("Float", Range(-0.9, 2.9)) = 1
        _V_T2M_Splat2_Vector2 ("Float", Range(-0.9, 2.9)) = 1
        // _V_T2M_Splat2_Vector3 ("Float", float) = 0.8
        [Gamma]_V_T2M_Splat2_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat2_Vector4 ("Float", float) = 1
        // [Header(____________________________________________________________________)]
        // [Space(5)]
        _V_T2M_Splat3_uvScale ("Layer 3 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat3 ("Layer 3 (RGB) BlendMasking (A)", 2D) = "white" { }
        // [NoScaleOffset]  _V_T2M_Splat3_bumpMap ("Layer 3 Normal Map", 2D) = "bump" { }
        // [NoScaleOffset]  _V_T2M_Splat3_mask ("SpecMasking", 2D) = "black" { }
        _V_T2M_Splat3_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat3_Vector1 ("Float", Range(-1.9, 1.9)) = 1
        _V_T2M_Splat3_Vector2 ("Float", Range(-1.9, 1.9)) = 1
        // _V_T2M_Splat3_Vector3 ("Float", float) = 0.8
        [Gamma]_V_T2M_Splat3_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat3_Vector4 ("Float", float) = 1
        // [Header(____________________________________________________________________)]
        // [Space(5)]
        _V_T2M_Splat4_uvScale ("Layer 4 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat4 ("Layer 4 (RGB) BlendMasking (A)", 2D) = "white" { }
        // [NoScaleOffset]  _V_T2M_Splat4_bumpMap ("Layer 4 Normal Map", 2D) = "bump" { }
        // [NoScaleOffset]  _V_T2M_Splat4_mask ("SpecMasking", 2D) = "white" { }
        _V_T2M_Splat4_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat4_Vector1 ("Float", Range(-2, 1.9)) = 1
        _V_T2M_Splat4_Vector2 ("Float", Range(-2, 1.9)) = 1
        // _V_T2M_Splat4_Vector3 ("Float", float) = 0.8
        [Gamma]_V_T2M_Splat4_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat4_Vector4 ("Float", float) = 1

        //눈 내릴때 마스킹을 어떤 타일에서 마스킹할거냐는 처리
        //길 같은 곳에만 눈이 내리지 않도록 만들 수 있습니다.
        // _SnowMask ("Vector", vector) = (0,0,0,0)

        [Toggle]_SnowMask_R ("SnowMask_R", float) = 0
        [Toggle]_SnowMask_G ("SnowMask_G", float) = 0
        [Toggle]_SnowMask_B ("SnowMask_B", float) = 0
        [Toggle]_SnowMask_A ("SnowMask_A", float) = 0


        [HideInInspector] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [HideInInspector] _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider]_Glossiness ("Smoothness", Range(0.01, 1)) = 0.5
        [HideInInspector]_SpecGlossMap ("Specular Map", 2D) = "white" { }
        [HideInInspector] [Enum(Specular Alpha, 0, Albedo Alpha, 1)] _SmoothnessSource ("Smoothness Source", Float) = 0.0
        [HideInInspector] [ToggleOff] _SpecularHighlights ("Specular Highlights", Float) = 1.0

        [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        [HideInInspector] [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        //[HideInInspector] _EmissionColor ("Emission Color", Color) = (0,0,0)
        // [HideInInspector][NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" {}

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Cull ("__cull", Float) = 2.0

        [HideInInspector] [ToogleOff] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [HideInInspector] _Smoothness ("SMoothness", Float) = 0.5

        // ObsoleteProperties
        // [HideInInspector] _MainTex ("BaseMap", 2D) = "white" {}
        // [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        // [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        // [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        // [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING //이거 지우면 플레이때 어둡게 나옴
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "MMN_TerrainMesh_Lit_Bump_input.hlsl"
            #include "MMN_TerrainMesh_Lit_Bump_ForwardPass.hlsl"

            ENDHLSL
        }

        //2022.1.7 . 배경팀에서 쓰지 않는다고 빼기로 협의완료
        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster" }

        //     ZWrite On
        //     ZTest LEqual
        //     ColorMask 0
        //     Cull[_Cull]

        //     HLSLPROGRAM

        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     // -------------------------------------
        //     // Material Keywords
        //     //#pragma shader_feature_local_fragment _ALPHATEST_ON
        //     #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #pragma multi_compile _ DOTS_INSTANCING_ON

        //     // -------------------------------------
        //     // Universal Pipeline keywords

        //     // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
        //     #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

        //     #pragma vertex ShadowPassVertex
        //     #pragma fragment ShadowPassFragment

        //     #include "MMN_TerrainMesh_Lit_Bump_input.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
        //     ENDHLSL

        // }


        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #define VERTEX_CAMERA_DEPEND_BENDING 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0

            #include "MMN_TerrainMesh_Lit_Bump_input.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple
            #pragma shader_feature EDITOR_VISUALIZATION

            // #pragma shader_feature_local_fragment _EMISSION
            // #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "MMN_TerrainMesh_Lit_Bump_input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_TerrainMesh_Lit_BumpGUI"
}
