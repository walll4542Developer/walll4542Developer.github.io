// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_AreaIndicator_Matte"
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
		[Header(Indicator Options)][Space(10)][KeywordEnum(Rectangle,Arc,Circle)] _Type("Type", Float) = 0
		[Toggle]_IsCalculateDepth("IsCalculateDepth", Float) = 0
		_GradationLength("게이지 차오르는 그라데이션의 길이", Range( 0 , 1)) = 0.5
		_OuterRadius("_OuterRadius", Float) = 1
		[HideInInspector][Toggle]_IsHostile("_IsHostile", Range( 0 , 1)) = 0
		_InnerRadius("_InnerRadius", Float) = 0
		_Angle("_Angle", Range( 0 , 360)) = 360
		_FillRate("_FillRate", Range( 0 , 1)) = 1
		[HideInInspector]_FinalAlphaMatte("_FinalAlphaMatte", Range( 0 , 1)) = 1
		[Header(Animation Options)][Space(10)]_StartAnimSpeed("시작 모션의 속도 값", Range( 0 , 1)) = 0.9
		[HideInInspector][HDR]_ColorMatte("_ColorMatte", Color) = (1,1,1,1)
		[HideInInspector]_Direction("_Direction", Vector) = (1,0,1,0)
		[Header(Stencil Options)][Space(10)]_StencilValue("Reference", Range( 0 , 255)) = 10
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Comperison", Float) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]_StencilZFail("ZFail", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10

	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent-199" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
			Name "IndicatorMatte"
			Tags { "LightMode"="IndicatorMatte" }

			Cull [_CullMode]
			Blend SrcAlpha OneMinusSrcAlpha
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			Stencil
			{
				Ref [_StencilValue]
				Comp [_StencilComp]
				Pass Keep
				Fail Keep
				ZFail [_StencilZFail]
			}

			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma exclude_renderers glcore gles gles3 switch 

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

			#include "../Includes/FXCommonOutputs.hlsl"
			#include "../Includes/FX_AreaIndicator_CalculateDepth.hlsl"
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_local __ _LIGHTRECEIVE_ON
			#pragma multi_compile_local __ _RAYCAST_ON
			#pragma multi_compile_local __ _SOFTPARTICLE_ON
			#pragma multi_compile_local __ _FOG_RCV_ON
			#pragma multi_compile_local _TYPE_RECTANGLE _TYPE_ARC _TYPE_CIRCLE


			CBUFFER_START( UnityPerMaterial )
			float4 _Direction;
			float4 _ColorMatte;
			float _LightRatio;
			float _Angle;
			float _OuterRadius;
			float _InnerRadius;
			float _FillRate;
			float _StartAnimSpeed;
			float _IsHostile;
			float _GradationLength;
			float _StencilValue;
			float _StencilZFail;
			float _StencilComp;
			float _NearPlaneAlpha;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _IsCalculateDepth;
			float _FinalAlphaMatte;
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

				float4 ase_texcoord3 : TEXCOORD3;
			};

						
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord3 = screenPos;
				
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
				float3 appendResult861 = (float3(_ColorMatte.rgb));
				float3 MainColor312 = appendResult861;
				float2 texCoord868 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV869 = texCoord868;
				float ObjectPositionY278 = UV869.y;
				float Progress309 = _FillRate;
				float smoothstepResult808 = smoothstep( 0.0 , ( 1.0 - _StartAnimSpeed ) , Progress309);
				float StartAnim315 = saturate( smoothstepResult808 );
				float RactangleWidthAlpha283 = step( abs( ( UV869.x - 0.5 ) ) , StartAnim315 );
				float4 appendResult307 = (float4(MainColor312 , ( saturate( ( saturate( ObjectPositionY278 ) + 1.0 ) ) * RactangleWidthAlpha283 )));
				float4 TypeRectangle321 = appendResult307;
				float2 temp_cast_1 = (0.5).xx;
				float2 CenteredUV15_g13 = ( UV869 - temp_cast_1 );
				float2 break17_g13 = CenteredUV15_g13;
				float2 appendResult23_g13 = (float2(( length( CenteredUV15_g13 ) * 1.0 * 2.0 ) , ( atan2( break17_g13.x , break17_g13.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult444 = (float2(appendResult23_g13.x , 1.0));
				float2 PolarCoord354 = appendResult444;
				float InnerRadius583 = saturate( ( _InnerRadius / _OuterRadius ) );
				float OuterRadius595 = 1.0;
				float3 objToWorld513 = mul( GetObjectToWorldMatrix(), float4( float3(0,0,0), 1 ) ).xyz;
				float3 normalizeResult522 = normalize( ( input.positionWS - objToWorld513 ) );
				float4 Direction825 = _Direction;
				float3 appendResult518 = (float3(Direction825.xyz));
				float3 normalizeResult521 = normalize( appendResult518 );
				float dotResult516 = dot( normalizeResult522 , normalizeResult521 );
				float Degree519 = degrees( acos( dotResult516 ) );
				float Angle529 = _Angle;
				float lerpResult796 = lerp( 0.0 , ( Angle529 * 0.5 ) , StartAnim315);
				float4 appendResult427 = (float4(MainColor312 , ( ( 1.0 - step( PolarCoord354.x , InnerRadius583 ) ) * step( PolarCoord354.x , OuterRadius595 ) * step( Degree519 , lerpResult796 ) )));
				float4 TypeArc326 = appendResult427;
				float temp_output_698_0 = saturate( PolarCoord354.y );
				float CircleProgression637 = saturate( temp_output_698_0 );
				float4 appendResult337 = (float4(MainColor312 , ( saturate( ( 0.0 + CircleProgression637 ) ) * step( PolarCoord354.x , StartAnim315 ) )));
				float4 TypeCircle325 = appendResult337;
				#if defined(_TYPE_RECTANGLE)
				float4 staticSwitch317 = TypeRectangle321;
				#elif defined(_TYPE_ARC)
				float4 staticSwitch317 = TypeArc326;
				#elif defined(_TYPE_CIRCLE)
				float4 staticSwitch317 = TypeCircle325;
				#else
				float4 staticSwitch317 = TypeRectangle321;
				#endif
				float4 break323 = staticSwitch317;
				float3 appendResult322 = (float3(break323.x , break323.y , break323.z));
				float Alpha844 = break323.w;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult840 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 PositionNDC837 = appendResult840;
				float4 appendResult841 = (float4(_ZBufferParams.x , _ZBufferParams.y , _ZBufferParams.z , _ZBufferParams.w));
				float4 ZBufferParams837 = appendResult841;
				float3 positionWS837 = input.positionWS;
				float alpha837 = Alpha844;
				float localCalculateDepthAlpha837 = CalculateDepthAlpha( PositionNDC837 , ZBufferParams837 , positionWS837 , alpha837 );
				float lerpResult849 = lerp( Alpha844 , localCalculateDepthAlpha837 , _IsCalculateDepth);
				float CalculateDepthAlpha845 = lerpResult849;
				float FinalAlphaMatte958 = _FinalAlphaMatte;
				float4 appendResult32_g12 = (float4(appendResult322 , ( CalculateDepthAlpha845 * FinalAlphaMatte958 )));
				half4 finalColor92_g12 = appendResult32_g12;
				half3 positionWS92_g12 = input.positionWS;
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
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;900;1739.325,318.5976;Inherit;False;1133;308;Ractangle Width Alpha;8;283;316;874;511;873;163;167;548;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;867;5552,-1232;Inherit;False;623;719;Script;13;914;913;583;209;309;595;488;825;517;529;921;917;920;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;866;5516,-1696;Inherit;False;662;342;Color;5;820;861;948;958;312;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;852;7600,-1696;Inherit;False;1104;660;CalculateDepthAlpha;10;850;840;838;837;849;845;843;842;841;839;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;836;6992,384;Inherit;False;350;327;Stencil Options;3;834;833;835;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;6300,-1696;Inherit;False;1256.2;550.7999;Animation;18;789;915;916;788;817;790;822;816;787;814;911;808;823;784;782;315;868;869;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;797;3248,1184;Inherit;False;1204;678;Alpha;15;606;585;586;607;587;622;596;547;568;546;796;795;567;566;758;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;770;1710.325,1468.597;Inherit;False;1162;409;Circle Progression;9;699;700;702;753;697;701;698;625;637;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;525;1571.325,972.5975;Inherit;False;1304;479;Degree;12;826;514;519;489;490;521;518;513;516;522;524;523;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;1331.324,684.5974;Inherit;False;1546;264;Polar Coordinate;7;354;444;338;445;334;875;947;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;367;3596.5,393.5002;Inherit;False;860.0341;337.2867;Alpha;8;346;355;345;418;421;465;422;786;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;304;3408,-256;Inherit;False;1048;319;Alpha;6;575;291;284;178;293;288;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;282;2235.324,-17.40248;Inherit;False;637;309;Object Position Y;4;870;872;278;507;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;76;6752,384;Inherit;False;189.2998;429.6001;Rendering Options;4;129;79;962;961;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;5696,224;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;337;4560,368;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;422;4124.5,441.5002;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;3996.5,441.5002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;3852.5,537.5001;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StepOpNode;346;4124.5,521.5001;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;307;4560,-304;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;427;4544,1152;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;759;5056,384;Inherit;False;325;TypeCircle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;3504,1232;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;3632,1328;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;586;3968,1232;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;607;3680,1232;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;587;4096,1232;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;596;3632,1408;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;3648,1488;Inherit;False;519;Degree;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;568;3968,1392;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;546;3968,1488;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;3312,1648;Inherit;False;529;Angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;566;3488,1648;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;796;3664,1568;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;795;3488,1568;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;4316.5,441.5002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;786;3804.5,633.5001;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;758;3456,1744;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;5056,304;Inherit;False;326;TypeArc;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;5056,224;Inherit;False;321;TypeRectangle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;517;5712,-784;Inherit;False;Property;_Direction;_Direction;25;0;Create;False;0;0;0;True;1;HideInInspector;False;1,0,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;317;5424,224;Inherit;False;Property;_Type;Type;13;0;Create;False;0;0;0;True;2;Header(Indicator Options);Space(10);False;1;0;0;True;;KeywordEnum;3;Rectangle;Arc;Circle;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;5952,-1184;Inherit;False;Progress;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ZBufferParams;839;7632,-1456;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;841;7808,-1456;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;842;7648,-1312;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;843;7840,-1232;Inherit;False;844;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;845;8464,-1232;Inherit;False;CalculateDepthAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;849;8304,-1232;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;837;8016,-1456;Inherit;False; ;1;File;4;True;PositionNDC;FLOAT2;0,0;In;;Inherit;False;True;ZBufferParams;FLOAT4;0,0,0,0;In;;Inherit;False;True;positionWS;FLOAT3;0,0,0;In;;Inherit;False;True;alpha;FLOAT;0;In;;Inherit;False;CalculateDepthAlpha;False;False;0;c37f3afae6c2d6c41b2bc8bd05ae245a;False;4;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;838;7632,-1632;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;840;7808,-1632;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;850;8064,-1152;Inherit;False;Property;_IsCalculateDepth;IsCalculateDepth;14;0;Create;False;0;0;0;True;1;Toggle;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;868;7120,-1472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;782;7200,-1328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;784;6864,-1328;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;823;6880,-1248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;808;7040,-1328;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;911;7200,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;6608,-1248;Inherit;False;Property;_StartAnimSpeed;시작 모션의 속도 값;22;0;Create;False;0;0;0;False;2;Header(Animation Options);Space(10);False;0.9;15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;915;6592,-1520;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;789;6320,-1520;Inherit;False;Property;_GaugeAnimDamping;게이지 차오르는 모션의 댐핑 값;23;0;Create;False;0;0;0;False;0;False;10;15;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;921;5744,-944;Inherit;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;920;5744,-864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;917;5600,-864;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;5344,-880;Inherit;False;Property;_OuterRadius;_OuterRadius;16;0;Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;584;5344,-800;Inherit;False;Property;_InnerRadius;_InnerRadius;18;0;Create;False;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;4016,-208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;293;4160,-208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;4304,-208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;916;6368,-1420;Inherit;False;914;IsHostile;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;5600,-1024;Inherit;False;Property;_Angle;_Angle;19;0;Create;False;0;0;0;True;0;False;360;1;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;6496,224;Inherit;False;MMN_CommonOutputs;0;;12;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,1,1;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;834;7040,512;Inherit;False;Property;_StencilComp;Comperison;27;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;835;7040,576;Inherit;False;Property;_StencilZFail;ZFail;28;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.StencilOp;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;847;6036,352;Inherit;False;845;CalculateDepthAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;844;5837,348;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;6753,225;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;0;14;MMN/FX/Amplify shader/FX_AreaIndicator_Matte;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;IndicatorMatte;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=-199;True;5;False;0;True;True;2;5;False;_BlendSrc;10;False;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;True;10;True;_StencilValue;255;False;;255;False;;1;True;_StencilComp;1;False;;1;False;;0;True;_StencilZFail;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;True;_ZTest;False;True;1;LightMode=IndicatorMatte;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;833;7040,432;Inherit;False;Property;_StencilValue;Reference;26;0;Create;False;0;0;0;True;2;Header(Stencil Options);Space(10);False;10;0;0;255;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;4705.692,-304;Inherit;False;TypeRectangle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;4768,368;Inherit;False;TypeCircle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;788;6576,-1616;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;817;6768,-1472;Inherit;False;3;0;FLOAT;-0.1;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;787;6768,-1568;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;814;6928,-1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;816;7056,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;7344,-1472;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;7344,-1328;Inherit;False;StartAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;7344,-1584;Inherit;False;GaugeAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;322;6048,224;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;3740.5,441.5002;Inherit;False;637;CircleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;355;3660.5,537.5001;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;301;4687,-943;Inherit;False;Property;_GradationLength;게이지 차오르는 그라데이션의 길이;15;0;Create;False;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;4688,1152;Inherit;False;TypeArc;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;913;5603.732,-608.1879;Inherit;False;Property;_IsHostile;_IsHostile;17;2;[HideInInspector];[Toggle];Create;False;0;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;5600,-1185;Inherit;False;Property;_FillRate;_FillRate;20;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;4304,1232;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;4016,-96;Inherit;False;283;RactangleWidthAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;3456,-208;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;3760,-208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;945;3824,-96;Inherit;False;Constant;_One1;One;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;955;4286.609,306.4787;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;956;4323.496,-376.1198;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;957;4288,1104;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;861;5776,-1648;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;959;6075.645,437.687;Inherit;False;958;FinalAlphaMatte;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;960;6367.645,387.687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;6784,608;Inherit;False;Property;_CullMode;Cull Mode;29;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;6784,688;Inherit;False;Property;_ZTest;Z Test;30;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;962;6784,448;Inherit;False;Property;_BlendSrc;Blend Src;31;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;961;6784,528;Inherit;False;Property;_BlendDst;Blend Dst;32;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;5039,-943;Inherit;False;GragationLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;5953,-1024;Inherit;False;Angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;5952,-944;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;583;5952,-868.0161;Inherit;False;InnerRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;825;5952,-784;Inherit;False;Direction;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;914;5952,-612.0161;Inherit;False;IsHostile;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;958;5918.415,-1454.861;Inherit;False;FinalAlphaMatte;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;1987.324,1100.597;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;524;1779.325,1020.598;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;522;2115.324,1100.597;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;516;2291.324,1228.597;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;513;1763.325,1164.597;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;518;1971.324,1324.597;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;521;2115.324,1324.597;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ACosOpNode;490;2403.325,1228.597;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;489;2515.324,1228.597;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;826;1795.325,1324.597;Inherit;False;825;Direction;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;444;2494.324,749.5974;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;334;1870.325,749.5974;Inherit;False;Polar Coordinates;-1;;13;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;1710.325,845.5974;Inherit;False;Constant;_16;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;1694.325,749.5974;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;445;2110.324,749.5974;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;947;2323.325,844.5974;Inherit;False;Constant;_Float5;Float 5;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;625;2483.324,1532.597;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;2099.324,1532.597;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;701;1763.325,1628.597;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;753;1939.325,1628.597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;1763.325,1756.597;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;700;1763.325,1534.597;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;699;1971.324,1532.597;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;697;2275.324,1652.597;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;514;1587.325,1165.597;Inherit;False;Constant;_0;0;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;354;2659.324,748.5974;Inherit;False;PolarCoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;519;2653.324,1230.597;Inherit;False;Degree;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;2331.325,61.59753;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;507;2298.325,130.5975;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;2138.324,194.5975;Inherit;False;Constant;_13;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;167;2347.325,382.5976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;163;2491.324,382.5976;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;548;2203.324,382.5976;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;1995.324,398.5976;Inherit;False;Constant;_14;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;2299.325,493.5975;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;873;1851.325,477.5975;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;506;2106.324,50.59753;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;872;2507.324,62.59753;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;874;2043.324,478.5975;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;2619.324,382.5976;Inherit;False;RactangleWidthAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;2635.324,62.59753;Inherit;False;ObjectPositionY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;637;2668.324,1531.597;Inherit;False;CircleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;5952,-1648;Inherit;False;MainColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;820;5552,-1648;Inherit;False;Property;_ColorMatte;_ColorMatte;24;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;948;5616,-1456;Inherit;False;Property;_FinalAlphaMatte;_FinalAlphaMatte;21;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
WireConnection;323;0;317;0
WireConnection;337;0;955;0
WireConnection;337;3;465;0
WireConnection;422;0;421;0
WireConnection;421;1;418;0
WireConnection;345;0;355;0
WireConnection;346;0;345;0
WireConnection;346;1;786;0
WireConnection;307;0;956;0
WireConnection;307;3;178;0
WireConnection;427;0;957;0
WireConnection;427;3;622;0
WireConnection;586;0;607;0
WireConnection;586;1;585;0
WireConnection;607;0;606;0
WireConnection;587;0;586;0
WireConnection;568;0;607;0
WireConnection;568;1;596;0
WireConnection;546;0;547;0
WireConnection;546;1;796;0
WireConnection;566;0;567;0
WireConnection;796;0;795;0
WireConnection;796;1;566;0
WireConnection;796;2;758;0
WireConnection;465;0;422;0
WireConnection;465;1;346;0
WireConnection;317;1;329;0
WireConnection;317;0;331;0
WireConnection;317;2;759;0
WireConnection;309;0;209;0
WireConnection;841;0;839;1
WireConnection;841;1;839;2
WireConnection;841;2;839;3
WireConnection;841;3;839;4
WireConnection;845;0;849;0
WireConnection;849;0;843;0
WireConnection;849;1;837;0
WireConnection;849;2;850;0
WireConnection;837;0;840;0
WireConnection;837;1;841;0
WireConnection;837;2;842;0
WireConnection;837;3;843;0
WireConnection;840;0;838;1
WireConnection;840;1;838;2
WireConnection;782;0;808;0
WireConnection;823;0;822;0
WireConnection;808;0;784;0
WireConnection;808;2;823;0
WireConnection;911;0;816;0
WireConnection;915;0;789;0
WireConnection;915;2;916;0
WireConnection;920;0;917;0
WireConnection;917;0;584;0
WireConnection;917;1;594;0
WireConnection;291;0;575;0
WireConnection;291;1;945;0
WireConnection;293;0;291;0
WireConnection;178;0;293;0
WireConnection;178;1;284;0
WireConnection;119;9;322;0
WireConnection;119;28;960;0
WireConnection;844;0;323;3
WireConnection;97;0;119;2
WireConnection;97;1;119;26
WireConnection;321;0;307;0
WireConnection;325;0;337;0
WireConnection;817;2;788;0
WireConnection;787;0;788;0
WireConnection;787;1;915;0
WireConnection;814;0;787;0
WireConnection;814;1;817;0
WireConnection;816;0;814;0
WireConnection;869;0;868;0
WireConnection;315;0;782;0
WireConnection;790;0;911;0
WireConnection;322;0;323;0
WireConnection;322;1;323;1
WireConnection;322;2;323;2
WireConnection;326;0;427;0
WireConnection;622;0;587;0
WireConnection;622;1;568;0
WireConnection;622;2;546;0
WireConnection;575;0;288;0
WireConnection;861;0;820;0
WireConnection;960;0;847;0
WireConnection;960;1;959;0
WireConnection;415;0;301;0
WireConnection;529;0;488;0
WireConnection;595;0;921;0
WireConnection;583;0;920;0
WireConnection;825;0;517;0
WireConnection;914;0;913;0
WireConnection;958;0;948;0
WireConnection;523;0;524;0
WireConnection;523;1;513;0
WireConnection;522;0;523;0
WireConnection;516;0;522;0
WireConnection;516;1;521;0
WireConnection;513;0;514;0
WireConnection;518;0;826;0
WireConnection;521;0;518;0
WireConnection;490;0;516;0
WireConnection;489;0;490;0
WireConnection;444;0;445;0
WireConnection;444;1;947;0
WireConnection;334;1;875;0
WireConnection;334;2;338;0
WireConnection;445;0;334;0
WireConnection;625;0;698;0
WireConnection;698;0;699;1
WireConnection;753;0;701;0
WireConnection;699;0;700;0
WireConnection;697;0;698;0
WireConnection;697;1;753;0
WireConnection;697;2;702;0
WireConnection;354;0;444;0
WireConnection;519;0;489;0
WireConnection;507;0;506;2
WireConnection;507;1;510;0
WireConnection;167;0;548;0
WireConnection;163;0;167;0
WireConnection;163;1;316;0
WireConnection;548;0;874;0
WireConnection;548;1;511;0
WireConnection;872;0;870;0
WireConnection;874;0;873;0
WireConnection;283;0;163;0
WireConnection;278;0;872;1
WireConnection;637;0;625;0
WireConnection;312;0;861;0
ASEEND*/
//CHKSM=09397A7A177B6A048724B71A6D99E21B35221679