// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Debuff_Light"
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
		[NoScaleOffset]_SubTex("SubTex", 2D) = "white" {}
		_Tiling("MainTex Tiling", Vector) = (1,1,1,0)
		_Main_Speed("Main_Speed", Vector) = (0,0,0,0)
		_NoiseTex1("NoiseTex", 2D) = "white" {}
		_NoisePower1("NoisePower", Float) = 0.1
		_Noise_Speed("Noise_Speed", Vector) = (0.3,-0.3,0,0)
		[Space()]_Mask("Mask", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Out_Color("Out_Color", Color) = (0.5240962,1.249991,4.385861,1)
		[HDR]_Mid_Color("Mid_Color", Color) = (0,2.251818,6.422235,1)
		[ASEEnd][HDR]_In_Color("In_Color", Color) = (0.2901961,0.372549,0.772549,0.6)
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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


			sampler2D _Mask;
			sampler2D _MainTex;
			sampler2D _SubTex;
			sampler2D _NoiseTex1;
			CBUFFER_START( UnityPerMaterial )
			float4 _In_Color;
			float4 _Mask_ST;
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
			float _NoisePower1;
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
				float localApplySoftParticle80_g20 = ( 0.0 );
				float localApplyLightColor6_g20 = ( 0.0 );
				float localApplyShadowAtten104_g20 = ( 0.0 );
				half localApplyRaycastingAlpha92_g20 = ( 0.0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float dotResult589 = dot( ase_worldViewDir , normalizedWorldNormal );
				float saferPower595 = abs( saturate( dotResult589 ) );
				float temp_output_591_0 = ( 1.0 - pow( saferPower595 , 2.0 ) );
				float temp_output_663_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float fresnelNdotV495 = dot( input.normalWS, ase_worldViewDir );
				float fresnelNode495 = ( 0.0 + 0.4 * pow( 1.0 - fresnelNdotV495, 0.1 ) );
				float2 uv_Mask = input.uv0.xy * _Mask_ST.xy + _Mask_ST.zw;
				float temp_output_536_0 = ( fresnelNode495 + ( tex2D( _Mask, uv_Mask ).g * 0.4 ) );
				float3 normalWS584 = normalizedWorldNormal;
				float3 temp_output_601_0 = input.positionWS;
				float temp_output_607_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float3 temp_output_602_0 = ( ( ( temp_output_601_0 * _Tiling ) + float3(0.7,1.3,0) ) + ( temp_output_607_0 * _Main_Speed ) );
				float3 break583 = temp_output_602_0;
				float2 appendResult586 = (float2(break583.z , break583.y));
				float2 appendResult582 = (float2(break583.x , break583.z));
				float2 appendResult585 = (float2(break583.x , break583.y));
				float3 appendResult581 = (float3(tex2D( _MainTex, appendResult586 ).r , tex2D( _MainTex, appendResult582 ).g , tex2D( _MainTex, appendResult585 ).b));
				float3 triplanarTex584 = appendResult581;
				float localTriplanar584 = Triplanar( normalWS584 , triplanarTex584 );
				float3 normalWS657 = normalizedWorldNormal;
				float2 texCoord623 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float3 break651 = ( temp_output_602_0 + ( tex2D( _NoiseTex1, ( texCoord623 + ( temp_output_607_0 * _Noise_Speed ) ) ).g * _NoisePower1 ) );
				float2 appendResult653 = (float2(break651.z , break651.y));
				float2 appendResult650 = (float2(break651.x , break651.z));
				float2 appendResult652 = (float2(break651.x , break651.y));
				float3 appendResult649 = (float3(tex2D( _SubTex, appendResult653 ).r , tex2D( _SubTex, appendResult650 ).g , tex2D( _SubTex, appendResult652 ).b));
				float3 triplanarTex657 = appendResult649;
				float localTriplanar657 = Triplanar( normalWS657 , triplanarTex657 );
				float temp_output_662_0 = saturate( ( ( sin( ( ( ( temp_output_663_0 * -10.0 ) * 2.0 ) + ( -50.0 * temp_output_536_0 ) ) ) * localTriplanar584 ) + ( sin( ( ( temp_output_536_0 * ( -50.0 - 15.0 ) ) + ( 2.0 * ( temp_output_663_0 * -20.0 ) ) ) ) * localTriplanar657 ) ) );
				float temp_output_563_0 = ( temp_output_591_0 + temp_output_662_0 );
				float temp_output_566_0 = saturate( ( ( 1.35 - temp_output_563_0 ) * 2.0 ) );
				float temp_output_562_0 = ( temp_output_591_0 * temp_output_662_0 );
				float4 lerpResult558 = lerp( ( ( _In_Color * temp_output_566_0 ) + ( _Mid_Color * saturate( ( ( 1.0 - temp_output_566_0 ) - saturate( ( 2.0 * ( -1.0 + ( 1.0 - temp_output_563_0 ) ) ) ) ) ) ) ) , _Out_Color , saturate( ( 2.0 * ( temp_output_562_0 * saturate( ( temp_output_562_0 - -0.21 ) ) ) ) ));
				float4 appendResult32_g20 = (float4(lerpResult558.rgb , saturate( (lerpResult558).a )));
				half4 finalColor92_g20 = appendResult32_g20;
				half3 positionWS92_g20 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g20 = ase_screenPosNorm;
				half4 screenPos92_g20 = ase_screenPosNorm;
				half nearPlane92_g20 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g20 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g20 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g20 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g20 , positionWS92_g20 , screenUV92_g20 , screenPos92_g20 , nearPlane92_g20 , nearPlaneInvertDistance92_g20 , raycastHarftoneClip92_g20 , raycastMinimumAlpha92_g20 );
				float4 finalColor104_g20 = finalColor92_g20;
				float4 shadowCoord104_g20 = input.uv0;
				float3 positionWS104_g20 = input.positionWS;
				float lightRatio104_g20 = _LightRatio;
				ApplyShadowAtten( finalColor104_g20 , shadowCoord104_g20 , positionWS104_g20 , lightRatio104_g20 );
				float4 finalColor6_g20 = finalColor104_g20;
				float3 normalWS6_g20 = input.normalWS;
				float lightRatio6_g20 = _LightRatio;
				ApplyLightColor( finalColor6_g20 , normalWS6_g20 , lightRatio6_g20 );
				float4 finalColor80_g20 = finalColor6_g20;
				float near80_g20 = _SoftParticleNearFadeDistance;
				float far80_g20 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g20 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g20 = ( 0.0 );
				float4 positionCS58_g20 = float4( 0,0,0,0 );
				float4 positionNDC58_g20 = float4( 0,0,0,0 );
				float3 positionOS58_g20 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g20 , positionNDC58_g20 , positionOS58_g20 );
				float4 positionNDC80_g20 = positionNDC58_g20;
				ApplySoftParticle( finalColor80_g20 , near80_g20 , far80_g20 , fadeOutRange80_g20 , positionNDC80_g20 );
				float4 break64_g20 = finalColor80_g20;
				float3 appendResult76_g20 = (float3(break64_g20.x , break64_g20.y , break64_g20.z));
				
				float3 Color = appendResult76_g20;
				float Alpha = break64_g20.w;

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
Node;AmplifyShaderEditor.CommentaryNode;596;-4823.496,2705.192;Inherit;False;762;574;Time;7;623;618;617;608;607;606;605;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;597;-4327.496,1841.192;Inherit;False;1397;809;Noise Texture;12;622;616;615;610;604;603;602;601;600;599;598;648;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;607;-4711.496,2881.192;Inherit;False;MMN_Time;-1;;17;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;617;-4743.496,2961.192;Inherit;False;Property;_Noise_Speed;Noise_Speed;19;0;Create;False;0;0;0;False;0;False;0.3,-0.3;0,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;599;-4311.496,1889.192;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;606;-4359.496,2881.192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;618;-4743.496,3089.192;Inherit;False;Property;_Main_Speed;Main_Speed;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;616;-4135.496,2033.192;Inherit;False;Property;_Tiling;MainTex Tiling;15;0;Create;False;0;0;0;True;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;601;-4135.496,1889.192;Inherit;False;World;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;623;-4439.496,2753.192;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;-4375.496,3041.192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;600;-3927.496,1937.192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;605;-4215.496,2753.192;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;622;-4135.496,2177.192;Inherit;False;Constant;_Offset;MainTex Offset;12;0;Create;False;0;0;0;True;0;False;0.7,1.3,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;610;-3991.496,2337.192;Inherit;True;Property;_NoiseTex1;NoiseTex;17;0;Create;False;0;0;0;False;0;False;-1;b9d432b16df585547b51afe19ed41d8a;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;615;-3863.496,2529.192;Inherit;False;Property;_NoisePower1;NoisePower;18;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;598;-3783.496,2161.192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;609;-3799.496,2993.192;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;602;-3623.496,2161.192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-3623.496,2401.192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;648;-3503.978,2102.333;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;535;-3232,1520;Inherit;True;Property;_Mask;Mask;20;0;Create;True;0;0;0;False;1;Space();False;-1;93092410bbc6f4ccba773578db5832d9;93092410bbc6f4ccba773578db5832d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;554;-2896,1840;Inherit;False;1392.282;1330.773;Triplanar Texture;18;657;654;655;656;653;652;651;650;649;584;593;594;592;586;585;583;582;581;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;603;-3463.496,2161.192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;651;-2720,2800;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;663;-2480,1248;Inherit;False;MMN_Time;-1;;19;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;550;-2928,1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-2784,1344;Inherit;False;Constant;_Bound;Bound;23;0;Create;True;0;0;0;False;0;False;-50;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;583;-2720,2144;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FresnelNode;495;-3232,1296;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.4;False;3;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-2320,1248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-10;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;652;-2512,2912;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;582;-2512,2160;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;585;-2512,2256;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;586;-2512,2064;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;536;-2768,1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;653;-2512,2720;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;513;-2608,1520;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;-2320,1408;Inherit;False;Constant;_Speed;Speed;34;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;-2320,1520;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-20;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;650;-2512,2816;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;656;-2352,2544;Inherit;True;Property;_SubTex;SubTex;14;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;46d90612be91b7d45a1f82e9a9e05fde;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;-2464,1328;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;553;-2016,608;Inherit;False;853;393;Fresnel;6;595;591;590;589;588;587;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;-2464,1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;654;-2352,2928;Inherit;True;Property;_MainTex4;MainTex;14;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;656;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;540;-2128,1504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;593;-2352,1888;Inherit;True;Property;_MainTex;MainTex;13;1;[NoScaleOffset];Create;False;0;0;0;False;2;Header(Texture Options);Space();False;-1;f6cf3a29a88091a48aab031f9f6ef590;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-2144,1248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;592;-2352,2272;Inherit;True;Property;_MainTex2;MainTex;13;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;593;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;594;-2352,2080;Inherit;True;Property;_MainTex3;MainTex;13;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;593;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;655;-2352,2736;Inherit;True;Property;_MainTex5;MainTex;14;0;Create;False;0;0;0;False;0;False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;656;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;587;-1952,656;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;588;-1968,816;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;581;-1936,2080;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;444;-1984,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;649;-1936,2736;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;508;-1984,1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;584;-1744,2080;Inherit;False; ;1;File;2;True;normalWS;FLOAT3;0,0,0;In;;Inherit;False;True;triplanarTex;FLOAT3;0,0,0;In;;Inherit;False;Triplanar;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;510;-1712,1472;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;589;-1760,736;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;447;-1712,1248;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;657;-1744,2736;Inherit;False; ;1;File;2;True;normalWS;FLOAT3;0,0,0;In;;Inherit;False;True;triplanarTex;FLOAT3;0,0,0;In;;Inherit;False;Triplanar;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;590;-1632,736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;658;-1408,2080;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;659;-1408,2176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;595;-1488,736;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;660;-1216,2144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;591;-1344,736;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;662;-1088,2144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;620;-847,1856;Inherit;False;Constant;_Mid_Cut;Mid_Cut;18;0;Create;False;0;0;0;False;0;False;1.35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;563;-832,2144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;621;-848,1936;Inherit;False;Constant;_In_Cut;In_Cut;18;0;Create;False;0;0;0;False;0;False;-1;-1.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;578;-656,2144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;564;-464,1760;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;611;-480,1904;Inherit;False;Constant;_Alpha1;Alpha;27;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;-464,1984;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;565;-304,1760;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;619;-848,1776;Inherit;False;Constant;_Out_Cut;Out_Cut;18;0;Create;False;0;0;0;False;2;Header(Cutout);Space();False;-0.21;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;562;-832,2032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;566;-176,1760;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;575;-304,1856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;571;-176,1856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;568;-16,1760;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;577;-304,2096;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;572;144,1760;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;576;-160,2096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;613;736,1728;Inherit;False;Property;_Mid_Color;Mid_Color;22;1;[HDR];Create;False;0;0;0;False;0;False;0,2.251818,6.422235,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;573;96,1984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;612;736,1552;Inherit;False;Property;_In_Color;In_Color;23;1;[HDR];Create;False;0;0;0;False;0;False;0.2901961,0.372549,0.772549,0.6;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;-16,2032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;580;-48,1712;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;569;272,1760;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;976,1744;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;567;144,2032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;561;976,1648;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;559;1136,1728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;614;736,1904;Inherit;False;Property;_Out_Color;Out_Color;21;1;[HDR];Create;False;0;0;0;False;2;Header(Color);Space();False;0.5240962,1.249991,4.385861,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;579;272,2032;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;558;1264,1792;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;557;1504,1872;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;556;1696,1856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;2064,1952;Inherit;False;204;375;Rendering Options;4;79;78;77;552;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;555;1840,1792;Inherit;False;MMN_CommonOutputs;0;;20;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;77;2096,2080;Inherit;False;Property;_BlendDst;Blend Dst;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;2096,2000;Inherit;False;Property;_BlendSrc;Blend Src;25;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;2096,2160;Inherit;False;Property;_CullMode;Cull Mode;27;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;552;2096,2240;Inherit;False;Property;_ZTest;Z Test;24;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;2080,1792;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Debuff_Light;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;606;0;607;0
WireConnection;606;1;617;0
WireConnection;601;0;599;0
WireConnection;608;0;607;0
WireConnection;608;1;618;0
WireConnection;600;0;601;0
WireConnection;600;1;616;0
WireConnection;605;0;623;0
WireConnection;605;1;606;0
WireConnection;610;1;605;0
WireConnection;598;0;600;0
WireConnection;598;1;622;0
WireConnection;609;0;608;0
WireConnection;602;0;598;0
WireConnection;602;1;609;0
WireConnection;604;0;610;2
WireConnection;604;1;615;0
WireConnection;648;0;602;0
WireConnection;603;0;602;0
WireConnection;603;1;604;0
WireConnection;651;0;603;0
WireConnection;550;0;535;2
WireConnection;583;0;648;0
WireConnection;505;0;663;0
WireConnection;652;0;651;0
WireConnection;652;1;651;1
WireConnection;582;0;583;0
WireConnection;582;1;583;2
WireConnection;585;0;583;0
WireConnection;585;1;583;1
WireConnection;586;0;583;2
WireConnection;586;1;583;1
WireConnection;536;0;495;0
WireConnection;536;1;550;0
WireConnection;653;0;651;2
WireConnection;653;1;651;1
WireConnection;513;0;435;0
WireConnection;507;0;663;0
WireConnection;650;0;651;0
WireConnection;650;1;651;2
WireConnection;656;1;653;0
WireConnection;441;0;435;0
WireConnection;441;1;536;0
WireConnection;506;0;536;0
WireConnection;506;1;513;0
WireConnection;654;1;652;0
WireConnection;540;0;539;0
WireConnection;540;1;507;0
WireConnection;593;1;586;0
WireConnection;538;0;505;0
WireConnection;538;1;539;0
WireConnection;592;1;585;0
WireConnection;594;1;582;0
WireConnection;655;1;650;0
WireConnection;581;0;593;1
WireConnection;581;1;594;2
WireConnection;581;2;592;3
WireConnection;444;0;538;0
WireConnection;444;1;441;0
WireConnection;649;0;656;1
WireConnection;649;1;655;2
WireConnection;649;2;654;3
WireConnection;508;0;506;0
WireConnection;508;1;540;0
WireConnection;584;0;588;0
WireConnection;584;1;581;0
WireConnection;510;0;508;0
WireConnection;589;0;587;0
WireConnection;589;1;588;0
WireConnection;447;0;444;0
WireConnection;657;0;588;0
WireConnection;657;1;649;0
WireConnection;590;0;589;0
WireConnection;658;0;447;0
WireConnection;658;1;584;0
WireConnection;659;0;510;0
WireConnection;659;1;657;0
WireConnection;595;0;590;0
WireConnection;660;0;658;0
WireConnection;660;1;659;0
WireConnection;591;0;595;0
WireConnection;662;0;660;0
WireConnection;563;0;591;0
WireConnection;563;1;662;0
WireConnection;578;0;563;0
WireConnection;564;0;620;0
WireConnection;564;1;563;0
WireConnection;574;0;621;0
WireConnection;574;1;578;0
WireConnection;565;0;564;0
WireConnection;565;1;611;0
WireConnection;562;0;591;0
WireConnection;562;1;662;0
WireConnection;566;0;565;0
WireConnection;575;0;611;0
WireConnection;575;1;574;0
WireConnection;571;0;575;0
WireConnection;568;0;566;0
WireConnection;577;0;562;0
WireConnection;577;1;619;0
WireConnection;572;0;568;0
WireConnection;572;1;571;0
WireConnection;576;0;577;0
WireConnection;573;0;611;0
WireConnection;570;0;562;0
WireConnection;570;1;576;0
WireConnection;580;0;566;0
WireConnection;569;0;572;0
WireConnection;560;0;613;0
WireConnection;560;1;569;0
WireConnection;567;0;573;0
WireConnection;567;1;570;0
WireConnection;561;0;612;0
WireConnection;561;1;580;0
WireConnection;559;0;561;0
WireConnection;559;1;560;0
WireConnection;579;0;567;0
WireConnection;558;0;559;0
WireConnection;558;1;614;0
WireConnection;558;2;579;0
WireConnection;557;0;558;0
WireConnection;556;0;557;0
WireConnection;555;9;558;0
WireConnection;555;28;556;0
WireConnection;97;0;555;2
WireConnection;97;1;555;26
ASEEND*/
//CHKSM=61F21F452DA7C437A39CBB953D839426441746AF