// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_AlphaTest_Explosion_01"
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
		_Main_X_Speed("Main_X_Speed", Float) = 0
		_Main_Y_Speed("Main_Y_Speed", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		[Toggle][Space()]_Use_WorldLight("Use_WorldLight", Float) = 0
		[Header(Vertex Offset)][Space()]_Vertex_Extrude("Vertex_Extrude", Float) = 0.5
		_Vertex_Suckin("Vertex_Suckin", Float) = -0.5
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Toggle][Header(Fresnel)][Space()]_Use_Fresnel("Use_Fresnel", Float) = 0
		_Bias("Bias", Float) = 0
		_Scale("Scale", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		_Power("Power", Float) = 5
		[Header(Intensity)][Space()]_Intensity_Color_Emissive("Intensity_Color_Emissive", Float) = 1
		_Intensity_Color_Smoke("Intensity_Color_Smoke", Float) = 1
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 0



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		UsePass "MMN/FX/AddPass/ShadowCaster"

		Pass
		{
			Name "Unlit"


			Cull [_CullMode]
			Blend Off
			ZTest [_ZTest]
			ZWrite On
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
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _NoiseTex;
			sampler2D _MaskTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _NoiseTex_ST;
			float4 _MaskTex_ST;
			float4 _MainTex_ST;
			float _LightRatio;
			float _Main_Y_Speed;
			float _Main_X_Speed;
			float _Use_Fresnel;
			float _Power;
			float _Scale;
			float _Bias;
			float _Intensity_Color_Emissive;
			float _Intensity_Color_Smoke;
			float _Use_WorldLight;
			float _Vertex_Suckin;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Vertex_Extrude;
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
				float3 ase_normal : NORMAL;
				float4 ase_texcoord4 : TEXCOORD4;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float3 VertexNormal322 = input.normalOS;
				float2 appendResult312 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float RandomUV319 = input.ase_texcoord1.w;
				float2 panner313 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult312 + ( uv_NoiseTex + RandomUV319 ));
				float NoiseTexture341 = tex2Dlod( _NoiseTex, float4( panner313, 0, 0.0) ).g;
				float2 uv_MaskTex = input.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float Mask320 = tex2Dlod( _MaskTex, float4( uv_MaskTex, 0, 0.0) ).g;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord4 = screenPos;

				output.ase_texcoord3 = input.ase_texcoord1;
				output.ase_color = input.color;
				output.ase_normal = input.normalOS;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( VertexNormal322 * ( ( ( 1.0 - NoiseTexture341 ) * _Vertex_Extrude ) + ( NoiseTexture341 * ( 1.0 - _Vertex_Suckin ) ) ) ) * Mask320 );
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
				float localApplySoftParticle80_g18 = ( 0.0 );
				float localApplyLightColor6_g18 = ( 0.0 );
				float localApplyShadowAtten104_g18 = ( 0.0 );
				half localApplyRaycastingAlpha92_g18 = ( 0.0 );
				float2 appendResult312 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float RandomUV319 = input.ase_texcoord3.w;
				float2 panner313 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult312 + ( uv_NoiseTex + RandomUV319 ));
				float NoiseTexture341 = tex2D( _NoiseTex, panner313 ).g;
				float temp_output_354_0 = ( 1.0 - NoiseTexture341 );
				float clampResult364 = clamp( temp_output_354_0 , input.ase_color.a , 1.0 );
				float3 VertexNormal322 = input.ase_normal;
				float dotResult349 = dot( ( VertexNormal322 + temp_output_354_0 ) , SafeNormalize(_MainLightPosition.xyz) );
				float clampResult360 = clamp( saturate( dotResult349 ) , input.ase_color.a , 1.0 );
				float lerpResult358 = lerp( clampResult364 , clampResult360 , _Use_WorldLight);
				float3 appendResult316 = (float3(input.uv0.z , input.uv0.w , input.ase_texcoord3.x));
				float3 EmissiveColor329 = appendResult316;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV366 = dot( input.normalWS, ase_worldViewDir );
				float fresnelNode366 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV366, _Power ) );
				float lerpResult357 = lerp( 1.0 , fresnelNode366 , _Use_Fresnel);
				float2 appendResult308 = (float2(_Main_X_Speed , _Main_Y_Speed));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner309 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult308 + uv_MainTex);
				float MainTexture340 = tex2D( _MainTex, panner309 ).g;
				float Emissive317 = input.ase_texcoord3.y;
				float4 lerpResult287 = lerp( ( lerpResult358 * input.ase_color * _Intensity_Color_Smoke ) , float4( ( EmissiveColor329 * _Intensity_Color_Emissive ) , 0.0 ) , saturate( ( lerpResult357 * ( ( ( ( NoiseTexture341 * MainTexture340 ) - Emissive317 ) / ( ( 1.0 - Emissive317 ) + 0.0001 ) ) * _Intensity_Alpha ) ) ));
				float temp_output_298_0 = ( MainTexture340 * NoiseTexture341 );
				float AlphaClip318 = input.ase_texcoord3.z;
				clip( temp_output_298_0 - AlphaClip318);
				float4 appendResult32_g18 = (float4(lerpResult287.rgb , temp_output_298_0));
				half4 finalColor92_g18 = appendResult32_g18;
				half3 positionWS92_g18 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g18 = ase_screenPosNorm;
				half4 screenPos92_g18 = ase_screenPosNorm;
				half nearPlane92_g18 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g18 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g18 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g18 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g18 , positionWS92_g18 , screenUV92_g18 , screenPos92_g18 , nearPlane92_g18 , nearPlaneInvertDistance92_g18 , raycastHarftoneClip92_g18 , raycastMinimumAlpha92_g18 );
				float4 finalColor104_g18 = finalColor92_g18;
				float4 shadowCoord104_g18 = input.uv0;
				float3 positionWS104_g18 = input.positionWS;
				float lightRatio104_g18 = _LightRatio;
				ApplyShadowAtten( finalColor104_g18 , shadowCoord104_g18 , positionWS104_g18 , lightRatio104_g18 );
				float4 finalColor6_g18 = finalColor104_g18;
				float3 normalWS6_g18 = input.normalWS;
				float lightRatio6_g18 = _LightRatio;
				ApplyLightColor( finalColor6_g18 , normalWS6_g18 , lightRatio6_g18 );
				float4 finalColor80_g18 = finalColor6_g18;
				float near80_g18 = _SoftParticleNearFadeDistance;
				float far80_g18 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g18 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g18 = ( 0.0 );
				float4 positionCS58_g18 = float4( 0,0,0,0 );
				float4 positionNDC58_g18 = float4( 0,0,0,0 );
				float3 positionOS58_g18 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g18 , positionNDC58_g18 , positionOS58_g18 );
				float4 positionNDC80_g18 = positionNDC58_g18;
				ApplySoftParticle( finalColor80_g18 , near80_g18 , far80_g18 , fadeOutRange80_g18 , positionNDC80_g18 );
				float4 break64_g18 = finalColor80_g18;
				float3 appendResult76_g18 = (float3(break64_g18.x , break64_g18.y , break64_g18.z));

				float3 Color = appendResult76_g18;
				float Alpha = break64_g18.w;

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
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"
	FallBack Off

	Fallback "Off"
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;372;-419.3672,12.7933;Inherit;False;543;400;AlpaClip;5;344;285;298;297;345;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;371;-414.3672,432.7933;Inherit;False;1163;558.9999;Vertex Data;12;293;281;289;295;296;361;362;283;286;290;374;343;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;89;992,288;Inherit;False;195;261;Rendering Options;2;91;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;99;1008,448;Inherit;False;Property;_ZTest;Z Test;31;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;1008,352;Inherit;False;Property;_CullMode;Cull Mode;26;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;280;-1384.591,1394.324;Inherit;False;2019.03;1359.431;Data;30;347;346;341;340;339;338;337;336;335;334;333;332;329;324;323;322;321;320;319;318;317;316;315;314;313;312;311;310;309;308;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;308;-294.5599,1798.734;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;309;-102.5593,1670.735;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;312;-312.0701,2194.019;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;313;-120.0691,2066.02;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;315;-159.6103,2212.538;Inherit;False;MMN_Time;-1;;15;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;316;-945.3295,1542.875;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;-927.2994,1735.171;Inherit;False;Emissive;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;318;-932.8195,1810.456;Inherit;False;AlphaClip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;347.1436,2515.582;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;321;-1187.484,2241.078;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;322;-1021.447,2232.581;Inherit;False;VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;323;-1228.751,1544.154;Inherit;True;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;324;-1242.855,1762.95;Inherit;True;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;-807.6545,1568.75;Inherit;False;EmissiveColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-470.5592,1798.734;Inherit;False;Property;_Main_X_Speed;Main_X_Speed;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;333;-470.5592,1878.734;Inherit;False;Property;_Main_Y_Speed;Main_Y_Speed;15;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-487.0692,2193.019;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;335;-488.0692,2274.018;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;18;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;336;58.01241,2495.431;Inherit;True;Property;_MaskTex;MaskTex;22;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;337;-99.16886,1795.07;Inherit;False;MMN_Time;-1;;17;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;339;67.8279,2053.131;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;340;398.5864,1703.244;Inherit;False;MainTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;341;376.0632,2068.172;Inherit;False;NoiseTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;471.156,529.6839;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-41.83807,778.4294;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;295;143.5023,619.8264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;280.609,527.0438;Inherit;False;322;VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;611.6302,531.3334;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;435.9321,633.266;Inherit;False;320;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;345;-408.3779,156.9537;Inherit;False;341;NoiseTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;297;-405.1085,74.70897;Inherit;False;340;MainTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-217.3779,99.95377;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;285;-52.48426,224.8177;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;-277.7361,276.9337;Inherit;False;318;AlphaClip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;287;-469.415,-256.6983;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-1259.225,312.0499;Inherit;False;Property;_Use_Fresnel;Use_Fresnel;23;1;[Toggle];Create;True;0;0;0;False;2;Header(Fresnel);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;366;-1229.766,50.8759;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-1395.052,122.2966;Inherit;False;Property;_Scale;Scale;25;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;369;-1394.052,41.29694;Inherit;False;Property;_Bias;Bias;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;368;-1375.052,192.2965;Inherit;False;Property;_Power;Power;27;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;357;-924.5269,175.8275;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-763.318,205.6948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;306;-620.6677,220.0604;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;292;-985.4238,432.7802;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;-1382.518,436.091;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-1558.817,497.1906;Inherit;False;340;MainTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;302;-1571.459,418.7576;Inherit;False;341;NoiseTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;291;-1426.136,591.8015;Inherit;False;317;Emissive;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;300;-1224,439.569;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;301;-1237.427,560.7985;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;303;-1101.635,557.7664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.0001;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;-1097.706,689.3214;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;30;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;367;-870.5677,431.0117;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-898.4199,-152.356;Inherit;False;Property;_Intensity_Color_Emissive;Intensity_Color_Emissive;28;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;328;-884.7236,-244.0273;Inherit;False;329;EmissiveColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;288;-656.2048,-220.3099;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;351;-1144.25,-864.2836;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;352;-655.4309,-880.124;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-980.835,-767.6813;Inherit;False;Property;_Intensity_Color_Smoke;Intensity_Color_Smoke;29;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;364;-943.741,-498.5143;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;360;-948.1968,-623.3309;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;358;-797.8237,-491.3473;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;363;-828.5248,-367.1248;Inherit;False;Property;_Use_WorldLight;Use_WorldLight;19;1;[Toggle];Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;348;-1428.979,-668.8555;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;349;-1220.009,-611.9001;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;353;-1682.915,-673.7258;Inherit;False;322;VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;354;-1512.341,-527.4131;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;355;-1712.252,-530.986;Inherit;False;341;NoiseTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;350;-1102.461,-608.823;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;356;-1476.134,-440.8539;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;327;244.8743,-114.3818;Inherit;False;MMN_CommonOutputs;0;;18;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.WireNode;373;-197.6082,-110.448;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;729.3865,-109.9986;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;0;22;MMN/FX/Amplify shader/FX_AlphaTest_Explosion_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=AlphaTest=Queue=0;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Off;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-243.475,876.0873;Inherit;False;Property;_Vertex_Suckin;Vertex_Suckin;21;0;Create;True;0;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;374;-56.97083,869.6492;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;296;-235.2328,554.4996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-125.5164,653.1191;Inherit;False;Property;_Vertex_Extrude;Vertex_Extrude;20;0;Create;True;0;0;0;False;2;Header(Vertex Offset);Space();False;0.5;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;-72.66083,553.6533;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-408.5873,654.1162;Inherit;False;341;NoiseTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;319;-918.4384,1904.679;Inherit;False;RandomUV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;338;89.44193,1670.735;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;311;-456.5453,2099.63;Inherit;False;319;RandomUV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;310;-252.7452,2024.228;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;347;-471.94,1964.102;Inherit;False;0;339;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;346;-520.5592,1477.735;Inherit;False;0;338;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;314;-160.4364,2516.52;Inherit;False;0;336;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;308;0;332;0
WireConnection;308;1;333;0
WireConnection;309;0;346;0
WireConnection;309;2;308;0
WireConnection;309;1;337;0
WireConnection;312;0;334;0
WireConnection;312;1;335;0
WireConnection;313;0;310;0
WireConnection;313;2;312;0
WireConnection;313;1;315;0
WireConnection;316;0;323;3
WireConnection;316;1;323;4
WireConnection;316;2;324;1
WireConnection;317;0;324;2
WireConnection;318;0;324;3
WireConnection;320;0;336;2
WireConnection;322;0;321;0
WireConnection;329;0;316;0
WireConnection;336;1;314;0
WireConnection;339;1;313;0
WireConnection;340;0;338;2
WireConnection;341;0;339;2
WireConnection;290;0;289;0
WireConnection;290;1;295;0
WireConnection;283;0;343;0
WireConnection;283;1;374;0
WireConnection;295;0;286;0
WireConnection;295;1;283;0
WireConnection;281;0;290;0
WireConnection;281;1;293;0
WireConnection;298;0;297;0
WireConnection;298;1;345;0
WireConnection;285;0;298;0
WireConnection;285;1;298;0
WireConnection;285;2;344;0
WireConnection;287;0;352;0
WireConnection;287;1;288;0
WireConnection;287;2;306;0
WireConnection;366;1;369;0
WireConnection;366;2;370;0
WireConnection;366;3;368;0
WireConnection;357;1;366;0
WireConnection;357;2;365;0
WireConnection;307;0;357;0
WireConnection;307;1;367;0
WireConnection;306;0;307;0
WireConnection;292;0;300;0
WireConnection;292;1;303;0
WireConnection;299;0;302;0
WireConnection;299;1;294;0
WireConnection;300;0;299;0
WireConnection;300;1;291;0
WireConnection;301;0;291;0
WireConnection;303;0;301;0
WireConnection;367;0;292;0
WireConnection;367;1;330;0
WireConnection;288;0;328;0
WireConnection;288;1;331;0
WireConnection;352;0;358;0
WireConnection;352;1;351;0
WireConnection;352;2;359;0
WireConnection;364;0;354;0
WireConnection;364;1;351;4
WireConnection;360;0;350;0
WireConnection;360;1;351;4
WireConnection;358;0;364;0
WireConnection;358;1;360;0
WireConnection;358;2;363;0
WireConnection;348;0;353;0
WireConnection;348;1;354;0
WireConnection;349;0;348;0
WireConnection;349;1;356;0
WireConnection;354;0;355;0
WireConnection;350;0;349;0
WireConnection;327;9;373;0
WireConnection;327;28;285;0
WireConnection;373;0;287;0
WireConnection;98;0;327;2
WireConnection;98;1;327;26
WireConnection;98;3;281;0
WireConnection;374;0;362;0
WireConnection;296;0;343;0
WireConnection;286;0;296;0
WireConnection;286;1;361;0
WireConnection;319;0;324;4
WireConnection;338;1;309;0
WireConnection;310;0;347;0
WireConnection;310;1;311;0
ASEEND*/
//CHKSM=B5B6EDE5FFDA7F89F1F90B3D554BCA7526A0E767