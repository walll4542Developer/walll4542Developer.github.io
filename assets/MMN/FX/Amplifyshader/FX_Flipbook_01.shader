// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_FlipBook_01"
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
		[Header(Main Texture)]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Flipbook)][Space()]_Colums("Colums", Float) = 1
		_Rows("Rows", Float) = 1
		_Speed("Speed", Float) = 10
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_Y_Speed1("Noise_Y_Speed", Float) = 1
		[Header(Distortion)][Space()]_Distortion_X_Power1("Distortion_X_Power", Float) = 0
		_Distortion_Y_Power1("Distortion_Y_Power", Float) = 0
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

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
            #pragma skip_variants FOG_EXP FOG_EXP2
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
			sampler2D _AddNoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AddNoiseTex_ST;
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float _AddNoise_X_Speed;
			float _Intensity_Alpha;
			float _Use_G_Channel_Alpha;
			float _Distortion_Y_Power1;
			float _Distortion_X_Power1;
			float _Noise_Y_Speed1;
			float _Speed;
			float _Rows;
			float _Colums;
			float _Intensity_Color;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _AddNoise_Y_Speed;
			float _LightRatio;
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
				float localApplySoftParticle80_g11 = ( 0.0 );
				float localApplyLightColor6_g11 = ( 0.0 );
				float localApplyShadowAtten104_g11 = ( 0.0 );
				half localApplyRaycastingAlpha92_g11 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float temp_output_4_0_g8 = _Colums;
				float temp_output_5_0_g8 = _Rows;
				float2 appendResult7_g8 = (float2(temp_output_4_0_g8 , temp_output_5_0_g8));
				float totalFrames39_g8 = ( temp_output_4_0_g8 * temp_output_5_0_g8 );
				float2 appendResult8_g8 = (float2(totalFrames39_g8 , temp_output_5_0_g8));
				float clampResult42_g8 = clamp( 0.0 , 0.0001 , ( totalFrames39_g8 - 1.0 ) );
				float temp_output_35_0_g8 = frac( ( ( ( _Speed * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) ) + clampResult42_g8 ) / totalFrames39_g8 ) );
				float2 appendResult29_g8 = (float2(temp_output_35_0_g8 , ( 1.0 - temp_output_35_0_g8 )));
				float2 temp_output_15_0_g8 = ( ( uv_MainTex / appendResult7_g8 ) + ( floor( ( appendResult8_g8 * appendResult29_g8 ) ) / appendResult7_g8 ) );
				float2 appendResult84 = (float2(0.0 , _Noise_Y_Speed1));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner85 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult84 + uv_NoiseTex);
				float temp_output_90_0 = ( tex2D( _NoiseTex, panner85 ).g + -0.5 );
				float2 appendResult94 = (float2(( temp_output_90_0 * _Distortion_X_Power1 ) , ( temp_output_90_0 * _Distortion_Y_Power1 )));
				float4 tex2DNode5 = tex2D( _MainTex, ( temp_output_15_0_g8 + appendResult94 ) );
				float4 lerpResult111 = lerp( ( input.ase_color * tex2DNode5 ) , input.ase_color , _Use_G_Channel_Alpha);
				float lerpResult110 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float2 appendResult118 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 uv_AddNoiseTex = input.uv0.xy * _AddNoiseTex_ST.xy + _AddNoiseTex_ST.zw;
				float2 panner120 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult118 + uv_AddNoiseTex);
				float4 appendResult32_g11 = (float4(( _Intensity_Color * lerpResult111 ).rgb , saturate( ( lerpResult110 * _Intensity_Alpha * input.ase_color.a * tex2D( _AddNoiseTex, panner120 ).g ) )));
				half4 finalColor92_g11 = appendResult32_g11;
				half3 positionWS92_g11 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g11 = ase_screenPosNorm;
				half4 screenPos92_g11 = ase_screenPosNorm;
				half nearPlane92_g11 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g11 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g11 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g11 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g11 , positionWS92_g11 , screenUV92_g11 , screenPos92_g11 , nearPlane92_g11 , nearPlaneInvertDistance92_g11 , raycastHarftoneClip92_g11 , raycastMinimumAlpha92_g11 );
				float4 finalColor104_g11 = finalColor92_g11;
				float4 shadowCoord104_g11 = input.uv0;
				float3 positionWS104_g11 = input.positionWS;
				float lightRatio104_g11 = _LightRatio;
				ApplyShadowAtten( finalColor104_g11 , shadowCoord104_g11 , positionWS104_g11 , lightRatio104_g11 );
				float4 finalColor6_g11 = finalColor104_g11;
				float3 normalWS6_g11 = input.normalWS;
				float lightRatio6_g11 = _LightRatio;
				ApplyLightColor( finalColor6_g11 , normalWS6_g11 , lightRatio6_g11 );
				float4 finalColor80_g11 = finalColor6_g11;
				float near80_g11 = _SoftParticleNearFadeDistance;
				float far80_g11 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g11 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g11 = ( 0.0 );
				float4 positionCS58_g11 = float4( 0,0,0,0 );
				float4 positionNDC58_g11 = float4( 0,0,0,0 );
				float3 positionOS58_g11 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g11 , positionNDC58_g11 , positionOS58_g11 );
				float4 positionNDC80_g11 = positionNDC58_g11;
				ApplySoftParticle( finalColor80_g11 , near80_g11 , far80_g11 , fadeOutRange80_g11 , positionNDC80_g11 );
				float4 break64_g11 = finalColor80_g11;
				float3 appendResult76_g11 = (float3(break64_g11.x , break64_g11.y , break64_g11.z));

				float3 Color = appendResult76_g11;
				float Alpha = break64_g11.w;

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

	Fallback Off
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.RangedFloatNode;82;-2624.207,490.1002;Inherit;False;Property;_Noise_Y_Speed1;Noise_Y_Speed;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;108;-2433.286,561.5753;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-2576.207,282.1;Inherit;False;0;87;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;84;-2448.207,410.1;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;85;-2256.207,282.1;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;87;-2064.207,282.1;Inherit;True;Property;_NoiseTex;NoiseTex;18;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;86;-1968.207,490.1002;Inherit;False;Constant;_Distortion_Offset1;Distortion_Offset;5;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2031.057,40.4481;Inherit;False;Property;_Speed;Speed;17;0;Create;True;0;0;0;False;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1744.207,218.1;Inherit;False;Property;_Distortion_X_Power1;Distortion_X_Power;20;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1744.207,460.1778;Inherit;False;Property;_Distortion_Y_Power1;Distortion_Y_Power;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1725.319,328.0916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;109;-2028.368,147.4833;Inherit;False;MMN_Time;-1;;7;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1893.894,-267.6343;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1840.057,73.44811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1504.207,330.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1814.78,-60.16819;Inherit;False;Property;_Rows;Rows;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1504.207,218.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1813.78,-140.1682;Inherit;False;Property;_Colums;Colums;15;0;Create;True;0;0;0;False;2;Header(Flipbook);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1232,464;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;23;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1360.207,218.1;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;71;-1605.78,-236.1682;Inherit;False;Flipbook;-1;;8;53c2488c220f6564ca6c90721ee16673;2,71,0,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;3;False;5;FLOAT;3;False;24;FLOAT;0;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.RangedFloatNode;115;-1232,544;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;24;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;119;-1088,320;Inherit;False;0;121;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;118;-1008,464;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;117;-1040,624;Inherit;False;MMN_Time;-1;;10;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;113;-660,-178;Inherit;False;242;259;Switch;2;112;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-1192.06,-88.56283;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;66;-714.446,-491.4748;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-970.6148,-165.4661;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;1;Header(Main Texture);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;120;-848,320;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-640,0;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-656,320;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;22;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-576,112;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;26;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-497,-302;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;114;-247,-354;Inherit;False;166;186;Switch;1;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;110;-576,-128;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;111;-224,-304;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-240,16;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-233,-450;Inherit;False;Property;_Intensity_Color;Intensity_Color;25;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-112,16;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;98;516.4039,-73.75314;Inherit;False;204;375;Rendering Options;4;102;101;100;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;43,-361;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;105;281.6301,-220.0984;Inherit;False;MMN_CommonOutputs;0;;11;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;102;549.4039,-25.75313;Inherit;False;Property;_BlendSrc;Blend Src;28;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;544,208;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;547.4039,54.247;Inherit;False;Property;_BlendDst;Blend Dst;29;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;549.4039,134.247;Inherit;False;Property;_CullMode;Cull Mode;30;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;107;522,-223;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_FlipBook_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;0;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;84;1;82;0
WireConnection;85;0;83;0
WireConnection;85;2;84;0
WireConnection;85;1;108;0
WireConnection;87;1;85;0
WireConnection;90;0;87;2
WireConnection;90;1;86;0
WireConnection;78;0;75;0
WireConnection;78;1;109;0
WireConnection;93;0;90;0
WireConnection;93;1;91;0
WireConnection;92;0;90;0
WireConnection;92;1;88;0
WireConnection;94;0;92;0
WireConnection;94;1;93;0
WireConnection;71;13;6;0
WireConnection;71;4;73;0
WireConnection;71;5;74;0
WireConnection;71;2;78;0
WireConnection;118;0;116;0
WireConnection;118;1;115;0
WireConnection;95;0;71;0
WireConnection;95;1;94;0
WireConnection;5;1;95;0
WireConnection;120;0;119;0
WireConnection;120;2;118;0
WireConnection;120;1;117;0
WireConnection;121;1;120;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;110;0;5;4
WireConnection;110;1;5;2
WireConnection;110;2;112;0
WireConnection;111;0;65;0
WireConnection;111;1;66;0
WireConnection;111;2;112;0
WireConnection;41;0;110;0
WireConnection;41;1;42;0
WireConnection;41;2;66;4
WireConnection;41;3;121;2
WireConnection;44;0;41;0
WireConnection;61;0;60;0
WireConnection;61;1;111;0
WireConnection;105;9;61;0
WireConnection;105;28;44;0
WireConnection;107;0;105;2
WireConnection;107;1;105;26
ASEEND*/
//CHKSM=68D999B2A889803E13B6156C2C9E3F4817BB27C7