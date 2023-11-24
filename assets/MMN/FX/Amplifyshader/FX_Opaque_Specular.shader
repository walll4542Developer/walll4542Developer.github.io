// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Opaque_Specular"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
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
		[HDR]_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularPower("Specular Power", Range( 1 , 1000)) = 100
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering Options)][Space()]_CullMode("Cull Mode", Float) = 2
		[ASEEnd][Enum(Off,0,On,1)]_ZWrite("Z Write", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		UsePass "MMN/FX/AddPass/ShadowCaster"

		Pass
		{
			Name "Unlit"
			

			Cull [_CullMode]
			Blend Off
			ZTest [_ZTest]
			ZWrite On
			ColorMask RGBA
			

			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma only_renderers d3d11 metal vulkan xboxone xboxseries ps4 playstation 

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
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _SpecularColor;
			float _ZWrite;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Intensity_Color;
			float _SpecularPower;
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
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float dotResult125 = dot( normalizedWorldNormal , ( float3( 0,0,0 ).x + float3( 0,0,0 ).x ) );
				float3 appendResult103 = (float3(( ( input.ase_color * tex2D( _MainTex, uv_MainTex ) * _Intensity_Color ) + ( _SpecularColor * pow( saturate( dotResult125 ) , _SpecularPower ) ) ).rgb));
				float4 appendResult32_g3 = (float4(appendResult103 , 1.0));
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
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"
	FallBack Off
	
	Fallback "Off"
}
/*ASEBEGIN
Version=19002
2553.333;426;2560;1057.667;1880.896;370.0786;1;True;False
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-864.3848,792.2634;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;123;-1056,384;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;125;-816,448;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-848,-128;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;120;-816,544;Inherit;False;Property;_SpecularPower;Specular Power;15;0;Create;False;0;0;0;False;0;False;100;1;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;128;-672,448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;127;-512,448;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-624,-128;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;c5fab1eb02e03e24491e663d25569187;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-512,64;Inherit;False;Property;_Intensity_Color;Intensity_Color;16;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;-528,144;Inherit;False;Property;_SpecularColor;Specular Color;14;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-496,-320;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-288,-96;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-256,160;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-64,-96;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;122;80,-16;Inherit;False;Constant;_Alpha;Alpha;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;64,-96;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;133;222,62;Inherit;False;225;326;Rendering Options;2;131;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;139;240,-96;Inherit;False;MMN_CommonOutputs;1;;3;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;91;272,112;Inherit;False;Property;_CullMode;Cull Mode;17;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Rendering Options);Space();False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;272,192;Inherit;False;Property;_ZTest;Z Test;19;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;273,272;Inherit;False;Property;_ZWrite;Z Write;18;1;[Enum];Create;False;0;2;Off;0;On;1;0;True;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;496,-96;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;0;13;MMN/FX/Amplify shader/FX_Opaque_Specular;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;7;d3d11;metal;vulkan;xboxone;xboxseries;ps4;playstation;0;Off;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;125;0;123;0
WireConnection;125;1;137;0
WireConnection;128;0;125;0
WireConnection;127;0;128;0
WireConnection;127;1;120;0
WireConnection;5;1;6;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;65;2;60;0
WireConnection;119;0;85;0
WireConnection;119;1;127;0
WireConnection;121;0;65;0
WireConnection;121;1;119;0
WireConnection;103;0;121;0
WireConnection;139;9;103;0
WireConnection;139;28;122;0
WireConnection;98;0;139;2
WireConnection;98;1;139;26
ASEEND*/
//CHKSM=AB1EB8C10792025FDEAF35AFF1C0EB98FFBAF101