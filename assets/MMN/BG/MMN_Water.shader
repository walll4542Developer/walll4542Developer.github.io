Shader "MMN/BG/Water"
{
    Properties
    {
        // [Space 50]
        // [Header(Water Color)]
        // [Space 50]

        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _ScatterColor1 ("Scatter Color 1", Color) = (0.5, 0.8, 1, 1)
        _ScatterColor2 ("Scatter Color 2", Color) = (0.06, 0.2, 0.4, 1)
        _ScatterColor3 ("Scatter Color 3", Color) = (0, 0.02, 0.07, 1)

        _ScatterDepth2 ("Depth for Scatter Color 2", float) = 1
        _ScatterDepth3 ("Depth for Scatter Color 3", float) = 1.6

        _Turbidity ("Turbidity", Range(0, 1)) = 0.5
        _DepthScale ("Depth Scale", float) = 1

        _FresnelColor ("Fresnel Color", Color) = (0.5764706, 0.6980392, 0.8000001, 1)
        _DistortionTexture ("DistortionTexture", 2D) = "black" { }

        _FoamColor ("Foam Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _FoamOpacity ("Foam Opacity", Range(0, 1)) = 1
        _FoamOffset ("Foam Offset", Range(-1, 1)) = 0.1
        _FoamEdgeIntensity ("Foam Edge Intensity", Range(0.0, 2.0)) = 0.0

        // [Space 50]
        // [Header(Move and Distortion)]
        // [Space 50]

        _FlowSpeed ("Flow Speed", float) = 1

        _DistortionAmount ("Distortion Amount", Range(0, 1)) = 1
        _BumpMap ("Normal Map ", 2D) = "bump" { }
        // [Space 50]
        // [Header(Specular Control)]
        // [Space 50]
        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecualrNormalMulti ("SpecularNormalMultiply", Range(1, 10)) = 1
        [PowerSlider(5.0)]_Glossiness ("Glossiness", Range(1, 256)) = 128
    }

    //LOD300
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-200" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "PreviewType" = "Plane" "ShaderModel" = "4.5" }
        LOD 200

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "Water" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            //--------------------------------------

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                float4 projectedPosition : TEXCOORD2;
                //half3 normalWS : TEXCOORD3;
                float4 normal : TEXCOORD3;    // xyz: normal, w: viewDir.x
                float4 tangent : TEXCOORD4;    // xyz: tangent, w: viewDir.y
                float4 bitangent : TEXCOORD5;    // xyz: bitangent, w: viewDir.z

                half fogFactor : TEXCOORD6;          // x: fogFactor
                float4 shadowCoord : TEXCOORD7;
                float4 screenPos : TEXCOORD8;

                half4 color : COLOR0;               // low-precision, 0–1 range data
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

            };

            float4 _FresnelColorGlobal;
            float _UseGlobalFresnel;

            CBUFFER_START(UnityPerMaterial)
                float4 _FresnelColor;
                float4 _ScatterColor1;
                float4 _ScatterColor2;
                float4 _ScatterColor3;
                half _ScatterDepth2;
                half _ScatterDepth3;
                half _Turbidity;
                float4 _FoamColor;
                half _FoamOpacity;
                half _FoamOffset;
                half _FoamEdgeIntensity;
                half _DepthScale;
                half _FlowSpeed;
                half _DistortionAmount;
                half _SpecualrNormalMulti;
                float _Glossiness;
                float4 _SpecColor;
                float4 _DistortionTexture_ST;
                float4 _BumpMap_ST;
                half _RaycastHarftoneClip;
            CBUFFER_END

            TEXTURE2D(_DistortionTexture);         SAMPLER(sampler_DistortionTexture);
            TEXTURE2D(_BumpMap);                   SAMPLER(sampler_BumpMap);

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.projectedPosition = vertexInput.positionNDC;
                output.positionCS = vertexInput.positionCS;

                output.normal = half4(normalInput.normalWS, viewDirWS.x);
                output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
                output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);

                output.color = input.color;
                output.fogFactor = fogFactor;

                output.shadowCoord = GetShadowCoord(vertexInput);
                output.screenPos = ComputeScreenPos(output.positionCS / output.positionCS.w);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {

                //플로우 UV와 텍스쳐
                float2 flowingUV = input.uv * 5.0 + float2(0.0, -1.0) * _Time.g / 30.0 * _FlowSpeed;
                float2 flowingUV2 = input.uv + float2(0.0, -1.0) * _Time.g / 42.0 * _FlowSpeed;
                float2 flowingUV3 = flowingUV.yx;

                float4 distortion = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV, _DistortionTexture));
                float4 distortion2 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV2, _DistortionTexture));
                float4 distortion3 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV3, _DistortionTexture));
                float distortionFactor = (distortion.r + distortion2.g * 0.4) / 1.4 * _DistortionAmount;


                //노말 + 디테일 노말 연산
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV, _BumpMap)), 1);
                half3 normalTS2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV2, _BumpMap)), 1);
                normalTS = normalize(float3(normalTS.rg + normalTS2.rg, normalTS.b * normalTS2.b) * float3(_DistortionAmount.xx, 1));


                //각 변수 계산해주기
                half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
                half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz)) ;
                normalWS = NormalizeNormalPerPixel(normalWS);
                viewDirWS = SafeNormalize(viewDirWS);


                // 프레넬
                //float3 viewDir = normalize(GetCameraPositionWS().xyz - input.positionWS.xyz);
                float sineThetaV = length(cross(normalWS, viewDirWS));
                float cosineThetaV = sqrt(1.0 - sineThetaV * sineThetaV);

                float reflectanceNought = 0.017;
                float reflectance = reflectanceNought + (1.0 - reflectanceNought) * pow((1.0 - cosineThetaV + distortionFactor / 5.0), 5.0);
                reflectance = saturate(reflectance);

                //스페큘러
                half3 normalWS4Specular = normalize(normalWS * half3(_SpecualrNormalMulti, 1, _SpecualrNormalMulti));
                Light mainLight = GetMainLight(input.shadowCoord);
                half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, normalWS4Specular, viewDirWS, 0.5, _Glossiness * 50);

                //리플렉션 프로브
                float3 reflectVec = reflect(-viewDirWS, normalWS);
                //reflectVec = normalize(reflectVec + (reflectance*0.25*float3(1,0,1))); //리플렉션 프로브를 흘러가는 텍스쳐로
                float3 Reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, 0), unity_SpecCube0_HDR);
                Reflectionprobe = saturate(Reflectionprobe);

                //Depth 계산합니다
                float rawDepth = SampleSceneDepth(input.projectedPosition.xy / input.projectedPosition.w);
                float sceneZ = LinearEyeDepth(rawDepth, _ZBufferParams);
                float thisZ = LinearEyeDepth(input.positionWS.xyz, GetWorldToViewMatrix());
                float waterDepth = max(0.0, sceneZ - thisZ);


                float scaledDepth = waterDepth / _DepthScale;
                if (unity_OrthoParams.w == 1)
                {
                    scaledDepth = 5;
                }
                float depthCoeff = 1.0 - pow(abs(_Turbidity), scaledDepth);

                //폼
                float foamDepth = max(0.5 - 3.0 * waterDepth, waterDepth + _FoamOffset);
                float foamDepthDistortion = (1.0 - (0.3 + distortion.r / 2.0 + distortion3.b / 5.0)) / (distortion2.g * 0.5 + 0.1);
                float drawFoam = (1 - saturate(pow(saturate(saturate(foamDepth) * foamDepthDistortion), 15.0)));
                float foamCoeff = drawFoam * _FoamOpacity;


                //벽쪽 얇은 폼
                // float2 foamEdgeFlowingUV = flowingUV + float2(0.5, -1.0) * _Time.g * 0.08 * _FlowSpeed;
                // float4 foamEdgeNoise = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, foamEdgeFlowingUV);
                // float foamEdgeWave = sin((_Time.y * _FlowSpeed * 0.94) - (distortion3.b * 1.84));
                // float foamEdge = ((foamEdgeWave * 0.5 + 0.5) * foamEdgeNoise.r * _FoamEdgeIntensity) / waterDepth;
                // foamEdge = saturate(pow(abs(foamEdge), 15.0) * 10.0) * _FoamOpacity;

                // foamCoeff += foamEdge;

                // float3 scatterColor1 = lerp(_ScatterColor1.rgb, float3(1.0, 1.0, 1.0), _Turbidity);
                float3 scatterColor1 = _ScatterColor1.rgb;
                float3 scatterColor = lerp(scatterColor1, _ScatterColor2.rgb, saturate(scaledDepth / _ScatterDepth2));
                scatterColor = lerp(scatterColor.rgb, _ScatterColor3.rgb, clamp((scaledDepth - _ScatterDepth2) / (_ScatterDepth3 - _ScatterDepth2), 0.0, 1.0));

                float3 fresnelColor = _FresnelColor.rgb;
                float3 reflectanceColor = lerp(scatterColor.rgb, fresnelColor.rgb * Reflectionprobe, reflectance);
                float4 color = float4(0, 0, 0, 0);
                color.rgb = lerp(reflectanceColor, _FoamColor.rgb, saturate(foamCoeff));

                //Light mainLight = GetMainLight();
                color.rgb *= input.color.rgb * mainLight.color * 1.5 ;
                specularColor *= _SpecColor.rgb ; //모바일에서 블룸을 강조하기 위해
                color.rgb += specularColor ;

                float opacity = saturate(foamCoeff + depthCoeff);
                opacity += Luminance(specularColor);

                //레이케스트 되면 사라지는 기능
                half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                //레인드롭 텍스쳐
                half3 color_Rain = color.rgb + MMN_GlobalTex_Raindrop(input.positionWS, normalWS) * 0.5;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);


                float4 fogCoord;
                fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);

                // ===============================================================================
                // ==                            Fog & CloudShadow Calc                         ==
                // ===============================================================================

                //하이트 포그  연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    input.positionWS, normalWS, fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    input.uv);

                float4 finalRGBA = real4(color.rgb, opacity);

                return (finalRGBA);
            }

            ENDHLSL
        }
    }


    //LOD100
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-200" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "PreviewType" = "Plane" "ShaderModel" = "4.5" }
        LOD 100
        Pass
        {
            Name "Base"
            Tags { "LightMode" = "Water" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 3.0

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                float4 projectedPosition : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
                float fogFactor : TEXCOORD6;          // x: fogFactor
                float4 screenPos : TEXCOORD8;
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

            };

            float4 _FresnelColorGlobal;
            float _UseGlobalFresnel;

            CBUFFER_START(UnityPerMaterial)
                float4 _ScatterColor1;
                float4 _ScatterColor2;
                float4 _ScatterColor3;
                float4 _FoamColor;
                float _ScatterDepth2;
                float _ScatterDepth3;
                float _Turbidity;
                float _DepthScale;
                float _RaycastHarftoneClip;
            CBUFFER_END

            TEXTURE2D(_DistortionTexture);         SAMPLER(sampler_DistortionTexture);

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.projectedPosition = vertexInput.positionNDC;
                output.positionCS = vertexInput.positionCS;

                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                output.fogFactor = fogFactor;
                output.screenPos = ComputeScreenPos(output.positionCS / output.positionCS.w);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half3 normalWS = NormalizeNormalPerPixel(input.normalWS);
                half3 viewDirWS = SafeNormalize(viewDirWS);

                //Depth 계산합니다
                float rawDepth = SampleSceneDepth(input.projectedPosition.xy / input.projectedPosition.w);
                float sceneZ = LinearEyeDepth(rawDepth, _ZBufferParams);
                float thisZ = LinearEyeDepth(input.positionWS.xyz, GetWorldToViewMatrix());
                float waterDepth = max(0.0, sceneZ - thisZ);

                float scaledDepth = waterDepth / _DepthScale;
                if (unity_OrthoParams.w == 1)
                {
                    scaledDepth = 5;
                }
                float depthCoeff = 1.0 - pow(abs(_Turbidity), scaledDepth);

                //3층 칼라 계산하기
                float3 scatterColor1 = saturate(_ScatterColor1.rgb + (0.5 * _FoamColor.rgb)); //경계에 흰 무늬 생기게 가장 얕은 곳에 경계칼라 0.5를 더한다
                float3 scatterColor = lerp(scatterColor1, _ScatterColor2.rgb, saturate(scaledDepth / _ScatterDepth2));
                scatterColor = lerp(scatterColor.rgb, _ScatterColor3.rgb, clamp((scaledDepth - _ScatterDepth2) / (_ScatterDepth3 - _ScatterDepth2), 0.0, 1.0));

                //칼라 선언
                float4 color = float4(0, 0, 0, 0);
                color.rgb = scatterColor.rgb;
                float opacity = depthCoeff;

                //레이케스트 되면 사라지는 기능
                half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                float4 fogCoord;
                fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);

                // ===============================================================================
                // ==                            Fog & CloudShadow Calc                         ==
                // ===============================================================================

                //하이트 포그  연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    input.positionWS, normalWS, fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    input.uv);

                float4 finalRGBA = real4(color.rgb, saturate(opacity + 0.1)); //물을 조금 불투명하게 해서 허전함을 속인다

                return finalRGBA;
            }

            ENDHLSL
        }
    }









    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_Water"
}
