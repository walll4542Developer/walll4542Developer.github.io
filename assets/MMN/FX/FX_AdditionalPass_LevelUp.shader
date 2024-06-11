Shader "MMN/FX/LevelUp"
{
	Properties
	{
		[HideInInspector][Toggle(_RAYCAST_ON)] _Raycast ("_Raycast", Float) = 1.0
		[HideInInspector][PerRendererData] _RaycastHarftoneClip ("raycastHarftoneClip", Range(0.0, 1.0)) = 0.0
		[HideInInspector] _RaycastMinimumAlpha ("raycastMinimumAlpha", Range(0.0, 1.0)) = 0.0
		[HideInInspector] _NearPlaneAlpha ("nearPlaneAlpha", Range(0.0, 1.0)) = 0.0
		[HideInInspector][ToggleUI] _NearPlaneInvertDistance ("nearPlaneInvertDistance", Range(0.0, 1.0)) = 0.0
		[HideInInspector][ToggleUI] _FogReceive ("FogReceive", Range(0.0, 1.0)) = 0.0

		[HDR][Header(Main Options)][Space(10)] _MainColor("색상", Color) = (1.0, 1.0, 1.0, 1.0)
		_Progress ("진행", Float) = 0.0
		_Power ("두께", Range(0.0, 1.0)) = 0.0

		// NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (0.0, -1.0, 0.0, 0.0)
        [HideInInspector] _CharacterHeadDirection ("xyz: direction, w: height", Vector) = (0.0, 0.0, 1.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

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
		LOD 100
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL


		Pass
		{
			Name "Unlit"


			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
            ZTest LEqual
            Cull Back
			ColorMask RGBA

			HLSLPROGRAM

			#pragma exclude_renderers glcore gles gles3 switch

            // Unity defined keywords
			#pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR
			#pragma multi_compile_fragment __ _RAYCAST_ON

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/CH/MMN_Character_Global_Input.hlsl"

			CBUFFER_START( UnityPerMaterial )
				float _RaycastHarftoneClip;
				float _RaycastMinimumAlpha;

				float _NearPlaneAlpha;
				float _NearPlaneInvertDistance;

				float _FogReceive;

				float4 _MainColor;
				float _Progress;
				float _Power;

				MM_DECLARE_PROPERTIES_FROM_SCRIPT
			CBUFFER_END

			#include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterMotionBlurPass.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR;
                uint id : SV_VertexID;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
				float4 fogCoord : TEXCOORD1; 		    // x : fogcoord				yzw :
				float3 positionWS : TEXCOORD2;
				float3 normalWS : TEXCOORD3;
				float4 positionNDC : TEXCOORD4;
			};

			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

#ifdef _VERTEX_OBJECT_MOTION_BLUR
			    // 오브젝트 모션블러(버텍스)를 적용한다
			    float4 positionOS = float4(CaculateMotionBlurVertexPositionOS(input.positionOS.xyz, input.normalOS, input.id), input.positionOS.w);
			    positionOS.xyz += input.normalOS.xyz * 0.001;
#else
    			float4 positionOS = float4(input.positionOS.xyz + input.normalOS.xyz * 0.001, input.positionOS.w);
#endif
				VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord;
				output.positionWS = vertexInput.positionWS.xyz;
				output.positionCS = vertexInput.positionCS;
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);
                output.positionNDC = vertexInput.positionNDC;

				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				float4 positionNDC = input.positionNDC / input.positionNDC.w;
				positionNDC.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? positionNDC.z : positionNDC.z * 0.5 + 0.5;

				float3 characterPosition = float3(_CharacterPositionAndVisualHeight.x, 0, _CharacterPositionAndVisualHeight.z);
				float3 positionWS = float3(input.positionWS.x, 0, input.positionWS.z);

				float3 globalPosition = characterPosition - positionWS;
				float baseline = dot(normalize(float3(_CharacterDirection.x, 0, _CharacterDirection.y)), globalPosition.xyz);

				baseline += 1.5; // 라인 시작지점을 캐릭터의 0.5m 앞에 둡니다.
				baseline = frac(saturate(baseline - _Progress)); // _Progress : 0 ~ 1
				float thickness = lerp(20, 1, _Power);
				baseline = pow(baseline, thickness);

				float3 color = _MainColor.rgb;
				float alpha = baseline * _MainColor.a;
				float4 finalColor = float4(color, alpha);

				ApplyRaycastingAlpha(finalColor, input.positionWS, positionNDC,
				_NearPlaneAlpha, _NearPlaneInvertDistance,
				_RaycastHarftoneClip, _RaycastMinimumAlpha);
				ApplyFogColor(finalColor, input.positionWS, input.normalWS, 0/*_Mode*/, 1/*_FogReceive*/, input.fogCoord);


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