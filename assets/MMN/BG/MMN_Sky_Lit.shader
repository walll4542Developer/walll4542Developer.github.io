Shader "MMN/BG/Sky_Lit"
{
    Properties
    {
        // [Toggle]_ALPHATEST ("알파테스트", float) = 0
        // [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        // _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0
        // _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }
    }

    SubShader
    {
        Tags { "Queue" = "Transparent-399" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300
        ZClip False

        Pass
        {
            Name "SkyLit"
            Tags { "LightMode" = "SkyLit" }
            // Use same blending / depth states as Standard shader
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            blend One Zero

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            // #pragma multi_compile_fragment _ DEBUG_DISPLAY
            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1
            #define LIGHT_LAMBERT 1

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            //GlobalVariables
            // half _Global_CloudDensity;
            // half _Global_CloudSpeed;
            // half _Global_CloudScale;
            // half _Global_CloudEdgeHardness;
            // half _Global_Night2Day;

            #include "../Includes/bendingVertex.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseMap_ST;
                half4 _BaseColor;
                half _AlbedoTintStrength;
                half _Surface;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
                half4 color : COLOR;
                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float4 normalWS : TEXCOORD2;    // xyz: normal, w: viewDir.x
                float4 tangentWS : TEXCOORD3;    // xyz: tangent, w: viewDir.y
                float4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
                #else
                    half fogFactor : TEXCOORD5;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    half4 shadowCoord : TEXCOORD6;
                #endif

                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

                half4 screenPos : TEXCOORD8;
                // float cameraDistance                : TEXCOORD9; //@TODO 이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
                half4 color : COLOR;
                half4 positionCS : SV_POSITION;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                //NORMALMAP
                half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                inputData.tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);

                inputData.viewDirectionWS = viewDirWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
                inputData.vertexLighting = half3(0, 0, 0);

                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

                // #if defined(DEBUG_DISPLAY)
                //     #if defined(LIGHTMAP_ON)
                //         inputData.staticLightmapUV = input.staticLightmapUV;
                //     #else
                //         inputData.vertexSH = input.vertexSH;
                //     #endif

                // #endif

            }

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_TRANSFER_INSTANCE_ID(input, output);
                // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                //카메라 바라보는 각도에 따라 버텍스 휘어짐
                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS ;
                output.positionCS.z = 0;

                //NORMALMAP
                half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);

                output.color = input.color;
                // output.screenPos = ComputeScreenPos(output.positionCS);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                output.fogFactor = fogFactor;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif

                return output;
            }

            // Used for StandardSimpleLighting shader
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half2 uv = input.uv;
                half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                half3 tintProp = _BaseColor.rgb;
                half tintStrengthProp = _AlbedoTintStrength;
                half3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp);
                //* saturate(input.color.rgb + (1 - _VertexColorWeight));
                half alpha = diffuseAlpha.a * _BaseColor.a;
                half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));

                InputData inputData;
                InitializeInputData(input, normalTS, inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, uv, _BaseMap);

                //라이트 각도가 정오(해가 높을수록)가 될수록 붉은 색을 칠한 부분의 노말이 하늘을 바라본다
                Light light = GetMainLight();
                float lightDir2Y = saturate(dot(light.direction, float3(0, 1, 0)));
                lightDir2Y = smoothstep(0.5, 1, lightDir2Y);
                inputData.normalWS = lerp(inputData.normalWS, float3(0, 1, 0), lightDir2Y);
                inputData.normalWS = normalize(inputData.normalWS);

                half4 color = UniversalFragmentLightCustom(inputData, diffuse, /* specular */0, /* smoothness */0, /* emission */0, alpha, normalTS, /*구름그림자를 안받게한다*/ 1, /*RampY*/0, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

                //하이트 포그  연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    input.positionWS, inputData.normalWS, inputData.fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale * 0.5,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed * 0.1,
                    _Global_FogHeightNoiseScale * 0.1,
                    uv);

                //원본 포그 연산
                //color.rgb =  MixFog(color.rgb, inputData.fogCoord);
                clip(alpha - 0.5);
                color.a = alpha;

                if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
                return 0;
                else
                    return color;
            }
            ENDHLSL
        }
    }

    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitGUI"

}
