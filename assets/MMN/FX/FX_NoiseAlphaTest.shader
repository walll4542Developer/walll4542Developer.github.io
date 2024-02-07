// @wooyoung 22.05.04
// 노드로 컨버팅 필요(버텍스 밴딩, 빛 적용, 딤 포그 미지원)

Shader "MMN/FX/NoiseAlphaTest"
{
    Properties
    {
        [Header(Texture Options)]
        [Space(10)]
        _MainTex ("MainTex", 2D) = "white" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 1, 1, 1.0)

        [Header(AlphaTest Options)]
        [Space(10)]
        _CutoutThreshold ("Alpha Test Value", Range(0.0, 2.0)) = 0
        [KeywordEnum(none, U, V)] _uvGradient ("Alpha Gradient Mode", float) = 2
        _GradientRange ("Gradient Range", Range(-1, 1)) = 0
        _AlphaTestRange ("Alpha Test Range", Range(0.0, 1)) = 0.1
        _BendRange ("Bend Range", Range(0, 0.1)) = 0.02
        [HDR]_ColorA ("Color A", Color) = (1, 1, 1, 1)
        [HDR]_ColorB ("Color B", Color) = (0, 0, 0, 1)

        [Header(Noise Options)]
        [Space(10)]
        // _randomize ("randomize", float) = 0
        _Power ("Vertex Offset", Range(0, 1)) = 0.2
        _Speed ("Time Speed", Range(-1, 1)) = 0.3
        _NoiseSize ("Noise Size", Range(0, 1)) = 0.1

        [Header(Zbuffer Options)]
        [Space(10)]
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite", Float) = 1
        [Enum(Default,2,Always,6)] _ZTest("ZTest", Float) = 2.0

        [Header(Environment Options)]
        [Space(10)]
        [Toggle(_FOG_RCV_ON)] _FogReceive ("안개 적용", Float) = 1.0
        [Toggle] _LightReceive ("빛 적용", Float) = 1.0
        // [Toggle] _DimLightReceive ("포그 적용", Float) = 1.0

        // Blend mode values
        [HideInInspector] _Mode ("__mode", Int) = -1
        [HideInInspector] _SrcBlend ("Src Blend", Float) = 1.0
        [HideInInspector] _DstBlend ("Dst Blend", Float) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "IgnoreProjector" = "True"
        }

        HLSLINCLUDE
		#pragma target 4.5
        ENDHLSL

        Pass // Opaque
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            Cull Off
            ColorMask RGB

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_local _UVGRADIENT_NONE _UVGRADIENT_U _UVGRADIENT_V
            #pragma multi_compile_local _FOG_RCV_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50 nolightprobe nolightmap

            #pragma vertex vert
            #pragma fragment frag

            #include "includes/FX_NoiseAlphaTestInput.hlsl"

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.uv.xy = TRANSFORM_TEX(input.texcoord.xy, _MainTex);
                output.uv.zw = input.texcoord.zw;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                input.positionOS.xyz += input.normalOS * TriplanarNoise(positionWS, output.normalWS) * _Power * input.color.r; // TriplanarNoise
                // input.positionOS.xyz += input.normalOS * FractalNoise(positionWS, 6, 1) * _Power * input.color.r; // MathNoise

                positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;

                output.color = input.color;

                #ifdef _FOG_RCV_ON
                    output.fogCoord.x = ComputeFogFactor(output.positionCS.z);
                #endif

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                half4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);

                float3 positionWS = input.positionWS;
                positionWS *= _NoiseSize + 0.00001;
                positionWS.y -= _Time.y * _Speed;

                half4 noiseTexture = TriplanarNoise(positionWS, input.normalWS);
                half noise0 = noiseTexture.r;
                half noise1 = TriplanarNoise(positionWS * 2, input.normalWS).r;

                half4 finalColor = textureColor * _Color;

                finalColor = ProcessNoiseAlphaTest(finalColor, input.uv.xy, _GradientRange, _CutoutThreshold + input.uv.z, _BendRange, _AlphaTestRange, noise0, noise1, _ColorA, _ColorB);
                clip(finalColor.a - (_CutoutThreshold + input.uv.z));
                half alpha = finalColor.a * input.color.a;

                // 빛 적용 여부
                Light mainLight = GetMainLight();
                finalColor.rgb *= lerp(real3(1.0, 1.0, 1.0), mainLight.color.rgb, _LightReceive);

                // TriplanarNoise Test
                // finalColor.rgb = TriplanarNoise(input.positionWS, input.normalWS, _Time.y * _Speed, _NoiseTex, sampler_NoiseTex, _NoiseTex_ST);

                // MathNoise Test
                // finalColor.rgb = FractalNoise(input.positionWS, 6, 1);

                #ifdef _FOG_RCV_ON
                    //하이트 포그  연산 일반 Alpha Blend
                    finalColor= MMN_GlobalTex_HeightFog(
                        finalColor,
                        input.positionWS, input.normalWS, input.fogCoord,
                        _Global_FogHeightOffset,
                        _Global_FogHeightScale,
                        _Global_FogHeightNoiseValue,
                        _Global_FogHeightNoiseSpeed,
                        _Global_FogHeightNoiseScale,
                        float2(0,0));

                    //하이트 포그  연산 ADD
                    // finalColor= MMN_GlobalTex_HeightFogAdd(
                    //     finalColor,
                    //     input.positionWS, input.normalWS, input.fogCoord,
                    //     _Global_FogHeightOffset,
                    //     _Global_FogHeightScale,
                    //     _Global_FogHeightNoiseValue,
                    //     _Global_FogHeightNoiseSpeed,
                    //     _Global_FogHeightNoiseScale,
                    //     float2(0,0));

                    //하이트 포그  연산 Multi
                    // finalColor= MMN_GlobalTex_HeightFogMulti(
                    //     finalColor,
                    //     input.positionWS, input.normalWS, input.fogCoord,
                    //     _Global_FogHeightOffset,
                    //     _Global_FogHeightScale,
                    //     _Global_FogHeightNoiseValue,
                    //     _Global_FogHeightNoiseSpeed,
                    //     _Global_FogHeightNoiseScale,
                    //     float2(0,0));


                    // finalColor.rgb = MixFog(finalColor.rgb, input.fogCoord);
                #endif

                return half4(finalColor.rgb, alpha);
            }
            ENDHLSL
        }

        Pass // 심플릿에 쓰는 ShadowCaster 개조
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile_local _UVGRADIENT_NONE _UVGRADIENT_U _UVGRADIENT_V

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile _ _ALPHATEST_ON
            #pragma multi_compile_instancing
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "includes/FX_NoiseAlphaTestInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
            // For Directional lights, _LightDirection is used when applying shadow Normal Bias.
            // For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
            float3 _LightDirection;
            float3 _LightPosition;

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.uv.xy = TRANSFORM_TEX(input.texcoord.xy, _MainTex);
                output.uv.zw = input.texcoord.zw;

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                input.positionOS.xyz += input.normalOS * TriplanarNoise(positionWS, output.normalWS) * _Power * input.color.r; // TriplanarNoise
                // input.positionOS.xyz += input.normalOS * FractalNoise(positionWS, 6, 1) * _Power * input.color.r; // MathNoise
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

                output.positionWS = positionWS;
                output.positionCS = positionCS;
                output.color = input.color;

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                half4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv.xy);
                half4 noiseTexture = TriplanarNoise(input.positionWS, input.normalWS);
                half noise0 = noiseTexture.r;
                half noise1 = TriplanarNoise(input.positionWS * 2, input.normalWS).r;

                half4 finalColor = textureColor * _Color;

                finalColor = ProcessNoiseAlphaTest(finalColor, input.uv.xy, _GradientRange, _CutoutThreshold + input.uv.z, _BendRange, _AlphaTestRange, noise0, noise1, _ColorA, _ColorB);
                clip(finalColor.a - (_CutoutThreshold + input.uv.z));

                // Alpha(finalColor.a, 1, _CutoutThreshold + input.uv.z);
                return 0;
            }
            ENDHLSL
        }
    }

    CustomEditor "MM.Client.Editor.ShaderGUI.FxBlendModeShaderGUI"
}
