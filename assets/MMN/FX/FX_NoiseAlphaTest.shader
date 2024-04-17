Shader "MMN/FX/NoiseAlphaTest"
{
    Properties
    {
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 0.0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 4.0

		[HideInInspector] _Mode ("Mode", Float) = -1.0

		[HideInInspector][ToggleUI][Space(10)] _LightReceive("LightReceive", Range(0.0, 1.0)) = 0.0
		[HideInInspector] _LightRatio("lightRatio", Range(0.0, 1.0)) = 1.0

		[HideInInspector][ToggleUI] _FogReceive("FogReceive", Range(0.0, 1.0)) = 0.0
		
        [Header(Texture Options)]
        [Space(10)]
        _MainTex ("MainTex", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(AlphaTest Options)]
        [Space(10)]
        _CutoutThreshold ("Alpha Test Value", Range(0.0, 2.0)) = 0.0
        [Enum(none, 0, U, 1, V, 2)] _uvGradient ("Alpha Gradient Mode", float) = 2.0
        _GradientRange ("Gradient Range", Range(-1.0, 1.0)) = 0.0
        _AlphaTestRange ("Alpha Test Range", Range(0.0, 1.0)) = 0.1
        _BendRange ("Bend Range", Range(0, 0.1)) = 0.02
        [HDR] _ColorA ("Color A", Color) = (1.0, 1.0, 1.0, 1.0)
        [HDR] _ColorB ("Color B", Color) = (0.0, 0.0, 0.0, 1.0)

        [Header(Noise Options)]
        [Space(10)]
        _Power ("Vertex Offset", Range(0.0, 1.0)) = 0.2
        _Speed ("Time Speed", Range(-1.0, 1.0)) = 0.3
        _NoiseSize ("Noise Size", Range(0.0, 1.0)) = 0.1
    }

    SubShader
    {
		LOD 100
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "IgnoreProjector" = "True"
        }

        HLSLINCLUDE
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

            #include "Includes/FX_NoiseAlphaTestInput.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
        ENDHLSL

        Pass
        {
            Blend Off
			ZWrite On
            ZTest [_ZTest]
            Cull [_CullMode]
            ColorMask RGBA

            HLSLPROGRAM
            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
				
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    			output.normalWS = normalInput.normalWS;

                input.positionOS.xyz += input.normalOS * TriplanarNoise(positionWS, output.normalWS) * _Power * input.color.r; // TriplanarNoise
                
				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

                output.uv0.xy = TRANSFORM_TEX(input.texcoord.xy, _MainTex);
                output.uv0.zw = input.texcoord.zw;
				output.positionWS = vertexInput.positionWS;
				output.positionCS = vertexInput.positionCS;
				output.fogCoord.x = ComputeFogFactor(vertexInput.positionCS.z);
				output.color = input.color;

                return output;
            }


            float4 frag(Varyings input) : SV_Target
            {
                float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0.xy);
				textureColor *= _Color;

                float3 positionWS = input.positionWS;
                positionWS *= _NoiseSize + 0.00001;
                positionWS.y -= _Time.y * _Speed;

                float4 noiseTexture = TriplanarNoise(positionWS, input.normalWS);
                float noise0 = noiseTexture.r;
                float noise1 = TriplanarNoise(positionWS * 2, input.normalWS).r;

				float3 color = textureColor.rgb;
				float alpha = textureColor.a * input.color.a;

                float4 finalColor = float4(color, alpha);

                finalColor = ProcessNoiseAlphaTest(finalColor, input.uv0.xy, _GradientRange, _CutoutThreshold + input.uv0.z, _BendRange, _AlphaTestRange, noise0, noise1, _ColorA, _ColorB, _uvGradient);
                clip(finalColor.a - (_CutoutThreshold + input.uv0.z));

				ApplyLightColor(finalColor, input.normalWS, _LightRatio, _LightReceive);
				ApplyFogColor(finalColor, input.positionWS, input.normalWS, _Mode, _FogReceive, input.fogCoord);

                return finalColor;
            }
            ENDHLSL
        }

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

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            float3 _LightDirection;
            float3 _LightPosition;

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

				float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
				
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    			output.normalWS = normalInput.normalWS;

                input.positionOS.xyz += input.normalOS * TriplanarNoise(positionWS, output.normalWS) * _Power * input.color.r; // TriplanarNoise
                positionWS = TransformObjectToWorld(input.positionOS.xyz);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, output.normalWS, lightDirectionWS));

                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif

				output.uv0.xy = TRANSFORM_TEX(input.texcoord.xy, _MainTex);
                output.uv0.zw = input.texcoord.zw;
				output.positionWS = positionWS;
				output.positionCS = positionCS;

                return output;
            }

            float4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                float4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv0.xy);
				textureColor *= _Color;
				
                float3 positionWS = input.positionWS;
                positionWS *= _NoiseSize + 0.00001;
                positionWS.y -= _Time.y * _Speed;

                float4 noiseTexture = TriplanarNoise(positionWS, input.normalWS);
                float noise0 = noiseTexture.r;
                float noise1 = TriplanarNoise(positionWS * 2, input.normalWS).r;
				
				float3 color = textureColor.rgb;
				float alpha = textureColor.a * input.color.a;

                float4 finalColor = float4(color, alpha);

                finalColor = ProcessNoiseAlphaTest(finalColor, input.uv0.xy, _GradientRange, _CutoutThreshold + input.uv0.z, _BendRange, _AlphaTestRange, noise0, noise1, _ColorA, _ColorB, _uvGradient);
                clip(finalColor.a - (_CutoutThreshold + input.uv0.z));

                return 0;
            }
            ENDHLSL
        }
    }
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"
	FallBack Off
}
