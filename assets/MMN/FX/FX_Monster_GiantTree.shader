Shader "MMN/FX/FX_Monster_GiantTree"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_DataTex("DataTex", 2D) = "black" {}
		[Toggle]_BlinkMode("Use Blink", float) = 0
		[Toggle]_ShadowMode("Use Shadow", float) = 0
		_Cutoff("Blink Animation", Range(0, 1)) = 0

		[Header(Jitter Options)]
		[Space(10)]
		[Toggle]_Jittering("Use Jittering", float) = 0
		_JitterStrength("Jitter Strength", Range(0, 1)) = 0.119
		_RandomSeed("Jitter Random Seed", Range(0, 1)) = 0.254
		_Speed("Jitter Speed", Range(0, 1)) = 0.1

        // NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (0.0, -1.0, 0.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InflateWidth ("_InflateWidth", Float) = 0.0
        [HideInInspector] _InflateColor ("_InflateColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue ("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength ("_VertexBufferLength", Integer) = 0
        //--------------------------------------------------------------------------------
	}

	SubShader
	{
		LOD 0

		Tags
		{
			"RenderPipeline"="UniversalPipeline"
			"RenderType"="Opaque"
			"Queue"="Geometry"
		}

		Pass
		{
			Name "Unlit"

			Cull back
			ZTest Lequal
			ZWrite On
			ColorMask RGBA

			HLSLPROGRAM
			#pragma target 4.5
			#pragma exclude_renderers glcore gles gles3

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/CH/MMN_Character_Global_Input.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_DataTex);
			SAMPLER(sampler_DataTex);

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _MainTex_TexelSize;
				float4 _MainTex_MipInfo;
				half _Cutoff;
				half _RandomSeed;
				half _Speed;
				half _JitterStrength;
				half _Jittering;
				half _BlinkMode;
				half _ShadowMode;

				MM_DECLARE_PROPERTIES_FROM_SCRIPT
			CBUFFER_END

			#include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterApplyFx.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterApplyFog.hlsl"

			struct Attributes
			{
				float4 color : COLOR;
				float4 positionOS : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 color : COLOR;
				float4 positionCS : SV_POSITION;
				float4 uv0 : TEXCOORD0;
				float4 fogCoord : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
				float3 viewDirWS : TEXCOORD3;
				float3 normalWS : TEXCOORD4;
			};

			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				output.uv0.xy = TRANSFORM_TEX(input.texcoord.xy, _MainTex);
				output.uv0.zw = input.texcoord.xy;
				output.positionCS = vertexInput.positionCS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);

				output.color = input.color;

				return output;
			}

			void InitializeCharacterInputData(Varyings input, out InputData inputData)
			{
				inputData = (InputData)0;
				inputData.positionWS = input.positionWS.xyz;

				float3 viewDirWS = input.viewDirWS;
				viewDirWS = SafeNormalize(viewDirWS);
				inputData.viewDirectionWS = viewDirWS;

				inputData.normalWS.xyz = SafeNormalize(input.normalWS.xyz);

				inputData.shadowCoord = float4(0, 0, 0, 0);

				inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
				inputData.vertexLighting = float3(0, 0, 0);
				inputData.bakedGI = 1.0; //음영을 사용 안하도록

				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
				inputData.shadowMask = float4(1, 1, 1, 1);
			}

			float2 JitterUV (float2 uv, half randomSeed)
			{
				float3 position = frac(uv.xyx * float3(123.45 + randomSeed, 789.74 + randomSeed, 345.65 + randomSeed));
				position += dot(position, position + 34.45 + randomSeed);
				float2 result = frac(float2(position.x * position.y, position.y * position.z));
				return result;
			}

			half4 frag(Varyings input) : SV_Target
			{
				// 셰이더 프로퍼티 범위 값 수정
				_Cutoff *= 4;
				_Cutoff = floor(_Cutoff);
				_Cutoff *= 0.25;

				float randomSeed = frac(saturate(input.color.r) + _RandomSeed); // 버텍스 컬러를 y축의 랜덤시드로 사용합니다.

				float4 uv = input.uv0;
				float time = frac(_Time.y * _Speed);

				half dataTexR0 = SAMPLE_TEXTURE2D(_DataTex, sampler_DataTex, float2(time, frac(randomSeed * 0.5 + 0.5))).r;
				half dataTexR1 = SAMPLE_TEXTURE2D(_DataTex, sampler_DataTex, float2(time, frac(randomSeed * 0.5))).r;
				half3 dataTexGBA = SAMPLE_TEXTURE2D(_DataTex, sampler_DataTex, float2(time, randomSeed)).gba;
				half4 dataTex = half4(dataTexR0, dataTexR1, dataTexGBA.gb);

				// 데이터 텍스쳐 튜닝
				dataTex.rgb = smoothstep(0.45, 0.55, dataTex.rgb);

				_Cutoff = lerp(_Cutoff, saturate(_Cutoff + (1 - dataTex.b)), _Jittering); // 눈 깜빡이기
				_Cutoff += 0.1; // 컷오프의 최소값 유지

				dataTex.rga = dataTex.rga * 2 - 1; // -1 ~ 1 범위 확장

				float2 uvOffset = float2(dataTex.r, dataTex.g);

				uvOffset.r *= _JitterStrength * 2; // 눈알은 가로가 더 길쭉하기 때문
				uvOffset.g *= _JitterStrength;

				float2 eyeUV = lerp(uv.xy, uv.xy + uvOffset, _Jittering); // 눈 지터링 토글 박스

				half3 eyeTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, eyeUV).rgb;
				half dataTexG = SAMPLE_TEXTURE2D(_DataTex, sampler_DataTex, eyeUV).g; // 동공 마스킹

				// 동공 크기 조절
				float size = 1.6;
				size += dataTex.a;

				eyeUV -= 0.5;
				eyeUV *= size;
				eyeUV += 0.5;

				float2 eyePupilUV = lerp(uv.xy, eyeUV, _Jittering); // 동공 지터링 토글 박스

				half3 eyeTexG = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, eyePupilUV).rgb;
				dataTexG = SAMPLE_TEXTURE2D(_DataTex, sampler_DataTex, eyePupilUV).g;

				eyeTex = lerp(eyeTex, eyeTexG, dataTexG);
				half eyeTexAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv.zw).a;

				_Cutoff = lerp(0, _Cutoff, _BlinkMode); // 눈 깜빡이기 클리핑
				clip(eyeTexAlpha - _Cutoff);

				eyeTex = lerp(eyeTex, eyeTex * eyeTexAlpha, _ShadowMode); // 눈 그림자 추가

                // Input data
                InputData inputData;
                InitializeCharacterInputData(input, inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, uv, _MainTex);

                // Light
                Light mainLight;
                LightingData lightingData;
                InitializeLightData(inputData, mainLight, lightingData);

				float3 mainLightColor = lightingData.mainLightColor;
				float3 ambientColor = lightingData.giColor;

				float3 lightColor = saturate(ambientColor + mainLightColor);

				half3 color = eyeTex * lightColor;
				half alpha = 1;
				half4 finalColor = half4(color, alpha);

				ApplyFx_BeforeFog(finalColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
				finalColor = ApplyFog(finalColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
				ApplyFx_AfterFog(finalColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, color, alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}
	FallBack Off
}