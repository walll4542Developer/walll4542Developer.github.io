// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Trail_Default"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(MainTexture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Main_U_Speed("Main_U_Speed", Float) = 0
		_Main_V_Speed("Main_V_Speed", Float) = 0
		[Header(NoiseTexture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_U_Speed("Noise_U_Speed", Float) = 0
		_Noise_V_Speed("Noise_V_Speed", Float) = 0
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 1
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
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
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

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

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float _LightRatio;
			float _Noise_V_Speed;
			float _Noise_U_Speed;
			float _Use_G_Channel_Alpha;
			float _Main_V_Speed;
			float _Intensity_Color;
			float _Main_U_Speed;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _NearPlaneAlpha;
			float _Intensity_Alpha;
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

				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
				output.ase_color = input.color;
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
				float localApplySoftParticle80_g9 = ( 0.0 );
				float localApplyLightColor6_g9 = ( 0.0 );
				float localApplyShadowAtten104_g9 = ( 0.0 );
				half localApplyRaycastingAlpha92_g9 = ( 0.0 );
				float temp_output_28_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 appendResult40 = (float2(_Main_U_Speed , _Main_V_Speed));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult20 = (float2(( uv_MainTex.x - 0.0 ) , uv_MainTex.y));
				float2 panner39 = ( temp_output_28_0 * appendResult40 + appendResult20);
				float4 tex2DNode10 = tex2D( _MainTex, panner39 );
				float lerpResult50 = lerp( tex2DNode10.a , tex2DNode10.g , _Use_G_Channel_Alpha);
				float2 appendResult48 = (float2(_Noise_U_Speed , _Noise_V_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult44 = (float2(( uv_NoiseTex.x - 0.0 ) , uv_NoiseTex.y));
				float2 panner45 = ( temp_output_28_0 * appendResult48 + appendResult44);
				float4 tex2DNode14 = tex2D( _NoiseTex, panner45 );
				float4 break32 = ( lerpResult50 * tex2DNode14.g * input.ase_color * _Intensity_Color );
				float3 appendResult8 = (float3(break32.r , break32.g , break32.b));
				float2 texCoord54 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult32_g9 = (float4(appendResult8 , saturate( ( lerpResult50 * tex2DNode14.g * saturate( ( ( 1.0 - texCoord54.x ) * tex2DNode14.g * input.ase_color.a ) ) * _Intensity_Alpha ) )));
				half4 finalColor92_g9 = appendResult32_g9;
				half3 positionWS92_g9 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g9 = ase_screenPosNorm;
				half4 screenPos92_g9 = ase_screenPosNorm;
				half nearPlane92_g9 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g9 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g9 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g9 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g9 , positionWS92_g9 , screenUV92_g9 , screenPos92_g9 , nearPlane92_g9 , nearPlaneInvertDistance92_g9 , raycastHarftoneClip92_g9 , raycastMinimumAlpha92_g9 );
				float4 finalColor104_g9 = finalColor92_g9;
				float4 shadowCoord104_g9 = input.uv0;
				float3 positionWS104_g9 = input.positionWS;
				float lightRatio104_g9 = _LightRatio;
				ApplyShadowAtten( finalColor104_g9 , shadowCoord104_g9 , positionWS104_g9 , lightRatio104_g9 );
				float4 finalColor6_g9 = finalColor104_g9;
				float3 normalWS6_g9 = input.normalWS;
				float lightRatio6_g9 = _LightRatio;
				ApplyLightColor( finalColor6_g9 , normalWS6_g9 , lightRatio6_g9 );
				float4 finalColor80_g9 = finalColor6_g9;
				float near80_g9 = _SoftParticleNearFadeDistance;
				float far80_g9 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g9 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g9 = ( 0.0 );
				float4 positionCS58_g9 = float4( 0,0,0,0 );
				float4 positionNDC58_g9 = float4( 0,0,0,0 );
				float3 positionOS58_g9 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g9 , positionNDC58_g9 , positionOS58_g9 );
				float4 positionNDC80_g9 = positionNDC58_g9;
				ApplySoftParticle( finalColor80_g9 , near80_g9 , far80_g9 , fadeOutRange80_g9 , positionNDC80_g9 );
				float4 break64_g9 = finalColor80_g9;
				float3 appendResult76_g9 = (float3(break64_g9.x , break64_g9.y , break64_g9.z));
				
				float3 Color = appendResult76_g9;
				float Alpha = break64_g9.w;

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
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2401.59,47.13741;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-2473.942,582.2296;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-2468.59,441.8374;Inherit;False;Property;_Main_V_Speed;Main_V_Speed;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2476.39,347.5374;Inherit;False;Property;_Main_U_Speed;Main_U_Speed;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-2149.368,81.30009;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2511.12,903.8696;Inherit;False;Property;_Noise_U_Speed;Noise_U_Speed;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;-2198.126,595.9977;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2503.32,998.1692;Inherit;False;Property;_Noise_V_Speed;Noise_V_Speed;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-2054.62,679.4694;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-2319.845,931.6805;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2019.89,123.1374;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;28;-2033.795,449.728;Inherit;False;MMN_Time;-1;;8;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-2285.115,375.3485;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;-2345.003,1055.036;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;39;-1865.509,269.1806;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;52;-1340,174;Inherit;False;224;252;Switch;2;50;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PannerNode;45;-1871.354,783.0349;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;56;-2111.003,1087.036;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1675.59,418.1374;Inherit;True;Property;_NoiseTex;NoiseTex;3;0;Create;True;0;0;0;True;2;Header(NoiseTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1675.59,226.1374;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;True;2;Header(MainTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;-1329,352;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;10;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;25;-1545.59,669.0746;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1119.371,512.4279;Inherit;False;Property;_Intensity_Color;Intensity_Color;6;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;-1265,224;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1617.003,1017.036;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;58;-1319.003,1089.036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1052.926,375.4509;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1336.371,905.4279;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-931.1669,377.1404;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1065.951,656.0502;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;8;-813.2623,379.8674;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;2;-448,528;Inherit;False;204;375;Rendering Options;4;6;4;3;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;38;-872.3712,662.4279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-416,736;Inherit;False;Property;_CullMode;Cull Mode;11;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-416,576;Inherit;False;Property;_BlendSrc;Blend Src;8;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;7;-688,384;Inherit;False;MMN_CommonOutputs;13;;9;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;53;-416,816;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-416,656;Inherit;False;Property;_BlendDst;Blend Dst;9;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-224,576;Inherit;False;Property;_ZWrite;ZWrite;12;2;[HideInInspector];[Enum];Create;False;0;2;Off;0;On;1;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;-448,384;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Trail_Default;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;True;_ZWrite;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;49;0;21;1
WireConnection;43;0;23;1
WireConnection;44;0;43;0
WireConnection;44;1;23;2
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;20;0;49;0
WireConnection;20;1;21;2
WireConnection;40;0;13;0
WireConnection;40;1;12;0
WireConnection;39;0;20;0
WireConnection;39;2;40;0
WireConnection;39;1;28;0
WireConnection;45;0;44;0
WireConnection;45;2;48;0
WireConnection;45;1;28;0
WireConnection;56;0;54;1
WireConnection;14;1;45;0
WireConnection;10;1;39;0
WireConnection;50;0;10;4
WireConnection;50;1;10;2
WireConnection;50;2;51;0
WireConnection;55;0;56;0
WireConnection;55;1;14;2
WireConnection;55;2;25;4
WireConnection;58;0;55;0
WireConnection;31;0;50;0
WireConnection;31;1;14;2
WireConnection;31;2;25;0
WireConnection;31;3;36;0
WireConnection;32;0;31;0
WireConnection;33;0;50;0
WireConnection;33;1;14;2
WireConnection;33;2;58;0
WireConnection;33;3;37;0
WireConnection;8;0;32;0
WireConnection;8;1;32;1
WireConnection;8;2;32;2
WireConnection;38;0;33;0
WireConnection;7;9;8;0
WireConnection;7;28;38;0
WireConnection;1;0;7;2
WireConnection;1;1;7;26
ASEEND*/
//CHKSM=615F430A3CF518B2F0BE664B42312345D91B837C