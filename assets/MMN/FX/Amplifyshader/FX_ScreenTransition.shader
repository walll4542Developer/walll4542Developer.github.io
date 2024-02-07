// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_ScreenTransition"
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
		_uv("uv", Vector) = (15,15,0,0)
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Speed("Speed", Float) = 1
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		_Mosaic("Mosaic", Float) = 70
		_Thickness("Thickness", Float) = 0.25
		_Step("Step", Range( -2 , 2)) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1

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

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float2 _uv;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Mosaic;
			float _Speed;
			float _Thickness;
			float _Step;
			float _Intensity_Color;
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
				float localApplySoftParticle80_g10 = ( 0.0 );
				float localApplyLightColor6_g10 = ( 0.0 );
				float localApplyShadowAtten104_g10 = ( 0.0 );
				half localApplyRaycastingAlpha92_g10 = ( 0.0 );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult117 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult334 = (float2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
				float2 appendResult128 = (float2(1.0 , ( _ScreenParams.y / _ScreenParams.x )));
				float temp_output_339_0 = saturate( ceil( ( _ScreenParams.x - _ScreenParams.y ) ) );
				float2 lerpResult336 = lerp( appendResult334 , appendResult128 , temp_output_339_0);
				float2 temp_output_302_0 = ( ( appendResult117 * lerpResult336 ) - ( float2( 0.5,0.5 ) * lerpResult336 ) );
				float4 tex2DNode136 = tex2D( _MainTex, ( ( ( ceil( ( frac( abs( ( temp_output_302_0 + float2( 0.125,0.125 ) ) ) ) * _Mosaic ) ) / _Mosaic ) * _uv.x ) + ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * _Speed ) ) );
				float4 tex2DNode286 = tex2D( _AlphaTex, ( ceil( ( ( temp_output_302_0 - float2( -0.5,-0.5 ) ) * _Mosaic ) ) / _Mosaic ) );
				float temp_output_298_0 = ( ( tex2DNode136.r + tex2DNode136.g + tex2DNode136.b ) * 0.33 * tex2DNode286.g );
				float temp_output_322_0 = ( ( _Thickness * _Step ) + _Step );
				float temp_output_376_0 = ( temp_output_298_0 + ( tex2DNode286.g - temp_output_322_0 ) );
				float temp_output_120_0 = step( _Step , saturate( temp_output_376_0 ) );
				float4 appendResult32_g10 = (float4(( ( tex2DNode136 * step( temp_output_298_0 , temp_output_322_0 ) ) * _Intensity_Color ).rgb , max( ( step( _Step , saturate( ( temp_output_376_0 * temp_output_376_0 ) ) ) * temp_output_120_0 ) , temp_output_120_0 )));
				half4 finalColor92_g10 = appendResult32_g10;
				half3 positionWS92_g10 = input.positionWS;
				half4 screenUV92_g10 = ase_screenPosNorm;
				half4 screenPos92_g10 = ase_screenPosNorm;
				half nearPlane92_g10 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g10 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g10 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g10 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g10 , positionWS92_g10 , screenUV92_g10 , screenPos92_g10 , nearPlane92_g10 , nearPlaneInvertDistance92_g10 , raycastHarftoneClip92_g10 , raycastMinimumAlpha92_g10 );
				float4 finalColor104_g10 = finalColor92_g10;
				float4 shadowCoord104_g10 = input.uv0;
				float3 positionWS104_g10 = input.positionWS;
				float lightRatio104_g10 = _LightRatio;
				ApplyShadowAtten( finalColor104_g10 , shadowCoord104_g10 , positionWS104_g10 , lightRatio104_g10 );
				float4 finalColor6_g10 = finalColor104_g10;
				float3 normalWS6_g10 = input.normalWS;
				float lightRatio6_g10 = _LightRatio;
				ApplyLightColor( finalColor6_g10 , normalWS6_g10 , lightRatio6_g10 );
				float4 finalColor80_g10 = finalColor6_g10;
				float near80_g10 = _SoftParticleNearFadeDistance;
				float far80_g10 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g10 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g10 = ( 0.0 );
				float4 positionCS58_g10 = float4( 0,0,0,0 );
				float4 positionNDC58_g10 = float4( 0,0,0,0 );
				float3 positionOS58_g10 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g10 , positionNDC58_g10 , positionOS58_g10 );
				float4 positionNDC80_g10 = positionNDC58_g10;
				ApplySoftParticle( finalColor80_g10 , near80_g10 , far80_g10 , fadeOutRange80_g10 , positionNDC80_g10 );
				float4 break64_g10 = finalColor80_g10;
				float3 appendResult76_g10 = (float3(break64_g10.x , break64_g10.y , break64_g10.z));
				
				float3 Color = appendResult76_g10;
				float Alpha = break64_g10.w;

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
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;134;-3728,-1200;Inherit;False;1144.207;1107.208;화면;15;358;361;336;332;126;333;123;128;334;115;132;117;133;130;360;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;360;-3568,-432;Inherit;False;516;187;화면비 큰 방향  0 가로 1 세로;3;339;338;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;839.8939,10.91327;Inherit;False;204;375;Rendering Options;4;82;81;79;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;82;871.8939,58.91327;Inherit;False;Property;_BlendSrc;Blend Src;20;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;871.8939,218.9133;Inherit;False;Property;_CullMode;Cull Mode;23;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;871.8939,138.9133;Inherit;False;Property;_BlendDst;Blend Dst;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;871.8939,298.9132;Inherit;False;Property;_ZTest;Z Test;21;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;206.9531,-342.6042;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-2768,-1136;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-2768,-1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;117;-2992,-1136;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;132;-3024,-1008;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;334;-3232,-720;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;-3232,-848;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenParams;123;-3696,-848;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;333;-3408,-720;Inherit;False;Constant;_Float5;Float 4;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-3408,-848;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;336;-2992,-848;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;337;-3520,-384;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;338;-3360,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;339;-3232,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;358;-2992,-224;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;193;-1984,-1136;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;250;-1856,-1136;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;244;-1728,-1136;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CeilOpNode;245;-1568,-1136;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;246;-1440,-1136;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;313;-1984,-576;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CeilOpNode;296;-1840,-576;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;297;-1712,-576;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;252;-1120,-1008;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;320;-2128,-576;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-1264,-784;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;326;-1440,-656;Inherit;False;Property;_Speed;Speed;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;253;-1472,-736;Inherit;False;MMN_Time;-1;;9;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;-2416,-832;Inherit;False;Property;_Mosaic;Mosaic;17;0;Create;True;0;0;0;False;0;False;70;70;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;299;-672,-944;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;839.8939,-133.0867;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_ScreenTransition;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.FunctionNode;77;583.8939,-133.0867;Inherit;False;MMN_CommonOutputs;0;;10;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;0,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SimpleSubtractOpNode;302;-2288,-1136;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;392;-2112,-1132;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.125,0.125;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;332;-3405,-637;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;361;-3248,-224;Inherit;False;Constant;_ScreenScaleFactor;ScreenScaleFactor;12;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenPosInputsNode;115;-3232,-1136;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;136;-992,-1008;Inherit;True;Property;_MainTex;MainTex;14;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;286;-1568,-576;Inherit;True;Property;_AlphaTex;AlphaTex;16;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;395;-5.597778,-245.006;Inherit;False;Property;_Intensity_Color;Intensity_Color;24;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-16,-944;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;321;-256,-832;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-480,-832;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.33;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;322;-512,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;369;-672,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-832,-512;Inherit;False;Property;_Thickness;Thickness;18;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;376;-523.7816,357.8143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;120;41.01822,450.1141;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;388;36.21835,229.8139;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;273.1646,282.7681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;375;-699.7815,357.8143;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;372;-315.7816,453.8143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;383;-315.7816,341.8143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;384;-123.7816,341.8143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;391;436.2183,293.814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-960.0002,-428.0633;Inherit;False;Property;_Step;Step;19;0;Create;True;0;0;0;False;0;False;0;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-1280,-1008;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;137;-1607,-1033;Inherit;False;0;136;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;396;-1603.507,-861.8842;Inherit;False;Property;_uv;uv;13;0;Create;True;0;0;0;False;0;False;15,15;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
WireConnection;327;0;323;0
WireConnection;327;1;395;0
WireConnection;130;0;117;0
WireConnection;130;1;336;0
WireConnection;133;0;132;0
WireConnection;133;1;336;0
WireConnection;117;0;115;1
WireConnection;117;1;115;2
WireConnection;334;0;332;0
WireConnection;334;1;333;0
WireConnection;128;0;333;0
WireConnection;128;1;126;0
WireConnection;126;0;123;2
WireConnection;126;1;123;1
WireConnection;336;0;334;0
WireConnection;336;1;128;0
WireConnection;336;2;339;0
WireConnection;337;0;123;1
WireConnection;337;1;123;2
WireConnection;338;0;337;0
WireConnection;339;0;338;0
WireConnection;358;0;361;1
WireConnection;358;1;361;2
WireConnection;358;2;339;0
WireConnection;193;0;392;0
WireConnection;250;0;193;0
WireConnection;244;0;250;0
WireConnection;244;1;243;0
WireConnection;245;0;244;0
WireConnection;246;0;245;0
WireConnection;246;1;243;0
WireConnection;313;0;320;0
WireConnection;313;1;243;0
WireConnection;296;0;313;0
WireConnection;297;0;296;0
WireConnection;297;1;243;0
WireConnection;252;0;249;0
WireConnection;252;1;254;0
WireConnection;320;0;302;0
WireConnection;254;0;253;0
WireConnection;254;1;326;0
WireConnection;299;0;136;1
WireConnection;299;1;136;2
WireConnection;299;2;136;3
WireConnection;84;0;77;2
WireConnection;84;1;77;26
WireConnection;77;9;327;0
WireConnection;77;28;391;0
WireConnection;302;0;130;0
WireConnection;302;1;133;0
WireConnection;392;0;302;0
WireConnection;332;0;123;1
WireConnection;332;1;123;2
WireConnection;136;1;252;0
WireConnection;286;1;297;0
WireConnection;323;0;136;0
WireConnection;323;1;321;0
WireConnection;321;0;298;0
WireConnection;321;1;322;0
WireConnection;298;0;299;0
WireConnection;298;2;286;2
WireConnection;322;0;369;0
WireConnection;322;1;121;0
WireConnection;369;0;324;0
WireConnection;369;1;121;0
WireConnection;376;0;298;0
WireConnection;376;1;375;0
WireConnection;120;0;121;0
WireConnection;120;1;372;0
WireConnection;388;0;121;0
WireConnection;388;1;384;0
WireConnection;394;0;388;0
WireConnection;394;1;120;0
WireConnection;375;0;286;2
WireConnection;375;1;322;0
WireConnection;372;0;376;0
WireConnection;383;0;376;0
WireConnection;383;1;376;0
WireConnection;384;0;383;0
WireConnection;391;0;394;0
WireConnection;391;1;120;0
WireConnection;249;0;246;0
WireConnection;249;1;396;1
ASEEND*/
//CHKSM=7AACE1CAEEAE7FD0DBD9D1CF10BE17CECED93028