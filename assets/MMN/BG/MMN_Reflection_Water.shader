Shader "MMN/Special/PlanerReflectionWater"
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
        // [Space 50]
        // [Header(NormalMap)]
        // [Space 50]

        // [Space 50]
        // [Header(Form)]
        // [Space 50]

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


        [Header(Reflection Options)]
        [Space(10)]
        [NoScaleOffset] _PlanarReflectionTexture ("리플렉션 텍스쳐(수정 금지)", 2D) = "Black" { }
        _ReflectionColor ("리플렉션 컬러", Color) = (1, 1, 1, 1)
        _ReflectionPower ("리플렉션 거리 조절", Range(1, 50)) = 10
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-200" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "PreviewType" = "Plane" "ShaderModel" = "4.5" }
        LOD 300
        ZClip False


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
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/bendingVertex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;

                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                float4 projectedPosition : TEXCOORD2;
                //float3 normalWS : TEXCOORD3;
                float4 normal : TEXCOORD3;    // xyz: normal, w: viewDir.x
                float4 tangent : TEXCOORD4;    // xyz: tangent, w: viewDir.y
                float4 bitangent : TEXCOORD5;    // xyz: bitangent, w: viewDir.z

                float fogFactor : TEXCOORD6;          // x: fogFactor
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     float4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light
                // #else
                //     float fogFactor : TEXCOORD6;
                // #endif

                float4 shadowCoord : TEXCOORD7;
                float4 screenPos : TEXCOORD8;

                float4 color : COLOR0;               // low-precision, 0–1 range data
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            float4 _FresnelColorGlobal;
            float _UseGlobalFresnel;

            CBUFFER_START(UnityPerMaterial)
                float4 _FresnelColor;
                float4 _ScatterColor1;
                float4 _ScatterColor2;
                float4 _ScatterColor3;
                float _ScatterDepth2;
                float _ScatterDepth3;
                float _Turbidity;
                float4 _FoamColor;
                float _FoamOpacity;
                float _FoamOffset;
                float _FoamEdgeIntensity;
                float _DepthScale;
                float _FlowSpeed;
                float _DistortionAmount;
                float _SpecualrNormalMulti;
                float _Glossiness;
                float4 _SpecColor;
                float4 _DistortionTexture_ST;
                float4 _BumpMap_ST;
                float _RaycastHarftoneClip;
                float4 _ReflectionColor;
                float _ReflectionPower;
            CBUFFER_END

            TEXTURE2D(_DistortionTexture);         SAMPLER(sampler_DistortionTexture);
            TEXTURE2D(_BumpMap);                   SAMPLER(sampler_BumpMap);
            TEXTURE2D(_PlanarReflectionTexture);       SAMPLER(sampler_PlanarReflectionTexture);

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                //카메라 바라보는 각도에 따라 버텍스 휘어짐
                // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                //float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.projectedPosition = vertexInput.positionNDC;
                output.positionCS = vertexInput.positionCS;

                output.normal = float4(normalInput.normalWS, viewDirWS.x);
                output.tangent = float4(normalInput.tangentWS, viewDirWS.y);
                output.bitangent = float4(normalInput.bitangentWS, viewDirWS.z);
                //output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                output.color = input.color;
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                //     output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);
                // #else
                    output.fogFactor = fogFactor;
                // #endif

                output.shadowCoord = GetShadowCoord(vertexInput);
                output.screenPos = ComputeScreenPos(output.positionCS);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //플로우 UV와 텍스쳐
                float2 flowingUV = input.uv * 5.0 + float2(0.0, -1.0) * _Time.g / 30.0 * _FlowSpeed;
                float2 flowingUV2 = input.uv + float2(0.0, -1.0) * _Time.g / 42.0 * _FlowSpeed;
                float2 flowingUV3 = flowingUV.yx;

                float4 distortion = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV, _DistortionTexture));
                float4 distortion2 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV2, _DistortionTexture));
                float4 distortion3 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV3, _DistortionTexture));
                float distortionFactor = (distortion.r + distortion2.g * 0.4) / 1.4 * _DistortionAmount;

                //노말 + 디테일 노말 연산
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV, _BumpMap)), 1);
                float3 normalTS2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV2, _BumpMap)), 1);
                normalTS = normalize(float3(normalTS.rg + normalTS2.rg, normalTS.b * normalTS2.b) * float3(_DistortionAmount.xx, 1));

                //각 변수 계산해주기
                float3 viewDirWS = float3(input.normal.w, input.tangent.w, input.bitangent.w);
                float3 normalWS = TransformTangentToWorld(normalTS, float3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz)) ;
                normalWS = NormalizeNormalPerPixel(normalWS);
                viewDirWS = SafeNormalize(viewDirWS);
                float3 viewSpaceNormal = normalize(mul((float3x3)UNITY_MATRIX_MV, normalWS));
                float2 screenSpaceNormal = (viewSpaceNormal.xy / viewSpaceNormal.z) * 0.5 + 0.5;

                //프레넬
                float rim = saturate(1 - dot(input.normal.xyz, viewDirWS));//플렛한 노말의 림
                float rim4ReflectionProbe = rim * rim * rim * rim * rim * rim;
                float rim4PlanerReflection = pow(rim, _ReflectionPower);

                //스페큘러
                float3 normalWS4Specular = normalize(normalWS * float3(_SpecualrNormalMulti, 1, _SpecualrNormalMulti));
                Light mainLight = GetMainLight(input.shadowCoord);
                float3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                float3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, normalWS4Specular, viewDirWS, 0.5, _Glossiness * 50);

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
                //scaledDepth = saturate(scaledDepth);
                float depthCoeff = 1.0 - pow(abs(_Turbidity), scaledDepth);

                //폼
                float foamDepth = max(0.5 - 3.0 * waterDepth, waterDepth + _FoamOffset);
                float foamDepthDistortion = (1.0 - (0.3 + distortion.r / 2.0 + distortion3.b / 5.0)) / (distortion2.g * 0.5 + 0.1);
                float drawFoam = (1 - saturate(pow(saturate(saturate(foamDepth) * foamDepthDistortion), 15.0)));
                float foamCoeff = drawFoam * saturate(_FoamOpacity -  thisZ/200);

                //리플렉션 프로브
                float3 reflectVec = reflect(-viewDirWS, normalWS);
                float reflectionProbeLodBias = (1.0 - _Glossiness / 256) ;
                float3 reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, reflectionProbeLodBias), unity_SpecCube0_HDR);
                reflectionprobe = saturate(reflectionprobe);

                // 물 색상 합쳐서 하나로 만들기
                float3 scatterColor1 = _ScatterColor1.rgb;
                float3 scatterColor = lerp(scatterColor1, _ScatterColor2.rgb, saturate(scaledDepth / _ScatterDepth2));
                scatterColor = lerp(scatterColor.rgb, _ScatterColor3.rgb, clamp((scaledDepth - _ScatterDepth2) / (_ScatterDepth3 - _ScatterDepth2), 0.0, 1.0));

                // 플래너 리플렉션 기능
                float2 screenUV = input.screenPos.xy / (input.screenPos.w + 0.0001);
                screenUV += float2((screenSpaceNormal.x - 0.5) * 0.1, 0);
                float3 planarReflectionColor = SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, screenUV, 0).rgb; //밉맵이 안생기는군요
                float3 planarReflectionResult = planarReflectionColor * _ReflectionColor.rgb;

                //변수 초기화
                float4 color = float4(0, 0, 0, 0);
                float opacity = 1;

                //반사 합성
                float3 fresnelColor = _FresnelColor.rgb;
                float3 reflectionProbeColor = lerp(scatterColor.rgb, fresnelColor.rgb * reflectionprobe, rim4ReflectionProbe);
                float3 planerReflectionColor = lerp(reflectionProbeColor.rgb, _ReflectionColor.rgb * planarReflectionResult.rgb, rim4PlanerReflection);

                //파도 폼과 합성
                color.rgb = lerp(planerReflectionColor, _FoamColor.rgb, saturate(foamCoeff));

                //조명과 스페큘러
                float powerdDepthCoeff = depthCoeff * depthCoeff;//알파를 진하게해서 끊어내기 위함

                color.rgb *= input.color.rgb * mainLight.color * 1.5 ;
                specularColor *= _SpecColor.rgb ; //모바일에서 블룸을 강조하기 위해
                color.rgb += specularColor * powerdDepthCoeff;
                opacity = saturate(foamCoeff + depthCoeff);
                opacity = saturate(opacity + (Luminance(specularColor) * powerdDepthCoeff));
                opacity =saturate(opacity + thisZ/300 ); //카메라 Far 거리에 알파가 잘려 보이지 않기 위해

                //레이케스트 되면 사라지는 기능
                // float RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                // clip(RaycasthalftoneAlpha - 0.1);

                //fog calc =============================================================
                float noisevalue;
                float3 withFogColor;
                Unity_SimpleNoise_float(input.positionWS.xz + _Time.y * _Global_FogHeightNoiseSpeed, _Global_FogHeightNoiseScale, noisevalue);
                //y is height
                float y = saturate(input.positionWS.y / 100 - _Global_FogHeightOffset -noisevalue * _Global_FogHeightNoiseValue);
                float fogHeightBottom = saturate(y * _Global_FogHeightScale);
                float fogHeightTop = saturate(-y * _Global_FogHeightScale);
                float fogHeight = max(fogHeightBottom, fogHeightTop);


                //레인드롭 텍스쳐
                float3 color_Rain = color.rgb + MMN_GlobalTex_Raindrop(input.positionWS, normalWS) * 0.1;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);


                //Fog Initialize . inputData로 Initialize하는데가 없어서 여기에 수동으로 추가. 그런데 버텍스 라이트를 안 사용함..
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                // #else
                    float4 fogCoord;
                fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
                // #endif

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

                float4 finalRGBA = float4(color.rgb, opacity);
                return (finalRGBA);
            }

            ENDHLSL
        }
    }

    // ===============================================================================
    // ==             중 이하 옵션에서는 플레너 리플렉션이 빠집니다                  ==
    // ===============================================================================


    //LOD 100
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent-200" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True" "PreviewType" = "Plane" "ShaderModel" = "4.5" }
        LOD 100
        ZClip False

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "Water" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex vert
            #pragma fragment frag


            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/bendingVertex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;

                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                float4 projectedPosition : TEXCOORD2;
                //float3 normalWS : TEXCOORD3;
                float4 normal : TEXCOORD3;    // xyz: normal, w: viewDir.x
                float4 tangent : TEXCOORD4;    // xyz: tangent, w: viewDir.y
                float4 bitangent : TEXCOORD5;    // xyz: bitangent, w: viewDir.z

                float fogFactor : TEXCOORD6;          // x: fogFactor
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     float4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light
                // #else
                //     float fogFactor : TEXCOORD6;
                // #endif

                float4 shadowCoord : TEXCOORD7;
                float4 screenPos : TEXCOORD8;

                float4 color : COLOR0;               // low-precision, 0–1 range data
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            float4 _FresnelColorGlobal;
            float _UseGlobalFresnel;

            CBUFFER_START(UnityPerMaterial)
                float4 _FresnelColor;
                float4 _ScatterColor1;
                float4 _ScatterColor2;
                float4 _ScatterColor3;
                float _ScatterDepth2;
                float _ScatterDepth3;
                float _Turbidity;
                float4 _FoamColor;
                float _FoamOpacity;
                float _FoamOffset;
                float _FoamEdgeIntensity;
                float _DepthScale;
                float _FlowSpeed;
                float _DistortionAmount;
                float _SpecualrNormalMulti;
                float _Glossiness;
                float4 _SpecColor;
                float4 _DistortionTexture_ST;
                float4 _BumpMap_ST;
                float _RaycastHarftoneClip;
                float4 _ReflectionColor;
            CBUFFER_END

            TEXTURE2D(_DistortionTexture);         SAMPLER(sampler_DistortionTexture);
            TEXTURE2D(_BumpMap);                   SAMPLER(sampler_BumpMap);
            TEXTURE2D(_PlanarReflectionTexture);       SAMPLER(sampler_PlanarReflectionTexture);

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                //카메라 바라보는 각도에 따라 버텍스 휘어짐
                // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                //float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.projectedPosition = vertexInput.positionNDC;
                output.positionCS = vertexInput.positionCS;

                output.normal = float4(normalInput.normalWS, viewDirWS.x);
                output.tangent = float4(normalInput.tangentWS, viewDirWS.y);
                output.bitangent = float4(normalInput.bitangentWS, viewDirWS.z);
                //output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);

                output.color = input.color;
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                //     output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);
                // #else
                    output.fogFactor = fogFactor;
                // #endif

                output.shadowCoord = GetShadowCoord(vertexInput);
                output.screenPos = ComputeScreenPos(output.positionCS);

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //플로우 UV와 텍스쳐
                float2 flowingUV = input.uv * 5.0 + float2(0.0, -1.0) * _Time.g / 30.0 * _FlowSpeed;
                // float2 flowingUV2 = input.uv + float2(0.0, -1.0) * _Time.g / 42.0 * _FlowSpeed;
                // float2 flowingUV3 = flowingUV.yx;

                float4 distortion = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV, _DistortionTexture));
                float4 distortion2 = distortion;
                float4 distortion3 = distortion;
                // float4 distortion2 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV2, _DistortionTexture));
                // float4 distortion3 = SAMPLE_TEXTURE2D(_DistortionTexture, sampler_DistortionTexture, TRANSFORM_TEX(flowingUV3, _DistortionTexture));

                //노말 + 디테일 노말 연산
                // float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV, _BumpMap)), 1);
                // float3 normalTS2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(flowingUV2, _BumpMap)), 1);
                // normalTS = normalize(float3(normalTS.rg + normalTS2.rg, normalTS.b * normalTS2.b) * float3(_DistortionAmount.xx, 1));

                //각 변수 계산해주기
                float3 viewDirWS = float3(input.normal.w, input.tangent.w, input.bitangent.w);
                // float3 normalWS = TransformTangentToWorld(normalTS, float3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz)) ;
                float3 normalWS = NormalizeNormalPerPixel(input.normal.xyz);
                viewDirWS = SafeNormalize(viewDirWS);
                // float3 viewSpaceNormal = normalize(mul((float3x3)UNITY_MATRIX_MV, normalWS));
                // float2 screenSpaceNormal = (viewSpaceNormal.xy / viewSpaceNormal.z) * 0.5 + 0.5;

                //프레넬
                float rim = saturate(1 - dot(input.normal.xyz, viewDirWS));//플렛한 노말의 림
                float rim4ReflectionProbe = rim * rim * rim * rim * rim * rim;
                float rim4PlanerReflection = pow(rim, 30);

                //스페큘러
                // float3 normalWS4Specular = normalize(normalWS * float3(_SpecualrNormalMulti,1,_SpecualrNormalMulti));
                // Light mainLight = GetMainLight(input.shadowCoord);
                // float3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                // float3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, normalWS4Specular, viewDirWS, 0.5, _Glossiness * 50);

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
                //scaledDepth = saturate(scaledDepth);
                float depthCoeff = 1.0 - pow(abs(_Turbidity), scaledDepth);

                //폼
                float foamDepth = max(0.5 - 3.0 * waterDepth, waterDepth + _FoamOffset);
                float foamDepthDistortion = (1.0 - (0.3 + distortion.r / 2.0 + distortion3.b / 5.0)) / (distortion2.g * 0.5 + 0.1);
                float drawFoam = (1 - saturate(pow(saturate(saturate(foamDepth) * foamDepthDistortion), 15.0)));
                float foamCoeff = drawFoam *saturate(_FoamOpacity -  thisZ/200);

                //리플렉션 프로브
                float3 reflectVec = reflect(-viewDirWS, normalWS);
                float reflectionProbeLodBias = (1.0 - _Glossiness / 256) ;
                float3 reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, reflectionProbeLodBias), unity_SpecCube0_HDR);
                reflectionprobe = saturate(reflectionprobe);

                // 물 색상 합쳐서 하나로 만들기
                // float3 scatterColor1 = _ScatterColor1.rgb;
                // float3 scatterColor = lerp(scatterColor1, _ScatterColor2.rgb, saturate(scaledDepth / _ScatterDepth2));
                // scatterColor = lerp(scatterColor.rgb, _ScatterColor3.rgb, clamp((scaledDepth - _ScatterDepth2) / (_ScatterDepth3 - _ScatterDepth2), 0.0, 1.0));
                float3 scatterColor = _ScatterColor3.rgb;

                // 플래너 리플렉션 기능
                // float2 screenUV = input.screenPos.xy / (input.screenPos.w + 0.0001);
                // screenUV += float2((screenSpaceNormal.x - 0.5) * 0.1,0);
                // float reflectionMapLodBias = (1.0 - _Glossiness) * 8;
                // float3 planarReflectionColor = SAMPLE_TEXTURE2D_LOD(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, screenUV, reflectionMapLodBias).rgb;
                // float3 planarReflectionResult = planarReflectionColor * _ReflectionColor.rgb;

                //변수 초기화
                float4 color = float4(0, 0, 0, 0);
                float opacity = 1;

                //반사 합성
                float3 fresnelColor = _FresnelColor.rgb;
                float3 reflectionProbeColor = lerp(scatterColor.rgb, fresnelColor.rgb * reflectionprobe, rim4ReflectionProbe);
                //    float3 planerReflectionColor = lerp(reflectionProbeColor.rgb, _ReflectionColor * planarReflectionResult.rgb , rim4PlanerReflection);

                //파도 폼과 합성
                color.rgb = lerp(reflectionProbeColor, _FoamColor.rgb, saturate(foamCoeff));

                //조명과 스페큘러
                Light mainLight = GetMainLight();
                color.rgb *= input.color.rgb * mainLight.color * 1.5 ;
                // specularColor *= _SpecColor.rgb ; //모바일에서 블룸을 강조하기 위해
                // color.rgb += specularColor ;
                opacity = saturate(foamCoeff + depthCoeff);
                opacity = saturate(opacity + thisZ/200); //카메라 Far 거리에 알파가 잘려 보이지 않기 위해 
                // opacity += Luminance(specularColor);

                //레이케스트 되면 사라지는 기능
                // float RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                // clip(RaycasthalftoneAlpha - 0.1);

                //fog calc =============================================================
                float noisevalue;
                float3 withFogColor;
                Unity_SimpleNoise_float(input.positionWS.xz + _Time.y * _Global_FogHeightNoiseSpeed, _Global_FogHeightNoiseScale, noisevalue);
                //y is height
                float y = saturate(input.positionWS.y / 100 - _Global_FogHeightOffset -noisevalue * _Global_FogHeightNoiseValue);
                float fogHeightBottom = saturate(y * _Global_FogHeightScale);
                float fogHeightTop = saturate(-y * _Global_FogHeightScale);
                float fogHeight = max(fogHeightBottom, fogHeightTop);


                //레인드롭 텍스쳐 //너무 무늬가 보여서 일단 제외
                // float3 color_Rain = color.rgb + MMN_GlobalTex_Raindrop(input.positionWS, normalWS) * 0.5;
                // color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);


                //Fog Initialize . inputData로 Initialize하는데가 없어서 여기에 수동으로 추가. 그런데 버텍스 라이트를 안 사용함..
                // #ifdef _ADDITIONAL_LIGHTS_VERTEX
                //     fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                // #else
                    float4 fogCoord;
                fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
                // #endif

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

                float4 finalRGBA = float4(color.rgb, opacity);
                return (finalRGBA);
            }

            ENDHLSL
        }
    }
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_Reflection_Water"
}
