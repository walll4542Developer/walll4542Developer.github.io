Shader "MMN/BG/Waterfall"
{
    Properties
    {
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0
        [Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0

        _ScatterColor2 ("Scatter Color 2", Color) = (0.06, 0.2, 0.4, 1)

        _Turbidity ("Turbidity", Range(0, 1)) = 0.5
        _FresnelColor ("Fresnel Color", Color) = (0.5764706, 0.6980392, 0.8000001, 1)

        _VertexFlowSpeed ("버텍스 플로우 스피드", float) = 3
        _VertexFlowCrmpled ("버텍스 플로우 구겨짐", Range(0, 1)) = 0.3

        _DistortionTexture ("DistortionTexture", 2D) = "black" { }
        _FoamColor ("Foam Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _FoamOpacity ("Foam Opacity", Range(0, 1)) = 1
        _FoamOffset ("Foam Offset", Range(-1, 1)) = 0.1
        _FlowSpeed ("Flow Speed", float) = 1

        _BumpMap ("Normal Map ", 2D) = "bump" { }
        _DistortionAmount ("Distortion Amount", Range(0, 1)) = 1

        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider(5.0)]_Glossiness ("Glossiness", Range(1, 256)) = 128
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-200" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "PreviewType" = "Plane" "ShaderModel" = "4.5" }

        Pass
        {
            Name "Base"

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options assumeuniformscaling maxcount:50 nolightprobe nolightmap //??
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/bendingVertex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;

                // UNITY_VERTEX_INPUT_INSTANCE_ID

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

                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            float4 _FresnelColorGlobal;
            float _UseGlobalFresnel;

            CBUFFER_START(UnityPerMaterial)
                half _VertexFlowSpeed;
                half _VertexFlowCrmpled;
                float4 _ScatterColor2;
                half _Turbidity;
                float4 _FresnelColor;
                float4 _FoamColor;
                half _FoamOpacity;
                half _FoamOffset;
                half _FlowSpeed;
                half _DistortionAmount;
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

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);


                float2 flowingUV = input.texcoord.xy * 5.0 + float2(0.0, -1.0) * _Time.z * _VertexFlowSpeed;
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D_LOD(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV, _BumpMap), 0), 1).rgb;

                // vertex transform
                // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz); //원본백업
                VertexPositionInputs vertexInput;

                vertexInput.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                vertexInput.positionWS.x += normalTS.r * _VertexFlowCrmpled * (1 - input.color.r);
                vertexInput.positionWS.z += normalTS.g * _VertexFlowCrmpled * (1 - input.color.r);
                vertexInput.positionVS = TransformWorldToView(vertexInput.positionWS);
                vertexInput.positionCS = TransformWorldToHClip(vertexInput.positionWS);

                float4 ndc = vertexInput.positionCS * 0.5f;
                vertexInput.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
                vertexInput.positionNDC.zw = vertexInput.positionCS.zw;


                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                //half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.projectedPosition = vertexInput.positionNDC;
                output.positionCS = vertexInput.positionCS;

                output.normal = half4(normalInput.normalWS, viewDirWS.x);
                output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
                output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);
                //output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                output.color = input.color; //r굴곡g포말b투명a음영
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                //     output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                // #else
                    output.fogFactor = fogFactor;
                // #endif

                output.shadowCoord = GetShadowCoord(vertexInput);
                output.screenPos = ComputeScreenPos(output.positionCS / output.positionCS.w);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //버텍스칼라 디버깅
                #ifdef _SHOWVERTEXCOLOR_ON
                    return float4(saturate(abs(input.color.rgb)), 1);
                #endif

                #ifdef _SHOWVERTEXALPHA_ON
                    return float4(saturate(abs(input.color.aaa)), 1);
                #endif


                //플로우 UV와 텍스쳐
                float2 flowingUV = input.uv * 5.0 + float2(0.0, -1.0) * _Time.g / 30.0 * _FlowSpeed;
                float2 flowingUV2 = input.uv + float2(0.0, -1.0) * _Time.g / 42.0 * _FlowSpeed;
                // float2 flowingUV3 = flowingUV.yx;

                float4 distortion = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV, _DistortionTexture));
                float4 distortion2 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV2, _DistortionTexture));
                // float4 distortion3 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV3, _DistortionTexture));
                float distortionFactor = (distortion.r + distortion2.g * 0.4) / 1.4 * _DistortionAmount;

                // return distortion2;


                //노말 + 디테일 노말 연산
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV, _BumpMap)), 1);
                half3 normalTS2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV2, _BumpMap)), 1);
                normalTS = normalize(float3(normalTS.rg + normalTS2.rg, normalTS.b * normalTS2.b) * float3(_DistortionAmount.xx, 1));

                // return float4(normalTS.xxx, 1);


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
                float reflectance = reflectanceNought + (1.0 - reflectanceNought) * pow((1.0 - cosineThetaV + distortionFactor / 5.0), 6.0);
                reflectance = saturate(reflectance);

                //스페큘러
                Light mainLight = GetMainLight(input.shadowCoord);
                half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, normalWS, viewDirWS, 0.5, _Glossiness * 50);

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

                float scaledDepth = waterDepth ;
                if (unity_OrthoParams.w == 1)
                {
                    scaledDepth = 5;
                }
                //scaledDepth = saturate(scaledDepth);
                float depthCoeff = 1.0 - pow(abs(_Turbidity), scaledDepth);

                //폼
                float foamDepth = max(0.5 - 3.0 * waterDepth, waterDepth + _FoamOffset);
                float foamDepthDistortion = (1.0 - (0.3 + distortion.r / 2.0 + distortion.b / 5.0)) / (distortion2.g * 1 + 0.1);
                float drawFoam = (1 - saturate(pow(saturate(saturate(foamDepth) * foamDepthDistortion * input.color.g), 15.0)));
                float foamCoeff = drawFoam * _FoamOpacity ;

                float3 scatterColor = _ScatterColor2.rgb;

                float3 fresnelColor = _FresnelColor.rgb;
                float3 reflectanceColor = lerp(scatterColor.rgb, fresnelColor.rgb * Reflectionprobe, reflectance);
                float4 color = float4(0, 0, 0, 0);
                color.rgb = lerp(reflectanceColor, _FoamColor.rgb, saturate(foamCoeff));

                //Light mainLight = GetMainLight();
                color.rgb *= mainLight.color * input.color.a;
                specularColor *= _SpecColor.rgb ; //모바일에서 블룸을 강조하기 위해
                color.rgb += specularColor ;

                float opacity = saturate(foamCoeff + depthCoeff);
                opacity += Luminance(specularColor);

                //레이케스트 되면 사라지는 기능
                half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                //fog calc =============================================================
                float noisevalue;
                float3 withFogColor;
                Unity_SimpleNoise_float(input.positionWS.xz + _Time.y * _Global_FogHeightNoiseSpeed, _Global_FogHeightNoiseScale, noisevalue);
                //y is height
                float y = saturate(input.positionWS.y / 100 - _Global_FogHeightOffset -noisevalue * _Global_FogHeightNoiseValue);
                half fogHeightBottom = saturate(y * _Global_FogHeightScale);
                half fogHeightTop = saturate(-y * _Global_FogHeightScale);
                half fogHeight = max(fogHeightBottom, fogHeightTop);


                //레인드롭 텍스쳐 : 폭포는 세로로 떨어지니까 이게 필요 없을 것 같아서.
                // half3 color_Rain = color.rgb + MMN_GlobalTex_Raindrop(input.positionWS, normalWS) * 0.5;
                // color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);


                //Fog Initialize . inputData로 Initialize하는데가 없어서 여기에 수동으로 추가. 그런데 버텍스 라이트를 안 사용함..
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                // #else
                    float4 fogCoord;
                fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
                // #endif


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

                float4 finalRGBA = real4(color.rgb, opacity * input.color.b);

                return (finalRGBA);
            }

            ENDHLSL
        }
    }
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_WaterFallGUI"
}
