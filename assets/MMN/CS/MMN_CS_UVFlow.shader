Shader "MMN/CutScene/UVFlow"
{
    Properties
    {

        [Header(Textures)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        [NoScaleOffset]_NoiseMap ("노이즈 맵", 2D) = "Black" {}
        _SecondMap ("용 그림자", 2D) = "white" {}
        _Color ("용 그림자 틴트 컬러", Color) = (1.0, 1.0, 1.0, 1.0)
        _UVFlowSpeed ("플로우 속도", Range(0.0, 10.0)) = 1
        _UVFlowPower ("플로우 강도", Range(0.0, 1.0)) = 0.05 // 구름
        // [IntRange]_NoiseSize ("노이즈 해상도", Range(1.0, 1000.0)) = 100
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            ZTest LEqual
            Cull back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Includes/BendingVertex.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "MMN_CS_UVFlow_Input.hlsl"

            struct Attributes
            {
                float4 color : COLOR;
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;

                float2 texcoord : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 color : COLOR;
                float4 positionCS : SV_POSITION; // Homogeneous clip space position

                float2 uv : TEXCOORD0;

                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;

                float3 positionWS : TEXCOORD4;   // World space position
                float3 positionOS : TEXCOORD5;   // Object space position

                float3 viewDirWS : TEXCOORD6;

                float3 vertexSH : TEXCOORD7;

                float fogCoord : TEXCOORD8;       // x: fogFactor

                float4 screenPos : TEXCOORD9;

                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.color = input.color;

                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInput.normalWS;
                output.tangentWS = normalInput.tangentWS;
                output.bitangentWS = normalInput.bitangentWS;

                output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

                output.vertexSH = SampleSHVertex(output.normalWS.xyz);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                output.fogCoord.x = fogFactor;

                output.screenPos = ComputeScreenPos(output.positionCS);
                output.positionOS = input.positionOS.xyz;

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

                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord);
                inputData.vertexLighting = float3(0, 0, 0);

                inputData.bakedGI = SampleSHPixel(input.vertexSH, inputData.normalWS);

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = float4(1, 1, 1, 1);
            }

            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float time = _Time.y;

                float uvFlowSpeed = _UVFlowSpeed * time;
                _UVFlowPower *= 0.1;

                float2 uv;
                uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, frac(float2(uv.x, uv.y + uvFlowSpeed)));
                float4 noiseMap = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, frac(float2(uv.x, uv.y + uvFlowSpeed)));

                uv = TRANSFORM_TEX(input.uv.xy, _SecondMap);

                float4 secondMap = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, uv + noiseMap.rg * _UVFlowPower - _UVFlowPower );
                secondMap *= _Color;

                float3 result = lerp(baseMap.rgb, _Color.rgb, secondMap.a);

                float3 baseColor = baseMap.rgb;
                float alpha = baseMap.a;

                float4 resultColor = 1;

                resultColor.rgb = result;
                resultColor.a = alpha;

                return resultColor;
            }
            ENDHLSL
        }
    }
}

