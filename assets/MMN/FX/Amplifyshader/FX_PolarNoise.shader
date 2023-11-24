// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_PolarNoise"
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
		[Toggle(_GORB_ON)] _GorB("GorB", Float) = 0
		[Header(Color)][Space()]_MainColor("Main Color", Color) = (1,1,1,0)
		[Gamma]_SubColor("Sub Color", Color) = (1,1,1,0)
		_Color_Range("Color_Range", Float) = 6.5
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "bump" {}
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		_Noise_Y_Tile("Noise_Y_Tile", Float) = 1
		_Noise_X_Tile("Noise_X_Tile", Float) = 1
		_Sphere_Mask_Hardness("Sphere_Mask_Hardness", Float) = 0
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Sphere_Mask_Radius("Sphere_Mask_Radius", Float) = 0
		_Noise_Range("Noise_Range", Float) = 2.05
		_Noise_Power("Noise_Power", Float) = 0.18
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

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

			#pragma exclude_renderers glcore gles gles3 

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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma shader_feature_local _GORB_ON
			#pragma multi_compile_instancing


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			UNITY_INSTANCING_BUFFER_START(MMNFXAmplifyshaderFX_PolarNoise)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float4, _NoiseTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _Noise_X_Tile)
				UNITY_DEFINE_INSTANCED_PROP(float, _Noise_Y_Tile)
				UNITY_DEFINE_INSTANCED_PROP(float, _Noise_X_Speed)
				UNITY_DEFINE_INSTANCED_PROP(float, _Noise_Y_Speed)
				UNITY_DEFINE_INSTANCED_PROP(float, _Noise_Power)
			UNITY_INSTANCING_BUFFER_END(MMNFXAmplifyshaderFX_PolarNoise)
			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float4 _SubColor;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Intensity_Color;
			float _Noise_Range;
			float _Color_Range;
			float _Intensity_Alpha;
			float _Sphere_Mask_Radius;
			float _Sphere_Mask_Hardness;
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

				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
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
				float localApplySoftParticle80_g14 = ( 0.0 );
				float localApplyLightColor6_g14 = ( 0.0 );
				float localApplyShadowAtten104_g14 = ( 0.0 );
				half localApplyRaycastingAlpha92_g14 = ( 0.0 );
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_MainTex_ST);
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float4 _NoiseTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_NoiseTex_ST);
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST_Instance.xy + _NoiseTex_ST_Instance.zw;
				float2 CenteredUV15_g10 = ( uv_NoiseTex - float2( 0.5,0.5 ) );
				float _Noise_X_Tile_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_Noise_X_Tile);
				float2 break17_g10 = CenteredUV15_g10;
				float _Noise_Y_Tile_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_Noise_Y_Tile);
				float2 appendResult23_g10 = (float2(( length( CenteredUV15_g10 ) * _Noise_X_Tile_Instance * 2.0 ) , ( atan2( break17_g10.x , break17_g10.y ) * ( 1.0 / TWO_PI ) * _Noise_Y_Tile_Instance )));
				float2 temp_output_161_0 = appendResult23_g10;
				float temp_output_162_0 = (temp_output_161_0).x;
				float _Noise_X_Speed_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_Noise_X_Speed);
				float _Noise_Y_Speed_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_Noise_Y_Speed);
				float2 appendResult53 = (float2(( temp_output_162_0 + ( _Noise_X_Speed_Instance * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) ) ) , ( (temp_output_161_0).y + ( _Noise_Y_Speed_Instance * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) ) )));
				float _Noise_Power_Instance = UNITY_ACCESS_INSTANCED_PROP(MMNFXAmplifyshaderFX_PolarNoise,_Noise_Power);
				float3 lerpResult89 = lerp( float3( uv_MainTex ,  0.0 ) , ( float3( uv_MainTex ,  0.0 ) + ( UnpackNormalScale( tex2D( _NoiseTex, appendResult53 ), 1.0f ) * _Noise_Power_Instance ) ) , pow( temp_output_162_0 , _Noise_Range ));
				float4 tex2DNode63 = tex2D( _MainTex, lerpResult89.xy );
				#ifdef _GORB_ON
				float staticSwitch107 = tex2DNode63.b;
				#else
				float staticSwitch107 = tex2DNode63.g;
				#endif
				float3 appendResult146 = (float3(_MainColor.r , _MainColor.g , _MainColor.b));
				float3 appendResult147 = (float3(_SubColor.r , _SubColor.g , _SubColor.b));
				float3 lerpResult135 = lerp( appendResult146 , appendResult147 , float3( saturate( ( _Color_Range * temp_output_161_0 ) ) ,  0.0 ));
				float3 temp_output_5_0_g13 = ( ( input.positionWS - float3( 0,0,0 ) ) / _Sphere_Mask_Radius );
				float dotResult8_g13 = dot( temp_output_5_0_g13 , temp_output_5_0_g13 );
				float4 appendResult32_g14 = (float4(( _Intensity_Color * input.ase_color * staticSwitch107 * float4( lerpResult135 , 0.0 ) ).rgb , ( saturate( ( ( input.ase_color.a * staticSwitch107 ) * _Intensity_Alpha ) ) * pow( saturate( dotResult8_g13 ) , _Sphere_Mask_Hardness ) )));
				half4 finalColor92_g14 = appendResult32_g14;
				half3 positionWS92_g14 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g14 = ase_screenPosNorm;
				half4 screenPos92_g14 = ase_screenPosNorm;
				half nearPlane92_g14 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g14 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g14 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g14 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g14 , positionWS92_g14 , screenUV92_g14 , screenPos92_g14 , nearPlane92_g14 , nearPlaneInvertDistance92_g14 , raycastHarftoneClip92_g14 , raycastMinimumAlpha92_g14 );
				float4 finalColor104_g14 = finalColor92_g14;
				float4 shadowCoord104_g14 = input.uv0;
				float3 positionWS104_g14 = input.positionWS;
				float lightRatio104_g14 = _LightRatio;
				ApplyShadowAtten( finalColor104_g14 , shadowCoord104_g14 , positionWS104_g14 , lightRatio104_g14 );
				float4 finalColor6_g14 = finalColor104_g14;
				float3 normalWS6_g14 = input.normalWS;
				float lightRatio6_g14 = _LightRatio;
				ApplyLightColor( finalColor6_g14 , normalWS6_g14 , lightRatio6_g14 );
				float4 finalColor80_g14 = finalColor6_g14;
				float near80_g14 = _SoftParticleNearFadeDistance;
				float far80_g14 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g14 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g14 = ( 0.0 );
				float4 positionCS58_g14 = float4( 0,0,0,0 );
				float4 positionNDC58_g14 = float4( 0,0,0,0 );
				float3 positionOS58_g14 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g14 , positionNDC58_g14 , positionOS58_g14 );
				float4 positionNDC80_g14 = positionNDC58_g14;
				ApplySoftParticle( finalColor80_g14 , near80_g14 , far80_g14 , fadeOutRange80_g14 , positionNDC80_g14 );
				float4 break64_g14 = finalColor80_g14;
				float3 appendResult76_g14 = (float3(break64_g14.x , break64_g14.y , break64_g14.z));
				
				float3 Color = appendResult76_g14;
				float Alpha = break64_g14.w;

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
	FallBack off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.RangedFloatNode;164;-4084.501,33.92254;Inherit;False;InstancedProperty;_Noise_X_Tile;Noise_X_Tile;21;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-4079.532,-273.6289;Inherit;False;0;58;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;165;-4065.501,196.9225;Inherit;False;InstancedProperty;_Noise_Y_Tile;Noise_Y_Tile;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3471.553,372.0884;Inherit;False;InstancedProperty;_Noise_Y_Speed;Noise_Y_Speed;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-3488.553,-111.9116;Inherit;False;InstancedProperty;_Noise_X_Speed;Noise_X_Speed;23;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;161;-3840.141,-271.063;Inherit;True;Polar Coordinates;-1;;10;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;158;-3475.971,458.299;Inherit;False;MMN_Time;-1;;11;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;156;-3477.971,-7.701004;Inherit;False;MMN_Time;-1;;12;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-3294.971,419.299;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-3271.971,-117.701;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;163;-3578.266,118.9215;Inherit;False;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;162;-3457.266,-248.0785;Inherit;False;True;False;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-3079.823,264.5154;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-3028.8,-118.7704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-2797.644,-81.61333;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;58;-2457.009,-68.81328;Inherit;True;Property;_NoiseTex;NoiseTex;18;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;da9939f62f7f83d42acfb5f542dafcc9;da9939f62f7f83d42acfb5f542dafcc9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;-2267.002,164.3414;Inherit;False;InstancedProperty;_Noise_Power;Noise_Power;26;0;Create;True;0;0;0;False;0;False;0.18;-0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-2048.48,-313.595;Inherit;False;0;63;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;94;-2446.301,587.2709;Inherit;False;Property;_Noise_Range;Noise_Range;25;0;Create;True;0;0;0;False;0;False;2.05;9.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-2113.001,-63.6586;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;93;-2044.173,428.3943;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-1895.48,-63.59497;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;89;-1645.863,-24.68115;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;63;-1451.075,-51.34006;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;a62644a78351afd438ea151d7c74d993;a62644a78351afd438ea151d7c74d993;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;65;-1117.075,-237.34;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;137;-2086.458,-647.5499;Inherit;False;Property;_Color_Range;Color_Range;17;0;Create;True;0;0;0;False;0;False;6.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;107;-1125.661,17.09521;Inherit;False;Property;_GorB;GorB;14;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;145;-1584.757,-942.5029;Inherit;False;Property;_SubColor;Sub Color;16;1;[Gamma];Create;True;0;0;0;False;0;False;1,1,1,0;0.3396226,0.3396226,0.3396226,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;144;-1574.757,-1194.503;Inherit;False;Property;_MainColor;Main Color;15;0;Create;True;0;0;0;False;2;Header(Color);Space();False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1746.973,-657.917;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-733.0747,-50.3399;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;149;-795.996,139.9436;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;-1524.275,-657.7213;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;146;-1224.348,-1157.611;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-578.4505,-32.12601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;147;-1278.348,-934.611;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-917.0746,-328.34;Inherit;False;Property;_Intensity_Color;Intensity_Color;27;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;150;-481.3541,93.23895;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;-1023.536,-862.4822;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;129;336,16;Inherit;False;204;375;Rendering Options;4;133;132;131;160;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-556.0749,-378.34;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-117.1399,86.12378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;84;80.8426,-126.3987;Inherit;False;MMN_CommonOutputs;0;;14;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;132;368,144;Inherit;False;Property;_BlendDst;Blend Dst;31;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;78;-2421.571,259.4228;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;160;368,304;Inherit;False;Property;_ZTest;Z Test;30;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;73;-2344.483,-433.6718;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;131;368,64;Inherit;False;Property;_BlendSrc;Blend Src;28;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;368,224;Inherit;False;Property;_CullMode;Cull Mode;32;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;134;334.9009,-126.1012;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;24;MMN/FX/Amplify shader/FX_PolarNoise;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;5;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;True;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;0;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-983.6337,472.224;Inherit;False;Property;_Sphere_Mask_Radius;Sphere_Mask_Radius;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-988.5753,569.8185;Inherit;False;Property;_Sphere_Mask_Hardness;Sphere_Mask_Hardness;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;166;-672.5744,419.7086;Inherit;True;SphereMask;-1;;13;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT3;0,0,0;False;14;FLOAT;0;False;12;FLOAT;0;False;1;FLOAT;0
