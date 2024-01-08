// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_CampFire"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(VoronoiTexture)][Space()]_VoronoiTex("VoronoiTex", 2D) = "white" {}
		[Header(Noise)][Space()]_Main("Main", Vector) = (1,1,0,0)
		_Sub("Sub", Vector) = (1,1,0,0)
		[Space(5)]_Noise_Power("Noise_Power", Float) = 1
		_Noise_Offset("Noise_Offset", Float) = 0
		_Noise_Range("Noise_Range", Range( -1 , 1)) = -1
		[Header(Intensity Options)][Space(10)]_Intensity("Intensity Color", Float) = 3
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
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[HDR][Header(Color)][Space()]_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		[HDR]_SubColor("Sub Color", Color) = (1,1,1,1)
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		_IntensityAlpha("Intensity Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 1
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0

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


			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA


			HLSLPROGRAM
			#define ASE_SRP_VERSION 999999

			#pragma exclude_renderers glcore gles gles3

			// GPU Instancing

			// Material Keywords
			// 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
			// #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // Unity defined keywords
			#pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _VoronoiTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Sub;
			float4 _MainColor;
			float4 _SubColor;
			float4 _Main;
			float4 _VoronoiTex_ST;
			float4 _MainTex_ST;
			float _Color_Offset;
			float _Intensity;
			float _Use_G_Channel_Alpha;
			float _Noise_Offset;
			float _Noise_Range;
			float _LightRatio;
			float _Color_Range;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Noise_Power;
			float _IntensityAlpha;
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
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord4 = screenPos;

				output.ase_texcoord3 = input.ase_texcoord1;
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
				float localApplySoftParticle80_g8 = ( 0.0 );
				float localApplyLightColor6_g8 = ( 0.0 );
				float localApplyShadowAtten104_g8 = ( 0.0 );
				half localApplyRaycastingAlpha92_g8 = ( 0.0 );
				float2 appendResult80 = (float2(_Main.z , _Main.w));
				float2 appendResult155 = (float2(input.uv0.z , input.ase_texcoord3.x));
				float2 uv_VoronoiTex = input.uv0.xy * _VoronoiTex_ST.xy + _VoronoiTex_ST.zw;
				float2 break161 = ( frac( ( appendResult155 + input.uv0.w ) ) + uv_VoronoiTex );
				float2 appendResult99 = (float2(( break161.x * _Main.x ) , ( break161.y * _Main.y )));
				float2 panner78 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult80 + appendResult99);
				float2 appendResult111 = (float2(_Sub.z , _Sub.w));
				float2 appendResult112 = (float2(( break161.x * _Sub.x ) , ( break161.y * _Sub.y )));
				float2 panner110 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult111 + appendResult112);
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float lerpResult122 = lerp( ( saturate( ( ( 1.0 - tex2D( _VoronoiTex, panner78 ).r ) + tex2D( _VoronoiTex, panner110 ).g ) ) * _Noise_Power ) , 0.0 , ( ( 1.0 - uv_MainTex.y ) + _Noise_Range ));
				float temp_output_130_0 = saturate( lerpResult122 );
				float2 temp_cast_0 = (_Noise_Offset).xx;
				float4 tex2DNode48 = tex2D( _MainTex, ( temp_output_130_0 + ( uv_MainTex - temp_cast_0 ) ) );
				float lerpResult165 = lerp( tex2DNode48.a , tex2DNode48.g , _Use_G_Channel_Alpha);
				float4 lerpResult135 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + temp_output_130_0 ) * _Color_Range ) ));
				float4 appendResult32_g8 = (float4(( lerpResult165 * input.ase_color * _Intensity * lerpResult135 ).rgb , saturate( ( lerpResult165 * input.ase_color.a * _IntensityAlpha ) )));
				half4 finalColor92_g8 = appendResult32_g8;
				half3 positionWS92_g8 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g8 = ase_screenPosNorm;
				half4 screenPos92_g8 = ase_screenPosNorm;
				half nearPlane92_g8 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g8 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g8 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g8 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g8 , positionWS92_g8 , screenUV92_g8 , screenPos92_g8 , nearPlane92_g8 , nearPlaneInvertDistance92_g8 , raycastHarftoneClip92_g8 , raycastMinimumAlpha92_g8 );
				float4 finalColor104_g8 = finalColor92_g8;
				float4 shadowCoord104_g8 = input.uv0;
				float3 positionWS104_g8 = input.positionWS;
				float lightRatio104_g8 = _LightRatio;
				ApplyShadowAtten( finalColor104_g8 , shadowCoord104_g8 , positionWS104_g8 , lightRatio104_g8 );
				float4 finalColor6_g8 = finalColor104_g8;
				float3 normalWS6_g8 = input.normalWS;
				float lightRatio6_g8 = _LightRatio;
				ApplyLightColor( finalColor6_g8 , normalWS6_g8 , lightRatio6_g8 );
				float4 finalColor80_g8 = finalColor6_g8;
				float near80_g8 = _SoftParticleNearFadeDistance;
				float far80_g8 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g8 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g8 = ( 0.0 );
				float4 positionCS58_g8 = float4( 0,0,0,0 );
				float4 positionNDC58_g8 = float4( 0,0,0,0 );
				float3 positionOS58_g8 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g8 , positionNDC58_g8 , positionOS58_g8 );
				float4 positionNDC80_g8 = positionNDC58_g8;
				ApplySoftParticle( finalColor80_g8 , near80_g8 , far80_g8 , fadeOutRange80_g8 , positionNDC80_g8 );
				float4 break64_g8 = finalColor80_g8;
				float3 appendResult76_g8 = (float3(break64_g8.x , break64_g8.y , break64_g8.z));

				float3 Color = appendResult76_g8;
				float Alpha = break64_g8.w;

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


}
/*ASEBEGIN
Version=18935
3264;207;1610;961;3075.249;2306.116;2.507662;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;158;-4115.245,-1852.111;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;159;-4115.245,-1676.111;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;155;-3898.51,-1801.205;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-3657.865,-1790.398;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3825.538,-1434.057;Inherit;True;0;90;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;157;-3529.865,-1790.398;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-3543.955,-1411.924;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;120;-3502.142,-1090.389;Inherit;False;Property;_Main;Main;3;0;Create;True;0;0;0;False;2;Header(Noise);Space();False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;161;-3446.326,-1198.472;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-3027.077,-1188.47;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-3031.969,-1090.063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;121;-3283.305,-598.959;Inherit;False;Property;_Sub;Sub;4;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;73;-2943.153,-876.0278;Inherit;False;MMN_Time;-1;;4;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;-2870.438,-1105.724;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-3060.36,-741.6729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-3061.883,-638.2118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-2875.726,-1011.137;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;90;-2719.262,-1275.544;Inherit;True;Property;_VoronoiTex;VoronoiTex;2;0;Create;True;0;0;0;False;2;Header(VoronoiTexture);Space();False;e2204a70ff6fa724ba478a1e604b5f27;e2204a70ff6fa724ba478a1e604b5f27;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;78;-2709.054,-1048.13;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;111;-2882.055,-507.0605;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;112;-2886.875,-605.0182;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;164;-2874.296,-390.2869;Inherit;False;MMN_Time;-1;;7;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-2417.154,-1063.188;Inherit;True;Property;_Voronoi;1;1;0;Create;False;0;0;0;True;0;False;48;e2204a70ff6fa724ba478a1e604b5f27;e2204a70ff6fa724ba478a1e604b5f27;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;110;-2694.744,-586.1061;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;91;-2418.524,-645.7611;Inherit;True;Property;_Voronoi1;2;2;0;Create;False;0;0;0;True;0;False;48;e2204a70ff6fa724ba478a1e604b5f27;e2204a70ff6fa724ba478a1e604b5f27;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;85;-2131.864,-993.2504;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;-1983.832,-893.2125;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1944.46,-555.5248;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;129;-1698.939,-464.213;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1930.115,-270.6492;Inherit;False;Property;_Noise_Range;Noise_Range;7;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;152;-1882.832,-991.2125;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1921.878,-645.3945;Inherit;False;Property;_Noise_Power;Noise_Power;5;0;Create;True;0;0;0;False;1;Space(5);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;128;-1582.939,-352.213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1678.689,-792.2622;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;122;-1515.888,-759.8002;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-1508.42,-439.2117;Inherit;False;Property;_Noise_Offset;Noise_Offset;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;83;-1432.231,-563.5586;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;130;-1354.078,-746.4149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1559.877,-1136.735;Inherit;False;Property;_Color_Offset;Color_Offset;22;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;167;-832,-848;Inherit;False;367;253;Switch;2;166;165;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-1367.877,-1136.735;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-1367.877,-1024.735;Inherit;False;Property;_Color_Range;Color_Range;23;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;150;-1252.497,-644.3835;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-1120,-848;Inherit;True;Property;_MainTex;MainTex;0;0;Create;False;0;0;0;True;3;;Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-1207.877,-1136.735;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-816,-672;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;1;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;-1367.426,-1342.309;Inherit;False;Property;_SubColor;Sub Color;25;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;50;-590.6758,-567.7803;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;140;-1063.877,-1136.735;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;165;-608,-800;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-410.9122,-382.2105;Inherit;False;Property;_IntensityAlpha;Intensity Alpha;27;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;132;-1341.426,-1527.309;Inherit;False;Property;_MainColor;Main Color;24;1;[HDR];Create;True;0;0;0;False;2;Header(Color);Space();False;0.5019608,0.5019608,0.5019608,1;0.5019608,0.5019608,0.5019608,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-194.4294,-556.3456;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;-1035.155,-1421.253;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-254.0629,-628.1478;Inherit;False;Property;_Intensity;Intensity Color;8;0;Create;False;0;0;0;True;2;Header(Intensity Options);Space(10);False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-81.99731,-767.8621;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;54;368,-592;Inherit;False;204;375;Rendering Options;4;60;59;57;168;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;96;-16.69759,-553.0524;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;400,-464;Inherit;False;Property;_BlendDst;Blend Dst;29;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;400,-384;Inherit;False;Property;_CullMode;Cull Mode;30;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;400,-544;Inherit;False;Property;_BlendSrc;Blend Src;28;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;58;97,-738;Inherit;False;MMN_CommonOutputs;9;;8;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;168;400,-304;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;368,-736;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;20;MMN/FX/Amplify shader/FX_CampFire;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;59;0;True;60;0;1;False;-1;0;False;-1;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;57;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;False;-1;True;0;True;168;False;True;0;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;155;0;158;3
WireConnection;155;1;159;1
WireConnection;156;0;155;0
WireConnection;156;1;158;4
WireConnection;157;0;156;0
WireConnection;160;0;157;0
WireConnection;160;1;6;0
WireConnection;161;0;160;0
WireConnection;105;0;161;0
WireConnection;105;1;120;1
WireConnection;106;0;161;1
WireConnection;106;1;120;2
WireConnection;99;0;105;0
WireConnection;99;1;106;0
WireConnection;113;0;161;0
WireConnection;113;1;121;1
WireConnection;114;0;161;1
WireConnection;114;1;121;2
WireConnection;80;0;120;3
WireConnection;80;1;120;4
WireConnection;78;0;99;0
WireConnection;78;2;80;0
WireConnection;78;1;73;0
WireConnection;111;0;121;3
WireConnection;111;1;121;4
WireConnection;112;0;113;0
WireConnection;112;1;114;0
WireConnection;26;0;90;0
WireConnection;26;1;78;0
WireConnection;110;0;112;0
WireConnection;110;2;111;0
WireConnection;110;1;164;0
WireConnection;91;0;90;0
WireConnection;91;1;110;0
WireConnection;85;0;26;1
WireConnection;153;0;85;0
WireConnection;153;1;91;2
WireConnection;129;0;46;2
WireConnection;152;0;153;0
WireConnection;128;0;129;0
WireConnection;128;1;124;0
WireConnection;81;0;152;0
WireConnection;81;1;82;0
WireConnection;122;0;81;0
WireConnection;122;2;128;0
WireConnection;83;0;46;0
WireConnection;83;1;84;0
WireConnection;130;0;122;0
WireConnection;137;0;136;0
WireConnection;137;1;130;0
WireConnection;150;0;130;0
WireConnection;150;1;83;0
WireConnection;48;1;150;0
WireConnection;139;0;137;0
WireConnection;139;1;138;0
WireConnection;140;0;139;0
WireConnection;165;0;48;4
WireConnection;165;1;48;2
WireConnection;165;2;166;0
WireConnection;63;0;165;0
WireConnection;63;1;50;4
WireConnection;63;2;62;0
WireConnection;135;0;131;0
WireConnection;135;1;132;0
WireConnection;135;2;140;0
WireConnection;51;0;165;0
WireConnection;51;1;50;0
WireConnection;51;2;49;0
WireConnection;51;3;135;0
WireConnection;96;0;63;0
WireConnection;58;9;51;0
WireConnection;58;28;96;0
WireConnection;1;0;58;2
WireConnection;1;1;58;26
ASEEND*/
//CHKSM=DB30D584E164F1EF829B447D5C6D79F1D81FB9F6