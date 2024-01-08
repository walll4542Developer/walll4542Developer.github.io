// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Debuff_Poison"
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
		[KeywordEnum(Base,Advance)] _ShowCase("ShowCase", Float) = 0
		[NoScaleOffset][Header(Texture Options)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Tiling("MainTex Tiling", Vector) = (1,1,1,0)
		_Offset("MainTex Offset", Vector) = (0,0,0,0)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Out_Color("Out_Color", Color) = (1,1,1,1)
		[HDR]_Mid_Color("Mid_Color", Color) = (0.1882353,1.498039,0,1)
		[ASEEnd][HDR]_In_Color("In_Color", Color) = (0.09749338,0.490566,0.0956449,0.2)
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
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma shader_feature_local _SHOWCASE_BASE _SHOWCASE_ADVANCE


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
				float localApplySoftParticle80_g16 = ( 0.0 );
				float localApplyLightColor6_g16 = ( 0.0 );
				float localApplyShadowAtten104_g16 = ( 0.0 );
				half localApplyRaycastingAlpha92_g16 = ( 0.0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float dotResult461 = dot( ase_worldViewDir , normalizedWorldNormal );
				float saferPower464 = abs( saturate( dotResult461 ) );
				float temp_output_465_0 = ( 1.0 - pow( saferPower464 , 1.0 ) );
				float3 normalWS441 = normalizedWorldNormal;
				float3 temp_output_539_0 = input.positionWS;
				float temp_output_548_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float3 break453 = ( ( ( ( temp_output_539_0 * _Tiling ) + _Offset ) + ( temp_output_548_0 * float3(-0.2,-0.2,0) ) ) + ( tex2D( _NoiseTex, ( uv_NoiseTex + ( temp_output_548_0 * float2( 0,0 ) ) ) ).g * 0.05 ) );
				float2 appendResult449 = (float2(break453.z , break453.y));
				float2 appendResult450 = (float2(break453.x , break453.z));
				float2 appendResult451 = (float2(break453.x , break453.y));
				float3 appendResult443 = (float3(tex2D( _MainTex, appendResult449 ).r , tex2D( _MainTex, appendResult450 ).g , tex2D( _MainTex, appendResult451 ).b));
				float3 triplanarTex441 = appendResult443;
				float localTriplanar441 = Triplanar( normalWS441 , triplanarTex441 );
				float temp_output_303_0 = ( temp_output_465_0 + localTriplanar441 );
				float temp_output_304_0 = saturate( ( ( 0.69 - temp_output_303_0 ) * 10.0 ) );
				float temp_output_327_0 = ( 1.0 - temp_output_303_0 );
				float temp_output_355_0 = saturate( ( ( 1.0 - temp_output_304_0 ) - saturate( ( 10.0 * ( -3.81 + temp_output_327_0 ) ) ) ) );
				#if defined(_SHOWCASE_BASE)
				float staticSwitch521 = temp_output_304_0;
				#elif defined(_SHOWCASE_ADVANCE)
				float staticSwitch521 = temp_output_355_0;
				#else
				float staticSwitch521 = temp_output_304_0;
				#endif
				#if defined(_SHOWCASE_BASE)
				float staticSwitch519 = temp_output_355_0;
				#elif defined(_SHOWCASE_ADVANCE)
				float staticSwitch519 = temp_output_327_0;
				#else
				float staticSwitch519 = temp_output_355_0;
				#endif
				float temp_output_371_0 = ( temp_output_465_0 * localTriplanar441 );
				float4 lerpResult376 = lerp( ( ( _In_Color * staticSwitch521 ) + ( _Mid_Color * staticSwitch519 ) ) , _Out_Color , saturate( ( 10.0 * ( temp_output_371_0 * saturate( ( temp_output_371_0 - 5.63 ) ) ) ) ));
				float4 appendResult32_g16 = (float4(lerpResult376.rgb , saturate( (lerpResult376).a )));
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
Node;AmplifyShaderEditor.CommentaryNode;534;-3600,-608;Inherit;False;1040.284;813.069;Noise Texture;11;539;536;542;543;551;544;540;538;537;535;541;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;533;-4112,256;Inherit;False;762;574;Time;7;553;552;549;548;547;546;545;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;537;-3584,-576;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;548;-3984,432;Inherit;False;MMN_Time;-1;;15;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;552;-4016,512;Inherit;False;Constant;_Noise_Speed;Noise_Speed;15;0;Create;False;0;0;0;False;0;False;0,0;-0.26,0.14;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TransformPositionNode;539;-3408,-560;Inherit;False;World;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;547;-3632,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;553;-4016,640;Inherit;False;Constant;_Main_Speed;Main_Speed;13;0;Create;True;0;0;0;False;0;False;-0.2,-0.2,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;546;-3712,304;Inherit;False;0;543;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;542;-3408,-416;Inherit;False;Property;_Tiling;MainTex Tiling;15;0;Create;False;0;0;0;True;0;False;1,1,1;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;549;-3648,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;545;-3488,304;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;538;-3200,-512;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;536;-3408,-272;Inherit;False;Property;_Offset;MainTex Offset;16;0;Create;False;0;0;0;True;0;False;0,0,0;1,1,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;550;-3072,528;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;543;-3264,-112;Inherit;True;Property;_NoiseTex;NoiseTex;17;0;Create;False;0;0;0;False;0;False;-1;b9d432b16df585547b51afe19ed41d8a;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;535;-3056,-288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;551;-3136,80;Inherit;False;Constant;_NoisePower1;NoisePower;15;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;-2896,-48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;540;-2896,-288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;541;-2736,-288;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;471;-2544,-592;Inherit;False;1399;664;Triplanar Texture;9;443;444;442;449;450;445;451;453;441;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;446;-1600,-832;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;463;-1584,-992;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;453;-2368,-288;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;461;-1392,-912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;449;-2160,-368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;451;-2160,-176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;450;-2160,-272;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;444;-2000,-352;Inherit;True;Property;_MainTex1;MainTex;14;0;Create;False;0;0;0;False;0;False;442;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;442;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;445;-2000,-160;Inherit;True;Property;_MainTex2;MainTex;14;0;Create;False;0;0;0;False;0;False;442;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Instance;442;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;442;-2000,-544;Inherit;True;Property;_MainTex;MainTex;14;1;[NoScaleOffset];Create;False;0;0;0;False;2;Header(Texture Options);Space();False;-1;efdfc3fcb1d5f3946876e04644dc90a2;b9d432b16df585547b51afe19ed41d8a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;466;-1264,-912;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;464;-1120,-912;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;443;-1584,-352;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;465;-976,-912;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;441;-1392,-352;Inherit;False; ;1;File;2;True;normalWS;FLOAT3;0,0,0;In;;Inherit;False;True;triplanarTex;FLOAT3;0,0,0;In;;Inherit;False;Triplanar;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-480,-560;Inherit;False;Constant;_Mid_Cut;Mid_Cut;20;0;Create;True;0;0;0;False;0;False;0.69;-0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;303;-464,-272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;208;-112,-512;Inherit;False;Constant;_Alpha;Alpha;24;0;Create;True;0;0;0;False;0;False;10;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-480,-640;Inherit;False;Constant;_In_Cut;In_Cut;21;0;Create;True;0;0;0;False;0;False;-3.81;-0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;332;-96,-656;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;327;-288,-272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;215;64,-656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;328;-96,-432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;64,-560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;6.72;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;304;192,-656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;380;-480,-480;Inherit;False;Constant;_Out_Cut;Out_Cut;19;0;Create;True;0;0;0;False;2;Header(Cutout);Space();False;5.63;-0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;349;352,-656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;330;192,-560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;371;-464,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;350;512,-656;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;423;60,-320;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;374;204,-320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;355;640,-656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;512;317,-692;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;352,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;519;800,-656;Inherit;False;Property;_ShowCase;ShowCase;13;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Base;Advance;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;521;800,-752;Inherit;False;Property;_Poison1;Poison;13;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Base;Advance;Reference;519;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;200;1104,-864;Inherit;False;Property;_In_Color;In_Color;20;1;[HDR];Create;True;0;0;0;False;0;False;0.09749338,0.490566,0.0956449,0.2;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;181;1104,-688;Inherit;False;Property;_Mid_Color;Mid_Color;19;1;[HDR];Create;True;0;0;0;False;0;False;0.1882353,1.498039,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;428;467,-421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;343;1344,-672;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;375;512,-384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;1344,-768;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;379;640,-384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;345;1504,-688;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;378;1104,-512;Inherit;False;Property;_Out_Color;Out_Color;18;1;[HDR];Create;True;0;0;0;False;2;Header(Color);Space();False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;376;1632,-624;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;422;1872,-544;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;417;2064,-545;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;76;2656,-624;Inherit;False;204;375;Rendering Options;4;79;78;77;424;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;119;2208,-624;Inherit;False;MMN_CommonOutputs;0;;16;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;79;2688,-416;Inherit;False;Property;_CullMode;Cull Mode;23;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;424;2704,-336;Inherit;False;Property;_ZTest;Z Test;24;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;2688,-576;Inherit;False;Property;_BlendSrc;Blend Src;21;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;2688,-496;Inherit;False;Property;_BlendDst;Blend Dst;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;2464,-624;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Debuff_Poison;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;539;0;537;0
WireConnection;547;0;548;0
WireConnection;547;1;552;0
WireConnection;549;0;548;0
WireConnection;549;1;553;0
WireConnection;545;0;546;0
WireConnection;545;1;547;0
WireConnection;538;0;539;0
WireConnection;538;1;542;0
WireConnection;550;0;549;0
WireConnection;543;1;545;0
WireConnection;535;0;538;0
WireConnection;535;1;536;0
WireConnection;544;0;543;2
WireConnection;544;1;551;0
WireConnection;540;0;535;0
WireConnection;540;1;550;0
WireConnection;541;0;540;0
WireConnection;541;1;544;0
WireConnection;453;0;541;0
WireConnection;461;0;463;0
WireConnection;461;1;446;0
WireConnection;449;0;453;2
WireConnection;449;1;453;1
WireConnection;451;0;453;0
WireConnection;451;1;453;1
WireConnection;450;0;453;0
WireConnection;450;1;453;2
WireConnection;444;1;450;0
WireConnection;445;1;451;0
WireConnection;442;1;449;0
WireConnection;466;0;461;0
WireConnection;464;0;466;0
WireConnection;443;0;442;1
WireConnection;443;1;444;2
WireConnection;443;2;445;3
WireConnection;465;0;464;0
WireConnection;441;0;446;0
WireConnection;441;1;443;0
WireConnection;303;0;465;0
WireConnection;303;1;441;0
WireConnection;332;0;217;0
WireConnection;332;1;303;0
WireConnection;327;0;303;0
WireConnection;215;0;332;0
WireConnection;215;1;208;0
WireConnection;328;0;329;0
WireConnection;328;1;327;0
WireConnection;331;0;208;0
WireConnection;331;1;328;0
WireConnection;304;0;215;0
WireConnection;349;0;304;0
WireConnection;330;0;331;0
WireConnection;371;0;465;0
WireConnection;371;1;441;0
WireConnection;350;0;349;0
WireConnection;350;1;330;0
WireConnection;423;0;371;0
WireConnection;423;1;380;0
WireConnection;374;0;423;0
WireConnection;355;0;350;0
WireConnection;512;0;304;0
WireConnection;372;0;371;0
WireConnection;372;1;374;0
WireConnection;519;1;355;0
WireConnection;519;0;327;0
WireConnection;521;1;512;0
WireConnection;521;0;355;0
WireConnection;428;0;208;0
WireConnection;343;0;181;0
WireConnection;343;1;519;0
WireConnection;375;0;428;0
WireConnection;375;1;372;0
WireConnection;344;0;200;0
WireConnection;344;1;521;0
WireConnection;379;0;375;0
WireConnection;345;0;344;0
WireConnection;345;1;343;0
WireConnection;376;0;345;0
WireConnection;376;1;378;0
WireConnection;376;2;379;0
WireConnection;422;0;376;0
WireConnection;417;0;422;0
WireConnection;119;9;376;0
WireConnection;119;28;417;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
ASEEND*/
//CHKSM=1F2538B28C1D68A7429676CE1CA1976B3A85B677