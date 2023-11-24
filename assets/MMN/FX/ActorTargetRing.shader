// Made with Amplify Shader Editor v1.9.1.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/ActorTargetRing"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HDR]_Color("Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("MainTex", 2D) = "white" {}
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
		[ASEEnd][Enum(UnityEngine.Rendering.CullMode)][Header(Z Buffer)][Space(10)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		_StencilValue("스탠실 Ref", Integer) = 10
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("스탠실 Comp", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail("스탠실 ZFail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("스탠실 Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail("스탠실 Fail", Float) = 0
        _Opaque("Opaque 적용", Float) = 1

	}

	SubShader
	{
		LOD 0

		Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent-199" 
        }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
            Name "Indicator"
            Tags { "LightMode" = "Indicator" }

            Stencil
            {
                Ref [_StencilValue]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }

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

			#include "Includes/FXCommonOutputs.hlsl"
            #include "../../MMN/FX/Includes/FX_AreaIndicator_CalculateDepth.hlsl"
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			half4 _Color;
			float _LightRatio;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _Opaque;
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
                float4 projectedPosition : TEXCOORD4;
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
                output.projectedPosition = vertexInput.positionNDC;

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				float localApplySoftParticle80_g1 = ( 0.0 );
				float localApplyLightColor6_g1 = ( 0.0 );
				float localApplyShadowAtten104_g1 = ( 0.0 );
				half localApplyRaycastingAlpha92_g1 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode7 = tex2D( _MainTex, uv_MainTex );
				float3 appendResult14 = (float3(( tex2DNode7 * input.ase_color * _Color ).rgb));
				float4 appendResult32_g1 = (float4(appendResult14 , ( tex2DNode7.a * input.ase_color.a )));
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

				if(_Opaque < 0.5)
				{
					finalColor.rgb *= 0.2;
            		finalColor.a = CalculateDepthAlphaTargetRing(input.projectedPosition.xy / input.projectedPosition.w, _ZBufferParams, input.positionWS.xyz, finalColor.a);	
				}

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
}
/*ASEBEGIN
Version=19102
Node;AmplifyShaderEditor.SamplerNode;7;-816,544;Inherit;True;Property;_MainTex;MainTex;1;0;Create;False;0;0;0;True;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;10;-688,736;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-736,368;Half;False;Property;_Color;Color;0;0;Create;False;0;0;0;True;0;False;0.5,0.5,0.5,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-352,320;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-352,432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-208,320;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;13;-64,320;Inherit;False;MMN_CommonOutputs;2;;1;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;192,320;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/ActorTargetRing;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;Hidden/InternalErrorShader;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;16;176,480;Inherit;False;204;375;Rendering Options;4;20;19;18;17;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;17;208,528;Inherit;False;Property;_BlendSrc;Blend Src;15;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;208,608;Inherit;False;Property;_BlendDst;Blend Dst;16;2;[HideInInspector];[Enum];Fetch;False;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;208,768;Inherit;False;Property;_ZTest;Z Test;18;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;208,688;Inherit;False;Property;_CullMode;Cull Mode;17;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;2;Header(Z Buffer);Space(10);False;0;0;0;0;0;1;FLOAT;0
WireConnection;12;0;7;0
WireConnection;12;1;10;0
WireConnection;12;2;9;0
WireConnection;11;0;7;4
WireConnection;11;1;10;4
WireConnection;14;0;12;0
WireConnection;13;9;14;0
WireConnection;13;28;11;0
WireConnection;1;0;13;2
WireConnection;1;1;13;26
ASEEND*/
//CHKSM=F919818B98DA1F7980F25B0AE30348A9F90BF578