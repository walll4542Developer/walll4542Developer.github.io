// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_NormalDistortion"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector]_Mode("Mode", Float) = -1
		[HideInInspector]_TransitionValue("TransitionValue", Range( 0 , 1)) = 1
		[HideInInspector]_SpawnTransition("SpawnTransition", Range( 0 , 1)) = 0
		[HideInInspector][PerRendererData]_RaycastHarftoneClip("raycastHarftoneClip", Range( 0 , 1)) = 0
		[HideInInspector]_RaycastMinimumAlpha("raycastMinimumAlpha", Range( 0 , 1)) = 0
		[HideInInspector]_NearPlaneAlpha("nearPlaneAlpha", Range( 0 , 1)) = 0
		[HideInInspector][ToggleUI]_NearPlaneInvertDistance("nearPlaneInvertDistance", Range( 0 , 1)) = 0
		[HideInInspector][ToggleUI][Space(10)]_LightReceive("LightReceive", Range( 0 , 1)) = 0
		[HideInInspector]_LightRatio("lightRatio", Range( 0 , 1)) = 1
		[HideInInspector][ToggleUI]_SoftParticle("SoftParticle", Range( 0 , 1)) = 0
		[HideInInspector]_SoftParticleNearFadeDistance("Soft Particle Near Fade", Float) = 0
		[HideInInspector]_SoftParticleFarFadeDistance("Soft Particle Far Fade", Float) = 1
		[HideInInspector][ToggleUI]_FogReceive("FogReceive", Range( 0 , 1)) = 0
		[HideInInspector]_SoftParticleFadeOutRange("SoftParticleFadeOutRange", Range( 0 , 10)) = 1
		[HideInInspector][Toggle(_RAYCAST_ON)] _Raycast("_Raycast", Float) = 1
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "black" {}
		[Toggle]_NormalTexture("NormalTexture", Float) = 0
		_Distortion_Power("Distortion_Power", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 100



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL


		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="Distortion" }

			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA


			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma exclude_renderers glcore gles gles3

			// Unity defined keywords
			#pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float _NearPlaneAlpha;
			float _Distortion_Power;
			float _SpawnTransition;
			float _TransitionValue;
			float _FogReceive;
			float _Mode;
			float _SoftParticle;
			float _SoftParticleFadeOutRange;
			float _SoftParticleNearFadeDistance;
			float _LightReceive;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFarFadeDistance;
			float _NormalTexture;
			CBUFFER_END


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;

			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
				float4 uv1 : TEXCOORD1; 				// xyzw : custom data
				float4 screenPos : TEXCOORD6;			// xyzw : ScreenSpace
				float4 fogCoord : TEXCOORD7; 		    // x : fogcoord				yzw :
				float3 positionWS : TEXCOORD8;
				float4 positionOS : TEXCOORD9;
				float3 normalWS : TEXCOORD10;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord2 = screenPos;

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

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord;
				output.positionWS = vertexInput.positionWS;
				output.positionOS = input.positionOS;
				output.positionCS = vertexInput.positionCS;
				output.screenPos = ComputeScreenPos(vertexInput.positionCS);
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				float localFXFinalColorOutputs125_g12 = ( 0.0 );
				float localGetPositionCSForBending36_g13 = ( 0.0 );
				float4 positionCS36_g13 = float4( 0,0,0,0 );
				float4 positionNDC36_g13 = float4( 0,0,0,0 );
				float3 positionOS36_g13 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS36_g13 , positionNDC36_g13 , positionOS36_g13 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 screenPos = input.ase_texcoord2;
				float4 lerpResult264 = lerp( ( tex2DNode5.g * screenPos ) , float4( UnpackNormalScale( tex2DNode5, 1.0 ) , 0.0 ) , _NormalTexture);
				float4 positionNDC32_g13 = ( positionNDC36_g13 + float4( ( input.ase_color.a * _Distortion_Power * lerpResult264 * -0.05 ).xy, 0.0 , 0.0 ) );
				float3 localSceneColor32_g13 = SceneColor( positionNDC32_g13 );
				float4 appendResult32_g12 = (float4(localSceneColor32_g13 , 1.0));
				float4 finalColor125_g12 = appendResult32_g12;
				float4 texCoord147_g12 = input.screenPos;
				texCoord147_g12.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g12 = texCoord147_g12;
				float4 positionNDC125_g12 = ScreenPos146_g12;
				float4 texCoord140_g12 = input.fogCoord;
				texCoord140_g12.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g12 = texCoord140_g12;
				float4 fogCoord125_g12 = fogCoord139_g12;
				float3 positionWS125_g12 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g12 = normalizedWorldNormal;
				float nearPlaneAlpha125_g12 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g12 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g12 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g12 = _RaycastMinimumAlpha;
				float lightRatio125_g12 = _LightRatio;
				float lightReceive125_g12 = _LightReceive;
				float near125_g12 = _SoftParticleNearFadeDistance;
				float far125_g12 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g12 = _SoftParticleFadeOutRange;
				float softParticle125_g12 = _SoftParticle;
				float mode125_g12 = _Mode;
				float fogReceive125_g12 = _FogReceive;
				float transitionValue125_g12 = _TransitionValue;
				float spawnTransition125_g12 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g12 , positionNDC125_g12 , fogCoord125_g12 , positionWS125_g12 , normalWS125_g12 , nearPlaneAlpha125_g12 , nearPlaneInvertDistance125_g12 , raycastHarftoneClip125_g12 , raycastMinimumAlpha125_g12 , lightRatio125_g12 , lightReceive125_g12 , near125_g12 , far125_g12 , fadeOutRange125_g12 , softParticle125_g12 , mode125_g12 , fogReceive125_g12 , transitionValue125_g12 , spawnTransition125_g12 );
				float4 break64_g12 = finalColor125_g12;
				float3 appendResult76_g12 = (float3(break64_g12.x , break64_g12.y , break64_g12.z));

				float3 color = appendResult76_g12;
				float alpha = break64_g12.w;

				float4 finalColor = float4(color, alpha);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, color, alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}

	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"

	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;266;-237,-158.0162;Inherit;False;263.2906;286.0162;Switch;2;265;264;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-944,-192;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;None;True;0;True;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;184;-512,-64;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-512,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;264;-122.7094,-108.0162;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;66;-247,-622;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;112,-352;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;76;848,-192;Inherit;False;204;375;Rendering Options;3;79;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;79;880,16;Inherit;False;Property;_CullMode;Cull Mode;21;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;880,96;Inherit;False;Property;_ZTest;Z Test;22;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;592,-352;Inherit;False;MMN_CommonOutputs;0;;12;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;77;880,-64;Inherit;False;Property;_BlendDst;Blend Dst;20;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;848,-352;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;16;MMN/FX/Amplify shader/FX_NormalDistortion;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;1;LightMode=Distortion;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-176,-320;Inherit;False;Property;_Distortion_Power;Distortion_Power;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-140.5818,-239.4319;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;-0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-208,32;Inherit;False;Property;_NormalTexture;NormalTexture;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;360,-242;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;880,-144;Inherit;False;Property;_BlendSrc;Blend Src;19;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;268;-795.5818,-409.4319;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;271;256,-352;Inherit;False;MMN_Distortion;-1;;13;4f09efce388c49e4494ed86a775863e4;0;1;54;FLOAT2;0,0;False;1;FLOAT3;2
WireConnection;184;0;5;0
WireConnection;249;0;5;2
WireConnection;249;1;268;0
WireConnection;264;0;249;0
WireConnection;264;1;184;0
WireConnection;264;2;265;0
WireConnection;130;0;66;4
WireConnection;130;1;129;0
WireConnection;130;2;264;0
WireConnection;130;3;270;0
WireConnection;119;9;271;2
WireConnection;119;28;131;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
WireConnection;271;54;130;0
ASEEND*/
//CHKSM=5C3D0E076EC49F5B4734EC7D7B1CEA6BEA59C03A