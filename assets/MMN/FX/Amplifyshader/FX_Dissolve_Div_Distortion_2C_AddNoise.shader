// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_2C_AddNoise"
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
		_SequenceX("Sequence X", Float) = 1
		_SequenceY("Sequence Y", Float) = 1
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = -0.5
		[Toggle]_Add_Offset("Add_Offset", Float) = 0
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		_Twist("Twist", Float) = 0
		_DefaultValues("Default Values", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1
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
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _AddNoiseTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseTex_ST;
			float4 _MainColor;
			float4 _SubColor;
			float4 _MainTex_ST;
			float4 _AddNoiseTex_ST;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Add_Offset;
			float _Distortion_Offset;
			float _Twist;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _DefaultValues;
			float _SequenceY;
			float _SequenceX;
			float _ColorGradation;
			float _Color_Range;
			float _Use_G_Channel_Alpha;
			float _NearPlaneAlpha;
			float _AddNoise_X_Speed;
			float _Intensity_Alpha;
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
			float _Color_Offset;
			float _AddNoise_Y_Speed;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				output.ase_texcoord2 = input.ase_texcoord1;
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
				float localFXFinalColorOutputs125_g28 = ( 0.0 );
				float2 appendResult89 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 uv_AddNoiseTex = input.uv0.xy * _AddNoiseTex_ST.xy + _AddNoiseTex_ST.zw;
				float2 appendResult275 = (float2(uv_AddNoiseTex.x , ( uv_AddNoiseTex.y + ( uv_AddNoiseTex.x * _Twist ) )));
				float2 break276 = appendResult275;
				float SequenceX177 = _SequenceX;
				float SequenceY178 = _SequenceY;
				float2 appendResult176 = (float2(( break276.x * SequenceX177 ) , ( break276.y * SequenceY178 )));
				float2 panner90 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult89 + frac( appendResult176 ));
				float4 tex2DNode85 = tex2D( _AddNoiseTex, panner90 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult273 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + ( uv_NoiseTex.x * _Twist ) )));
				float2 break274 = appendResult273;
				float2 appendResult185 = (float2(( break274.x * SequenceX177 ) , ( break274.y * SequenceY178 )));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + frac( appendResult185 ));
				float lerpResult284 = lerp( 0.0 , input.ase_texcoord2.x , _Add_Offset);
				float temp_output_81_0 = ( tex2D( _NoiseTex, panner49 ).g + ( _Distortion_Offset + lerpResult284 ) );
				float temp_output_151_0 = saturate( input.uv0.w );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power * temp_output_151_0 ) , ( temp_output_81_0 * _Distortion_Y_Power * temp_output_151_0 )));
				float4 tex2DNode5 = tex2D( _MainTex, ( uv_MainTex + appendResult77 ) );
				float lerpResult129 = lerp( ( tex2DNode85.g * tex2DNode5.a ) , ( tex2DNode85.g * tex2DNode5.g ) , _Use_G_Channel_Alpha);
				float temp_output_150_0 = saturate( ( input.uv0.z + _DefaultValues ) );
				float temp_output_22_0 = ( lerpResult129 - temp_output_150_0 );
				float2 texCoord154 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult158 = (float2(( texCoord154.x * SequenceX177 ) , ( texCoord154.y * SequenceY178 )));
				float lerpResult136 = lerp( temp_output_22_0 , frac( appendResult158 ).x , _ColorGradation);
				float4 lerpResult25 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult136 ) * _Color_Range ) ));
				float4 lerpResult128 = lerp( ( lerpResult25 * tex2DNode5 ) , lerpResult25 , _Use_G_Channel_Alpha);
				float3 appendResult243 = (float3(( _Intensity_Color * lerpResult128 * input.ase_color ).rgb));
				float4 appendResult32_g28 = (float4(appendResult243 , ( ( (lerpResult25).a * saturate( ( ( temp_output_22_0 / ( ( 1.0 - temp_output_150_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * input.ase_color.a ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g28 = appendResult32_g28;
				float4 texCoord147_g28 = input.screenPos;
				texCoord147_g28.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g28 = texCoord147_g28;
				float4 positionNDC125_g28 = ScreenPos146_g28;
				float4 texCoord140_g28 = input.fogCoord;
				texCoord140_g28.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g28 = texCoord140_g28;
				float4 fogCoord125_g28 = fogCoord139_g28;
				float3 positionWS125_g28 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g28 = normalizedWorldNormal;
				float nearPlaneAlpha125_g28 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g28 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g28 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g28 = _RaycastMinimumAlpha;
				float lightRatio125_g28 = _LightRatio;
				float lightReceive125_g28 = _LightReceive;
				float near125_g28 = _SoftParticleNearFadeDistance;
				float far125_g28 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g28 = _SoftParticleFadeOutRange;
				float softParticle125_g28 = _SoftParticle;
				float mode125_g28 = _Mode;
				float fogReceive125_g28 = _FogReceive;
				float transitionValue125_g28 = _TransitionValue;
				float spawnTransition125_g28 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g28 , positionNDC125_g28 , fogCoord125_g28 , positionWS125_g28 , normalWS125_g28 , nearPlaneAlpha125_g28 , nearPlaneInvertDistance125_g28 , raycastHarftoneClip125_g28 , raycastMinimumAlpha125_g28 , lightRatio125_g28 , lightReceive125_g28 , near125_g28 , far125_g28 , fadeOutRange125_g28 , softParticle125_g28 , mode125_g28 , fogReceive125_g28 , transitionValue125_g28 , spawnTransition125_g28 );
				float4 break64_g28 = finalColor125_g28;
				float3 appendResult76_g28 = (float3(break64_g28.x , break64_g28.y , break64_g28.z));

				float3 color = appendResult76_g28;
				float alpha = break64_g28.w;

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
Node;AmplifyShaderEditor.RangedFloatNode;270;-2111.333,-253.8714;Inherit;False;Property;_Twist;Twist;30;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;279;-1851.753,-25.38034;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-1815.813,233.0509;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;272;-1671.813,185.0508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-260.4111,-898.7306;Inherit;False;Property;_SequenceX;Sequence X;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-270.4111,-792.7305;Inherit;False;Property;_SequenceY;Sequence Y;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;273;-1547.056,23.98561;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;-103.4091,-904.062;Inherit;False;SequenceX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-115.4091,-804.062;Inherit;False;SequenceY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-1458.452,297.9633;Inherit;False;178;SequenceY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-1436.452,220.9633;Inherit;False;177;SequenceX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;274;-1393.66,23.39535;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-1808.159,-403.8943;Inherit;False;0;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-1170.104,49.27835;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-1180.104,185.2785;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;185;-1017.664,100.2598;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;278;-1476.884,-192.878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1118.604,343.4041;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;21;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1119.874,421.8751;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;22;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;186;-894.1644,124.9599;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-942.6044,343.4041;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;126;-920.7374,515.8815;Inherit;False;MMN_Time;-1;;26;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;277;-1332.884,-240.8782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;275;-1208.127,-401.9433;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-762.6044,321.4041;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-558.6041,215.4041;Inherit;True;Property;_NoiseTex;NoiseTex;20;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;179;-814.4093,-456.0617;Inherit;False;177;SequenceX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;-834.4093,-379.0617;Inherit;False;178;SequenceY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;276;-1057.331,-576.7336;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;78;-238.6042,391.4041;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;26;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;-142.6042,471.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-219.7163,261.3955;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;-541.4091,-473.0617;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-524.4091,-621.062;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-291.6042,116.404;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;25;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;1.395752,263.4041;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-555.9872,-218.6698;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;29;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;1.395752,151.4041;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-555.9872,-298.6699;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;28;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;176;-348.4091,-518.0619;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;171;-196.4092,-512.0618;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;127;-260.7372,-152.1183;Inherit;False;MMN_Time;-1;;27;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-334.4872,-298.6699;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;145.3957,151.4041;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;17.39577,-41.596;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-203.4111,-1133.73;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;257.3959,-40.596;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;90;17.01271,-329.6699;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;401.3959,-40.596;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;a6aeb5355da7b0d43b94c52a81a5f6a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;352.1139,-341.7933;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;27;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;04b22506c10d2d94f983b5a17dfef117;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;162.5889,-836.7306;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;645.1948,555.0949;Inherit;False;Property;_DefaultValues;Default Values;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;160.5889,-949.7306;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;897.3959,219.4041;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;158;344.5888,-907.7306;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;842.1949,512.095;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;734.313,-64.57011;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;736.9139,-171.17;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;129;982.1368,91.87659;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;625.3959,-696.5962;Inherit;False;422.6843;276.8151;Color Gradation;2;136;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FractNode;157;485.5889,-913.7306;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;150;881.3959,407.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;1172.328,252.2551;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;161;661.5889,-901.7305;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;26;993.3959,-312.5959;Inherit;False;Property;_Color_Offset;Color_Offset;36;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;1185.396,-312.5959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;1185.396,-200.5959;Inherit;False;Property;_Color_Range;Color_Range;37;0;Create;True;0;0;0;False;0;False;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1345.396,-312.5959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;1057.396,407.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;1057.396,487.4041;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1313.396,-792.5962;Inherit;False;Property;_SubColor;Sub Color;34;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.2479339,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;34;1489.396,-312.5959;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;1313.396,-584.5962;Inherit;False;Property;_MainColor;Main Color;33;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;152;1201.396,407.4041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;25;1585.396,-488.5959;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;1345.396,295.4041;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;1796.496,-384.8074;Inherit;False;179.2;183.4;Switch;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1542.856,-113.0805;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1344.396,414.4041;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;39;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;1857.396,-121.596;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1553.396,295.4041;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;1889.396,-504.596;Inherit;False;Property;_Intensity_Color;Intensity_Color;38;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;1819.296,-334.8074;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;44;1697.396,295.4041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;1697.396,183.4041;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;2097.396,-328.5959;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;2241.396,-328.5959;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2097.396,119.404;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;2768,-144;Inherit;False;204;375;Rendering Options;4;116;115;113;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;116;2800,-96;Inherit;False;Property;_BlendSrc;Blend Src;41;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;2800,144;Inherit;False;Property;_ZTest;Z Test;35;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;2800,-16;Inherit;False;Property;_BlendDst;Blend Dst;42;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;2800,64;Inherit;False;Property;_CullMode;Cull Mode;43;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;2512,-304;Inherit;False;MMN_CommonOutputs;0;;28;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;2768,-304;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_2C_AddNoise;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;280;-197.8569,702.4436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;601.3959,322.4041;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-526.6041,521.404;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;281;-666.4363,749.571;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;134;657.3959,-648.5962;Inherit;False;Property;_ColorGradation;Color Gradation;32;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;881.3959,-648.5962;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;282;-607.1155,900.4268;Inherit;False;422.6843;276.8151;Color Gradation;2;284;283;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;284;-351.1155,948.4268;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-551.6041,416.4041;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;23;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;283;-575.1155,948.4268;Inherit;False;Property;_Add_Offset;Add_Offset;24;1;[Toggle];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;285;2403.579,98.38461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;286;2277.079,270.3846;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;287;2088.079,272.3846;Inherit;False;Property;_EffectAlpha;EffectAlpha;40;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;271;0;279;1
WireConnection;271;1;270;0
WireConnection;272;0;279;2
WireConnection;272;1;271;0
WireConnection;273;0;279;1
WireConnection;273;1;272;0
WireConnection;177;0;159;0
WireConnection;178;0;160;0
WireConnection;274;0;273;0
WireConnection;183;0;274;0
WireConnection;183;1;181;0
WireConnection;184;0;274;1
WireConnection;184;1;182;0
WireConnection;185;0;183;0
WireConnection;185;1;184;0
WireConnection;278;0;88;1
WireConnection;278;1;270;0
WireConnection;186;0;185;0
WireConnection;52;0;50;0
WireConnection;52;1;187;0
WireConnection;277;0;88;2
WireConnection;277;1;278;0
WireConnection;275;0;88;1
WireConnection;275;1;277;0
WireConnection;49;0;186;0
WireConnection;49;2;52;0
WireConnection;49;1;126;0
WireConnection;48;1;49;0
WireConnection;276;0;275;0
WireConnection;151;0;82;4
WireConnection;81;0;48;2
WireConnection;81;1;280;0
WireConnection;175;0;276;1
WireConnection;175;1;180;0
WireConnection;174;0;276;0
WireConnection;174;1;179;0
WireConnection;79;0;81;0
WireConnection;79;1;78;0
WireConnection;79;2;151;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;72;2;151;0
WireConnection;176;0;174;0
WireConnection;176;1;175;0
WireConnection;171;0;176;0
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;67;0;6;0
WireConnection;67;1;77;0
WireConnection;90;0;171;0
WireConnection;90;2;89;0
WireConnection;90;1;127;0
WireConnection;5;1;67;0
WireConnection;85;1;90;0
WireConnection;156;0;154;2
WireConnection;156;1;178;0
WireConnection;155;0;154;1
WireConnection;155;1;177;0
WireConnection;158;0;155;0
WireConnection;158;1;156;0
WireConnection;189;0;24;3
WireConnection;189;1;188;0
WireConnection;92;0;85;2
WireConnection;92;1;5;4
WireConnection;91;0;85;2
WireConnection;91;1;5;2
WireConnection;129;0;92;0
WireConnection;129;1;91;0
WireConnection;129;2;130;0
WireConnection;157;0;158;0
WireConnection;150;0;189;0
WireConnection;22;0;129;0
WireConnection;22;1;150;0
WireConnection;161;0;157;0
WireConnection;30;0;26;0
WireConnection;30;1;136;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;43;0;150;0
WireConnection;34;0;32;0
WireConnection;152;0;43;0
WireConnection;152;1;153;0
WireConnection;25;0;29;0
WireConnection;25;1;35;0
WireConnection;25;2;34;0
WireConnection;40;0;22;0
WireConnection;40;1;152;0
WireConnection;125;0;25;0
WireConnection;125;1;5;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;128;0;125;0
WireConnection;128;1;25;0
WireConnection;128;2;130;0
WireConnection;44;0;41;0
WireConnection;46;0;25;0
WireConnection;61;0;60;0
WireConnection;61;1;128;0
WireConnection;61;2;66;0
WireConnection;243;0;61;0
WireConnection;45;0;46;0
WireConnection;45;1;44;0
WireConnection;45;2;66;4
WireConnection;119;9;243;0
WireConnection;119;28;285;0
WireConnection;121;0;119;2
WireConnection;121;1;119;26
WireConnection;280;0;71;0
WireConnection;280;1;284;0
WireConnection;136;0;22;0
WireConnection;136;1;161;0
WireConnection;136;2;134;0
WireConnection;284;1;281;1
WireConnection;284;2;283;0
WireConnection;285;0;45;0
WireConnection;285;1;286;0
WireConnection;286;0;287;0
ASEEND*/
//CHKSM=B91E7F2E1DD5726F3B6DB93224CC565EB46E6144