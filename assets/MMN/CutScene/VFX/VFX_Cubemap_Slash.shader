// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/CutScene/VFX/VFX_Cubemap_Slash"
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
		[Header(tcd1.x     Dissolve)][Header(tcd1.y     Intensity_Color)][Header(tcd1.z     Power_Color)][Header(tcd1.W    Mask_Dissolve)][Header(tcd3.x     Alpha_X_Offset)][Header(tcd3.y     Alpha_Y_Offset)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_Main_Color("Main_Color", Color) = (1,1,1,1)
		[Toggle(_USE_POWER_ON)] _USE_Power("USE_Power", Float) = 0
		_Main_Power("Main_Power", Float) = 1
		[Toggle(_USE_INTENSITY_ON)] _USE_Intensity("USE_Intensity", Float) = 0
		_Main_Intensity("Main_Intensity", Float) = 1
		_Alpha_Intensity("Alpha_Intensity", Float) = 1
		_Parallex_Height("Parallex_Height", Float) = 0
		_Parallex_Scale("Parallex_Scale", Float) = 0
		[Toggle(_USE_STEP_ON)] _USE_Step("USE_Step", Float) = 0
		[HDR]_Outline_Color("Outline_Color", Color) = (1024,1024,1024,0)
		_OutLine("OutLine", Range( 0 , 0.5)) = 0.5
		[Toggle(_USE_CUBEMAP_ON)] _USE_CubeMap("USE_CubeMap", Float) = 0
		_CubemapTex("CubemapTex", CUBE) = "white" {}
		_AlphaTex("AlphaTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

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
			#pragma shader_feature_local _USE_CUBEMAP_ON
			#pragma shader_feature_local _USE_POWER_ON
			#pragma shader_feature_local _USE_INTENSITY_ON
			#pragma shader_feature_local _USE_STEP_ON


			sampler2D _MainTex;
			samplerCUBE _CubemapTex;
			sampler2D _AlphaTex;
			sampler2D _NoiseTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MaskTex_ST;
			float4 _NoiseTex_ST;
			float4 _AlphaTex_ST;
			float4 _Outline_Color;
			float4 _Main_Color;
			float _LightRatio;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Main_Intensity;
			float _Main_Power;
			float _Parallex_Scale;
			float _Parallex_Height;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Alpha_Intensity;
			float _OutLine;
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
				float4 ase_texcoord3 : TEXCOORD3;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord5 = screenPos;
				
				output.ase_texcoord3 = input.ase_texcoord1;
				output.ase_texcoord4 = input.ase_texcoord3;
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
				float localApplySoftParticle80_g36 = ( 0.0 );
				float localApplyLightColor6_g36 = ( 0.0 );
				float localApplyShadowAtten104_g36 = ( 0.0 );
				half localApplyRaycastingAlpha92_g36 = ( 0.0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldReflection = reflect(-ase_worldViewDir, input.normalWS);
				float2 Offset35 = ( ( _Parallex_Height - 1 ) * ase_worldViewDir.xy * _Parallex_Scale ) + ase_worldReflection.xy;
				#ifdef _USE_CUBEMAP_ON
				float4 staticSwitch79 = texCUBE( _CubemapTex, ase_worldReflection );
				#else
				float4 staticSwitch79 = tex2D( _MainTex, Offset35 );
				#endif
				#ifdef _USE_POWER_ON
				float staticSwitch120 = _Main_Power;
				#else
				float staticSwitch120 = input.ase_texcoord3.z;
				#endif
				float4 temp_cast_1 = (staticSwitch120).xxxx;
				#ifdef _USE_INTENSITY_ON
				float staticSwitch119 = _Main_Intensity;
				#else
				float staticSwitch119 = input.ase_texcoord3.y;
				#endif
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult84 = (float2(( input.ase_texcoord4.x + uv_AlphaTex.x ) , ( uv_AlphaTex.y + input.ase_texcoord4.y )));
				float2 appendResult49 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner48 = ( 1.0 * _Time.y * appendResult49 + uv_NoiseTex);
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_28_0 = saturate( ( ( tex2D( _AlphaTex, appendResult84 ).r * ( tex2D( _NoiseTex, panner48 ).r + input.ase_texcoord3.x ) * ( tex2D( _MaskTex, uv_MaskTex ).r + input.ase_texcoord3.w ) ) * _Alpha_Intensity ) );
				#ifdef _USE_STEP_ON
				float staticSwitch80 = step( 0.1 , temp_output_28_0 );
				#else
				float staticSwitch80 = temp_output_28_0;
				#endif
				#ifdef _USE_STEP_ON
				float staticSwitch109 = step( _OutLine , temp_output_28_0 );
				#else
				float staticSwitch109 = (0.0 + (saturate( ( temp_output_28_0 - _OutLine ) ) - 0.0) * (1.0 - 0.0) / (0.5 - 0.0));
				#endif
				float4 appendResult32_g36 = (float4(( ( ( _Main_Color * ( pow( staticSwitch79 , temp_cast_1 ) * staticSwitch119 ) ) + ( _Outline_Color * saturate( ( staticSwitch80 - staticSwitch109 ) ) ) ) * input.ase_color ).rgb , ( input.ase_color.a * saturate( staticSwitch80 ) )));
				half4 finalColor92_g36 = appendResult32_g36;
				half3 positionWS92_g36 = input.positionWS;
				float4 screenPos = input.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g36 = ase_screenPosNorm;
				half4 screenPos92_g36 = ase_screenPosNorm;
				half nearPlane92_g36 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g36 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g36 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g36 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g36 , positionWS92_g36 , screenUV92_g36 , screenPos92_g36 , nearPlane92_g36 , nearPlaneInvertDistance92_g36 , raycastHarftoneClip92_g36 , raycastMinimumAlpha92_g36 );
				float4 finalColor104_g36 = finalColor92_g36;
				float4 shadowCoord104_g36 = input.uv0;
				float3 positionWS104_g36 = input.positionWS;
				float lightRatio104_g36 = _LightRatio;
				ApplyShadowAtten( finalColor104_g36 , shadowCoord104_g36 , positionWS104_g36 , lightRatio104_g36 );
				float4 finalColor6_g36 = finalColor104_g36;
				float3 normalWS6_g36 = input.normalWS;
				float lightRatio6_g36 = _LightRatio;
				ApplyLightColor( finalColor6_g36 , normalWS6_g36 , lightRatio6_g36 );
				float4 finalColor80_g36 = finalColor6_g36;
				float near80_g36 = _SoftParticleNearFadeDistance;
				float far80_g36 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g36 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g36 = ( 0.0 );
				float4 positionCS58_g36 = float4( 0,0,0,0 );
				float4 positionNDC58_g36 = float4( 0,0,0,0 );
				float3 positionOS58_g36 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g36 , positionNDC58_g36 , positionOS58_g36 );
				float4 positionNDC80_g36 = positionNDC58_g36;
				ApplySoftParticle( finalColor80_g36 , near80_g36 , far80_g36 , fadeOutRange80_g36 , positionNDC80_g36 );
				float4 break64_g36 = finalColor80_g36;
				float3 appendResult76_g36 = (float3(break64_g36.x , break64_g36.y , break64_g36.z));
				
				float3 Color = appendResult76_g36;
				float Alpha = break64_g36.w;

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
Node;AmplifyShaderEditor.CommentaryNode;118;-3139.963,267.6469;Inherit;False;3154.965;1055.456;Opacity;32;25;44;84;86;83;47;85;10;48;49;50;51;46;75;26;76;74;45;28;81;82;111;110;63;64;109;65;66;116;67;80;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;117;-2162.599,-680.9604;Inherit;False;2063.462;716.4015;Main;17;19;23;73;18;79;77;33;1;17;43;42;39;35;119;120;122;121;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;3;732.833,166.1667;Inherit;False;204;375;Rendering Options;4;7;6;5;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;4;764.833,294.1667;Inherit;False;Property;_BlendDst;Blend Dst;34;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;764.833,454.1667;Inherit;False;Property;_ZTest;Z Test;32;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;764.833,214.1667;Inherit;False;Property;_BlendSrc;Blend Src;33;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;764.833,374.1667;Inherit;False;Property;_CullMode;Cull Mode;35;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;8;399.833,-158.8333;Inherit;False;MMN_CommonOutputs;0;;36;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;9;773,-136;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/CutScene/VFX/VFX_Cubemap_Slash;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;16.64746,-184.6246;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ParallaxMappingNode;35;-1769.599,-464.9603;Inherit;False;Normal;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;39;-2049.599,-233.9604;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;-2046.599,-420.9603;Inherit;False;Property;_Parallex_Height;Parallex_Height;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2038.599,-341.9603;Inherit;False;Property;_Parallex_Scale;Parallex_Scale;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;1;-2112.599,-630.9604;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-277.1392,-453.3949;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-156.4606,83.69578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;72;-313.3525,179.3754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;24;-14,-43;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;205,-138;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;202,126;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2044.086,798.4453;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;84;-2445.773,415.1836;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-2601.241,372.5396;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-2600.46,480.0621;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-2897.961,317.6469;Inherit;False;0;44;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;85;-2906.368,468.5594;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;48;-2611.643,729.3633;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-2806.963,833.2943;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-2862.432,684.6066;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-2041.062,1038.104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;26;-2321.086,909.4456;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1882.781,777.8767;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;-1531.91,778.5738;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1709.925,778.1569;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;111;-1315.677,566.6079;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;110;-1167.677,567.6079;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;63;-991.0622,764.5624;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1156.152,735.4816;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;109;-759.6768,491.6078;Inherit;False;Property;_USE_Step;USE_Step;22;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;65;-1013.076,322.5697;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1658.076,319.5697;Inherit;False;Property;_OutLine;OutLine;24;0;Create;True;0;0;0;False;0;False;0.5;0.1391304;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;116;-991.6768,566.6079;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-514.0693,464.6092;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;80;-746.622,716.8211;Inherit;False;Property;_USE_Step;USE_Step;21;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-162.9981,593.5695;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-2395.085,703.4451;Inherit;True;Property;_NoiseTex;NoiseTex;28;0;Create;True;0;0;0;False;0;False;-1;None;8874f400812212544b716e952b4155a8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;74;-2382.061,1096.104;Inherit;True;Property;_MaskTex;MaskTex;31;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;50;-3089.963,826.2943;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3087.963,928.2936;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2709.061,1123.104;Inherit;False;0;74;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-2280.463,396.6947;Inherit;True;Property;_AlphaTex;AlphaTex;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;69;-580.5309,82.54311;Inherit;False;Property;_Outline_Color;Outline_Color;23;1;[HDR];Create;True;0;0;0;False;0;False;1024,1024,1024,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-552.5449,-599.8308;Inherit;False;Property;_Main_Color;Main_Color;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;77;-1564.266,-261.4267;Inherit;True;Property;_CubemapTex;CubemapTex;26;0;Create;True;0;0;0;False;0;False;-1;74937f63d8f92984f8776d945d5d14c8;74937f63d8f92984f8776d945d5d14c8;True;0;False;white;Auto;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-1544.6,-486.9603;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;1;;0;0;False;8;Header(tcd1.x     Dissolve);Header(tcd1.y     Intensity_Color);Header(tcd1.z     Power_Color);Header(tcd1.W    Mask_Dissolve);Header(tcd3.x     Alpha_X_Offset);Header(tcd3.y     Alpha_Y_Offset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-445.6005,-396.9603;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;73;-1414.417,-147.5192;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;17;-730.6006,-401.9603;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-1206.605,-215.4337;Inherit;False;Property;_Main_Power;Main_Power;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-913.6052,-53.43372;Inherit;False;Property;_Main_Intensity;Main_Intensity;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;79;-1232.266,-407.4266;Inherit;False;Property;_USE_CubeMap;USE_CubeMap;25;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;120;-1035.478,-315.1652;Inherit;False;Property;_USE_Power;USE_Power;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;119;-715.4783,-168.1652;Inherit;False;Property;_USE_Intensity;USE_Intensity;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1908.925,931.1569;Inherit;False;Property;_Alpha_Intensity;Alpha_Intensity;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;8;9;20;0
WireConnection;8;28;29;0
WireConnection;9;0;8;2
WireConnection;9;1;8;26
WireConnection;70;0;19;0
WireConnection;70;1;68;0
WireConnection;35;0;1;0
WireConnection;35;1;42;0
WireConnection;35;2;43;0
WireConnection;35;3;39;0
WireConnection;19;0;23;0
WireConnection;19;1;18;0
WireConnection;68;0;69;0
WireConnection;68;1;72;0
WireConnection;72;0;67;0
WireConnection;20;0;70;0
WireConnection;20;1;24;0
WireConnection;29;0;24;4
WireConnection;29;1;71;0
WireConnection;25;0;10;1
WireConnection;25;1;26;1
WireConnection;84;0;86;0
WireConnection;84;1;83;0
WireConnection;86;0;85;1
WireConnection;86;1;47;1
WireConnection;83;0;47;2
WireConnection;83;1;85;2
WireConnection;48;0;46;0
WireConnection;48;2;49;0
WireConnection;49;0;50;0
WireConnection;49;1;51;0
WireConnection;75;0;74;1
WireConnection;75;1;26;4
WireConnection;45;0;44;1
WireConnection;45;1;25;0
WireConnection;45;2;75;0
WireConnection;28;0;81;0
WireConnection;81;0;45;0
WireConnection;81;1;82;0
WireConnection;111;0;28;0
WireConnection;111;1;66;0
WireConnection;110;0;111;0
WireConnection;63;0;64;0
WireConnection;63;1;28;0
WireConnection;109;1;116;0
WireConnection;109;0;65;0
WireConnection;65;0;66;0
WireConnection;65;1;28;0
WireConnection;116;0;110;0
WireConnection;67;0;80;0
WireConnection;67;1;109;0
WireConnection;80;1;28;0
WireConnection;80;0;63;0
WireConnection;71;0;80;0
WireConnection;10;1;48;0
WireConnection;74;1;76;0
WireConnection;44;1;84;0
WireConnection;77;1;1;0
WireConnection;33;1;35;0
WireConnection;18;0;17;0
WireConnection;18;1;119;0
WireConnection;17;0;79;0
WireConnection;17;1;120;0
WireConnection;79;1;33;0
WireConnection;79;0;77;0
WireConnection;120;1;73;3
WireConnection;120;0;121;0
WireConnection;119;1;73;2
WireConnection;119;0;122;0
ASEEND*/
//CHKSM=217B68E27079D06AEC72D675684652399D86EA70