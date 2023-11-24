Shader "MMN/FX/AddPass"
{
    Properties
    {
    }
    SubShader
    {
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용

            //--------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            // GPU Instancing
            #pragma multi_compile _ _ALPHATEST_ON
            // #pragma multi_compile_instancing
            // -------------------------------------
            // Universal Pipeline keywords
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_ShadowCasterInput.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
