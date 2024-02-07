// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/CutScene/VFX/VFX_Dissovle_Tex"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Header(tcd0.z     Dissolve)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Main_Color("Main_Color", Color) = (1,1,1,0)
		_RGB_Intensity("RGB_Intensity", Float) = 1
		_RGB_Power("RGB_Power", Float) = 1
		_DissolveTex("DissolveTex", 2D) = "white" {}
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
		_Mask_Ins("Mask_Ins", Float) = 1
		_Mask_Pow("Mask_Pow", Float) = 1
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[ASEEnd][Toggle(_USE_CUTOUT_ON)] _Use_Cutout("Use_Cutout", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
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

			#include "../../FX/Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma multi_compile_local __ _USE_CUTOUT_ON


			sampler2D _MainTex;
			sampler2D _DissolveTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Main_Color;
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _RGB_Intensity;
			float _RGB_Power;
			float _Use_G_Channel_Alpha;
			float _Mask_Ins;
			float _Mask_Pow;
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
				float localApplySoftParticle80_g5 = ( 0.0 );
				float localApplyLightColor6_g5 = ( 0.0 );
				float localApplyShadowAtten104_g5 = ( 0.0 );
				half localApplyRaycastingAlpha92_g5 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode79 = tex2D( _MainTex, uv_MainTex );
				float4 temp_cast_0 = (_RGB_Power).xxxx;
				float lerpResult102 = lerp( tex2DNode79.a , tex2DNode79.g , _Use_G_Channel_Alpha);
				float2 uv_DissolveTex = input.uv0.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
				float temp_output_77_0 = ( tex2D( _DissolveTex, uv_DissolveTex ).r + input.uv0.z );
				#ifdef _USE_CUTOUT_ON
				float staticSwitch99 = step( 0.1 , temp_output_77_0 );
				#else
				float staticSwitch99 = temp_output_77_0;
				#endif
				float4 appendResult32_g5 = (float4(( input.ase_color * pow( ( _RGB_Intensity * ( _Main_Color * tex2DNode79 ) ) , temp_cast_0 ) ).rgb , ( input.ase_color.a * saturate( ( pow( ( lerpResult102 * _Mask_Ins ) , _Mask_Pow ) * staticSwitch99 ) ) )));
				half4 finalColor92_g5 = appendResult32_g5;
				half3 positionWS92_g5 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g5 = ase_screenPosNorm;
				half4 screenPos92_g5 = ase_screenPosNorm;
				half nearPlane92_g5 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g5 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g5 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g5 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g5 , positionWS92_g5 , screenUV92_g5 , screenPos92_g5 , nearPlane92_g5 , nearPlaneInvertDistance92_g5 , raycastHarftoneClip92_g5 , raycastMinimumAlpha92_g5 );
				float4 finalColor104_g5 = finalColor92_g5;
				float4 shadowCoord104_g5 = input.uv0;
				float3 positionWS104_g5 = input.positionWS;
				float lightRatio104_g5 = _LightRatio;
				ApplyShadowAtten( finalColor104_g5 , shadowCoord104_g5 , positionWS104_g5 , lightRatio104_g5 );
				float4 finalColor6_g5 = finalColor104_g5;
				float3 normalWS6_g5 = input.normalWS;
				float lightRatio6_g5 = _LightRatio;
				ApplyLightColor( finalColor6_g5 , normalWS6_g5 , lightRatio6_g5 );
				float4 finalColor80_g5 = finalColor6_g5;
				float near80_g5 = _SoftParticleNearFadeDistance;
				float far80_g5 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g5 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g5 = ( 0.0 );
				float4 positionCS58_g5 = float4( 0,0,0,0 );
				float4 positionNDC58_g5 = float4( 0,0,0,0 );
				float3 positionOS58_g5 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g5 , positionNDC58_g5 , positionOS58_g5 );
				float4 positionNDC80_g5 = positionNDC58_g5;
				ApplySoftParticle( finalColor80_g5 , near80_g5 , far80_g5 , fadeOutRange80_g5 , positionNDC80_g5 );
				float4 break64_g5 = finalColor80_g5;
				float3 appendResult76_g5 = (float3(break64_g5.x , break64_g5.y , break64_g5.z));

				float3 Color = appendResult76_g5;
				float Alpha = break64_g5.w;

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
Version=19102
Node;AmplifyShaderEditor.CommentaryNode;100;-1196.286,-405.5222;Inherit;False;390.5479;254.5044;Switch;2;102;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;82;-1796.125,-521.0659;Inherit;True;0;79;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;91;-1157.567,83.43733;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;74;-1195.772,-122.7756;Inherit;True;Property;_DissolveTex;DissolveTex;4;0;Create;True;0;0;0;False;0;False;-1;None;1057d23271741f84e9cc9567c1c32b94;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;101;-1178.173,-243.5223;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;20;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;79;-1532.163,-544.08;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;e299c7a115f5c5d44aafdaec6761a4b2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-723.7998,-108.8117;Inherit;False;Property;_Mask_Ins;Mask_Ins;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-697.4154,329.6711;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;102;-954.173,-355.5223;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-855.1331,19.59061;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-659.7998,-255.8117;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-560.7999,-111.8117;Inherit;False;Property;_Mask_Pow;Mask_Pow;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;84;-733.2107,-724.1062;Inherit;False;Property;_Main_Color;Main_Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.7286801,0.1752957,0.6620398,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;80;-521.658,319.2909;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;104;-496.7998,-255.8117;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;99;-425.4209,3.970825;Inherit;False;Property;_Use_Cutout;Use_Cutout;21;0;Create;True;0;0;0;False;0;False;1;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-493.9213,-652.91;Inherit;False;Property;_RGB_Intensity;RGB_Intensity;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-486.5244,-515.9589;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-148.2139,-94.09698;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-216.2623,-622.4416;Inherit;False;Property;_RGB_Power;RGB_Power;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-296.9075,-518.7982;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;98;-49.26233,-526.4416;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;88;433.7607,-96.54057;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;85;-162.2879,-303.9406;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;38.05982,-350.2432;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;64;945.3986,-103.6933;Inherit;False;204;375;Rendering Options;4;55;62;63;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;591.2721,-155.5234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;977.3986,104.3067;Inherit;False;Property;_CullMode;Cull Mode;24;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;978.3986,-55.69334;Inherit;False;Property;_BlendSrc;Blend Src;22;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;976,192;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;977.3986,24.30665;Inherit;False;Property;_BlendDst;Blend Dst;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;94;726.6362,-253.6349;Inherit;False;MMN_CommonOutputs;5;;5;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;96;963.0481,-253.0827;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/CutScene/VFX/VFX_Dissovle_Tex;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;79;1;82;0
WireConnection;102;0;79;4
WireConnection;102;1;79;2
WireConnection;102;2;101;0
WireConnection;77;0;74;1
WireConnection;77;1;91;3
WireConnection;103;0;102;0
WireConnection;103;1;105;0
WireConnection;80;0;93;0
WireConnection;80;1;77;0
WireConnection;104;0;103;0
WireConnection;104;1;106;0
WireConnection;99;1;77;0
WireConnection;99;0;80;0
WireConnection;83;0;84;0
WireConnection;83;1;79;0
WireConnection;81;0;104;0
WireConnection;81;1;99;0
WireConnection;89;0;90;0
WireConnection;89;1;83;0
WireConnection;98;0;89;0
WireConnection;98;1;97;0
WireConnection;88;0;81;0
WireConnection;86;0;85;0
WireConnection;86;1;98;0
WireConnection;87;0;85;4
WireConnection;87;1;88;0
WireConnection;94;9;86;0
WireConnection;94;28;87;0
WireConnection;96;0;94;2
WireConnection;96;1;94;26
ASEEND*/
//CHKSM=672E48A7FB03B511A229547768126C411D8E1D0F