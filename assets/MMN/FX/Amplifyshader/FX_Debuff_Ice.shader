// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Debuff_Ice"
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
		[NoScaleOffset][Header(Texture Options)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Tiling("MainTex Tiling", Vector) = (0.8,0.8,0.8,0)
		_Main_Speed("Main_Speed", Vector) = (0,0.2,0,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoisePower("NoisePower", Float) = 0.1
		_Noise_Speed("Noise_Speed", Vector) = (0,0.1,0,0)
		[HDR]_In_Color("In_Color", Color) = (0.09411765,0.4392157,0.4901961,0.2)
		[HDR]_Mid_Color("Mid_Color", Color) = (1.498039,1.498039,1.498039,1)
		[ASEEnd][HDR][Header(Color)][Space()]_Out_Color("Out_Color", Color) = (1.457735,2.342256,3.383649,1)
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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
			CBUFFER_START( UnityPerMaterial )
			float4 _In_Color;
			float4 _NoiseTex_ST;
			float4 _Mid_Color;
			float4 _Out_Color;
			float3 _Tiling;
			float3 _Main_Speed;
			float2 _Noise_Speed;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _NoisePower;
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
				float localApplySoftParticle80_g16 = ( 0.0 );
				float localApplyLightColor6_g16 = ( 0.0 );
				float localApplyShadowAtten104_g16 = ( 0.0 );
				half localApplyRaycastingAlpha92_g16 = ( 0.0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float dotResult476 = dot( ase_worldViewDir , normalizedWorldNormal );
				float saferPower479 = abs( saturate( dotResult476 ) );
				float temp_output_478_0 = ( 1.0 - pow( saferPower479 , 1.0 ) );
				float3 normalWS471 = normalizedWorldNormal;
				float3 temp_output_501_0 = input.positionWS;
				float temp_output_510_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float3 break469 = ( ( ( ( temp_output_501_0 * _Tiling ) + float3(0,0,0) ) + ( temp_output_510_0 * _Main_Speed ) ) + ( tex2D( _NoiseTex, ( uv_NoiseTex + ( temp_output_510_0 * _Noise_Speed ) ) ).g * _NoisePower ) );
				float2 appendResult473 = (float2(break469.z , break469.y));
				float2 appendResult468 = (float2(break469.x , break469.z));
				float2 appendResult472 = (float2(break469.x , break469.y));
				float3 appendResult467 = (float3(tex2D( _MainTex, appendResult473 ).r , tex2D( _MainTex, appendResult468 ).g , tex2D( _MainTex, appendResult472 ).b));
				float3 triplanarTex471 = appendResult467;
				float localTriplanar471 = Triplanar( normalWS471 , triplanarTex471 );
				float temp_output_437_0 = ( temp_output_478_0 + localTriplanar471 );
				float temp_output_443_0 = saturate( ( ( 1.33 - temp_output_437_0 ) * 1.0 ) );
				float temp_output_436_0 = ( temp_output_478_0 * localTriplanar471 );
				float4 lerpResult432 = lerp( ( ( _In_Color * temp_output_443_0 ) + ( _Mid_Color * saturate( ( ( 1.0 - temp_output_443_0 ) - saturate( ( 1.0 * ( -0.2 + ( 1.0 - temp_output_437_0 ) ) ) ) ) ) ) ) , _Out_Color , saturate( ( 1.0 * ( temp_output_436_0 * saturate( ( temp_output_436_0 - -0.4 ) ) ) ) ));
				float4 appendResult32_g16 = (float4(lerpResult432.rgb , saturate( (lerpResult432).a )));
				half4 finalColor92_g16 = appendResult32_g16;
				half3 positionWS92_g16 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g16 = ase_screenPosNorm;
				half4 screenPos92_g16 = ase_screenPosNorm;
				half nearPlane92_g16 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g16 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g16 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g16 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g16 , positionWS92_g16 , screenUV92_g16 , screenPos92_g16 , nearPlane92_g16 , nearPlaneInvertDistance92_g16 , raycastHarftoneClip92_g16 , raycastMinimumAlpha92_g16 );
				float4 finalColor104_g16 = finalColor92_g16;
				float4 shadowCoord104_g16 = input.uv0;
				float3 positionWS104_g16 = input.positionWS;
				float lightRatio104_g16 = _LightRatio;
				ApplyShadowAtten( finalColor104_g16 , shadowCoord104_g16 , positionWS104_g16 , lightRatio104_g16 );
				float4 finalColor6_g16 = finalColor104_g16;
				float3 normalWS6_g16 = input.normalWS;
				float lightRatio6_g16 = _LightRatio;
				ApplyLightColor( finalColor6_g16 , normalWS6_g16 , lightRatio6_g16 );
				float4 finalColor80_g16 = finalColor6_g16;
				float near80_g16 = _SoftParticleNearFadeDistance;
				float far80_g16 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g16 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g16 = ( 0.0 );
				float4 positionCS58_g16 = float4( 0,0,0,0 );
				float4 positionNDC58_g16 = float4( 0,0,0,0 );
				float3 positionOS58_g16 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g16 , positionNDC58_g16 , positionOS58_g16 );
				float4 positionNDC80_g16 = positionNDC58_g16;
				ApplySoftParticle( finalColor80_g16 , near80_g16 , far80_g16 , fadeOutRange80_g16 , positionNDC80_g16 );
				float4 break64_g16 = finalColor80_g16;
				float3 appendResult76_g16 = (float3(break64_g16.x , break64_g16.y , break64_g16.z));
				
				float3 Color = appendResult76_g16;
				float Alpha = break64_g16.w;

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
Node;AmplifyShaderEditor.CommentaryNode;496;-2480,2048;Inherit;False;1011.896;785.9595;Noise Texture;11;498;504;513;505;506;503;502;501;500;499;497;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;495;-2944,2864;Inherit;False;762;574;Time;7;515;514;511;510;509;508;507;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;514;-2864,3120;Inherit;False;Property;_Noise_Speed;Noise_Speed;18;0;Create;False;0;0;0;False;0;False;0,0.1;0,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;499;-2464,2096;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;510;-2832,3040;Inherit;False;MMN_Time;-1;;15;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;515;-2864,3248;Inherit;False;Property;_Main_Speed;Main_Speed;15;0;Create;True;0;0;0;False;0;False;0,0.2,0;0,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;504;-2288,2240;Inherit;False;Property;_Tiling;MainTex Tiling;14;0;Create;False;0;0;0;True;0;False;0.8,0.8,0.8;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;508;-2560,2912;Inherit;False;0;505;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;-2480,3040;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TransformPositionNode;501;-2288,2096;Inherit;False;World;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;507;-2336,2912;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;500;-2080,2144;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;498;-2288,2384;Inherit;False;Constant;_Offset;MainTex Offset;12;0;Create;False;0;0;0;True;0;False;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-2496,3200;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;505;-2144,2544;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;False;0;0;0;False;0;False;493;b9d432b16df585547b51afe19ed41d8a;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;497;-1936,2368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;513;-2016,2736;Inherit;False;Property;_NoisePower;NoisePower;17;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;512;-1912,3181;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;502;-1776,2368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;-1776,2608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;503;-1616,2368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;426;-556.6353,1623.74;Inherit;False;853;393;Fresnel;6;479;478;477;476;475;474;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;427;-1440,2064;Inherit;False;1399;664;Triplanar Texture;9;493;492;491;473;472;471;469;468;467;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;475;-508.6353,1831.74;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;474;-492.6353,1671.74;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;469;-1264,2368;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;476;-300.6353,1751.74;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;468;-1056,2384;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;473;-1056,2288;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;472;-1056,2480;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;493;-896,2304;Inherit;True;Property;_MainTex3;MainTex;13;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;491;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;491;-896,2112;Inherit;True;Property;_MainTex;MainTex;13;1;[NoScaleOffset];Create;False;0;0;0;False;2;Header(Texture Options);Space();False;-1;2d0185883b9904e4297371dc7eb19a56;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;492;-896,2496;Inherit;True;Property;_MainTex2;MainTex;13;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;491;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;477;-172.6353,1751.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;467;-480,2304;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;479;-28.63525,1751.74;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;478;115.3647,1751.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;471;-288,2304;Inherit;False; ;1;File;2;True;normalWS;FLOAT3;0,0,0;In;;Inherit;False;True;triplanarTex;FLOAT3;0,0,0;In;;Inherit;False;Triplanar;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;437;627.3647,2391.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;439;613.3647,2103.74;Inherit;False;Constant;_Mid_Cut;Mid_Cut;19;0;Create;True;0;0;0;False;0;False;1.33;1.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;451;979.3647,2151.74;Inherit;False;Constant;_Alpha;Alpha;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;456;803.3647,2391.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;441;995.3647,2007.74;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;608,2192;Inherit;False;Constant;_In_Cut;In_Cut;20;0;Create;True;0;0;0;False;0;False;-0.2;-0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;1155.365,2007.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;452;995.3647,2231.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;438;608,2016;Inherit;False;Constant;_Out_Cut;Out_Cut;18;0;Create;True;0;0;0;False;2;Header(Cutout);Space();False;-0.4;-0.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;627.3647,2279.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;443;1283.365,2007.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;1155.365,2103.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;445;1443.365,2007.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;455;1151.365,2343.74;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;448;1283.365,2103.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;449;1603.365,2007.74;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;454;1295.365,2343.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;461;1408.365,1971.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;458;2195.365,1975.74;Inherit;False;Property;_Mid_Color;Mid_Color;20;1;[HDR];Create;False;0;0;0;False;0;False;1.498039,1.498039,1.498039,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;459;2195.365,1799.74;Inherit;False;Property;_In_Color;In_Color;19;1;[HDR];Create;False;0;0;0;False;0;False;0.09411765,0.4392157,0.4901961,0.2;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;450;1558.365,2242.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;1443.365,2279.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;446;1731.365,2007.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;2435.365,1991.74;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;444;1603.365,2279.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;2435.365,1895.74;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;433;2595.365,1975.74;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;460;2195.365,2151.74;Inherit;False;Property;_Out_Color;Out_Color;21;1;[HDR];Create;False;0;0;0;False;2;Header(Color);Space();False;1.457735,2.342256,3.383649,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;457;1731.365,2279.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;432;2723.365,2039.74;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;431;2963.365,2119.74;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;430;3155.365,2118.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;3616,2400;Inherit;False;Property;_CullMode;Cull Mode;24;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;3616,2320;Inherit;False;Property;_BlendDst;Blend Dst;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;3616,2240;Inherit;False;Property;_BlendSrc;Blend Src;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;3616,2480;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;429;3299.365,2039.74;Inherit;False;MMN_CommonOutputs;0;;16;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;3584,2048;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Debuff_Ice;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;509;0;510;0
WireConnection;509;1;514;0
WireConnection;501;0;499;0
WireConnection;507;0;508;0
WireConnection;507;1;509;0
WireConnection;500;0;501;0
WireConnection;500;1;504;0
WireConnection;511;0;510;0
WireConnection;511;1;515;0
WireConnection;505;1;507;0
WireConnection;497;0;500;0
WireConnection;497;1;498;0
WireConnection;512;0;511;0
WireConnection;502;0;497;0
WireConnection;502;1;512;0
WireConnection;506;0;505;2
WireConnection;506;1;513;0
WireConnection;503;0;502;0
WireConnection;503;1;506;0
WireConnection;469;0;503;0
WireConnection;476;0;474;0
WireConnection;476;1;475;0
WireConnection;468;0;469;0
WireConnection;468;1;469;2
WireConnection;473;0;469;2
WireConnection;473;1;469;1
WireConnection;472;0;469;0
WireConnection;472;1;469;1
WireConnection;493;1;468;0
WireConnection;491;1;473;0
WireConnection;492;1;472;0
WireConnection;477;0;476;0
WireConnection;467;0;491;1
WireConnection;467;1;493;2
WireConnection;467;2;492;3
WireConnection;479;0;477;0
WireConnection;478;0;479;0
WireConnection;471;0;475;0
WireConnection;471;1;467;0
WireConnection;437;0;478;0
WireConnection;437;1;471;0
WireConnection;456;0;437;0
WireConnection;441;0;439;0
WireConnection;441;1;437;0
WireConnection;442;0;441;0
WireConnection;442;1;451;0
WireConnection;452;0;440;0
WireConnection;452;1;456;0
WireConnection;436;0;478;0
WireConnection;436;1;471;0
WireConnection;443;0;442;0
WireConnection;453;0;451;0
WireConnection;453;1;452;0
WireConnection;445;0;443;0
WireConnection;455;0;436;0
WireConnection;455;1;438;0
WireConnection;448;0;453;0
WireConnection;449;0;445;0
WireConnection;449;1;448;0
WireConnection;454;0;455;0
WireConnection;461;0;443;0
WireConnection;450;0;451;0
WireConnection;447;0;436;0
WireConnection;447;1;454;0
WireConnection;446;0;449;0
WireConnection;434;0;458;0
WireConnection;434;1;446;0
WireConnection;444;0;450;0
WireConnection;444;1;447;0
WireConnection;435;0;459;0
WireConnection;435;1;461;0
WireConnection;433;0;435;0
WireConnection;433;1;434;0
WireConnection;457;0;444;0
WireConnection;432;0;433;0
WireConnection;432;1;460;0
WireConnection;432;2;457;0
WireConnection;431;0;432;0
WireConnection;430;0;431;0
WireConnection;429;9;432;0
WireConnection;429;28;430;0
WireConnection;97;0;429;2
WireConnection;97;1;429;26
ASEEND*/
//CHKSM=86B16FED377951C0663C2B41518191BFB955263A