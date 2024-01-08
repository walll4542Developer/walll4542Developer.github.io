// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/MUD_Hand_Flipbook_Noise"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(tcd0.z     NoisePower)][Header(tcd0.w     ColorRange)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Normal][Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "bump" {}
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Clip("Clip", Float) = 0
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
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 0



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

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
			CBUFFER_START( UnityPerMaterial )
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Intensity_Color;
			float _Clip;
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
				float localApplySoftParticle80_g1 = ( 0.0 );
				float localApplyLightColor6_g1 = ( 0.0 );
				float localApplyShadowAtten104_g1 = ( 0.0 );
				half localApplyRaycastingAlpha92_g1 = ( 0.0 );
				float2 texCoord35 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner30 = ( 1.0 * _Time.y * float2( 0,0.5 ) + float2( 0,0 ));
				float3 tex2DNode29 = UnpackNormalScale( tex2D( _NoiseTex, panner30 ), 1.0f );
				float2 appendResult36 = (float2(tex2DNode29.r , tex2DNode29.g));
				float4 tex2DNode12 = tex2D( _MainTex, ( texCoord35 + ( appendResult36 * input.uv0.z ) ) );
				float saferPower52 = abs( tex2DNode12.g );
				float temp_output_34_0 = ( input.ase_color.a * ( tex2DNode12.b * tex2DNode12.a ) );
				clip( temp_output_34_0 - _Clip);
				float4 appendResult32_g1 = (float4(( ( ( tex2DNode12.r + pow( saferPower52 , input.uv0.w ) ) * _Intensity_Color ) * tex2DNode12.a * input.ase_color ).rgb , temp_output_34_0));
				half4 finalColor92_g1 = appendResult32_g1;
				half3 positionWS92_g1 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g1 = ase_screenPosNorm;
				half4 screenPos92_g1 = ase_screenPosNorm;
				half nearPlane92_g1 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g1 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g1 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g1 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g1 , positionWS92_g1 , screenUV92_g1 , screenPos92_g1 , nearPlane92_g1 , nearPlaneInvertDistance92_g1 , raycastHarftoneClip92_g1 , raycastMinimumAlpha92_g1 );
				float4 finalColor104_g1 = finalColor92_g1;
				float4 shadowCoord104_g1 = input.uv0;
				float3 positionWS104_g1 = input.positionWS;
				float lightRatio104_g1 = _LightRatio;
				ApplyShadowAtten( finalColor104_g1 , shadowCoord104_g1 , positionWS104_g1 , lightRatio104_g1 );
				float4 finalColor6_g1 = finalColor104_g1;
				float3 normalWS6_g1 = input.normalWS;
				float lightRatio6_g1 = _LightRatio;
				ApplyLightColor( finalColor6_g1 , normalWS6_g1 , lightRatio6_g1 );
				float4 finalColor80_g1 = finalColor6_g1;
				float near80_g1 = _SoftParticleNearFadeDistance;
				float far80_g1 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g1 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g1 = ( 0.0 );
				float4 positionCS58_g1 = float4( 0,0,0,0 );
				float4 positionNDC58_g1 = float4( 0,0,0,0 );
				float3 positionOS58_g1 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g1 , positionNDC58_g1 , positionOS58_g1 );
				float4 positionNDC80_g1 = positionNDC58_g1;
				ApplySoftParticle( finalColor80_g1 , near80_g1 , far80_g1 , fadeOutRange80_g1 , positionNDC80_g1 );
				float4 break64_g1 = finalColor80_g1;
				float3 appendResult76_g1 = (float3(break64_g1.x , break64_g1.y , break64_g1.z));

				float3 Color = appendResult76_g1;
				float Alpha = break64_g1.w;

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
Version=19200
Node;AmplifyShaderEditor.PannerNode;30;-1487.34,157.405;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;29;-1294.532,130.5881;Inherit;True;Property;_NoiseTex;NoiseTex;1;1;[Normal];Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;b78d342a61a8e424780022b2cf160349;b78d342a61a8e424780022b2cf160349;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;36;-909.5728,83.34962;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;28;-946.1104,234.1297;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-691.2625,64.39835;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-947.4033,-54.89064;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-508.0962,-51.06405;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-283.3139,-80.19495;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;4;Header(tcd0.z     NoisePower);Header(tcd0.w     ColorRange);Header(Main Texture);Space();False;-1;d632ec61c5a22c846addc220caaa924f;d632ec61c5a22c846addc220caaa924f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;55;-170.9553,326.3363;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;482.8688,-240.5063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;202.1724,293.2013;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;459.2327,-68.10992;Inherit;False;Property;_Intensity_Color;Intensity_Color;2;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;45;217.8545,100.7786;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;483.4049,240.8441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;490.0279,356.4905;Inherit;False;Property;_Clip;Clip;3;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;632.949,-132.9449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;50;657.7283,274.8902;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;677.0483,56.5347;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;56;1168,352;Inherit;False;204;375;Rendering Options;4;60;59;58;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;1200,560;Inherit;False;Property;_CullMode;Cull Mode;19;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;46;873.8293,179.0981;Inherit;False;MMN_CommonOutputs;4;;1;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;59;1200,480;Inherit;False;Property;_BlendDst;Blend Dst;18;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;1200,400;Inherit;False;Property;_BlendSrc;Blend Src;17;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;1200,640;Inherit;False;Property;_ZTest;Z Test;20;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;1166.327,214.1998;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/MUD_Hand_Flipbook_Noise;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=AlphaTest=Queue=0;True;5;False;0;True;True;1;5;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.PowerNode;52;306.04,-152.6662;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
WireConnection;29;1;30;0
WireConnection;36;0;29;1
WireConnection;36;1;29;2
WireConnection;37;0;36;0
WireConnection;37;1;28;3
WireConnection;38;0;35;0
WireConnection;38;1;37;0
WireConnection;12;1;38;0
WireConnection;55;0;28;4
WireConnection;19;0;12;1
WireConnection;19;1;52;0
WireConnection;33;0;12;3
WireConnection;33;1;12;4
WireConnection;34;0;45;4
WireConnection;34;1;33;0
WireConnection;17;0;19;0
WireConnection;17;1;18;0
WireConnection;50;0;34;0
WireConnection;50;1;34;0
WireConnection;50;2;51;0
WireConnection;22;0;17;0
WireConnection;22;1;12;4
WireConnection;22;2;45;0
WireConnection;46;9;22;0
WireConnection;46;28;50;0
WireConnection;40;0;46;2
WireConnection;40;1;46;26
WireConnection;52;0;12;2
WireConnection;52;1;55;0
ASEEND*/
//CHKSM=01FEA24B2DEF5FBDFFCCC1D3713C3D06CF5EDE3D