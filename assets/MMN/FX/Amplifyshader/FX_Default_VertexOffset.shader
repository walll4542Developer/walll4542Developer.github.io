// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Default_VertexOffset"
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
		[Header(tcd0.z     p_Speed)][Header(tcd0.w     p_Size.x)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Toggle][Header(Vertex Option)][Space()]_Use_VretexColor("Use_VretexColor", Float) = 0
		_VelocityVector("Velocity Vector", Vector) = (0,1,0,0)
		_VertexOffset_Speed("VertexOffset_Speed", Float) = 1
		_Sphereofinfluence("Sphere of influence", Range( 0 , 0.9)) = 0.9
		_VertexOffset_Power("VertexOffset_Power", Float) = 1
		_SinScope("Sin Scope", Float) = 20
		_Threshold("Threshold", Float) = 10
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		_Color("Color", Color) = (1,1,1,1)
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
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_COLOR
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON


			sampler2D _MaskTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float4 _Color;
			float3 _VelocityVector;
			float _LightRatio;
			float _Use_G_Channel_Alpha;
			float _Intensity_Color;
			float _Use_VretexColor;
			float _Sphereofinfluence;
			float _Threshold;
			float _SinScope;
			float _VertexOffset_Power;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _VertexOffset_Speed;
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
				float4 ase_texcoord2 : TEXCOORD2;
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
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float2 uv_MaskTex = input.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float3 appendResult137 = (float3(( tex2Dlod( _MaskTex, float4( uv_MaskTex, 0, 0.0) ).g * sin( ( ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * _VertexOffset_Speed ) + ( 10.0 * input.texcoord.z ) ) ) * _VertexOffset_Power * input.normalOS * input.texcoord.w )));
				float4 break213 = input.color;
				float3 appendResult216 = (float3(break213.r , break213.g , ( ( break213.b * 2.0 ) + -1.0 )));
				float3 normalizeResult232 = normalize( cross( input.ase_texcoord1.xyz , _VelocityVector ) );
				float3 worldToObj237 = mul( GetWorldToObjectMatrix(), float4( ( sin( ( ( ( appendResult216 * 0.1 ).z * _SinScope ) + ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * input.ase_texcoord2.w ) ) ) * _Threshold * normalizeResult232 * (1.0 + (input.color.b - 0.0) * (_Sphereofinfluence - 1.0) / (1.0 - 0.0)) ), 1 ) ).xyz;
				float3 lerpResult241 = lerp( appendResult137 , worldToObj237 , _Use_VretexColor);

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;

				output.ase_color = input.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = lerpResult241;
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
				float localApplySoftParticle80_g11 = ( 0.0 );
				float localApplyLightColor6_g11 = ( 0.0 );
				float localApplyShadowAtten104_g11 = ( 0.0 );
				half localApplyRaycastingAlpha92_g11 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float4 MainTex_RGB247 = tex2DNode5;
				float4 lerpResult208 = lerp( ( input.ase_color * MainTex_RGB247 ) , input.ase_color , _Use_G_Channel_Alpha);
				float3 appendResult114 = (float3(( _Intensity_Color * lerpResult208 * _Color ).rgb));
				float Switch249 = _Use_VretexColor;
				float4 lerpResult252 = lerp( float4( appendResult114 , 0.0 ) , ( MainTex_RGB247 * _Color * _Intensity_Color ) , Switch249);
				float lerpResult207 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float4 appendResult32_g11 = (float4(lerpResult252.rgb , saturate( ( lerpResult207 * _Intensity_Alpha * input.ase_color.a ) )));
				half4 finalColor92_g11 = appendResult32_g11;
				half3 positionWS92_g11 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g11 = ase_screenPosNorm;
				half4 screenPos92_g11 = ase_screenPosNorm;
				half nearPlane92_g11 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g11 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g11 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g11 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g11 , positionWS92_g11 , screenUV92_g11 , screenPos92_g11 , nearPlane92_g11 , nearPlaneInvertDistance92_g11 , raycastHarftoneClip92_g11 , raycastMinimumAlpha92_g11 );
				float4 finalColor104_g11 = finalColor92_g11;
				float4 shadowCoord104_g11 = input.uv0;
				float3 positionWS104_g11 = input.positionWS;
				float lightRatio104_g11 = _LightRatio;
				ApplyShadowAtten( finalColor104_g11 , shadowCoord104_g11 , positionWS104_g11 , lightRatio104_g11 );
				float4 finalColor6_g11 = finalColor104_g11;
				float3 normalWS6_g11 = input.normalWS;
				float lightRatio6_g11 = _LightRatio;
				ApplyLightColor( finalColor6_g11 , normalWS6_g11 , lightRatio6_g11 );
				float4 finalColor80_g11 = finalColor6_g11;
				float near80_g11 = _SoftParticleNearFadeDistance;
				float far80_g11 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g11 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g11 = ( 0.0 );
				float4 positionCS58_g11 = float4( 0,0,0,0 );
				float4 positionNDC58_g11 = float4( 0,0,0,0 );
				float3 positionOS58_g11 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g11 , positionNDC58_g11 , positionOS58_g11 );
				float4 positionNDC80_g11 = positionNDC58_g11;
				ApplySoftParticle( finalColor80_g11 , near80_g11 , far80_g11 , fadeOutRange80_g11 , positionNDC80_g11 );
				float4 break64_g11 = finalColor80_g11;
				float3 appendResult76_g11 = (float3(break64_g11.x , break64_g11.y , break64_g11.z));

				float3 Color = appendResult76_g11;
				float Alpha = break64_g11.w;

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
Version=19202
Node;AmplifyShaderEditor.TexCoordVertexDataNode;131;-256,768;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;127;-256,432;Inherit;False;MMN_Time;-1;;9;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-656,-448;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;210;-477.1537,-82;Inherit;False;269.1537;300.425;Switch;2;209;207;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;211;-208,-433;Inherit;False;169;175;Switch;1;208;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-448,-272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-48,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;203;-48,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-459.1537,122.425;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;208;-192,-383;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;16,-96;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;24;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;207;-368,-32;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;201;112,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;186;372.4769,788.4338;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;138;192,256;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;128;288,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;124;80,64;Inherit;True;Property;_MaskTex;MaskTex;15;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;016157555484cb64a8449ff4743ab1c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;192,416;Inherit;False;Property;_VertexOffset_Power;VertexOffset_Power;20;0;Create;True;0;0;0;False;0;False;1;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;192,-256;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;480,48;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;76;1123.413,-106.6607;Inherit;False;204;375;Rendering Options;4;79;78;77;212;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;212;1155.413,181.3393;Inherit;False;Property;_ZTest;Z Test;29;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1155.413,101.3393;Inherit;False;Property;_CullMode;Cull Mode;28;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;1155.413,21.33929;Inherit;False;Property;_BlendDst;Blend Dst;27;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;624,48;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1155.413,-58.66071;Inherit;False;Property;_BlendSrc;Blend Src;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;213;-1383.492,975.6016;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-1183.492,1153.601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-1052.492,1154.601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;216;-951.4908,1007.602;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-894.4908,1130.601;Inherit;False;Constant;_Float2;Float 0;5;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-768.4905,1003.602;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-685.1006,1142.194;Inherit;False;Property;_SinScope;Sin Scope;21;0;Create;True;0;0;0;False;0;False;20;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;220;-747.8737,1327.91;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;221;-638.8907,1008.401;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;222;-719.8006,1252.396;Inherit;False;MMN_Time;-1;;12;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;223;-669.0752,1541.446;Inherit;False;1;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-542.1,1295.195;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;-476.0008,1062.495;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;227;-571.786,1873.735;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;228;-444.2128,1556.781;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-311.8008,1105.194;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;231;-413.6017,1871.916;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;232;-231.2137,1555.781;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;233;-290.5388,1879.868;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;234;-190.5008,1099.995;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-316.6006,1208.894;Inherit;False;Property;_Threshold;Threshold;22;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-31.60158,1114.396;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;237;169.399,1111.778;Inherit;True;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;238;-1592.582,973.5358;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;239;532.3246,441.5045;Inherit;False;547.4225;299.6555;Switch;3;240;241;249;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;194.6,-381.9;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-1168.1,-103.3;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;4;Header(tcd0.z     p_Speed);Header(tcd0.w     p_Size.x);Header(Main Texture);Space();False;-1;None;016157555484cb64a8449ff4743ab1c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;248;-67.89417,-825.6393;Inherit;False;247;MainTex_RGB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;242;-81.43513,-716.6055;Inherit;False;Property;_Color;Color;25;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;60;-105.8,-518.2001;Inherit;False;Property;_Intensity_Color;Intensity_Color;23;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;210.063,-733.0315;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;251;383.243,-804.1532;Inherit;False;547.4225;299.6555;Switch;2;252;250;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-256,560;Inherit;False;Property;_VertexOffset_Speed;VertexOffset_Speed;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-256,656;Inherit;False;Constant;_pSpeedbySpeed;p.Speed by Speed;17;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;225;-631.2123,1687.781;Inherit;False;Property;_VelocityVector;Velocity Vector;17;0;Create;True;0;0;0;False;0;False;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;230;-592.9294,2060.74;Inherit;False;Property;_Sphereofinfluence;Sphere of influence;19;0;Create;True;0;0;0;False;0;False;0.9;0.2;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;241;849.3568,530.351;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;249;819.0654,663.7581;Inherit;False;Switch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;587.3658,642.5178;Inherit;False;Property;_Use_VretexColor;Use_VretexColor;16;1;[Toggle];Create;True;0;0;0;False;2;Header(Vertex Option);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;247;-696.1786,-239.6842;Inherit;False;MainTex_RGB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;51.48792,-428.3321;Inherit;False;-1;;1;0;OBJECT;;False;1;OBJECT;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;418,-386;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;471.3878,-605.8466;Inherit;False;249;Switch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;252;603.2753,-726.3067;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;1151,-376;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_Default_VertexOffset;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.FunctionNode;119;918,-386;Inherit;False;MMN_CommonOutputs;0;;11;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SaturateNode;44;468.4855,-249.2837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;65;0;66;0
WireConnection;65;1;247;0
WireConnection;129;0;127;0
WireConnection;129;1;206;0
WireConnection;203;0;130;0
WireConnection;203;1;131;3
WireConnection;208;0;65;0
WireConnection;208;1;66;0
WireConnection;208;2;209;0
WireConnection;207;0;5;4
WireConnection;207;1;5;2
WireConnection;207;2;209;0
WireConnection;201;0;129;0
WireConnection;201;1;203;0
WireConnection;186;0;131;4
WireConnection;128;0;201;0
WireConnection;41;0;207;0
WireConnection;41;1;42;0
WireConnection;41;2;66;4
WireConnection;126;0;124;2
WireConnection;126;1;128;0
WireConnection;126;2;136;0
WireConnection;126;3;138;0
WireConnection;126;4;186;0
WireConnection;137;0;126;0
WireConnection;213;0;238;0
WireConnection;214;0;213;2
WireConnection;215;0;214;0
WireConnection;216;0;213;0
WireConnection;216;1;213;1
WireConnection;216;2;215;0
WireConnection;218;0;216;0
WireConnection;218;1;217;0
WireConnection;221;0;218;0
WireConnection;224;0;222;0
WireConnection;224;1;220;4
WireConnection;226;0;221;2
WireConnection;226;1;219;0
WireConnection;228;0;223;0
WireConnection;228;1;225;0
WireConnection;229;0;226;0
WireConnection;229;1;224;0
WireConnection;231;0;227;0
WireConnection;232;0;228;0
WireConnection;233;0;231;2
WireConnection;233;4;230;0
WireConnection;234;0;229;0
WireConnection;236;0;234;0
WireConnection;236;1;235;0
WireConnection;236;2;232;0
WireConnection;236;3;233;0
WireConnection;237;0;236;0
WireConnection;61;0;60;0
WireConnection;61;1;208;0
WireConnection;61;2;242;0
WireConnection;243;0;248;0
WireConnection;243;1;242;0
WireConnection;243;2;60;0
WireConnection;241;0;137;0
WireConnection;241;1;237;0
WireConnection;241;2;240;0
WireConnection;249;0;240;0
WireConnection;247;0;5;0
WireConnection;114;0;61;0
WireConnection;252;0;114;0
WireConnection;252;1;243;0
WireConnection;252;2;250;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
WireConnection;97;3;241;0
WireConnection;119;9;252;0
WireConnection;119;28;44;0
WireConnection;44;0;41;0
ASEEND*/
//CHKSM=ADF1DF087AD12F275E35325D2D068F8F159E0A4B