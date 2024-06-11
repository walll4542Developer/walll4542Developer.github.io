// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/BG/Grass"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [HideInInspector][Toggle]_ALPHATEST ("알파테스트", float) = 1 //기본이 켜있게
        [MainColor] [HDR]_BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        [HDR] _TopColor ("TopColor(VertexColor G)", color) = (0, 0, 0, 0)
        _ShadowDim ("ShadowDimming(그림자 영향력 조절)", Range(0, 1)) = 0
        // [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" {}


        //글로벌 텍스쳐
        _GlobalTextureBlending ("GlobalTextureBlending", Range(0, 1)) = 0
        _TextureBlendingScroll ("_TextureBlendingScroll(구름속도 연동)", Range(0, 2)) = 0.1
        [Toggle]_ShowGlobalTexture ("Show Global Texture(확인용)", Float) = 0

        //스페큘러
        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider(10)]_Glossiness ("Smoothness", Range(0.1, 1)) = 0.5

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }

        //바람과 푸시 영향력
        _WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들립니다
        _WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7
        _GrassPushPower ("GrassPushPower(미는 힘 영향력)", Float) = 1
        [HideInInspector][Toggle]_VertexAniOff ("버텍스 애니를 강제로 끈다", Float) = 0

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

        // [ToogleOff] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0
        [HideInInspector] _Smoothness ("SMoothness", Float) = 0.5

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        _GrassVisualRange ("최대 가시 거리", Range(-10, 10)) = 0
        [Toggle] _GrassVisualActionToggle ("풀 등장/퇴장 연출 활성화 버튼", Float) = 1.0

        _InstancingColor ("_Instancing Color", Color) = (1, 1, 1, 1)
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
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature _SHOWGLOBALTEXTURE_ON                        

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile_fragment _ _GLOBAL_OPTION_VERY_LOW

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #define BUMP_SCALE_NOT_SUPPORTED 1
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #define _NEARHALFTONECLIP_ON 1

            #include "MMN_GrassInput.hlsl"
            #include "MMN_GrassForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // #pragma multi_compile _ALPHATEST_ON _ALPHATEST_OFF

            #define VERTEX_GRASS_HEIGHT_MOVEMENT 1
            #define LODFADE 1
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #define _NEARHALFTONECLIP_ON 1 //늘 켜지게 되어 있음
            #define RAYCAST 1
            #define _ALPHATEST_ON
            #define GRASS_INSTANCING

            #include "MMN_GrassInput.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
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
            Blend [_SrcBlend][_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON                        

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _GLOBAL_OPTION_VERY_LOW

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #define BUMP_SCALE_NOT_SUPPORTED 1
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #define _NEARHALFTONECLIP_ON 1

            #include "MMN_GrassInput.hlsl"
            #include "MMN_GrassForwardPass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // #pragma multi_compile _ALPHATEST_ON _ALPHATEST_OFF

            #define VERTEX_GRASS_HEIGHT_MOVEMENT 1
            #define LODFADE 1
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #define _NEARHALFTONECLIP_ON 1 //늘 켜지게 되어 있음
            #define RAYCAST 1
            #define _ALPHATEST_ON
            #define GRASS_INSTANCING

            #include "MMN_GrassInput.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_GrassGUI"
}
