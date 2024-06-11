// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/BG/Baked/SimpleLitBaked"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [HDR]_SpecColor ("Specular Color", Color) = (0, 0, 0, 0)
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0
        _Gloss ("Glossiness", Range(0.01, 5)) = 1
        _RampY ("RampY", Range(0, 1)) = 0.5
        [Toggle]_BackfaceReceiveShadowOff ("백페이스 리시브 셰도우 끄기", float) = 0

        _SpecGlossMap ("Specular Map", 2D) = "white" { }
        _SmoothnessSource ("Smoothness Source", Float) = 0.0
        _SpecularHighlights ("Specular Highlights", Float) = 1.0

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }
        [Enum(Always, 0, NightOnly, 1, DayOnly, 2)] _Night2DayEnum ("언제 Emission이 켜지게 할까요", float) = 0

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0

        [ToggleUI] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        _QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }


        //흔들리기. 버텍스 알파에 대응한다.
        _WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        _WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        [Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0
        //버텍스 애니를 강제로 끄기. 셰이더 피쳐나 멀티컴파일로 분리하면 SRP 버퍼가 가동이 안될수 있어서 강제 포함
        [Toggle]_VertexAniOn ("버텍스 애니를 강제로 끈다", float) = 1
        [Toggle]_UseVertexAnimation ("버텍스 애니 기능 통채로 끄기", float) = 0 //GUI에서만 쓰는 기능이라 프로퍼티에서만 유지합니다.

        [Header(Stencil Options)]
        [Space]
        _StencilRef ("Stencil Ref", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail Keep
                ZFail Keep
            }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            // ZWrite[_ZWrite]
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            // Universal Pipeline keywords
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK //이걸빼면 더 어두워짐
            // #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            // #pragma multi_compile _ _CLUSTERED_RENDERING
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES


            // #pragma multi_compile _ LIGHTMAP_ON
            #define LIGHTMAP_ON 1
            #define HALF_SUBTRACTIVE_LIGHTMAP_ON 1
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
            // #define BUMP_SCALE_NOT_SUPPORTED 1



            #include "MMN_SimpleLitInput.hlsl"
            #include "MMN_SimpleLitForwardPass.hlsl"
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
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define VERTEX_CAMERA_DEPEND_BENDING 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_SimpleLitInput.hlsl"
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

            #include "MMN_SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }

    // SubShader //저사양 옵션용 셰이더 봉인
    // {
    //     Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel"="2.0" }
    //     LOD 300

    //     Pass
    //     {
    //         Name "ForwardLit"
    //         Tags { "LightMode" = "UniversalForward" }

    //         // Use same blending / depth states as Standard shader
    //         Blend[_SrcBlend][_DstBlend]
    //         ZWrite[_ZWrite]
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local _NORMALMAP
    //         #pragma shader_feature_local_fragment _EMISSION
    //         #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
    //         #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
    //         #pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         // -------------------------------------
    //         // Universal Pipeline keywords
    //         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
    //         #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
    //         #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    //         #pragma multi_compile _ SHADOWS_SHADOWMASK
    //         #pragma multi_compile_fragment _ _SHADOWS_SOFT
    //         #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
    //         #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
    //         #pragma multi_compile_fragment _ _LIGHT_LAYERS
    //         #pragma multi_compile_fragment _ _LIGHT_COOKIES
    //         #pragma multi_compile _ _CLUSTERED_RENDERING


    //         // -------------------------------------
    //         // Unity defined keywords
    //         #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    //         #pragma multi_compile _ LIGHTMAP_ON
    //         #pragma multi_compile _ DYNAMICLIGHTMAP_ON
    //         #pragma multi_compile_fog
    //         #pragma multi_compile_fragment _ DEBUG_DISPLAY

    //         #pragma vertex LitPassVertexSimple
    //         #pragma fragment LitPassFragmentSimple
    //         #define BUMP_SCALE_NOT_SUPPORTED 1

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitForwardPass.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "ShadowCaster"
    //         Tags { "LightMode" = "ShadowCaster" }

    //         ZWrite On
    //         ZTest LEqual
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         // -------------------------------------
    //         // Universal Pipeline keywords

    //         // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
    //         #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

    //         #pragma vertex ShadowPassVertex
    //         #pragma fragment ShadowPassFragment

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "DepthOnly"
    //         Tags { "LightMode" = "DepthOnly" }

    //         ZWrite On
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex DepthOnlyVertex
    //         #pragma fragment DepthOnlyFragment

    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
    //         ENDHLSL
    //     }

    //     // This pass is used when drawing to a _CameraNormalsTexture texture
    //     Pass
    //     {
    //         Name "DepthNormals"
    //         Tags { "LightMode" = "DepthNormals" }

    //         ZWrite On
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex DepthNormalsVertex
    //         #pragma fragment DepthNormalsFragment

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local _NORMALMAP
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

    //         //--------------------------------------
    //         // GPU Instancing
    //         #pragma multi_compile_instancing

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitDepthNormalsPass.hlsl"
    //         ENDHLSL
    //     }

    //     // This pass it not used during regular rendering, only for lightmap baking.
    //     Pass
    //     {
    //         Name "Meta"
    //         Tags { "LightMode" =  "Meta" }

    //         Cull Off

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex UniversalVertexMeta
    //         #pragma fragment UniversalFragmentMetaSimple

    //         #pragma shader_feature_local_fragment _EMISSION
    //         #pragma shader_feature_local_fragment _SPECGLOSSMAP
    //         #pragma shader_feature EDITOR_VISUALIZATION

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "Universal2D"
    //         Tags { "LightMode" = "Universal2D" }
    //         Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex vert
    //         #pragma fragment frag
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
    //         ENDHLSL
    //     }
    // }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitGUI"
}
