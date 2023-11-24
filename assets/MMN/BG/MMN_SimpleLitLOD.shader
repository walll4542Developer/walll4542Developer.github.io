Shader "MMN/BG/SimpleLitLOD"
{
    Properties
    {
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0
        [Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0
        [HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }
        [Enum(Always, 0, NightOnly, 1, DayOnly, 2)] _Night2DayEnum ("언제 Emission이 켜지게 할까요", float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 200

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "MMN_SimpleLitInput.hlsl"
            // #include "MMN_SimpleLitForwardPass.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float3 normalWS : TEXCOORD2;
                float fogFactor : TEXCOORD3;
                float4 vertexSH : TEXCOORD7;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
            };

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
                inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);
                inputData.viewDirectionWS = viewDirWS;
                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
                inputData.bakedGI = SAMPLE_GI(/* input.staticLightmapUV */1, input.vertexSH.rgb, inputData.normalWS);
                #if defined(DEBUG_DISPLAY)
                    inputData.vertexSH = input.vertexSH;
                #endif
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // VertexShader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                output.fogFactor = fogFactor;

                return output;
            }

            // Fragment shader
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {

                float2 uv = input.uv;
                float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                
                //틴트칼라와 버텍스 칼라
                half3 tintProp = _BaseColor.rgb;
                half tintStrengthProp = _AlbedoTintStrength;
                half3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));
                half alpha = 1;

                //버텍스칼라 디버깅
                #ifdef _SHOWVERTEXCOLOR_ON
                    return half4(saturate(abs(input.color.rgb)), 1);
                #endif

                #ifdef _SHOWVERTEXALPHA_ON
                    return half4(saturate(abs(input.color.aaa)), 1);
                #endif

                half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;

                //Emission 을 밤낮에 따라 켜지게 꺼지게 혹은 계속 유지하게 하는 기능
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
                InitializeInputData(input, /* normalTS */ half3(0, 0, 1), inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);
                
                //라이팅
                half4 color = 0;
                color = UniversalFragmentLightCustomLOD(inputData, diffuse, /* specular */0, /* smoothness */0, emission, /* alpha */1, /* normalTS */ half3(0, 0, 1));

                //비내리는 텍스쳐 전환
                half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
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

                color.a = 1; //간혹 특정기기에서 번쩍거리는 현상 방지를 위한 강제 코드
                return color;
            }
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

            //-------------------------------------
            // Material Keywords
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define VERTEX_CAMERA_DEPEND_BENDING 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "MMN_SimpleLitInput.hlsl"
            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    
    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitGUI_LOD"
}
