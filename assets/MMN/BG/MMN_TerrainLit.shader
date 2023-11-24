//편집용 유니티 터레인 셰이더. 편집할때만 사용하고 실무에서는 사용 안해서 최적화가 필요 없습니다.

Shader "MMN/BG/TerrainLit"
{
    Properties
    {
        [HideInInspector] [ToggleUI] _EnableHeightBlend ("EnableHeightBlend", Float) = 0.0
        _HeightTransition ("Height Transition", Range(0, 1.0)) = 0.0
        // Layer count is passed down to guide height-blend enable/disable, due
        // to the fact that heigh-based blend will be broken with multipass.
        [HideInInspector] [PerRendererData] _NumLayersCount ("Total Layer Count", Float) = 1.0

        _V_T2M_Splat1_uvScale ("Layer 1 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat1_mask ("SpecMasking", 2D) = "white" { }

        
        _V_T2M_Splat2_uvScale ("Layer 2 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat2_mask ("SpecMasking", 2D) = "white" { }
        _V_T2M_Splat2_Vector1 ("Float", Range(-0.9, 2.9)) = 1
        _V_T2M_Splat2_Vector2 ("Float", Range(-0.9, 2.9)) = 1
        _V_T2M_Splat2_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat2_Vector4 ("Float", float) = 1

        _V_T2M_Splat3_uvScale ("Layer 3 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat3_mask ("SpecMasking", 2D) = "white" { }
        _V_T2M_Splat3_Vector1 ("Float", Range(-1.9, 1.9)) = 1
        _V_T2M_Splat3_Vector2 ("Float", Range(-1.9, 1.9)) = 1
        _V_T2M_Splat3_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat3_Vector4 ("Float", float) = 1

        _V_T2M_Splat4_uvScale ("Layer 4 UV Scale", Float) = 1.000000
        [NoScaleOffset]  _V_T2M_Splat4_mask ("SpecMasking", 2D) = "white" { }
        _V_T2M_Splat4_Vector1 ("Float", Range(-2, 1.9)) = 1
        _V_T2M_Splat4_Vector2 ("Float", Range(-2, 1.9)) = 1
        _V_T2M_Splat4_EdgeColor ("경계면 칼라 멀티플라이", Color) = (0.45, 0.45, 0.45, 1)
        // _V_T2M_Splat4_Vector4 ("Float", float) = 1

        _SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider]_Glossiness ("Smoothness", Range(1, 1024)) = 128


        // set by terrain engine
        [HideInInspector] _Control ("Control (RGBA)", 2D) = "red" { }
        [HideInInspector] _Splat3 ("Layer 3 (A)", 2D) = "grey" { }
        [HideInInspector] _Splat2 ("Layer 2 (B)", 2D) = "grey" { }
        [HideInInspector] _Splat1 ("Layer 1 (G)", 2D) = "grey" { }
        [HideInInspector] _Splat0 ("Layer 0 (R)", 2D) = "grey" { }
        [HideInInspector] _Normal3 ("Normal 3 (A)", 2D) = "bump" { }
        [HideInInspector] _Normal2 ("Normal 2 (B)", 2D) = "bump" { }
        [HideInInspector] _Normal1 ("Normal 1 (G)", 2D) = "bump" { }
        [HideInInspector] _Normal0 ("Normal 0 (R)", 2D) = "bump" { }
        [HideInInspector] _Mask3 ("Mask 3 (A)", 2D) = "grey" { }
        [HideInInspector] _Mask2 ("Mask 2 (B)", 2D) = "grey" { }
        [HideInInspector] _Mask1 ("Mask 1 (G)", 2D) = "grey" { }
        [HideInInspector] _Mask0 ("Mask 0 (R)", 2D) = "grey" { }
        [HideInInspector][Gamma] _Metallic0 ("Metallic 0", Range(0.0, 1.0)) = 0.0
        [HideInInspector][Gamma] _Metallic1 ("Metallic 1", Range(0.0, 1.0)) = 0.0
        [HideInInspector][Gamma] _Metallic2 ("Metallic 2", Range(0.0, 1.0)) = 0.0
        [HideInInspector][Gamma] _Metallic3 ("Metallic 3", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _Smoothness0 ("Smoothness 0", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _Smoothness1 ("Smoothness 1", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _Smoothness2 ("Smoothness 2", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _Smoothness3 ("Smoothness 3", Range(0.0, 1.0)) = 0.5

        // used in fallback on old cards & base map
        [HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "grey" { }
        [HideInInspector] _BaseColor ("Main Color", Color) = (1, 1, 1, 1)

        [HideInInspector] _TerrainHolesTexture ("Holes Map (RGB)", 2D) = "white" { }

        [ToggleUI] _EnableInstancedPerPixelNormal ("Enable Instanced per-pixel normal", Float) = 1.0
    }

    HLSLINCLUDE

    #pragma multi_compile_fragment __ _ALPHATEST_ON

    ENDHLSL

    SubShader
    {
        Tags { "Queue" = "Geometry-100" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "Lit" "IgnoreProjector" = "False" }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            HLSLPROGRAM

            #pragma target 3.0

            #pragma vertex SplatmapVert
            #pragma fragment SplatmapFragment

            #define _METALLICSPECGLOSSMAP 1
            #define _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A 1

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma multi_compile _ _DIM_FOG_ON
            #pragma multi_compile _ _DIM_FOG_ARRAY_ON
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

            #pragma shader_feature_local_fragment _TERRAIN_BLEND_HEIGHT
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _MASKMAP
            // Sample normal in pixel shader when doing instancing
            #pragma shader_feature_local _TERRAIN_INSTANCED_PERPIXEL_NORMAL


            #include "MMN_TerrainLitInput.hlsl"
            #include "MMN_TerrainLitPasses.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/bendingVertex.hlsl"


            ENDHLSL
        }

        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster" }

        //     ZWrite On
        //     ColorMask 0

        //     HLSLPROGRAM

        //     #pragma target 2.0

        //     #pragma vertex ShadowPassVertex
        //     #pragma fragment ShadowPassFragment

        //     #pragma multi_compile_instancing
        //     #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

        //     #include "MMN_TerrainLitInput.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitPasses.hlsl"
        //     #include "MMN_TerrainLitPasses.hlsl"
        //     ENDHLSL
        // }






        //G 버퍼는 필요없으니까 뺍시다
        // Pass
        // {
        //     Name "GBuffer"
        //     Tags { "LightMode" = "UniversalGBuffer" }

        //     HLSLPROGRAM

        //     #pragma exclude_renderers gles
        //     #pragma target 3.0
        //     #pragma vertex SplatmapVert
        //     #pragma fragment SplatmapFragment

        //     #define _METALLICSPECGLOSSMAP 1
        //     #define _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A 1

        //     // -------------------------------------
        //     // Universal Pipeline keywords
        //     #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        //     #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //     //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        //     //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        //     #pragma multi_compile _ _SHADOWS_SOFT
        //     #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

        //     // -------------------------------------
        //     // Unity defined keywords
        //     #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        //     #pragma multi_compile _ LIGHTMAP_ON
        //     #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        //     //#pragma multi_compile_fog
        //     #pragma multi_compile_instancing
        //     #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

        //     #pragma shader_feature_local _TERRAIN_BLEND_HEIGHT
        //     #pragma shader_feature_local _NORMALMAP
        //     #pragma shader_feature_local _MASKMAP
        //     // Sample normal in pixel shader when doing instancing
        //     #pragma shader_feature_local _TERRAIN_INSTANCED_PERPIXEL_NORMAL
        //     #define TERRAIN_GBUFFER 1

        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitInput.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitPasses.hlsl"
        //                 //GlobalVariables
        //     half _Global_CloudDensity;
        //     half _Global_CloudSpeed;
        //     half _Global_CloudScale;
        //     half _Global_CloudEdgeHardness;

        //     #include "MMN_TerrainLitPasses.hlsl"
        //     ENDHLSL

        // }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM

            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

            #include "MMN_TerrainLitInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitPasses.hlsl"
            #include "MMN_TerrainLitPasses.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        // Pass
        // {
        //     Name "DepthNormals"
        //     Tags { "LightMode" = "DepthNormals" }

        //     ZWrite On

        //     HLSLPROGRAM

        //     #pragma target 2.0
        //     #pragma vertex DepthNormalOnlyVertex
        //     #pragma fragment DepthNormalOnlyFragment

        //     #pragma shader_feature_local _NORMALMAP
        //     #pragma multi_compile_instancing
        //     #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

        //     #include "MMN_TerrainLitInput.hlsl"
        //     // #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitPasses.hlsl"
        //     #include "MMN_TerrainLitPasses.hlsl"
        //     ENDHLSL
        // }

        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }

            HLSLPROGRAM

            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

            #define SCENESELECTIONPASS
            #include "MMN_TerrainLitInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/Terrain/TerrainLitPasses.hlsl"
            #include "MMN_TerrainLitPasses.hlsl"
            ENDHLSL
        }

        UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
    }
    // Dependency "AddPassShader" = "Hidden/Universal Render Pipeline/Terrain/Lit (Add Pass)"
    Dependency "AddPassShader" = "Hidden/MMN/BG/TerrainLit(Add Pass)"
    Dependency "BaseMapShader" = "Hidden/Universal Render Pipeline/Terrain/Lit (Base Pass)"
    Dependency "BaseMapGenShader" = "Hidden/Universal Render Pipeline/Terrain/Lit (Basemap Gen)"

    

    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_TerrainLitGUI"
}



