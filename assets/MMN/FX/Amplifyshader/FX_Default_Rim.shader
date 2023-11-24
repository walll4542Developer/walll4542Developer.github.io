// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Default_Rim"
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
		[HDR]_MainColor("Main Color", Color) = (1,1,1,1)
		[Space()]_VertexOffset("Vertex Offset", Float) = 10
		[HDR][Header(Rim Light)][Space()]_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
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
			#define ASE_SRP_VERSION 999999

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


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float4 _MainTex_ST;
			float4 _RimColor;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _VertexOffset;
			float _Intensity_Color;
			float _Use_G_Channel_Alpha;
			float _RimPower;
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
				float3 vertexValue = ( input.normalOS * _VertexOffset );
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
				float localApplySoftParticle80_g8 = ( 0.0 );
				float localApplyLightColor6_g8 = ( 0.0 );
				float localApplyShadowAtten104_g8 = ( 0.0 );
				half localApplyRaycastingAlpha92_g8 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 lerpResult141 = lerp( ( input.ase_color * tex2DNode5 ) , input.ase_color , _Use_G_Channel_Alpha);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult126 = dot( input.ase_normal , ase_worldViewDir );
				float3 appendResult114 = (float3(( ( _Intensity_Color * ( _MainColor * lerpResult141 ) ) + ( saturate( pow( ( 1.0 - saturate( dotResult126 ) ) , _RimPower ) ) * _RimColor * _RimColor.a ) ).rgb));
				float lerpResult140 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float4 appendResult32_g8 = (float4(appendResult114 , saturate( ( lerpResult140 * _Intensity_Alpha * input.ase_color.a ) )));
				half4 finalColor92_g8 = appendResult32_g8;
				half3 positionWS92_g8 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g8 = ase_screenPosNorm;
				half4 screenPos92_g8 = ase_screenPosNorm;
				half nearPlane92_g8 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g8 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g8 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g8 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g8 , positionWS92_g8 , screenUV92_g8 , screenPos92_g8 , nearPlane92_g8 , nearPlaneInvertDistance92_g8 , raycastHarftoneClip92_g8 , raycastMinimumAlpha92_g8 );
				float4 finalColor104_g8 = finalColor92_g8;
				float4 shadowCoord104_g8 = input.uv0;
				float3 positionWS104_g8 = input.positionWS;
				float lightRatio104_g8 = _LightRatio;
				ApplyShadowAtten( finalColor104_g8 , shadowCoord104_g8 , positionWS104_g8 , lightRatio104_g8 );
				float4 finalColor6_g8 = finalColor104_g8;
				float3 normalWS6_g8 = input.normalWS;
				float lightRatio6_g8 = _LightRatio;
				ApplyLightColor( finalColor6_g8 , normalWS6_g8 , lightRatio6_g8 );
				float4 finalColor80_g8 = finalColor6_g8;
				float near80_g8 = _SoftParticleNearFadeDistance;
				float far80_g8 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g8 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g8 = ( 0.0 );
				float4 positionCS58_g8 = float4( 0,0,0,0 );
				float4 positionNDC58_g8 = float4( 0,0,0,0 );
				float3 positionOS58_g8 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g8 , positionNDC58_g8 , positionOS58_g8 );
				float4 positionNDC80_g8 = positionNDC58_g8;
				ApplySoftParticle( finalColor80_g8 , near80_g8 , far80_g8 , fadeOutRange80_g8 , positionNDC80_g8 );
				float4 break64_g8 = finalColor80_g8;
				float3 appendResult76_g8 = (float3(break64_g8.x , break64_g8.y , break64_g8.z));
				
				float3 Color = appendResult76_g8;
				float Alpha = break64_g8.w;

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
	
	
}
/*ASEBEGIN
Version=18935
3264;207;1610;961;1352;574.5;1;True;False
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;134;-1025.642,536.0845;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;135;-1025.642,377.0854;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;126;-833.6423,376.0854;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1008,-128;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-528,-448;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-784,-128;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;016157555484cb64a8449ff4743ab1c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;127;-697.2421,378.6854;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;143;-462,-82;Inherit;False;279;261;Switch;2;142;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-448,96;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-320,-272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-686.0563,482.4694;Inherit;False;Property;_RimPower;Rim Power;18;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;129;-557.6665,370.9404;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-141,-365;Inherit;False;168;178;Switch;1;141;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;145;-156.9785,-592.8585;Inherit;False;Property;_MainColor;Main Color;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;141;-125,-315;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;130;-397.6671,370.9404;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;132;-252.1232,372.917;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;124,-474;Inherit;False;Property;_Intensity_Color;Intensity_Color;19;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;-332.1232,500.917;Inherit;False;Property;_RimColor;Rim Color;17;1;[HDR];Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1,1,1,1;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;67.02148,-279.8585;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-128,96;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;20;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-108.123,372.917;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;140;-336,-32;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;192,-352;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;320,-352;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;48,-112;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;441.5837,-350.549;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;136;396.9537,96.93616;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;138;401.9643,256.7184;Inherit;False;Property;_VertexOffset;Vertex Offset;16;0;Create;True;0;0;0;False;1;Space();False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;848,-192;Inherit;False;204;375;Rendering Options;3;79;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;44;176,-112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;880,-64;Inherit;False;Property;_BlendDst;Blend Dst;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;880,-144;Inherit;False;Property;_BlendSrc;Blend Src;21;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;880,96;Inherit;False;Property;_ZTest;Z Test;24;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;592,96;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;79;880,16;Inherit;False;Property;_CullMode;Cull Mode;23;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;592,-352;Inherit;False;MMN_CommonOutputs;0;;8;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;848,-352;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;20;MMN/FX/Amplify shader/FX_Default_Rim;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;78;0;True;77;0;1;False;-1;0;False;-1;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;79;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;0;True;147;False;True;0;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;126;0;135;0
WireConnection;126;1;134;0
WireConnection;5;1;6;0
WireConnection;127;0;126;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;129;0;127;0
WireConnection;141;0;65;0
WireConnection;141;1;66;0
WireConnection;141;2;142;0
WireConnection;130;0;129;0
WireConnection;130;1;128;0
WireConnection;132;0;130;0
WireConnection;146;0;145;0
WireConnection;146;1;141;0
WireConnection;133;0;132;0
WireConnection;133;1;131;0
WireConnection;133;2;131;4
WireConnection;140;0;5;4
WireConnection;140;1;5;2
WireConnection;140;2;142;0
WireConnection;61;0;60;0
WireConnection;61;1;146;0
WireConnection;139;0;61;0
WireConnection;139;1;133;0
WireConnection;41;0;140;0
WireConnection;41;1;42;0
WireConnection;41;2;66;4
WireConnection;114;0;139;0
WireConnection;44;0;41;0
WireConnection;137;0;136;0
WireConnection;137;1;138;0
WireConnection;119;9;114;0
WireConnection;119;28;44;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
WireConnection;97;3;137;0
ASEEND*/
//CHKSM=F5794F4031ACFCDF33B762A0CA5F461AE972495D