// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/ActorTargetRing"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Color("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("MainTex", 2D) = "white" {}
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
		_StencilValue("StencilRef", Float) = 10
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("StencilComp", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail("StencilZFail", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("StencilPass", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilFail("StencilFail", Float) = 0
		_Opaque("Opaque 적용", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 0

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
			Name "Indicator"
			Tags { "LightMode"="Indicator" }

			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			Stencil
			{
				Ref [_StencilValue]
				Comp [_StencilComp]
				Pass [_StencilPass]
				Fail [_StencilFail]
				ZFail [_StencilZFail]
			}

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

			#include "../Includes/FX_AreaIndicator_CalculateDepth.hlsl"
			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _Color;
			float _NearPlaneAlpha;
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
			float _Opaque;
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
				float localCalculateDepthAlphaTargetRingOpaque34 = ( 0.0 );
				float localFXFinalColorOutputs125_g8 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode7 = tex2D( _MainTex, uv_MainTex );
				float3 appendResult46 = (float3(( tex2DNode7 * input.ase_color * _Color ).rgb));
				float4 appendResult32_g8 = (float4(appendResult46 , ( tex2DNode7.a * input.ase_color.a )));
				float4 finalColor125_g8 = appendResult32_g8;
				float4 texCoord147_g8 = input.screenPos;
				texCoord147_g8.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g8 = texCoord147_g8;
				float4 positionNDC125_g8 = ScreenPos146_g8;
				float4 texCoord140_g8 = input.fogCoord;
				texCoord140_g8.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g8 = texCoord140_g8;
				float4 fogCoord125_g8 = fogCoord139_g8;
				float3 positionWS125_g8 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g8 = normalizedWorldNormal;
				float nearPlaneAlpha125_g8 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g8 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g8 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g8 = _RaycastMinimumAlpha;
				float lightRatio125_g8 = _LightRatio;
				float lightReceive125_g8 = _LightReceive;
				float near125_g8 = _SoftParticleNearFadeDistance;
				float far125_g8 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g8 = _SoftParticleFadeOutRange;
				float softParticle125_g8 = _SoftParticle;
				float mode125_g8 = _Mode;
				float fogReceive125_g8 = _FogReceive;
				float transitionValue125_g8 = _TransitionValue;
				float spawnTransition125_g8 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g8 , positionNDC125_g8 , fogCoord125_g8 , positionWS125_g8 , normalWS125_g8 , nearPlaneAlpha125_g8 , nearPlaneInvertDistance125_g8 , raycastHarftoneClip125_g8 , raycastMinimumAlpha125_g8 , lightRatio125_g8 , lightReceive125_g8 , near125_g8 , far125_g8 , fadeOutRange125_g8 , softParticle125_g8 , mode125_g8 , fogReceive125_g8 , transitionValue125_g8 , spawnTransition125_g8 );
				float4 break64_g8 = finalColor125_g8;
				float3 appendResult76_g8 = (float3(break64_g8.x , break64_g8.y , break64_g8.z));
				float4 appendResult14 = (float4(appendResult76_g8 , break64_g8.w));
				float4 finalColor34 = appendResult14;
				float opaque34 = _Opaque;
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 positionNDC34 = ase_screenPosNorm;
				float4 appendResult39 = (float4(_ZBufferParams.x , _ZBufferParams.y , _ZBufferParams.z , _ZBufferParams.w));
				float4 ZBufferParams34 = appendResult39;
				float3 positionWS34 = input.positionWS;
				CalculateDepthAlphaTargetRingOpaque( finalColor34 , opaque34 , positionNDC34 , ZBufferParams34 , positionWS34 );
				float4 break45 = finalColor34;
				float3 appendResult36 = (float3(break45.x , break45.y , break45.z));

				float3 color = appendResult36;
				float alpha = break45.w;

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
Node;AmplifyShaderEditor.CommentaryNode;33;848,480;Inherit;False;260;483;Stencil Options;5;26;28;29;30;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;608,480;Inherit;False;204;375;Rendering Options;4;20;19;18;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;10;-1216,736;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1344,544;Inherit;True;Property;_MainTex;MainTex;1;0;Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-576,448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-416,320;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;0,320;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;43;-32,512;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;39;0,688;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;37;-32,848;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ZBufferParams;38;-208,688;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;36;736,320;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;592,320;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CustomExpressionNode;34;272,320;Inherit;False; ;7;File;5;True;finalColor;FLOAT4;0,0,0,0;InOut;;Half;False;True;opaque;FLOAT;0;In;;Half;False;True;positionNDC;FLOAT4;0,0,0,0;In;;Float;False;True;ZBufferParams;FLOAT4;0,0,0,0;In;;Float;False;True;positionWS;FLOAT3;0,0,0;In;;Float;False;CalculateDepthAlphaTargetRingOpaque;False;False;0;c37f3afae6c2d6c41b2bc8bd05ae245a;False;6;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT3;0,0,0;False;2;FLOAT;0;FLOAT4;2
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;896,320;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/ActorTargetRing;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Indicator;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;True;255;True;_StencilValue;255;False;;255;False;;7;True;_StencilComp;1;True;_StencilPass;1;True;_StencilFail;1;True;_StencilZFail;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;1;LightMode=Indicator;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-1584,560;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;640,608;Inherit;False;Property;_BlendDst;Blend Dst;25;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;640,688;Inherit;False;Property;_CullMode;Cull Mode;26;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;640,768;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;896,528;Inherit;False;Property;_StencilValue;StencilRef;18;0;Fetch;False;0;0;0;True;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;897,608;Inherit;False;Property;_StencilComp;StencilComp;19;1;[Enum];Fetch;False;0;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;896,688;Inherit;False;Property;_StencilZFail;StencilZFail;20;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.StencilOp;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;896,768;Inherit;False;Property;_StencilPass;StencilPass;21;1;[Enum];Fetch;False;0;0;1;UnityEngine.Rendering.StencilOp;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;896,848;Inherit;False;Property;_StencilFail;StencilFail;22;1;[Enum];Fetch;False;0;0;1;UnityEngine.Rendering.StencilOp;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;9;-1264,368;Inherit;False;Property;_Color;Color;0;0;Create;False;0;0;0;True;0;False;0.5,0.5,0.5,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;0,432;Inherit;False;Property;_Opaque;Opaque 적용;23;0;Create;False;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;640,528;Inherit;False;Property;_BlendSrc;Blend Src;24;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-578.5844,320.0001;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;50;-256,320;Inherit;False;MMN_CommonOutputs;2;;8;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
WireConnection;7;1;40;0
WireConnection;11;0;7;4
WireConnection;11;1;10;4
WireConnection;46;0;12;0
WireConnection;14;0;50;2
WireConnection;14;3;50;26
WireConnection;39;0;38;1
WireConnection;39;1;38;2
WireConnection;39;2;38;3
WireConnection;39;3;38;4
WireConnection;36;0;45;0
WireConnection;36;1;45;1
WireConnection;36;2;45;2
WireConnection;45;0;34;2
WireConnection;34;1;14;0
WireConnection;34;2;32;0
WireConnection;34;3;43;0
WireConnection;34;4;39;0
WireConnection;34;5;37;0
WireConnection;1;0;36;0
WireConnection;1;1;45;3
WireConnection;12;0;7;0
WireConnection;12;1;10;0
WireConnection;12;2;9;0
WireConnection;50;9;46;0
WireConnection;50;28;11;0
ASEEND*/
//CHKSM=771794A60E74F8C8A4B6B39B03AA16DD5BC87B2F