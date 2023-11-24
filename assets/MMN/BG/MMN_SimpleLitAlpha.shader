// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/BG/SimpleLitAlphaBlend"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        // [Toggle]_NEARHALFTONECLIP ("니어 클립", float) = 0
        // [Toggle]_ALPHATEST ("알파테스트", float) = 0
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0

        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        // _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _Smoothness ("Smoothness", Range(0.0, 1.0)) = 0.5
        _Gloss ("Glossiness", Range(0.01, 5)) = 1

        _SpecGlossMap ("Specular Map", 2D) = "white" { }
        _SmoothnessSource ("Smoothness Source", Float) = 0.0
        _SpecularHighlights ("Specular Highlights", Float) = 1.0

        [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        [HDR]_EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // [HideInInspector] _Cull ("__cull", Float) = 2.0

        [ToggleUI] _ReceiveShadows ("Receive Shadows", Float) = 1.0

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


        //흔들리기. 버텍스 알파에 대응한다.
        _WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        _WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        [Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0
        //버텍스 애니를 강제로 끄기. 셰이더 피쳐나 멀티컴파일로 분리하면 SRP 버퍼가 가동이 안될수 있어서 강제 포함
        [Toggle]_VertexAniOn ("버텍스 애니를 켠다", float) = 1
        [Toggle]_UseVertexAnimation ("버텍스 애니 기능 GUI 에서 끄기", float) = 0 //GUI에서만 쓰는 기능이라 프로퍼티에서만 유지합니다.

    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            // Blend[_SrcBlend][_DstBlend]
            Blend SrcAlpha OneMinusSrcAlpha
            // ZWrite[_ZWrite]
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            #pragma shader_feature_local_fragment _ _NEARHALFTONECLIP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
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

            #include "MMN_SimpleLitAlphaInput.hlsl"
            #include "MMN_SimpleLitAlphaForwardPass.hlsl"
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"
}
