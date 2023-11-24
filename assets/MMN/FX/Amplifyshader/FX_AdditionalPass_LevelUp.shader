// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/LevelUp"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector][Toggle(_FOG_RCV_ON)] _FogReceive("안개 적용", Float) = 0
		[HideInInspector][PerRendererData]_RaycastHarftoneClip("raycastHarftoneClip", Range( 0 , 1)) = 0
		[HideInInspector]_RaycastMinimumAlpha("raycastMinimumAlpha", Range( 0 , 1)) = 0
		[HideInInspector]_NearPlaneAlpha("nearPlaneAlpha", Range( 0 , 1)) = 0
		[HideInInspector][Toggle]_NearPlaneInvertDistance("nearPlaneInvertDistance", Range( 0 , 1)) = 0
		[HideInInspector][Space(10)][Toggle(_LIGHTRECEIVE_ON)] _LightReceive("빛 적용", Float) = 0
		[HideInInspector][Toggle(_SOFTPARTICLE_ON)] _SoftParticle("소프트 파티클 적용", Float) = 0
		[HideInInspector][Toggle(_RAYCAST_ON)] _Raycast("레이캐스트 적용", Float) = 0
		[HideInInspector]_LightRatio("lightRatio", Range( 0 , 1)) = 1
		[HideInInspector]_SoftParticleNearFadeDistance("Soft Particle Near Fade", Float) = 0
		[HideInInspector]_SoftParticleFarFadeDistance("Soft Particle Far Fade", Float) = 1
		[HideInInspector]_SoftParticleFadeOutRange("사라지는 범위 조절", Range( 0 , 10)) = 1
		_CharacterDirection("_CharacterDirection", Vector) = (1,0,0,0)
		[HDR][Header(Main Options)][Space(10)]_MainColor("색상", Color) = (1,1,1,1)
		_Progress("진행", Float) = 0
		_Power("두께", Range( 0 , 1)) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		
		// NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (1.0, 0.0, 0.0, 0.0)
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

        [HideInInspector] _EffectAlphaValue("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength("_VertexBufferLength", Integer) = 0
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			

			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			

			HLSLPROGRAM

			#pragma exclude_renderers glcore gles gles3 switch 

			// GPU Instancing
			
			// Material Keywords
			// 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
			// #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // Unity defined keywords
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			#pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/CH/MMN_Character_Global_Input.hlsl"

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON

			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Progress;
			float _Power;

			MM_DECLARE_PROPERTIES_FROM_SCRIPT
			
			float _Mode = -1;
			float _TransitionValue = 1;
			float _FogPower = 0;
			CBUFFER_END

			#include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterMotionBlurPass.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
				uint id : SV_VertexID;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream 
				float4 uv1 : TEXCOORD1; 				// xyzw : custom data
				float4 fogCoord : TEXCOORD2; 		// x : fogcoord				yzw :
				float4 screenPosition : TEXCOORD3;
				float3 positionWS : TEXCOORD4;
				float4 positionOS : TEXCOORD5;
				float3 normalWS : TEXCOORD6;
				float4 positionNDC : TEXCOORD7;
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

				VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord; // output.shadowCoord
				output.positionWS = TransformObjectToWorld(positionOS.xyz);
				output.positionOS = positionOS;
				output.positionCS = vertexInput.positionCS;
				output.screenPosition = ComputeScreenPos(vertexInput.positionCS);
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);
				output.positionNDC = vertexInput.positionNDC;

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				float3 swizzleWorldPosition = input.positionWS.xzy;
				float baseline = dot(normalize(float3(_CharacterDirection.xy, 0)), swizzleWorldPosition);
				baseline = frac(baseline + _Progress);
				float thickness = lerp(20, 1, _Power);
				baseline = pow(baseline, thickness);
				
				float3 color = _MainColor.rgb;
				float alpha = baseline;
				float4 finalColor = float4(color, alpha);

				ApplyRaycastingAlpha(finalColor, input.positionWS, input.screenPosition, input.screenPosition, _NearPlaneAlpha, _NearPlaneInvertDistance, _RaycastHarftoneClip, _RaycastMinimumAlpha);
				ApplyShadowAtten(finalColor, input.uv0, input.positionWS, _LightRatio);
				ApplyLightColor(finalColor, input.normalWS, _LightRatio);
				ApplySoftParticle(finalColor, _SoftParticleNearFadeDistance, _SoftParticleFarFadeDistance, _SoftParticleFadeOutRange, input.positionNDC);

				ApplyFogColor(finalColor, input.positionWS, input.normalWS, _Mode, _FogPower, input.fogCoord.x);
				ApplyTransitionValue(finalColor, _Mode, _TransitionValue);

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
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"
	FallBack Off
}