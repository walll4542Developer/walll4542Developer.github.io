Shader "MMN/FX/ObjectDecal"
{
    Properties
    {
        [Header(Texture)]
        [Space(10)]
        [MainTexture] _BaseMap ("데칼 맵", 2D) = "white" {}
        [MainColor] _BaseColor ("베이스 틴트", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        [HDR] _EmissionColor ("이미션 색상", Color) = (0, 0, 0, 1)
        [NoScaleOffset] _EmissionMap ("이미션 마스크 맵", 2D) = "black" {}
        [Enum(Always, 0, NightOnly, 1, DayOnly, 2)] _Night2DayEnum ("언제 이미션이 켜지게 할까요?", Float) = 0

        [Header(Rendering Options)]
        [Space(10)]
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc("Blend Src", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst("Blend Dst", Float) = 10
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Z Test", Float) = 8

        [HideInInspector][NoScaleOffset] unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "Decal" }

            Blend [_BlendSrc] [_BlendDst]
            ZWrite Off
            ZTest [_ZTest]
            Cull Back
            ColorMask RGBA

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/CustomLighting.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/BlendingHelper.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/Night2DayControl.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;

                float3 normalWS : TEXCOORD0;    // xyz: normal
                float4 fogCoord : TEXCOORD1;    // x: fogFactor, yzw: vertexLighting

                float4 positionNDC : TEXCOORD2;

            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                float4 shadowCoord : TEXCOORD3;
            #endif

                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 4);
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_TexelSize;
            float4 _BaseMap_MipInfo;

            TEXTURE2D(_EmissionMap);
            SAMPLER(sampler_EmissionMap);

            CBUFFER_START( UnityPerMaterial )
                float4 _BaseMap_ST;
                float4 _BaseColor;

                float4 _EmissionColor;
                float _Night2DayEnum;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionNDC = vertexInput.positionNDC;

                // 데칼에서 노멀을 실제 모델의 노멀을 사용하면 큐브의 노멀을 사용하는 것이기 때문에
                // 정상적인 셰딩을 할 수 없다. 그래서 데칼은 바닥에 그려진다는 특성을 이용해서 y-up을 노멀로 사용한다.
                output.normalWS.xyz = float3(0.0, 1.0, 0.0);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
            #ifdef _ADDITIONAL_LIGHTS_VERTEX
                float3 vertexLight = MM_VertexLighting(vertexInput.positionWS.xyz, output.normalWS);
                output.fogCoord = float4(fogFactor, vertexLight); //fogFactorAndVertexLight
            #else
                output.fogCoord = float4(fogFactor, 0.0, 0.0, 0.0);
            #endif

            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = GetShadowCoord(vertexInput);
            #endif

                return output;
            }

            void InitializeInputData(Varyings input, float4 decalWorldPosition, out InputData inputData)
            {
                inputData = (InputData)0;

                // 데칼에서 월드 포지션을 실제 모델의 월드 포지션을 사용하면 큐브의 포지션을 사용하는 것이기 때문에
                // 정상적인 셰딩에 사용할 수 없다. 그래서 데칼을 그리는 면, 즉 뎁스에 의해 계산된 면의 포지션을 사용한다.
                inputData.positionWS = decalWorldPosition;
                inputData.normalWS = NormalizeNormalPerPixel(input.normalWS.xyz);

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
                    inputData.vertexLighting = half3(input.fogCoord.yzw);
                #else
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
                    inputData.vertexLighting = half3(0, 0, 0);
                #endif

                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = half4(1, 1, 1, 1);
            }

            half4 frag(Varyings input) : SV_Target
            {
                float4 positionNDC = input.positionNDC / input.positionNDC.w;
                positionNDC.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? positionNDC.z : positionNDC.z * 0.5 + 0.5;

                float2 decalUV = 0;
                float boundingBox = 1;
                float4 decalWorldPosition;
                ApplyScreenSpaceDecal(positionNDC, decalUV, boundingBox, decalWorldPosition);

                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, decalUV);
                float3 diffuse = baseMap.rgb * _BaseColor.rgb;
                float alpha = baseMap.a * boundingBox * _BaseColor.a;
                clip(boundingBox - 0.5); // 블렌드 모드가 알파 블렌드가 아닐 때를 위해 컷 오프시킴.

                float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, decalUV).rgb * _EmissionColor.rgb;

                // Emission 을 밤낮에 따라 켜지게 꺼지게 혹은 계속 유지하게 하는 기능
                #define NightOnly 1
                #define DayOnly 2

                if (_Night2DayEnum == NightOnly)
                {
                    emission *= abs(1 - _Global_Night2Day);
                }
                else if (_Night2DayEnum == DayOnly)
                {
                    emission *= _Global_Night2Day;
                }
                else
                {
                    emission = emission;
                }

                InputData inputData;
                InitializeInputData(input, decalWorldPosition, inputData);

                // 눈 내리기 처리
                diffuse.rgb = snowTextureLerp(inputData.positionWS.rgb, diffuse.rgb, inputData.normalWS.rgb, inputData.bakedGI);

                float4 resultColor;

                // Half Subtractive 라이팅
                float4 specularGloss = float4(0, 0, 0, 0);
                float smoothness = 0.0;
                float3 normalTS = float3(0, 0, 1);
                float shadowDimming = 0;
                float halfLambertWeight = 0.5;
                float _BackfaceReceiveShadowOff = 0;
                FRONT_FACE_TYPE isFacing = 0.0;
                float _BackFaceNormalturn = 0.0;

                #if HALF_SUBTRACTIVE_LIGHTMAP_ON
                    resultColor = UniversalFragmentLightCustomBaked(
                        inputData, diffuse, specularGloss, smoothness,
                        emission, alpha, normalTS, shadowDimming,
                        halfLambertWeight, _BackfaceReceiveShadowOff, isFacing,
                        _BackFaceNormalturn);
                #else
                    resultColor = UniversalFragmentLightCustom(
                        inputData, diffuse, specularGloss, smoothness,
                        emission, alpha, normalTS, shadowDimming,
                        halfLambertWeight, _BackfaceReceiveShadowOff, isFacing,
                        _BackFaceNormalturn);
                #endif

                // 비내리기 처리
                float3 rainColor = ((resultColor.rgb * resultColor.rgb) + resultColor.rgb) / 2.0;
                rainColor = rainColor.rgb + MMN_GlobalTex_Raindrop(inputData.positionWS, inputData.normalWS) * step(0.85, inputData.bakedGI).r * rainColor.rgb;
                resultColor.rgb = wetTextureLerp(inputData.positionWS, resultColor.rgb, rainColor.rgb);

                // 컨텍트 셰도우
                resultColor *= MMN_RecieveContactShadow(inputData.positionWS.rgb, inputData.shadowCoord);

                // 하이트 포그
                resultColor = MMN_GlobalTex_HeightFog(
                    resultColor,
                    inputData.positionWS, inputData.normalWS, inputData.fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    decalUV);

                resultColor.a = alpha;

                return resultColor;
            }
            ENDHLSL
        }
    }
    FallBack Off
}
