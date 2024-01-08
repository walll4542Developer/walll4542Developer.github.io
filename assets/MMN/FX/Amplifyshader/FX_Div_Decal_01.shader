// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Div_Deacal_01"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector][Toggle(_FOG_RCV_ON)] _FogReceive("안개 적용", Float) = 0
		[HideInInspector][PerRendererData]_RaycastHarftoneClip("raycastHarftoneClip", Range( 0 , 1)) = 0
		[HideInInspector]_RaycastMinimumAlpha("raycastMinimumAlpha", Range( 0 , 1)) = 0
		[HideInInspector]_NearPlaneAlpha("nearPlaneAlpha", Range( 0 , 1)) = 0
		[HideInInspector][Toggle]_NearPlaneInvertDistance("nearPlaneInvertDistance", Range( 0 , 1)) = 0
		[HideInInspector][Space(10)][Toggle(_LIGHTRECEIVE_ON)] _LightReceive("빛 적용", Float) = 0
		[HideInInspector][Toggle(_SOFTPARTICLE_ON)] _SoftParticle("소프트 파티클 적용", Float) = 0
		[HideInInspector][Toggle(_RAYCAST_ON)] _Raycast("레이캐스트 적용", Float) = 0
		[HideInInspector]_LightRatio("lightRatio", Range( 0 , 1)) = 1
		[HideInInspector]_SoftParticleNearFadeDistance("Soft Particle Near Fade", Float) = 0
		[HideInInspector]_SoftParticleFarFadeDistance("Soft Particle Far Fade", Float) = 1
		[HideInInspector]_SoftParticleFadeOutRange("사라지는 범위 조절", Range( 0 , 10)) = 1
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle][Enum(Noraml,0,Polar,1)]_Type("Type", Float) = 0
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
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		_Cutout("Cutout", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10

	}

	SubShader
	{
		LOD 0

		

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

			// GPU Instancing
			
			// Material Keywords
			// 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
			// #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // Unity defined keywords
			#pragma multi_compile_fog
			#pragma multi_compile_fragment _ DEBUG_DISPLAY
			// #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            // #pragma multi_compile_fragment _ _SHADOWS_SOFT
            // #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // #pragma multi_compile_fragment _ _LIGHT_COOKIES
			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			#include "../Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _AddNoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _BaseColor;
			float4 _MainColor;
			float4 _SubColor;
			float _LightRatio;
			float _Color_Range;
			float _Color_Offset;
			float _ColorGradation;
			float _Cutout;
			float _Use_G_Channel_Alpha;
			float _AddNoise_Tile_V;
			float _AddNoise_Tile_U;
			float _AddNoise_Y_Speed;
			float _AddNoise_X_Speed;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Distortion_Offset;
			float _Noise_Tile_V;
			float _Noise_Tile_U;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Type;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Intensity_Color;
			float _Intensity_Alpha;
			CBUFFER_END

			float _Mode = -1;
			float _TransitionValue = 1;
			float _FogPower = 0;

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
    			half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				half4 color : COLOR;
				
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				half4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream 
				half4 uv1 : TEXCOORD1; 				// xyzw : custom data
				half4 fogCoord : TEXCOORD2; 		// x : fogcoord				yzw :
				half3 positionWS : TEXCOORD11;
				float4 positionOS : TEXCOORD12;
				float3 normalWS : TEXCOORD13;

				float4 ase_texcoord3 : TEXCOORD3;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
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

				VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

				input.normalOS = input.normalOS;

				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord; // output.shadowCoord
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionOS = input.positionOS;
				output.positionCS = vertexInput.positionCS;
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				float localApplySoftParticle80_g49 = ( 0.0 );
				float localApplyLightColor6_g49 = ( 0.0 );
				float localApplyShadowAtten104_g49 = ( 0.0 );
				half localApplyRaycastingAlpha92_g49 = ( 0.0 );
				float localApplyScreenSpaceDecal36_g50 = ( 0.0 );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g50 = ase_screenPosNorm;
				float2 decalUV36_g50 = float2( 0,0 );
				float boundingBox36_g50 = 0.0;
				ApplyScreenSpaceDecal( screenPos36_g50 , decalUV36_g50 , boundingBox36_g50 );
				float2 Decal_UV399 = decalUV36_g50;
				float2 CenteredUV15_g48 = ( Decal_UV399 - float2( 0.5,0.5 ) );
				float2 break17_g48 = CenteredUV15_g48;
				float2 appendResult23_g48 = (float2(( length( CenteredUV15_g48 ) * 1.0 * 2.0 ) , ( atan2( break17_g48.x , break17_g48.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 temp_output_365_0 = appendResult23_g48;
				float Polar353 = _Type;
				float2 lerpResult364 = lerp( Decal_UV399 , temp_output_365_0 , Polar353);
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + Decal_UV399);
				float2 CenteredUV15_g43 = ( Decal_UV399 - float2( 0.5,0.5 ) );
				float2 break17_g43 = CenteredUV15_g43;
				float2 appendResult23_g43 = (float2(( length( CenteredUV15_g43 ) * _Noise_Tile_U * 2.0 ) , ( atan2( break17_g43.x , break17_g43.y ) * ( 1.0 / TWO_PI ) * _Noise_Tile_V )));
				float2 panner362 = ( 1.0 * _Time.y * appendResult52 + appendResult23_g43);
				float2 lerpResult351 = lerp( panner49 , panner362 , Polar353);
				float temp_output_81_0 = ( tex2D( _NoiseTex, lerpResult351 ).g + _Distortion_Offset );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power ) , ( temp_output_81_0 * _Distortion_Y_Power )));
				float4 tex2DNode5 = tex2D( _MainTex, ( lerpResult364 + appendResult77 ) );
				float2 appendResult89 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 panner90 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult89 + Decal_UV399);
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
				float Decal_Alpha407 = boundingBox36_g50;
				float4 appendResult32_g49 = (float4(appendResult243 , ( _BaseColor.a * (Color419).a * saturate( ( ( temp_output_22_0 / ( ( 1.0 - temp_output_150_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * Decal_Alpha407 )));
				half4 finalColor92_g49 = appendResult32_g49;
				half3 positionWS92_g49 = input.positionWS;
				half4 screenUV92_g49 = ase_screenPosNorm;
				half4 screenPos92_g49 = ase_screenPosNorm;
				half nearPlane92_g49 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g49 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g49 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g49 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g49 , positionWS92_g49 , screenUV92_g49 , screenPos92_g49 , nearPlane92_g49 , nearPlaneInvertDistance92_g49 , raycastHarftoneClip92_g49 , raycastMinimumAlpha92_g49 );
				float4 finalColor104_g49 = finalColor92_g49;
				float4 shadowCoord104_g49 = input.uv0;
				float3 positionWS104_g49 = input.positionWS;
				float lightRatio104_g49 = _LightRatio;
				ApplyShadowAtten( finalColor104_g49 , shadowCoord104_g49 , positionWS104_g49 , lightRatio104_g49 );
				float4 finalColor6_g49 = finalColor104_g49;
				float3 normalWS6_g49 = input.normalWS;
				float lightRatio6_g49 = _LightRatio;
				ApplyLightColor( finalColor6_g49 , normalWS6_g49 , lightRatio6_g49 );
				float4 finalColor80_g49 = finalColor6_g49;
				float near80_g49 = _SoftParticleNearFadeDistance;
				float far80_g49 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g49 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g49 = ( 0.0 );
				float4 positionCS58_g49 = float4( 0,0,0,0 );
				float4 positionNDC58_g49 = float4( 0,0,0,0 );
				float3 positionOS58_g49 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g49 , positionNDC58_g49 , positionOS58_g49 );
				float4 positionNDC80_g49 = positionNDC58_g49;
				ApplySoftParticle( finalColor80_g49 , near80_g49 , far80_g49 , fadeOutRange80_g49 , positionNDC80_g49 );
				float4 break64_g49 = finalColor80_g49;
				float3 appendResult76_g49 = (float3(break64_g49.x , break64_g49.y , break64_g49.z));
				
				float3 Color = appendResult76_g49;
				float Alpha = break64_g49.w;

				float4 finalColor = float4(Color, Alpha);
				ApplyFogColor(finalColor, input.positionWS, input.normalWS, _Mode, _FogPower, input.fogCoord.x);
				ApplyTransitionValue(finalColor, _Mode, _TransitionValue);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, Color, Alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"
	FallBack Off
	
	Fallback "Off"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;424;609.8897,205.5085;Inherit;False;1206.545;687.9583;;10;22;42;376;44;41;40;152;153;43;150;Texture Cutout / Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;415;-710.2073,-168.0522;Inherit;False;919.0228;343.2153;MainTexture UV;6;404;363;403;365;364;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;414;-710.9044,-885.5891;Inherit;False;916.6899;701.7622;AddNoiseTexture UV;12;370;372;371;374;405;90;86;373;369;89;127;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;406;-1539.542,193.0832;Inherit;False;1749.632;692.7508;NoiseTexture UV;21;77;79;375;73;72;71;81;48;187;50;126;49;402;52;354;351;362;401;348;347;330;Texture Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;133;243.8043,-882.2222;Inherit;False;1364.257;491.118;;16;368;419;25;35;29;33;26;34;32;30;134;136;366;367;154;426;Color Gradation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;132;1766.463,-421.8179;Inherit;False;179.2;183.4;Switch;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;112;2628.977,-87.39326;Inherit;False;244.0042;447.334;Rendering Options;4;113;116;392;393;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;116;2660.977,-39.39327;Inherit;False;Property;_BlendSrc;Blend Src;40;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;2660.977,40.6067;Inherit;False;Property;_BlendDst;Blend Dst;41;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;330;-1292.309,287.5741;Inherit;False;Polar Coordinates;-1;;43;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-1497.409,321.5881;Inherit;False;Property;_Noise_Tile_U;Noise_Tile_U;19;0;Create;True;0;0;0;False;1;Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;348;-1488.114,391.4841;Inherit;False;Property;_Noise_Tile_V;Noise_Tile_V;20;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-1486.549,239.44;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;362;-1058.501,351.8054;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;351;-859.8222,356.5302;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;354;-1054.164,476.4971;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1287.371,638.6193;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;402;-1318.422,560.7973;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-1058.382,567.1578;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;126;-1286.68,768.7188;Inherit;False;MMN_Time;-1;;45;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1491.676,621.7589;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;17;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;187;-1489.196,711.9207;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;18;0;Create;True;0;0;0;False;0;False;1;-0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;413;161.6548,-184.3911;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-683.5085,-381.4698;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;127;-388.2579,-314.9185;Inherit;False;MMN_Time;-1;;46;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-462.008,-461.47;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;369;-216.0578,-762.6311;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;373;-45.57799,-680.7985;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-683.5085,-461.47;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;25;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;90;-220.9085,-498.97;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;405;-688.3668,-585.7604;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;374;-249.7642,-608.1306;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;371;-475.7644,-810.6627;Inherit;False;Polar Coordinates;-1;;47;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;372;-687.7664,-835.7486;Inherit;False;Property;_AddNoise_Tile_U;AddNoise_Tile_U;28;0;Create;True;0;0;0;False;1;Space();False;1;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-681.7714,-743.2524;Inherit;False;Property;_AddNoise_Tile_V;AddNoise_Tile_V;29;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-705.4935,329.0183;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;d837d530b5931a647abf5aa9974b95c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-414.8804,377.3859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-660.5402,520.0167;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;21;0;Create;True;0;0;0;False;1;Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-184.2172,323.5698;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-410.4205,298.1585;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;22;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-415.553,474.359;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;23;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-186.2172,434.57;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;-9.21736,357.5698;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;364;-66.12847,-27.01192;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;365;-515.5478,-114.946;Inherit;False;Polar Coordinates;-1;;48;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;403;-697.4596,-117.8214;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;-247.5258,26.42875;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;404;-252.8362,-48.88953;Inherit;False;399;Decal UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;100.2982,66.77998;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;258.1022,-766.6576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;367;274.4558,-545.0918;Inherit;False;353;Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;642.6927,-713.8528;Inherit;False;Property;_Color_Offset;Color_Offset;35;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;820.4659,-717.2122;Inherit;False;Property;_Color_Range;Color_Range;36;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1010.644,-745.2313;Inherit;False;Property;_SubColor;Sub Color;33;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.1981132,0.1981132,0.1981132,0.8627451;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;1015.798,-575.9598;Inherit;False;Property;_MainColor;Main Color;32;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;0.09433959,0.09433959,0.09433959,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;25;1252.203,-778.4351;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;419;1389.768,-767.5082;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;368;270.451,-646.1124;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;128;1789.263,-371.8181;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;420;1288.186,-169.951;Inherit;False;419;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;1458.388,-352.0859;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;2061.46,-379.5687;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;2211.46,-374.5687;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;119;2400.667,-367.2651;Inherit;False;MMN_CommonOutputs;0;;49;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SaturateNode;150;839.2828,430.4416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;1015.283,430.4416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;1015.283,510.4417;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;1159.283,430.4416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;1303.283,318.4414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;1511.283,318.4414;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;1655.283,318.4414;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;376;709.4476,433.0218;Inherit;False;Property;_Cutout;Cutout;39;0;Create;True;0;0;0;False;0;False;0;0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;1302.283,437.4416;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;38;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;1088.615,270.0924;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;1877.329,475.2921;Inherit;False;407;Decal Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;410;1857.844,305.4845;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2124.762,302.7604;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;2010.06,-237.069;Inherit;False;Property;_Intensity_Color;Intensity_Color;37;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;297.2144,-62.74542;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;20fdb8dfded9fe841b8a1dc450752be4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;85;280.8204,-284.7498;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;24;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;797cb16604acdde438871d273fc38fbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;422;608.5625,-341.3942;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;625.0135,-212.7287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;637.9131,-80.72882;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;639.379,59.18319;Inherit;False;416;Texure Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;129;833.9372,-145.3823;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;426;527.5844,-399.5598;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;425;1177.552,-268.1461;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;2668.136,-360.557;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;16;MMN/FX/Amplify shader/FX_Div_Deacal_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;1;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;393;2667.034,217.0392;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;2667.034,137.0393;Inherit;False;Property;_CullMode;Cull Mode;30;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;353;-969.2443,-126.8389;Inherit;False;Polar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;350;-1139.818,-126.2299;Inherit;False;Property;_Type;Type;15;2;[Toggle];[Enum];Create;True;2;Header(Color);Space();2;Noraml;0;Polar;1;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;400;-1137.278,-17.30642;Inherit;False;MMN_Decal;-1;;50;e77bca24c8bef3c4f881df7c049f144a;0;0;2;FLOAT2;62;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;399;-962.2779,-18.30654;Inherit;False;Decal UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;-949.1766,66.26814;Inherit;False;Decal Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-935.2231,-216.8266;Inherit;False;Texure Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1178.531,-225.76;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;478.8044,-593.2222;Inherit;False;Property;_ColorGradation;Color Gradation;31;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;630.8045,-831.2222;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;366;464.3897,-760.2975;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;878.4655,-833.2123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;1023.465,-834.2123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;772.4659,-834.2123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;1744.761,-222.7714;Inherit;False;416;Texure Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;421;1832.405,221.268;Inherit;False;419;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;394;1755.934,-129.0868;Inherit;False;Property;_BaseColor;베이스 틴트;34;0;Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
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
WireConnection;49;0;402;0
WireConnection;49;2;52;0
WireConnection;49;1;126;0
WireConnection;413;0;365;0
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;369;0;371;0
WireConnection;369;2;89;0
WireConnection;373;0;90;0
WireConnection;373;1;369;0
WireConnection;373;2;374;0
WireConnection;90;0;405;0
WireConnection;90;2;89;0
WireConnection;90;1;127;0
WireConnection;371;1;405;0
WireConnection;371;3;372;0
WireConnection;371;4;370;0
WireConnection;48;1;351;0
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;79;0;81;0
WireConnection;79;1;375;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;364;0;404;0
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
WireConnection;61;0;128;0
WireConnection;61;1;394;0
WireConnection;61;2;60;0
WireConnection;243;0;61;0
WireConnection;119;9;243;0
WireConnection;119;28;45;0
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
WireConnection;121;0;119;2
WireConnection;121;1;119;26
WireConnection;353;0;350;0
WireConnection;399;0;400;62
WireConnection;407;0;400;2
WireConnection;416;0;130;0
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
ASEEND*/
//CHKSM=3CC0F58577D8EA992D0404D9164417152417BC46