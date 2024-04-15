// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Opaque"
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
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 100



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
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float _NearPlaneAlpha;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _LightReceive;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticle;
			float _Mode;
			float _FogReceive;
			float _TransitionValue;
			float _SpawnTransition;
			float _Intensity_Color;
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
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

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
				float localFXFinalColorOutputs125_g3 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 break80 = ( input.ase_color * tex2D( _MainTex, uv_MainTex ) * _Intensity_Color );
				float4 appendResult81 = (float4(break80.r , break80.g , break80.b , 0.0));
				float4 appendResult32_g3 = (float4(appendResult81.xyz , break80.a));
				float4 finalColor125_g3 = appendResult32_g3;
				float4 texCoord147_g3 = input.screenPos;
				texCoord147_g3.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g3 = texCoord147_g3;
				float4 positionNDC125_g3 = ScreenPos146_g3;
				float4 texCoord140_g3 = input.fogCoord;
				texCoord140_g3.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g3 = texCoord140_g3;
				float4 fogCoord125_g3 = fogCoord139_g3;
				float3 positionWS125_g3 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g3 = normalizedWorldNormal;
				float nearPlaneAlpha125_g3 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g3 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g3 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g3 = _RaycastMinimumAlpha;
				float lightRatio125_g3 = _LightRatio;
				float lightReceive125_g3 = _LightReceive;
				float near125_g3 = _SoftParticleNearFadeDistance;
				float far125_g3 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g3 = _SoftParticleFadeOutRange;
				float softParticle125_g3 = _SoftParticle;
				float mode125_g3 = _Mode;
				float fogReceive125_g3 = _FogReceive;
				float transitionValue125_g3 = _TransitionValue;
				float spawnTransition125_g3 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g3 , positionNDC125_g3 , fogCoord125_g3 , positionWS125_g3 , normalWS125_g3 , nearPlaneAlpha125_g3 , nearPlaneInvertDistance125_g3 , raycastHarftoneClip125_g3 , raycastMinimumAlpha125_g3 , lightRatio125_g3 , lightReceive125_g3 , near125_g3 , far125_g3 , fadeOutRange125_g3 , softParticle125_g3 , mode125_g3 , fogReceive125_g3 , transitionValue125_g3 , spawnTransition125_g3 );
				float4 break64_g3 = finalColor125_g3;
				float3 appendResult76_g3 = (float3(break64_g3.x , break64_g3.y , break64_g3.z));

				float3 color = appendResult76_g3;
				float alpha = break64_g3.w;

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

	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"

	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.RangedFloatNode;60;-512,64;Inherit;False;Property;_Intensity_Color;Intensity_Color;17;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-704,-288;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-832,-96;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;f41b7975f35d20f4caec19a56f570551;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-288,-96;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;80;-141.7245,-95.95819;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;75;457.4745,95.9418;Inherit;False;221;244;Rendering Options;2;79;84;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;81;18.27551,-144.9582;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;79;478.4756,158.9418;Inherit;False;Property;_CullMode;Cull Mode;18;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;74;191.2755,-56.45819;Inherit;False;MMN_CommonOutputs;0;;3;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT4;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;84;479,239;Inherit;False;Property;_ZTest;Z Test;19;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;83;466,-57;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;100;14;MMN/FX/Amplify shader/FX_Opaque;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;False;0;True;True;0;0;False;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;65;2;60;0
WireConnection;80;0;65;0
WireConnection;81;0;80;0
WireConnection;81;1;80;1
WireConnection;81;2;80;2
WireConnection;74;9;81;0
WireConnection;74;28;80;3
WireConnection;83;0;74;2
WireConnection;83;1;74;26
ASEEND*/
//CHKSM=57D070765A7E2DE0C9C7B00B2831977AF5D5C43D