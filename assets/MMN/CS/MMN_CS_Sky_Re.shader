Shader "MMN/CutScene/Sky_Re"
{
    Properties
    {
        _StencilRef("Stencil Ref", Int) = 0
        //[Header(Used by Global Volume)]
        [HDR]_SkyColorTop("Top스카이칼라", Color) = (0.5,0.5,1.0)
		[HDR]_SkyColorMiddle("Middle스카이칼라", Color) = (0.5,0.5,0.5)
		[HDR]_SkyColorBottom("Bottom스카이칼라(원경포그)", Color) = (0,0,0)

        _SkyPosition4 ("Top칼라 높은 위치", float) = 0.8
        _SkyPosition3 ("Top칼라 낮은 위치", float) = 0.5
        _SkyPosition2 ("Bottom칼라 높은 위치", float) = 0.4
        _SkyPosition1 ("Bottom칼라 낮은 위치", float) = 0

		[HideInInspector]_SunDisk("태양 크기", Range(0.04,0.5)) = 0.5
		[HideInInspector]_SunGlowDisk("태양 글로우 크기 ", Range(0.04,10)) = 0.5
        [HideInInspector][HDR]_SunGlowColor("태양 글로우 칼라(조명색과도 연동됨)", color) = (1,1,1,1)
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Background"
            "Queue" = "Background"
            "PreviewType" = "Skybox"
        }

        Cull Off
        ZWrite Off

        Stencil
        {
            Ref [_StencilRef]
            Comp Equal
            Pass Keep
        }

        Pass
        {
            Name "Base"
            HLSLPROGRAM
            #pragma target 4.5
            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options assumeuniformscaling maxcount:50 nolightprobe nolightmap

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float3 uv : TEXCOORD0;
                half fogCoord : TEXCOORD1;          // x: fogFactor
                float3 positionWS : TEXCOORD2;
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position
            };

            // 글로벌 변수
            float4 _Global_VertexPositionOffset;

			CBUFFER_START(UnityPerMaterial)

				float4 _SkyColorTop;
				float4 _SkyColorMiddle;
				float4 _SkyColorBottom;

				float _SkyPosition1;
				float _SkyPosition2;
				float _SkyPosition3;
				float _SkyPosition4;

				half _SunDisk;
				half _SunGlowDisk;
                float4 _SunGlowColor;

            CBUFFER_END

            TEXTURE2D(_MainTex);
            TEXTURE2D(_MainTex2);
            TEXTURE2D(_MainTex3);
            TEXTURE2D(_MainTex4);
            TEXTURE2D(_Clouds);
            TEXTURE2D(_Clouds2);
            TEXTURE2D(_Clouds3);
            TEXTURE2D(_Star1);

            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_MainTex2);
            SAMPLER(sampler_MainTex3);
            SAMPLER(sampler_MainTex4);
            SAMPLER(sampler_Clouds);
            SAMPLER(sampler_Clouds2);
            SAMPLER(sampler_Clouds3);
            SAMPLER(sampler_Star1);

            float2 ToRadialCoords(float3 coords)
            {
                float3 normalizedCoords = normalize(coords);
                float latitude = acos(normalizedCoords.y);
                float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
                float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / PI, 1.0 / PI);
                return float2(0.5, 1.0) - sphereCoords;
            }

            float3 RotateAroundYInDegrees(float3 positionOS, float degrees)
            {
                float alpha = DegToRad(degrees);
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
               return float3(mul(m, positionOS.xz), positionOS.y ).xzy;
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
				output.positionCS = TransformObjectToHClip(input.positionOS.rgb);
                output.positionCS.z = 0;
                output.uv = input.positionOS.xyz;

                // 카메라 룩 방향에 따라 배경이 휘어지는데, 스카이도 어느 정도 영향받게 한다.
                float3 cameraForwardVector = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
				output.uv.y += cameraForwardVector.y * _Global_VertexPositionOffset.z*0.05;

                output.fogCoord.x = ComputeFogFactor(output.positionCS.z);
				output.positionWS = TransformObjectToWorld(input.positionOS.rgb); // 사실 OS로 해도 되지만 또 사람 마음이 정석을 추구하는지라
                return output;
            }

			// Calculates the sun shape. 태양 디스크 연산. 레거시에서 이식해 온걸 개조함
			half3 calcSunAttenuation(half3 lightPos, half3 ray, half3 lightcolor)
			{
				half3 delta = lightPos - ray;
				half dist = length(delta);
				half spot = max(0, 1.0 - smoothstep(0.0, _SunDisk, dist));
				half glow = max(0, 1.0 - smoothstep(0.0, _SunGlowDisk, dist));
				return (pow(spot,20)  + pow(glow ,10) * 0.1 ) * lightcolor.rgb * _SunGlowColor.rgb *10 ;
			}

            half4 frag(Varyings input) : SV_Target
            {
				//sky Color Calc
				float skyColormask1 = smoothstep(_SkyPosition3, _SkyPosition4, input.uv.y);
				float skyColormask2 = smoothstep(_SkyPosition1, _SkyPosition2, input.uv.y);
				float4 skyGradColor = lerp(_SkyColorMiddle, _SkyColorTop, skyColormask1 * skyColormask1);
                skyGradColor = lerp(_SkyColorBottom, skyGradColor, skyColormask2);

				//sundisk draw
				Light light = GetMainLight();
				half3 direction = light.direction;
				half3 ray = normalize(input.positionWS.xyz);
				half3 sundirection = normalize(direction);
				half3 sundisk = calcSunAttenuation(sundirection, ray , light.color) ;

                half3 finalColor = skyGradColor.rgb + sundisk.rgb;
				half4 finalResult = half4(finalColor, 1.0);

                //return fogHeightBottom;
                return finalResult;
            }

            ENDHLSL
        }
    }

    Fallback Off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SkyGUI"
}
