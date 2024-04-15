// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/Stencil/FX_Dissolve_Div_Distortion_2C_Stencil"
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
		[Header(tcd0.z     Dissolve)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Header(Color)][Space()]_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[Header(Stencil Options)][Space()]_StencilRef("Stencil Ref", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comp", Float) = 8
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("Stencil Pass", Float) = 2
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

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


			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			Stencil
			{
				Ref [_StencilRef]
				Comp [_StencilComp]
				Pass [_StencilPass]
				Fail Keep
				ZFail Keep
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

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _SubColor;
			float _NearPlaneAlpha;
			float _Use_G_Channel_Alpha;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Color_Offset;
			float _Intensity_Color;
			float _Color_Range;
			float _SpawnTransition;
			float _FogReceive;
			float _Mode;
			float _SoftParticle;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _LightReceive;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _TransitionValue;
			float _Intensity_Alpha;
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
				float localFXFinalColorOutputs125_g5 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + uv_NoiseTex);
				float temp_output_81_0 = ( tex2D( _NoiseTex, panner49 ).g + -0.5 );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power * input.uv0.w ) , ( temp_output_81_0 * _Distortion_Y_Power * input.uv0.w )));
				float4 tex2DNode5 = tex2D( _MainTex, ( uv_MainTex + appendResult77 ) );
				float lerpResult100 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float temp_output_22_0 = ( lerpResult100 - input.uv0.z );
				float4 lerpResult25 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + temp_output_22_0 ) * _Color_Range ) ));
				float4 lerpResult101 = lerp( ( lerpResult25 * tex2DNode5 ) , lerpResult25 , _Use_G_Channel_Alpha);
				float4 appendResult32_g5 = (float4(( _Intensity_Color * lerpResult101 * input.ase_color ).rgb , ( (lerpResult25).a * saturate( ( ( temp_output_22_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * input.ase_color.a )));
				float4 finalColor125_g5 = appendResult32_g5;
				float4 texCoord147_g5 = input.screenPos;
				texCoord147_g5.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g5 = texCoord147_g5;
				float4 positionNDC125_g5 = ScreenPos146_g5;
				float4 texCoord140_g5 = input.fogCoord;
				texCoord140_g5.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g5 = texCoord140_g5;
				float4 fogCoord125_g5 = fogCoord139_g5;
				float3 positionWS125_g5 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g5 = normalizedWorldNormal;
				float nearPlaneAlpha125_g5 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g5 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g5 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g5 = _RaycastMinimumAlpha;
				float lightRatio125_g5 = _LightRatio;
				float lightReceive125_g5 = _LightReceive;
				float near125_g5 = _SoftParticleNearFadeDistance;
				float far125_g5 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g5 = _SoftParticleFadeOutRange;
				float softParticle125_g5 = _SoftParticle;
				float mode125_g5 = _Mode;
				float fogReceive125_g5 = _FogReceive;
				float transitionValue125_g5 = _TransitionValue;
				float spawnTransition125_g5 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g5 , positionNDC125_g5 , fogCoord125_g5 , positionWS125_g5 , normalWS125_g5 , nearPlaneAlpha125_g5 , nearPlaneInvertDistance125_g5 , raycastHarftoneClip125_g5 , raycastMinimumAlpha125_g5 , lightRatio125_g5 , lightReceive125_g5 , near125_g5 , far125_g5 , fadeOutRange125_g5 , softParticle125_g5 , mode125_g5 , fogReceive125_g5 , transitionValue125_g5 , spawnTransition125_g5 );
				float4 break64_g5 = finalColor125_g5;
				float3 appendResult76_g5 = (float3(break64_g5.x , break64_g5.y , break64_g5.z));

				float3 color = appendResult76_g5;
				float alpha = break64_g5.w;

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
Node;AmplifyShaderEditor.FunctionNode;95;-3205.07,566.7941;Inherit;False;MMN_Time;-1;;4;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-3312,240;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;52;-3184,368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-2992,240;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2704,448;Inherit;False;Constant;_Distortion_Offset;Distortion_Offset;5;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-2800,240;Inherit;True;Property;_NoiseTex;NoiseTex;18;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-2461.112,285.9915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2480,416;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;22;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2480,176;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;21;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-2467.771,528.8877;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2240,176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2240,288;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;-2096,176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2224,-16;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;103;-1549.643,81.02454;Inherit;False;298;263;Switch;2;104;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-1984,-16;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1840,-16;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;104;-1516.475,250.4018;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1412.269,522.1508;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;100;-1443.643,131.0245;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1248,-288;Inherit;False;Property;_Color_Offset;Color_Offset;25;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1159.068,477.851;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1056,-176;Inherit;False;Property;_Color_Range;Color_Range;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1056,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-896,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-928,-768;Inherit;False;Property;_SubColor;Sub Color;24;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;-928,-560;Inherit;False;Property;_MainColor;Main Color;23;0;Create;True;0;0;0;False;2;Header(Color);Space();False;0.5019608,0.5019608,0.5019608,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;43;-1155.495,589.081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;-752,-288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-897,439;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-896,320;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;-656,-464;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-656,-160;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-688,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-424,-370;Inherit;False;171;177;Switch;1;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;66;-384,-96;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;-544,320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;101;-400,-320;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-352,-480;Inherit;False;Property;_Intensity_Color;Intensity_Color;27;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;-512,208;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-144,96;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;528,-64;Inherit;False;185;296;Stencil Options;3;99;98;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;85;296.935,-66.25128;Inherit;False;204;375;Rendering Options;4;89;87;86;105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-144,-304;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;86;328.9353,141.7491;Inherit;False;Property;_CullMode;Cull Mode;35;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;544,-16;Inherit;False;Property;_StencilRef;Stencil Ref;29;0;Fetch;True;0;0;0;True;2;Header(Stencil Options);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;90;48.79959,-215.9475;Inherit;False;MMN_CommonOutputs;0;;5;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;105;336,224;Inherit;False;Property;_ZTest;Z Test;31;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;327.9353,61.74883;Inherit;False;Property;_BlendDst;Blend Dst;34;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;544,144;Inherit;False;Property;_StencilPass;Stencil Pass;32;1;[Enum];Fetch;True;0;1;Option1;0;1;UnityEngine.Rendering.StencilOp;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;328.9353,-18.25124;Inherit;False;Property;_BlendSrc;Blend Src;33;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;544,64;Inherit;False;Property;_StencilComp;Stencil Comp;30;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;92;295.7972,-218.1724;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/Stencil/FX_Dissolve_Div_Distortion_2C_Stencil;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;True;255;True;_StencilRef;255;False;;255;False;;7;True;_StencilComp;1;True;_StencilPass;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3360,448;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-3360,368;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;52;0;106;0
WireConnection;52;1;51;0
WireConnection;49;0;47;0
WireConnection;49;2;52;0
WireConnection;49;1;95;0
WireConnection;48;1;49;0
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;72;2;82;4
WireConnection;79;0;81;0
WireConnection;79;1;78;0
WireConnection;79;2;82;4
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;67;0;6;0
WireConnection;67;1;77;0
WireConnection;5;1;67;0
WireConnection;100;0;5;4
WireConnection;100;1;5;2
WireConnection;100;2;104;0
WireConnection;22;0;100;0
WireConnection;22;1;24;3
WireConnection;30;0;26;0
WireConnection;30;1;22;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;43;0;24;3
WireConnection;34;0;32;0
WireConnection;40;0;22;0
WireConnection;40;1;43;0
WireConnection;25;0;29;0
WireConnection;25;1;35;0
WireConnection;25;2;34;0
WireConnection;94;0;25;0
WireConnection;94;1;5;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;44;0;41;0
WireConnection;101;0;94;0
WireConnection;101;1;25;0
WireConnection;101;2;104;0
WireConnection;46;0;25;0
WireConnection;45;0;46;0
WireConnection;45;1;44;0
WireConnection;45;2;66;4
WireConnection;61;0;60;0
WireConnection;61;1;101;0
WireConnection;61;2;66;0
WireConnection;90;9;61;0
WireConnection;90;28;45;0
WireConnection;92;0;90;2
WireConnection;92;1;90;26
ASEEND*/
//CHKSM=9EE12BACFF3E45DE57B369CB1F041B86144BD797