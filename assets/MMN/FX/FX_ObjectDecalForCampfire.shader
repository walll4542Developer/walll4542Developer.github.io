Shader "MMN/FX/ObjectDecalForCampFire"
{
    Properties
    {
        _CampFireLightPositionWS ("_CampFireLightPositionWS", Vector) = (0, 0, 0, 0)
        _CampFireLightColor ("_CampFireLightColor", Color) = (1, 1, 1, 1)
        _CampFireLightIntensity ("_CampFireLightIntensity", Float) = 1
        _CampFireLightRange ("_CampFireLightRange", Float) = 1
    }

    SubShader
    {
        LOD 100
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "CampFireDecal" }

            Blend SrcColor One
            ZWrite Off
            ZTest Always
            Cull Front

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_ObjectDecalForCampfire.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float4 positionNDC : TEXCOORD1;
            };

            CBUFFER_START( UnityPerMaterial )
                float4 _CampFireLightPositionWS;
                float4 _CampFireLightColor;
                float _CampFireLightIntensity;
                float _CampFireLightRange;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;
                output.positionNDC = vertexInput.positionNDC;

                // NOTE @jihun.song: 캠프파이어의 데칼의 모양은 스피어 모양이라서 스피어의 노멀을 그대로 사용한다.
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            void InitializeInputData(Varyings input, float4 decalWorldPosition, out InputData inputData)
            {
                inputData = (InputData)0;

                // 데칼에서 월드 포지션을 실제 모델의 월드 포지션을 사용하면 큐브의 포지션을 사용하는 것이기 때문에
                // 정상적인 셰딩에 사용할 수 없다. 그래서 데칼을 그리는 면, 즉 뎁스에 의해 계산된 면의 포지션을 사용한다.
                inputData.positionWS = decalWorldPosition.xyz;
                inputData.normalWS = NormalizeNormalPerPixel(input.normalWS.xyz);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = float4(1, 1, 1, 1);
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 positionNDC = input.positionNDC / input.positionNDC.w;
                positionNDC.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? positionNDC.z : positionNDC.z * 0.5 + 0.5;

                float2 decalUV = 0;
                float boundingBox = 1;
                float4 decalWorldPosition;
                ApplyScreenSpaceDecal(positionNDC, decalUV, boundingBox, decalWorldPosition);

                InputData inputData;
                InitializeInputData(input, decalWorldPosition, inputData);

                float4 resultColor = AdditionalLightForDecal(
                    inputData.normalWS, decalWorldPosition.xyz,
                    _CampFireLightPositionWS, _CampFireLightIntensity, _CampFireLightRange, _CampFireLightColor);
                resultColor.a *= boundingBox;

                return resultColor;
            }
            ENDHLSL
        }
    }

    FallBack Off
}
