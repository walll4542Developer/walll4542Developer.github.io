Shader "MMN/CH/FX_TransparentGlow"
{
    Properties
    {
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _BumpMap ("노말 맵", 2D) = "white" {}
        _BumpPower ("노말 맵 파워", Range(0.0, 1.0)) = 1
        [Enum(Off, 0, On, 1)] _ZWrite ("ZWrite", Float) = 1

        _Color ("틴트 컬러", Color) = (1.0, 1.0, 1.0, 1.0)
        _TintColorIntensity ("틴트 컬러 인텐시티", Float) = 1.0

        _FresnelColor ("프레넬 컬러", Color) = (1.0, 1.0, 1.0, 1.0)
        _FresnelRange ("프레넬 범위", Range(0.0, 1.0)) = 0.3
        _FresnelPower ("프레넬 파워", Range(0.0, 2.0)) = 1

        [Header(Advanced Options)]
        [Space(10)]
        [Toggle] _InflateInverseNormal ("사망 시 부풀는 연출/ 노멀 방향 반대로", Float) = 0

        // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (1.0, 0.0, 0.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InflateWidth ("_InflateWidth", Float) = 0.0
        [HideInInspector] _InflateColor ("_InflateColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue("_MotionBlurLerpValue", Float) = 0.0
        
        [HideInInspector] _StencilValue("_StencilValue", Integer) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "TransparentRenderObject" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite [_ZWrite]
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "MMN_CharacterFX_TransparentGlow_Input.hlsl"
            #include "../Includes/BendingVertex.hlsl"
            #include "Includes/CharacterApplyFx.hlsl"
            #include "Includes/CharacterApplyFog.hlsl"
            #include "Includes/CharacterLighting.hlsl"
            #include "Includes/CharacterDithering.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;

                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION; // Homogeneous clip space position

                float2 uv : TEXCOORD0;

                float3 positionWS : TEXCOORD1;   // World space position
                float3 normalWS : TEXCOORD2;
                float4 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;

                float4 fogCoord : TEXCOORD6;     // x: fogFactor, yzw: vertexLighting
                float4 positionNDC : TEXCOORD7;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                float3 inflateNormal = (_InflateInverseNormal > 0.5) ? -input.normalOS : input.normalOS;
                float3 positionOS = CharacterInflateWidth(input.positionOS.xyz, inflateNormal, _InflateWidth);
                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);

                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInput.normalWS;
                float crossSign = float(input.tangentOS.w) * GetOddNegativeScale();
                output.tangentWS = float4(normalInput.tangentWS, crossSign);
                output.bitangentWS = normalInput.bitangentWS;
                output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

                output.positionNDC = ComputeScreenPos(output.positionCS);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    float3 vertexLight = AdditionalLightsVertex(output.positionWS.xyz, output.normalWS);
                    output.fogCoord = float4(fogFactor, vertexLight); //fogFactorAndVertexLight
                #else
                    output.fogCoord = float4(fogFactor, 0.0, 0.0, 0.0);
                #endif

                return output;
            }

            void InitializeInputData(Varyings input, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS.xyz;

                float3 viewDirWS = input.viewDirWS;
                viewDirWS = SafeNormalize(viewDirWS);
                inputData.viewDirectionWS = viewDirWS;

                inputData.normalWS.xyz = input.normalWS.xyz;

                inputData.shadowCoord = float4(0, 0, 0, 0);

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
                    inputData.vertexLighting = input.fogCoord.yzw;
                #else
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
                    inputData.vertexLighting = float3(0, 0, 0);
                #endif

                inputData.bakedGI = 1.0; //음영을 사용 안하도록

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = float4(1, 1, 1, 1);
            }

            float4 frag(Varyings input) : SV_Target
            {
                //-----------------------------------------------------------------------------
                // Diffuse
                //-----------------------------------------------------------------------------
                float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                float3 baseColor = baseMap.rgb;
                float alpha = baseMap.a;

                HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

                //-----------------------------------------------------------------------------
                // Initialize data
                //-----------------------------------------------------------------------------
                // Input data
                InputData inputData;
                InitializeInputData(input, inputData);

                // Light
                Light mainLight;
                LightingData lightingData;
                InitializeLightData(inputData, mainLight, lightingData);

                //-----------------------------------------------------------------------------
                // Process Color
                //-----------------------------------------------------------------------------
                float3 mainLightColor = saturate(lightingData.mainLightColor + lightingData.giColor);

                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(input.uv.xy + float2(0,-_Time.x), _BumpMap)));
                float3x3 tangentToWorld = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                float3 bumpNormal = TransformTangentToWorld(lerp(float3(0,0,1), normalTS, _BumpPower), tangentToWorld);

                float nDotV = 1-step(dot(bumpNormal, inputData.viewDirectionWS), _FresnelRange);
                float fresnelValue = (1.0 - nDotV) * _FresnelPower;
                float3 fresnelResult = mainLightColor * fresnelValue * _FresnelColor.rgb;

                //-----------------------------------------------------------------------------
                // Result
                //-----------------------------------------------------------------------------
                float3 lightColor = mainLightColor;
                float4 resultColor;
                resultColor.rgb = saturate(baseColor * lightColor * _TintColorIntensity);
                resultColor.rgb = lerp(resultColor.rgb, fresnelResult, fresnelValue);
                resultColor.rgb *= _Color.rgb;

                ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
                resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
                ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

                resultColor.a = saturate(alpha * _Color.a);

                return resultColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //--------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #undef _ALPHA_TEST

            #include "MMN_CharacterFX_TransparentGlow_Input.hlsl"
            #include "Includes/CharacterShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "MMN_CharacterFX_TransparentGlow_Input.hlsl"
            #include "Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
