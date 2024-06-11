Shader "MMN/Special/FloorReflection"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Header(Stencil Options)]
        [Space(10)]
        _StencilRef("Stencil Ref", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_Comp("Comp", Int) = 3

        [Header(Texture Options)]
        [Space(10)]
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Color", Color) = (0.5, 0.5, 0.5, 1)

        [Header(Reflection Options)]
        [Space(10)]
        _CubeMap("Reflection CubeMap", Cube) = ""{}
        _Lerp ("Reflection Lerp", Range(0, 1)) = 0.5
        [HDR]_SpecColor ("Reflection Color", Color) = (10, 10, 10, 1)
        _Gloss ("Glossiness", Range(0.01, 5)) = 1

        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Cull ("__cull", Float) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "SimpleLit"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Stencil
        {
            Ref [_StencilRef]
            Comp [_Comp]
            Pass Keep
        }
        Offset -1, 0

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]
            ZTest LEqual

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords
            #define _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_FloorReflectionInput.hlsl"
            #include "MMN_FloorReflectionForwardPass.hlsl"
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

            // -------------------------------------
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
            // #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
            // 에디터에서 니어 클리핑을 잠시 안보게 할 수 있는 기능. 에디터 한정이라 셰이더 피쳐로 올립니다
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            // GPU Instancing
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
            #define RAYCAST 1
            #define LODFADE 1

            #include "MMN_FloorReflectionInput.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    Fallback "Hidden/Universal Render Pipeline/FallbackError"
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_WindowGlassGUI"
}
