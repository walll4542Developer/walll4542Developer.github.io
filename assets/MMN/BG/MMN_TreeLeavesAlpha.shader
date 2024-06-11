// 이 셰이더는 평소 사용하지 않고 가시성 처리에서만 사용할예정입니다
Shader "Hidden/MMN/BG/TreeLeavesAlphaBlend"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        // [Toggle]_AlphaTest ("알파테스트", float) = 1
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [MainTexture] _BaseMap ("Base Map (RGB)  / Alpha (A)", 2D) = "white" { }
        [MainColor]   _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

        // _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        // Blending state
        // [HideInInspector] _Surface ("__surface", Float) = 0.0
        // [HideInInspector] _Blend ("__blend", Float) = 0.0
        // [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        // [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        // [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        // [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // [HideInInspector] _Cull ("__cull", Float) = 2.0

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
        // [Header(Center Pos n VertexColor _______________________________________________________________________________)]
        // [Space(10)]
        _CenterPointHeight ("Center Position Height", float) = 0
        [Toggle]_ShowCenterPosition ("Show Center Position(확인용)", float) = 0
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        // [Space(10)]
        // [Header(Wind n Push _______________________________________________________________________________)]
        // [Space(10)]
        _WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        _WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        _GrassPushPower ("GrassPushPower(미는 힘 영향력)", float) = 1
        // [Toggle]_ShowGlobalTexture ("Show Global Texture(확인용)", float) = 0

        // [Space(10)]
        // [Header(Shadow and AO _____________________________________________________________________________)]
        // [Space(10)]
        _ReceiveShadowStrength ("_ReceiveShadowStrength", Range(0, 1)) = 0.5
        _AOarea ("AOarea", Range(0, 10)) = 2
        _AOintensity ("AOintensity", float) = 3
        _AOVertical ("AO Aspect ratio(가로세로비율)", Range(0.01, 3)) = 1
        // [Toggle]_ShowAO ("Show inner AO(확인용)", float) = 0

        // [Space(10)]
        // [Header(Lighting Control _____________________________________________________________________________)]
        // [Space(10)]
        _NormalLerp ("NormalLerp", Range(0, 1)) = 1
        _ShadingPow ("ShadingPow", Range(0, 3)) = 0.2
        // _ReceiveGIStrength ("ReceiveGIStrength", Range(0,5)) = 1
        // _TopLightColor ("Ambient TopLight Color", color) = (0.1, 0.3, 0.1, 1)
        _TopLightThickness ("Ambient TopLight Thickness", Range(0.1, 40)) = 4
        // [Toggle]_TOPLIGHT ("Show Top Light(확인용)", float) = 0

        // [Space(10)]
        // [Header(Rim Control _____________________________________________________________________________)]
        // [Space(10)]
        _RimArea ("RimArea", Range(0, 20)) = 7
        _RimRange ("RimRange", float) = 8
        [HDR]_RimColor ("RimColor", color) = (0.1, 0.3, 0.1, 1)
        // [Toggle]_RimPreview ("Rim Preview(확인용)", float) = 0


        // _NoiseTexture ("_NoiseTexture", 2D) = "gray"{}

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
            Cull off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature _ _SHOWCENTERPOSITION_ON
            // #pragma shader_feature _ _RIMPREVIEW_ON
            // #pragma shader_feature _ _SHOWAO_ON
            // #pragma shader_feature _ _TOPLIGHT_ON
            // #pragma shader_feature _ _SHOWVERTEXCOLOR_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // //#pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile_fragment _ _GLOBAL_OPTION_VERY_LOW

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_TreeLeavesAlpha_Input.hlsl"
            #include "MMN_TreeLeavesAlphaForwardPass.hlsl"
            ENDHLSL
        }
    }

    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_TreeLeavesGUI"
}
