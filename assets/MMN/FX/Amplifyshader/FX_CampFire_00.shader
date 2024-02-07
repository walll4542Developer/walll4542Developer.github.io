// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_CampFire_00"
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
		[Header(tcd0.z     Dissolve)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = -0.5
		[Header(Distortion)][Space()]_Distortion_X_Power("Distortion_X_Power", Float) = 1
		_Distortion_Y_Power("Distortion_Y_Power", Float) = 1
		[Header(AddNoise Texture)][Space()]_AddNoiseTex("AddNoiseTex", 2D) = "white" {}
		_AddNoise_X_Speed("AddNoise_X_Speed", Float) = 1
		_AddNoise_Y_Speed("AddNoise_Y_Speed", Float) = 1
		[Header(Mask)][Space()]_Noise_MaskRange("Noise_MaskRange", Float) = 1
		_AddNoise_MaskRange("AddNoise_MaskRange", Float) = 0
		[HDR][Header(Color)][Space()]_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HDR]_SubColor("Sub Color", Color) = (1,1,1,1)
		_Color_Range("Color_Range", Float) = 0
		_Color_Offset("Color_Offset", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0

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
			sampler2D _NoiseTex;
			sampler2D _AddNoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _AddNoiseTex_ST;
			float4 _SubColor;
			float4 _MainColor;
			float4 _NoiseTex_ST;
			float _AddNoise_Y_Speed;
			float _AddNoise_X_Speed;
			float _Use_G_Channel_Alpha;
			float _Noise_MaskRange;
			float _Distortion_Y_Power;
			float _Distortion_X_Power;
			float _Distortion_Offset;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _LightRatio;
			float _Color_Offset;
			float _Color_Range;
			float _Intensity_Color;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Intensity_Alpha;
			float _AddNoise_MaskRange;
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
				float localApplySoftParticle80_g11 = ( 0.0 );
				float localApplyLightColor6_g11 = ( 0.0 );
				float localApplyShadowAtten104_g11 = ( 0.0 );
				half localApplyRaycastingAlpha92_g11 = ( 0.0 );
				float2 texCoord230 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float V233 = texCoord230.y;
				float saferPower265 = abs( ( V233 + _Color_Range ) );
				float4 lerpResult209 = lerp( _SubColor , _MainColor , saturate( pow( saferPower265 , _Color_Offset ) ));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult174 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 appendResult155 = (float2(input.uv0.z , input.ase_texcoord3.x));
				float2 temp_output_157_0 = frac( ( appendResult155 + input.uv0.w ) );
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner175 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult174 + ( temp_output_157_0 + uv_NoiseTex ));
				float temp_output_178_0 = ( tex2D( _NoiseTex, panner175 ).g + _Distortion_Offset );
				float2 appendResult186 = (float2(( temp_output_178_0 * _Distortion_X_Power * input.uv0.w ) , ( temp_output_178_0 * _Distortion_Y_Power * input.uv0.w )));
				float U232 = texCoord230.x;
				float temp_output_245_0 = ( ( 1.0 - U232 ) * ( 1.0 - V233 ) * U232 * 4.0 );
				float saferPower249 = abs( temp_output_245_0 );
				float Mask01258 = pow( saferPower249 , 2.5 );
				float4 tex2DNode194 = tex2D( _MainTex, ( uv_MainTex + ( appendResult186 * saturate( ( 1.0 - ( Mask01258 + _Noise_MaskRange ) ) ) ) ) );
				float4 lerpResult214 = lerp( ( lerpResult209 * tex2DNode194 ) , lerpResult209 , _Use_G_Channel_Alpha);
				float4 break221 = ( _Intensity_Color * lerpResult214 * input.ase_color );
				float3 appendResult224 = (float3(break221.r , break221.g , break221.b));
				float2 appendResult188 = (float2(_AddNoise_X_Speed , _AddNoise_Y_Speed));
				float2 uv_AddNoiseTex = input.uv0.xy * _AddNoiseTex_ST.xy + _AddNoiseTex_ST.zw;
				float2 panner191 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult188 + ( temp_output_157_0 + uv_AddNoiseTex ));
				float4 tex2DNode193 = tex2D( _AddNoiseTex, panner191 );
				float lerpResult199 = lerp( ( tex2DNode193.g * tex2DNode194.a ) , ( tex2DNode193.g * tex2DNode194.g ) , _Use_G_Channel_Alpha);
				float saferPower277 = abs( ( temp_output_245_0 + _AddNoise_MaskRange ) );
				float Mask02278 = pow( saferPower277 , 2.5 );
				float4 appendResult32_g11 = (float4(appendResult224 , ( (lerpResult209).a * saturate( ( ( ( ( lerpResult199 - input.uv0.z ) / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) + Mask02278 ) ) * input.ase_color.a )));
				half4 finalColor92_g11 = appendResult32_g11;
				half3 positionWS92_g11 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g11 = ase_screenPosNorm;
				half4 screenPos92_g11 = ase_screenPosNorm;
				half nearPlane92_g11 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g11 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g11 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g11 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g11 , positionWS92_g11 , screenUV92_g11 , screenPos92_g11 , nearPlane92_g11 , nearPlaneInvertDistance92_g11 , raycastHarftoneClip92_g11 , raycastMinimumAlpha92_g11 );
				float4 finalColor104_g11 = finalColor92_g11;
				float4 shadowCoord104_g11 = input.uv0;
				float3 positionWS104_g11 = input.positionWS;
				float lightRatio104_g11 = _LightRatio;
				ApplyShadowAtten( finalColor104_g11 , shadowCoord104_g11 , positionWS104_g11 , lightRatio104_g11 );
				float4 finalColor6_g11 = finalColor104_g11;
				float3 normalWS6_g11 = input.normalWS;
				float lightRatio6_g11 = _LightRatio;
				ApplyLightColor( finalColor6_g11 , normalWS6_g11 , lightRatio6_g11 );
				float4 finalColor80_g11 = finalColor6_g11;
				float near80_g11 = _SoftParticleNearFadeDistance;
				float far80_g11 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g11 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g11 = ( 0.0 );
				float4 positionCS58_g11 = float4( 0,0,0,0 );
				float4 positionNDC58_g11 = float4( 0,0,0,0 );
				float3 positionOS58_g11 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g11 , positionNDC58_g11 , positionOS58_g11 );
				float4 positionNDC80_g11 = positionNDC58_g11;
				ApplySoftParticle( finalColor80_g11 , near80_g11 , far80_g11 , fadeOutRange80_g11 , positionNDC80_g11 );
				float4 break64_g11 = finalColor80_g11;
				float3 appendResult76_g11 = (float3(break64_g11.x , break64_g11.y , break64_g11.z));

				float3 Color = appendResult76_g11;
				float Alpha = break64_g11.w;

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

	Fallback "off"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.TextureCoordinatesNode;230;-2288.709,-1008.465;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;159;-3894.601,-806.8976;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;158;-3893.601,-982.8977;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-2041.709,-986.4646;Inherit;False;U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-2034.709,-899.4646;Inherit;False;V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-2229.43,-1540.891;Inherit;True;232;U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;-2227.491,-1329.853;Inherit;True;233;V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-3677.865,-931.9917;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;-3437.22,-921.1847;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;250;-2005.43,-1236.891;Inherit;False;Constant;_MakPower;MakPower;23;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;246;-2021.43,-1540.891;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;247;-2024.691,-1316.152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-3482.189,200.3002;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;16;0;Create;True;0;0;0;False;0;False;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3604.893,-564.8434;Inherit;True;0;176;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;245;-1820.891,-1500.753;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;157;-3317.021,-914.6844;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-3482.189,280.3002;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;17;0;Create;True;0;0;0;False;0;False;1;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;174;-3306.189,200.3002;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;172;-3284.323,372.7778;Inherit;False;MMN_Time;-1;;9;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-3323.31,-542.7103;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;175;-3126.189,178.3002;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-1374.43,-1570.891;Inherit;False;Mask01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;237;-2653.02,649.6539;Inherit;False;Property;_Noise_MaskRange;Noise_MaskRange;24;0;Create;True;0;0;0;False;2;Header(Mask);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;176;-2922.189,72.30024;Inherit;True;Property;_NoiseTex;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;93092410bbc6f4ccba773578db5832d9;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;177;-2826.189,280.3002;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;18;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2624,568;Inherit;False;258;Mask01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-2464,576;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;181;-2589.96,361.188;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;178;-2583.302,118.2918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-2655.189,-26.69976;Inherit;False;Property;_Distortion_X_Power;Distortion_X_Power;19;0;Create;True;0;0;0;False;2;Header(Distortion);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-2602.189,248.3002;Inherit;False;Property;_Distortion_Y_Power;Distortion_Y_Power;20;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-2306.189,206.3002;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;251;-2256,576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-2335.189,7.300243;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-2583.573,-446.7737;Inherit;False;Property;_AddNoise_X_Speed;AddNoise_X_Speed;22;0;Create;True;0;0;0;False;0;False;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-2583.573,-366.7736;Inherit;False;Property;_AddNoise_Y_Speed;AddNoise_Y_Speed;23;0;Create;True;0;0;0;False;0;False;1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;186;-2157.189,18.30024;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;238;-2112,576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;189;-3057.357,-828.3453;Inherit;False;0;193;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;187;-2356.323,-302.2221;Inherit;False;MMN_Time;-1;;10;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;-1928.461,91.0415;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;188;-2362.073,-446.7737;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;267;-2957.059,-918.6918;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;190;-2369.39,-196.3998;Inherit;False;0;194;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;234;-1715.609,-761.1646;Inherit;True;233;V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;191;-2222.573,-595.7736;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-2106.189,-183.6998;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-1690.817,-551.0917;Inherit;False;Property;_Color_Range;Color_Range;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;262;-1488.817,-687.0917;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-1438.817,-448.0917;Inherit;False;Property;_Color_Offset;Color_Offset;30;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;195;-1508.189,-101.2271;Inherit;False;281.5415;271.9273;Switch;2;199;197;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;193;-2011.471,-484.8971;Inherit;True;Property;_AddNoiseTex;AddNoiseTex;21;0;Create;True;0;0;0;False;2;Header(AddNoise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;194;-1962.189,-183.6998;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;93092410bbc6f4ccba773578db5832d9;a6aeb5355da7b0d43b94c52a81a5f6a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;-1626.672,-314.2738;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-1755.879,-1271.623;Inherit;False;Property;_AddNoise_MaskRange;AddNoise_MaskRange;25;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;197;-1508.991,84.67044;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-1629.272,-207.6738;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;208;-1223.64,-910.71;Inherit;False;Property;_MainColor;Main Color;26;1;[HDR];Create;True;0;0;0;False;2;Header(Color);Space();False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;207;-1223.64,-1118.711;Inherit;False;Property;_SubColor;Sub Color;28;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0.2479339,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;263;-1124.817,-683.0917;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;199;-1371.721,-61.50475;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;276;-1582.316,-1380.385;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;200;-1534.458,354.451;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;212;-1277.685,421.3812;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;201;-1282.289,310.1513;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;209;-959.941,-770.0142;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;-1212.076,-1325.443;Inherit;False;Mask02;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;215;-1039.189,130.3002;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-1019.189,271.3002;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;34;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;211;-567.0892,-527.9112;Inherit;False;179.2;183.4;Switch;1;214;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;210;-742.5618,-449.1207;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;213;-506.1893,-263.6997;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;214;-544.2894,-477.9112;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-818.6781,140.4158;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;259;-1055.099,538.6017;Inherit;True;278;Mask02;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-474.1893,-647.6997;Inherit;False;Property;_Intensity_Color;Intensity_Color;31;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;253;-757.3856,395.6259;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-266.1893,-471.6997;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;221;-115.3048,-471.5367;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;222;-550.3988,155.5619;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;220;-666.1892,40.30024;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-266.1893,-71.69976;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;224;16.05232,-471.5367;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;54;664.5912,-488.0402;Inherit;False;204;375;Rendering Options;4;60;59;57;279;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;228;4.875684,-749.9799;Inherit;False;MMN_CommonOutputs;0;;11;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;59;696.5912,-440.0401;Inherit;False;Property;_BlendSrc;Blend Src;32;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;173;-3392.651,56.93452;Inherit;False;0;176;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;-2045.709,-1077.465;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;-1548.093,549.8458;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;696.5912,-280.0401;Inherit;False;Property;_CullMode;Cull Mode;35;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;696.5912,-360.0401;Inherit;False;Property;_BlendDst;Blend Dst;33;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;688,-192;Inherit;False;Property;_ZTest;Z Test;27;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;368,-736;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_CampFire_00;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.PowerNode;265;-1271.817,-685.0917;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;249;-1602.43,-1681.891;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;277;-1455.076,-1360.443;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;2.5;False;1;FLOAT;0
WireConnection;232;0;230;1
WireConnection;233;0;230;2
WireConnection;155;0;158;3
WireConnection;155;1;159;1
WireConnection;156;0;155;0
WireConnection;156;1;158;4
WireConnection;246;0;243;0
WireConnection;247;0;244;0
WireConnection;245;0;246;0
WireConnection;245;1;247;0
WireConnection;245;2;243;0
WireConnection;245;3;250;0
WireConnection;157;0;156;0
WireConnection;174;0;171;0
WireConnection;174;1;170;0
WireConnection;160;0;157;0
WireConnection;160;1;6;0
WireConnection;175;0;160;0
WireConnection;175;2;174;0
WireConnection;175;1;172;0
WireConnection;258;0;249;0
WireConnection;176;1;175;0
WireConnection;236;0;260;0
WireConnection;236;1;237;0
WireConnection;178;0;176;2
WireConnection;178;1;177;0
WireConnection;185;0;178;0
WireConnection;185;1;180;0
WireConnection;185;2;181;4
WireConnection;251;0;236;0
WireConnection;182;0;178;0
WireConnection;182;1;179;0
WireConnection;182;2;181;4
WireConnection;186;0;182;0
WireConnection;186;1;185;0
WireConnection;238;0;251;0
WireConnection;252;0;186;0
WireConnection;252;1;238;0
WireConnection;188;0;184;0
WireConnection;188;1;183;0
WireConnection;267;0;157;0
WireConnection;267;1;189;0
WireConnection;191;0;267;0
WireConnection;191;2;188;0
WireConnection;191;1;187;0
WireConnection;192;0;190;0
WireConnection;192;1;252;0
WireConnection;262;0;234;0
WireConnection;262;1;261;0
WireConnection;193;1;191;0
WireConnection;194;1;192;0
WireConnection;198;0;193;2
WireConnection;198;1;194;2
WireConnection;196;0;193;2
WireConnection;196;1;194;4
WireConnection;263;0;265;0
WireConnection;199;0;196;0
WireConnection;199;1;198;0
WireConnection;199;2;197;0
WireConnection;276;0;245;0
WireConnection;276;1;257;0
WireConnection;212;0;200;3
WireConnection;201;0;199;0
WireConnection;201;1;200;3
WireConnection;209;0;207;0
WireConnection;209;1;208;0
WireConnection;209;2;263;0
WireConnection;278;0;277;0
WireConnection;215;0;201;0
WireConnection;215;1;212;0
WireConnection;210;0;209;0
WireConnection;210;1;194;0
WireConnection;214;0;210;0
WireConnection;214;1;209;0
WireConnection;214;2;197;0
WireConnection;219;0;215;0
WireConnection;219;1;217;0
WireConnection;253;0;219;0
WireConnection;253;1;259;0
WireConnection;218;0;216;0
WireConnection;218;1;214;0
WireConnection;218;2;213;0
WireConnection;221;0;218;0
WireConnection;222;0;253;0
WireConnection;220;0;209;0
WireConnection;223;0;220;0
WireConnection;223;1;222;0
WireConnection;223;2;213;4
WireConnection;224;0;221;0
WireConnection;224;1;221;1
WireConnection;224;2;221;2
WireConnection;228;9;224;0
WireConnection;228;28;223;0
WireConnection;231;0;230;0
WireConnection;1;0;228;2
WireConnection;1;1;228;26
WireConnection;265;0;262;0
WireConnection;265;1;264;0
WireConnection;249;0;245;0
WireConnection;277;0;276;0
ASEEND*/
//CHKSM=48E3BCE89DAFECC81D8620AECFBAD3D9EBEFD4B4