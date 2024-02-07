Shader "MM/FX/FX_TEST_Particle_Smoke_Alpha2"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _MaskTex ("MaskTex", 2D) = "white" {}

        _TextureLevel ("Texture Level", Float) = 10.0
        _Intensive ("Intensive", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50 nolightprobe nolightmap

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float rotateDeg : TEXCOORD1;
                float cutOut : TEXCOORD2;
                real4 color : COLOR;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float rotateDeg : TEXCOORD1;
                float cutOut : TEXCOORD2;
                float3 positionWS : TEXCOORD3;      // World space position
                float3 normalWS : TEXCOORD4;      // World space position
                half fogCoord : TEXCOORD5;      // x: fogFactor
                half cameraDistance : TEXCOORD6;

                real4 color : COLOR0;               // low-precision, 0–1 range data
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;

                TEXTURE2D(_MaskTex);
                SAMPLER(sampler_MaskTex);
                float4 _MaskTex_ST;

                float _TextureLevel;
                float _Intensive;
            CBUFFER_END


            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.rotateDeg = input.rotateDeg;
                output.cutOut = input.cutOut;

                output.color = input.color;
                output.cameraDistance = distance(GetCameraPositionWS(), positionWS);
                output.fogCoord.x = ComputeFogFactor(output.positionCS.z);

                return output;
            }

            real4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                real4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

                float rotateCos = cos(DegToRad(input.rotateDeg.x));
                float rotateSin = sin(DegToRad(input.rotateDeg.x));

                float2 uvPivot = float2(0.5, 0.5);
                float2x2 rotationMatrix = float2x2(rotateCos, -rotateSin, rotateSin, rotateCos);
                float2 rotateUVs = mul(input.uv - uvPivot, rotationMatrix) + uvPivot;
                real4 maskTextureColor = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, TRANSFORM_TEX(rotateUVs, _MaskTex));

                real3 finalColor = textureColor.rgb * input.color.rgb * _Intensive;

                float fadeInFactor = saturate(maskTextureColor.r - input.cutOut.x);
                float finalAlpha = saturate(fadeInFactor * _TextureLevel * (1.0 - maskTextureColor.r)) * textureColor.a * input.color.a;

                real4 finalRGBA = real4(finalColor, finalAlpha);

                finalRGBA = MMN_GlobalTex_HeightFog(
                    finalRGBA,
                    input.positionWS, input.normalWS, float4(input.fogCoord, 0, 0, 0),
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    input.uv);

                //카메라에 근접시 투명하게 만들어 줍니다.
                float cameraDistance = input.cameraDistance / 5;
                finalRGBA.a *= saturate(pow(abs(cameraDistance), 10));

                return finalRGBA;
            }

            ENDHLSL
        }
    }
}
