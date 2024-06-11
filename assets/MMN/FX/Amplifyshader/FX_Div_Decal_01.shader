// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Div_Decal_01"
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
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle][Enum(Noraml,0,Polar,1)]_Type("Type", Float) = 0
		[Space()]_Main_Tile_U("Main_Tile_U", Float) = 1
		_Main_Tile_V("Main_Tile_V", Float) = 1
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Space()]_Noise_Tile_U("Noise_Tile_U", Float) = 1
		_Noise_Tile_V("Noise_Tile_V", Float) = 1
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = 0
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space()]_AddNoise_Tile_U("AddNoise_Tile_U", Float) = 1
		_AddNoise_Tile_V("AddNoise_Tile_V", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		_BaseColor("베이스 틴트", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		_Cutout("Cutout", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10

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
			Tags { "LightMode"="Decal" }

			Cull Front
			Blend [_BlendSrc] [_BlendDst]
			ZTest Always
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
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _AddNoiseTex;
			float _DimmingFactor;
			float _IsControlPlayer;
			CBUFFER_START( UnityPerMaterial )
			float4 _BaseColor;
			float4 _SubColor;
			float4 _MainColor;
			float _NearPlaneAlpha;
			float _Distortion_Offset;
			float _Distortion_X_Power;
			float _Distortion_Y_Power;
			float _AddNoise_X_Speed;
			float _AddNoise_Y_Speed;
			float _AddNoise_Tile_U;
			float _AddNoise_Tile_V;
			float _Use_G_Channel_Alpha;
			float _Cutout;
			float _ColorGradation;
			float _Color_Offset;
			float _Color_Range;
			float _Intensity_Color;
			float _Noise_Tile_V;
			float _Intensity_Alpha;
			float _Noise_Tile_U;
			float _Noise_X_Speed;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _LightReceive;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _Noise_Y_Speed;
			float _SoftParticleFadeOutRange;
			float _Mode;
			float _FogReceive;
			float _TransitionValue;
			float _SpawnTransition;
			float _Main_Tile_U;
			float _Main_Tile_V;
			float _Type;
			float _SoftParticle;
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
				float4 ase_texcoord2 : TEXCOORD2;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord2 = screenPos;
				
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
				float localFXFinalColorOutputs125_g51 = ( 0.0 );
				float localApplyScreenSpaceDecal36_g54 = ( 0.0 );
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g54 = ase_screenPosNorm;
				float2 decalUV36_g54 = float2( 0,0 );
				float boundingBox36_g54 = 0.0;
				float4 decalWorldSpace36_g54 = float4( 0,0,0,0 );
				ApplyScreenSpaceDecal( screenPos36_g54 , decalUV36_g54 , boundingBox36_g54 , decalWorldSpace36_g54 );
				float2 Decal_UV399 = decalUV36_g54;
				float2 break455 = Decal_UV399;
				float2 appendResult460 = (float2(( break455.x * _Main_Tile_U ) , ( break455.y * _Main_Tile_V )));
				float2 CenteredUV15_g48 = ( Decal_UV399 - float2( 0.5,0.5 ) );
				float2 break17_g48 = CenteredUV15_g48;
				float2 appendResult23_g48 = (float2(( length( CenteredUV15_g48 ) * 1.0 * 2.0 ) , ( atan2( break17_g48.x , break17_g48.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 temp_output_365_0 = appendResult23_g48;
				float Polar353 = _Type;
				float2 lerpResult364 = lerp( appendResult460 , temp_output_365_0 , Polar353);
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 break446 = Decal_UV399;
				float2 appendResult445 = (float2(( break446.x * _Noise_Tile_U ) , ( break446.y * _Noise_Tile_V )));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + appendResult445);
				float2 CenteredUV15_g52 = ( Decal_UV399 - float2( 0.5,0.5 ) );
				float2 break17_g52 = CenteredUV15_g52;
				float2 appendResult23_g52 = (float2(( length( CenteredUV15_g52 ) * _Noise_Tile_U * 2.0 ) , ( atan2( break17_g52.x , break17_g52.y ) * ( 1.0 / TWO_PI ) * _Noise_Tile_V )));
				float2 panner362 = ( 1.0 * _Time.y * appendResult52 + appendResult23_g52);
				float2 lerpResult351 = lerp( panner49 , panner362 , Polar353);
				float temp_output_81_0 = ( tex2D( _NoiseTex, lerpResult351 ).g + _Distortion_Offset );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power ) , ( temp_output_81_0 * _Distortion_Y_Power )));
				float4 tex2DNode5 = tex2D( _MainTex, ( lerpResult364 + appendResult77 ) );
				float2 appendResult89 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 break450 = Decal_UV399;
				float2 appendResult452 = (float2(( break450.x * _AddNoise_Tile_U ) , ( break450.y * _AddNoise_Tile_V )));
				float2 panner90 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult89 + appendResult452);
				float2 CenteredUV15_g47 = ( Decal_UV399 - float2( 0.5,0.5 ) );
				float2 break17_g47 = CenteredUV15_g47;
				float2 appendResult23_g47 = (float2(( length( CenteredUV15_g47 ) * _AddNoise_Tile_U * 2.0 ) , ( atan2( break17_g47.x , break17_g47.y ) * ( 1.0 / TWO_PI ) * _AddNoise_Tile_V )));
				float2 panner369 = ( 1.0 * _Time.y * appendResult89 + appendResult23_g47);
				float2 lerpResult373 = lerp( panner90 , panner369 , Polar353);
				float4 tex2DNode85 = tex2D( _AddNoiseTex, lerpResult373 );
				float Texure_Alpha416 = _Use_G_Channel_Alpha;
				float lerpResult129 = lerp( ( tex2DNode85.g * tex2DNode5.a ) , ( tex2DNode85.g * tex2DNode5.g ) , Texure_Alpha416);
				float temp_output_150_0 = saturate( _Cutout );
				float temp_output_22_0 = ( lerpResult129 - temp_output_150_0 );
				float2 texCoord154 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult366 = lerp( texCoord154.x , temp_output_365_0.x , Polar353);
				float lerpResult136 = lerp( temp_output_22_0 , lerpResult366 , _ColorGradation);
				float4 lerpResult25 = lerp( _SubColor , _MainColor , saturate( ( ( lerpResult136 + _Color_Offset ) * _Color_Range ) ));
				float4 Color419 = lerpResult25;
				float4 lerpResult128 = lerp( ( tex2DNode5 * Color419 ) , Color419 , Texure_Alpha416);
				float3 appendResult243 = (float3(( lerpResult128 * _BaseColor * _Intensity_Color ).rgb));
				float DimmingFactor436 = ( _DimmingFactor * _IsControlPlayer );
				float lerpResult433 = lerp( 1.0 , 3.0 , DimmingFactor436);
				float ColorForDimming434 = lerpResult433;
				float Decal_Alpha407 = boundingBox36_g54;
				float4 appendResult32_g51 = (float4(( appendResult243 * ColorForDimming434 ) , ( ( _BaseColor.a * (Color419).a * saturate( ( ( temp_output_22_0 / ( ( 1.0 - temp_output_150_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * Decal_Alpha407 ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g51 = appendResult32_g51;
				float4 texCoord147_g51 = input.screenPos;
				texCoord147_g51.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g51 = texCoord147_g51;
				float4 positionNDC125_g51 = ScreenPos146_g51;
				float4 texCoord140_g51 = input.fogCoord;
				texCoord140_g51.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g51 = texCoord140_g51;
				float4 fogCoord125_g51 = fogCoord139_g51;
				float3 positionWS125_g51 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g51 = normalizedWorldNormal;
				float nearPlaneAlpha125_g51 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g51 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g51 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g51 = _RaycastMinimumAlpha;
				float lightRatio125_g51 = _LightRatio;
				float lightReceive125_g51 = _LightReceive;
				float near125_g51 = _SoftParticleNearFadeDistance;
				float far125_g51 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g51 = _SoftParticleFadeOutRange;
				float softParticle125_g51 = _SoftParticle;
				float mode125_g51 = _Mode;
				float fogReceive125_g51 = _FogReceive;
				float transitionValue125_g51 = _TransitionValue;
				float spawnTransition125_g51 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g51 , positionNDC125_g51 , fogCoord125_g51 , positionWS125_g51 , normalWS125_g51 , nearPlaneAlpha125_g51 , nearPlaneInvertDistance125_g51 , raycastHarftoneClip125_g51 , raycastMinimumAlpha125_g51 , lightRatio125_g51 , lightReceive125_g51 , near125_g51 , far125_g51 , fadeOutRange125_g51 , softParticle125_g51 , mode125_g51 , fogReceive125_g51 , transitionValue125_g51 , spawnTransition125_g51 );
				float4 break64_g51 = finalColor125_g51;
				float3 appendResult76_g51 = (float3(break64_g51.x , break64_g51.y , break64_g51.z));
				
				float3 color = appendResult76_g51;
				float alpha = break64_g51.w;

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
Node;AmplifyShaderEditor.CommentaryNode;462;2112,-928;Inherit;False;724;435;ColorForDimming;8;435;461;436;434;432;431;433;463;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;424;609.8897,205.5085;Inherit;False;1206.545;687.9583;;10;22;42;376;44;41;40;152;153;43;150;Texture Cutout / Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;415;-1036,-168.0522;Inherit;False;1244.815;512.6932;MainTexture UV;12;404;456;460;457;459;458;455;403;67;363;365;364;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;414;-1035.322,-885.5891;Inherit;False;1241.108;704.053;AddNoiseTexture UV;17;450;370;372;451;449;452;86;454;371;374;90;373;369;89;127;87;405;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;406;-2372.332,387.8854;Inherit;False;2600.312;691.1053;NoiseTexture UV;25;445;448;446;447;402;348;347;401;48;77;79;375;73;72;71;81;187;50;126;49;52;354;351;362;330;Texture Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;133;243.8043,-882.2222;Inherit;False;1364.257;491.118;;16;368;419;25;35;29;33;26;34;32;30;134;136;366;367;154;426;Color Gradation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;132;1766.463,-421.8179;Inherit;False;179.2;183.4;Switch;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;112;2944,-224;Inherit;False;200.0042;391.334;Rendering Options;4;392;393;113;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;413;161.6548,-184.3911;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-683.5085,-381.4698;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;31;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;127;-388.2579,-314.9185;Inherit;False;MMN_Time;-1;;46;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-462.008,-461.47;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;369;-216.0578,-762.6311;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;373;-45.57799,-680.7985;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;90;-220.9085,-498.97;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-249.7642,-608.1306;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;371;-475.7644,-810.6627;Inherit;False;Polar Coordinates;-1;;47;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;364;-66.12847,-27.01192;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;365;-515.5478,-114.946;Inherit;False;Polar Coordinates;-1;;48;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;-247.5258,26.42875;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;100.2982,66.77998;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;258.1022,-766.6576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;367;274.4558,-545.0918;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;642.6927,-713.8528;Inherit;False;Property;_Color_Offset;Color_Offset;40;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;820.4659,-717.2122;Inherit;False;Property;_Color_Range;Color_Range;41;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1010.644,-745.2313;Inherit;False;Property;_SubColor;Sub Color;38;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.1981132,0.1981132,0.1981132,0.8627451;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;1015.798,-575.9598;Inherit;False;Property;_MainColor;Main Color;37;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;0.09433959,0.09433959,0.09433959,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;25;1252.203,-778.4351;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;1389.768,-767.5082;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;368;270.451,-646.1124;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;128;1789.263,-371.8181;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;1288.186,-169.951;Inherit;False;419;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1458.388,-352.0859;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;150;839.2828,430.4416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;1015.283,430.4416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;1015.283,510.4417;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;1159.283,430.4416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;1303.283,318.4414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1511.283,318.4414;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;1655.283,318.4414;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;709.4476,433.0218;Inherit;False;Property;_Cutout;Cutout;45;0;Create;True;0;0;0;False;0;False;0;0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1302.283,437.4416;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;44;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;1088.615,270.0924;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;1877.329,475.2921;Inherit;False;407;Decal Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;410;1857.844,305.4845;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2124.762,302.7604;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;2010.06,-237.069;Inherit;False;Property;_Intensity_Color;Intensity_Color;43;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;297.2144,-62.74542;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;20fdb8dfded9fe841b8a1dc450752be4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;280.8204,-284.7498;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;29;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;797cb16604acdde438871d273fc38fbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;422;608.5625,-341.3942;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;625.0135,-212.7287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;637.9131,-80.72882;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;639.379,59.18319;Inherit;False;416;Texure Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;129;833.9372,-145.3823;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;426;527.5844,-399.5598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;425;1177.552,-268.1461;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;478.8044,-593.2222;Inherit;False;Property;_ColorGradation;Color Gradation;36;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;630.8045,-831.2222;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;366;464.3897,-760.2975;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;878.4655,-833.2123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;1023.465,-834.2123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;772.4659,-834.2123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;1744.761,-222.7714;Inherit;False;416;Texure Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;421;1832.405,221.268;Inherit;False;419;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;394;1755.934,-129.0868;Inherit;False;Property;_BaseColor;베이스 틴트;39;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;2399.016,-100.9413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;428;2272.516,71.05874;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;2083.516,73.05874;Inherit;False;Property;_EffectAlpha;EffectAlpha;42;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;438;2272,-288;Inherit;False;434;ColorForDimming;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;2064,-384;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;2208,-384;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;437;2496,-384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;116;2976,-176;Inherit;False;Property;_BlendSrc;Blend Src;46;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;2976,-96;Inherit;False;Property;_BlendDst;Blend Dst;47;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;2960,-384;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Div_Decal_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;1;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;393;2976,64;Inherit;False;Property;_ZTest;Z Test;32;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;2976,-16;Inherit;False;Property;_CullMode;Cull Mode;35;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;2704,-384;Inherit;False;MMN_CommonOutputs;0;;51;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.FunctionNode;330;-1274.419,482.3763;Inherit;False;Polar Coordinates;-1;;52;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;362;-1040.611,546.6076;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;351;-841.9323,551.3324;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-1036.274,671.2993;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1269.481,833.4215;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-1040.492,761.96;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;126;-1268.79,963.521;Inherit;False;MMN_Time;-1;;53;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1473.786,816.5611;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;22;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-396.9904,572.1881;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-642.6503,714.8189;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;26;0;Create;True;0;0;0;False;1;Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-166.3272,518.372;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-392.5305,492.9607;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;27;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-397.663,669.1611;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;28;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-168.3272,629.3722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;8.672636,552.372;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-687.6036,523.8205;Inherit;True;Property;_NoiseTex;NoiseTex;21;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;d837d530b5931a647abf5aa9974b95c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;401;-1468.659,434.2422;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-2109.556,498.488;Inherit;False;Property;_Noise_Tile_U;Noise_Tile_U;24;0;Create;True;0;0;0;False;1;Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;402;-2303.568,714.6974;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-1897.984,748.9079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;446;-2074.984,742.9078;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;448;-1868.984,906.9079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;445;-1699.984,742.9079;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;454;-660.4146,-801.3412;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-686.5085,-471.47;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;30;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;353;-1472.244,-220.8389;Inherit;False;Polar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;350;-1642.818,-220.2299;Inherit;False;Property;_Type;Type;18;2;[Toggle];[Enum];Create;True;2;Header(Color);Space();2;Noraml;0;Polar;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;399;-1465.278,-112.3065;Inherit;False;Decal UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;-1452.177,-27.73186;Inherit;False;Decal Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-1438.223,-310.8266;Inherit;False;Texure Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1681.531,-319.76;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;403;-721.4596,-117.8214;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;455;-795.2037,193.4217;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;458;-401.2039,221.4218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;-399.2039,128.4218;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;457;-645.5957,249.5506;Inherit;False;Property;_Main_Tile_V;Main_Tile_V;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;460;-234.5498,177.0101;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;456;-650.5907,107.0544;Inherit;False;Property;_Main_Tile_U;Main_Tile_U;19;0;Create;True;0;0;0;False;1;Space();False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;404;-966.8362,194.1105;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;452;-459.3792,-582.3811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;-685.3792,-682.3811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;451;-688.3792,-577.3811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;372;-917.7664,-739.7485;Inherit;False;Property;_AddNoise_Tile_U;AddNoise_Tile_U;33;0;Create;True;0;0;0;False;1;Space();False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-920.7715,-513.2523;Inherit;False;Property;_AddNoise_Tile_V;AddNoise_Tile_V;34;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;450;-832.379,-634.3812;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;405;-1005.221,-637.2319;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1471.306,906.7229;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;23;0;Create;True;0;0;0;False;0;False;1;-0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-2108.26,575.3842;Inherit;False;Property;_Noise_Tile_V;Noise_Tile_V;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;400;-1680,-112;Inherit;False;MMN_Decal;-1;;54;e77bca24c8bef3c4f881df7c049f144a;0;0;3;FLOAT2;62;FLOAT;2;FLOAT4;66
Node;AmplifyShaderEditor.RegisterLocalVarNode;434;2592,-704;Inherit;False;ColorForDimming;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;432;2160,-704;Inherit;False;Constant;_DimmingColorIntensity;DimmingColorIntensity;15;0;Create;False;0;0;0;True;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;431;2192,-608;Inherit;False;436;DimmingFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;433;2416,-704;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;436;2592,-880;Inherit;False;DimmingFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;2160,-880;Inherit;False;Global;_DimmingFactor;_DimmingFactor;15;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0.0486654;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;463;2448,-880;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;461;2160,-800;Inherit;False;Global;_IsControlPlayer;_IsControlPlayer;34;1;[HideInInspector];Create;True;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
WireConnection;413;0;365;0
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;369;0;371;0
WireConnection;369;2;89;0
WireConnection;373;0;90;0
WireConnection;373;1;369;0
WireConnection;373;2;374;0
WireConnection;90;0;452;0
WireConnection;90;2;89;0
WireConnection;90;1;127;0
WireConnection;371;1;454;0
WireConnection;371;3;372;0
WireConnection;371;4;370;0
WireConnection;364;0;460;0
WireConnection;364;1;365;0
WireConnection;364;2;363;0
WireConnection;365;1;403;0
WireConnection;67;0;364;0
WireConnection;67;1;77;0
WireConnection;25;0;29;0
WireConnection;25;1;35;0
WireConnection;25;2;34;0
WireConnection;419;0;25;0
WireConnection;368;0;413;0
WireConnection;128;0;125;0
WireConnection;128;1;420;0
WireConnection;128;2;418;0
WireConnection;125;0;422;0
WireConnection;125;1;420;0
WireConnection;150;0;376;0
WireConnection;43;0;150;0
WireConnection;152;0;43;0
WireConnection;152;1;153;0
WireConnection;40;0;22;0
WireConnection;40;1;152;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;44;0;41;0
WireConnection;22;0;129;0
WireConnection;22;1;150;0
WireConnection;410;0;421;0
WireConnection;45;0;394;4
WireConnection;45;1;410;0
WireConnection;45;2;44;0
WireConnection;45;3;408;0
WireConnection;5;1;67;0
WireConnection;85;1;373;0
WireConnection;422;0;5;0
WireConnection;91;0;85;2
WireConnection;91;1;5;2
WireConnection;92;0;85;2
WireConnection;92;1;5;4
WireConnection;129;0;92;0
WireConnection;129;1;91;0
WireConnection;129;2;417;0
WireConnection;426;0;425;0
WireConnection;425;0;22;0
WireConnection;136;0;426;0
WireConnection;136;1;366;0
WireConnection;136;2;134;0
WireConnection;366;0;154;1
WireConnection;366;1;368;0
WireConnection;366;2;367;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;34;0;32;0
WireConnection;30;0;136;0
WireConnection;30;1;26;0
WireConnection;427;0;45;0
WireConnection;427;1;428;0
WireConnection;428;0;429;0
WireConnection;61;0;128;0
WireConnection;61;1;394;0
WireConnection;61;2;60;0
WireConnection;243;0;61;0
WireConnection;437;0;243;0
WireConnection;437;1;438;0
WireConnection;121;0;119;2
WireConnection;121;1;119;26
WireConnection;119;9;437;0
WireConnection;119;28;427;0
WireConnection;330;1;401;0
WireConnection;330;3;347;0
WireConnection;330;4;348;0
WireConnection;362;0;330;0
WireConnection;362;2;52;0
WireConnection;351;0;49;0
WireConnection;351;1;362;0
WireConnection;351;2;354;0
WireConnection;52;0;50;0
WireConnection;52;1;187;0
WireConnection;49;0;445;0
WireConnection;49;2;52;0
WireConnection;49;1;126;0
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;79;0;81;0
WireConnection;79;1;375;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;48;1;351;0
WireConnection;447;0;446;0
WireConnection;447;1;347;0
WireConnection;446;0;402;0
WireConnection;448;0;446;1
WireConnection;448;1;348;0
WireConnection;445;0;447;0
WireConnection;445;1;448;0
WireConnection;353;0;350;0
WireConnection;399;0;400;62
WireConnection;407;0;400;2
WireConnection;416;0;130;0
WireConnection;455;0;404;0
WireConnection;458;0;455;1
WireConnection;458;1;457;0
WireConnection;459;0;455;0
WireConnection;459;1;456;0
WireConnection;460;0;459;0
WireConnection;460;1;458;0
WireConnection;452;0;449;0
WireConnection;452;1;451;0
WireConnection;449;0;450;0
WireConnection;449;1;372;0
WireConnection;451;0;450;1
WireConnection;451;1;370;0
WireConnection;450;0;405;0
WireConnection;434;0;433;0
WireConnection;433;1;432;0
WireConnection;433;2;431;0
WireConnection;436;0;463;0
WireConnection;463;0;435;0
WireConnection;463;1;461;0
ASEEND*/
//CHKSM=009EE446DD873368B16CF92B3B39093489E6ABE4