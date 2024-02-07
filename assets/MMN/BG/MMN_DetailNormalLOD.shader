// 노말맵을 안쓰지만 디테일노말입니다. 원래 쓰던건데 개조하다 보니 안쓰게 됨
Shader "MMN/BG/DetailNormalLOD"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        //셰이더 셋업
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0

        //셰이더 조절
        [MainColor] _BaseColor ("Base Tint 틴트칼라", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength 베이스맵 틴트 강도", Range(-1.0, 1.0)) = 0.0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        //메인 텍스쳐
        [MainTexture] _BaseMap ("Base Map (RGB) SpecularMask (A)", 2D) = "white" { }
        //디테일맵. 돌산의 퇴적 줄무늬 등을 만들때 사용한다
        _DetailMap ("DetailMap (RGB) Blending (A)", 2D) = "black" { }
        [Toggle]_DetailMapYenable ("DetailMapYenable", float) = 0

        [HDR]_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [PowerSlider(3)]_Glossiness ("Glossiness", Range(0.01, 10)) = 0.8

        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }

        //2nd 맵. 노말의 Y 에만 나온다
        [Toggle] _SECONDMAP ("UseSecondMap (WorldNormal Y)", float) = 0
        _SecondMap ("SecondMap", 2D) = "white" { }
        _SecondMapOffset ("SecondMapOffset", float) = 0
        _SecondMapScale ("SecondMapScale", Range(0, 1)) = 1
        _SecondMapBlendHardness ("SecondMapBlendHardness", Range(0, 0.5)) = 0.25
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore d3d9
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            // -------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_local_fragment _ _SECONDMAP_ON
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1
            #define LIGHT_SPECULAR 1

            #include "MMN_DetailNormal_Input.hlsl"
            // #include "MMN_DetailNormal_ForwardPass.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"
            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                half4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                half3 normalWS : TEXCOORD2;
                half fogFactor : TEXCOORD3;
                float4 vertexSH : TEXCOORD7;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
            };

            void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
                inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);
                inputData.viewDirectionWS = viewDirWS;
                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
                inputData.vertexLighting = half3(0, 0, 0);
                inputData.bakedGI = SAMPLE_GI(/* input.staticLightmapUV */1, input.vertexSH.rgb, inputData.normalWS);
                #if defined(DEBUG_DISPLAY)
                    inputData.vertexSH = input.vertexSH;
                #endif
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = input.texcoord;
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                output.fogFactor = fogFactor;

                return output;
            }


            // Used for StandardSimpleLighting shader
            float4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 uv = input.uv;
                float4 diffuseAlpha = SampleAlbedoAlpha(TRANSFORM_TEX(uv, _BaseMap), TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                half3 diffuse = diffuseAlpha.rgb;
                half alpha = diffuseAlpha.a * _BaseColor.a;

                //알파 테스트 기능
                #if defined(_ALPHATEST_ON)
                    clip(alpha - _Cutoff);
                #endif

                //텍스쳐 연산
                float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
                float4 specular = _SpecColor * diffuseAlpha.a;
                float smoothness = _Glossiness ;

                InputData inputData;
                InitializeInputData(input, /* normalTS */float3(0, 0, 1), inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //디테일 맵 섞기
                float3 posWS4Detail = input.positionWS * 0.1;
                float4 detailXY = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.xy, _DetailMap));
                float4 detailZY = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.zy, _DetailMap));
                float4 detailXZ = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.xz, _DetailMap));
                float4 detailMap = lerp(detailXY, detailZY, abs(inputData.normalWS.r));
                detailMap = lerp(detailMap, detailXZ, abs(inputData.normalWS.g) * _DetailMapYenable);
                diffuse = lerp(diffuse, detailMap.rgb, detailMap.a);

                //버텍스 칼라는 첫 번째 맵에만 적용
                diffuse *= saturate(input.color.rgb + (1 - _VertexColorWeight));

                //버텍스 칼라만 임시로 보는 기능
                #ifdef _SHOWVERTEXCOLOR_ON
                    return float4(saturate(abs(input.color.rgb)), 1);
                #endif


                //세컨드 텍스쳐를 노말 Y 방향으로 더할 때 활성화. 따로 인클루드로 뺄까도 생각해 봤지만 여기에서밖에 안쓰이므로 일단 존재
                #if _SECONDMAP_ON
                    // 세컨드 텍스쳐 사용
                    float secondTextureMask = 0;
                    float vertexAlphaMask = 0;

                    secondTextureMask = saturate(inputData.normalWS.y - _SecondMapOffset) ;
                    secondTextureMask = pow(secondTextureMask, _SecondMapScale);
                    //float sp = saturate(step(0.5, t * secondMap.a + t));

                    vertexAlphaMask = 1 - input.color.a;
                    secondTextureMask += pow(saturate(vertexAlphaMask), _SecondMapScale);

                    // 세컨드 텍스쳐를 구해서 연산한다
                    // float4 secondMap = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(uv, _SecondMap));
                    float4 secondMapXY = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.xy, _SecondMap));
                    float4 secondMapZY = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.zy, _SecondMap));
                    float4 secondMapXZ = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.xz, _SecondMap));
                    float4 secondMap = lerp(secondMapXY, detailZY, abs(inputData.normalWS.r));
                    secondMap = lerp(secondMap, secondMapXZ, abs(inputData.normalWS.g));

                    float secondMapMask = saturate(smoothstep(_SecondMapBlendHardness, 1 - _SecondMapBlendHardness, secondTextureMask + secondTextureMask));
                    diffuse.rgb = lerp(diffuse.rgb, secondMap.rgb, secondMapMask);

                    //스페큘러가 2nd 텍스쳐에서는 고정되게
                    alpha = lerp(alpha, secondMap.a, secondMapMask);
                #endif

                //전역적으로 틴트칼라 적용하기
                float3 tintProp = _BaseColor.rgb;
                float tintStrengthProp = _AlbedoTintStrength;
                diffuse = TextureTintBlend(diffuse.rgb, tintProp, tintStrengthProp);

                //리플렉션 프로브. 스페큘러 마스킹으로 마스킹된다
                float3 reflectionProbe = LightingReflectionProbe(inputData.viewDirectionWS, inputData.normalWS, _Glossiness);
                emission += reflectionProbe * alpha * _SpecColor.rgb * _Global_GILightMulti.rgb;

                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);

                //라이팅
                half4 color = 0;
                color = UniversalFragmentLightCustomLOD(inputData, diffuse, specular, smoothness, emission, /* alpha */1, /* normalTS */ half3(0, 0, 1));

                //레인텍스쳐 only 레인 드롭 애니메이션은 삭제
                half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

                //하이트 포그  연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    input.positionWS, inputData.normalWS, inputData.fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    uv);

                return color;
            };


            ENDHLSL
        }


        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_local_fragment _ _NEARHALFTONECLIP_ON

            #define VERTEX_CAMERA_DEPEND_BENDING 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 0
            #define LODFADE 0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_DetailNormal_Input.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_DetailNormalGUI_LOD"
}
