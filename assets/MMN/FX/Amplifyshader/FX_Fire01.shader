// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Fire 01"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(tcd0.zwlx    p_Center)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Voronoi("Voronoi", 2D) = "white" {}
		[HideInInspector]_SmoothNoise("SmoothNoise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (1,1,1,0)
		_NoisePower("NoisePower", Range( 1 , 50)) = 1
		_NoiseRange("NoiseRange", Range( -1 , 1)) = 0
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
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		_IntensityAlpha("Intensity Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 1
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

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
			#define ASE_SRP_VERSION 120110

			#pragma exclude_renderers glcore gles gles3 switch

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


			sampler2D _SmoothNoise;
			sampler2D _MainTex;
			sampler2D _Voronoi;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseScale;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _NoiseSpeed;
			float _NoiseRange;
			float _NoisePower;
			float _Use_G_Channel_Alpha;
			float _Intensity;
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
				float localApplySoftParticle80_g6 = ( 0.0 );
				float localApplyLightColor6_g6 = ( 0.0 );
				float localApplyShadowAtten104_g6 = ( 0.0 );
				half localApplyRaycastingAlpha92_g6 = ( 0.0 );
				float temp_output_4_0 = ( _NoiseSpeed * 0.5 * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) );
				float2 appendResult71 = (float2(input.uv0.z , input.ase_texcoord3.x));
				float2 texCoord6 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_11_0 = ( frac( ( appendResult71 + input.uv0.w ) ) + texCoord6 );
				float4 _NoiseScale1 = float4(4,3,3,0);
				float2 texCoord35 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord46 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode48 = tex2D( _MainTex, ( saturate( ( saturate( ( pow( ( 1.0 - tex2D( _Voronoi, ( ( ( ( temp_output_4_0 * float2( 0,-0.7 ) ) + temp_output_11_0 ) / _NoiseScale1.x ) * _NoiseScale.x ) ).g ) , 5.0 ) * 0.6 ) ) * saturate( ( pow( ( 1.0 - tex2D( _Voronoi, ( ( ( ( temp_output_4_0 * float2( 0,-0.5 ) ) + temp_output_11_0 ) / _NoiseScale1.y ) * _NoiseScale.y ) ).g ) , 5.0 ) * 0.6 ) ) * ( saturate( ( 1.0 - tex2D( _Voronoi, ( ( ( ( temp_output_4_0 * float2( 0,-1 ) ) + temp_output_11_0 ) / _NoiseScale1.z ) * _NoiseScale.z ) ).r ) ) * 2.0 ) * ( texCoord35.y - _NoiseRange ) * _NoisePower ) ) + texCoord46 ) );
				float4 lerpResult78 = lerp( ( tex2DNode48 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float3 appendResult52 = (float3(( lerpResult78 * _Intensity ).rgb));
				float lerpResult77 = lerp( tex2DNode48.a , tex2DNode48.g , _Use_G_Channel_Alpha);
				float4 appendResult32_g6 = (float4(appendResult52 , ( lerpResult77 * input.ase_color.a * _IntensityAlpha )));
				half4 finalColor92_g6 = appendResult32_g6;
				half3 positionWS92_g6 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g6 = ase_screenPosNorm;
				half4 screenPos92_g6 = ase_screenPosNorm;
				half nearPlane92_g6 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g6 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g6 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g6 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g6 , positionWS92_g6 , screenUV92_g6 , screenPos92_g6 , nearPlane92_g6 , nearPlaneInvertDistance92_g6 , raycastHarftoneClip92_g6 , raycastMinimumAlpha92_g6 );
				float4 finalColor104_g6 = finalColor92_g6;
				float4 shadowCoord104_g6 = input.uv0;
				float3 positionWS104_g6 = input.positionWS;
				float lightRatio104_g6 = _LightRatio;
				ApplyShadowAtten( finalColor104_g6 , shadowCoord104_g6 , positionWS104_g6 , lightRatio104_g6 );
				float4 finalColor6_g6 = finalColor104_g6;
				float3 normalWS6_g6 = input.normalWS;
				float lightRatio6_g6 = _LightRatio;
				ApplyLightColor( finalColor6_g6 , normalWS6_g6 , lightRatio6_g6 );
				float4 finalColor80_g6 = finalColor6_g6;
				float near80_g6 = _SoftParticleNearFadeDistance;
				float far80_g6 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g6 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g6 = ( 0.0 );
				float4 positionCS58_g6 = float4( 0,0,0,0 );
				float4 positionNDC58_g6 = float4( 0,0,0,0 );
				float3 positionOS58_g6 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g6 , positionNDC58_g6 , positionOS58_g6 );
				float4 positionNDC80_g6 = positionNDC58_g6;
				ApplySoftParticle( finalColor80_g6 , near80_g6 , far80_g6 , fadeOutRange80_g6 , positionNDC80_g6 );
				float4 break64_g6 = finalColor80_g6;
				float3 appendResult76_g6 = (float3(break64_g6.x , break64_g6.y , break64_g6.z));

				float3 Color = appendResult76_g6;
				float Alpha = break64_g6.w;

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

	Fallback Off
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.TexCoordVertexDataNode;68;-3760.633,-1541.367;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;69;-3760.633,-1365.367;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;71;-3543.898,-1490.461;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-3616,-960;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;False;0;0;0;True;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;73;-3616,-880;Inherit;False;MMN_Time;-1;;4;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-3360,-1488;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-3440,-960;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3751.692,-1128.526;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;75;-3232,-1488;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;7;-3357.448,-627.4681;Inherit;False;Constant;_Direction1;Direction1;14;0;Create;True;0;0;0;False;0;False;0,-0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;8;-3357.448,-755.4681;Inherit;False;Constant;_Direction0;Direction0;14;0;Create;True;0;0;0;False;0;False;0,-0.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-3037.448,-659.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-3143.448,-1061.468;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;12;-3357.448,-499.4681;Inherit;False;Constant;_Direction2;Direction2;14;0;Create;True;0;0;0;False;0;False;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-3037.448,-755.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;17;-3533.448,-579.4681;Inherit;False;Constant;_NoiseScale1;DivideNoiseScale;13;0;Create;False;0;0;0;True;0;False;4,3,3,0;4,3,3,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-2909.448,-755.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-2909.448,-659.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-3037.448,-563.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;20;-3533.448,-755.4681;Inherit;False;Property;_NoiseScale;NoiseScale;4;0;Create;False;0;0;0;True;0;False;1,1,1,0;4,3,3,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-2909.448,-563.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;21;-2781.448,-659.4681;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-2781.448,-755.4681;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-2653.448,-659.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-2781.448,-563.4681;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2653.448,-755.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2653.448,-563.4681;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;26;-2493.448,-883.4681;Inherit;True;Property;_Voronoi;Voronoi;1;0;Create;False;0;0;0;True;0;False;26;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-2493.448,-691.4681;Inherit;True;Property;Voronoi1;Voronoi;1;1;[HideInInspector];Create;False;0;0;0;True;0;False;26;None;None;True;0;False;white;Auto;False;Instance;26;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;28;-2189.448,-659.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;76;-2496,-496;Inherit;True;Property;Voronoi2;Voronoi;1;1;[HideInInspector];Create;False;0;0;0;True;0;False;26;None;None;True;0;False;white;Auto;False;Instance;26;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;30;-2189.448,-851.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;31;-2045.448,-659.4681;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;33;-2045.448,-851.4681;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-2189.448,-467.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2192,-256;Inherit;False;Property;_NoiseRange;NoiseRange;6;0;Create;False;0;0;0;True;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1901.448,-851.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1901.448,-659.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-2045.448,-467.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2141.448,-387.4681;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-1917.448,-371.4681;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-1773.448,-659.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1917.448,-467.4681;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-1773.448,-851.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2192,-176;Inherit;False;Property;_NoisePower;NoisePower;5;0;Create;False;0;0;0;True;0;False;1;0;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1517.448,-755.4681;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-1517.448,-579.4681;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;45;-1389.448,-739.4681;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-1261.448,-739.4681;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;80;-600.7668,-819;Inherit;False;244;402.9376;Switch;3;79;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;50;-925.4481,-547.4681;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;48;-1053.448,-739.4681;Inherit;True;Property;_MainTex;MainTex;0;0;Create;False;0;0;0;True;3;Header(tcd0.zwlx    p_Center);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;79;-576,-497;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;21;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-720,-832;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;78;-544,-769;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-909.4481,-371.4681;Inherit;False;Property;_Intensity;Intensity Color;7;0;Create;False;0;0;0;True;2;Header(Intensity Options);Space(10);False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-288,-736;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-448,-352;Inherit;False;Property;_IntensityAlpha;Intensity Alpha;22;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;77;-544,-641;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;288,-592;Inherit;False;204;375;Rendering Options;4;60;59;57;81;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-256,-464;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-160,-736;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;57;320,-384;Inherit;False;Property;_CullMode;Cull Mode;25;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-2496,-1072;Inherit;True;Property;_SmoothNoise;SmoothNoise;2;1;[HideInInspector];Create;False;0;0;0;True;0;False;29;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;81;319,-305;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;320,-464;Inherit;False;Property;_BlendDst;Blend Dst;24;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;320,-544;Inherit;False;Property;_BlendSrc;Blend Src;23;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;58;32,-736;Inherit;False;MMN_CommonOutputs;8;;6;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;288,-736;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Fire 01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;0;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;71;0;68;3
WireConnection;71;1;69;1
WireConnection;74;0;71;0
WireConnection;74;1;68;4
WireConnection;4;0;2;0
WireConnection;4;2;73;0
WireConnection;75;0;74;0
WireConnection;10;0;4;0
WireConnection;10;1;7;0
WireConnection;11;0;75;0
WireConnection;11;1;6;0
WireConnection;13;0;4;0
WireConnection;13;1;8;0
WireConnection;16;0;13;0
WireConnection;16;1;11;0
WireConnection;15;0;10;0
WireConnection;15;1;11;0
WireConnection;14;0;4;0
WireConnection;14;1;12;0
WireConnection;19;0;14;0
WireConnection;19;1;11;0
WireConnection;21;0;15;0
WireConnection;21;1;17;2
WireConnection;18;0;16;0
WireConnection;18;1;17;1
WireConnection;24;0;21;0
WireConnection;24;1;20;2
WireConnection;22;0;19;0
WireConnection;22;1;17;3
WireConnection;23;0;18;0
WireConnection;23;1;20;1
WireConnection;25;0;22;0
WireConnection;25;1;20;3
WireConnection;26;1;23;0
WireConnection;27;1;24;0
WireConnection;28;0;27;2
WireConnection;76;1;25;0
WireConnection;30;0;26;2
WireConnection;31;0;28;0
WireConnection;33;0;30;0
WireConnection;32;0;76;1
WireConnection;34;0;33;0
WireConnection;38;0;31;0
WireConnection;36;0;32;0
WireConnection;42;0;35;2
WireConnection;42;1;37;0
WireConnection;43;0;38;0
WireConnection;40;0;36;0
WireConnection;41;0;34;0
WireConnection;44;0;41;0
WireConnection;44;1;43;0
WireConnection;44;2;40;0
WireConnection;44;3;42;0
WireConnection;44;4;39;0
WireConnection;45;0;44;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;48;1;47;0
WireConnection;64;0;48;0
WireConnection;64;1;50;0
WireConnection;78;0;64;0
WireConnection;78;1;50;0
WireConnection;78;2;79;0
WireConnection;51;0;78;0
WireConnection;51;1;49;0
WireConnection;77;0;48;4
WireConnection;77;1;48;2
WireConnection;77;2;79;0
WireConnection;63;0;77;0
WireConnection;63;1;50;4
WireConnection;63;2;62;0
WireConnection;52;0;51;0
WireConnection;58;9;52;0
WireConnection;58;28;63;0
WireConnection;1;0;58;2
WireConnection;1;1;58;26
ASEEND*/
//CHKSM=BA1CED73DF574DFCC592020C13930C0CF6F349A0