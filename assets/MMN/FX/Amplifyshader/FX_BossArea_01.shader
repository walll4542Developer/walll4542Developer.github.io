// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_BossArea_01"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_WorldPivotAndRadius("경계의 월드 피벗(xyz)과 반지름(w)", Vector) = (0,0,0,25)
		[Toggle]_IsWorldPivot("월드 피벗 기준으로 사라지게 합니까?", Float) = 0
		_MinimumAlpha("알파의 최솟값", Range( 0 , 1)) = 0
		_DistanceBias("멀리있으면 사라지는 거리 (미터 단위 m 기준)", Range( 0 , 100)) = 20
		_Radius("버텍스 밀기의 범위", Range( 0 , 10)) = 10
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
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = -0.5
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		_DefaultValues("Default Values", Float) = 0
		_Noise_UV_pow("Noise_UV_pow", Float) = 2
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
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
			#include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"


			sampler2D _AddNoiseTex;
			sampler2D _NoiseTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float4 _SubColor;
			float4 _WorldPivotAndRadius;
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float4 _AddNoiseTex_ST;
			float _NearPlaneAlpha;
			float _Noise_UV_pow;
			float _Noise_X_Speed;
			float _Noise_Y_Speed;
			float _Distortion_Offset;
			float _Distortion_Y_Power;
			float _Use_G_Channel_Alpha;
			float _DefaultValues;
			float _ColorGradation;
			float _Color_Range;
			float _IsWorldPivot;
			float _DistanceBias;
			float _Distortion_X_Power;
			float _AddNoise_Y_Speed;
			float _AddNoise_X_Speed;
			float _Color_Offset;
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
			float _Radius;
			float _Intensity_Color;
			float _MinimumAlpha;
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

				float localInterectionBorderFX372 = ( 0.0 );
				float3 ase_worldPos = TransformObjectToWorld( (input.positionOS).xyz );
				float3 positionWS372 = ase_worldPos;
				float3 appendResult365 = (float3(_Global_pos.xyz));
				float3 GlobalPosition368 = appendResult365;
				float3 GlobalPosition372 = GlobalPosition368;
				float radius372 = _Radius;
				float3 offset372 = float3( 0,0,0 );
				float alpha372 = 1.0;
				InterectionBorderFX( positionWS372 , GlobalPosition372 , radius372 , offset372 , alpha372 );

				output.ase_color = input.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = offset372;
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
				float localFXFinalColorOutputs125_g37 = ( 0.0 );
				float2 appendResult89 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 uv_AddNoiseTex = input.uv0.xy * _AddNoiseTex_ST.xy + _AddNoiseTex_ST.zw;
				float temp_output_469_0 = pow( abs( uv_AddNoiseTex.x ) , _Noise_UV_pow );
				float temp_output_491_0 = saturate( ceil( uv_AddNoiseTex.x ) );
				float2 appendResult176 = (float2(( ( temp_output_469_0 * temp_output_491_0 ) - ( temp_output_469_0 * ( 1.0 - temp_output_491_0 ) ) ) , uv_AddNoiseTex.y));
				float3 ase_objectScale = float3( length( GetObjectToWorldMatrix()[ 0 ].xyz ), length( GetObjectToWorldMatrix()[ 1 ].xyz ), length( GetObjectToWorldMatrix()[ 2 ].xyz ) );
				float2 appendResult484 = (float2(( ase_objectScale.x * 0.01 ) , ase_objectScale.y));
				float2 UV_Pow478 = ( appendResult176 * appendResult484 );
				float2 panner90 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult89 + UV_Pow478);
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult185 = (float2(uv_NoiseTex.x , uv_NoiseTex.y));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + appendResult185);
				float4 tex2DNode48 = tex2D( _NoiseTex, panner49 );
				float temp_output_81_0 = ( tex2DNode48.g + _Distortion_Offset );
				float temp_output_151_0 = saturate( input.uv0.w );
				float2 appendResult77 = (float2(( temp_output_81_0 * _Distortion_X_Power * temp_output_151_0 ) , ( temp_output_81_0 * _Distortion_Y_Power * temp_output_151_0 )));
				float4 tex2DNode85 = tex2D( _AddNoiseTex, ( panner90 + appendResult77 ) );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float lerpResult129 = lerp( ( tex2DNode85.g * tex2DNode5.a * tex2DNode48.a ) , ( tex2DNode85.g * tex2DNode5.g ) , _Use_G_Channel_Alpha);
				float temp_output_150_0 = saturate( ( input.uv0.z + _DefaultValues ) );
				float temp_output_22_0 = ( lerpResult129 - temp_output_150_0 );
				float2 texCoord154 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult136 = lerp( temp_output_22_0 , texCoord154.x , _ColorGradation);
				float4 lerpResult25 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult136 ) * _Color_Range ) ));
				float4 lerpResult128 = lerp( ( lerpResult25 * tex2DNode5 ) , lerpResult25 , _Use_G_Channel_Alpha);
				float3 appendResult243 = (float3(( _Intensity_Color * lerpResult128 * input.ase_color ).rgb));
				float3 appendResult365 = (float3(_Global_pos.xyz));
				float3 GlobalPosition368 = appendResult365;
				float3 break306 = GlobalPosition368;
				float2 appendResult305 = (float2(break306.x , break306.z));
				float4 WorldPivotAndRadius319 = _WorldPivotAndRadius;
				float4 break307 = WorldPivotAndRadius319;
				float2 appendResult308 = (float2(break307.x , break307.z));
				float Distance309 = distance( appendResult305 , appendResult308 );
				float lerpResult300 = lerp( distance( input.positionWS , GlobalPosition368 ) , Distance309 , _IsWorldPivot);
				float DistanceBias277 = _WorldPivotAndRadius.w;
				float lerpResult363 = lerp( 5.0 , DistanceBias277 , _IsWorldPivot);
				float lerpResult297 = lerp( max( ( 1.0 - saturate( ( ( lerpResult300 - lerpResult363 ) / ( _DistanceBias + 0.01 ) ) ) ) , _MinimumAlpha ) , 1.0 , unity_OrthoParams.w);
				float localInterectionBorderFX372 = ( 0.0 );
				float3 positionWS372 = input.positionWS;
				float3 GlobalPosition372 = GlobalPosition368;
				float radius372 = _Radius;
				float3 offset372 = float3( 0,0,0 );
				float alpha372 = 1.0;
				InterectionBorderFX( positionWS372 , GlobalPosition372 , radius372 , offset372 , alpha372 );
				float4 appendResult32_g37 = (float4(appendResult243 , ( saturate( ( lerpResult297 * ( (lerpResult25).a * saturate( ( ( temp_output_22_0 / ( ( 1.0 - temp_output_150_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * input.ase_color.a ) ) ) * alpha372 )));
				float4 finalColor125_g37 = appendResult32_g37;
				float4 texCoord147_g37 = input.screenPos;
				texCoord147_g37.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g37 = texCoord147_g37;
				float4 positionNDC125_g37 = ScreenPos146_g37;
				float4 texCoord140_g37 = input.fogCoord;
				texCoord140_g37.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g37 = texCoord140_g37;
				float4 fogCoord125_g37 = fogCoord139_g37;
				float3 positionWS125_g37 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g37 = normalizedWorldNormal;
				float nearPlaneAlpha125_g37 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g37 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g37 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g37 = _RaycastMinimumAlpha;
				float lightRatio125_g37 = _LightRatio;
				float lightReceive125_g37 = _LightReceive;
				float near125_g37 = _SoftParticleNearFadeDistance;
				float far125_g37 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g37 = _SoftParticleFadeOutRange;
				float softParticle125_g37 = _SoftParticle;
				float mode125_g37 = _Mode;
				float fogReceive125_g37 = _FogReceive;
				float transitionValue125_g37 = _TransitionValue;
				float spawnTransition125_g37 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g37 , positionNDC125_g37 , fogCoord125_g37 , positionWS125_g37 , normalWS125_g37 , nearPlaneAlpha125_g37 , nearPlaneInvertDistance125_g37 , raycastHarftoneClip125_g37 , raycastMinimumAlpha125_g37 , lightRatio125_g37 , lightReceive125_g37 , near125_g37 , far125_g37 , fadeOutRange125_g37 , softParticle125_g37 , mode125_g37 , fogReceive125_g37 , transitionValue125_g37 , spawnTransition125_g37 );
				float4 break64_g37 = finalColor125_g37;
				float3 appendResult76_g37 = (float3(break64_g37.x , break64_g37.y , break64_g37.z));

				float3 color = appendResult76_g37;
				float alpha = break64_g37.w;

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
Node;AmplifyShaderEditor.CommentaryNode;479;-5018.462,-1548.544;Inherit;False;2132.066;786.7716;UV_Pow;16;478;485;484;270;176;468;475;474;88;476;470;472;471;469;488;491;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;362;352,-640;Inherit;False;1303;256;경계 포지션과 캐릭터 포지션;6;368;365;364;321;277;319;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;312;207.2717,299.0192;Inherit;False;1128.986;382.0809;XZ 평면에서만 계산합니다.;9;303;320;309;249;307;308;305;306;369;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;246;352,-352;Inherit;False;2028.109;512.7332;CameraDistance / NearHalftoneAlpha;22;218;361;276;300;283;358;295;223;297;207;269;261;360;359;310;302;228;363;366;367;370;489;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;82;-2686,528;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-2704,448;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;32;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-2533,141;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;30;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;151;-2384,496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2480,416;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;31;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-2461.112,285.9915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2240,176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-2240,288;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;77;-2096,176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;90;-2224.383,-305.0739;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;85;-1889.282,-317.1974;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;33;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;04b22506c10d2d94f983b5a17dfef117;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;131;-1488,64;Inherit;False;281.5415;271.9273;Switch;2;130;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1504.482,-146.5741;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1507.083,-39.9741;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1440,240;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;22;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;-1616,-672;Inherit;False;422.6843;276.8151;Color Gradation;2;136;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;129;-1360,112;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1069.068,276.851;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1584,-624;Inherit;False;Property;_ColorGradation;Color Gradation;38;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1248,-288;Inherit;False;Property;_Color_Offset;Color_Offset;42;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;136;-1360,-624;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-1056,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1056,-176;Inherit;False;Property;_Color_Range;Color_Range;43;0;Create;True;0;0;0;False;0;False;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-896,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;-928,-768;Inherit;False;Property;_SubColor;Sub Color;40;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0.2479339,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;34;-752,-288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-928,-560;Inherit;False;Property;_MainColor;Main Color;39;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;25;-656,-464;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-1184,512;Inherit;False;Constant;_Float0;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1184,432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-698.5396,-88.48444;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;132;-444.9,-360.2115;Inherit;False;179.2;183.4;Switch;1;128;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;152;-1040,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-897,439;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;45;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-352,-480;Inherit;False;Property;_Intensity_Color;Intensity_Color;44;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;128;-422.1001,-310.2115;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-896,320;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-688,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-144,-304;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;-544,208;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-544,320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;112;3456,-144;Inherit;False;204;375;Rendering Options;4;116;115;113;137;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-144,0;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;360;1344,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;269;1632,-128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OrthoParams;295;1632,-256;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;66;-384,-97;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;359;1488,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;1344,-48;Inherit;False;Property;_MinimumAlpha;알파의 최솟값;2;0;Create;False;0;0;0;True;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;297;1888,-128;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;2080,-128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;207;2240,-128;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;310;672,-144;Inherit;False;309;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;358;1216,-129;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;283;1072,-128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;300;896,-208;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;1088,-32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;800,64;Inherit;False;Property;_DistanceBias;멀리있으면 사라지는 거리 (미터 단위 m 기준);3;0;Create;False;0;0;0;True;0;False;20;0.5;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;363;896,-64;Inherit;False;3;0;FLOAT;5;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;306;687.2713,347.0191;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;305;815.2714,363.0191;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;249;959.2715,411.0192;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;308;815.2714,523.0193;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;307;671.2713,523.0193;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;320;415.2715,523.0193;Inherit;False;319;WorldPivotAndRadius;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;624,16;Inherit;False;277;DistanceBias;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;302;560,-64;Inherit;False;Property;_IsWorldPivot;월드 피벗 기준으로 사라지게 합니까?;1;1;[Toggle];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;367;704,-240;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;228;436,-286;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;303;463.2715,347.0191;Inherit;False; ;3;File;0;GetCameraPosition;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;0;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;369;447.2715,427.0192;Inherit;False;368;GlobalPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;365;1296,-576;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;368;1440,-576;Inherit;False;GlobalPosition;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;370;391.382,-140.876;Inherit;False;368;GlobalPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;321;400,-592;Inherit;False;Property;_WorldPivotAndRadius;경계의 월드 피벗(xyz)과 반지름(w);0;0;Create;False;0;0;0;True;0;False;0,0,0,25;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;277;784,-496;Inherit;False;DistanceBias;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;364;1072,-576;Inherit;False;Global;_Global_pos;_Global_pos;30;0;Fetch;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;243;0,-304;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;366;165,-221;Inherit;False;MMN_CameraDistance;-1;;31;56f3a7831b6d0f14ab4523551780d8eb;0;1;86;FLOAT3;0,0,0;False;1;FLOAT;26
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;784,-592;Inherit;False;WorldPivotAndRadius;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;1103.272,411.0192;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;469;-4264.229,-1498.544;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-3816.462,-1493.192;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;470;-4488.462,-1493.192;Inherit;False;Property;_Noise_UV_pow;Noise_UV_pow;37;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-2640,-272;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;34;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2640,-192;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;35;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-2416,-272;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;477;-2448,-384;Inherit;False;478;UV_Pow;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;127;-2432,-128;Inherit;False;MMN_Time;-1;;32;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;-1488,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;150;-1344,432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-1680,608;Inherit;False;Property;_DefaultValues;Default Values;36;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1696,432;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;476;-3586.8,-1253.321;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;474;-4016,-1248;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;475;-3816.462,-1253.192;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;468;-4475.261,-1353.126;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;176;-3360,-1168;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;485;-3216,-1168;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-1987,-870;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;489;2052.521,80.98842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;484;-3339,-945;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;478;-3072,-1168;Inherit;False;UV_Pow;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-1970.149,-97.56787;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1886.392,120.2251;Inherit;True;Property;_MainTex;MainTex;21;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;a6aeb5355da7b0d43b94c52a81a5f6a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2098.781,424.6501;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CeilOpNode;471;-4480,-1120;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;491;-4304,-1120;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;488;-3509.967,-1013.017;Inherit;False;0.01;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;88;-4968.462,-1253.192;Inherit;False;0;85;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;185;-3259.06,124.8558;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-3488,128;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;187;-3361.27,446.471;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;29;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-3360,368;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;26;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;126;-3162.133,540.4776;Inherit;False;MMN_Time;-1;;33;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-3184,368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-3004,346;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-2800,240;Inherit;True;Property;_NoiseTex;NoiseTex;23;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;514;2176,864;Inherit;True;Property;_DotTex1;DotTex;21;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Instance;513;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;515;1792,896;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;516;1968,880;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;519;1776,1008;Inherit;False;MMN_Time;-1;;34;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;1616,896;Inherit;False;Property;_Dot_G_Speed;Dot_G_Speed;27;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;270;-3696,-1008;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;507;1040,880;Inherit;False;0;513;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectScaleNode;529;1088,1024;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;530;1264,880;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;531;1264,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;532;1408,880;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;520;2176,1120;Inherit;True;Property;_DotTex2;DotTex;22;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Instance;513;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;522;1968,1136;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;524;1616,1152;Inherit;False;Property;_Dot_B_Speed;Dot_B_Speed;25;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;523;1776,1264;Inherit;False;MMN_Time;-1;;35;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;521;1792,1152;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;512;1984,608;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;509;1632,624;Inherit;False;Property;_Dot_R_Speed;Dot_R_Speed;28;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;510;1792,736;Inherit;False;MMN_Time;-1;;36;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;511;1808,624;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;116;3488,-96;Inherit;False;Property;_BlendSrc;Blend Src;46;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;3488,64;Inherit;False;Property;_CullMode;Cull Mode;48;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;113;3488,-16;Inherit;False;Property;_BlendDst;Blend Dst;47;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;3488,144;Inherit;False;Property;_ZTest;Z Test;41;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;121;3456,-304;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_BossArea_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;2;Include;;False;;Native;False;0;0;;Include;Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl;False;;Custom;False;0;0;;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;3008,-240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;381;2400,160;Inherit;False;Property;_Radius;버텍스 밀기의 범위;4;0;Create;False;0;0;0;True;0;False;10;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;372;2704,16;Inherit;False; ;7;File;5;True;positionWS;FLOAT3;0,0,0;In;;Inherit;False;True;GlobalPosition;FLOAT3;0,0,0;In;;Inherit;False;True;radius;FLOAT;0;In;;Inherit;False;True;offset;FLOAT3;0,0,0;Out;;Inherit;False;True;alpha;FLOAT;1;Out;;Inherit;False;InterectionBorderFX;False;True;0;d2b180d66d3b6594ba4923958c85921a;False;6;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;3;FLOAT;0;FLOAT3;5;FLOAT;6
Node;AmplifyShaderEditor.WorldPosInputsNode;371;2480,-64;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;373;2432,80;Inherit;False;368;GlobalPosition;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;533;3168,-304;Inherit;False;MMN_CommonOutputs;5;;37;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SimpleAddOpNode;528;2608,864;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;513;2176,608;Inherit;True;Property;_DotTex;DotTex;24;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;151;0;82;4
WireConnection;81;0;48;2
WireConnection;81;1;71;0
WireConnection;72;0;81;0
WireConnection;72;1;73;0
WireConnection;72;2;151;0
WireConnection;79;0;81;0
WireConnection;79;1;78;0
WireConnection;79;2;151;0
WireConnection;77;0;72;0
WireConnection;77;1;79;0
WireConnection;90;0;477;0
WireConnection;90;2;89;0
WireConnection;90;1;127;0
WireConnection;85;1;67;0
WireConnection;91;0;85;2
WireConnection;91;1;5;2
WireConnection;92;0;85;2
WireConnection;92;1;5;4
WireConnection;92;2;48;4
WireConnection;129;0;92;0
WireConnection;129;1;91;0
WireConnection;129;2;130;0
WireConnection;22;0;129;0
WireConnection;22;1;150;0
WireConnection;136;0;22;0
WireConnection;136;1;154;1
WireConnection;136;2;134;0
WireConnection;30;0;26;0
WireConnection;30;1;136;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;34;0;32;0
WireConnection;25;0;29;0
WireConnection;25;1;35;0
WireConnection;25;2;34;0
WireConnection;43;0;150;0
WireConnection;125;0;25;0
WireConnection;125;1;5;0
WireConnection;152;0;43;0
WireConnection;152;1;153;0
WireConnection;128;0;125;0
WireConnection;128;1;25;0
WireConnection;128;2;130;0
WireConnection;40;0;22;0
WireConnection;40;1;152;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;61;0;60;0
WireConnection;61;1;128;0
WireConnection;61;2;66;0
WireConnection;46;0;25;0
WireConnection;44;0;41;0
WireConnection;45;0;46;0
WireConnection;45;1;44;0
WireConnection;45;2;66;4
WireConnection;360;0;358;0
WireConnection;269;0;359;0
WireConnection;269;1;261;0
WireConnection;359;0;360;0
WireConnection;297;0;269;0
WireConnection;297;2;295;4
WireConnection;223;0;297;0
WireConnection;223;1;489;0
WireConnection;207;0;223;0
WireConnection;358;0;283;0
WireConnection;358;1;361;0
WireConnection;283;0;300;0
WireConnection;283;1;363;0
WireConnection;300;0;367;0
WireConnection;300;1;310;0
WireConnection;300;2;302;0
WireConnection;361;0;218;0
WireConnection;363;1;276;0
WireConnection;363;2;302;0
WireConnection;306;0;369;0
WireConnection;305;0;306;0
WireConnection;305;1;306;2
WireConnection;249;0;305;0
WireConnection;249;1;308;0
WireConnection;308;0;307;0
WireConnection;308;1;307;2
WireConnection;307;0;320;0
WireConnection;367;0;228;0
WireConnection;367;1;370;0
WireConnection;365;0;364;0
WireConnection;368;0;365;0
WireConnection;277;0;321;4
WireConnection;243;0;61;0
WireConnection;319;0;321;0
WireConnection;309;0;249;0
WireConnection;469;0;468;0
WireConnection;469;1;470;0
WireConnection;472;0;469;0
WireConnection;472;1;491;0
WireConnection;89;0;86;0
WireConnection;89;1;87;0
WireConnection;189;0;24;3
WireConnection;189;1;188;0
WireConnection;150;0;189;0
WireConnection;476;0;472;0
WireConnection;476;1;475;0
WireConnection;474;0;491;0
WireConnection;475;0;469;0
WireConnection;475;1;474;0
WireConnection;468;0;88;1
WireConnection;176;0;476;0
WireConnection;176;1;88;2
WireConnection;485;0;176;0
WireConnection;485;1;484;0
WireConnection;489;0;45;0
WireConnection;484;0;488;0
WireConnection;484;1;270;2
WireConnection;478;0;485;0
WireConnection;67;0;90;0
WireConnection;67;1;77;0
WireConnection;5;1;6;0
WireConnection;471;0;88;1
WireConnection;491;0;471;0
WireConnection;488;0;270;1
WireConnection;185;0;47;1
WireConnection;185;1;47;2
WireConnection;52;0;50;0
WireConnection;52;1;187;0
WireConnection;49;0;185;0
WireConnection;49;2;52;0
WireConnection;49;1;126;0
WireConnection;48;1;49;0
WireConnection;514;1;516;0
WireConnection;515;0;518;0
WireConnection;516;0;532;0
WireConnection;516;2;515;0
WireConnection;516;1;519;0
WireConnection;530;0;507;1
WireConnection;530;1;529;1
WireConnection;531;0;507;2
WireConnection;531;1;529;2
WireConnection;532;0;530;0
WireConnection;532;1;531;0
WireConnection;520;1;522;0
WireConnection;522;0;532;0
WireConnection;522;2;521;0
WireConnection;522;1;523;0
WireConnection;521;0;524;0
WireConnection;512;0;532;0
WireConnection;512;2;511;0
WireConnection;512;1;510;0
WireConnection;511;0;509;0
WireConnection;121;0;533;2
WireConnection;121;1;533;26
WireConnection;121;3;372;5
WireConnection;385;0;207;0
WireConnection;385;1;372;6
WireConnection;372;1;371;0
WireConnection;372;2;373;0
WireConnection;372;3;381;0
WireConnection;533;9;243;0
WireConnection;533;28;385;0
WireConnection;528;0;513;1
WireConnection;528;1;514;2
WireConnection;528;2;520;3
WireConnection;513;1;512;0
ASEEND*/
//CHKSM=F12C71FEA237ACE58028F7E9B06836D14DBE754E