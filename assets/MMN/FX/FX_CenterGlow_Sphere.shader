// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/CenterGlow (Sphere)"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Toggle]_Night2DayReceive("밤 낮 적용을 받을 것인지?", Float) = 0
		[Enum(Always,0,NightOnly,1,DayOnly,2)]_Night2DayEnum("밤낮에 따라 켜지고 꺼지게 하기", Float) = 0
		[HDR]_Color("Color", Color) = (1,1,0.538,1)
		_Opacity("Opacity", Range( 0 , 1)) = 0.25
		_Power("Power", Range( 1 , 16)) = 8
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
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
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 0

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
			ZWrite [_ZWrite]
			ColorMask RGBA
			

			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma exclude_renderers glcore gles gles3 switch 

			// GPU Instancing
			
			// Material Keywords
			// 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
			// #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // Unity defined keywords
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT
            // #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // #pragma multi_compile_fragment _ _LIGHT_COOKIES
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			#include "Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			float _Global_Night2Day;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float _Night2DayEnum;
			float _Night2DayReceive;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Power;
			float _Opacity;
			CBUFFER_END

			float _Mode = -1;
			float _TransitionValue = 1;
			float _FogPower = 0;

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
    			half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				half4 color : COLOR;
				
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				half4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream 
				half4 uv1 : TEXCOORD1; 				// xyzw : custom data
				half4 fogCoord : TEXCOORD2; 		// x : fogcoord				yzw :
				half3 positionWS : TEXCOORD11;
				float4 positionOS : TEXCOORD12;
				float3 normalWS : TEXCOORD13;

				float4 ase_texcoord3 : TEXCOORD3;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

				input.normalOS = input.normalOS;

				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord; // output.shadowCoord
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionOS = input.positionOS;
				output.positionCS = vertexInput.positionCS;
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				float localApplySoftParticle80_g6 = ( 0.0 );
				float localApplyLightColor6_g6 = ( 0.0 );
				float localApplyShadowAtten104_g6 = ( 0.0 );
				half localApplyRaycastingAlpha92_g6 = ( 0.0 );
				float3 appendResult22 = (float3(_Color.r , _Color.g , _Color.b));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult12 = dot( ase_worldViewDir , input.normalWS );
				float4 appendResult87_g4 = (float4(appendResult22 , max( 0.0 , ( saturate( pow( saturate( dotResult12 ) , _Power ) ) - _Opacity ) )));
				float4 break89_g4 = ( appendResult87_g4 * ( 1.0 - ( _Night2DayReceive * _Global_Night2Day ) ) );
				float3 appendResult90_g4 = (float3(break89_g4.x , break89_g4.y , break89_g4.z));
				float4 appendResult32_g6 = (float4(appendResult90_g4 , break89_g4.w));
				half4 finalColor92_g6 = appendResult32_g6;
				half3 positionWS92_g6 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g6 = ase_screenPosNorm;
				half4 screenPos92_g6 = ase_screenPosNorm;
				half nearPlane92_g6 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g6 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g6 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g6 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g6 , positionWS92_g6 , screenUV92_g6 , screenPos92_g6 , nearPlane92_g6 , nearPlaneInvertDistance92_g6 , raycastHarftoneClip92_g6 , raycastMinimumAlpha92_g6 );
				float4 finalColor104_g6 = finalColor92_g6;
				float4 shadowCoord104_g6 = input.uv0;
				float3 positionWS104_g6 = input.positionWS;
				float lightRatio104_g6 = _LightRatio;
				ApplyShadowAtten( finalColor104_g6 , shadowCoord104_g6 , positionWS104_g6 , lightRatio104_g6 );
				float4 finalColor6_g6 = finalColor104_g6;
				float3 normalWS6_g6 = input.normalWS;
				float lightRatio6_g6 = _LightRatio;
				ApplyLightColor( finalColor6_g6 , normalWS6_g6 , lightRatio6_g6 );
				float4 finalColor80_g6 = finalColor6_g6;
				float near80_g6 = _SoftParticleNearFadeDistance;
				float far80_g6 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g6 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g6 = ( 0.0 );
				float4 positionCS58_g6 = float4( 0,0,0,0 );
				float4 positionNDC58_g6 = float4( 0,0,0,0 );
				float3 positionOS58_g6 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g6 , positionNDC58_g6 , positionOS58_g6 );
				float4 positionNDC80_g6 = positionNDC58_g6;
				ApplySoftParticle( finalColor80_g6 , near80_g6 , far80_g6 , fadeOutRange80_g6 , positionNDC80_g6 );
				float4 break64_g6 = finalColor80_g6;
				float3 appendResult76_g6 = (float3(break64_g6.x , break64_g6.y , break64_g6.z));
				
				float3 Color = appendResult76_g6;
				float Alpha = break64_g6.w;

				float4 finalColor = float4(Color, Alpha);
				ApplyFogColor(finalColor, input.positionWS, input.normalWS, _Mode, _FogPower, input.fogCoord.x);
				ApplyTransitionValue(finalColor, _Mode, _TransitionValue);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, Color, Alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"
	FallBack Off
	
	Fallback "Off"
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-2444.11,-86.03247;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;11;-2448.983,90.59517;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;12;-2240.683,26.03424;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2197.378,287.2632;Float;False;Property;_Power;Power;5;0;Create;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;8;1;1;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-2111.563,24.81616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;15;-1891.161,23.84753;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;-1706.352,-235.6644;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2077.469,-215.619;Float;False;Property;_Opacity;Opacity;4;0;Create;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0.25;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-1545.53,-235.6642;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-1675.673,-407.9707;Inherit;False;Property;_Color;Color;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,0.538,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMaxOpNode;24;-1390.682,-260.1115;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;22;-1400.415,-379.4204;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;32;-944.3512,-383.5286;Inherit;False;MMN_GlobalVolumeController;0;;4;f19d2630dcd1f1341ad9954a7d08abde;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.CommentaryNode;2;214.088,-26.6012;Inherit;False;204;375;Rendering Options;4;8;4;3;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;31;-41.05882,-163.218;Inherit;False;MMN_CommonOutputs;10;;6;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;8;246.089,181.399;Inherit;False;Property;_CullMode;Cull Mode;8;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;252.089,101.399;Inherit;False;Property;_BlendDst;Blend Dst;7;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;254.705,18.5965;Inherit;False;Property;_BlendSrc;Blend Src;6;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;439.0289,18.69141;Inherit;False;Property;_ZWrite;ZWrite;9;1;[Enum];Create;False;0;2;Off;0;On;1;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;256,272;Inherit;False;Property;_ZTest;Z Test;23;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;230,-169;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/CenterGlow (Sphere);308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;True;_ZWrite;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;14;0;12;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;17;0;15;0
WireConnection;20;0;17;0
WireConnection;20;1;16;0
WireConnection;24;1;20;0
WireConnection;22;0;19;1
WireConnection;22;1;19;2
WireConnection;22;2;19;3
WireConnection;32;9;22;0
WireConnection;32;28;24;0
WireConnection;31;9;32;2
WireConnection;31;28;32;26
WireConnection;1;0;31;2
WireConnection;1;1;31;26
ASEEND*/
//CHKSM=A8184817E834880670653A7AE98471475153DF9E