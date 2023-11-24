// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Div_Deacal_01"
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
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle][Enum(Noraml,0,Polar,1)]_Type("Type", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Space()]_Noise_Tile_U("Noise_Tile_U", Float) = 1
		_Noise_Tile_V("Noise_Tile_V", Float) = 1
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = 0
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space()]_AddNoise_Tile_U("AddNoise_Tile_U", Float) = 1
		_AddNoise_Tile_V("AddNoise_Tile_V", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		_Cutout("Cutout", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10

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
			Tags { "LightMode"="Decal" }

			Cull Off
			Blend [_BlendSrc] [_BlendDst]
			ZTest Always
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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _AddNoiseTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _SubColor;
			float4 _MainColor;
			float _LightRatio;
			float _ColorGradation;
			float _Cutout;
			float _Use_G_Channel_Alpha;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Distortion_Offset;
			float _Noise_Tile_V;
			float _Noise_Tile_U;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Type;
			float _AddNoise_Tile_V;
			float _AddNoise_Tile_U;
			float _AddNoise_Y_Speed;
			float _AddNoise_X_Speed;
			float _Color_Offset;
			float _Intensity_Color;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Color_Range;
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

				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
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
				float localApplySoftParticle80_g28 = ( 0.0 );
				float localApplyLightColor6_g28 = ( 0.0 );
				float localApplyShadowAtten104_g28 = ( 0.0 );
				half localApplyRaycastingAlpha92_g28 = ( 0.0 );
				float2 appendResult89 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float localApplyScreenSpaceDecal36_g47 = ( 0.0 );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g47 = ase_screenPosNorm;
				float2 decalUV36_g47 = float2( 0,0 );
				float boundingBox36_g47 = 0.0;
				ApplyScreenSpaceDecal( screenPos36_g47 , decalUV36_g47 , boundingBox36_g47 );
				float2 temp_output_383_62 = decalUV36_g47;
				float2 panner90 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult89 + temp_output_383_62);
				float2 CenteredUV15_g36 = ( temp_output_383_62 - float2( 0.5,0.5 ) );
				float2 break17_g36 = CenteredUV15_g36;
				float2 appendResult23_g36 = (float2(( length( CenteredUV15_g36 ) * _AddNoise_Tile_U * 2.0 ) , ( atan2( break17_g36.x , break17_g36.y ) * ( 1.0 / TWO_PI ) * _AddNoise_Tile_V )));
				float2 panner369 = ( 1.0 * _Time.y * appendResult89 + appendResult23_g36);
				float Polar353 = _Type;
				float2 lerpResult373 = lerp( panner90 , panner369 , Polar353);
				float4 tex2DNode85 = tex2D( _AddNoiseTex, lerpResult373 );
				float localApplyScreenSpaceDecal36_g46 = ( 0.0 );
				float4 screenPos36_g46 = ase_screenPosNorm;
				float2 decalUV36_g46 = float2( 0,0 );
				float boundingBox36_g46 = 0.0;
				ApplyScreenSpaceDecal( screenPos36_g46 , decalUV36_g46 , boundingBox36_g46 );
				float2 temp_output_381_62 = decalUV36_g46;
				float2 CenteredUV15_g35 = ( temp_output_381_62 - float2( 0.5,0.5 ) );
				float2 break17_g35 = CenteredUV15_g35;
				float2 appendResult23_g35 = (float2(( length( CenteredUV15_g35 ) * 1.0 * 2.0 ) , ( atan2( break17_g35.x , break17_g35.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 temp_output_365_0 = appendResult23_g35;
				float2 lerpResult364 = lerp( temp_output_381_62 , temp_output_365_0 , Polar353);
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float localApplyScreenSpaceDecal36_g48 = ( 0.0 );
				float4 screenPos36_g48 = ase_screenPosNorm;
				float2 decalUV36_g48 = float2( 0,0 );
				float boundingBox36_g48 = 0.0;
				ApplyScreenSpaceDecal( screenPos36_g48 , decalUV36_g48 , boundingBox36_g48 );
				float2 temp_output_378_62 = decalUV36_g48;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + temp_output_378_62);
				float2 CenteredUV15_g43 = ( temp_output_378_62 - float2( 0.5,0.5 ) );
				float2 break17_g43 = CenteredUV15_g43;
				float2 appendResult23_g43 = (float2(( length( CenteredUV15_g43 ) * _Noise_Tile_U * 2.0 ) , ( atan2( break17_g43.x , break17_g43.y ) * ( 1.0 / TWO_PI ) * _Noise_Tile_V )));
				float2 panner362 = ( 1.0 * _Time.y * appendResult52 + appendResult23_g43);
				float2 lerpResult351 = lerp( panner49 , panner362 , Polar353);
				float temp_output_81_0 = ( tex2D( _NoiseTex, lerpResult351 ).g + _Distortion_Offset );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power ) , ( temp_output_81_0 * _Distortion_Y_Power )));
				float4 tex2DNode5 = tex2D( _MainTex, ( lerpResult364 + appendResult77 ) );
				float lerpResult129 = lerp( ( tex2DNode85.g * tex2DNode5.a ) , ( tex2DNode85.g * tex2DNode5.g ) , _Use_G_Channel_Alpha);
				float temp_output_150_0 = saturate( _Cutout );
				float temp_output_22_0 = ( lerpResult129 - temp_output_150_0 );
				float2 texCoord154 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult366 = lerp( texCoord154.x , temp_output_365_0.x , Polar353);
				float lerpResult136 = lerp( temp_output_22_0 , lerpResult366 , _ColorGradation);
				float4 lerpResult25 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult136 ) * _Color_Range ) ));
				float4 lerpResult128 = lerp( ( lerpResult25 * tex2DNode5 ) , lerpResult25 , _Use_G_Channel_Alpha);
				float3 appendResult243 = (float3(( _Intensity_Color * lerpResult128 * input.ase_color ).rgb));
				float localApplyScreenSpaceDecal36_g42 = ( 0.0 );
				float4 screenPos36_g42 = ase_screenPosNorm;
				float2 decalUV36_g42 = float2( 0,0 );
				float boundingBox36_g42 = 0.0;
				ApplyScreenSpaceDecal( screenPos36_g42 , decalUV36_g42 , boundingBox36_g42 );
				float4 appendResult32_g28 = (float4(appendResult243 , ( (lerpResult25).a * saturate( ( ( temp_output_22_0 / ( ( 1.0 - temp_output_150_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * input.ase_color.a * boundingBox36_g42 )));
				half4 finalColor92_g28 = appendResult32_g28;
				half3 positionWS92_g28 = input.positionWS;
				half4 screenUV92_g28 = ase_screenPosNorm;
				half4 screenPos92_g28 = ase_screenPosNorm;
				half nearPlane92_g28 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g28 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g28 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g28 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g28 , positionWS92_g28 , screenUV92_g28 , screenPos92_g28 , nearPlane92_g28 , nearPlaneInvertDistance92_g28 , raycastHarftoneClip92_g28 , raycastMinimumAlpha92_g28 );
				float4 finalColor104_g28 = finalColor92_g28;
				float4 shadowCoord104_g28 = input.uv0;
				float3 positionWS104_g28 = input.positionWS;
				float lightRatio104_g28 = _LightRatio;
				ApplyShadowAtten( finalColor104_g28 , shadowCoord104_g28 , positionWS104_g28 , lightRatio104_g28 );
				float4 finalColor6_g28 = finalColor104_g28;
				float3 normalWS6_g28 = input.normalWS;
				float lightRatio6_g28 = _LightRatio;
				ApplyLightColor( finalColor6_g28 , normalWS6_g28 , lightRatio6_g28 );
				float4 finalColor80_g28 = finalColor6_g28;
				float near80_g28 = _SoftParticleNearFadeDistance;
				float far80_g28 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g28 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g28 = ( 0.0 );
				float4 positionCS58_g28 = float4( 0,0,0,0 );
				float4 positionNDC58_g28 = float4( 0,0,0,0 );
				float3 positionOS58_g28 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g28 , positionNDC58_g28 , positionOS58_g28 );
				float4 positionNDC80_g28 = positionNDC58_g28;
				ApplySoftParticle( finalColor80_g28 , near80_g28 , far80_g28 , fadeOutRange80_g28 , positionNDC80_g28 );
				float4 break64_g28 = finalColor80_g28;
				float3 appendResult76_g28 = (float3(break64_g28.x , break64_g28.y , break64_g28.z));
				
				float3 Color = appendResult76_g28;
				float Alpha = break64_g28.w;

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
Node;AmplifyShaderEditor.SimpleAddOpNode;67;257.3959,-40.596;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;85;352.1139,-341.7933;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;24;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;04b22506c10d2d94f983b5a17dfef117;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;897.3959,219.4041;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;736.9139,-171.17;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;129;982.1368,91.87659;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;286.5043,-866.4221;Inherit;False;560.6843;374.8151;Color Gradation;5;154;136;134;366;367;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;150;881.3959,407.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;1172.328,252.2551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;993.3959,-312.5959;Inherit;False;Property;_Color_Offset;Color_Offset;34;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;1185.396,-312.5959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;1185.396,-200.5959;Inherit;False;Property;_Color_Range;Color_Range;35;0;Create;True;0;0;0;False;0;False;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1345.396,-312.5959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;1057.396,407.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;1057.396,487.4041;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1313.396,-792.5962;Inherit;False;Property;_SubColor;Sub Color;33;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.2479339,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;34;1489.396,-312.5959;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;1313.396,-584.5962;Inherit;False;Property;_MainColor;Main Color;32;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;1201.396,407.4041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;1585.396,-488.5959;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;1345.396,295.4041;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;1796.496,-384.8074;Inherit;False;179.2;183.4;Switch;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1542.856,-113.0805;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1344.396,414.4041;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;37;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;1857.396,-121.596;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1553.396,295.4041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;1889.396,-504.596;Inherit;False;Property;_Intensity_Color;Intensity_Color;36;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;1819.296,-334.8074;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;44;1697.396,295.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;1697.396,183.4041;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;2097.396,-328.5959;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;2241.396,-328.5959;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2097.396,119.404;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;2769,-5.999969;Inherit;False;244.0042;447.334;Rendering Options;4;113;116;392;393;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;116;2801,42.00003;Inherit;False;Property;_BlendSrc;Blend Src;39;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;2801,122;Inherit;False;Property;_BlendDst;Blend Dst;40;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;2439.667,-260.2651;Inherit;False;MMN_CommonOutputs;0;;28;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;2695.667,-260.2651;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Div_Deacal_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;2;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-535.1873,-438.3698;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;26;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;127;-239.9372,-371.8183;Inherit;False;MMN_Time;-1;;29;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-313.6873,-518.3699;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;136;680.5043,-818.4221;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;366;502.0897,-683.4974;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;-156.1405,11.51596;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;291.8021,-749.8575;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-48.39105,141.8232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;95.60892,141.8232;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-48.39105,254.8232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-365.054,281.6393;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;365;-502.1006,-82.41876;Inherit;False;Polar Coordinates;-1;;35;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;368;-294.8296,-291.1833;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;364;69.51904,-117.9848;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;369;-67.73654,-819.5314;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;367;287.3558,-611.5916;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-319.4434,-731.0309;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;373;102.7433,-737.6987;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-535.1873,-518.3699;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;25;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-384.5941,139.412;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;22;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-378.7266,416.6122;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;23;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;353;-890.2247,-1103.041;Inherit;False;Polar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;372;-557.6451,-901.7488;Inherit;False;Property;_AddNoise_Tile_U;AddNoise_Tile_U;28;0;Create;True;0;0;0;False;1;Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;371;-336.5437,-911.7629;Inherit;False;Polar Coordinates;-1;;36;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;376;751.5607,409.9843;Inherit;False;Property;_Cutout;Cutout;38;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;724.313,-18.57011;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;384;1705.358,472.9948;Inherit;False;MMN_Decal;-1;;42;e77bca24c8bef3c4f881df7c049f144a;0;0;2;FLOAT2;62;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;71;-500.7142,644.2703;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;21;0;Create;True;0;0;0;False;1;Space(10);False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1514.884,521.5655;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-1280.895,489.1039;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-962.9883,450.6263;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;362;-1121.888,208.1087;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;330;-1363.696,112.8774;Inherit;False;Polar Coordinates;-1;;43;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;351;-879.629,266.4249;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1722.189,528.705;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;17;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1719.709,618.8668;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;18;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;126;-1493.193,690.6649;Inherit;False;MMN_Time;-1;;45;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-703.6675,255.2717;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;456.5043,-818.4221;Inherit;False;Property;_ColorGradation;Color Gradation;31;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;350;-1060.799,-1102.432;Inherit;False;Property;_Type;Type;15;2;[Toggle];[Enum];Create;True;2;Header(Color);Space();2;Noraml;0;Polar;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;2838.521,327.9302;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;2838.521,247.9302;Inherit;False;Property;_CullMode;Cull Mode;30;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-1731.501,246.7874;Inherit;False;Property;_Noise_Tile_V;Noise_Tile_V;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;381;-1004.957,-164.6918;Inherit;False;MMN_Decal;-1;;46;e77bca24c8bef3c4f881df7c049f144a;0;0;2;FLOAT2;62;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;90;-72.5873,-555.8698;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-550.3501,-824.8527;Inherit;False;Property;_AddNoise_Tile_V;AddNoise_Tile_V;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;383;-645.9235,-694.0466;Inherit;False;MMN_Decal;-1;;47;e77bca24c8bef3c4f881df7c049f144a;0;0;2;FLOAT2;62;FLOAT;2
Node;AmplifyShaderEditor.FunctionNode;378;-1764.1,9.385422;Inherit;False;MMN_Decal;-1;;48;e77bca24c8bef3c4f881df7c049f144a;0;0;2;FLOAT2;62;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;347;-1730.796,156.8914;Inherit;False;Property;_Noise_Tile_U;Noise_Tile_U;19;0;Create;True;0;0;0;False;1;Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;401.3959,-40.596;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;a6aeb5355da7b0d43b94c52a81a5f6a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;67;0;364;0
WireConnection;67;1;77;0
WireConnection;85;1;373;0
WireConnection;91;0;85;2
WireConnection;91;1;5;2
WireConnection;129;0;92;0
WireConnection;129;1;91;0
WireConnection;129;2;130;0
WireConnection;150;0;376;0
WireConnection;22;0;129;0
WireConnection;22;1;150;0
WireConnection;30;0;26;0
WireConnection;30;1;136;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;43;0;150;0
WireConnection;34;0;32;0
WireConnection;152;0;43;0
WireConnection;152;1;153;0
WireConnection;25;0;29;0
WireConnection;25;1;35;0
WireConnection;25;2;34;0
WireConnection;40;0;22;0
WireConnection;40;1;152;0
WireConnection;125;0;25;0
WireConnection;125;1;5;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;128;0;125;0
WireConnection;128;1;25;0
WireConnection;128;2;130;0
WireConnection;44;0;41;0
WireConnection;46;0;25;0
WireConnection;61;0;60;0
WireConnection;61;1;128;0
WireConnection;61;2;66;0
WireConnection;243;0;61;0
WireConnection;45;0;46;0
WireConnection;45;1;44;0
WireConnection;45;2;66;4
WireConnection;45;3;384;2
WireConnection;119;9;243;0
WireConnection;119;28;45;0
WireConnection;121;0;119;2
WireConnection;121;1;119;26
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;136;0;22;0
WireConnection;136;1;366;0
WireConnection;136;2;134;0
WireConnection;366;0;154;1
WireConnection;366;1;368;0
WireConnection;366;2;367;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;79;0;81;0
WireConnection;79;1;375;0
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;365;1;381;62
WireConnection;368;0;365;0
WireConnection;364;0;381;62
WireConnection;364;1;365;0
WireConnection;364;2;363;0
WireConnection;369;0;371;0
WireConnection;369;2;89;0
WireConnection;373;0;90;0
WireConnection;373;1;369;0
WireConnection;373;2;374;0
WireConnection;353;0;350;0
WireConnection;371;1;383;62
WireConnection;371;3;372;0
WireConnection;371;4;370;0
WireConnection;92;0;85;2
WireConnection;92;1;5;4
WireConnection;52;0;50;0
WireConnection;52;1;187;0
WireConnection;49;0;378;62
WireConnection;49;2;52;0
WireConnection;49;1;126;0
WireConnection;362;0;330;0
WireConnection;362;2;52;0
WireConnection;330;1;378;62
WireConnection;330;3;347;0
WireConnection;330;4;348;0
WireConnection;351;0;49;0
WireConnection;351;1;362;0
WireConnection;351;2;354;0
WireConnection;48;1;351;0
WireConnection;90;0;383;62
WireConnection;90;2;89;0
WireConnection;90;1;127;0
WireConnection;5;1;67;0
ASEEND*/
//CHKSM=3280B1CFE877A081B6BA61461E6ADD8E5D09DC9D