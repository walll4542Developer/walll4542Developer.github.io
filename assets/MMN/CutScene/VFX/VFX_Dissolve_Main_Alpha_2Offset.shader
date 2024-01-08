// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/CutScene/VFX/VFX_Dissolve_Main_Alpha_2Offset"
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
		[Header(tcd2.x     Dissolve)][Header(tcd2.zlw     MainTex Offset)][Header(tcd4.zlw     AlphaTex Offset)][Header(Main Texture)][Space()]_MainTex1("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha1("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex1("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		_Twist("Twist", Float) = 0
		_AlphaTex("AlphaTex", 2D) = "white" {}
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		[HideInInspector][Enum(Default,2,Always,6)]_ZTest("Z Test", Float) = 2
		_MainColor1("Main Color", Color) = (1,1,1,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color1("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1

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


			sampler2D _MainTex1;
			sampler2D _NoiseTex1;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaTex_ST;
			float4 _NoiseTex1_ST;
			float4 _MainColor1;
			float4 _MainTex1_ST;
			float4 _SubColor;
			float _LightRatio;
			float _ColorGradation;
			float _Twist;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Color_Offset;
			float _Use_G_Channel_Alpha1;
			float _Intensity_Color1;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _Color_Range;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord5 = screenPos;

				output.ase_texcoord3 = input.ase_texcoord1;
				output.ase_color = input.color;
				output.ase_texcoord4 = input.ase_texcoord3;
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
				float localApplySoftParticle80_g9 = ( 0.0 );
				float localApplyLightColor6_g9 = ( 0.0 );
				float localApplyShadowAtten104_g9 = ( 0.0 );
				half localApplyRaycastingAlpha92_g9 = ( 0.0 );
				float2 uv_MainTex1 = input.uv0.xy * _MainTex1_ST.xy + _MainTex1_ST.zw;
				float2 appendResult80 = (float2(input.ase_texcoord3.z , input.ase_texcoord3.w));
				float4 tex2DNode41 = tex2D( _MainTex1, ( uv_MainTex1 + appendResult80 ) );
				float4 lerpResult68 = lerp( ( tex2DNode41 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha1);
				float lerpResult44 = lerp( tex2DNode41.a , tex2DNode41.g , _Use_G_Channel_Alpha1);
				float2 appendResult37 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex1 = input.uv0.xy * _NoiseTex1_ST.xy + _NoiseTex1_ST.zw;
				float2 appendResult39 = (float2(uv_NoiseTex1.x , ( uv_NoiseTex1.y + ( uv_NoiseTex1.x * _Twist ) )));
				float2 panner40 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult37 + appendResult39);
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult86 = (float2(input.ase_texcoord4.z , input.ase_texcoord4.w));
				float temp_output_51_0 = ( ( lerpResult44 * tex2D( _NoiseTex1, panner40 ).g * tex2D( _AlphaTex, ( uv_AlphaTex + appendResult86 ) ).g ) - input.ase_texcoord3.x );
				float2 texCoord49 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult53 = lerp( temp_output_51_0 , texCoord49.x , _ColorGradation);
				float4 lerpResult66 = lerp( _SubColor , _MainColor1 , saturate( ( ( _Color_Offset + lerpResult53 ) * _Color_Range ) ));
				float4 appendResult32_g9 = (float4(( _Intensity_Color1 * lerpResult68 * lerpResult66 ).rgb , ( input.ase_color.a * saturate( ( ( temp_output_51_0 / ( 1.0 - input.ase_texcoord3.x ) ) * _Intensity_Alpha ) ) * (lerpResult66).a )));
				half4 finalColor92_g9 = appendResult32_g9;
				half3 positionWS92_g9 = input.positionWS;
				float4 screenPos = input.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g9 = ase_screenPosNorm;
				half4 screenPos92_g9 = ase_screenPosNorm;
				half nearPlane92_g9 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g9 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g9 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g9 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g9 , positionWS92_g9 , screenUV92_g9 , screenPos92_g9 , nearPlane92_g9 , nearPlaneInvertDistance92_g9 , raycastHarftoneClip92_g9 , raycastMinimumAlpha92_g9 );
				float4 finalColor104_g9 = finalColor92_g9;
				float4 shadowCoord104_g9 = input.uv0;
				float3 positionWS104_g9 = input.positionWS;
				float lightRatio104_g9 = _LightRatio;
				ApplyShadowAtten( finalColor104_g9 , shadowCoord104_g9 , positionWS104_g9 , lightRatio104_g9 );
				float4 finalColor6_g9 = finalColor104_g9;
				float3 normalWS6_g9 = input.normalWS;
				float lightRatio6_g9 = _LightRatio;
				ApplyLightColor( finalColor6_g9 , normalWS6_g9 , lightRatio6_g9 );
				float4 finalColor80_g9 = finalColor6_g9;
				float near80_g9 = _SoftParticleNearFadeDistance;
				float far80_g9 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g9 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g9 = ( 0.0 );
				float4 positionCS58_g9 = float4( 0,0,0,0 );
				float4 positionNDC58_g9 = float4( 0,0,0,0 );
				float3 positionOS58_g9 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g9 , positionNDC58_g9 , positionOS58_g9 );
				float4 positionNDC80_g9 = positionNDC58_g9;
				ApplySoftParticle( finalColor80_g9 , near80_g9 , far80_g9 , fadeOutRange80_g9 , positionNDC80_g9 );
				float4 break64_g9 = finalColor80_g9;
				float3 appendResult76_g9 = (float3(break64_g9.x , break64_g9.y , break64_g9.z));

				float3 Color = appendResult76_g9;
				float Alpha = break64_g9.w;

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
Node;AmplifyShaderEditor.CommentaryNode;20;-164.6812,1841.006;Inherit;False;204;375;Rendering Options;4;25;24;23;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-1844.667,1420.468;Inherit;False;238.7762;259.8605;Switch;1;44;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2250.724,805.4677;Inherit;False;422.6843;276.8151;Color Gradation;3;53;50;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-2218.724,933.4677;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;50;-2218.724,853.4677;Inherit;False;Property;_ColorGradation;Color Gradation;23;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-1381.748,1547.787;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1788.747,929.5502;Inherit;False;Property;_Color_Offset;Color_Offset;27;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;53;-1994.724,853.4677;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1596.747,929.5502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1596.747,1041.55;Inherit;False;Property;_Color_Range;Color_Range;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;56;-1357.724,1741.468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1436.747,929.5502;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;-1133.724,1629.468;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;60;-1356.748,561.5507;Inherit;False;Property;_SubColor;Sub Color;26;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;61;-1292.748,929.5502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;62;-1356.748,737.5502;Inherit;False;Property;_MainColor1;Main Color;25;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-1133.724,1741.468;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;30;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1066.749,1189.296;Inherit;False;187.9032;189.0854;Switch;1;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-944.7242,1630.468;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;66;-1084.748,833.5502;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1230.086,1240.719;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;68;-1038.086,1239.296;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;69;-765.7242,1629.468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;70;-785.9825,868.3774;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-818.7482,1016.671;Inherit;False;Property;_Intensity_Color1;Intensity_Color;29;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-583.3317,1427.446;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-589.7242,1629.468;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-2482.724,1354.468;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-2322.724,1226.468;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;86;-2588.423,2427.312;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-2428.423,2299.312;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2759.782,2150.805;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2759.782,2070.805;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;16;0;Create;True;0;0;0;False;0;False;1;-0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-2583.782,2070.805;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;40;-2391.782,1942.805;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2885.322,1845.945;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-3299.322,2041.945;Inherit;False;Property;_Twist;Twist;20;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-3131.322,1975.945;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1533.724,1621.468;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-1744.724,1465.468;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;59;-1431.891,1360.045;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-2167.724,1895.368;Inherit;True;Property;_NoiseTex1;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;89;-2290.423,2290.362;Inherit;True;Property;_AlphaTex;AlphaTex;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-2690.724,1226.468;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-2157.724,1373.468;Inherit;True;Property;_MainTex1;MainTex;13;0;Create;True;0;0;0;False;5;Header(tcd2.x     Dissolve);Header(tcd2.zlw     MainTex Offset);Header(tcd4.zlw     AlphaTex Offset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;39;-2613.481,1710.323;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;48;-1739.724,1883.468;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;29;-163.5636,1430.704;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;21;MMN/CutScene/VFX/VFX_Dissolve_Main_Alpha_2Offset;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2049.252,1657.365;Inherit;False;Property;_Use_G_Channel_Alpha1;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-2794.831,2299.312;Inherit;False;0;89;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;36;-2533.761,2184.868;Inherit;False;MMN_Time;-1;;8;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-435.8893,1428.379;Inherit;False;MMN_CommonOutputs;0;;9;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;21;-132.6812,1889.006;Inherit;False;Property;_BlendSrc;Blend Src;18;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-132.6812,1969.006;Inherit;False;Property;_BlendDst;Blend Dst;19;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-132.6812,2049.006;Inherit;False;Property;_CullMode;Cull Mode;22;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-132.6812,2129.006;Inherit;False;Property;_ZTest;Z Test;24;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;83;-2731.724,1352.468;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;84;-2725.724,1525.468;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;91;-2866.423,2422.312;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;90;-2860.423,2596.644;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-3339.089,1637.724;Inherit;True;0;45;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;51;0;47;0
WireConnection;51;1;48;1
WireConnection;53;0;51;0
WireConnection;53;1;49;1
WireConnection;53;2;50;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;56;0;48;1
WireConnection;57;0;54;0
WireConnection;57;1;55;0
WireConnection;58;0;51;0
WireConnection;58;1;56;0
WireConnection;61;0;57;0
WireConnection;65;0;58;0
WireConnection;65;1;63;0
WireConnection;66;0;60;0
WireConnection;66;1;62;0
WireConnection;66;2;61;0
WireConnection;67;0;41;0
WireConnection;67;1;59;0
WireConnection;68;0;67;0
WireConnection;68;1;59;0
WireConnection;68;2;42;0
WireConnection;69;0;65;0
WireConnection;70;0;66;0
WireConnection;72;0;71;0
WireConnection;72;1;68;0
WireConnection;72;2;66;0
WireConnection;74;0;59;4
WireConnection;74;1;69;0
WireConnection;74;2;70;0
WireConnection;80;0;83;3
WireConnection;80;1;84;4
WireConnection;82;0;81;0
WireConnection;82;1;80;0
WireConnection;86;0;91;3
WireConnection;86;1;90;4
WireConnection;88;0;87;0
WireConnection;88;1;86;0
WireConnection;37;0;35;0
WireConnection;37;1;33;0
WireConnection;40;0;39;0
WireConnection;40;2;37;0
WireConnection;40;1;36;0
WireConnection;34;0;30;2
WireConnection;34;1;32;0
WireConnection;32;0;30;1
WireConnection;32;1;31;0
WireConnection;47;0;44;0
WireConnection;47;1;45;2
WireConnection;47;2;89;2
WireConnection;44;0;41;4
WireConnection;44;1;41;2
WireConnection;44;2;42;0
WireConnection;45;1;40;0
WireConnection;89;1;88;0
WireConnection;41;1;82;0
WireConnection;39;0;30;1
WireConnection;39;1;34;0
WireConnection;29;0;75;2
WireConnection;29;1;75;26
WireConnection;75;9;72;0
WireConnection;75;28;74;0
ASEEND*/
//CHKSM=83F4F8400089034CF8B16B463CC1285382AB3A99