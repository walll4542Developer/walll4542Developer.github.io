// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/TEST_Fresnel_Cutout"
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
		_MinTex("MinTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[Header(Fresnel)][Space()]_FrenselRange("FrenselRange", Float) = 2
		[Toggle(_FRESNELINVERSION_ON)] _Fresnelinversion("Fresnel inversion ", Float) = 0
		[Toggle(_UV_WORLDLOCAL_ON)] _UV_WorldLocal("UV_World / Local", Float) = 0
		[ASEEnd][Toggle(_STEP_ON)] _Step("Step", Float) = 0
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
			#pragma shader_feature_local _STEP_ON
			#pragma shader_feature_local _UV_WORLDLOCAL_ON
			#pragma shader_feature_local _FRESNELINVERSION_ON


			sampler2D _MinTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MinTex_ST;
			float4 _NoiseTex_ST;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _FrenselRange;
			float _Intensity_Color;
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
				float localApplySoftParticle80_g5 = ( 0.0 );
				float localApplyLightColor6_g5 = ( 0.0 );
				float localApplyShadowAtten104_g5 = ( 0.0 );
				half localApplyRaycastingAlpha92_g5 = ( 0.0 );
				float2 uv_MinTex = input.uv0.xy * _MinTex_ST.xy + _MinTex_ST.zw;
				#ifdef _UV_WORLDLOCAL_ON
				float3 staticSwitch125 = float3( uv_MinTex ,  0.0 );
				#else
				float3 staticSwitch125 = input.positionWS;
				#endif
				float2 appendResult101 = (float2(0.0 , 0.0));
				float2 panner14 = ( 1.0 * _Time.y * float2( 0,0 ) + ( staticSwitch125 + float3( 0,0,0 ) + float3( appendResult101 ,  0.0 ) ).xy);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV8 = dot( input.normalWS, ase_worldViewDir );
				float fresnelNode8 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV8, _FrenselRange ) );
				#ifdef _FRESNELINVERSION_ON
				float staticSwitch76 = ( 1.0 - fresnelNode8 );
				#else
				float staticSwitch76 = fresnelNode8;
				#endif
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult147 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + 0.0 )));
				float2 panner143 = ( 1.0 * _Time.y * float2( 0,0 ) + appendResult147);
				float temp_output_128_0 = ( saturate( ( ( tex2D( _MinTex, panner14 ).r * 2.0 ) * saturate( staticSwitch76 ) ) ) - saturate( ( tex2D( _NoiseTex, panner143 ).r - 0.0 ) ) );
				#ifdef _STEP_ON
				float staticSwitch118 = step( 0.2 , temp_output_128_0 );
				#else
				float staticSwitch118 = temp_output_128_0;
				#endif
				float4 appendResult32_g5 = (float4(( staticSwitch118 * input.ase_color * _Intensity_Color ).rgb , ( staticSwitch118 * input.ase_color.a * _Intensity_Alpha )));
				half4 finalColor92_g5 = appendResult32_g5;
				half3 positionWS92_g5 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g5 = ase_screenPosNorm;
				half4 screenPos92_g5 = ase_screenPosNorm;
				half nearPlane92_g5 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g5 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g5 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g5 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g5 , positionWS92_g5 , screenUV92_g5 , screenPos92_g5 , nearPlane92_g5 , nearPlaneInvertDistance92_g5 , raycastHarftoneClip92_g5 , raycastMinimumAlpha92_g5 );
				float4 finalColor104_g5 = finalColor92_g5;
				float4 shadowCoord104_g5 = input.uv0;
				float3 positionWS104_g5 = input.positionWS;
				float lightRatio104_g5 = _LightRatio;
				ApplyShadowAtten( finalColor104_g5 , shadowCoord104_g5 , positionWS104_g5 , lightRatio104_g5 );
				float4 finalColor6_g5 = finalColor104_g5;
				float3 normalWS6_g5 = input.normalWS;
				float lightRatio6_g5 = _LightRatio;
				ApplyLightColor( finalColor6_g5 , normalWS6_g5 , lightRatio6_g5 );
				float4 finalColor80_g5 = finalColor6_g5;
				float near80_g5 = _SoftParticleNearFadeDistance;
				float far80_g5 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g5 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g5 = ( 0.0 );
				float4 positionCS58_g5 = float4( 0,0,0,0 );
				float4 positionNDC58_g5 = float4( 0,0,0,0 );
				float3 positionOS58_g5 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g5 , positionNDC58_g5 , positionOS58_g5 );
				float4 positionNDC80_g5 = positionNDC58_g5;
				ApplySoftParticle( finalColor80_g5 , near80_g5 , far80_g5 , fadeOutRange80_g5 , positionNDC80_g5 );
				float4 break64_g5 = finalColor80_g5;
				float3 appendResult76_g5 = (float3(break64_g5.x , break64_g5.y , break64_g5.z));
				
				float3 Color = appendResult76_g5;
				float Alpha = break64_g5.w;

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
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1388.524,-262.7476;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;124;-1466.344,-530.7985;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;101;-1635.04,-304.3211;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-1346.375,272.061;Inherit;False;Property;_FrenselRange;FrenselRange;17;0;Create;True;0;0;0;False;2;Header(Fresnel);Space();False;2;3.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;125;-1181.086,-603.8323;Inherit;False;Property;_UV_WorldLocal;UV_World / Local;19;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;142;-1243.984,534.0358;Inherit;False;0;67;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;107;-1040.468,-263.6742;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;8;-1188.353,221.0245;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-931.0944,-100.0805;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-1019.582,700.5208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;116;-887.4451,347.4688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;14;-798.2977,-147.3634;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;-922.582,560.5208;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-628.9928,-171.9196;Inherit;True;Property;_MinTex;MinTex;13;0;Create;True;0;0;0;False;0;False;-1;None;ceac38e7b02aaf34b99292de1cc0d8b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;143;-795.9321,550.7685;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;76;-756.8272,213.069;Inherit;False;Property;_Fresnelinversion;Fresnel inversion ;18;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-430.7287,58.1335;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;-315.8667,-97.32776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;67;-598.2507,486.2701;Inherit;True;Property;_NoiseTex;NoiseTex;14;0;Create;True;0;0;0;False;0;False;-1;None;7de8119c595bd994dbbb6f989fdb46c0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;129;-259.3958,552.9175;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-120,-64;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;127;16.84483,553.8732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;120;72.36005,-55.41412;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;0.3600006,231.5859;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;128;183.0511,316.5715;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;117;233.6848,179.0443;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;621.4921,417.5972;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;16;0;Create;True;0;0;0;False;0;False;1;0.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;118;360.36,33.58588;Inherit;False;Property;_Step;Step;20;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;102;546.7326,85.1243;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;577.4921,288.5972;Inherit;False;Property;_Intensity_Color;Intensity_Color;15;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;812.1998,167.9319;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;811.2972,26.05904;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;157;1312.976,173.395;Inherit;False;204;375;Rendering Options;4;161;159;158;167;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;158;1343.977,301.3952;Inherit;False;Property;_BlendDst;Blend Dst;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;164;1054.038,29.28659;Inherit;False;MMN_CommonOutputs;0;;5;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;161;1344.977,221.395;Inherit;False;Property;_BlendSrc;Blend Src;21;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;1344.977,381.3954;Inherit;False;Property;_CullMode;Cull Mode;23;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;167;1344,464;Inherit;False;Property;_ZTest;Z Test;24;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;166;1320.525,24.5895;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/TEST_Fresnel_Cutout;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;125;1;124;0
WireConnection;125;0;13;0
WireConnection;107;0;101;0
WireConnection;8;3;95;0
WireConnection;71;0;125;0
WireConnection;71;2;107;0
WireConnection;148;0;142;2
WireConnection;116;0;8;0
WireConnection;14;0;71;0
WireConnection;147;0;142;1
WireConnection;147;1;148;0
WireConnection;6;1;14;0
WireConnection;143;0;147;0
WireConnection;76;1;8;0
WireConnection;76;0;116;0
WireConnection;23;0;76;0
WireConnection;134;0;6;1
WireConnection;67;1;143;0
WireConnection;129;0;67;1
WireConnection;7;0;134;0
WireConnection;7;1;23;0
WireConnection;127;0;129;0
WireConnection;120;0;7;0
WireConnection;128;0;120;0
WireConnection;128;1;127;0
WireConnection;117;0;119;0
WireConnection;117;1;128;0
WireConnection;118;1;128;0
WireConnection;118;0;117;0
WireConnection;115;0;118;0
WireConnection;115;1;102;4
WireConnection;115;2;131;0
WireConnection;114;0;118;0
WireConnection;114;1;102;0
WireConnection;114;2;130;0
WireConnection;164;9;114;0
WireConnection;164;28;115;0
WireConnection;166;0;164;2
WireConnection;166;1;164;26
ASEEND*/
//CHKSM=86F461AD82DD777714EAE673D9AD9EEA15FF56D4