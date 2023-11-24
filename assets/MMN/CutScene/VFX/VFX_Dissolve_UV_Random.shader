// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/CutScene/VFX/VFX_Dissolve_UV_Randam"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(tcd0.U   Dissolve)][Header(tcd0.Z   X_Offset)][Header(tcd0.W   Y_Offset)][Space()]_MainTex("MainTex", 2D) = "white" {}
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
		[HDR]_MainColor("Main Color", Color) = (1,1,1,1)
		_Intensity_Color("Intensity_Color", Float) = 0
		_NoiseTex("NoiseTex", 2D) = "white" {}
		[ASEEnd][Toggle(_USE_G_CHANNEL_ALPHA_ON)] _Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(Default,2,Always,6)]_ZTest("Z Test", Float) = 2

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

			#include "../../FX/Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma multi_compile_local __ _USE_G_CHANNEL_ALPHA_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Intensity_Color;
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

				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord4 = screenPos;
				
				output.ase_color = input.color;
				output.ase_texcoord3 = input.ase_texcoord1;
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
				float localApplySoftParticle80_g4 = ( 0.0 );
				float localApplyLightColor6_g4 = ( 0.0 );
				float localApplyShadowAtten104_g4 = ( 0.0 );
				half localApplyRaycastingAlpha92_g4 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode9 = tex2D( _MainTex, uv_MainTex );
				#ifdef _USE_G_CHANNEL_ALPHA_ON
				float staticSwitch29 = tex2DNode9.g;
				#else
				float staticSwitch29 = tex2DNode9.a;
				#endif
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult13 = (float2(( uv_NoiseTex.x + input.ase_texcoord3.z ) , ( uv_NoiseTex.y + input.ase_texcoord3.w )));
				float4 appendResult32_g4 = (float4(( _Intensity_Color * ( input.ase_color * ( _MainColor * tex2DNode9 ) ) ).rgb , saturate( ( input.ase_color.a * ( staticSwitch29 * saturate( step( 0.1 , ( tex2D( _NoiseTex, appendResult13 ).r + input.ase_texcoord3.x ) ) ) ) ) )));
				half4 finalColor92_g4 = appendResult32_g4;
				half3 positionWS92_g4 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g4 = ase_screenPosNorm;
				half4 screenPos92_g4 = ase_screenPosNorm;
				half nearPlane92_g4 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g4 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g4 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g4 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g4 , positionWS92_g4 , screenUV92_g4 , screenPos92_g4 , nearPlane92_g4 , nearPlaneInvertDistance92_g4 , raycastHarftoneClip92_g4 , raycastMinimumAlpha92_g4 );
				float4 finalColor104_g4 = finalColor92_g4;
				float4 shadowCoord104_g4 = input.uv0;
				float3 positionWS104_g4 = input.positionWS;
				float lightRatio104_g4 = _LightRatio;
				ApplyShadowAtten( finalColor104_g4 , shadowCoord104_g4 , positionWS104_g4 , lightRatio104_g4 );
				float4 finalColor6_g4 = finalColor104_g4;
				float3 normalWS6_g4 = input.normalWS;
				float lightRatio6_g4 = _LightRatio;
				ApplyLightColor( finalColor6_g4 , normalWS6_g4 , lightRatio6_g4 );
				float4 finalColor80_g4 = finalColor6_g4;
				float near80_g4 = _SoftParticleNearFadeDistance;
				float far80_g4 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g4 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g4 = ( 0.0 );
				float4 positionCS58_g4 = float4( 0,0,0,0 );
				float4 positionNDC58_g4 = float4( 0,0,0,0 );
				float3 positionOS58_g4 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g4 , positionNDC58_g4 , positionOS58_g4 );
				float4 positionNDC80_g4 = positionNDC58_g4;
				ApplySoftParticle( finalColor80_g4 , near80_g4 , far80_g4 , fadeOutRange80_g4 , positionNDC80_g4 );
				float4 break64_g4 = finalColor80_g4;
				float3 appendResult76_g4 = (float3(break64_g4.x , break64_g4.y , break64_g4.z));
				
				float3 Color = appendResult76_g4;
				float Alpha = break64_g4.w;

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
	
	Fallback "Off"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.TexCoordVertexDataNode;18;-1373,76.5;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-988,-11.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-978,-129.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-827,-86.5;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-677,-113.5;Inherit;True;Property;_NoiseTex;NoiseTex;16;0;Create;True;0;0;0;False;0;False;-1;None;d837d530b5931a647abf5aa9974b95c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-308.8058,-80.24365;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-275.8057,-169.2437;Inherit;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-660,-462.5;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;4;Header(tcd0.U   Dissolve);Header(tcd0.Z   X_Offset);Header(tcd0.W   Y_Offset);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;27;-97.80566,-149.2437;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;13.19434,-247.2437;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-296.8057,-403.2437;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;0;Create;True;0;0;0;False;0;False;1;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;-224.8057,-773.2437;Inherit;False;Property;_MainColor;Main Color;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;78.19421,-538.2437;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;21;154.1942,-724.2437;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;173.1943,-391.2437;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;513.1942,-614.2437;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;35;523.1943,-721.2437;Inherit;False;Property;_Intensity_Color;Intensity_Color;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;507.1942,-389.2437;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;696.1943,-505.2437;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;33;655.1943,-345.2437;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;3;1280,-208;Inherit;False;204;375;Rendering Options;4;7;6;5;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;4;1312,-160;Inherit;False;Property;_BlendSrc;Blend Src;18;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2;845,-331.5;Inherit;False;MMN_CommonOutputs;1;;4;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;5;1312,80;Inherit;False;Property;_ZTest;Z Test;21;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;1312,0;Inherit;False;Property;_CullMode;Cull Mode;20;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;1312,-80;Inherit;False;Property;_BlendDst;Blend Dst;19;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1288,-362;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/CutScene/VFX/VFX_Dissolve_UV_Randam;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-1036,-470.5;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1324,-229.5;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;17;0;11;2
WireConnection;17;1;18;4
WireConnection;16;0;11;1
WireConnection;16;1;18;3
WireConnection;13;0;16;0
WireConnection;13;1;17;0
WireConnection;10;1;13;0
WireConnection;19;0;10;1
WireConnection;19;1;18;1
WireConnection;9;1;12;0
WireConnection;27;0;28;0
WireConnection;27;1;19;0
WireConnection;32;0;27;0
WireConnection;29;1;9;4
WireConnection;29;0;9;2
WireConnection;22;0;31;0
WireConnection;22;1;9;0
WireConnection;26;0;29;0
WireConnection;26;1;32;0
WireConnection;24;0;21;0
WireConnection;24;1;22;0
WireConnection;23;0;21;4
WireConnection;23;1;26;0
WireConnection;34;0;35;0
WireConnection;34;1;24;0
WireConnection;33;0;23;0
WireConnection;2;9;34;0
WireConnection;2;28;33;0
WireConnection;1;0;2;2
WireConnection;1;1;2;26
ASEEND*/
//CHKSM=9458A19C5AEBC4A37F265E340AFFD66A7F8666F6