WireConnection;161;1;10;0
WireConnection;161;3;164;0
WireConnection;161;4;165;0
WireConnection;159;0;22;0
WireConnection;159;1;158;0
WireConnection;157;0;19;0
WireConnection;157;1;156;0
WireConnection;163;0;161;0
WireConnection;162;0;161;0
WireConnection;41;0;163;0
WireConnection;41;1;159;0
WireConnection;40;0;162;0
WireConnection;40;1;157;0
WireConnection;53;0;40;0
WireConnection;53;1;41;0
WireConnection;58;1;53;0
WireConnection;61;0;58;0
WireConnection;61;1;57;0
WireConnection;93;0;162;0
WireConnection;93;1;94;0
WireConnection;88;0;87;0
WireConnection;88;1;61;0
WireConnection;89;0;87;0
WireConnection;89;1;88;0
WireConnection;89;2;93;0
WireConnection;63;1;89;0
WireConnection;107;1;63;2
WireConnection;107;0;63;3
WireConnection;136;0;137;0
WireConnection;136;1;161;0
WireConnection;68;0;65;4
WireConnection;68;1;107;0
WireConnection;141;0;136;0
WireConnection;146;0;144;1
WireConnection;146;1;144;2
WireConnection;146;2;144;3
WireConnection;148;0;68;0
WireConnection;148;1;149;0
WireConnection;147;0;145;1
WireConnection;147;1;145;2
WireConnection;147;2;145;3
WireConnection;150;0;148;0
WireConnection;135;0;146;0
WireConnection;135;1;147;0
WireConnection;135;2;141;0
WireConnection;67;0;70;0
WireConnection;67;1;65;0
WireConnection;67;2;107;0
WireConnection;67;3;135;0
WireConnection;170;0;150;0
WireConnection;170;1;166;0
WireConnection;84;9;67;0
WireConnection;84;28;170;0
WireConnection;134;0;84;2
WireConnection;134;1;84;26
WireConnection;166;14;168;0
WireConnection;166;12;169;0
ASEEND*/
//CHKSM=EC5CDC934444A3086CF7CDE571ACDCB737DAE9C7