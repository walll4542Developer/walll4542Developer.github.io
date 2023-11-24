// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/Stencil/FX_Dissolve_Sub_Panning_Stencil"
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
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[Header(Stencil Options)][Space()]_StencilRef("Stencil Ref", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comp", Float) = 8
		[ASEEnd][Enum(UnityEngine.Rendering.StencilOp)]_StencilPass("Stencil Pass", Float) = 2
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
			Stencil
			{
				Ref [_StencilRef]
				Comp [_StencilComp]
				Pass [_StencilPass]
				Fail Keep
				ZFail Keep
			}

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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
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
			float _Use_G_Channel_Alpha;
			float _Noise_Y_Speed;
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
				float localApplySoftParticle80_g7 = ( 0.0 );
				float localApplyLightColor6_g7 = ( 0.0 );
				float localApplyShadowAtten104_g7 = ( 0.0 );
				half localApplyRaycastingAlpha92_g7 = ( 0.0 );
				float4 break92 = ( _Intensity_Color * input.ase_color );
				float3 appendResult93 = (float3(break92.r , break92.g , break92.b));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float lerpResult100 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float2 appendResult52 = (float2(0.0 , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + uv_NoiseTex);
				float4 appendResult32_g7 = (float4(appendResult93 , ( input.ase_color.a * saturate( ( ( ( lerpResult100 * tex2D( _NoiseTex, panner49 ).g ) - input.uv0.z ) * _Intensity_Alpha ) ) )));
				half4 finalColor92_g7 = appendResult32_g7;
				half3 positionWS92_g7 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g7 = ase_screenPosNorm;
				half4 screenPos92_g7 = ase_screenPosNorm;
				half nearPlane92_g7 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g7 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g7 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g7 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g7 , positionWS92_g7 , screenUV92_g7 , screenPos92_g7 , nearPlane92_g7 , nearPlaneInvertDistance92_g7 , raycastHarftoneClip92_g7 , raycastMinimumAlpha92_g7 );
				float4 finalColor104_g7 = finalColor92_g7;
				float4 shadowCoord104_g7 = input.uv0;
				float3 positionWS104_g7 = input.positionWS;
				float lightRatio104_g7 = _LightRatio;
				ApplyShadowAtten( finalColor104_g7 , shadowCoord104_g7 , positionWS104_g7 , lightRatio104_g7 );
				float4 finalColor6_g7 = finalColor104_g7;
				float3 normalWS6_g7 = input.normalWS;
				float lightRatio6_g7 = _LightRatio;
				ApplyLightColor( finalColor6_g7 , normalWS6_g7 , lightRatio6_g7 );
				float4 finalColor80_g7 = finalColor6_g7;
				float near80_g7 = _SoftParticleNearFadeDistance;
				float far80_g7 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g7 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g7 = ( 0.0 );
				float4 positionCS58_g7 = float4( 0,0,0,0 );
				float4 positionNDC58_g7 = float4( 0,0,0,0 );
				float3 positionOS58_g7 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g7 , positionNDC58_g7 , positionOS58_g7 );
				float4 positionNDC80_g7 = positionNDC58_g7;
				ApplySoftParticle( finalColor80_g7 , near80_g7 , far80_g7 , fadeOutRange80_g7 , positionNDC80_g7 );
				float4 break64_g7 = finalColor80_g7;
				float3 appendResult76_g7 = (float3(break64_g7.x , break64_g7.y , break64_g7.z));
				
				float3 Color = appendResult76_g7;
				float Alpha = break64_g7.w;

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
Node;AmplifyShaderEditor.RangedFloatNode;51;-2064,176;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-1204.812,-259.0065;Inherit;False;257.6497;262.7989;Switch;2;101;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1728,-256;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;95;-1861.907,221.8284;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-2016,-32;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;52;-1888,96;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-1504,-256;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;101;-1184,-81.00648;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;49;-1696,-32;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-1504,-32;Inherit;True;Property;_NoiseTex;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;100;-1104,-209.0065;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-928,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-992,112;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-704,0;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-691,104;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;18;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;65;-348.6075,-194.0215;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-348.6075,-290.0215;Inherit;False;Property;_Intensity_Color;Intensity_Color;17;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-140.6075,-210.0215;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-502,-7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;92;17.62079,-258.6134;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;44;-323,-8;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;590,20;Inherit;False;204;375;Rendering Options;4;55;62;63;103;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;134.8481,-257.9211;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;96;813,26;Inherit;False;185;296;Stencil Options;3;99;98;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-147,-8;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;829,234;Inherit;False;Property;_StencilPass;Stencil Pass;21;1;[Enum];Fetch;True;0;1;Option1;0;1;UnityEngine.Rendering.StencilOp;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;829,154;Inherit;False;Property;_StencilComp;Stencil Comp;20;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;8;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;829,74;Inherit;False;Property;_StencilRef;Stencil Ref;19;0;Fetch;True;0;0;0;True;2;Header(Stencil Options);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;622,148;Inherit;False;Property;_BlendDst;Blend Dst;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;622,228;Inherit;False;Property;_CullMode;Cull Mode;24;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;91;332.7378,-127.998;Inherit;False;MMN_CommonOutputs;0;;7;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;62;622,68;Inherit;False;Property;_BlendSrc;Blend Src;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;624,304;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;94;587.4782,-126.4749;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/Stencil/FX_Dissolve_Sub_Panning_Stencil;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;True;255;True;_StencilRef;255;False;;255;False;;7;True;_StencilComp;1;True;_StencilPass;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;0;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;52;1;51;0
WireConnection;5;1;6;0
WireConnection;49;0;47;0
WireConnection;49;2;52;0
WireConnection;49;1;95;0
WireConnection;48;1;49;0
WireConnection;100;0;5;4
WireConnection;100;1;5;2
WireConnection;100;2;101;0
WireConnection;54;0;100;0
WireConnection;54;1;48;2
WireConnection;22;0;54;0
WireConnection;22;1;24;3
WireConnection;61;0;60;0
WireConnection;61;1;65;0
WireConnection;41;0;22;0
WireConnection;41;1;42;0
WireConnection;92;0;61;0
WireConnection;44;0;41;0
WireConnection;93;0;92;0
WireConnection;93;1;92;1
WireConnection;93;2;92;2
WireConnection;66;0;65;4
WireConnection;66;1;44;0
WireConnection;91;9;93;0
WireConnection;91;28;66;0
WireConnection;94;0;91;2
WireConnection;94;1;91;26
ASEEND*/
//CHKSM=970F5CDF3397694E6D1023BCE00968BFFE9D79EE