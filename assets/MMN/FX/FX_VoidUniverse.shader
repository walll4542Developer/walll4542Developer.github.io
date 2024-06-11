Shader "MMN/FX/VoidUniverse"
{
    Properties
    {
        [Header(Texture)]
        [Space(10)]
        [NoScaleOffset] [MainTexture] _BaseMap ("베이스 맵", 2D) = "white" {}
        _UniverseUVScale ("베이스 맵 UV 스케일", Range(1.0, 5.0)) = 2.0

        [Header(Silhouette Options)]
        [Space(10)]
        [NoScaleOffset] _SilhouetteMap ("실루엣 맵", 2D) = "white" {}
        _SilhouetteUVScale ("실루엣 맵 UV 스케일", Range(1.0, 20.0)) = 2.0
        _SilhouetteColor ("실루엣 색상", Color) = (0.21, 0.37, 0.53, 1.0)
        _SilhouetteThickness ("실루엣 두께", Range(0.0, 1.0)) = 0.25
        _SilhouetteAnimSpeed ("실루엣 애니메이션 속도", Range(0.0, 30.0)) = 12.0
        _SilhouetteInnerGlowBase ("실루엣 안쪽 베이스", Range(-1.0, 1.0)) = 0.25
        _SilhouetteInnerGlowSharpness ("실루엣 안쪽 날카로움", Range(0.0, 10.0)) = 0.8
        _SilhouetteEdgeBase ("실루엣 가장자리 베이스", Range(-1.0, 1.0)) = 0.35
        _SilhouetteEdgeSharpness ("실루엣 가장자리 날카로움", Range(0.0, 10.0)) = 5.0
    }

    Subshader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Blend One Zero
            ZWrite On
            ZTest LEqual
            Cull Back
            ColorMask RGBA

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
            // Vertex and Fragment

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
			};

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_TexelSize;
            float4 _BaseMap_MipInfo;

            TEXTURE2D(_SilhouetteMap);
            SAMPLER(sampler_SilhouetteMap);

            CBUFFER_START( UnityPerMaterial )
                float4 _BaseMap_ST;

                float _UniverseUVScale;
                float _SilhouetteUVScale;

                float4 _SilhouetteColor;
                float _SilhouetteThickness;
                float _SilhouetteAnimSpeed;

                float _SilhouetteInnerGlowBase;
                float _SilhouetteInnerGlowSharpness;

                float _SilhouetteEdgeBase;
                float _SilhouetteEdgeSharpness;
            CBUFFER_END

            Varyings vert (Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = vertexInput.positionCS;

                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                output.uv = TRANSFORM_TEX(input.texcoord.xy, _BaseMap) * 6.0;

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float4 resultColor;

                // Texcoord
                float2 uv = input.uv;

                // Fresnel
                float3 positionWS = input.positionWS;
                float3 normalWS = input.normalWS;

                float3 viewDirWS = normalize(GetCameraPositionWS() - positionWS);
                float nDotV = dot(normalize(normalWS), viewDirWS);

                // Universe Texture
                float2 screenRatio = _ScreenParams.xy / min(_ScreenParams.x, _ScreenParams.y);
                float2 screenUV = (input.positionCS.xy / _ScreenParams.xy - float2(0.5, 0.5)) * screenRatio;

                float2 universeUV = screenUV * _UniverseUVScale + float2(0.5, 0.5);
                float4 universeTexColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, universeUV);

                // Noise (Silhouette)
                float2 silhouetteUV = screenUV * _SilhouetteUVScale + float2(0.5, 0.5);
                float3 silhouetteTexColor = SAMPLE_TEXTURE2D(_SilhouetteMap, sampler_SilhouetteMap, silhouetteUV).rgb;

                float time = frac(_Time.x * _SilhouetteAnimSpeed);
                float3 weightRGB = float3(
                    saturate(abs(time * 3.0 - 1.5) - 0.5),
                    saturate(-abs(time * 3.0 - 1.0) + 1.0),
                    saturate(-abs(time * 3.0 - 2.0) + 1.0)
                );

                float noise = dot(silhouetteTexColor, weightRGB);

                // Silhouette
                float rimThickness = _SilhouetteThickness * 2 - 1;
                float rim = 1 - saturate(nDotV) + rimThickness;
                float contourHeight = noise + rim * 2.0 - 1.0;

                float silhouetteInnerGlow = saturate((rim + _SilhouetteInnerGlowBase) * _SilhouetteInnerGlowSharpness);
                float silhouetteEdge = saturate((contourHeight + _SilhouetteEdgeBase) * _SilhouetteEdgeSharpness);
                float silhouetteBias = saturate(contourHeight * 100.0);

                // Composite
                resultColor.rgb = lerp(universeTexColor.rgb, _SilhouetteColor.rgb, silhouetteBias);
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
    Fallback Off
}
