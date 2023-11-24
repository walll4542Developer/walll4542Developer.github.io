Shader "MMN/BG/WindowGlass"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Toggle]_NEARHALFTONECLIP ("니어 클립", float) = 0
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        // _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [HDR]_SpecColor ("Specular Color", Color) = (10, 10, 10, 1)
        _Smoothness ("SMoothness", Float) = 0.5
        _Gloss ("Glossiness", Range(0.01, 5)) = 1

        // _SpecGlossMap ("Specular Map", 2D) = "white" {}
        // _SmoothnessSource ("Smoothness Source", Float) = 0.0
        // _SpecularHighlights ("Specular Highlights", Float) = 1.0

        // [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        // [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        //유리창 전용
        [Enum(outside, 0, inside, 1)] _OutsideInside ("밖인지 안인지", Float) = 0.0
        [HDR]_EmissionColorDark ("어두운 유리창 색", Color) = (0, 0, 0, 1)
        [HDR]_EmissionColorBright ("밝은 유리창 색", Color) = (15, 14, 4, 1)
        _TempNight2DaySwitchTest ("밤-> 낮 변환테스트", Range(0, 1)) = 1
        // [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }


        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // [HideInInspector] _Cull ("__cull", Float) = 2.0

        [HideInInspector][ToogleOff] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.01
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }


        //흔들리기. 버텍스 알파에 대응한다. 유리에는 필요없지만 셰도우나 댑스 패스를 다른셰이더와 공유하고 있기 때문에, SRP 배쳐를 위해 놔둡니다
        [HideInInspector]_WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        [HideInInspector]_WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        [Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0
        //버텍스 애니를 강제로 끄기. 셰이더 피쳐나 멀티컴파일로 분리하면 SRP 버퍼가 가동이 안될수 있어서 강제 포함
        [HideInInspector] [Toggle]_VertexAniOn ("버텍스 애니를 켠다", float) = 0
        [HideInInspector][Toggle]_UseVertexAnimation ("버텍스 애니 기능 통채로 끄기", float) = 0 //GUI에서만 쓰는 기능이라 프로퍼티에서만 유지합니다.

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
            ZWrite[_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON //글로벌이라서 로컬로 하면 곤란
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            // #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            // #pragma multi_compile _ _CLUSTERED_RENDERING

            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            // #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            // #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "MMN_WindowGrassInput.hlsl"
            #include "MMN_WindowGrassForwardPass.hlsl"
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

            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "MMN_WindowGrassInput.hlsl"
            #include "MMN_SimpleLitShadowCasterPass.hlsl"
            ENDHLSL
        }

        // 댑스 프라이밍 Only 일때 사용됨
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

            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
            #define RAYCAST 1
            #define LODFADE 1

            #include "MMN_WindowGrassInput.hlsl"
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

            #include "MMN_WindowGrassInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_WindowGlassGUI"
}
