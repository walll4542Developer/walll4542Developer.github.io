// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/VFX/Amplify shader/FX_NormalDistortion_Panning"
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
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "black" {}
		[Toggle]_NormalTexture("NormalTexture", Float) = 0
		_Distortion_Power("Distortion_Power", Float) = 1
		_Main_X_Speed("Main_X_Speed", Float) = 0
		_Main_Y_Speed("Main_Y_Speed", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[ASEEnd]_Opacity("Opacity", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent-499" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="Distortion" }

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
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Distortion_Power;
			float _Main_X_Speed;
			float _Main_Y_Speed;
			float _NormalTexture;
			float _Opacity;
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
				float localApplySoftParticle80_g12 = ( 0.0 );
				float localApplyLightColor6_g12 = ( 0.0 );
				float localApplyShadowAtten104_g12 = ( 0.0 );
				half localApplyRaycastingAlpha92_g12 = ( 0.0 );
				float localGetPositionCSForBending36_g11 = ( 0.0 );
				float4 positionCS36_g11 = float4( 0,0,0,0 );
				float4 positionNDC36_g11 = float4( 0,0,0,0 );
				float3 positionOS36_g11 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS36_g11 , positionNDC36_g11 , positionOS36_g11 );
				float2 appendResult272 = (float2(_Main_X_Speed , _Main_Y_Speed));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 panner271 = ( 1.0 * _Time.y * appendResult272 + uv_MainTex);
				float4 tex2DNode5 = tex2D( _MainTex, panner271 );
				float4 computeScreenPos246 = ComputeScreenPos( float4( float3(0,1,0) , 0.0 ) );
				float4 lerpResult264 = lerp( ( tex2DNode5.g * computeScreenPos246 ) , float4( UnpackNormalScale( tex2DNode5, 1.0 ) , 0.0 ) , _NormalTexture);
				half4 positionNDC32_g11 = ( positionNDC36_g11 + float4( ( input.ase_color.a * _Distortion_Power * lerpResult264 ).xy, 0.0 , 0.0 ) );
				half3 localSceneColor32_g11 = SceneColor( positionNDC32_g11 );
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 appendResult32_g12 = (float4(localSceneColor32_g11 , ( tex2D( _MaskTex, uv_MaskTex ).r * _Opacity )));
				half4 finalColor92_g12 = appendResult32_g12;
				half3 positionWS92_g12 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g12 = ase_screenPosNorm;
				half4 screenPos92_g12 = ase_screenPosNorm;
				half nearPlane92_g12 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g12 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g12 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g12 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g12 , positionWS92_g12 , screenUV92_g12 , screenPos92_g12 , nearPlane92_g12 , nearPlaneInvertDistance92_g12 , raycastHarftoneClip92_g12 , raycastMinimumAlpha92_g12 );
				float4 finalColor104_g12 = finalColor92_g12;
				float4 shadowCoord104_g12 = input.uv0;
				float3 positionWS104_g12 = input.positionWS;
				float lightRatio104_g12 = _LightRatio;
				ApplyShadowAtten( finalColor104_g12 , shadowCoord104_g12 , positionWS104_g12 , lightRatio104_g12 );
				float4 finalColor6_g12 = finalColor104_g12;
				float3 normalWS6_g12 = input.normalWS;
				float lightRatio6_g12 = _LightRatio;
				ApplyLightColor( finalColor6_g12 , normalWS6_g12 , lightRatio6_g12 );
				float4 finalColor80_g12 = finalColor6_g12;
				float near80_g12 = _SoftParticleNearFadeDistance;
				float far80_g12 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g12 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g12 = ( 0.0 );
				float4 positionCS58_g12 = float4( 0,0,0,0 );
				float4 positionNDC58_g12 = float4( 0,0,0,0 );
				float3 positionOS58_g12 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g12 , positionNDC58_g12 , positionOS58_g12 );
				float4 positionNDC80_g12 = positionNDC58_g12;
				ApplySoftParticle( finalColor80_g12 , near80_g12 , far80_g12 , fadeOutRange80_g12 , positionNDC80_g12 );
				float4 break64_g12 = finalColor80_g12;
				float3 appendResult76_g12 = (float3(break64_g12.x , break64_g12.y , break64_g12.z));
				
				float3 Color = appendResult76_g12;
				float Alpha = break64_g12.w;

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
Node;AmplifyShaderEditor.RangedFloatNode;274;-1767.789,454.4615;Inherit;False;Property;_Main_Y_Speed;Main_Y_Speed;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-1804.942,353.3654;Inherit;False;Property;_Main_X_Speed;Main_X_Speed;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;272;-1599,314.5;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-1752,147.4808;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;271;-1349,221.5;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;263;-944,-432;Inherit;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;246;-768,-353;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;266;-200.4346,-173.2517;Inherit;False;263.2906;286.0162;Switch;2;265;264;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-994,-139;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;None;True;0;True;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;265;-172.4348,16.76451;Inherit;False;Property;_NormalTexture;NormalTexture;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;184;-534,-45;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;249;-512,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;276;-266.613,183.5061;Inherit;False;0;275;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;264;-86.14415,-123.2517;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;66;-144,-528;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;129;-176,-320;Inherit;False;Property;_Distortion_Power;Distortion_Power;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;278;294.9781,407.7347;Inherit;False;Property;_Opacity;Opacity;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;275;170.6331,32.66103;Inherit;True;Property;_MaskTex;MaskTex;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;112,-352;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;543.6682,-19.31911;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;134;256,-352;Inherit;False;MMN_Distortion;-1;;11;4f09efce388c49e4494ed86a775863e4;0;1;54;FLOAT2;0,0;False;1;FLOAT3;2
Node;AmplifyShaderEditor.CommentaryNode;76;848,-192;Inherit;False;204;375;Rendering Options;3;79;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;77;880,-64;Inherit;False;Property;_BlendDst;Blend Dst;21;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;880,16;Inherit;False;Property;_CullMode;Cull Mode;22;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;880,-144;Inherit;False;Property;_BlendSrc;Blend Src;20;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;880,96;Inherit;False;Property;_ZTest;Z Test;23;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;592,-352;Inherit;False;MMN_CommonOutputs;0;;12;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;848,-352;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/VFX/Amplify shader/FX_NormalDistortion_Panning;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=-499;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;1;LightMode=Distortion;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;272;0;273;0
WireConnection;272;1;274;0
WireConnection;271;0;270;0
WireConnection;271;2;272;0
WireConnection;246;0;263;0
WireConnection;5;1;271;0
WireConnection;184;0;5;0
WireConnection;249;0;5;2
WireConnection;249;1;246;0
WireConnection;264;0;249;0
WireConnection;264;1;184;0
WireConnection;264;2;265;0
WireConnection;275;1;276;0
WireConnection;130;0;66;4
WireConnection;130;1;129;0
WireConnection;130;2;264;0
WireConnection;277;0;275;1
WireConnection;277;1;278;0
WireConnection;134;54;130;0
WireConnection;119;9;134;2
WireConnection;119;28;277;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
ASEEND*/
//CHKSM=35EAF8B74FD54949A345972C624D3999073B3B7C