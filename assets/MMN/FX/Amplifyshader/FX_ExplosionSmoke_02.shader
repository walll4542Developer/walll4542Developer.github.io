// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_ExplosionSmoke_02"
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
		[Header(tcd0.z      Dissolve)][Header(tcd0.w     Emissive Dissolve)][Header(tcd1.x       AlpSub Sensitivity)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Enum(MainTex,0,AlphaTex,1)]_EmissivDissolve("Emissiv Dissolve", Float) = 0
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		_AlphaTexSub("AlphaTex Sub", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_FireColor("Fire Color", Color) = (1,1,1,1)
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
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


			sampler2D _MainTex;
			sampler2D _AlphaTex;
			sampler2D _AlphaTexSub;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _AlphaTexSub_ST;
			float4 _AlphaTex_ST;
			float4 _FireColor;
			float _Color_Range;
			float _EmissivDissolve;
			float _Intensity_Color;
			float _Use_G_Channel_Alpha;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _NearPlaneAlpha;
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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord5 = screenPos;
				
				output.ase_color = input.color;
				output.ase_texcoord3 = input.ase_texcoord1;
				output.ase_texcoord4 = input.ase_texcoord2;
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
				float3 appendResult176 = (float3(input.ase_texcoord3.z , input.ase_texcoord3.w , input.ase_texcoord4.x));
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float4 tex2DNode68 = tex2D( _AlphaTex, uv_AlphaTex );
				float lerpResult168 = lerp( tex2DNode5.g , tex2DNode68.g , _EmissivDissolve);
				float2 uv_AlphaTexSub = input.uv0.xy * _AlphaTexSub_ST.xy + _AlphaTexSub_ST.zw;
				float temp_output_167_0 = ( tex2D( _AlphaTexSub, uv_AlphaTexSub ).g * input.ase_texcoord3.x );
				float4 lerpResult25 = lerp( ( tex2DNode5.a * input.ase_color * _Intensity_Color ) , ( float4( appendResult176 , 0.0 ) * _FireColor ) , saturate( ( ( ( 1.0 - input.uv0.w ) - ( lerpResult168 + temp_output_167_0 ) ) * _Color_Range ) ));
				float lerpResult104 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float temp_output_109_0 = floor( ( ( lerpResult104 - ( lerpResult104 * ( input.uv0.z + tex2DNode68.g + temp_output_167_0 ) ) ) * 10.0 ) );
				float4 appendResult32_g7 = (float4(( lerpResult25 * saturate( ( temp_output_109_0 / 1.5 ) ) ).rgb , saturate( ( lerpResult104 * input.ase_color.a * ( temp_output_109_0 * _Intensity_Alpha ) ) )));
				half4 finalColor92_g7 = appendResult32_g7;
				half3 positionWS92_g7 = input.positionWS;
				float4 screenPos = input.ase_texcoord5;
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
	
	Fallback Off
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.TexCoordVertexDataNode;160;-3888.251,1150.192;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;158;-2845.683,916.4875;Inherit;True;Property;_AlphaTexSub;AlphaTex Sub;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-2848,347;Inherit;False;0;68;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2661.063,-431.3874;Inherit;True;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-2502,635;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;-1920.208,300.062;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-2515.313,1014.001;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;68;-2573,326;Inherit;True;Property;_AlphaTex;AlphaTex;16;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;d837d530b5931a647abf5aa9974b95c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-2454,-431;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;5;Header(tcd0.z      Dissolve);Header(tcd0.w     Emissive Dissolve);Header(tcd1.x       AlpSub Sensitivity);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-2135.012,546.3828;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;104;-1841.792,193.5834;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-1530.809,74.86862;Inherit;False;Property;_EmissivDissolve;Emissiv Dissolve;15;1;[Enum];Create;True;2;Header(Color);Space();2;MainTex;0;AlphaTex;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-1624,-281;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;168;-1495.194,-39.80968;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1543,569;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;186;-1258.184,-263.8526;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-1298.227,-23.99916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1414.8,551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;173;-1136.227,-101.8075;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;178;-1446.766,-652.39;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;175;-1458.157,-847.0102;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1280,549.1667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1136,16;Inherit;False;Property;_Color_Range;Color_Range;21;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-892,-225;Inherit;False;Property;_Intensity_Color;Intensity_Color;22;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-1080,96;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-1204.053,453.8838;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;109;-1156,551.1667;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-976,-96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;176;-1178.312,-810.4349;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;35;-1159,-540;Inherit;False;Property;_FireColor;Fire Color;20;1;[HDR];Create;True;0;0;0;False;2;Header(Color);Space();False;1,1,1,1;11.57831,2.303539,1.037679,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-976.0532,468.8838;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;111;-981,642.1667;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;-832,-96;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;-909.3115,-711.4349;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-888.6926,-402.8675;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;25;-681,-447;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;118;-861.6394,636.3303;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-497.8504,348.1041;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-302.6394,-152.6696;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;97;204.1815,51.37476;Inherit;False;204;375;Rendering Options;4;101;100;98;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;157;-380.0532,346.8838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-3565.452,1002.413;Inherit;False;Property;_AlpSubXSpeed;AlpSub X Speed;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;94;-43.61536,-104.5462;Inherit;False;MMN_CommonOutputs;0;;7;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;183;-3572.452,1113.413;Inherit;False;Property;_AlpSubYSpeed;AlpSub Y Speed;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;185;-3560.061,896.9521;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;179;-3780.551,744.1957;Inherit;False;0;158;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-3345.452,760.4128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;101;236.1815,99.37478;Inherit;False;Property;_BlendSrc;Blend Src;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;-3293.452,998.4129;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;180;-3180.995,835.1359;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;98;235.1815,179.3749;Inherit;False;Property;_BlendDst;Blend Dst;24;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;240,336;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;236.1815,259.3749;Inherit;False;Property;_CullMode;Cull Mode;25;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;103;214.4702,-104.7017;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_ExplosionSmoke_02;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;0;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;167;0;158;2
WireConnection;167;1;160;1
WireConnection;68;1;67;0
WireConnection;5;1;6;0
WireConnection;88;0;24;3
WireConnection;88;1;68;2
WireConnection;88;2;167;0
WireConnection;104;0;5;4
WireConnection;104;1;5;2
WireConnection;104;2;106;0
WireConnection;168;0;5;2
WireConnection;168;1;68;2
WireConnection;168;2;169;0
WireConnection;81;0;104;0
WireConnection;81;1;88;0
WireConnection;186;0;82;4
WireConnection;174;0;168;0
WireConnection;174;1;167;0
WireConnection;22;0;104;0
WireConnection;22;1;81;0
WireConnection;173;0;186;0
WireConnection;173;1;174;0
WireConnection;110;0;22;0
WireConnection;109;0;110;0
WireConnection;32;0;173;0
WireConnection;32;1;33;0
WireConnection;176;0;175;3
WireConnection;176;1;175;4
WireConnection;176;2;178;1
WireConnection;155;0;109;0
WireConnection;155;1;156;0
WireConnection;111;0;109;0
WireConnection;34;0;32;0
WireConnection;177;0;176;0
WireConnection;177;1;35;0
WireConnection;85;0;5;4
WireConnection;85;1;66;0
WireConnection;85;2;60;0
WireConnection;25;0;85;0
WireConnection;25;1;177;0
WireConnection;25;2;34;0
WireConnection;118;0;111;0
WireConnection;45;0;104;0
WireConnection;45;1;66;4
WireConnection;45;2;155;0
WireConnection;119;0;25;0
WireConnection;119;1;118;0
WireConnection;157;0;45;0
WireConnection;94;9;119;0
WireConnection;94;28;157;0
WireConnection;185;0;160;2
WireConnection;184;0;179;0
WireConnection;184;1;185;0
WireConnection;181;0;182;0
WireConnection;181;1;183;0
WireConnection;180;0;184;0
WireConnection;180;2;181;0
WireConnection;103;0;94;2
WireConnection;103;1;94;26
ASEEND*/
//CHKSM=7B6C2CF09F79F9D4844408DF9FACFE61523AFBA2