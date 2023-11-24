// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Panning_2CVertexOffset_2"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w    VertexOffset Power)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha1("Use_G_Channel_Alpha", Float) = 0
		[Space()]_Main_X_Speed("Main_X_Speed", Float) = 1
		[Header(Sub Texture)][Space()]_SubTex("SubTex", 2D) = "white" {}
		_Sub_X_Speed("Sub_X_Speed", Float) = -0.5
		_Sub_Y_Speed("Sub_Y_Speed", Float) = 0.5
		_Sub_Pow("Sub_Pow", Float) = 1
		_Sub_Range("Sub_Range", Float) = 1
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
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

			#pragma exclude_renderers glcore gles gles3 

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
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MaskTex;
			sampler2D _MainTex;
			sampler2D _SubTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _SubTex_ST;
			float4 _MaskTex_ST;
			float4 _SubColor;
			float4 _MainColor;
			float _Sub_Y_Speed;
			float _Sub_X_Speed;
			float _Sub_Pow;
			float _Intensity_Color;
			float _Color_Range;
			float _ColorGradation;
			float _Color_Offset;
			float _LightRatio;
			float _Main_X_Speed;
			float _Use_G_Channel_Alpha1;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Sub_Range;
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

				float2 uv_MaskTex = input.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 tex2DNode5 = tex2Dlod( _MaskTex, float4( uv_MaskTex, 0, 0.0) );
				float lerpResult146 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha1);
				float2 appendResult52 = (float2(_Main_X_Speed , 0.0));
				float2 uv_MainTex = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + uv_MainTex);
				float temp_output_54_0 = ( lerpResult146 * tex2Dlod( _MainTex, float4( panner49, 0, 0.0) ).g );
				
				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
				output.ase_color = input.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_54_0 * input.normalOS * input.texcoord.w );
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
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MaskTex, uv_MaskTex );
				float lerpResult146 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha1);
				float2 appendResult52 = (float2(_Main_X_Speed , 0.0));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + uv_MainTex);
				float temp_output_54_0 = ( lerpResult146 * tex2D( _MainTex, panner49 ).g );
				float temp_output_22_0 = ( temp_output_54_0 - input.uv0.z );
				float2 texCoord141 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult142 = lerp( temp_output_22_0 , texCoord141.x , _ColorGradation);
				float4 lerpResult25 = lerp( _MainColor , _SubColor , saturate( ( ( _Color_Offset + lerpResult142 ) * _Color_Range ) ));
				float4 lerpResult149 = lerp( ( tex2DNode5 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha1);
				float2 appendResult116 = (float2(_Sub_X_Speed , _Sub_Y_Speed));
				float2 uv_SubTex = input.uv0.xy * _SubTex_ST.xy + _SubTex_ST.zw;
				float2 appendResult121 = (float2(uv_SubTex.x , uv_SubTex.y));
				float2 panner117 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult116 + appendResult121);
				float saferPower130 = abs( tex2D( _SubTex, panner117 ).r );
				float4 appendResult32_g9 = (float4(( ( lerpResult25 * lerpResult149 * _Intensity_Color ) + ( lerpResult25 * _Sub_Pow * pow( saferPower130 , _Sub_Range ) ) ).rgb , ( input.ase_color.a * saturate( ( ( temp_output_22_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * (lerpResult25).a )));
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
Version=19200
Node;AmplifyShaderEditor.RangedFloatNode;50;-3296.838,291.2646;Inherit;False;Property;_Main_X_Speed;Main_X_Speed;15;0;Create;True;0;0;0;False;1;Space();False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-3120.838,291.2646;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;97;-3079.819,451.9888;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;49;-2928.838,163.2646;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-2736.837,-60.73541;Inherit;True;Property;_MaskTex;MaskTex;21;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;91227f7ffeda1d840a77cc0ddc7d9298;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-2736.837,162.2646;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.w    VertexOffset Power);Header(Main Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1737.835,62.78572;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1823.937,286.7717;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;139;-1823.818,-638.6071;Inherit;False;422.6843;276.8151;Color Gradation;3;142;141;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1504,0;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;141;-1791.818,-511.6071;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1441.978,-368.8051;Inherit;False;Property;_Color_Offset;Color_Offset;25;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;142;-1567.818,-590.6071;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;-2525.824,807.016;Inherit;False;Property;_Sub_X_Speed;Sub_X_Speed;17;0;Create;True;0;0;0;False;0;False;-0.5;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-2525.824,887.0162;Inherit;False;Property;_Sub_Y_Speed;Sub_Y_Speed;18;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1281.978,-249.8049;Inherit;False;Property;_Color_Range;Color_Range;26;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;114;-2632.824,625.0161;Inherit;False;0;111;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1288.978,-525.8051;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;116;-2349.824,807.016;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1089.978,-368.8051;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;115;-2308.805,967.7409;Inherit;False;MMN_Time;-1;;8;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;-2369.987,658.47;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;29;-1153.551,-720.3333;Inherit;False;Property;_SubColor;Sub Color;24;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.9292453,0.9942631,1,0.8235294;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;43;-1251.229,145.0185;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;133;-2286.863,-105.0722;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;117;-2157.824,679.016;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;35;-1152.551,-909.3331;Inherit;False;Property;_MainColor;Main Color;23;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-695.8846,-78.78841;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;34;-886.3137,-403.0549;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-741.7597,264.5276;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;-1841.986,636.4701;Inherit;True;Property;_SubTex;SubTex;16;0;Create;True;0;0;0;False;2;Header(Sub Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;25;-907.0603,-777.7762;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-1312.933,619.3188;Inherit;False;Property;_Sub_Range;Sub_Range;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-617.085,360.7324;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;29;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;127;-377.9657,242.0853;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-756.1273,-333.2703;Inherit;False;Property;_Sub_Pow;Sub_Pow;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-581.5729,-798.9911;Inherit;False;Property;_Intensity_Color;Intensity_Color;28;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;134;-372.2718,105.313;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-388.7164,-892.0801;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-472.7269,-568.1386;Inherit;True;3;3;0;COLOR;1,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;-214.1053,-28.71738;Inherit;True;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;138;-158.7883,248.416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;93;194.3966,724.1251;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;132;-1668.039,490.6282;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;1188.546,254.6804;Inherit;False;190;475;Rendering Options;4;82;81;79;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;92;203.1675,563.2053;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-90.28125,-700.6692;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;190.2209,-12.71652;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;1204.546,558.6804;Inherit;False;Property;_CullMode;Cull Mode;32;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1204.546,478.6803;Inherit;False;Property;_BlendDst;Blend Dst;31;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;1200,640;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;1204.546,398.6803;Inherit;False;Property;_BlendSrc;Blend Src;30;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;667.2451,407.5365;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;77;573.1427,-357.4293;Inherit;False;MMN_CommonOutputs;0;;9;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;971.4738,-173.3796;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Dissolve_Div_Panning_2CVertexOffset_2;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-1791.818,-590.6071;Inherit;False;Property;_ColorGradation;Color Gradation;22;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-2117.049,-70.19476;Inherit;False;250.3594;260.6834;Switch;2;146;145;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2093.702,108.8052;Inherit;False;Property;_Use_G_Channel_Alpha1;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;146;-2029.702,-20.19476;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;147;-282.229,-379.521;Inherit;False;182.0251;190.676;Switch;1;149;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;149;-252.229,-326.521;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-535.2754,-303.4819;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-3248.838,163.2646;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2960.838,-60.73541;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;130;-1120.305,504.944;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;52;0;50;0
WireConnection;49;0;47;0
WireConnection;49;2;52;0
WireConnection;49;1;97;0
WireConnection;5;1;6;0
WireConnection;48;1;49;0
WireConnection;54;0;146;0
WireConnection;54;1;48;2
WireConnection;22;0;54;0
WireConnection;22;1;24;3
WireConnection;142;0;22;0
WireConnection;142;1;141;1
WireConnection;142;2;140;0
WireConnection;30;0;26;0
WireConnection;30;1;142;0
WireConnection;116;0;113;0
WireConnection;116;1;112;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;121;0;114;1
WireConnection;121;1;114;2
WireConnection;43;0;24;3
WireConnection;133;0;5;0
WireConnection;117;0;121;0
WireConnection;117;2;116;0
WireConnection;117;1;115;0
WireConnection;34;0;32;0
WireConnection;40;0;22;0
WireConnection;40;1;43;0
WireConnection;111;1;117;0
WireConnection;25;0;35;0
WireConnection;25;1;29;0
WireConnection;25;2;34;0
WireConnection;127;0;40;0
WireConnection;127;1;126;0
WireConnection;134;0;25;0
WireConnection;61;0;25;0
WireConnection;61;1;149;0
WireConnection;61;2;125;0
WireConnection;109;0;25;0
WireConnection;109;1;129;0
WireConnection;109;2;130;0
WireConnection;46;0;134;0
WireConnection;138;0;127;0
WireConnection;132;0;54;0
WireConnection;137;0;61;0
WireConnection;137;1;109;0
WireConnection;45;0;66;4
WireConnection;45;1;138;0
WireConnection;45;2;46;0
WireConnection;86;0;132;0
WireConnection;86;1;92;0
WireConnection;86;2;93;4
WireConnection;77;9;137;0
WireConnection;77;28;45;0
WireConnection;84;0;77;2
WireConnection;84;1;77;26
WireConnection;84;3;86;0
WireConnection;146;0;5;4
WireConnection;146;1;5;2
WireConnection;146;2;145;0
WireConnection;149;0;94;0
WireConnection;149;1;66;0
WireConnection;149;2;145;0
WireConnection;94;0;133;0
WireConnection;94;1;66;0
WireConnection;130;0;111;1
WireConnection;130;1;131;0
ASEEND*/
//CHKSM=28AC70E68AD66B9ED07DFB3951604C828307D880