// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/TEST_Dissolve_Trail_02"
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
		[Header(tcd0.z     Dissolve)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Space()]_M_Speed_X("M_Speed_X", Float) = 0
		_M_Speed_Y("M_Speed_Y", Float) = 0
		[Header(Dissolve Texture)][Space()]_DissolveTex("DissolveTex", 2D) = "white" {}
		[Space()]_D_Speed_X("D_Speed_X", Float) = -1
		_D_Speed_Y("D_Speed_Y", Float) = 0
		_DissolveValue("Dissolve Value", Float) = 0
		[Header(Noise Texture)][Space(5)]_NoiseTex("NoiseTex", 2D) = "white" {}
		_N_Speed_Y("N_Speed_Y", Float) = 0
		_NoiseFower("Noise Fower", Float) = 0.37
		[Header(Sub Glow)][Space(5)]_RangeGlow("Range Glow", Float) = 4.94
		_AlphaGlow("Alpha Glow", Float) = 0.9
		_ColorGlow("Color Glow", Color) = (1,1,1,1)
		_AlphaGradation("Alpha Gradation", Float) = -0.2
		[Toggle(_COLORDISSOLVE_ON)] _ColorDissolve("ColorDissolve", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma shader_feature_local _COLORDISSOLVE_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _DissolveTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _DissolveTex_ST;
			float4 _NoiseTex_ST;
			float4 _ColorGlow;
			float _LightRatio;
			float _RangeGlow;
			float _DissolveValue;
			float _D_Speed_Y;
			float _D_Speed_X;
			float _NoiseFower;
			float _N_Speed_Y;
			float _M_Speed_Y;
			float _M_Speed_X;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _AlphaGlow;
			float _AlphaGradation;
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
				float localApplySoftParticle80_g3 = ( 0.0 );
				float localApplyLightColor6_g3 = ( 0.0 );
				float localApplyShadowAtten104_g3 = ( 0.0 );
				half localApplyRaycastingAlpha92_g3 = ( 0.0 );
				float2 appendResult162 = (float2(_M_Speed_X , _M_Speed_Y));
				float2 texCoord65 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV101 = texCoord65;
				float2 panner159 = ( 1.0 * _Time.y * appendResult162 + UV101);
				float2 appendResult91 = (float2(0.0 , _N_Speed_Y));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner84 = ( 1.0 * _Time.y * appendResult91 + uv_NoiseTex);
				float2 appendResult90 = (float2(_D_Speed_X , _D_Speed_Y));
				float2 uv_DissolveTex = input.uv0.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float2 panner69 = ( 1.0 * _Time.y * appendResult90 + uv_DissolveTex);
				float U97 = ( 1.0 - texCoord65.x );
				#ifdef _COLORDISSOLVE_ON
				float staticSwitch205 = (-2.0 + (input.ase_color.a - 0.0) * (1.0 - -2.0) / (1.0 - 0.0));
				#else
				float staticSwitch205 = _DissolveValue;
				#endif
				float temp_output_66_0 = ( tex2D( _MainTex, ( panner159 + ( ( tex2D( _NoiseTex, panner84 ).r - 0.17 ) * _NoiseFower ) ) ).r * saturate( ( tex2D( _DissolveTex, ( panner69 + float2( 0,0 ) ) ).r + U97 + staticSwitch205 ) ) );
				float temp_output_165_0 = step( 0.3 , temp_output_66_0 );
				float temp_output_186_0 = ( saturate( ( ( temp_output_66_0 - temp_output_165_0 ) * _RangeGlow ) ) * _AlphaGlow );
				float temp_output_171_0 = saturate( temp_output_165_0 );
				float4 appendResult32_g3 = (float4(( ( _ColorGlow * temp_output_186_0 ) + ( temp_output_171_0 * input.ase_color ) ).rgb , ( ( temp_output_171_0 + temp_output_186_0 ) * saturate( ( U97 + _AlphaGradation ) ) * input.ase_color.a )));
				half4 finalColor92_g3 = appendResult32_g3;
				half3 positionWS92_g3 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g3 = ase_screenPosNorm;
				half4 screenPos92_g3 = ase_screenPosNorm;
				half nearPlane92_g3 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g3 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g3 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g3 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g3 , positionWS92_g3 , screenUV92_g3 , screenPos92_g3 , nearPlane92_g3 , nearPlaneInvertDistance92_g3 , raycastHarftoneClip92_g3 , raycastMinimumAlpha92_g3 );
				float4 finalColor104_g3 = finalColor92_g3;
				float4 shadowCoord104_g3 = input.uv0;
				float3 positionWS104_g3 = input.positionWS;
				float lightRatio104_g3 = _LightRatio;
				ApplyShadowAtten( finalColor104_g3 , shadowCoord104_g3 , positionWS104_g3 , lightRatio104_g3 );
				float4 finalColor6_g3 = finalColor104_g3;
				float3 normalWS6_g3 = input.normalWS;
				float lightRatio6_g3 = _LightRatio;
				ApplyLightColor( finalColor6_g3 , normalWS6_g3 , lightRatio6_g3 );
				float4 finalColor80_g3 = finalColor6_g3;
				float near80_g3 = _SoftParticleNearFadeDistance;
				float far80_g3 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g3 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g3 = ( 0.0 );
				float4 positionCS58_g3 = float4( 0,0,0,0 );
				float4 positionNDC58_g3 = float4( 0,0,0,0 );
				float3 positionOS58_g3 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g3 , positionNDC58_g3 , positionOS58_g3 );
				float4 positionNDC80_g3 = positionNDC58_g3;
				ApplySoftParticle( finalColor80_g3 , near80_g3 , far80_g3 , fadeOutRange80_g3 , positionNDC80_g3 );
				float4 break64_g3 = finalColor80_g3;
				float3 appendResult76_g3 = (float3(break64_g3.x , break64_g3.y , break64_g3.z));
				
				float3 Color = appendResult76_g3;
				float Alpha = break64_g3.w;

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
Node;AmplifyShaderEditor.RangedFloatNode;95;-2839.062,126.2936;Inherit;False;Property;_N_Speed_Y;N_Speed_Y;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-2648.426,649.5167;Inherit;False;Property;_D_Speed_Y;D_Speed_Y;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2636.726,574.8167;Inherit;False;Property;_D_Speed_X;D_Speed_X;17;0;Create;True;0;0;0;False;1;Space();False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-2795.291,-152.0048;Inherit;False;0;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;91;-2629.563,6.293605;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;84;-2570.291,-147.3695;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-2615.728,423.6217;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;65;-1080.935,-491.0391;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;90;-2452.426,580.8167;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;161;-2307.476,-289.4447;Inherit;False;Property;_M_Speed_Y;M_Speed_Y;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;96;-875.1173,-428.6192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-864.5389,-508.5251;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;100;-1914.665,1120.648;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;-2363.284,-180.2493;Inherit;True;Property;_NoiseTex;NoiseTex;20;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space(5);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;69;-2316.728,444.257;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.5,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-2311.282,-362.1525;Inherit;False;Property;_M_Speed_X;M_Speed_X;14;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;86;-2023.776,-150.9539;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.17;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;97;-734.164,-433.0191;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-2085.01,453.0417;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1930.717,724.2369;Inherit;False;Property;_DissolveValue;Dissolve Value;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;162;-2081.614,-362.5842;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;202;-1636.008,1186.192;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2169.141,-587.6534;Inherit;True;101;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2038.602,138.265;Inherit;False;Property;_NoiseFower;Noise Fower;22;0;Create;True;0;0;0;False;0;False;0.37;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-1866.883,409.5078;Inherit;True;Property;_DissolveTex;DissolveTex;16;0;Create;True;0;0;0;False;2;Header(Dissolve Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-1799.818,-130.3668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.38;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;205;-1218.551,1156.176;Inherit;False;Property;_ColorDissolve;ColorDissolve;27;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;159;-1899.523,-422.9905;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-1810.081,607.5211;Inherit;False;97;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-1658.521,-147.8783;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;181;-1547.518,530.0402;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;180;-1157.347,764.1772;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1428.595,201.5161;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1040.299,320.4662;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;165;-900.5899,581.6819;Inherit;True;2;0;FLOAT;0.3;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;170;-522.6339,368.5062;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;185;-461.8091,575.1996;Inherit;False;Property;_RangeGlow;Range Glow;23;0;Create;True;0;0;0;False;2;Header(Sub Glow);Space(5);False;4.94;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-300.8428,371.0612;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-293.7908,617.4438;Inherit;False;Property;_AlphaGlow;Alpha Glow;24;0;Create;True;0;0;0;False;0;False;0.9;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;172;-94.83368,373.606;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;192;-62.28658,1237.621;Inherit;False;Property;_AlphaGradation;Alpha Gradation;26;0;Create;True;0;0;0;False;0;False;-0.2;-0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-125.4489,1117.14;Inherit;False;97;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-74.58215,27.1573;Inherit;False;Property;_ColorGlow;Color Glow;25;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;191;113.0405,1172.337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;171;-625.0892,660.3299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;37.19092,493.1996;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;304.0804,286.9344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-280.2598,797.3091;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;164.189,781.1565;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;237.9668,1171.129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;455.0663,532.8062;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;407.3909,989.7293;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;221;1210.48,927.7999;Inherit;False;204;375;Rendering Options;4;225;224;223;228;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;207;884.5424,742.0349;Inherit;False;MMN_CommonOutputs;0;;3;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;74;-1455.355,400.3765;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;224;1242.48,1135.8;Inherit;False;Property;_CullMode;Cull Mode;30;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;1241.48,1055.8;Inherit;False;Property;_BlendDst;Blend Dst;29;1;[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;1242.48,974.7999;Inherit;False;Property;_BlendSrc;Blend Src;28;1;[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;1248,1216;Inherit;False;Property;_ZTest;Z Test;31;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;227;1207.91,744.25;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/TEST_Dissolve_Trail_02;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;91;1;95;0
WireConnection;84;0;83;0
WireConnection;84;2;91;0
WireConnection;90;0;92;0
WireConnection;90;1;93;0
WireConnection;96;0;65;1
WireConnection;101;0;65;0
WireConnection;85;1;84;0
WireConnection;69;0;68;0
WireConnection;69;2;90;0
WireConnection;86;0;85;1
WireConnection;97;0;96;0
WireConnection;152;0;69;0
WireConnection;162;0;160;0
WireConnection;162;1;161;0
WireConnection;202;0;100;4
WireConnection;48;1;152;0
WireConnection;88;0;86;0
WireConnection;88;1;89;0
WireConnection;205;1;105;0
WireConnection;205;0;202;0
WireConnection;159;0;102;0
WireConnection;159;2;162;0
WireConnection;87;0;159;0
WireConnection;87;1;88;0
WireConnection;181;0;48;1
WireConnection;181;1;99;0
WireConnection;181;2;205;0
WireConnection;180;0;181;0
WireConnection;5;1;87;0
WireConnection;66;0;5;1
WireConnection;66;1;180;0
WireConnection;165;1;66;0
WireConnection;170;0;66;0
WireConnection;170;1;165;0
WireConnection;184;0;170;0
WireConnection;184;1;185;0
WireConnection;172;0;184;0
WireConnection;191;0;189;0
WireConnection;191;1;192;0
WireConnection;171;0;165;0
WireConnection;186;0;172;0
WireConnection;186;1;136;0
WireConnection;178;0;133;0
WireConnection;178;1;186;0
WireConnection;176;0;171;0
WireConnection;176;1;100;0
WireConnection;175;0;171;0
WireConnection;175;1;186;0
WireConnection;193;0;191;0
WireConnection;173;0;178;0
WireConnection;173;1;176;0
WireConnection;177;0;175;0
WireConnection;177;1;193;0
WireConnection;177;2;100;4
WireConnection;207;9;173;0
WireConnection;207;28;177;0
WireConnection;227;0;207;2
WireConnection;227;1;207;26
ASEEND*/
//CHKSM=35DD0EF38478778F54B7E773895ED1E4826740E5