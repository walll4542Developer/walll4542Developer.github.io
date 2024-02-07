// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Line"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w    LineOffset)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		[HDR]_LineColor("Line Color", Color) = (1,1,1,0)
		_LineNoisePower("Line Noise Power", Float) = 0.15
		_LineThickness("Line Thickness", Range( 0 , 1)) = 0.005
		[Header(Rim Light)][Space()]_RimPower("Rim Power", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaTex_ST;
			float4 _NoiseTex_ST;
			float4 _LineColor;
			float4 _MainTex_ST;
			float _LightRatio;
			float _LineThickness;
			float _LineNoisePower;
			float _Noise_X_Speed;
			float _Intensity_Color;
			float _Use_G_Channel_Alpha;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Intensity_Alpha;
			float _RimPower;
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
				float localApplySoftParticle80_g7 = ( 0.0 );
				float localApplyLightColor6_g7 = ( 0.0 );
				float localApplyShadowAtten104_g7 = ( 0.0 );
				half localApplyRaycastingAlpha92_g7 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult156 = lerp( ( tex2DNode5 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float2 appendResult83 = (float2(_Noise_X_Speed , 0.0));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner84 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult83 + uv_NoiseTex);
				float4 tex2DNode85 = tex2D( _NoiseTex, panner84 );
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float temp_output_133_0 = saturate( ( ( tex2DNode85.g * _LineNoisePower ) + tex2D( _AlphaTex, uv_AlphaTex ).g + input.uv0.w ) );
				float temp_output_124_0 = step( ( 1.0 - frac( temp_output_133_0 ) ) , _LineThickness );
				float4 lerpResult142 = lerp( ( lerpResult156 * _Intensity_Color ) , _LineColor , temp_output_124_0);
				float lerpResult155 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult91 = dot( normalizedWorldNormal , ase_worldViewDir );
				float4 appendResult32_g7 = (float4(lerpResult142.rgb , saturate( ( ( input.ase_color.a * ( ( ( lerpResult155 * tex2DNode85.g ) - input.uv0.z ) / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha * ( 1.0 - floor( temp_output_133_0 ) ) * saturate( pow( ( 1.0 - saturate( abs( dotResult91 ) ) ) , _RimPower ) ) ) + temp_output_124_0 ) )));
				half4 finalColor92_g7 = appendResult32_g7;
				half3 positionWS92_g7 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g7 = ase_screenPosNorm;
				half4 screenPos92_g7 = ase_screenPosNorm;
				half nearPlane92_g7 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g7 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g7 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g7 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g7 , positionWS92_g7 , screenUV92_g7 , screenPos92_g7 , nearPlane92_g7 , nearPlaneInvertDistance92_g7 , raycastHarftoneClip92_g7 , raycastMinimumAlpha92_g7 );
				float4 finalColor104_g7 = finalColor92_g7;
				float4 shadowCoord104_g7 = input.uv0;
				float3 positionWS104_g7 = input.positionWS;
				float lightRatio104_g7 = _LightRatio;
				ApplyShadowAtten( finalColor104_g7 , shadowCoord104_g7 , positionWS104_g7 , lightRatio104_g7 );
				float4 finalColor6_g7 = finalColor104_g7;
				float3 normalWS6_g7 = input.normalWS;
				float lightRatio6_g7 = _LightRatio;
				ApplyLightColor( finalColor6_g7 , normalWS6_g7 , lightRatio6_g7 );
				float4 finalColor80_g7 = finalColor6_g7;
				float near80_g7 = _SoftParticleNearFadeDistance;
				float far80_g7 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g7 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g7 = ( 0.0 );
				float4 positionCS58_g7 = float4( 0,0,0,0 );
				float4 positionNDC58_g7 = float4( 0,0,0,0 );
				float3 positionOS58_g7 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g7 , positionNDC58_g7 , positionOS58_g7 );
				float4 positionNDC80_g7 = positionNDC58_g7;
				ApplySoftParticle( finalColor80_g7 , near80_g7 , far80_g7 , fadeOutRange80_g7 , positionNDC80_g7 );
				float4 break64_g7 = finalColor80_g7;
				float3 appendResult76_g7 = (float3(break64_g7.x , break64_g7.y , break64_g7.z));

				float3 Color = appendResult76_g7;
				float Alpha = break64_g7.w;

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
Version=19105
Node;AmplifyShaderEditor.RangedFloatNode;80;-2147.897,520.7534;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;83;-1971.896,520.7534;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;154;-2001.885,693.8821;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;146;-1172.298,1449.817;Inherit;False;1122.575;405.7441;Rim Light;9;96;93;92;94;109;111;91;153;88;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-2099.897,392.7533;Inherit;False;0;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;88;-1122.298,1667.561;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;84;-1779.896,392.7533;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;147;-1566.312,753.9017;Inherit;False;1389;633.5096;Line;12;124;134;141;126;139;132;133;120;136;149;144;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;85;-1587.897,392.7533;Inherit;True;Property;_NoiseTex;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2091.573,163.5992;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;91;-930.2977,1507.562;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-1482.161,803.9017;Inherit;False;Property;_LineNoisePower;Line Noise Power;19;0;Create;True;0;0;0;False;0;False;0.15;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;158;-1537,94;Inherit;False;234;256;Switch;2;157;155;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1520,272;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1867.572,163.5992;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.w    LineOffset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;144;-1453.912,1170.611;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;149;-1436.312,935.4113;Inherit;True;Property;_AlphaTex;AlphaTex;17;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1285.13,806.2177;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-1043.064,928.9852;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;-1456,144;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;133;-908.3118,935.4113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;105;-1134.503,399.6687;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1039.181,279.9934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;93;-374.7223,1499.817;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;139;-764.3118,935.4113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;106;-846.5041,399.6687;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;132;-764.3118,1031.411;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;107;-846.5041,287.6688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-764.3118,1271.411;Inherit;False;Property;_LineThickness;Line Thickness;20;0;Create;True;0;0;0;False;0;False;0.005;0.006;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;108;-622.5041,287.6688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;134;-588.312,1031.411;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;96;-214.7223,1499.817;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;141;-620.312,935.4113;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-1264,80;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-668.7412,461.7571;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;124;-412.3119,1031.411;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;159;-896.8779,-286.1536;Inherit;False;178;180;Switch;1;156;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-1088,-192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-232.5312,156.9867;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;156;-876.8779,-236.1536;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-832,-80;Inherit;False;Property;_Intensity_Color;Intensity_Color;22;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-80,240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;48,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-624,-192;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;143;-688,0;Inherit;False;Property;_LineColor;Line Color;18;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.273585,0.6305643,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;142;-416,-192;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;64;596.0701,110.0891;Inherit;False;204;375;Rendering Options;1;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;628.0701,158.0891;Inherit;False;Property;_BlendSrc;Blend Src;24;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;629.7631,318.0891;Inherit;False;Property;_CullMode;Cull Mode;26;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;633.2477,399.6976;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;150;349.5012,-48.24681;Inherit;False;MMN_CommonOutputs;0;;7;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;63;628.0701,238.0891;Inherit;False;Property;_BlendDst;Blend Dst;25;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;152;596.0701,-49.91093;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;24;MMN/FX/Amplify shader/FX_Dissolve_Div_Line;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.WorldNormalVector;153;-1157.904,1497.042;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;111;-802.2977,1507.562;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;109;-674.2978,1507.562;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-663.1119,1611.346;Inherit;False;Property;_RimPower;Rim Power;21;0;Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;92;-534.7219,1499.817;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;83;0;80;0
WireConnection;84;0;82;0
WireConnection;84;2;83;0
WireConnection;84;1;154;0
WireConnection;85;1;84;0
WireConnection;91;0;153;0
WireConnection;91;1;88;0
WireConnection;5;1;6;0
WireConnection;136;0;85;2
WireConnection;136;1;137;0
WireConnection;120;0;136;0
WireConnection;120;1;149;2
WireConnection;120;2;144;4
WireConnection;155;0;5;4
WireConnection;155;1;5;2
WireConnection;155;2;157;0
WireConnection;133;0;120;0
WireConnection;65;0;155;0
WireConnection;65;1;85;2
WireConnection;93;0;92;0
WireConnection;93;1;94;0
WireConnection;139;0;133;0
WireConnection;106;0;105;3
WireConnection;132;0;133;0
WireConnection;107;0;65;0
WireConnection;107;1;105;3
WireConnection;108;0;107;0
WireConnection;108;1;106;0
WireConnection;134;0;132;0
WireConnection;96;0;93;0
WireConnection;141;0;139;0
WireConnection;124;0;134;0
WireConnection;124;1;126;0
WireConnection;113;0;5;0
WireConnection;113;1;66;0
WireConnection;41;0;66;4
WireConnection;41;1;108;0
WireConnection;41;2;42;0
WireConnection;41;3;141;0
WireConnection;41;4;96;0
WireConnection;156;0;113;0
WireConnection;156;1;66;0
WireConnection;156;2;157;0
WireConnection;138;0;41;0
WireConnection;138;1;124;0
WireConnection;44;0;138;0
WireConnection;61;0;156;0
WireConnection;61;1;60;0
WireConnection;142;0;61;0
WireConnection;142;1;143;0
WireConnection;142;2;124;0
WireConnection;150;9;142;0
WireConnection;150;28;44;0
WireConnection;152;0;150;2
WireConnection;152;1;150;26
WireConnection;111;0;91;0
WireConnection;109;0;111;0
WireConnection;92;0;109;0
ASEEND*/
//CHKSM=915F563135406301A34D058D3E839078BC00A63A