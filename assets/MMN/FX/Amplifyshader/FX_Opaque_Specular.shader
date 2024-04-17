// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Opaque_Specular"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
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
		[HDR]_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_CameraOffset("CameraOffset", Vector) = (1,1.5,1,0)
		_SpecularPower("Specular Power", Range( 1 , 1000)) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)][Header(Rendering Options)][Space()]_CullMode("Cull Mode", Float) = 2
		[Enum(Off,0,On,1)]_ZWrite("Z Write", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

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

			#pragma exclude_renderers glcore gles gles3 switch

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
			float4 _SpecularColor;
			float4 _MainTex_ST;
			float3 _CameraOffset;
			float _ZWrite;
			float _Intensity_Color;
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
			float _NearPlaneAlpha;
			float _SoftParticleFarFadeDistance;
			float _SpecularPower;
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
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalizeResult162 = normalize( ( ( _WorldSpaceCameraPos + _CameraOffset ) - input.positionOS.xyz ) );
				float dotResult159 = dot( normalizedWorldNormal , normalizeResult162 );
				float3 appendResult103 = (float3(( ( input.ase_color * tex2D( _MainTex, uv_MainTex ) * _Intensity_Color ) + ( _SpecularColor * pow( saturate( dotResult159 ) , _SpecularPower ) ) ).rgb));
				float4 appendResult32_g3 = (float4(appendResult103 , 1.0));
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
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-848,-128;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-624,-128;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;c5fab1eb02e03e24491e663d25569187;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-512,64;Inherit;False;Property;_Intensity_Color;Intensity_Color;20;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;-528,144;Inherit;False;Property;_SpecularColor;Specular Color;17;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-496,-320;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-288,-96;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-64,-96;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;103;64,-96;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;133;496,64;Inherit;False;225;326;Rendering Options;3;131;91;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;91;544,112;Inherit;False;Property;_CullMode;Cull Mode;21;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Rendering Options);Space();False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;544,272;Inherit;False;Property;_ZWrite;Z Write;22;1;[Enum];Create;False;0;2;Off;0;On;1;0;True;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-176.4469,485.5779;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;139;224,-96;Inherit;False;MMN_CommonOutputs;1;;3;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;496,-96;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;100;18;MMN/FX/Amplify shader/FX_Opaque_Specular;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;122;64,0;Inherit;False;Constant;_Alpha;Alpha;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;544,192;Inherit;False;Property;_ZTest;Z Test;23;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;158;-928,496;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;163;-1584,656;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-1264,656;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;165;-1264,816;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;164;-1056,656;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;162;-896,656;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;159;-720,496;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;160;-576,496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;152;-384,496;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;155;-1520,816;Inherit;False;Property;_CameraOffset;CameraOffset;18;0;Create;True;0;0;0;False;0;False;1,1.5,1;1,1.5,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;120;-704,624;Inherit;False;Property;_SpecularPower;Specular Power;19;0;Create;False;0;0;0;False;0;False;1;100;1;1000;0;1;FLOAT;0
WireConnection;5;1;6;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;65;2;60;0
WireConnection;121;0;65;0
WireConnection;121;1;119;0
WireConnection;103;0;121;0
WireConnection;119;0;85;0
WireConnection;119;1;152;0
WireConnection;139;9;103;0
WireConnection;139;28;122;0
WireConnection;98;0;139;2
WireConnection;98;1;139;26
WireConnection;177;0;163;0
WireConnection;177;1;155;0
WireConnection;164;0;177;0
WireConnection;164;1;165;0
WireConnection;162;0;164;0
WireConnection;159;0;158;0
WireConnection;159;1;162;0
WireConnection;160;0;159;0
WireConnection;152;0;160;0
WireConnection;152;1;120;0
ASEEND*/
//CHKSM=AA1BFA7176DBC6964140ADC3F55C16CFB98BFA7C