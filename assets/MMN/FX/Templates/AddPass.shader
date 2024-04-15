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

			Blend Off
			ZWrite On
            ZTest LEqual
            Cull Back
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //--------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_ShadowCasterInput.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
