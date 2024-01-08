// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Test_Dissolve"
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
		_MaskTexture("Mask Texture", 2D) = "white" {}
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_Tiling("Tiling", Vector) = (1,0.7,0,0)
		_Mask("Mask", Range( -1 , 1)) = 0
		_SubTexMask("SubTexMask", Range( -1 , 1)) = 0
		_Dissolve("Dissolve", Range( -0.1 , 1)) = 0.55
		_Eage("Eage", Float) = 0.06
		[ASEEnd]_Power("Power", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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

			#include "Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MaskTexture;
			sampler2D _NoiseTexture;
			CBUFFER_START( UnityPerMaterial )
			float4 _TintColor;
			float2 _Tiling;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Mask;
			float _SubTexMask;
			float _Dissolve;
			float _Eage;
			float _Power;
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
				float localApplySoftParticle80_g4 = ( 0.0 );
				float localApplyLightColor6_g4 = ( 0.0 );
				float localApplyShadowAtten104_g4 = ( 0.0 );
				half localApplyRaycastingAlpha92_g4 = ( 0.0 );
				float2 texCoord103 = input.uv0.xy * _Tiling + float2( 0,0 );
				float V156 = texCoord103.y;
				float temp_output_125_0 = ( 1.0 - V156 );
				float2 UV155 = texCoord103;
				float2 panner104 = ( 1.0 * _Time.y * float2( 0,-0.3 ) + UV155);
				float2 panner116 = ( 1.0 * _Time.y * float2( 0.1,-0.2 ) + UV155);
				float2 panner149 = ( 1.0 * _Time.y * float2( -0.2,-0.2 ) + UV155);
				float Tex161 = ( tex2D( _MaskTexture, panner104 ).r * tex2D( _NoiseTexture, panner116 ).r * tex2D( _NoiseTexture, panner149 ).r );
				float temp_output_93_0 = step( Tex161 , _Dissolve );
				float temp_output_101_0 = ( saturate( ( ( temp_output_125_0 + _SubTexMask ) * Tex161 * temp_output_93_0 ) ) + ( temp_output_93_0 - 0.7 ) + ( temp_output_93_0 - step( Tex161 , ( _Dissolve - _Eage ) ) ) );
				float4 appendResult32_g4 = (float4(( saturate( ( temp_output_125_0 + _Mask ) ) * temp_output_101_0 * _TintColor * _Power ).rgb , saturate( temp_output_101_0 )));
				half4 finalColor92_g4 = appendResult32_g4;
				half3 positionWS92_g4 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g4 = ase_screenPosNorm;
				half4 screenPos92_g4 = ase_screenPosNorm;
				half nearPlane92_g4 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g4 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g4 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g4 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g4 , positionWS92_g4 , screenUV92_g4 , screenPos92_g4 , nearPlane92_g4 , nearPlaneInvertDistance92_g4 , raycastHarftoneClip92_g4 , raycastMinimumAlpha92_g4 );
				float4 finalColor104_g4 = finalColor92_g4;
				float4 shadowCoord104_g4 = input.uv0;
				float3 positionWS104_g4 = input.positionWS;
				float lightRatio104_g4 = _LightRatio;
				ApplyShadowAtten( finalColor104_g4 , shadowCoord104_g4 , positionWS104_g4 , lightRatio104_g4 );
				float4 finalColor6_g4 = finalColor104_g4;
				float3 normalWS6_g4 = input.normalWS;
				float lightRatio6_g4 = _LightRatio;
				ApplyLightColor( finalColor6_g4 , normalWS6_g4 , lightRatio6_g4 );
				float4 finalColor80_g4 = finalColor6_g4;
				float near80_g4 = _SoftParticleNearFadeDistance;
				float far80_g4 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g4 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g4 = ( 0.0 );
				float4 positionCS58_g4 = float4( 0,0,0,0 );
				float4 positionNDC58_g4 = float4( 0,0,0,0 );
				float3 positionOS58_g4 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g4 , positionNDC58_g4 , positionOS58_g4 );
				float4 positionNDC80_g4 = positionNDC58_g4;
				ApplySoftParticle( finalColor80_g4 , near80_g4 , far80_g4 , fadeOutRange80_g4 , positionNDC80_g4 );
				float4 break64_g4 = finalColor80_g4;
				float3 appendResult76_g4 = (float3(break64_g4.x , break64_g4.y , break64_g4.z));

				float3 Color = appendResult76_g4;
				float Alpha = break64_g4.w;

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
Node;AmplifyShaderEditor.Vector2Node;168;-3057.769,-195.8242;Float;False;Property;_Tiling;Tiling;16;0;Create;True;0;0;0;False;0;False;1,0.7;1,0.7;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;103;-2810.945,-222.6648;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,0.7;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;166;-2899.977,32.83108;Inherit;False;1110.395;812.879;Comment;10;161;152;62;115;157;114;148;149;116;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;155;-2586.212,-254.5007;Float;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;157;-2876.341,446.603;Inherit;False;155;UV;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;104;-2650.839,337.7718;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;149;-2640.771,563.9628;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.2,-0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;116;-2650.152,450.534;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,-0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;152;-2687.693,144.0588;Float;True;Property;_NoiseTexture;Noise Texture;14;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;114;-2442.273,346.7937;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;148;-2436.37,539.4625;Inherit;True;Property;_TextureSample2;Texture Sample 2;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-2440.285,157.7332;Inherit;True;Property;_MaskTexture;Mask Texture;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-2126.922,353.1764;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-2572.594,-171.5536;Float;False;V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;-1763.627,-61.89508;Inherit;False;156;V;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;161;-1992.133,354.6508;Float;False;Tex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-1719.729,164.8262;Float;False;Property;_SubTexMask;SubTexMask;18;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;125;-1596.96,-61.45457;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1587.903,412.5539;Inherit;False;161;Tex;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1608.316,562.5328;Float;False;Property;_Dissolve;Dissolve;19;0;Create;True;0;0;0;False;0;False;0.55;0.55;-0.1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-1600.742,693.7388;Float;False;Property;_Eage;Eage;20;0;Create;True;0;0;0;False;0;False;0.06;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-1387.147,678.1678;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;93;-1382.051,450.9758;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1346.795,-3.375849;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-1441.436,185.5876;Inherit;False;161;Tex;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;-1405.502,597.5538;Inherit;False;161;Tex;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1204.011,82.18533;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1685.955,-131.543;Float;False;Property;_Mask;Mask;17;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1135.607,507.7238;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;95;-1214.607,672.7238;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-1083.407,660.2237;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-1361.777,-167.0975;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-980.6079,448.7238;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;120;-893.6932,84.10094;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-563.8113,286.4113;Float;False;Property;_Power;Power;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;-623.3884,124.5782;Float;False;Property;_TintColor;Tint Color;15;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-657.1882,378.4781;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;-870.8815,-160.3228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;144;-247.8727,347.8736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-234.6647,85.17133;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;173;224.1953,275.0724;Inherit;False;204;375;Rendering Options;4;177;176;174;191;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;172;-50.20459,109.4724;Inherit;False;MMN_CommonOutputs;0;;4;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;177;256.1953,323.0724;Inherit;False;Property;_BlendSrc;Blend Src;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;256.1953,403.0725;Inherit;False;Property;_BlendDst;Blend Dst;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;259.1953,483.0725;Inherit;False;Property;_CullMode;Cull Mode;24;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;256,560;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;190;221.7119,110.3283;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Test_Dissolve;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;103;0;168;0
WireConnection;155;0;103;0
WireConnection;104;0;157;0
WireConnection;149;0;157;0
WireConnection;116;0;157;0
WireConnection;114;0;152;0
WireConnection;114;1;116;0
WireConnection;148;0;152;0
WireConnection;148;1;149;0
WireConnection;62;1;104;0
WireConnection;115;0;62;1
WireConnection;115;1;114;1
WireConnection;115;2;148;1
WireConnection;156;0;103;2
WireConnection;161;0;115;0
WireConnection;125;0;158;0
WireConnection;96;0;94;0
WireConnection;96;1;97;0
WireConnection;93;0;164;0
WireConnection;93;1;94;0
WireConnection;118;0;125;0
WireConnection;118;1;119;0
WireConnection;121;0;118;0
WireConnection;121;1;162;0
WireConnection;121;2;93;0
WireConnection;95;0;165;0
WireConnection;95;1;96;0
WireConnection;98;0;93;0
WireConnection;98;1;95;0
WireConnection;147;0;125;0
WireConnection;147;1;146;0
WireConnection;99;0;93;0
WireConnection;99;1;100;0
WireConnection;120;0;121;0
WireConnection;101;0;120;0
WireConnection;101;1;99;0
WireConnection;101;2;98;0
WireConnection;151;0;147;0
WireConnection;144;0;101;0
WireConnection;105;0;151;0
WireConnection;105;1;101;0
WireConnection;105;2;106;0
WireConnection;105;3;150;0
WireConnection;172;9;105;0
WireConnection;172;28;144;0
WireConnection;190;0;172;2
WireConnection;190;1;172;26
ASEEND*/
//CHKSM=C259C9991ED2C61D4E3A23A22F2EEE6DB86D8ADA