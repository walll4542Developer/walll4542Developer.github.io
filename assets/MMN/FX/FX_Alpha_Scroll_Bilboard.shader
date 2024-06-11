//최종 컬러 값 = 텍스쳐 컬러 * 인게임 라이트 컬러 * 1.6의 컬러가 출력되며, 알파 값은 메인 텍스쳐와 알파 텍스쳐의 곱으로 계산된다.
//메인텍스쳐의 uv가 _Time.x * _SteamSpeed의 수치로 흐른다.
//ZWrite On, Cull Off

Shader "MM/FX/Alpha_Scroll_Billboard"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _AlphaTex ("Alpha Texture", 2D) = "white" {}
        _SteamSpeed ("Steam Speed", Float) = 1.0

        [Header(Billboard Options)]
        [KeywordEnum(Unity, Max)] _UpAxis ("Axis Type", Float) = 0.0
        [KeywordEnum(Free, Y)] _UpVectorFixed ("Up-Vector Fixed Mode", Float) = 0.0
        [KeywordEnum(Pivot, Bottom)] _RotationPivot ("Rotation Pivot", Float) = 0.0
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
            ZWrite On
            Cull Off

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile __ _UPAXIS_UNITY _UPAXIS_MAX
            #pragma multi_compile __ _UPVECTORFIXED_FREE _UPVECTORFIXED_Y
            #pragma multi_compile __ _ROTATIONPIVOT_PIVOT _ROTATIONPIVOT_BOTTOM

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

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                float3 normalWS : TEXCOORD2;      // World space position
                float fogCoord : TEXCOORD3;      // x: fogFactor

                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
                float4 _MainTex_ST;

                TEXTURE2D(_AlphaTex);
                SAMPLER(sampler_AlphaTex);
                float4 _AlphaTex_ST;

                float _SteamSpeed;
            CBUFFER_END


            void BillboardVert(inout Attributes input)
            {
                float4x4 objectToWorld = GetObjectToWorldMatrix();
                float4x4 worldToView = GetWorldToViewMatrix();

                // 오브젝트 스케일 적용
                input.positionOS.xy *= float2(length(objectToWorld._m00_m10_m20), length(objectToWorld._m01_m11_m21));

                // 카메라 방향 가져오고
                float3 right = normalize(worldToView._m00_m01_m02);
                float3 up = float3(0.0, 1.0, 0.0);
            #ifdef _UPVECTORFIXED_FREE
                up = normalize(worldToView._m10_m11_m12);
            #endif
                float3 forward = -normalize(worldToView._m20_m21_m22);

                // 카메라를 바라볼 수 있도록 회전행렬을 만들고
                float4x4 rotationMatrix;
            #ifdef _UPAXIS_MAX
                rotationMatrix = float4x4(
                    -up,           0.0,
                    forward,       0.0,
                    right,         0.0,
                    0.0, 0.0, 0.0, 1.0);
            #else
                rotationMatrix = float4x4(
                    right,         0.0,
                    up,            0.0,
                    forward,       0.0,
                    0.0, 0.0, 0.0, 1.0);
            #endif

                // 회전의 기준축(pivot)을 Quad 메시의 바닥으로 하기 위해서 내려주는데
                // 아래와 같은 식이 만족하려면 Quad 메시의 기준축이 바닥이 아닌 정 중앙이어야 한다.
                // 만약 Quad 메시의 기준축이 바닥이면 아래 식을 안써도 되는데 재질에서 On, Off 하려면 어쩔 수 없다.
            #ifdef _ROTATIONPIVOT_PIVOT
                input.positionOS = mul(input.positionOS, rotationMatrix);
            #elif defined(_ROTATIONPIVOT_BOTTOM)
                float height = distance(0.0, input.positionOS.y);
                input.positionOS.y += height;
                input.positionOS = mul(input.positionOS, rotationMatrix);
                input.positionOS.y -= height;
            #endif

                input.positionOS.xyz = mul((float3x3)GetWorldToObjectMatrix(), input.positionOS.xyz);
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                BillboardVert(input);

                output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.fogCoord.x = ComputeFogFactor(output.positionCS.z);

                return output;
            }

            real4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                float2 flowUV = input.uv - float2(0, frac(_Time.x * _SteamSpeed));

                real4 textureColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, flowUV);
                real alpha = SAMPLE_TEXTURE2D(_AlphaTex, sampler_AlphaTex, input.uv).r;

                real3 finalColor = textureColor.rgb;

                // 빛 적용 여부
                Light mainLight = GetMainLight();
                finalColor.rgb *= mainLight.color.rgb * 1.6;

                real4 finalRGBA = real4(finalColor, (textureColor.a * alpha));

                finalRGBA = MMN_GlobalTex_HeightFog(
                    finalRGBA,
                    input.positionWS, input.normalWS, float4(input.fogCoord, 0, 0, 0),
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    input.uv);

                return finalRGBA;
            }

            ENDHLSL
        }
    }
}
