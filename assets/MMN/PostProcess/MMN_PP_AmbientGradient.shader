Shader "MMN/PP/AmbientGradient"
{
    Properties
    {
        [HideInInspector]_MainTex ("MainTex", 2D) = "black" { }
        //볼륨에서 메터리얼을 컨트롤하면서 프로퍼티가 잠겨서 값이 안들어갑니다.
        //아래 155번 줄에서 상수로 입력합시다.

        [Header(LightSideControl)]
        [Toggle]_LightSidePreviewToggle ("밝은 부분만 미리보기", float) = 1
        [HideInInspector] _DayLightSideColor ("낮의 밝은 부분 칼라 가중치", color) = (0.3, 0.20, 0.15, 1)
        // _NightLightSideColor ("밤의 밝은 부분 칼라 가중치", color) = (0.25, 0.20, 0.3, 1)
        // [HideInInspector]_LightSideInvBrightArea2 ("밝은 부분 위치 바이어스", Range(1, 2)) = 1
        // [HideInInspector] _LightSideInvDarkArea ("밝은 부분 경계 부드럽게", Range(0, 5)) = 4

        [Header(DarkSideControl)]

        [Toggle]_DarkSidePreviewToggle ("어두운 부분만 미리보기", float) = 0
        [HideInInspector] _DayDarkSideColor ("낮의 어두운 부분 칼라 가중치", color) = (0, 0, 0, 1)
        // _NightDarkSideColor ("밤의 어두운 부분 칼라 가중치", color) = (0.5, 0.5, 0.5, 1)
        // [HideInInspector]_DarkSideInvBrightArea ("밝은 부분 위치 바이어스", Range(0, 2)) = 0.2
        // [HideInInspector]_DarkSideInvDarkArea ("어두운 부분 경계 부드럽게", Range(0, 5)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 cameraDir : TEXCOORD1;
                float3 cameraDirX : TEXCOORD2;
                float3 cameraDirY : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                // float _LightSidePreviewToggle;
                // float _DarkSidePreviewToggle;
                float4 _DayLightSideColor;
                // float4 _NightLightSideColor;
                float4 _DayDarkSideColor;
                // float4 _NightDarkSideColor;
                // float _LightSideInvBrightArea2;
                // float _LightSideInvDarkArea;
                // float _DarkSideInvBrightArea;
                // float _DarkSideInvDarkArea;
            CBUFFER_END

            // @myeongsoo.jeong 2024-04-11 [NOTE]
            // AmbientGradientSetter.cs 참고
            float _Global_Night2Day;

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.cameraDir = normalize(mul((float3x3)unity_CameraToWorld, float3(0, 0, 1)));
                OUT.cameraDirX = normalize(mul((float3x3)unity_CameraToWorld, float3(1, 0, 0)));
                OUT.cameraDirY = normalize(mul((float3x3)unity_CameraToWorld, float3(0, 1, 0)));
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            //Linear Gradient https://www.shadertoy.com/view/MtlBWX 대명님이 알려주심
            //두 점 사이의 그라디언트를 그린다. b는 태양과의 거리. a 는 0.5인데 반대로 밀 수 있게 해 놓음
            float LinearGradient(float3 sundir, float2 screenPos, float power, float invBrightArea, float invDarkArea)
            {
                float2 b = sundir.xy * invBrightArea; // 클수록 밝은쪽이 밀려간다
                float2 a = float2(0.5, 0.5) - sundir.xy * invDarkArea; //클수록 어두운쪽이 밀려난다(좁아진다)

                float2 uv = screenPos;

                float2 ab = b - a ;
                float2 ap = uv - a;
                float len = length(ab);

                float t = clamp(dot(ab, ap) / len / len, 0, 1);
                float gradientcolor = saturate(lerp(0, 1, t));
                gradientcolor = pow(gradientcolor, power); //변칙감마. 어두움 파워를 조절
                return gradientcolor;
            }

            float SimpleRadialGradient(float3 sundir, float2 screenPos, float invBrightArea, float invDarkArea)
            {
                float2 sunPosRel = sundir.xy - float2(0.5, 0.5);
                float2 sunPos = sunPosRel * invBrightArea;
                float2 oppSunPos = -sunPosRel * invDarkArea;

                float2 uv = screenPos - float2(0.5, 0.5);

                float2 sunLen = sunPos - uv;
                float2 oppSunLen = oppSunPos - uv;

                float gradientcolor = max(0.0, 1.0 - dot(sunLen, sunLen));
                // gradientcolor = saturate(gradientcolor);//pow(saturate(gradientcolor), invDarkArea);
                // gradientcolor = saturate(pow(saturate(gradientcolor), 2.0));
                gradientcolor = gradientcolor * gradientcolor;
                return gradientcolor;
            }




            struct MMLight
            {
                float3 direction;
                float4 color;
                float distanceAttenuation;
                float shadowAttenuation;
                uint layerMask;
            };

            MMLight MMGetMainLight()
            {
                MMLight light;
                light.direction = float3(_MainLightPosition.xyz);
                #if USE_CLUSTERED_LIGHTING
                    light.distanceAttenuation = 1.0;
                #else
                    light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
                #endif
                light.shadowAttenuation = 1.0;
                light.color = _MainLightColor.rgba;

                #ifdef _LIGHT_LAYERS
                    light.layerMask = _MainLightLayerMask;
                #else
                    light.layerMask = DEFAULT_LIGHT_LAYERS;
                #endif

                return light;
            }

            //여기까지 GetMainLight 입니다


            //조절값들을 상수로 고정합니다. 프로퍼티를 볼륨에서 제어하기 때문입니다.
            static const float _LightSideInvBrightArea2 = 1.5; //밝은 부분 위치를 옮깁니다. 수가 클수록 태양방향으로 이동합니다.
            static const float _LightSideInvDarkArea = 5; //밝은 부분 경계 부드럽게

            static const float _DarkSideInvBrightArea = 0.2;//어두운 부분 위치를 옮깁니다.수가 클수록 태양방향으로 이동합니다.
            static const float _DarkSideInvDarkArea = 1;//어두운 부분 경계 부드럽게

            static const float _LightSidePreviewToggle = 0; //밝은 부분만 미리보기
            static const float _DarkSidePreviewToggle = 0; //어두운 부분만 미리보기


            float4 frag(Varyings IN) : SV_Target
            {

                MMLight light = MMGetMainLight();

                float3 lightDir = normalize(light.direction);
                float3 cameraDir = normalize(IN.cameraDir);

                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.screenPos.xy);


                float3 delta = lightDir - abs(cameraDir);

                float LdotV = dot(lightDir, cameraDir);
                // 0.35를 빼는 이유는 이렇게 하면 빛이 가려졌다 나타났다 하는 효과가 나와서 마치 카메라 후드에 클리핑되는 것처럼 느껴지게 된다
                float spot = saturate((LdotV - 0.50) * 30);


                float DdotC_X = (dot(lightDir, normalize(IN.cameraDirX)) + 0.5);
                float DdotC_Y = (dot(lightDir, normalize(IN.cameraDirY)) + 0.5);
                float3 sundir = float3(DdotC_X, DdotC_Y, 0);

                //리니어 그라디언트를 구한다 (태양방향, 스크린UV, 그라디언트 power, 밝은쪽 밀어내기(0이 한계), 검은쪽 밀어내기(0이 변화없음))
                float dayGradient = SimpleRadialGradient(sundir, IN.screenPos.xy, _LightSideInvBrightArea2, _LightSideInvDarkArea);

                float nightGradient = SimpleRadialGradient(sundir, IN.screenPos.xy, _DarkSideInvBrightArea, _DarkSideInvDarkArea);


                //최종연산하기
                float4 fragcolor = float4(1, 1, 1, 1);
                float3 brightGradientColor = (dayGradient * light.color.rgb * spot * _DayLightSideColor.rgb * 2.0);
                float3 darkGradientColor = saturate(nightGradient + _DayDarkSideColor.rgb);

                // fragcolor.rgb = brightGradientColor + color.rgb  ;
                fragcolor.rgb = brightGradientColor + color.rgb * darkGradientColor;

                //미니맵 등, 오쏘그래프 모드에서는 안나오게 한다.
                if (unity_OrthoParams.w == 1)
                {
                    return color;
                }

                //미리보기 토글
                if (_LightSidePreviewToggle == 1 && _DarkSidePreviewToggle == 1)
                {
                    return float4(brightGradientColor + darkGradientColor, 1);
                }
                else if (_LightSidePreviewToggle == 1)
                {
                    return float4(brightGradientColor, 1);
                }
                else if (_DarkSidePreviewToggle == 1)
                {
                    return float4(darkGradientColor, 1);
                }

                return fragcolor;
            }
            ENDHLSL
        }
    }
}