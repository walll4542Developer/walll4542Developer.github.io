// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/VFX/Amplify shader/FX_SpeedLine"
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
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle][Header(Line Options)][Space()]_LineStyle("Line Style (Polar / Rotator)", Float) = 0
		[Toggle]_LineMask("Line Mask (Full / Half)", Float) = 0
		_LineRotatorDegrees("Line Rotator Degrees", Range( 0 , 360)) = 0
		_LineMaskIntensity("Line Mask Intensity", Float) = 1
		_LineMaskRange("Line Mask Range", Range( -2 , 2)) = 0.5
		_LineOffSet("Line OffSet", Float) = 0
		[Toggle][Header(Mask Options)][Space(10)]_LineCenterMask("Use Mask?", Float) = 0
		[Toggle]_MaskShape("Mask Shape (Center / Quad)", Float) = 0
		_CenterMaskRotatorDegrees("Mask Rotator Degrees", Range( 0 , 360)) = 0
		_CenterMaskRange("Center Mask Range", Range( 0 , 1)) = 0.5
		_MaskSharpness("Quad Mask Sharpness", Range( 0 , 1)) = 0
		_VerticalMaskRange("Quad Mask Vertical  Range", Range( 0 , 1)) = 0
		_HorizontalMaskRange("Quad Mask Horizontal  Range", Range( 0 , 1)) = 0
		[Header(Main Property)][Space()]_MainXSpeed("Main X Speed", Float) = 0
		_MainYSpeed("Main Y Speed", Float) = 0
		[Space()]_MainRadialScale("Main Radial Scale ", Float) = 0
		_MainLengthScale("Main Length Scale ", Float) = 5
		[Header(SubTexture)][Space()]_SubTex("SubTex", 2D) = "white" {}
		[Header(Sub Property)][Space()]_SubXSpeed("Sub X Speed", Float) = 1
		_SubYSpeed("Sub Y Speed", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Space()]_SubRadialScale("Sub Radial Scale", Float) = 1
		_SubLengthScale("Sub Length Scale", Float) = 1
		[HDR][Header(Intensity)][Space()]_Color("Color", Color) = (1,1,1,1)
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


			sampler2D _SubTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float _LightRatio;
			float _HorizontalMaskRange;
			float _MaskSharpness;
			float _LineCenterMask;
			float _CenterMaskRotatorDegrees;
			float _CenterMaskRange;
			float _LineMask;
			float _LineMaskIntensity;
			float _LineMaskRange;
			float _Use_G_Channel_Alpha;
			float _LineOffSet;
			float _MainLengthScale;
			float _MainRadialScale;
			float _MainYSpeed;
			float _MainXSpeed;
			float _LineStyle;
			float _LineRotatorDegrees;
			float _SubLengthScale;
			float _SubRadialScale;
			float _SubYSpeed;
			float _SubXSpeed;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _VerticalMaskRange;
			float _MaskShape;
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
				float localApplySoftParticle80_g36 = ( 0.0 );
				float localApplyLightColor6_g36 = ( 0.0 );
				float localApplyShadowAtten104_g36 = ( 0.0 );
				half localApplyRaycastingAlpha92_g36 = ( 0.0 );
				float2 appendResult208 = (float2(_SubXSpeed , _SubYSpeed));
				float2 localScreenRatio428 = ScreenRatio(  );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 break431 = ase_screenPosNorm;
				float2 appendResult434 = (float2(break431.x , break431.y));
				float2 RawScreenPosition459 = appendResult434;
				float2 _Vertical = float2(0.5,0);
				float2 ifLocalVar547 = 0;
				if( _ScreenParams.x <= _ScreenParams.y )
				ifLocalVar547 = _Vertical;
				else
				ifLocalVar547 = float2( 0,0.5 );
				float2 localScreenOffset518 = ScreenOffset(  );
				float2 ScreenUV553 = ( ( ( localScreenRatio428 * RawScreenPosition459 ) + ifLocalVar547 ) - localScreenOffset518 );
				float2 CenteredUV15_g35 = ( ScreenUV553 - float2( 0.5,0.5 ) );
				float2 break17_g35 = CenteredUV15_g35;
				float2 appendResult23_g35 = (float2(( length( CenteredUV15_g35 ) * _SubRadialScale * 2.0 ) , ( atan2( break17_g35.x , break17_g35.y ) * ( 1.0 / TWO_PI ) * _SubLengthScale )));
				float Rotator269 = ( ( ( 2.0 / 360.0 ) * _LineRotatorDegrees ) * PI );
				float cos258 = cos( Rotator269 );
				float sin258 = sin( Rotator269 );
				float2 rotator258 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos258 , -sin258 , sin258 , cos258 )) + float2( 0.5,0.5 );
				float2 appendResult262 = (float2(_SubRadialScale , _SubLengthScale));
				float LineStlyeSwitch275 = _LineStyle;
				float2 lerpResult285 = lerp( appendResult23_g35 , ( rotator258 * appendResult262 ) , LineStlyeSwitch275);
				float2 panner209 = ( 1.0 * _Time.y * appendResult208 + lerpResult285);
				float Time282 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 appendResult170 = (float2(_MainXSpeed , _MainYSpeed));
				float2 CenteredUV15_g34 = ( ScreenUV553 - float2( 0.5,0.5 ) );
				float2 break17_g34 = CenteredUV15_g34;
				float2 appendResult23_g34 = (float2(( length( CenteredUV15_g34 ) * _MainRadialScale * 2.0 ) , ( atan2( break17_g34.x , break17_g34.y ) * ( 1.0 / TWO_PI ) * _MainLengthScale )));
				float cos268 = cos( Rotator269 );
				float sin268 = sin( Rotator269 );
				float2 rotator268 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos268 , -sin268 , sin268 , cos268 )) + float2( 0.5,0.5 );
				float2 appendResult264 = (float2(_MainRadialScale , _MainLengthScale));
				float2 lerpResult274 = lerp( ( appendResult23_g34 + _LineOffSet ) , ( ( rotator268 * appendResult264 ) + _LineOffSet ) , LineStlyeSwitch275);
				float2 panner169 = ( Time282 * appendResult170 + lerpResult274);
				float4 tex2DNode5 = tex2D( _MainTex, panner169 );
				float lerpResult248 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float2 break455 = ScreenUV553;
				float2 appendResult456 = (float2(break455.x , break455.y));
				float LineMaskRange329 = ( _LineMaskRange + input.uv0.xyz.z );
				float cos555 = cos( Rotator269 );
				float sin555 = sin( Rotator269 );
				float2 rotator555 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos555 , -sin555 , sin555 , cos555 )) + float2( 0.5,0.5 );
				float lerpResult301 = lerp( ( ( length( ( appendResult456 - float2( 0.5,0.5 ) ) ) - LineMaskRange329 ) * _LineMaskIntensity ) , ( ( 1.0 - ( ( rotator555.x + LineMaskRange329 ) * ( ( 1.0 - rotator555.x ) + LineMaskRange329 ) ) ) * _LineMaskIntensity ) , LineStlyeSwitch275);
				float cos564 = cos( Rotator269 );
				float sin564 = sin( Rotator269 );
				float2 rotator564 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos564 , -sin564 , sin564 , cos564 )) + float2( 0.5,0.5 );
				float smoothstepResult386 = smoothstep( 0.0 , 0.2 , saturate( rotator564.x ));
				float LineMaskSwitch390 = _LineMask;
				float lerpResult389 = lerp( 1.0 , smoothstepResult386 , LineMaskSwitch390);
				float MaskRotatorDegrees421 = ( ( ( 2.0 / 360.0 ) * _CenterMaskRotatorDegrees ) * PI );
				float cos424 = cos( MaskRotatorDegrees421 );
				float sin424 = sin( MaskRotatorDegrees421 );
				float2 rotator424 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos424 , -sin424 , sin424 , cos424 )) + float2( 0.5,0.5 );
				float smoothstepResult400 = smoothstep( 0.0 , _CenterMaskRange , abs( ( rotator424 - float2( 0.5,0 ) ).x ));
				float LineCenterMask405 = _LineCenterMask;
				float lerpResult402 = lerp( 1.0 , smoothstepResult400 , LineCenterMask405);
				float cos567 = cos( Rotator269 );
				float sin567 = sin( Rotator269 );
				float2 rotator567 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos567 , -sin567 , sin567 , cos567 )) + float2( 0.5,0.5 );
				float smoothstepResult572 = smoothstep( 0.49 , 0.51 , saturate( rotator567.x ));
				float lerpResult574 = lerp( 1.0 , smoothstepResult572 , LineMaskSwitch390);
				float Mask_Smoothness613 = ( _MaskSharpness * 0.5 );
				float cos578 = cos( MaskRotatorDegrees421 );
				float sin578 = sin( MaskRotatorDegrees421 );
				float2 rotator578 = mul( ScreenUV553 - float2( 0.5,0.5 ) , float2x2( cos578 , -sin578 , sin578 , cos578 )) + float2( 0.5,0.5 );
				float2 break579 = ( rotator578 - float2( 0.5,0.5 ) );
				float Horizontal_Mask_Range611 = ( ( ( 1.0 - _HorizontalMaskRange ) * 2.0 ) - 1.0 );
				float Vertical_Mask_Range612 = ( ( ( 1.0 - _VerticalMaskRange ) * 2.0 ) - 1.0 );
				float smoothstepResult591 = smoothstep( Mask_Smoothness613 , ( 1.0 - Mask_Smoothness613 ) , max( saturate( ( abs( break579.x ) + Horizontal_Mask_Range611 ) ) , saturate( ( abs( break579.y ) + Vertical_Mask_Range612 ) ) ));
				float lerpResult570 = lerp( 1.0 , smoothstepResult591 , LineCenterMask405);
				float MaskShapeSwitch597 = _MaskShape;
				float lerpResult599 = lerp( ( lerpResult389 * lerpResult402 ) , ( lerpResult574 * lerpResult570 ) , MaskShapeSwitch597);
				float temp_output_153_0 = saturate( ( ( ( ( tex2D( _SubTex, panner209 ).g * lerpResult248 ) + lerpResult301 ) * lerpResult599 ) * 10.0 ) );
				float4 appendResult32_g36 = (float4(( _Color * input.ase_color * temp_output_153_0 ).rgb , ( _Color.a * input.ase_color.a * temp_output_153_0 )));
				half4 finalColor92_g36 = appendResult32_g36;
				half3 positionWS92_g36 = input.positionWS;
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

	Fallback "Off"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;604;-144,496;Inherit;False;452;387;MaskShape;4;599;596;595;600;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;561;-2208,592;Inherit;False;1103;267;CenterMask;8;400;426;424;559;425;560;416;603;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;412;-272,-1920;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-432,-1824;Inherit;False;Property;_LineRotatorDegrees;Line Rotator Degrees;17;0;Create;False;0;0;0;False;0;False;0;0.28;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;414;-128,-1872;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;411;16,-1872;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;177;-256,-1552;Inherit;False;Property;_LineMaskRange;Line Mask Range;19;0;Create;True;0;0;0;False;0;False;0.5;0;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;323;-208,-1456;Inherit;False;0;3;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;178;-2576,-816;Inherit;False;Property;_MainRadialScale;Main Radial Scale ;30;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;418;-272,-1744;Inherit;False;2;0;FLOAT;2;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-2544,-928;Inherit;False;269;Rotator;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;202;-2576,-704;Inherit;False;Property;_MainLengthScale;Main Length Scale ;31;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;267;-2352,-807;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;264;-2288,-880;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;417;-128,-1696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;321;48,-1504;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;-1402.284,-97.49709;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;199;-2096,-864;Inherit;False;Property;_LineOffSet;Line OffSet;20;0;Create;True;0;0;0;False;0;False;0;1.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;329;192,-1504;Inherit;False;LineMaskRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;281;32,-1600;Inherit;False;MMN_Time;-1;;33;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;420;16,-1696;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-2304,-1712;Inherit;False;Property;_SubLengthScale;Sub Length Scale;37;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;-2304,-1888;Inherit;False;269;Rotator;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;132;-2288,-704;Inherit;False;Polar Coordinates;-1;;34;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;0.1;False;4;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;333;-2023.919,-1010.64;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-2304,-1792;Inherit;False;Property;_SubRadialScale;Sub Radial Scale;36;0;Create;True;0;0;0;False;1;Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-1712,-496;Float;False;Property;_MainXSpeed;Main X Speed;28;0;Create;True;0;0;0;False;2;Header(Main Property);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;262;-1968,-1776;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;309;-1872,-1008;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-1392,-176;Inherit;False;329;LineMaskRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;-1872,-704;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-1712,-416;Float;False;Property;_MainYSpeed;Main Y Speed;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;282;192,-1600;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;284;-1616,-1760;Inherit;False;384;226;Switch;2;286;285;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;276;-1744,-640;Inherit;False;275;LineStlyeSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;258;-2016,-1968;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;346;-1392,16;Inherit;False;329;LineMaskRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;421;193,-1696;Inherit;False;MaskRotatorDegrees;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;348;-1200,-48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-1177,-1271;Inherit;False;Property;_SubXSpeed;Sub X Speed;33;0;Create;True;0;0;0;False;2;Header(Sub Property);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;349;-1040,-48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;283;-1536,-400;Inherit;False;282;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;-1776,-1776;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;344;-1037,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;-1584,-1632;Inherit;False;275;LineStlyeSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;274;-1520,-720;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;216;-1856,-1616;Inherit;False;Polar Coordinates;-1;;35;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;0.1;False;4;FLOAT;10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;207;-1177,-1191;Inherit;False;Property;_SubYSpeed;Sub Y Speed;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;170;-1504,-528;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;246;-777.8287,-651.7859;Inherit;False;384;226;Switch;2;248;247;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;350;-842.3157,-113.0473;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;208;-985,-1255;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;285;-1376,-1712;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-761.8287,-510.7859;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;14;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;299;-220,-376;Inherit;False;384;226;Switch;1;301;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;351;-704,-112;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;209;-834.6159,-1295.85;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;387;-800,352;Inherit;False;593;424;Switch;5;401;389;388;392;402;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;248;-537.8287,-603.7859;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;203;-628.4814,-1318.484;Inherit;True;Property;_SubTex;SubTex;32;0;Create;True;1;;0;0;False;2;Header(SubTexture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;353;-528,-112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;405;192,-1952;Inherit;False;LineCenterMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;205;32,-880;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;305;224,-320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;157;736,-752;Inherit;False;Property;_Color;Color;38;1;[HDR];Create;True;0;0;0;False;2;Header(Intensity);Space();False;1,1,1,1;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;176;768,-576;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;76;1520,-416;Inherit;False;204;375;Rendering Options;4;79;78;77;330;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;1040,-480;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;1040,-608;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;77;1552,-288;Inherit;False;Property;_BlendDst;Blend Dst;40;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;330;1552,-128;Inherit;False;Property;_ZTest;Z Test;35;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;1552,-368;Inherit;False;Property;_BlendSrc;Blend Src;39;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;1552,-208;Inherit;False;Property;_CullMode;Cull Mode;41;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;1232,-576;Inherit;False;MMN_CommonOutputs;0;;36;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;1520,-576;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/VFX/Amplify shader/FX_SpeedLine;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;233;-720,160;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.04;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;213;-896,176;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-939.6868,256;Inherit;False;329;LineMaskRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;268;-2272,-1009;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;269;192,-1872;Inherit;False;Rotator;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1125.669,-675.5303;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;016157555484cb64a8449ff4743ab1c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;169;-1328,-656;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;153;825.9366,-321.5159;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;456;-1296,176;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;455;-1424,176;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;541;-107.3219,-2790.023;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;547;-292.3221,-2735.023;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;539;-509.0924,-2577.595;Inherit;False;Constant;_Horizontal;Horizontal;28;0;Create;True;0;0;0;False;0;False;0,0.5;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenParams;517;-525.092,-2753.595;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;543;71.67812,-2685.023;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;518;-109.0924,-2593.595;Float;False; ;2;File;0;ScreenOffset;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;553;215.5002,-2696.629;Inherit;False;ScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;265;-2563.733,-1009.161;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;540;-509.0924,-2449.595;Inherit;False;Constant;_Vertical;Vertical;28;0;Create;True;0;0;0;False;0;False;0.5,0;0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;434;-656,-2848;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;431;-800,-2832;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ScreenPosInputsNode;458;-992,-2832;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;-288,-2848;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;459;-528,-2848;Inherit;False;RawScreenPosition;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;428;-432,-2928;Float;False; ;2;File;0;ScreenRatio;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;0;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;-2304,-1984;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;301;-12,-296;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;-768,16;Inherit;False;Property;_LineMaskIntensity;Line Mask Intensity;18;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-528,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;555;-1616,-80;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;211;-1152,176;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;-224,-256;Inherit;False;275;LineStlyeSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;688,-320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;565;-2688,1120;Inherit;False;1776.592;403.0402;CenterMask;17;594;593;592;591;590;589;588;587;586;585;584;583;582;581;580;579;578;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;566;-880,944;Inherit;False;443;488;Switch;5;575;574;573;570;569;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;303;464,-320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;275;192,-2192;Inherit;False;LineStlyeSwitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;390;192,-2112;Inherit;False;LineMaskSwitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;597;192,-2032;Inherit;False;MaskShapeSwitch;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;334;-1920,-80;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-1920,0;Inherit;False;269;Rotator;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-736,400;Inherit;False;Constant;_One;One;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;402;-352,608;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;369;-1584,448;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;376;-1456,448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;400;-1296,640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;424;-1888,640;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;559;-1712,640;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;425;-1568,640;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.AbsOpNode;560;-1440,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;416;-1584,736;Inherit;False;Property;_CenterMaskRange;Center Mask Range;24;0;Create;False;0;0;0;False;0;False;0.5;3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;386;-1296,448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;564;-1760,448;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;388;-784,528;Inherit;False;390;LineMaskSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;567;-1712,992;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;568;-1536,992;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;569;-752,1136;Inherit;False;Constant;_One1;One;24;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;570;-592,1168;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;571;-1408,992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;572;-1248,992;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.49;False;2;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;573;-848,1056;Inherit;False;390;LineMaskSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;574;-592,976;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;575;-848,1312;Inherit;False;405;LineCenterMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;578;-2384,1168;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;579;-2064,1168;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;580;-1696,1184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;581;-1808,1184;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;582;-2656,1264;Inherit;False;421;MaskRotatorDegrees;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;583;-1936,1168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;584;-1936,1360;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;585;-1808,1360;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;586;-1696,1360;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;587;-2208,1168;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;588;-1536,1264;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;591;-1104,1264;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;592;-1264,1424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;594;-2624,1168;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;-592,656;Inherit;False;405;LineCenterMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;576;-1936,1040;Inherit;False;269;Rotator;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;426;-2160,752;Inherit;False;421;MaskRotatorDegrees;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;-2112,656;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;599;128,624;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;596;-96,656;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;595;-96,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;600;-96,768;Inherit;False;597;MaskShapeSwitch;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;389;-352,432;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;577;-1936,960;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;601;-1968,496;Inherit;False;269;Rotator;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;602;-1968,416;Inherit;False;553;ScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;605;492.0485,-1356.649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;606;636.0485,-1356.649;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;607;348.0485,-1356.649;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;608;492.0485,-1244.649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;609;636.0485,-1244.649;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;610;348.0485,-1244.649;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;614;636.0485,-1132.649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;611;780.0485,-1356.649;Inherit;False;Horizontal Mask Range;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;612;781.0485,-1244.649;Inherit;False;Vertical Mask Range;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;796.0485,-1132.649;Inherit;False;Mask Smoothness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;589;-2192,1280;Inherit;False;611;Horizontal Mask Range;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-2192,1424;Inherit;False;612;Vertical Mask Range;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;593;-1505.491,1360;Inherit;False;613;Mask Smoothness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;616;76.04846,-1357.649;Inherit;False;Property;_HorizontalMaskRange;Quad Mask Horizontal  Range;27;0;Create;False;0;0;0;False;0;False;0;3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;617;76.04846,-1244.649;Inherit;False;Property;_VerticalMaskRange;Quad Mask Vertical  Range;26;0;Create;False;0;0;0;False;0;False;0;3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;615;348.0485,-1132.649;Inherit;False;Property;_MaskSharpness;Quad Mask Sharpness;25;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-432,-1648;Inherit;False;Property;_CenterMaskRotatorDegrees;Mask Rotator Degrees;23;0;Create;False;0;0;0;True;0;False;0;0.28;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;598;-96,-2032;Inherit;False;Property;_MaskShape;Mask Shape (Center / Quad);22;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;404;0,-1952;Inherit;False;Property;_LineCenterMask;Use Mask?;21;1;[Toggle];Create;False;0;0;0;False;2;Header(Mask Options);Space(10);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;391;-64,-2112;Inherit;False;Property;_LineMask;Line Mask (Full / Half);16;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-64,-2192;Inherit;False;Property;_LineStyle;Line Style (Polar / Rotator);15;1;[Toggle];Create;False;0;0;0;False;2;Header(Line Options);Space();False;0;0;0;0;0;1;FLOAT;0
WireConnection;414;0;412;0
WireConnection;414;1;255;0
WireConnection;411;0;414;0
WireConnection;267;0;265;0
WireConnection;264;0;178;0
WireConnection;264;1;202;0
WireConnection;417;0;418;0
WireConnection;417;1;419;0
WireConnection;321;0;177;0
WireConnection;321;1;323;3
WireConnection;345;0;555;0
WireConnection;329;0;321;0
WireConnection;420;0;417;0
WireConnection;132;1;267;0
WireConnection;132;3;178;0
WireConnection;132;4;202;0
WireConnection;333;0;268;0
WireConnection;333;1;264;0
WireConnection;262;0;228;0
WireConnection;262;1;229;0
WireConnection;309;0;333;0
WireConnection;309;1;199;0
WireConnection;198;0;132;0
WireConnection;198;1;199;0
WireConnection;282;0;281;0
WireConnection;258;0;254;0
WireConnection;258;2;270;0
WireConnection;421;0;420;0
WireConnection;348;0;345;0
WireConnection;349;0;348;0
WireConnection;349;1;346;0
WireConnection;331;0;258;0
WireConnection;331;1;262;0
WireConnection;344;0;345;0
WireConnection;344;1;347;0
WireConnection;274;0;198;0
WireConnection;274;1;309;0
WireConnection;274;2;276;0
WireConnection;216;1;254;0
WireConnection;216;3;228;0
WireConnection;216;4;229;0
WireConnection;170;0;171;0
WireConnection;170;1;172;0
WireConnection;350;0;344;0
WireConnection;350;1;349;0
WireConnection;208;0;206;0
WireConnection;208;1;207;0
WireConnection;285;0;216;0
WireConnection;285;1;331;0
WireConnection;285;2;286;0
WireConnection;351;0;350;0
WireConnection;209;0;285;0
WireConnection;209;2;208;0
WireConnection;248;0;5;4
WireConnection;248;1;5;2
WireConnection;248;2;247;0
WireConnection;203;1;209;0
WireConnection;353;0;351;0
WireConnection;353;1;312;0
WireConnection;405;0;404;0
WireConnection;205;0;203;2
WireConnection;205;1;248;0
WireConnection;305;0;205;0
WireConnection;305;1;301;0
WireConnection;175;0;157;4
WireConnection;175;1;176;4
WireConnection;175;2;153;0
WireConnection;158;0;157;0
WireConnection;158;1;176;0
WireConnection;158;2;153;0
WireConnection;119;9;158;0
WireConnection;119;28;175;0
WireConnection;97;0;119;2
WireConnection;97;1;119;26
WireConnection;233;0;213;0
WireConnection;233;1;325;0
WireConnection;213;0;211;0
WireConnection;268;0;265;0
WireConnection;268;2;271;0
WireConnection;269;0;411;0
WireConnection;5;1;169;0
WireConnection;169;0;274;0
WireConnection;169;2;170;0
WireConnection;169;1;283;0
WireConnection;153;0;427;0
WireConnection;456;0;455;0
WireConnection;456;1;455;1
WireConnection;455;0;334;0
WireConnection;541;0;435;0
WireConnection;541;1;547;0
WireConnection;547;0;517;1
WireConnection;547;1;517;2
WireConnection;547;2;539;0
WireConnection;547;3;540;0
WireConnection;547;4;540;0
WireConnection;543;0;541;0
WireConnection;543;1;518;0
WireConnection;553;0;543;0
WireConnection;434;0;431;0
WireConnection;434;1;431;1
WireConnection;431;0;458;0
WireConnection;435;0;428;0
WireConnection;435;1;459;0
WireConnection;459;0;434;0
WireConnection;301;0;307;0
WireConnection;301;1;353;0
WireConnection;301;2;300;0
WireConnection;307;0;233;0
WireConnection;307;1;312;0
WireConnection;555;0;334;0
WireConnection;555;2;314;0
WireConnection;211;0;456;0
WireConnection;427;0;303;0
WireConnection;303;0;305;0
WireConnection;303;1;599;0
WireConnection;275;0;273;0
WireConnection;390;0;391;0
WireConnection;597;0;598;0
WireConnection;402;0;392;0
WireConnection;402;1;400;0
WireConnection;402;2;401;0
WireConnection;369;0;564;0
WireConnection;376;0;369;0
WireConnection;400;0;560;0
WireConnection;400;2;416;0
WireConnection;424;0;603;0
WireConnection;424;2;426;0
WireConnection;559;0;424;0
WireConnection;425;0;559;0
WireConnection;560;0;425;0
WireConnection;386;0;376;0
WireConnection;564;0;602;0
WireConnection;564;2;601;0
WireConnection;567;0;577;0
WireConnection;567;2;576;0
WireConnection;568;0;567;0
WireConnection;570;0;569;0
WireConnection;570;1;591;0
WireConnection;570;2;575;0
WireConnection;571;0;568;0
WireConnection;572;0;571;0
WireConnection;574;0;569;0
WireConnection;574;1;572;0
WireConnection;574;2;573;0
WireConnection;578;0;594;0
WireConnection;578;2;582;0
WireConnection;579;0;587;0
WireConnection;580;0;581;0
WireConnection;581;0;583;0
WireConnection;581;1;589;0
WireConnection;583;0;579;0
WireConnection;584;0;579;1
WireConnection;585;0;584;0
WireConnection;585;1;590;0
WireConnection;586;0;585;0
WireConnection;587;0;578;0
WireConnection;588;0;580;0
WireConnection;588;1;586;0
WireConnection;591;0;588;0
WireConnection;591;1;593;0
WireConnection;591;2;592;0
WireConnection;592;0;593;0
WireConnection;599;0;595;0
WireConnection;599;1;596;0
WireConnection;599;2;600;0
WireConnection;596;0;574;0
WireConnection;596;1;570;0
WireConnection;595;0;389;0
WireConnection;595;1;402;0
WireConnection;389;0;392;0
WireConnection;389;1;386;0
WireConnection;389;2;388;0
WireConnection;605;0;607;0
WireConnection;606;0;605;0
WireConnection;607;0;616;0
WireConnection;608;0;610;0
WireConnection;609;0;608;0
WireConnection;610;0;617;0
WireConnection;614;0;615;0
WireConnection;611;0;606;0
WireConnection;612;0;609;0
WireConnection;613;0;614;0
ASEEND*/
//CHKSM=E241A67CA8203446DE83555EF75A750C82C3709C