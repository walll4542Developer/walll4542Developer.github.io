// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/BG/TreeLeaves"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [MainTexture] _BaseMap ("Base Map (RGB)  / Alpha (A)", 2D) = "white" { }
        [MainColor]   _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [Toggle]_AlphaTest ("알파테스트", float) = 1

        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Cull ("__cull", Float) = 2.0

        [HideInInspector][ToggleOff] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [HideInInspector] _Smoothness ("Smoothness", Float) = 0.5

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }

        // [Space(10)]
        // [Header(Center Pos n VertexColor _센터포지션 & 버텍스칼라 _)]
        // [Space(10)]
        _CenterPointHeight ("Center Position Height 센터 포지션 높이 ", float) = 0
        [Toggle]_ShowCenterPosition ("Show Center Position(확인용)", float) = 0
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0
        [Toggle]_IsBush ("Isbush(임포스터 베이크 전용 옵션)", float) = 0
        [Toggle]_IsSnow ("IsSnow(임포스터 베이크 전용 옵션)", float) = 0

        // [Space(10)]
        // [Header(Wind n Push _바람과 푸시 영향력 _)]
        // [Space(10)]
        _WindMultiply ("Wind Multiply(바람 흔들림 크기)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        _WindSpeedMultiply ("Wind Speed Multiply(바람 속도 곱하기)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        _GrassPushPower ("GrassPushPower(풀숲 밀려나기)", float) = 1
        // [Toggle]_ShowGlobalTexture ("Show Global Texture(확인용)", float) = 0

        // [Space(10)]
        // [Header(Shadow and AO _그림자와 AO_)]
        // [Space(10)]
        _ReceiveShadowStrength ("_ReceiveShadowStrength", Range(0, 1)) = 0.5
        _AOarea ("AOarea", Range(0, 10)) = 2
        _AOintensity ("AOintensity", float) = 3
        _AOVertical ("AO Aspect ratio(가로세로비율)", Range(0.01, 3)) = 1
        [Toggle]_ShowAO ("Show inner AO(확인용)", float) = 0

        // [Space(10)]
        // [Header(Lighting Control _____________________________________________________________________________)]
        // [Space(10)]
        _NormalLerp ("NormalLerp", Range(0, 1)) = 1
        _ShadingPow ("ShadingPow", Range(0, 3)) = 0.2
        _TopLightColor ("Ambient TopLight Color", color) = (0.1, 0.3, 0.1, 1)
        _TopLightThickness ("Ambient TopLight Thickness", Range(0.1, 40)) = 4
        _RimArea ("RimArea", Range(0, 20)) = 7
        _RimRange ("RimRange", float) = 8
        [Toggle]_TOPLIGHT ("Show Top Light(확인용)", float) = 0

        _GIStrength ("_GIStrength(암부 밝기 가중치)", Range(0, 1)) = 0

        // [Space(10)]
        // [Header(Rim Control _____________________________________________________________________________)]
        // [Space(10)]
        [HDR]_RimColor ("RimColor", color) = (0.1, 0.3, 0.1, 1)
        [Toggle]_RimPreview ("Rim Preview(확인용)", float) = 0


        // _NoiseTexture ("_NoiseTexture", 2D) = "gray"{}

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
            // Cull[_Cull]
            Cull off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ _SHOWCENTERPOSITION_ON
            #pragma shader_feature _ _RIMPREVIEW_ON
            #pragma shader_feature _ _SHOWAO_ON
            #pragma shader_feature _ _TOPLIGHT_ON
            #pragma shader_feature _ _SHOWVERTEXCOLOR_ON
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_TreeLeaves_Input.hlsl"
            #include "MMN_TreeLeavesForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "MMN_TreeLeaves_Input.hlsl"
            #include "MMN_TreeLeavesShadowCasterPass.hlsl"
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

            //-------------------------------------
            // Material Keywords
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define _NEARHALFTONECLIP_ON 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 1
            #define RAYCAST 1
            #define TREELODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_TreeLeaves_Input.hlsl"
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

            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "MMN_TreeLeaves_Input.hlsl"
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
            // Cull[_Cull]
            Cull off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ _SHOWCENTERPOSITION_ON
            #pragma shader_feature _ _RIMPREVIEW_ON
            #pragma shader_feature _ _SHOWAO_ON
            #pragma shader_feature _ _TOPLIGHT_ON
            #pragma shader_feature _ _SHOWVERTEXCOLOR_ON
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ _LIGHT_LAYERS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_TreeLeaves_Input.hlsl"
            #include "MMN_TreeLeavesForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "MMN_TreeLeaves_Input.hlsl"
            #include "MMN_TreeLeavesShadowCasterPass.hlsl"
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

            //-------------------------------------
            // Material Keywords
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define _NEARHALFTONECLIP_ON 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 1
            #define RAYCAST 1
            #define TREELODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_TreeLeaves_Input.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_TreeLeavesGUI"
}
