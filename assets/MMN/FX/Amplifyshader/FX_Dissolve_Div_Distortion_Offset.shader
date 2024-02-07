// Made with Amplify Shader Editor v1.9.0.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_Offset"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.wlx     AlphaTex Offset Power)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		_Twist("Twist", Float) = 0
		[Header(Distortion)][Space()]_XY_PowerZW_Offset("XY_Power ZW_Offset", Vector) = (1,1,-0.5,-0.5)
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[ASEEnd]_Intensity_Alpha("Intensity_Alpha", Float) = 1
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

		UsePass "MMN/FX/AddPass/ShadowCaster"

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
			sampler2D _MaskTex;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaTex_ST;
			float4 _MaskTex_ST;
			float4 _XY_PowerZW_Offset;
			float4 _NoiseTex_ST;
			float4 _SubColor;
			float4 _MainColor;
			float4 _MainTex_ST;
			float _LightRatio;
			float _ColorGradation;
			float _Use_G_Channel_Alpha;
			float _Twist;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Color_Offset;
			float _Intensity_Color;
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
				float localApplySoftParticle80_g9 = ( 0.0 );
				float localApplyLightColor6_g9 = ( 0.0 );
				float localApplyShadowAtten104_g9 = ( 0.0 );
				half localApplyRaycastingAlpha92_g9 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult163 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult164 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + ( uv_NoiseTex.x * _Twist ) )));
				float2 panner165 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult163 + appendResult164);
				float4 tex2DNode167 = tex2D( _NoiseTex, panner165 );
				float2 appendResult172 = (float2(( ( tex2DNode167.r + _XY_PowerZW_Offset.z ) * _XY_PowerZW_Offset.x ) , ( ( tex2DNode167.g + _XY_PowerZW_Offset.w ) * _XY_PowerZW_Offset.y )));
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 tex2DNode128 = tex2D( _MainTex, ( uv_MainTex + ( appendResult172 * tex2D( _MaskTex, uv_MaskTex ).g ) ) );
				float lerpResult133 = lerp( tex2DNode128.a , tex2DNode128.g , _Use_G_Channel_Alpha);
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult175 = (float2(input.uv0.w , input.ase_texcoord3.x));
				float temp_output_135_0 = ( ( lerpResult133 * tex2D( _AlphaTex, ( uv_AlphaTex + appendResult175 ) ).g ) - input.uv0.z );
				float2 texCoord185 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult186 = lerp( temp_output_135_0 , texCoord185.x , _ColorGradation);
				float4 lerpResult144 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult186 ) * _Color_Range ) ));
				float4 lerpResult151 = lerp( ( lerpResult144 * tex2DNode128 ) , lerpResult144 , _Use_G_Channel_Alpha);
				float4 appendResult32_g9 = (float4(( _Intensity_Color * lerpResult151 * input.ase_color ).rgb , ( (lerpResult144).a * saturate( ( ( temp_output_135_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * input.ase_color.a )));
				half4 finalColor92_g9 = appendResult32_g9;
				half3 positionWS92_g9 = input.positionWS;
				float4 screenPos = input.ase_texcoord4;
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

	Fallback "Off"
}
/*ASEBEGIN
Version=19002
-26;103.3333;2560;1275.667;4609.734;607.8668;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;156;-3824,-176;Inherit;False;Property;_Twist;Twist;18;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;189;-4000.825,-440.5277;Inherit;False;0;167;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-3664,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-3536,176;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;17;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-3536,96;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;16;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;161;-3520,-208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;163;-3360,96;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;164;-3392,-272;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;162;-3376,272;Inherit;False;MMN_Time;-1;;8;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;165;-3184,32;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;167;-2993.3,33.3;Inherit;True;Property;_NoiseTex;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;166;-2912,256;Inherit;False;Property;_XY_PowerZW_Offset;XY_Power ZW_Offset;19;0;Create;True;1;Header(Distortion);0;0;False;2;Header(Distortion);Space();False;1,1,-0.5,-0.5;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;168;-2656,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;182;-2636.517,334;Inherit;False;552.2266;266.8713;MaskTex;2;123;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;-2656,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-2432,-32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;120;-2608,384;Inherit;False;0;123;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-2432,80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;123;-2384,384;Inherit;True;Property;_MaskTex;MaskTex;20;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;172;-2288,-32;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;181;-2146,686;Inherit;False;882;577;AlphaTex;6;173;174;175;176;177;178;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;124;-2304,-288;Inherit;False;0;128;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;174;-2096,880;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2128,-32;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;173;-2096,1056;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-2064,-288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;126;-1536,-224;Inherit;False;268.7578;251.2733;Switch;2;133;130;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;175;-1888,880;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;176;-1968,736;Inherit;False;0;178;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;128;-1920,-288;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.wlx     AlphaTex Offset Power);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;130;-1520,-48;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-1728,736;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;133;-1504,-176;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-1584,736;Inherit;True;Property;_AlphaTex;AlphaTex;21;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;129;-1280,144;Inherit;False;555.6001;278.9999;CustomData Dissolve_Divide;4;143;141;135;131;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;183;-1872,-816;Inherit;False;422.6843;276.8151;Color Gradation;3;186;185;184;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;131;-1264,256;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-1280,48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;185;-1840,-688;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;135;-1008,208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-1440,-944;Inherit;False;830.4828;643.692;2Color;8;144;142;140;139;138;137;136;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;184;-1840,-768;Inherit;False;Property;_ColorGradation;Color Gradation;22;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;186;-1616,-768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-1424,-496;Inherit;False;Property;_Color_Offset;Color_Offset;25;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-1232,-496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-1232,-384;Inherit;False;Property;_Color_Range;Color_Range;26;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;138;-1072,-496;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;142;-992,-896;Inherit;False;Property;_SubColor;Sub Color;24;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;139;-928,-496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;141;-1008,320;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;140;-992,-688;Inherit;False;Property;_MainColor;Main Color;23;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;144;-752,-624;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-688,272;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;143;-848,208;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;147;-368,-400;Inherit;False;181.6049;183.8025;Switch;1;151;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-480,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-560,-320;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-304,-512;Inherit;False;Property;_Intensity_Color;Intensity_Color;27;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;149;-560,-16;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;150;-336,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;153;-336,-192;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;151;-336,-352;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-96,-336;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-96,-48;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;85;313.847,-61.39833;Inherit;False;204;375;Rendering Options;4;89;87;86;187;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;86;345.8473,146.6021;Inherit;False;Property;_CullMode;Cull Mode;32;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;90;67.26201,-209.2646;Inherit;False;MMN_CommonOutputs;0;;9;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;187;347.4407,227.963;Inherit;False;Property;_ZTest;Z Test;28;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;344.8473,66.60173;Inherit;False;Property;_BlendDst;Blend Dst;31;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;345.8473,-13.39828;Inherit;False;Property;_BlendSrc;Blend Src;30;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;92;311.3293,-210.9366;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;13;MMN/FX/Amplify shader/FX_Dissolve_Div_Distortion_Offset;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Off;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;158;0;189;1
WireConnection;158;1;156;0
WireConnection;161;0;189;2
WireConnection;161;1;158;0
WireConnection;163;0;159;0
WireConnection;163;1;160;0
WireConnection;164;0;189;1
WireConnection;164;1;161;0
WireConnection;165;0;164;0
WireConnection;165;2;163;0
WireConnection;165;1;162;0
WireConnection;167;1;165;0
WireConnection;168;0;167;2
WireConnection;168;1;166;4
WireConnection;169;0;167;1
WireConnection;169;1;166;3
WireConnection;171;0;169;0
WireConnection;171;1;166;1
WireConnection;170;0;168;0
WireConnection;170;1;166;2
WireConnection;123;1;120;0
WireConnection;172;0;171;0
WireConnection;172;1;170;0
WireConnection;125;0;172;0
WireConnection;125;1;123;2
WireConnection;127;0;124;0
WireConnection;127;1;125;0
WireConnection;175;0;174;4
WireConnection;175;1;173;1
WireConnection;128;1;127;0
WireConnection;177;0;176;0
WireConnection;177;1;175;0
WireConnection;133;0;128;4
WireConnection;133;1;128;2
WireConnection;133;2;130;0
WireConnection;178;1;177;0
WireConnection;179;0;133;0
WireConnection;179;1;178;2
WireConnection;135;0;179;0
WireConnection;135;1;131;3
WireConnection;186;0;135;0
WireConnection;186;1;185;1
WireConnection;186;2;184;0
WireConnection;137;0;134;0
WireConnection;137;1;186;0
WireConnection;138;0;137;0
WireConnection;138;1;136;0
WireConnection;139;0;138;0
WireConnection;141;0;131;3
WireConnection;144;0;142;0
WireConnection;144;1;140;0
WireConnection;144;2;139;0
WireConnection;143;0;135;0
WireConnection;143;1;141;0
WireConnection;146;0;143;0
WireConnection;146;1;145;0
WireConnection;148;0;144;0
WireConnection;148;1;128;0
WireConnection;149;0;144;0
WireConnection;150;0;146;0
WireConnection;151;0;148;0
WireConnection;151;1;144;0
WireConnection;151;2;130;0
WireConnection;154;0;152;0
WireConnection;154;1;151;0
WireConnection;154;2;153;0
WireConnection;155;0;149;0
WireConnection;155;1;150;0
WireConnection;155;2;153;4
WireConnection;90;9;154;0
WireConnection;90;28;155;0
WireConnection;92;0;90;2
WireConnection;92;1;90;26
ASEEND*/
//CHKSM=0FDDD259DC4BFA271837CD1B08D568514B73DABD