// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/CutScene/VFX/VFX_Main_Offset_Distortion_ShockWave"
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
		[Header(tcd1.x     MainTex_X_Offset)][Header(tcd1.y     MainTex_Y_Offset)][Header(tcd1.z     Dissolve)][Header(tcd1.w     Distortion)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Main_Color("Main_Color", Color) = (1,1,1,1)
		[HDR]_Sub_Color("Sub_Color", Color) = (0.5,0.5,0.5,1)
		_Color_Offset("Color_Offset", Float) = 1
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
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


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Main_Color;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _Sub_Color;
			float4 _MaskTex_ST;
			float _Intensity_Color;
			float _Color_Range;
			float _Color_Offset;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _NearPlaneAlpha;
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

				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord4 = screenPos;

				output.ase_texcoord3 = input.ase_texcoord1;
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
				float2 appendResult14 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner13 = ( 1.0 * _Time.y * appendResult14 + uv_NoiseTex);
				float4 tex2DNode8 = tex2D( _NoiseTex, panner13 );
				float2 appendResult11 = (float2(tex2DNode8.r , tex2DNode8.g));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult18 = (float2(( uv_MainTex.x + input.ase_texcoord3.x ) , ( uv_MainTex.y + input.ase_texcoord3.y )));
				float4 tex2DNode9 = tex2D( _MainTex, ( ( appendResult11 * input.ase_texcoord3.w ) + appendResult18 ) );
				float4 lerpResult43 = lerp( _Sub_Color , _Main_Color , saturate( ( saturate( pow( tex2DNode9.g , _Color_Offset ) ) * _Color_Range ) ));
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 appendResult32_g36 = (float4(( ( lerpResult43 * _Intensity_Color ) * input.ase_color ).rgb , ( input.ase_color.a * saturate( ( saturate( ( ( tex2DNode8.r + input.ase_texcoord3.z ) * tex2D( _MaskTex, uv_MaskTex ).r * tex2DNode9.g ) ) * _Intensity_Alpha ) ) )));
				half4 finalColor92_g36 = appendResult32_g36;
				half3 positionWS92_g36 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
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
Node;AmplifyShaderEditor.CommentaryNode;2;808.0756,43.37338;Inherit;False;204;375;Rendering Options;4;6;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;840.0756,171.3734;Inherit;False;Property;_BlendDst;Blend Dst;27;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;840.0756,331.3734;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;840.0756,251.3734;Inherit;False;Property;_CullMode;Cull Mode;28;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1815.73,-290.116;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1607.73,-320.116;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1981.73,-276.116;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1970.73,-170.116;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-2522.377,-661.853;Inherit;True;Property;_NoiseTex;NoiseTex;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;13;-2751.331,-634.0158;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-2949.331,-453.0159;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-2223.33,-636.0158;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1841.236,-567.1761;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2248.107,-382.1143;Inherit;False;Property;_Noise_Strength;Noise_Strength;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;20;-2291.73,-106.116;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;25;-923.1069,-439.1143;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-759.0922,-435.1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-576.1069,-437.1143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;42;-416.0922,-439.1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-654.0922,-886.1552;Inherit;False;Property;_Sub_Color;Sub_Color;20;1;[HDR];Create;True;0;0;0;False;0;False;0.5,0.5,0.5,1;0.5,0.5,0.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1087.23,-344.3341;Inherit;False;Property;_Color_Offset;Color_Offset;21;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;-243.0922,-728.1552;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-760.2305,-341.3341;Inherit;False;Property;_Color_Range;Color_Range;22;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;46.46979,-596.8709;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;705.5893,-251.7935;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/CutScene/VFX/VFX_Main_Offset_Distortion_ShockWave;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.FunctionNode;7;428.2896,-247.4354;Inherit;False;MMN_CommonOutputs;0;;36;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-947.3534,-46.52815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;33;-1264,-43.46889;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-750.3071,72.45262;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-278.3387,103.1181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-472.3388,98.11805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;37;-97.33862,105.1181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;46.74355,-268.4415;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;258.9113,-361.9421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;263.9113,-107.9421;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2270.73,-270.116;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-3020.331,-641.0158;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1226.997,183.8816;Inherit;True;Property;_MaskTex;MaskTex;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1512.492,204.0073;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-516.3387,223.1181;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;840.0756,91.37338;Inherit;False;Property;_BlendSrc;Blend Src;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-655.0922,-654.1552;Inherit;False;Property;_Main_Color;Main_Color;19;1;[HDR];Create;True;0;0;0;False;3;Header(Color);Space();;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-178.8147,-459.3893;Inherit;False;Property;_Intensity_Color;Intensity_Color;23;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-3161.331,-450.0159;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3141.331,-360.0159;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1365.848,-347.0565;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;5;;;;;;0;0;False;6;Header(tcd1.x     MainTex_X_Offset);Header(tcd1.y     MainTex_Y_Offset);Header(tcd1.z     Dissolve);Header(tcd1.w     Distortion);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;18;0;21;0
WireConnection;18;1;22;0
WireConnection;17;0;23;0
WireConnection;17;1;18;0
WireConnection;21;0;19;1
WireConnection;21;1;20;1
WireConnection;22;0;19;2
WireConnection;22;1;20;2
WireConnection;8;1;13;0
WireConnection;13;0;12;0
WireConnection;13;2;14;0
WireConnection;14;0;15;0
WireConnection;14;1;16;0
WireConnection;11;0;8;1
WireConnection;11;1;8;2
WireConnection;23;0;11;0
WireConnection;23;1;20;4
WireConnection;25;0;9;2
WireConnection;25;1;29;0
WireConnection;41;0;25;0
WireConnection;26;0;41;0
WireConnection;26;1;30;0
WireConnection;42;0;26;0
WireConnection;43;0;40;0
WireConnection;43;1;44;0
WireConnection;43;2;42;0
WireConnection;45;0;43;0
WireConnection;45;1;46;0
WireConnection;1;0;7;2
WireConnection;1;1;7;26
WireConnection;7;9;48;0
WireConnection;7;28;49;0
WireConnection;31;0;8;1
WireConnection;31;1;33;3
WireConnection;28;0;31;0
WireConnection;28;1;10;1
WireConnection;28;2;9;2
WireConnection;35;0;36;0
WireConnection;35;1;38;0
WireConnection;36;0;28;0
WireConnection;37;0;35;0
WireConnection;48;0;45;0
WireConnection;48;1;47;0
WireConnection;49;0;47;4
WireConnection;49;1;37;0
WireConnection;10;1;50;0
WireConnection;9;1;17;0
ASEEND*/
//CHKSM=A8DD81C155A76B3F6C7981AF41DF72B3EFEE0CC5