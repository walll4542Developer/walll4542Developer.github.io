// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Beam"
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
		[Header(MainTexture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Space(10)]_Main_U_Speed("Main_U_Speed", Float) = 0
		_Main_V_Speed("Main_V_Speed", Float) = 0
		[Header(Vibration)][Space()]_Vibration_Intensity("Vibration_Intensity", Float) = 0.1
		_Vibration_Bound("Vibration_Bound", Float) = 10
		_Vibration_Period("Vibration_Period", Range( 0 , 60)) = 30
		[Header(MaskTexture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Space()]_Mask_U_Speed("Mask_U_Speed", Float) = 0
		_Mask_V_Speed("Mask_V_Speed", Float) = 0
		[Header(NoiseTexture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Distortion_Offset("Distortion_Offset", Float) = 0
		_Distortion_Intensity("Distortion_Intensity", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space()]_Noise_U_Speed("Noise_U_Speed", Float) = 0
		_Noise_V_Speed("Noise_V_Speed", Float) = 0
		[Header(AddTexture)][Space()]_AddTex("AddTex", 2D) = "white" {}
		[Toggle]_Use_Noise_AddTex("Use_Noise_AddTex", Float) = 0
		[Space()]_Add_U_Speed("Add_U_Speed", Float) = 0
		_Add_V_Speed("Add_V_Speed", Float) = 0
		[Space()]_Add_Intensity("Add_Intensity", Float) = 0
		_Add_Cut("Add_Cut", Range( -1 , 1)) = 0
		_AddSmooth("AddSmooth", Float) = 1
		[Header(FlareTexture)][Space()]_FlareTex("FlareTex", 2D) = "white" {}
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1
		[Toggle]_Use_Noise_FlareTex("Use_Noise_FlareTex", Float) = 0
		[Space()]_Flare_U_Speed("Flare_U_Speed", Float) = 0
		_Flare_V_Speed("Flare_V_Speed", Float) = 0
		_Flare_Intensity("Flare_Intensity", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (1,1,1,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		_Cut("Cut", Range( -1 , 1)) = 1
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


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _AddTex;
			sampler2D _FlareTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _AddTex_ST;
			float4 _MaskTex_ST;
			float4 _SubColor;
			float4 _FlareTex_ST;
			float4 _MainColor;
			float _Add_U_Speed;
			float _Add_V_Speed;
			float _Use_Noise_AddTex;
			float _Add_Cut;
			float _AddSmooth;
			float _Add_Intensity;
			float _Flare_V_Speed;
			float _Vibration_Bound;
			float _Use_Noise_FlareTex;
			float _Flare_Intensity;
			float _Mask_U_Speed;
			float _Mask_V_Speed;
			float _Use_G_Channel_Alpha;
			float _ColorGradation;
			float _Color_Range;
			float _Intensity_Color;
			float _Intensity_Alpha;
			float _Flare_U_Speed;
			float _Vibration_Intensity;
			float _NearPlaneAlpha;
			float _Cut;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _LightReceive;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticle;
			float _Vibration_Period;
			float _Mode;
			float _TransitionValue;
			float _SpawnTransition;
			float _Color_Offset;
			float _Main_U_Speed;
			float _Main_V_Speed;
			float _Noise_U_Speed;
			float _Noise_V_Speed;
			float _Distortion_Offset;
			float _Distortion_Intensity;
			float _FogReceive;
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
				float localFXFinalColorOutputs125_g15 = ( 0.0 );
				float2 appendResult458 = (float2(_Main_U_Speed , _Main_V_Speed));
				float Time465 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 appendResult479 = (float2(_Noise_U_Speed , _Noise_V_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner483 = ( Time465 * appendResult479 + uv_NoiseTex);
				float NoiseTexData563 = ( ( tex2D( _NoiseTex, panner483 ).g - _Distortion_Offset ) * _Distortion_Intensity );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult514 = (float2(uv_MainTex.x , ( uv_MainTex.y - 0.0 )));
				float2 break506 = ( NoiseTexData563 + appendResult514 );
				float2 texCoord467 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float U469 = texCoord467.x;
				float temp_output_455_0 = ( ( ( cos( ( Time465 * _Vibration_Period ) ) * cos( ( Time465 * ( _Vibration_Period - ( _Vibration_Period / 2.0 ) ) ) ) ) * _Vibration_Intensity ) + ( _Vibration_Intensity * saturate( sin( ( ( U469 * _Vibration_Bound ) + fmod( ( Time465 * -20.0 ) , 12.5 ) ) ) ) ) );
				float V470 = texCoord467.y;
				float lerpResult362 = lerp( ( break506.y + temp_output_455_0 ) , ( break506.y - temp_output_455_0 ) , V470);
				float2 appendResult365 = (float2(break506.x , lerpResult362));
				float2 panner360 = ( 1.0 * _Time.y * appendResult458 + appendResult365);
				float4 tex2DNode358 = tex2D( _MainTex, panner360 );
				float2 appendResult488 = (float2(_Add_U_Speed , _Add_V_Speed));
				float2 uv_AddTex = input.uv0.xy * _AddTex_ST.xy + _AddTex_ST.zw;
				float2 appendResult554 = (float2(uv_AddTex.x , ( uv_AddTex.y - 0.0 )));
				float2 lerpResult549 = lerp( appendResult554 , ( appendResult554 + NoiseTexData563 ) , _Use_Noise_AddTex);
				float2 panner487 = ( Time465 * appendResult488 + lerpResult549);
				float2 AddUV573 = panner487;
				float4 tex2DNode475 = tex2D( _AddTex, AddUV573 );
				float temp_output_511_0 = ( saturate( ( ( tex2DNode475.g + _Add_Cut ) * _AddSmooth ) ) * _Add_Intensity );
				float2 appendResult536 = (float2(_Flare_U_Speed , _Flare_V_Speed));
				float2 uv_FlareTex = input.uv0.xy * _FlareTex_ST.xy + _FlareTex_ST.zw;
				float2 appendResult557 = (float2(uv_FlareTex.x , ( uv_FlareTex.y - 0.0 )));
				float2 lerpResult561 = lerp( appendResult557 , ( appendResult557 + NoiseTexData563 ) , _Use_Noise_FlareTex);
				float2 panner538 = ( Time465 * appendResult536 + lerpResult561);
				float2 FlareUV569 = panner538;
				float temp_output_540_0 = ( tex2D( _FlareTex, FlareUV569 ).g * _Flare_Intensity );
				float2 appendResult525 = (float2(_Mask_U_Speed , _Mask_V_Speed));
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 panner527 = ( Time465 * appendResult525 + uv_MaskTex);
				float4 tex2DNode474 = tex2D( _MaskTex, panner527 );
				float lerpResult530 = lerp( ( ( tex2DNode358.a + temp_output_511_0 + temp_output_540_0 ) * tex2DNode474.g ) , ( ( tex2DNode358.g + temp_output_511_0 + temp_output_540_0 ) * tex2DNode474.g ) , _Use_G_Channel_Alpha);
				float2 texCoord597 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult598 = lerp( lerpResult530 , texCoord597.x , _ColorGradation);
				float4 lerpResult588 = lerp( _MainColor , _SubColor , saturate( ( ( _Color_Offset + lerpResult598 ) * _Color_Range ) ));
				float4 appendResult32_g15 = (float4(( lerpResult588 * ( input.ase_color * _Intensity_Color * lerpResult530 ) ).rgb , ( saturate( ( lerpResult530 * input.ase_color.a * _Intensity_Alpha * ( 0.0 + ( tex2DNode475.g + _Cut ) ) ) ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g15 = appendResult32_g15;
				float4 texCoord147_g15 = input.screenPos;
				texCoord147_g15.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g15 = texCoord147_g15;
				float4 positionNDC125_g15 = ScreenPos146_g15;
				float4 texCoord140_g15 = input.fogCoord;
				texCoord140_g15.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g15 = texCoord140_g15;
				float4 fogCoord125_g15 = fogCoord139_g15;
				float3 positionWS125_g15 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g15 = normalizedWorldNormal;
				float nearPlaneAlpha125_g15 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g15 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g15 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g15 = _RaycastMinimumAlpha;
				float lightRatio125_g15 = _LightRatio;
				float lightReceive125_g15 = _LightReceive;
				float near125_g15 = _SoftParticleNearFadeDistance;
				float far125_g15 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g15 = _SoftParticleFadeOutRange;
				float softParticle125_g15 = _SoftParticle;
				float mode125_g15 = _Mode;
				float fogReceive125_g15 = _FogReceive;
				float transitionValue125_g15 = _TransitionValue;
				float spawnTransition125_g15 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g15 , positionNDC125_g15 , fogCoord125_g15 , positionWS125_g15 , normalWS125_g15 , nearPlaneAlpha125_g15 , nearPlaneInvertDistance125_g15 , raycastHarftoneClip125_g15 , raycastMinimumAlpha125_g15 , lightRatio125_g15 , lightReceive125_g15 , near125_g15 , far125_g15 , fadeOutRange125_g15 , softParticle125_g15 , mode125_g15 , fogReceive125_g15 , transitionValue125_g15 , spawnTransition125_g15 );
				float4 break64_g15 = finalColor125_g15;
				float3 appendResult76_g15 = (float3(break64_g15.x , break64_g15.y , break64_g15.z));

				float3 color = appendResult76_g15;
				float alpha = break64_g15.w;

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
Node;AmplifyShaderEditor.FunctionNode;380;909.5685,948.1518;Inherit;False;MMN_Time;-1;;13;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-3984,1888;Inherit;False;Property;_Noise_V_Speed;Noise_V_Speed;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;481;-3984,1808;Inherit;False;Property;_Noise_U_Speed;Noise_U_Speed;30;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;486;-3792,1952;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;479;-3808,1824;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;476;-3888,1664;Inherit;False;0;437;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;483;-3616,1680;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;467;879.2065,754.5607;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;437;-3408,1712;Inherit;True;Property;_NoiseTex;NoiseTex;26;0;Create;True;0;0;0;False;2;Header(NoiseTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;438;-3344,1920;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;473;-4039.406,765.0699;Inherit;False;1704.2;764.2997;;27;472;455;382;454;466;445;448;447;471;461;449;450;451;434;385;394;464;386;375;384;381;379;383;362;364;363;517;Vibration;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;466;-3901.599,1310.99;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;382;-4014.487,865.3079;Inherit;False;Property;_Vibration_Period;Vibration_Period;22;0;Create;True;0;0;0;False;0;False;30;30;0;60;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;576;-4032,2160;Inherit;False;1892.609;1531.178;;26;547;560;550;552;553;554;565;490;551;559;489;555;556;488;491;557;487;566;573;534;533;558;536;537;538;569;UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-3093.699,1784.317;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-3120,1920;Inherit;False;Property;_Distortion_Intensity;Distortion_Intensity;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;469;1101.207,771.5607;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;394;-3714.808,1065.372;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;517;-3931.21,1215.998;Inherit;False;Property;_Vibration_Bound;Vibration_Bound;21;0;Create;True;0;0;0;False;0;False;10;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;471;-3786.666,1197.908;Inherit;False;469;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;447;-3763.318,1411.701;Inherit;False;Constant;_Float3;Float 3;13;0;Create;True;0;0;0;False;0;False;12.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-2960,1776;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;552;-3664,3344;Inherit;False;Constant;_Float2;Float 2;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;448;-3748.318,1314.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-20;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;550;-3632,3072;Inherit;False;0;475;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;553;-3392,3280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;464;-3677.638,817.8569;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;445;-3612.306,1352.47;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;385;-3593.802,975.0056;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;451;-3630.889,1201.638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;563;-2832,1776;Inherit;False;NoiseTexData;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;450;-3491.857,1204.145;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;384;-3439.802,947.0051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;515;-3520,672;Inherit;False;Constant;_MoveToTrailUV;_MoveToTrailUV;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;359;-3536,528;Inherit;False;0;358;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;-3435.487,846.3079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;565;-3376,3440;Inherit;False;563;NoiseTexData;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;547;-2944,3056;Inherit;False;330.9904;311.8222;Switch;2;549;548;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;554;-3232,3104;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CosOpNode;375;-3291.792,852.866;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;559;-3968,2256;Inherit;False;0;539;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;386;-3291.666,935.5814;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;555;-3984,2464;Inherit;False;Constant;_Float4;Float 4;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;548;-2896,3280;Inherit;False;Property;_Use_Noise_AddTex;Use_Noise_AddTex;33;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;489;-2928,3392;Inherit;False;Property;_Add_U_Speed;Add_U_Speed;34;0;Create;True;0;0;0;False;1;Space();False;0;-0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;516;-3248,608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-2928,3472;Inherit;False;Property;_Add_V_Speed;Add_V_Speed;35;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;449;-3338.173,1203.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;551;-3104,3248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;556;-3712,2400;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;514;-3088,560;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;383;-3164.468,877.0361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;564;-3520,432;Inherit;False;563;NoiseTexData;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;549;-2784,3104;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;488;-2720,3440;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;434;-3272.284,1037.596;Inherit;False;Property;_Vibration_Intensity;Vibration_Intensity;20;0;Create;True;0;0;0;False;2;Header(Vibration);Space();False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;491;-2720,3584;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;461;-3215.571,1202.867;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;441;-2976,416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;557;-3584,2288;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;560;-3232,2224;Inherit;False;330.9904;311.8222;Switch;2;562;561;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;379;-3045.826,875.293;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;454;-3042.063,1155.162;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;487;-2528,3088;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;566;-3760,2560;Inherit;False;563;NoiseTexData;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;558;-3424,2464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;506;-2848,592;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;470;1108.207,842.5605;Inherit;False;V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;455;-2893.875,878.2569;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;533;-3120,2576;Inherit;False;Property;_Flare_U_Speed;Flare_U_Speed;42;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;534;-3120,2640;Inherit;False;Property;_Flare_V_Speed;Flare_V_Speed;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;573;-2352,3088;Inherit;False;AddUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;562;-3200,2416;Inherit;False;Property;_Use_Noise_FlareTex;Use_Noise_FlareTex;41;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;561;-3072,2288;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;536;-2912,2608;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;574;-1605.934,440.6606;Inherit;False;573;AddUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;363;-2712.812,817.9412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;364;-2717.375,922.7912;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;-2748.857,1032.323;Inherit;False;470;V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;537;-2912,2720;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;475;-1527.909,380.6788;Inherit;True;Property;_AddTex;AddTex;32;0;Create;True;0;0;0;False;2;Header(AddTexture);Space();False;-1;None;e1da7a47c699fcf4ea75c2255ab58862;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;544;-1468.332,644.1966;Inherit;False;Property;_Add_Cut;Add_Cut;37;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;538;-2720,2320;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;362;-2558.507,852.9252;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;569;-2544,2320;Inherit;False;FlareUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;459;-2005.946,59.66617;Inherit;False;Property;_Main_U_Speed;Main_U_Speed;18;0;Create;True;0;0;0;False;1;Space(10);False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;543;-1160.332,471.1966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;-2368,640;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;460;-2001.946,145.6662;Inherit;False;Property;_Main_V_Speed;Main_V_Speed;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;546;-1147.332,667.1965;Inherit;False;Property;_AddSmooth;AddSmooth;38;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;528;-777.8834,952.3035;Inherit;False;Property;_Mask_U_Speed;Mask_U_Speed;24;0;Create;True;0;0;0;False;1;Space();False;0;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;568;-1829.84,621.184;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;575;-1593.615,1014.251;Inherit;False;569;FlareUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;458;-1823.946,83.66617;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;545;-1035.332,478.1966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;523;-778.1275,1026.276;Inherit;False;Property;_Mask_V_Speed;Mask_V_Speed;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;513;-915.7266,478.0724;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;526;-587.5856,1088.174;Inherit;False;465;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;539;-1442.169,988.9739;Inherit;True;Property;_FlareTex;FlareTex;39;0;Create;True;0;0;0;False;2;Header(FlareTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;360;-1675.71,123.3472;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.3,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;512;-947.4768,676.2598;Inherit;False;Property;_Add_Intensity;Add_Intensity;36;0;Create;True;0;0;0;False;1;Space();False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;524;-694.1634,802.6738;Inherit;False;0;474;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;525;-604.6744,963.2778;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;527;-409.0003,811.024;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;358;-1494.604,96.40003;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;2;Header(MainTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;540;-1040.812,1050.604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-778.552,476.3088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;502;-604.0092,304.5521;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;474;-336.0353,769.2325;Inherit;True;Property;_MaskTex;MaskTex;23;0;Create;True;0;0;0;False;2;Header(MaskTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;579;-1735.685,785.3481;Inherit;False;Property;_Cut;Cut;52;0;Create;True;0;0;0;False;0;False;1;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;501;-542.4097,140.552;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;532;-167.9235,174.3625;Inherit;False;330.9904;311.8222;Switch;2;530;531;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;578;-1131.685,797.3481;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;499;-324.4123,159.6745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;500;-263.4123,287.6746;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;391;7.242191,-10.89018;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;581;-504.894,561.0872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;463;115.9876,423.4544;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;51;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;280.4658,225.7815;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;198.8772,92.16154;Inherit;False;Property;_Intensity_Color;Intensity_Color;50;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;1008,272;Inherit;False;204;375;Rendering Options;4;79;78;77;577;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;387;240.5386,-22.94981;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1040,320;Inherit;False;Property;_BlendSrc;Blend Src;53;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1040,480;Inherit;False;Property;_CullMode;Cull Mode;55;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;1040,400;Inherit;False;Property;_BlendDst;Blend Dst;54;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;390;430.5384,228.0502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;1021.927,117.2803;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Beam;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;584;607.2063,229.0616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;582;317.2063,421.0616;Inherit;False;Property;_EffectAlpha;EffectAlpha;40;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;583;506.2063,419.0616;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;465;1104,944;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;577;1040,560;Inherit;False;Property;_ZTest;Z Test;29;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;585;758.131,123.3539;Inherit;False;MMN_CommonOutputs;0;;15;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.ColorNode;586;380.3458,-185.8114;Inherit;False;Property;_SubColor;Sub Color;47;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.9528301,0.8118268,0.3910199,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;587;381.3458,-374.8112;Inherit;False;Property;_MainColor;Main Color;46;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.7948946,0.6367924,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;588;626.8365,-243.2543;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;589;650.8429,-32.95898;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;590;109.7319,-354.8479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;-98.26807,-322.8479;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;593;-402.2681,-578.8479;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;595;-946.2681,-690.8479;Inherit;False;422.6843;276.8151;Color Gradation;4;598;597;596;594;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;597;-914.2681,-562.8479;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;598;-690.2681,-642.8479;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;531;-147.7041,363.6746;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;530;-7.861696,224.3625;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;592;-290.2681,-194.8479;Inherit;False;Property;_Color_Range;Color_Range;49;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;-562.2681,-418.8479;Inherit;False;Property;_Color_Offset;Color_Offset;48;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;541;-1337.737,1203.555;Inherit;False;Property;_Flare_Intensity;Flare_Intensity;44;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;-914.2681,-641.8479;Inherit;False;Property;_ColorGradation;Color Gradation;45;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
WireConnection;479;0;481;0
WireConnection;479;1;482;0
WireConnection;483;0;476;0
WireConnection;483;2;479;0
WireConnection;483;1;486;0
WireConnection;437;1;483;0
WireConnection;436;0;437;2
WireConnection;436;1;438;0
WireConnection;469;0;467;1
WireConnection;394;0;382;0
WireConnection;439;0;436;0
WireConnection;439;1;440;0
WireConnection;448;0;466;0
WireConnection;553;0;550;2
WireConnection;553;1;552;0
WireConnection;445;0;448;0
WireConnection;445;1;447;0
WireConnection;385;0;382;0
WireConnection;385;1;394;0
WireConnection;451;0;471;0
WireConnection;451;1;517;0
WireConnection;563;0;439;0
WireConnection;450;0;451;0
WireConnection;450;1;445;0
WireConnection;384;0;464;0
WireConnection;384;1;385;0
WireConnection;381;0;464;0
WireConnection;381;1;382;0
WireConnection;554;0;550;1
WireConnection;554;1;553;0
WireConnection;375;0;381;0
WireConnection;386;0;384;0
WireConnection;516;0;359;2
WireConnection;516;1;515;0
WireConnection;449;0;450;0
WireConnection;551;0;554;0
WireConnection;551;1;565;0
WireConnection;556;0;559;2
WireConnection;556;1;555;0
WireConnection;514;0;359;1
WireConnection;514;1;516;0
WireConnection;383;0;375;0
WireConnection;383;1;386;0
WireConnection;549;0;554;0
WireConnection;549;1;551;0
WireConnection;549;2;548;0
WireConnection;488;0;489;0
WireConnection;488;1;490;0
WireConnection;461;0;449;0
WireConnection;441;0;564;0
WireConnection;441;1;514;0
WireConnection;557;0;559;1
WireConnection;557;1;556;0
WireConnection;379;0;383;0
WireConnection;379;1;434;0
WireConnection;454;0;434;0
WireConnection;454;1;461;0
WireConnection;487;0;549;0
WireConnection;487;2;488;0
WireConnection;487;1;491;0
WireConnection;558;0;557;0
WireConnection;558;1;566;0
WireConnection;506;0;441;0
WireConnection;470;0;467;2
WireConnection;455;0;379;0
WireConnection;455;1;454;0
WireConnection;573;0;487;0
WireConnection;561;0;557;0
WireConnection;561;1;558;0
WireConnection;561;2;562;0
WireConnection;536;0;533;0
WireConnection;536;1;534;0
WireConnection;363;0;506;1
WireConnection;363;1;455;0
WireConnection;364;0;506;1
WireConnection;364;1;455;0
WireConnection;475;1;574;0
WireConnection;538;0;561;0
WireConnection;538;2;536;0
WireConnection;538;1;537;0
WireConnection;362;0;363;0
WireConnection;362;1;364;0
WireConnection;362;2;472;0
WireConnection;569;0;538;0
WireConnection;543;0;475;2
WireConnection;543;1;544;0
WireConnection;365;0;506;0
WireConnection;365;1;362;0
WireConnection;568;0;365;0
WireConnection;458;0;459;0
WireConnection;458;1;460;0
WireConnection;545;0;543;0
WireConnection;545;1;546;0
WireConnection;513;0;545;0
WireConnection;539;1;575;0
WireConnection;360;0;568;0
WireConnection;360;2;458;0
WireConnection;525;0;528;0
WireConnection;525;1;523;0
WireConnection;527;0;524;0
WireConnection;527;2;525;0
WireConnection;527;1;526;0
WireConnection;358;1;360;0
WireConnection;540;0;539;2
WireConnection;540;1;541;0
WireConnection;511;0;513;0
WireConnection;511;1;512;0
WireConnection;502;0;358;4
WireConnection;502;1;511;0
WireConnection;502;2;540;0
WireConnection;474;1;527;0
WireConnection;501;0;358;2
WireConnection;501;1;511;0
WireConnection;501;2;540;0
WireConnection;578;0;475;2
WireConnection;578;1;579;0
WireConnection;499;0;501;0
WireConnection;499;1;474;2
WireConnection;500;0;502;0
WireConnection;500;1;474;2
WireConnection;581;1;578;0
WireConnection;389;0;530;0
WireConnection;389;1;391;4
WireConnection;389;2;463;0
WireConnection;389;3;581;0
WireConnection;387;0;391;0
WireConnection;387;1;392;0
WireConnection;387;2;530;0
WireConnection;390;0;389;0
WireConnection;97;0;585;2
WireConnection;97;1;585;26
WireConnection;584;0;390;0
WireConnection;584;1;583;0
WireConnection;583;0;582;0
WireConnection;465;0;380;0
WireConnection;585;9;589;0
WireConnection;585;28;584;0
WireConnection;588;0;587;0
WireConnection;588;1;586;0
WireConnection;588;2;590;0
WireConnection;589;0;588;0
WireConnection;589;1;387;0
WireConnection;590;0;591;0
WireConnection;591;0;593;0
WireConnection;591;1;592;0
WireConnection;593;0;594;0
WireConnection;593;1;598;0
WireConnection;598;0;530;0
WireConnection;598;1;597;1
WireConnection;598;2;596;0
WireConnection;530;0;500;0
WireConnection;530;1;499;0
WireConnection;530;2;531;0
ASEEND*/
//CHKSM=126D3AFDEE0F09A50572AB3ECED5D32FCF0D9C9B