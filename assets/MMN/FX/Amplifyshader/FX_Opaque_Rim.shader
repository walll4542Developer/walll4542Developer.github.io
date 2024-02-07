// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Opaque_Rim"
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
		[HDR][Header(Rim Light)][Space()]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower1("Rim Power", Float) = 1
		[Toggle]_RimnAddMult("Rimn Add/Mult", Float) = 0
		[Toggle]_OneMinus("One Minus", Float) = 0
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Color("Color", Color) = (1,1,1,1)
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _Color;
			float4 _RimColor;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Intensity_Color;
			float _OneMinus;
			float _RimPower1;
			float _RimnAddMult;
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
				float3 ase_normal : NORMAL;
				float4 ase_texcoord3 : TEXCOORD3;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;

				output.ase_color = input.color;
				output.ase_normal = input.normalOS;
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
				float4 temp_output_65_0 = ( input.ase_color * tex2D( _MainTex, uv_MainTex ) * _Intensity_Color * _Color );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult77 = dot( ase_worldViewDir , input.ase_normal );
				float lerpResult105 = lerp( dotResult77 , ( 1.0 - dotResult77 ) , _OneMinus);
				float4 temp_output_87_0 = ( input.ase_color.a * saturate( pow( ( 1.0 - saturate( lerpResult105 ) ) , _RimPower1 ) ) * _RimColor );
				float4 lerpResult108 = lerp( ( temp_output_65_0 + temp_output_87_0 ) , ( temp_output_65_0 * temp_output_87_0 ) , _RimnAddMult);
				float4 appendResult32_g3 = (float4(lerpResult108.rgb , 1.0));
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
Version=19105
Node;AmplifyShaderEditor.RangedFloatNode;80;-849.9332,461.5524;Inherit;False;Property;_RimPower1;Rim Power;15;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-721.5433,350.0234;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1056,-96;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;82;-561.5438,350.0234;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;-496,480;Inherit;False;Property;_RimColor;Rim Color;14;1;[HDR];Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1,1,1,0;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-704,-288;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-832,-96;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;c5fab1eb02e03e24491e663d25569187;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-512,64;Inherit;False;Property;_Intensity_Color;Intensity_Color;18;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;83;-416,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-288,-96;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-272,352;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;89;702.8427,294.7566;Inherit;False;195;261;Rendering Options;1;91;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;88;400.6436,140.3566;Inherit;False;MMN_CommonOutputs;0;;3;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;91;724.8438,348.7566;Inherit;False;Property;_CullMode;Cull Mode;20;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;736,448;Inherit;False;Property;_ZTest;Z Test;21;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;701,141;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;0;19;MMN/FX/Amplify shader/FX_Opaque_Rim;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;103;-1147.585,569.9393;Inherit;False;384;230;Switch;2;105;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;77;-1158.519,352.1684;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;101;-1377,445;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;100;-1375.999,285;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;79;-904.1191,354.7684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;107;91.25281,433.2311;Inherit;False;384;230;Switch;2;109;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;108;290.2527,465.2311;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;102;-1193.585,502.2727;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;105;-948.585,601.9393;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;105,144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;99.25281,289.5644;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1133.585,715.9393;Inherit;False;Property;_OneMinus;One Minus;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;105.2528,579.2311;Inherit;False;Property;_RimnAddMult;Rimn Add/Mult;16;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;106;-505.785,-311.8274;Inherit;False;Property;_Color;Color;19;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;81;0;79;0
WireConnection;82;0;81;0
WireConnection;82;1;80;0
WireConnection;5;1;6;0
WireConnection;83;0;82;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;65;2;60;0
WireConnection;65;3;106;0
WireConnection;87;0;66;4
WireConnection;87;1;83;0
WireConnection;87;2;85;0
WireConnection;88;9;108;0
WireConnection;98;0;88;2
WireConnection;98;1;88;26
WireConnection;77;0;100;0
WireConnection;77;1;101;0
WireConnection;79;0;105;0
WireConnection;108;0;84;0
WireConnection;108;1;114;0
WireConnection;108;2;109;0
WireConnection;102;0;77;0
WireConnection;105;0;77;0
WireConnection;105;1;102;0
WireConnection;105;2;104;0
WireConnection;84;0;65;0
WireConnection;84;1;87;0
WireConnection;114;0;65;0
WireConnection;114;1;87;0
ASEEND*/
//CHKSM=070C0A0F809DA4CDB60955ADDDE26C92A65326B5