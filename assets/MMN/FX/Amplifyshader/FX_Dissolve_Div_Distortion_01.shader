// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_01"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w     Distortion Power)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		_Twist("Twist", Float) = 0
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _SubColor;
			float4 _MaskTex_ST;
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float4 _MainColor;
			float _Color_Range;
			float _ColorGradation;
			float _Use_G_Channel_Alpha;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Twist;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Color_Offset;
			float _Intensity_Alpha;
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
				float localFXFinalColorOutputs125_g7 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult109 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult111 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + ( uv_NoiseTex.x * _Twist ) )));
				float2 panner112 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult109 + appendResult111);
				float temp_output_118_0 = ( tex2D( _NoiseTex, panner112 ).g + -0.5 );
				float2 appendResult122 = (float2(( temp_output_118_0 * _Distortion_X_Power * input.uv0.w ) , ( temp_output_118_0 * _Distortion_Y_Power * input.uv0.w )));
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 tex2DNode128 = tex2D( _MainTex, ( uv_MainTex + ( appendResult122 * tex2D( _MaskTex, uv_MaskTex ).g ) ) );
				float lerpResult133 = lerp( tex2DNode128.a , tex2DNode128.g , _Use_G_Channel_Alpha);
				float temp_output_135_0 = ( lerpResult133 - input.uv0.z );
				float2 texCoord157 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult159 = lerp( temp_output_135_0 , texCoord157.x , _ColorGradation);
				float4 lerpResult144 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult159 ) * _Color_Range ) ));
				float4 lerpResult151 = lerp( ( lerpResult144 * tex2DNode128 ) , lerpResult144 , _Use_G_Channel_Alpha);
				float4 appendResult32_g7 = (float4(( _Intensity_Color * lerpResult151 * input.ase_color ).rgb , ( ( (lerpResult144).a * saturate( ( ( temp_output_135_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * input.ase_color.a ) * saturate( _EffectAlpha ) )));
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
Version=19202
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-3856,-448;Inherit;False;0;114;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;103;-3776,-304;Inherit;False;Property;_Twist;Twist;21;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3584,-96;Inherit;False;1430.184;557.7893;UV Distortion;14;122;121;119;118;117;116;115;114;113;112;110;109;108;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-3616,-304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-3536,176;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-3472,-352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-3536,96;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;111;-3360,-448;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;110;-3392,272;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;-3360,96;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;112;-3168,-32;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;114;-2976,-32;Inherit;True;Property;_NoiseTex;NoiseTex;18;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;113;-2880,192;Inherit;False;Constant;_Distortion_Offset;Distortion_Offset;5;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;117;-2672,272;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-2672,-32;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;23;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-2672,64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;120;-2640,496;Inherit;False;0;123;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;122;-2288,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;123;-2416,496;Inherit;True;Property;_MaskTex;MaskTex;22;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2128,-32;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;-2304,-288;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;126;-1616,-192;Inherit;False;268.7578;251.2733;Switch;2;133;130;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-2064,-288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;128;-1920,-288;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.w     Distortion Power);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;-1600,-16;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;-1296,176;Inherit;False;555.6001;278.9999;CustomData Dissolve_Divide;4;143;141;135;131;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;131;-1280,288;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;133;-1584,-144;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;156;-1248,-192;Inherit;False;422.6843;276.8151;Color Gradation;3;159;158;157;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;158;-1216,-144;Inherit;False;Property;_ColorGradation;Color Gradation;25;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-1488,-944;Inherit;False;830.4828;643.692;2Color;8;144;142;140;139;138;137;136;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;157;-1216,-48;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;135;-1024,240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;159;-992,-144;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1472,-496;Inherit;False;Property;_Color_Offset;Color_Offset;28;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1280,-384;Inherit;False;Property;_Color_Range;Color_Range;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-1280,-496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1120,-496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;142;-1040,-896;Inherit;False;Property;_SubColor;Sub Color;27;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;140;-1040,-688;Inherit;False;Property;_MainColor;Main Color;26;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;141;-1024,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;139;-976,-496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-688,272;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;33;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;143;-864,240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;144;-800,-624;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-480,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-560,-320;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;147;-368,-400;Inherit;False;181.6049;183.8025;Switch;1;151;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-304,-512;Inherit;False;Property;_Intensity_Color;Intensity_Color;32;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;149;-560,-16;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;151;-336,-352;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;153;-336,-192;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;150;-336,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;85;313.847,-61.39833;Inherit;False;204;375;Rendering Options;4;89;87;86;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-96,-336;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-96,-48;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;90;67.26201,-209.2646;Inherit;False;MMN_CommonOutputs;0;;7;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;86;345.8473,146.6021;Inherit;False;Property;_CullMode;Cull Mode;35;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;352,224;Inherit;False;Property;_ZTest;Z Test;30;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;344.8473,66.60173;Inherit;False;Property;_BlendDst;Blend Dst;34;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;345.8473,-13.39828;Inherit;False;Property;_BlendSrc;Blend Src;31;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;92;311.3293,-210.9366;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-2673,175;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-2408,118;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2422,-49;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;104.532,39.86038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;162;-21.96799,211.8604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-210.968,213.8604;Inherit;False;Property;_EffectAlpha;EffectAlpha;36;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;104;0;102;1
WireConnection;104;1;103;0
WireConnection;107;0;102;2
WireConnection;107;1;104;0
WireConnection;111;0;102;1
WireConnection;111;1;107;0
WireConnection;109;0;108;0
WireConnection;109;1;106;0
WireConnection;112;0;111;0
WireConnection;112;2;109;0
WireConnection;112;1;110;0
WireConnection;114;1;112;0
WireConnection;118;0;114;2
WireConnection;118;1;113;0
WireConnection;122;0;119;0
WireConnection;122;1;121;0
WireConnection;123;1;120;0
WireConnection;125;0;122;0
WireConnection;125;1;123;2
WireConnection;127;0;124;0
WireConnection;127;1;125;0
WireConnection;128;1;127;0
WireConnection;133;0;128;4
WireConnection;133;1;128;2
WireConnection;133;2;130;0
WireConnection;135;0;133;0
WireConnection;135;1;131;3
WireConnection;159;0;135;0
WireConnection;159;1;157;1
WireConnection;159;2;158;0
WireConnection;137;0;134;0
WireConnection;137;1;159;0
WireConnection;138;0;137;0
WireConnection;138;1;136;0
WireConnection;141;0;131;3
WireConnection;139;0;138;0
WireConnection;143;0;135;0
WireConnection;143;1;141;0
WireConnection;144;0;142;0
WireConnection;144;1;140;0
WireConnection;144;2;139;0
WireConnection;146;0;143;0
WireConnection;146;1;145;0
WireConnection;148;0;144;0
WireConnection;148;1;128;0
WireConnection;149;0;144;0
WireConnection;151;0;148;0
WireConnection;151;1;144;0
WireConnection;151;2;130;0
WireConnection;150;0;146;0
WireConnection;154;0;152;0
WireConnection;154;1;151;0
WireConnection;154;2;153;0
WireConnection;155;0;149;0
WireConnection;155;1;150;0
WireConnection;155;2;153;4
WireConnection;90;9;154;0
WireConnection;90;28;161;0
WireConnection;92;0;90;2
WireConnection;92;1;90;26
WireConnection;121;0;118;0
WireConnection;121;1;116;0
WireConnection;121;2;117;4
WireConnection;119;0;118;0
WireConnection;119;1;115;0
WireConnection;119;2;117;4
WireConnection;161;0;155;0
WireConnection;161;1;162;0
WireConnection;162;0;163;0
ASEEND*/
//CHKSM=FA9A8B87F4DB76C38ABE0FD38125FA686BD7CB0F