// 실제 사용되는 터레인 셰이더는 이것입니다. 터레인 투 메쉬와 자동 연결을 위해서 이름을 이렇게 지었습니다.
Shader "Amazing Assets/Terrain To Mesh/Splatmap"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {


        //신형 TTM에 연결가능하게 하기 위한 프로퍼티
        [Space]
        [NoScaleOffset] _T2M_SplatMap_0 ("Splat Map #10 (RGBA)", 2D) = "black" { }//_V_T2M_Control

        [NoScaleOffset] _T2M_Layer_0_Diffuse ("Paint Map 1 (R)", 2D) = "white" { }//_V_T2M_Splat1
        [NoScaleOffset] _T2M_Layer_1_Diffuse ("Paint Map 1 (R)", 2D) = "white" { }//_V_T2M_Splat2
        [NoScaleOffset] _T2M_Layer_2_Diffuse ("Paint Map 2 (G)", 2D) = "white" { }//_V_T2M_Splat3
        [NoScaleOffset] _T2M_Layer_3_Diffuse ("Paint Map 3 (B)", 2D) = "white" { }//_V_T2M_Splat4
        ///////////////////////////////////////////////////


        [HideInInspector][MainColor] _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _V_T2M_Splat1_uvScale ("Layer 1 UV Scale", Float) = 1.000000
        _V_T2M_Splat2_uvScale ("Layer 2 UV Scale", Float) = 1.000000

        //        _V_T2M_Splat2_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat2_Vector1 ("Float", Range(-0.9, 2.9)) = 1
        _V_T2M_Splat2_Vector2 ("Float", Range(-0.9, 2.9)) = 1
        [Gamma]_V_T2M_Splat2_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)

        _V_T2M_Splat3_uvScale ("Layer 3 UV Scale", Float) = 1.000000
        //        _V_T2M_Splat3_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat3_Vector1 ("Float", Range(-1.9, 1.9)) = 1
        _V_T2M_Splat3_Vector2 ("Float", Range(-1.9, 1.9)) = 1
        [Gamma]_V_T2M_Splat3_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)

        _V_T2M_Splat4_uvScale ("Layer 4 UV Scale", Float) = 1.000000
        //        _V_T2M_Splat4_Vector ("Vector", vector) = (1, 1, 1, 1)
        _V_T2M_Splat4_Vector1 ("Float", Range(-2, 1.9)) = 1
        _V_T2M_Splat4_Vector2 ("Float", Range(-2, 1.9)) = 1
        [Gamma]_V_T2M_Splat4_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)

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
    }

    //LOD300
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

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
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_TerrainMesh_input.hlsl"
            #include "MMN_TerrainMesh_ForwardPass.hlsl"

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

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_TerrainMesh_input.hlsl"
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

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_TerrainMesh_input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }

    //LOD100
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING //이거 지우면 플레이때 어둡게 나옴
            #pragma multi_compile _ _LIGHT_LAYERS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_TerrainMesh_input.hlsl"
            #include "MMN_TerrainMesh_ForwardPass.hlsl"

            ENDHLSL
        }

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

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_TerrainMesh_input.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_TerrainMeshGUI"
}
