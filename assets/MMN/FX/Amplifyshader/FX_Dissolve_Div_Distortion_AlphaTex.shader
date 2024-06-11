// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_AlphaTex"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w     Distortion Power)][Header(tcd1.xy     AlphaTex Offset)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Add_Noise_Alpha("Add_Noise_Alpha", Float) = 0.35
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (1,1,1,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1

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
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _SubColor;
			float4 _NoiseTex_ST;
			float4 _AlphaTex_ST;
			float _Add_Noise_Alpha;
			float _Intensity_Alpha;
			float _Color_Range;
			float _ColorGradation;
			float _Color_Offset;
			float _Use_G_Channel_Alpha;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _NearPlaneAlpha;
			float _SpawnTransition;
			float _TransitionValue;
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
			float _Intensity_Color;
			float _EffectAlpha;
			CBUFFER_END


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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

				output.ase_color = input.color;
				output.ase_texcoord2 = input.ase_texcoord1;
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
				float localFXFinalColorOutputs125_g7 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + uv_NoiseTex);
				float4 tex2DNode48 = tex2D( _NoiseTex, panner49 );
				float temp_output_81_0 = ( tex2DNode48.g + -0.5 );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power * input.uv0.w ) , ( temp_output_81_0 * _Distortion_Y_Power * input.uv0.w )));
				float4 tex2DNode5 = tex2D( _MainTex, ( uv_MainTex + appendResult77 ) );
				float4 lerpResult121 = lerp( ( tex2DNode5 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float lerpResult120 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float temp_output_22_0 = ( lerpResult120 - input.uv0.z );
				float2 texCoord132 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult134 = lerp( temp_output_22_0 , texCoord132.x , _ColorGradation);
				float4 lerpResult142 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult134 ) * _Color_Range ) ));
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult98 = (float2(( input.ase_texcoord2.x + uv_AlphaTex.x ) , ( input.ase_texcoord2.y + uv_AlphaTex.y )));
				float4 appendResult32_g7 = (float4(( _Intensity_Color * lerpResult121 * lerpResult142 ).rgb , ( ( input.ase_color.a * lerpResult120 * saturate( ( ( temp_output_22_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * saturate( ( tex2DNode48.g + _Add_Noise_Alpha ) ) * tex2D( _AlphaTex, appendResult98 ).g ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g7 = appendResult32_g7;
				float4 texCoord147_g7 = input.screenPos;
				texCoord147_g7.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g7 = texCoord147_g7;
				float4 positionNDC125_g7 = ScreenPos146_g7;
				float4 texCoord140_g7 = input.fogCoord;
				texCoord140_g7.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g7 = texCoord140_g7;
				float4 fogCoord125_g7 = fogCoord139_g7;
				float3 positionWS125_g7 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g7 = normalizedWorldNormal;
				float nearPlaneAlpha125_g7 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g7 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g7 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g7 = _RaycastMinimumAlpha;
				float lightRatio125_g7 = _LightRatio;
				float lightReceive125_g7 = _LightReceive;
				float near125_g7 = _SoftParticleNearFadeDistance;
				float far125_g7 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g7 = _SoftParticleFadeOutRange;
				float softParticle125_g7 = _SoftParticle;
				float mode125_g7 = _Mode;
				float fogReceive125_g7 = _FogReceive;
				float transitionValue125_g7 = _TransitionValue;
				float spawnTransition125_g7 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g7 , positionNDC125_g7 , fogCoord125_g7 , positionWS125_g7 , normalWS125_g7 , nearPlaneAlpha125_g7 , nearPlaneInvertDistance125_g7 , raycastHarftoneClip125_g7 , raycastMinimumAlpha125_g7 , lightRatio125_g7 , lightReceive125_g7 , near125_g7 , far125_g7 , fadeOutRange125_g7 , softParticle125_g7 , mode125_g7 , fogReceive125_g7 , transitionValue125_g7 , spawnTransition125_g7 );
				float4 break64_g7 = finalColor125_g7;
				float3 appendResult76_g7 = (float3(break64_g7.x , break64_g7.y , break64_g7.z));
				
				float3 color = appendResult76_g7;
				float alpha = break64_g7.w;

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
Version=19105
Node;AmplifyShaderEditor.FunctionNode;119;-3167.505,501.5085;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-3312,240;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;52;-3184,368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-2992,240;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2704,448;Inherit;False;Constant;_Distortion_Offset;Distortion_Offset;5;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-2461.112,285.9915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2480,416;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2480,176;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;23;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2240,288;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2240,176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;-2096,176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-1984,-16;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;123;-1466.973,11.69732;Inherit;False;257.0979;268.6705;Switch;2;122;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-1440,189.6973;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;-1376,61.69733;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1076.516,431.7599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1080.089,320.5299;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;94;-1627.942,882.689;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;92;-1643.942,1058.689;Inherit;False;0;93;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-1355.942,1074.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;105;-2466.263,691.4064;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;83;-878.4343,-27.25745;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;104;-1324.222,731.6476;Inherit;False;Property;_Add_Noise_Alpha;Add_Noise_Alpha;22;0;Create;True;0;0;0;False;0;False;0.35;0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-897,439;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;35;0;Create;True;0;0;0;False;0;False;1;0.49;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-1355.942,946.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-896,320;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-1120.117,653.979;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.35;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;98;-1211.942,946.689;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;124;-463,-114;Inherit;False;181;199;Switch;1;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-700.5412,-106.0353;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-688,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-412.5416,-202.0353;Inherit;False;Property;_Intensity_Color;Intensity_Color;32;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;102;-992.1171,653.979;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;121;-432,-64;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;93;-1051.942,946.689;Inherit;True;Property;_AlphaTex;AlphaTex;18;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;-544,320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;254.7298,131.8346;Inherit;False;204;375;Rendering Options;4;113;112;110;125;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-195.5483,-114.6385;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-183.4526,177.7731;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;286.7301,339.8349;Inherit;False;Property;_CullMode;Cull Mode;33;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;116;-4.670044,-35.76532;Inherit;False;MMN_CommonOutputs;0;;7;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;113;286.7301,179.8347;Inherit;False;Property;_BlendSrc;Blend Src;28;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;285.7301,259.8348;Inherit;False;Property;_BlendDst;Blend Dst;30;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;288,416;Inherit;False;Property;_ZTest;Z Test;34;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;118;256.766,-41.35977;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;20;MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_AlphaTex;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;-11.89288,319.0587;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;127;-138.3929,491.0587;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-327.3929,493.0587;Inherit;False;Property;_EffectAlpha;EffectAlpha;36;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3360,448;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-3364.509,374.3023;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;21;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-2800,240;Inherit;True;Property;_NoiseTex;NoiseTex;19;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2371,-74;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-2462.771,507.8877;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1325.119,318.5311;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1840,-16;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;5;Header(tcd0.z     Dissolve);Header(tcd0.w     Distortion Power);Header(tcd1.xy     AlphaTex Offset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;130;-2148.789,-722.151;Inherit;False;422.6843;276.8151;Color Gradation;3;134;132;131;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-2116.789,-674.1511;Inherit;False;Property;_ColorGradation;Color Gradation;25;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;132;-2116.789,-594.1511;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;133;-1441.829,-970.5708;Inherit;False;873.9635;616.705;2Color;8;142;141;140;139;138;137;136;135;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;134;-1892.788,-674.1511;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-1425.829,-554.5715;Inherit;False;Property;_Color_Offset;Color_Offset;29;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1233.829,-442.5712;Inherit;False;Property;_Color_Range;Color_Range;31;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-1233.829,-554.5715;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1073.829,-554.5715;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;139;-993.8291,-922.5708;Inherit;False;Property;_SubColor;Sub Color;27;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;140;-929.829,-554.5715;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;141;-993.8291,-746.5714;Inherit;False;Property;_MainColor;Main Color;26;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;142;-721.8287,-650.5713;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;143;-1867.025,-229.3479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;52;0;129;0
WireConnection;52;1;51;0
WireConnection;49;0;47;0
WireConnection;49;2;52;0
WireConnection;49;1;119;0
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;79;0;81;0
WireConnection;79;1;78;0
WireConnection;79;2;82;4
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;72;2;82;4
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;67;0;6;0
WireConnection;67;1;77;0
WireConnection;120;0;5;4
WireConnection;120;1;5;2
WireConnection;120;2;122;0
WireConnection;43;0;24;3
WireConnection;22;0;120;0
WireConnection;22;1;24;3
WireConnection;103;0;94;2
WireConnection;103;1;92;2
WireConnection;105;0;48;2
WireConnection;99;0;94;1
WireConnection;99;1;92;1
WireConnection;40;0;22;0
WireConnection;40;1;43;0
WireConnection;91;0;105;0
WireConnection;91;1;104;0
WireConnection;98;0;99;0
WireConnection;98;1;103;0
WireConnection;84;0;5;0
WireConnection;84;1;83;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;102;0;91;0
WireConnection;121;0;84;0
WireConnection;121;1;83;0
WireConnection;121;2;122;0
WireConnection;93;1;98;0
WireConnection;44;0;41;0
WireConnection;61;0;60;0
WireConnection;61;1;121;0
WireConnection;61;2;142;0
WireConnection;45;0;83;4
WireConnection;45;1;120;0
WireConnection;45;2;44;0
WireConnection;45;3;102;0
WireConnection;45;4;93;2
WireConnection;116;9;61;0
WireConnection;116;28;126;0
WireConnection;118;0;116;2
WireConnection;118;1;116;26
WireConnection;126;0;45;0
WireConnection;126;1;127;0
WireConnection;127;0;128;0
WireConnection;48;1;49;0
WireConnection;5;1;67;0
WireConnection;134;0;143;0
WireConnection;134;1;132;1
WireConnection;134;2;131;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;138;0;137;0
WireConnection;138;1;136;0
WireConnection;140;0;138;0
WireConnection;142;0;139;0
WireConnection;142;1;141;0
WireConnection;142;2;140;0
WireConnection;143;0;22;0
ASEEND*/
//CHKSM=8ABB7CD220A783C855D1DEDC1792CD692C18E9EC