// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Debuff_Fire"
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
		_Tiling("MainTex Tiling", Vector) = (1,1,1,0)
		_Offset("MainTex Offset", Vector) = (0,0,0,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Out_Color("Out_Color", Color) = (2,0,0,1)
		[HDR]_Mid_Color("Mid_Color", Color) = (3.441591,0.7027332,0,1)
		[ASEEnd][HDR]_In_Color("In_Color", Color) = (1,0.03623188,0,0.2)
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 2
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
			float3 _Offset;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
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
				float localApplySoftParticle80_g15 = ( 0.0 );
				float localApplyLightColor6_g15 = ( 0.0 );
				float localApplyShadowAtten104_g15 = ( 0.0 );
				half localApplyRaycastingAlpha92_g15 = ( 0.0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float dotResult476 = dot( ase_worldViewDir , normalizedWorldNormal );
				float saferPower479 = abs( saturate( dotResult476 ) );
				float temp_output_478_0 = ( 1.0 - pow( saferPower479 , 1.0 ) );
				float3 normalWS471 = normalizedWorldNormal;
				float3 temp_output_521_0 = input.positionWS;
				float temp_output_461_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float3 break469 = ( ( ( ( temp_output_521_0 * _Tiling ) + _Offset ) + ( temp_output_461_0 * float3(-0.42,-0.4,-0.23) ) ) + ( tex2D( _NoiseTex, ( uv_NoiseTex + ( temp_output_461_0 * float2( 0.18,-0.19 ) ) ) ).g * 0.2 ) );
				float2 appendResult473 = (float2(break469.z , break469.y));
				float2 appendResult467 = (float2(break469.x , break469.z));
				float2 appendResult472 = (float2(break469.x , break469.y));
				float3 appendResult465 = (float3(tex2D( _MainTex, appendResult473 ).r , tex2D( _MainTex, appendResult467 ).g , tex2D( _MainTex, appendResult472 ).b));
				float3 triplanarTex471 = appendResult465;
				float localTriplanar471 = Triplanar( normalWS471 , triplanarTex471 );
				float temp_output_434_0 = ( temp_output_478_0 + localTriplanar471 );
				float temp_output_304_0 = saturate( ( ( temp_output_434_0 - 0.7 ) * 10.0 ) );
				float temp_output_433_0 = ( temp_output_478_0 * localTriplanar471 );
				float4 lerpResult429 = lerp( ( ( _In_Color * saturate( ( ( 1.0 - temp_output_304_0 ) - saturate( ( ( ( 1.0 - temp_output_434_0 ) + -1.0 ) * 10.0 ) ) ) ) ) + ( _Mid_Color * temp_output_304_0 ) ) , _Out_Color , saturate( ( 10.0 * ( saturate( ( temp_output_433_0 - 0.17 ) ) * temp_output_433_0 ) ) ));
				float4 appendResult32_g15 = (float4(lerpResult429.rgb , saturate( (lerpResult429).a )));
				half4 finalColor92_g15 = appendResult32_g15;
				half3 positionWS92_g15 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g15 = ase_screenPosNorm;
				half4 screenPos92_g15 = ase_screenPosNorm;
				half nearPlane92_g15 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g15 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g15 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g15 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g15 , positionWS92_g15 , screenUV92_g15 , screenPos92_g15 , nearPlane92_g15 , nearPlaneInvertDistance92_g15 , raycastHarftoneClip92_g15 , raycastMinimumAlpha92_g15 );
				float4 finalColor104_g15 = finalColor92_g15;
				float4 shadowCoord104_g15 = input.uv0;
				float3 positionWS104_g15 = input.positionWS;
				float lightRatio104_g15 = _LightRatio;
				ApplyShadowAtten( finalColor104_g15 , shadowCoord104_g15 , positionWS104_g15 , lightRatio104_g15 );
				float4 finalColor6_g15 = finalColor104_g15;
				float3 normalWS6_g15 = input.normalWS;
				float lightRatio6_g15 = _LightRatio;
				ApplyLightColor( finalColor6_g15 , normalWS6_g15 , lightRatio6_g15 );
				float4 finalColor80_g15 = finalColor6_g15;
				float near80_g15 = _SoftParticleNearFadeDistance;
				float far80_g15 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g15 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g15 = ( 0.0 );
				float4 positionCS58_g15 = float4( 0,0,0,0 );
				float4 positionNDC58_g15 = float4( 0,0,0,0 );
				float3 positionOS58_g15 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g15 , positionNDC58_g15 , positionOS58_g15 );
				float4 positionNDC80_g15 = positionNDC58_g15;
				ApplySoftParticle( finalColor80_g15 , near80_g15 , far80_g15 , fadeOutRange80_g15 , positionNDC80_g15 );
				float4 break64_g15 = finalColor80_g15;
				float3 appendResult76_g15 = (float3(break64_g15.x , break64_g15.y , break64_g15.z));
				
				float3 Color = appendResult76_g15;
				float Alpha = break64_g15.w;

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
Node;AmplifyShaderEditor.CommentaryNode;425;-3424,1664;Inherit;False;1397;809;Noise Texture;11;487;491;490;489;486;485;484;483;501;512;521;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;461;-3824,2704;Inherit;False;MMN_Time;-1;;14;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;485;-3408,1712;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;526;-3856,2784;Inherit;False;Constant;_Noise_Speed;Noise_Speed;15;0;Create;False;0;0;0;False;0;False;0.18,-0.19;-0.26,0.14;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TransformPositionNode;521;-3248,1712;Inherit;False;World;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;489;-3248,1856;Inherit;False;Property;_Tiling;MainTex Tiling;14;0;Create;False;0;0;0;True;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;497;-3472,2704;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;524;-3552,2576;Inherit;False;0;491;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;519;-3888,2912;Inherit;False;Constant;_Main_Speed;Main_Speed;13;0;Create;True;0;0;0;False;0;False;-0.42,-0.4,-0.23;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;463;-3488,2864;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;490;-3248,2000;Inherit;False;Property;_Offset;MainTex Offset;15;0;Create;False;0;0;0;True;0;False;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;483;-3040,1760;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;525;-3328,2576;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;528;-2896,2800;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;484;-2896,1984;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;486;-2976,2352;Inherit;False;Constant;_NoisePower1;NoisePower;15;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;491;-3104,2160;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;False;0;0;0;False;0;False;491;b9d432b16df585547b51afe19ed41d8a;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;-2736,2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;501;-2736,1984;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;426;-1114.913,1230.373;Inherit;False;853;393;Fresnel;6;479;478;477;476;475;474;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;427;-2000,1664;Inherit;False;1399;664;Triplanar Texture;9;480;473;472;471;469;468;467;466;465;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;512;-2560,1984;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;474;-1050.913,1278.373;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;475;-1066.913,1438.373;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;469;-1824,1984;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;476;-858.913,1358.373;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;467;-1616,2000;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;472;-1616,2096;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;473;-1616,1904;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;466;-1440,1920;Inherit;True;Property;_MainTex1;MainTex;13;0;Create;False;0;0;0;False;0;False;480;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;480;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;468;-1440,2112;Inherit;True;Property;_MainTex2;MainTex;13;0;Create;False;0;0;0;False;0;False;480;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;480;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;480;-1440,1728;Inherit;True;Property;_MainTex;MainTex;13;1;[NoScaleOffset];Create;True;0;0;0;False;2;Header(Texture Options);Space();False;-1;d837d530b5931a647abf5aa9974b95c3;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;477;-730.913,1358.373;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;479;-592,1360;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;465;-1040,1920;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;471;-848,1920;Inherit;False; ;1;File;2;True;normalWS;FLOAT3;0,0,0;In;;Inherit;False;True;triplanarTex;FLOAT3;0,0,0;In;;Inherit;False;Triplanar;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;478;-448,1360;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;-197.2365,1504.332;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;436;53.08704,1710.373;Inherit;False;Constant;_Mid_Cut;Mid_Cut;22;0;Create;True;0;0;0;False;0;False;0.7;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;332;395,1491;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;385.7936,1581.948;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;54.08704,1630.373;Inherit;False;Constant;_In_Cut;In_Cut;24;0;Create;True;0;0;0;False;0;False;-1;-5.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;448;602.3634,1688.19;Inherit;False;Constant;_Alpha1;Alpha;24;0;Create;True;0;0;0;False;0;False;10;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;784,1856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;784,1536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;928,1856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;53.08704,1790.373;Inherit;False;Constant;_Out_Cut;Out_Cut;19;0;Create;True;0;0;0;False;2;Header(Cutout);Space();False;0.17;0.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;304;928,1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-244.9399,1864.968;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;330;1056,1856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;349;1056,1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;423;224,1856;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;374;352,1856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;350;1264,1552;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;480,1936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;355;1424,1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;455;1616,1632;Inherit;False;Property;_Mid_Color;Mid_Color;18;1;[HDR];Create;False;0;0;0;False;0;False;3.441591,0.7027332,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;456;1616,1456;Inherit;False;Property;_In_Color;In_Color;19;1;[HDR];Create;False;0;0;0;False;0;False;1,0.03623188,0,0.2;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;508;1904,1520;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;816,1744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;509;1904,1632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;457;1616,1808;Inherit;False;Property;_Out_Color;Out_Color;17;1;[HDR];Create;False;0;0;0;False;2;Header(Color);Space();False;2,0,0,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;379;1264,1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;510;2064,1568;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;429;2208,1696;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;422;2464,1776;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;417;2656,1776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;3040,1872;Inherit;False;204;375;Rendering Options;4;79;78;77;424;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;78;3073,1920;Inherit;False;Property;_BlendSrc;Blend Src;20;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;3072,2000;Inherit;False;Property;_BlendDst;Blend Dst;21;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;3072,2080;Inherit;False;Property;_CullMode;Cull Mode;22;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;3088,2160;Inherit;False;Property;_ZTest;Z Test;23;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;2784,1696;Inherit;False;MMN_CommonOutputs;0;;15;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;3040,1696;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Debuff_Fire;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;521;0;485;0
WireConnection;497;0;461;0
WireConnection;497;1;526;0
WireConnection;463;0;461;0
WireConnection;463;1;519;0
WireConnection;483;0;521;0
WireConnection;483;1;489;0
WireConnection;525;0;524;0
WireConnection;525;1;497;0
WireConnection;528;0;463;0
WireConnection;484;0;483;0
WireConnection;484;1;490;0
WireConnection;491;1;525;0
WireConnection;487;0;491;2
WireConnection;487;1;486;0
WireConnection;501;0;484;0
WireConnection;501;1;528;0
WireConnection;512;0;501;0
WireConnection;512;1;487;0
WireConnection;469;0;512;0
WireConnection;476;0;474;0
WireConnection;476;1;475;0
WireConnection;467;0;469;0
WireConnection;467;1;469;2
WireConnection;472;0;469;0
WireConnection;472;1;469;1
WireConnection;473;0;469;2
WireConnection;473;1;469;1
WireConnection;466;1;467;0
WireConnection;468;1;472;0
WireConnection;480;1;473;0
WireConnection;477;0;476;0
WireConnection;479;0;477;0
WireConnection;465;0;480;1
WireConnection;465;1;466;2
WireConnection;465;2;468;3
WireConnection;471;0;475;0
WireConnection;471;1;465;0
WireConnection;478;0;479;0
WireConnection;434;0;478;0
WireConnection;434;1;471;0
WireConnection;332;0;434;0
WireConnection;332;1;436;0
WireConnection;327;0;434;0
WireConnection;328;0;327;0
WireConnection;328;1;437;0
WireConnection;215;0;332;0
WireConnection;215;1;448;0
WireConnection;331;0;328;0
WireConnection;331;1;448;0
WireConnection;304;0;215;0
WireConnection;433;0;478;0
WireConnection;433;1;471;0
WireConnection;330;0;331;0
WireConnection;349;0;304;0
WireConnection;423;0;433;0
WireConnection;423;1;435;0
WireConnection;374;0;423;0
WireConnection;350;0;349;0
WireConnection;350;1;330;0
WireConnection;372;0;374;0
WireConnection;372;1;433;0
WireConnection;355;0;350;0
WireConnection;508;0;456;0
WireConnection;508;1;355;0
WireConnection;375;0;448;0
WireConnection;375;1;372;0
WireConnection;509;0;455;0
WireConnection;509;1;304;0
WireConnection;379;0;375;0
WireConnection;510;0;508;0
WireConnection;510;1;509;0
WireConnection;429;0;510;0
WireConnection;429;1;457;0
WireConnection;429;2;379;0
WireConnection;422;0;429;0
WireConnection;417;0;422;0
WireConnection;119;9;429;0
WireConnection;119;28;417;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
ASEEND*/
//CHKSM=212F0396E52778DE58942FDB52A0027B459DD7CD