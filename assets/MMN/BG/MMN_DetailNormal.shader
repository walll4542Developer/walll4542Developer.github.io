// Shader targeted for low end devices. Single Pass Forward Rendering.
// 노말맵을 안쓰지만 디테일노말입니다. 원래 쓰던건데 개조하다 보니 안쓰게 됨
Shader "MMN/BG/DetailNormal"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        //셰이더 셋업
        [Toggle]_NEARHALFTONECLIP ("니어 클립", float) = 0
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0

        //셰이더 조절
        [MainColor] _BaseColor ("Base Tint 틴트칼라", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength 베이스맵 틴트 강도", Range(-1.0, 1.0)) = 0.0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0
         _RampY ("RampY", Range(0, 1)) = 0.5
        _halfLambertWeight ("halfLambertWeight", Range(0, 1)) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) SpecularMask (A)", 2D) = "white" { }
        // //임시로 만든 베이스맵 2
        // _BaseMap2 ("BaseMap2", 2D) = "white" { }
        // _BaseMap2BlendWeight ("베이스맵 2 경계선 부드럽기", Range(1, 30)) = 1
        //디테일맵. 돌산의 퇴적 줄무늬를 만들때 사용한다
        _DetailMap ("DetailMap (RGB) Blending (A)", 2D) = "black" { }
        [Toggle]_DetailMapYenable ("DetailMapYenable", float) = 0

        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider(3)]_Glossiness ("Glossiness", Range(0.01, 10)) = 0.8

        // _BumpMap ("Normal Map", 2D) = "bump" { }
        // _DetailBumpMap ("Detail Normal Map", 2D) = "bump" { }
        // _DetailBumpScale ("Detail Normal Scale", Range(0, 2)) = 1.0

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }

        //2nd Normal
        // [Space(10)]
        // [Header(SecondMap    ____________________________________________________________________)]
        // [Space(10)]
        [Toggle] _SECONDMAP ("UseSecondMap (WorldNormal Y)", float) = 0
        // [Toggle] _VERTEXCOL ("UseSecondMap (VC R)", float) = 0
        _SecondMap ("SecondMap", 2D) = "white" { }
        _SecondMapOffset ("SecondMapOffset", float) = 0
        _SecondMapScale ("SecondMapScale", Range(0, 1)) = 1
        _SecondMapBlendHardness ("SecondMapBlendHardness", Range(0, 0.5)) = 0.25

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Cull ("__cull", Float) = 2.0

        [HideInInspector][ToogleOff] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [HideInInspector] _Smoothness ("SMoothness", Float) = 0.5

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0
    }

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
            // ZWrite[_ZWrite]
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore d3d9
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용

            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_local_fragment _ _NEARHALFTONECLIP_ON
            #pragma multi_compile_local_fragment _ _SECONDMAP_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
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
            #define LIGHT_SPECULAR 1

            // #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_DetailNormal_Input.hlsl"
            #include "MMN_DetailNormal_Input.hlsl"
            #include "MMN_DetailNormal_ForwardPass.hlsl"
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

            #include "MMN_DetailNormal_Input.hlsl"
            #include "MMN_DetailNormal_ShadowCaterPass.hlsl"
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

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_local_fragment _ _NEARHALFTONECLIP_ON

            #define VERTEX_CAMERA_DEPEND_BENDING 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_DetailNormal_Input.hlsl"
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

            #include "MMN_DetailNormal_Input.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_DetailNormalGUI"
}
