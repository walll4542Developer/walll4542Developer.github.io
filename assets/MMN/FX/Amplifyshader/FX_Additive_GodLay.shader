// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/Environment/Additive_GodLay"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_GodlayTex("Godlay Texture", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 10)) = 1
		_Speed("Speed", Range( 0 , 3)) = 0.3
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_Intensive("Intensive", Range( 0 , 1)) = 0.3
		_Float0("부드러운 높이 조절", Range( 1 , 10)) = 2
		[Toggle][Space()][Header(Night Setting)][Space()]_NightToggle("밤 세팅 적용", Float) = 0
		[HDR]_Color_Night("Color_Night", Color) = (1,1,1,1)
		_Intensive_Night("Intensive_Night", Range( 0 , 1)) = 0.3
		_Float1("부드러운 높이 조절_밤", Range( 1 , 10)) = 2
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
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
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 0

	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent+100" }

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


			sampler2D _GodlayTex;
			float _Global_Night2Day;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color_Night;
			float4 _Color;
			float _LightRatio;
			float _Float1;
			float _Float0;
			float _Intensive;
			float _Softness;
			float _Intensive_Night;
			float _Speed;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _NearPlaneAlpha;
			float _NightToggle;
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
				float localApplySoftParticle80_g13 = ( 0.0 );
				float localApplyLightColor6_g13 = ( 0.0 );
				float localApplyShadowAtten104_g13 = ( 0.0 );
				half localApplyRaycastingAlpha92_g13 = ( 0.0 );
				float2 texCoord11 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_83_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 appendResult24 = (float2(( texCoord11.x + ( temp_output_83_0 * _Speed ) ) , texCoord11.y));
				float2 appendResult19 = (float2(( texCoord11.x + ( ( temp_output_83_0 * 0.0 ) * _Speed ) ) , texCoord11.y));
				float2 appendResult20 = (float2(( texCoord11.x + ( ( temp_output_83_0 * 0.1 ) * _Speed ) ) , texCoord11.y));
				float3 normalizeResult22 = normalize( ( _WorldSpaceCameraPos - input.positionWS ) );
				float dotResult27 = dot( input.normalWS , normalizeResult22 );
				float saferPower31 = abs( dotResult27 );
				float4 lerpResult77 = lerp( ( _Intensive * _Color * saturate( ( input.positionOS.xyz.y / _Float0 ) ) ) , ( saturate( ( input.positionOS.xyz.y / _Float1 ) ) * _Color_Night * _Intensive_Night ) , ( ( 1.0 - saturate( _Global_Night2Day ) ) * _NightToggle ));
				float4 appendResult32_g13 = (float4(( tex2D( _GodlayTex, appendResult24 ).r * tex2D( _GodlayTex, appendResult19 ).g * tex2D( _GodlayTex, appendResult20 ).b * saturate( pow( saferPower31 , _Softness ) ) * lerpResult77 ).rgb , 1.0));
				half4 finalColor92_g13 = appendResult32_g13;
				half3 positionWS92_g13 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g13 = ase_screenPosNorm;
				half4 screenPos92_g13 = ase_screenPosNorm;
				half nearPlane92_g13 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g13 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g13 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g13 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g13 , positionWS92_g13 , screenUV92_g13 , screenPos92_g13 , nearPlane92_g13 , nearPlaneInvertDistance92_g13 , raycastHarftoneClip92_g13 , raycastMinimumAlpha92_g13 );
				float4 finalColor104_g13 = finalColor92_g13;
				float4 shadowCoord104_g13 = input.uv0;
				float3 positionWS104_g13 = input.positionWS;
				float lightRatio104_g13 = _LightRatio;
				ApplyShadowAtten( finalColor104_g13 , shadowCoord104_g13 , positionWS104_g13 , lightRatio104_g13 );
				float4 finalColor6_g13 = finalColor104_g13;
				float3 normalWS6_g13 = input.normalWS;
				float lightRatio6_g13 = _LightRatio;
				ApplyLightColor( finalColor6_g13 , normalWS6_g13 , lightRatio6_g13 );
				float4 finalColor80_g13 = finalColor6_g13;
				float near80_g13 = _SoftParticleNearFadeDistance;
				float far80_g13 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g13 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g13 = ( 0.0 );
				float4 positionCS58_g13 = float4( 0,0,0,0 );
				float4 positionNDC58_g13 = float4( 0,0,0,0 );
				float3 positionOS58_g13 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g13 , positionNDC58_g13 , positionOS58_g13 );
				float4 positionNDC80_g13 = positionNDC58_g13;
				ApplySoftParticle( finalColor80_g13 , near80_g13 , far80_g13 , fadeOutRange80_g13 , positionNDC80_g13 );
				float4 break64_g13 = finalColor80_g13;
				float3 appendResult76_g13 = (float3(break64_g13.x , break64_g13.y , break64_g13.z));
				
				float3 Color = appendResult76_g13;
				float Alpha = break64_g13.w;

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
Node;AmplifyShaderEditor.CommentaryNode;2;-2256,-1312;Inherit;False;564;393;Time;6;14;13;10;8;7;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-1952,-400;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;83;-2208,-1152;Inherit;False;MMN_Time;-1;;12;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-2069.127,-171.3704;Inherit;False;1400;1062;DayNight Color;19;56;67;59;62;70;61;30;35;71;51;73;77;76;78;80;69;72;74;82;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;12;-2016,-544;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;67;-1695,292;Inherit;False;Global;_Global_Night2Day;_Global_Night2Day;3;0;Create;False;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;5;-1632,-1312;Inherit;False;604.3411;377;Comment;7;24;20;19;18;16;15;11;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2019.127,166.6297;Inherit;False;Property;_Float0;부드러운 높이 조절;5;0;Create;False;0;0;0;True;0;False;2;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;59;-1955.127,294.6296;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-2000,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2019.127,486.6296;Inherit;False;Property;_Float1;부드러운 높이 조절_밤;9;0;Create;False;0;0;0;True;0;False;2;1;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-2000,-1056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2208,-1264;Inherit;False;Property;_Speed;Speed;2;0;Create;True;0;0;0;False;0;False;0.3;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-1728,-416;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;21;-1952,-688;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1584,-1168;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;80;-1488,288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;70;-1715.127,486.6296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1856,-1056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1856,-1248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1856,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;22;-1584,-416;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;62;-1715.127,166.6297;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1715.127,774.6296;Inherit;False;Property;_Intensive_Night;Intensive_Night;8;0;Create;True;0;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;72;-1651.127,582.6296;Inherit;False;Property;_Color_Night;Color_Night;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;71;-1587.127,486.6296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;82;-1360,288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1650.127,378.6296;Inherit;False;Property;_NightToggle;밤 세팅 적용;6;1;[Toggle];Create;False;0;0;0;False;3;Space();Header(Night Setting);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1360,-1072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-1651.127,-25.3704;Inherit;False;Property;_Color;Color;3;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;27;-1440,-512;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1296,-432;Inherit;False;Property;_Softness;Softness;1;0;Create;True;0;0;0;False;0;False;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;61;-1587.127,166.6297;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-1360,-1168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1360,-1264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1715.127,-121.3704;Inherit;False;Property;_Intensive;Intensive;4;0;Create;False;0;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-1200,-1264;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1331.126,-57.37038;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1331.126,486.6296;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1207,290;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;31;-992,-512;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-1200,-1072;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-1200,-1168;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;25;-944,-1360;Inherit;True;Property;_GodlayTex;Godlay Texture;0;0;Create;False;0;0;0;False;0;False;25;e577963ff47b6434bba5b2b8e2e2f23d;e577963ff47b6434bba5b2b8e2e2f23d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-944,-976;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;25;None;None;True;0;False;white;Auto;False;Instance;25;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;77;-832,288;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;34;-832,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-944,-1168;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;25;None;None;True;0;False;white;Auto;False;Instance;25;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;45;32,-912;Inherit;False;204;375;Rendering Options;4;49;47;46;84;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-368,-1120;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-368,-928;Inherit;False;Constant;_Alpha;Alpha;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;64,-864;Inherit;False;Property;_BlendSrc;Blend Src;10;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;64,-784;Inherit;False;Property;_BlendDst;Blend Dst;11;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;64,-624;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;64,-704;Inherit;False;Property;_CullMode;Cull Mode;12;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;39;-224,-1072;Inherit;False;MMN_CommonOutputs;13;;13;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;32,-1072;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/Environment/Additive_GodLay;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=100;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;6;0;83;0
WireConnection;8;0;83;0
WireConnection;17;0;12;0
WireConnection;17;1;9;0
WireConnection;80;0;67;0
WireConnection;70;0;59;2
WireConnection;70;1;74;0
WireConnection;10;0;8;0
WireConnection;10;1;7;0
WireConnection;13;0;83;0
WireConnection;13;1;7;0
WireConnection;14;0;6;0
WireConnection;14;1;7;0
WireConnection;22;0;17;0
WireConnection;62;0;59;2
WireConnection;62;1;56;0
WireConnection;71;0;70;0
WireConnection;82;0;80;0
WireConnection;16;0;11;1
WireConnection;16;1;10;0
WireConnection;27;0;21;0
WireConnection;27;1;22;0
WireConnection;61;0;62;0
WireConnection;15;0;11;1
WireConnection;15;1;14;0
WireConnection;18;0;11;1
WireConnection;18;1;13;0
WireConnection;24;0;18;0
WireConnection;24;1;11;2
WireConnection;51;0;30;0
WireConnection;51;1;35;0
WireConnection;51;2;61;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;73;2;69;0
WireConnection;78;0;82;0
WireConnection;78;1;76;0
WireConnection;31;0;27;0
WireConnection;31;1;26;0
WireConnection;20;0;16;0
WireConnection;20;1;11;2
WireConnection;19;0;15;0
WireConnection;19;1;11;2
WireConnection;25;1;24;0
WireConnection;28;1;20;0
WireConnection;77;0;51;0
WireConnection;77;1;73;0
WireConnection;77;2;78;0
WireConnection;34;0;31;0
WireConnection;29;1;19;0
WireConnection;32;0;25;1
WireConnection;32;1;29;2
WireConnection;32;2;28;3
WireConnection;32;3;34;0
WireConnection;32;4;77;0
WireConnection;39;9;32;0
WireConnection;39;28;37;0
WireConnection;1;0;39;2
WireConnection;1;1;39;26
ASEEND*/
//CHKSM=03F2C03B3B8CCAE8F4B1759A109E2C50941B20EA