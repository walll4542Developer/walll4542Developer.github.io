// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_AreaIndicator"
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogPower("_FogPower", Range(0, 1)) = 0
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector][Toggle(_FOG_RCV_ON)] _FogReceive("안개 적용", Float) = 1
		[Header(Indicator Options)][Space(10)][KeywordEnum(Rectangle,Arc,Circle)] _Type("Type", Float) = 0
		[NoScaleOffset][Header(Color Design Options)][Space(10)]_MainTex("메인 텍스쳐", 2D) = "white" {}
		_IntensityColor("게이지 컬러 인텐시티", Float) = 1
		[HideInInspector]_FinalAlpha("알파의 최종값", Range( 0 , 1)) = 1
		_MinAlpha("알파의 최솟값", Range( 0 , 1)) = 0.3
		_GradationLength("게이지 차오르는 그라데이션의 길이", Range( 0 , 1)) = 0.5
		[IntRange]_Tiling("점 패턴의 밀도", Range( 1 , 20)) = 10
		[HideInInspector]_OuterRadius("_OuterRadius", Float) = 1
		[HideInInspector][Toggle]_IsHostile("_IsHostile", Range( 0 , 1)) = 0
		[HideInInspector]_InnerRadius("_InnerRadius", Float) = 0
		[HideInInspector]_Angle("_Angle", Range( 0 , 360)) = 360
		[HideInInspector]_FinalAlphaMatte("_FinalAlphaMatte", Range( 0 , 1)) = 1
		_FillRate("_FillRate", Range( 0 , 1)) = 1
		[Header(Animation Options)][Space(10)]_StartAnimSpeed("시작 모션의 속도 값", Range( 0 , 1)) = 0.9
		_GaugeAnimDamping("게이지 차오르는 모션의 댐핑 값", Range( 1 , 100)) = 10
		[HideInInspector][HDR]_UnfilledColor("_UnfilledColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_ColorMatte("_ColorMatte", Color) = (1,1,1,1)
		[HideInInspector][HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_FilledColor("_FilledColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_SubColor("SubColor", Color) = (1,1,1,1)
		[HideInInspector]_Direction("_Direction", Vector) = (1,0,1,0)
		[HideInInspector]_ColorBlendT("_ColorBlendT", Range( 0 , 1)) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent+100" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="Decal" }

			Cull Front
			Blend [_BlendSrc] [_BlendDst]
			ZTest Always
			ZWrite Off
			ColorMask RGBA
			

			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma only_renderers d3d11 metal vulkan 

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
			#pragma multi_compile_local_fragment __ _FOG_RCV_ON
			#pragma multi_compile_local _TYPE_RECTANGLE _TYPE_ARC _TYPE_CIRCLE


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainColor;
			float4 _SubColor;
			float4 _ColorMatte;
			float4 _UnfilledColor;
			float4 _FilledColor;
			float4 _Direction;
			float _ColorBlendT;
			float _OuterRadius;
			float _InnerRadius;
			float _FinalAlpha;
			float _StartAnimSpeed;
			float _IsHostile;
			float _IntensityColor;
			float _FillRate;
			float _GradationLength;
			float _MinAlpha;
			float _Tiling;
			float _FinalAlphaMatte;
			float _GaugeAnimDamping;
			float _Angle;
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
				float3 appendResult861 = (float3(_UnfilledColor.rgb));
				float4 appendResult864 = (float4(( appendResult861 * float3( 1,1,1 ) ) , _UnfilledColor.a));
				float4 MainColor312 = appendResult864;
				float localApplyScreenSpaceDecal36_g16 = ( 0.0 );
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g16 = ase_screenPosNorm;
				float2 decalUV36_g16 = float2( 0,0 );
				float boundingBox36_g16 = 0.0;
				float4 decalWorldSpace36_g16 = float4( 0,0,0,0 );
				ApplyScreenSpaceDecal( screenPos36_g16 , decalUV36_g16 , boundingBox36_g16 , decalWorldSpace36_g16 );
				float4 temp_output_973_66 = decalWorldSpace36_g16;
				float4 break972 = temp_output_973_66;
				float2 appendResult971 = (float2(break972.x , break972.z));
				float2 DecalWorldSpace969 = appendResult971;
				float Tiling829 = _Tiling;
				float DotPattern272 = tex2D( _MainTex, frac( ( DecalWorldSpace969 * Tiling829 ) ) ).g;
				float2 UV869 = decalUV36_g16;
				float ObjectPositionY278 = UV869.y;
				float MinAlpha613 = _MinAlpha;
				float temp_output_231_0 = saturate( ( DotPattern272 + ObjectPositionY278 + MinAlpha613 ) );
				float3 appendResult863 = (float3(_FilledColor.rgb));
				float4 appendResult865 = (float4(( appendResult863 * _IntensityColor ) , _FilledColor.a));
				float4 SubColor311 = appendResult865;
				float GragationLength415 = _GradationLength;
				float Progress309 = _FillRate;
				float saferPower787 = abs( Progress309 );
				float IsHostile914 = _IsHostile;
				float lerpResult915 = lerp( _GaugeAnimDamping , 1.0 , IsHostile914);
				float lerpResult817 = lerp( -0.1 , 0.05 , Progress309);
				float GaugeAnim790 = saturate( saturate( ( pow( saferPower787 , lerpResult915 ) + lerpResult817 ) ) );
				float temp_output_238_0 = ( ObjectPositionY278 + ( 1.0 - GaugeAnim790 ) );
				float smoothstepResult300 = smoothstep( ( 1.0 - GragationLength415 ) , 1.0 , saturate( temp_output_238_0 ));
				float RactangleProgression294 = ( DotPattern272 * ( smoothstepResult300 * step( temp_output_238_0 , 1.0 ) ) );
				float4 lerpResult241 = lerp( ( MainColor312 * temp_output_231_0 ) , SubColor311 , RactangleProgression294);
				float3 appendResult181 = (float3(lerpResult241.xyz));
				float smoothstepResult808 = smoothstep( 0.0 , ( 1.0 - _StartAnimSpeed ) , Progress309);
				float StartAnim315 = saturate( smoothstepResult808 );
				float RactangleWidthAlpha283 = step( abs( ( UV869.x - 0.5 ) ) , StartAnim315 );
				float FinalAlpha924 = _FinalAlpha;
				float4 appendResult307 = (float4(appendResult181 , ( saturate( ( ( temp_output_231_0 * saturate( max( ObjectPositionY278 , MinAlpha613 ) ) ) + RactangleProgression294 ) ) * RactangleWidthAlpha283 * FinalAlpha924 )));
				float4 TypeRectangle321 = appendResult307;
				float InnerRadius583 = saturate( ( _InnerRadius / _OuterRadius ) );
				float OuterRadius595 = 1.0;
				float2 temp_cast_3 = (0.5).xx;
				float2 CenteredUV15_g13 = ( UV869 - temp_cast_3 );
				float2 break17_g13 = CenteredUV15_g13;
				float2 appendResult23_g13 = (float2(( length( CenteredUV15_g13 ) * 1.0 * 2.0 ) , ( atan2( break17_g13.x , break17_g13.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 break445 = appendResult23_g13;
				float2 appendResult444 = (float2(break445.x , frac( ( break445.y + 1.0 ) )));
				float2 PolarCoord354 = appendResult444;
				float smoothstepResult604 = smoothstep( InnerRadius583 , OuterRadius595 , saturate( PolarCoord354.x ));
				float temp_output_479_0 = saturate( ( max( smoothstepResult604 , MinAlpha613 ) + ( smoothstepResult604 * DotPattern272 ) ) );
				float smoothstepResult697 = smoothstep( ( InnerRadius583 - 0.01 ) , OuterRadius595 , saturate( PolarCoord354.x ));
				float temp_output_631_0 = ( smoothstepResult697 + ( 1.0 - GaugeAnim790 ) );
				float smoothstepResult624 = smoothstep( ( 1.0 - GragationLength415 ) , 1.0 , saturate( temp_output_631_0 ));
				float ArcProgression637 = ( DotPattern272 * ( smoothstepResult624 * step( temp_output_631_0 , 1.0 ) ) );
				float4 lerpResult480 = lerp( ( temp_output_479_0 * MainColor312 ) , SubColor311 , ArcProgression637);
				float3 appendResult482 = (float3(lerpResult480.xyz));
				float4 WorldSpaceDegree976 = temp_output_973_66;
				float3 appendResult980 = (float3(WorldSpaceDegree976.xyz));
				float3 objToWorld513 = mul( GetObjectToWorldMatrix(), float4( float3(0,0,0), 1 ) ).xyz;
				float3 normalizeResult522 = normalize( ( appendResult980 - objToWorld513 ) );
				float4 Direction825 = _Direction;
				float3 appendResult518 = (float3(Direction825.xyz));
				float3 normalizeResult521 = normalize( appendResult518 );
				float dotResult516 = dot( normalizeResult522 , normalizeResult521 );
				float Degree519 = degrees( acos( dotResult516 ) );
				float Angle529 = _Angle;
				float lerpResult796 = lerp( 0.0 , ( Angle529 * 0.5 ) , StartAnim315);
				float4 appendResult427 = (float4(appendResult482 , ( temp_output_479_0 * ( 1.0 - step( PolarCoord354.x , InnerRadius583 ) ) * step( PolarCoord354.x , OuterRadius595 ) * step( Degree519 , lerpResult796 ) * FinalAlpha924 )));
				float4 TypeArc326 = appendResult427;
				float temp_output_383_0 = saturate( ( PolarCoord354.x + ( 1.0 - StartAnim315 ) ) );
				float temp_output_378_0 = saturate( ( max( temp_output_383_0 , MinAlpha613 ) + ( temp_output_383_0 * DotPattern272 ) ) );
				float4 lerpResult384 = lerp( ( temp_output_378_0 * MainColor312 ) , SubColor311 , ArcProgression637);
				float3 appendResult385 = (float3(lerpResult384.xyz));
				float4 appendResult337 = (float4(appendResult385 , ( saturate( ( temp_output_378_0 + ArcProgression637 ) ) * step( PolarCoord354.x , StartAnim315 ) * FinalAlpha924 )));
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
				
				float BoundingBox958 = boundingBox36_g16;
				
				float3 Color = appendResult322;
				float Alpha = ( break323.w * BoundingBox958 );

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
	
	FallBack Off
	
	Fallback "Off"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;977;6304,-992;Inherit;False;884;507;Decal;7;958;869;973;971;972;969;976;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;900;1264,16;Inherit;False;1133;308;Ractangle Width Alpha;8;283;316;874;511;873;163;167;548;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;867;5552,-1232;Inherit;False;623;719;Script;15;914;913;583;209;309;388;595;488;825;517;529;306;921;917;920;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;866;4848,-1696;Inherit;False;1330;438;Color;13;312;311;820;819;861;863;859;858;860;864;865;186;240;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;6300,-1696;Inherit;False;1260.2;668.7999;Animation;16;822;808;823;784;315;782;790;816;814;787;817;788;916;789;915;911;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;797;3169,1425;Inherit;False;1204;678;Alpha;16;606;585;586;607;587;622;596;547;568;546;796;795;567;566;758;927;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;774;720,352;Inherit;False;1672.742;380.5703;Ractangle Progression;13;416;303;267;280;238;246;265;300;263;273;235;294;794;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;770;368,1536;Inherit;False;2037;406;Arc Progression;19;635;636;625;632;627;624;633;631;626;634;637;697;698;699;753;701;700;702;793;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;766;736,1968;Inherit;False;1666;406;Circle Progression;14;396;398;402;399;397;394;393;395;392;401;400;405;417;792;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;733;2576,912;Inherit;False;1837;422;Color;18;482;472;471;692;604;601;484;473;480;485;479;689;481;617;730;483;600;603;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;732;2480,112;Inherit;False;1933;406;Color;19;385;351;384;360;378;357;358;727;668;669;729;383;731;349;350;386;387;618;854;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;525;976,1040;Inherit;False;1433;480;Degree;13;519;489;490;522;521;516;513;523;514;826;518;980;979;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;864,752;Inherit;False;1546;264;Polar Coordinate;9;354;444;453;454;442;338;445;334;875;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;367;3552,544;Inherit;False;860.0341;337.2867;Alpha;9;346;355;345;418;421;465;422;786;926;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;305;3232,-688;Inherit;False;1176;413;Color;11;271;314;313;299;231;180;241;181;279;589;615;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;304;3360,-240;Inherit;False;1048;319;Alpha;11;575;295;291;284;298;178;293;288;588;614;925;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;282;1603,-320;Inherit;False;794;313;Object Position Y;6;278;510;506;507;870;872;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;275;1360,-640;Inherit;False;1036.427;289.9003;Dot Pattern;6;272;970;831;169;168;955;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;76;6752,384;Inherit;False;204;375;Rendering Options;4;79;78;77;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;5696,224;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;385;4256,160;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;337;4560,368;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;386;3504,320;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;378;3504,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;3376,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;729;2848,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;383;2976,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;618;2976,240;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;727;3216,160;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;731;3216,272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;357;2512,160;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;358;2688,160;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;3824,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;422;4080,592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;3952,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;3696,592;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;3808,688;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;355;3616,688;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;346;4080,672;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;307;4560,-304;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;427;4544,1152;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SmoothstepOpNode;604;3072,960;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;601;2928,960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;484;2784,960;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;483;2608,960;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;600;2608,1040;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;2608,1120;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;3072,1088;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;481;3072,1168;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;482;4240,960;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;3712,1056;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;3712,1136;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;479;3712,960;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;689;3344,960;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;730;3344,1056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;692;3584,960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;485;3712,1216;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;3904,960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;759;5056,384;Inherit;False;325;TypeCircle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;3411,1475;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;3539,1571;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;586;3875,1475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;607;3587,1475;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;587;4003,1475;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;596;3539,1651;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;3555,1731;Inherit;False;519;Degree;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;568;3875,1635;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;546;3875,1731;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;3219,1891;Inherit;False;529;Angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;566;3395,1891;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;796;3571,1811;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;795;3395,1811;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;4211,1475;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;4272,592;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;2976,320;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;786;3760,784;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;758;3363,1987;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;5056,304;Inherit;False;326;TypeArc;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;5056,224;Inherit;False;321;TypeRectangle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;480;4080,960;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;384;4096,160;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;854;4064.15,326.6642;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;861;5312,-1648;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;863;5312,-1472;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;864;5728,-1648;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;865;5728,-1472;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;5952,-1024;Inherit;False;Angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;517;5712,-784;Inherit;False;Property;_Direction;_Direction;21;0;Create;False;0;0;0;True;1;HideInInspector;False;1,0,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;825;5952,-784;Inherit;False;Direction;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;354;2192,816;Inherit;False;PolarCoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;2032,416;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;398;1536,2096;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;402;1200,2256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;399;1376,2096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;397;1712,2224;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;394;1840,2016;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;393;2032,2032;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;1872,2096;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;401;1200,2176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;405;1232,2080;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;417;960,2256;Inherit;False;415;GragationLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;625;1552,1664;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;626;1232,1744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;699;624,1600;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;700;416,1600;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;792;1008,2176;Inherit;False;790;GaugeAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;317;5424,224;Inherit;False;Property;_Type;Type;1;0;Create;False;0;0;0;True;2;Header(Indicator Options);Space(10);False;1;0;0;True;;KeywordEnum;3;Rectangle;Arc;Circle;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;267;1200,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;303;1200,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;5952,-1104;Inherit;False;ColorBlendT;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;872;2032,-240;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;387;3504,400;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;2048,1600;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;1056,2080;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;627;1232,1824;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;634;1856,1584;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;631;1392,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;992,1824;Inherit;False;415;GragationLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;624;1696,1664;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;1888,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;392;2160,2032;Inherit;False;CircleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;669;2688,272;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;668;2512,272;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;246;1536,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;1840,400;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;1872,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;2160,416;Inherit;False;RactangleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;416;960,640;Inherit;False;415;GragationLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;238;1376,479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;300;1680,480;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;265;1712,608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;5952,-1184;Inherit;False;Progress;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;794;992,560;Inherit;False;790;GaugeAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;911;7200,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;396;1680,2096;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;914;5952,-608;Inherit;False;IsHostile;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;915;6592,-1520;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;789;6320,-1520;Inherit;False;Property;_GaugeAnimDamping;게이지 차오르는 모션의 댐핑 값;15;0;Create;False;0;0;0;False;0;False;10;15;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;753;592,1696;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;752,1600;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;913;5603.732,-608.1879;Inherit;False;Property;_IsHostile;_IsHostile;9;2;[HideInInspector];[Toggle];Create;False;0;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;5952,-944;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;920;5744,-864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;917;5600,-864;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;5039,-943;Inherit;False;GragationLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;924;5039.62,-1021.661;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;4240,-480;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;3632,-640;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;3632,-544;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;3279,-528;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;3264,-448;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;615;3296,-368;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;589;3568,-448;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;231;3680,-448;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;3840,-480;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;241;4081,-481;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;3840,-384;Inherit;False;294;RactangleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;3824,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;3968,-192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;3376,-160;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;293;4112,-192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;614;3408,-80;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;588;3568,-160;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;3680,-160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;295;3696,-80;Inherit;False;294;RactangleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;3968,-80;Inherit;False;283;RactangleWidthAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;350;3504,240;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;4256,-192;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;925;4035.524,-5.868164;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;926;4179.499,771.4666;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;927;4086.499,1796.467;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;1856,-241;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;507;1823,-172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;506;1631,-252;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;510;1663,-108;Inherit;False;Constant;_13;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;4687,-943;Inherit;False;Property;_GradationLength;게이지 차오르는 그라데이션의 길이;6;0;Create;False;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;923;4690.62,-1022.661;Float;False;Property;_FinalAlpha;알파의 최종값;4;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;916;6368,-1420;Inherit;False;914;IsHostile;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;5600,-1104;Inherit;False;Property;_ColorBlendT;_ColorBlendT;22;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;5041,-1112;Inherit;False;MinAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;2160,-240;Inherit;False;ObjectPositionY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;701;416,1696;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;793;1024,1744;Inherit;False;790;GaugeAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;416,1824;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;633;1728,1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;697;944,1600;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;6753,225;Float;False;True;-1;2;;0;16;MMN/FX/Amplify shader/FX_AreaIndicator;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=100;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;1;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;10;True;_StencilValue;255;False;;255;False;;1;True;_StencilComp;1;False;;1;False;;0;True;_StencilZFail;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;3;d3d11;metal;vulkan;0;Off;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;129;6784,672;Inherit;False;Property;_ZTest;Z Test;26;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;637;2201,1599;Inherit;False;ArcProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;4705.692,-304;Inherit;False;TypeRectangle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;4688,1152;Inherit;False;TypeArc;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;4768,368;Inherit;False;TypeCircle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;788;6576,-1616;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;817;6768,-1472;Inherit;False;3;0;FLOAT;-0.1;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;787;6768,-1568;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;814;6928,-1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;816;7056,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;322;6048,224;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;5952,-1648;Inherit;False;MainColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;5952,-1472;Inherit;False;SubColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;167;1872,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;163;2016,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;1824,192;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;548;1728,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;1520,96;Inherit;False;Constant;_14;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;874;1568,176;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;2144,80;Inherit;False;RactangleWidthAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;6784,512;Inherit;False;Property;_BlendDst;Blend Dst;24;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;6784,432;Inherit;False;Property;_BlendSrc;Blend Src;23;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;612;4689,-1112;Inherit;False;Property;_MinAlpha;알파의 최솟값;5;0;Create;False;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;5600,-1024;Inherit;False;Property;_Angle;_Angle;11;1;[HideInInspector];Create;False;0;0;0;True;0;False;360;1;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;4688,-864;Inherit;False;Property;_Tiling;점 패턴의 밀도;7;1;[IntRange];Create;False;0;0;0;True;0;False;10;0;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;829;5040,-864;Inherit;False;Tiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;186;4864,-1648;Inherit;False;Property;_MainColor;MainColor;18;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;240;4864,-1472;Inherit;False;Property;_SubColor;SubColor;20;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;820;5088,-1648;Inherit;False;Property;_UnfilledColor;_UnfilledColor;16;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;819;5088,-1472;Inherit;False;Property;_FilledColor;_FilledColor;19;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;5568,-1472;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;860;5312,-1392;Inherit;False;Property;_IntensityColor;게이지 컬러 인텐시티;3;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;858;5568,-1648;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;209;5600,-1184;Inherit;False;Property;_FillRate;_FillRate;13;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;873;1376,175;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;7344,-1584;Inherit;False;GaugeAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;280;1152,480;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;518;1472,1392;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;826;1296,1392;Inherit;False;825;Direction;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;514;1088,1232;Inherit;False;Constant;_0;0;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;1488,1168;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;513;1264,1232;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;516;1824,1296;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;521;1632,1392;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;522;1664,1168;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ACosOpNode;490;1936,1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;489;2048,1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;519;2192,1296;Inherit;False;Degree;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;444;2048,816;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;453;1920,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;1792,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;445;1664,816;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;454;1648,912;Inherit;False;Constant;_1;1;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;334;1424,816;Inherit;False;Polar Coordinates;-1;;13;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;1232,912;Inherit;False;Constant;_16;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;1216,816;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;1616,-544;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;20;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;169;1776,-544;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;2176,-512;Inherit;False;DotPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;831;1424,-464;Inherit;False;829;Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;958;6912,-864;Inherit;False;BoundingBox;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;6912,-944;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;973;6352,-944;Inherit;False;MMN_Decal;-1;;16;e77bca24c8bef3c4f881df7c049f144a;0;0;3;FLOAT2;62;FLOAT;2;FLOAT4;66
Node;AmplifyShaderEditor.DynamicAppendNode;971;6752,-672;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;972;6592,-672;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;978;6304,304;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;960;6064,368;Inherit;False;958;BoundingBox;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;955;1888,-576;Inherit;True;Property;_MainTex;메인 텍스쳐;2;1;[NoScaleOffset];Create;False;0;0;0;False;2;Header(Color Design Options);Space(10);False;-1;e65f70cb4b8718c4f9047e3eab4db5e1;e65f70cb4b8718c4f9047e3eab4db5e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;980;1328,1136;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;979;1072,1136;Inherit;False;976;WorldSpaceDegree;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;976;6912,-768;Inherit;False;WorldSpaceDegree;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;970;1408,-544;Inherit;False;969;DecalWorldSpace;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;969;6913,-672;Inherit;False;DecalWorldSpace;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;782;7200,-1312;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;7344,-1312;Inherit;False;StartAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;823;6848,-1248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;808;7008,-1312;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;6576,-1248;Inherit;False;Property;_StartAnimSpeed;시작 모션의 속도 값;14;0;Create;False;0;0;0;False;2;Header(Animation Options);Space(10);False;0.9;15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;784;6832,-1328;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;583;5952,-864;Inherit;False;InnerRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;921;5744,-944;Inherit;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;584;5345,-896;Inherit;False;Property;_InnerRadius;_InnerRadius;10;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;5341,-815;Inherit;False;Property;_OuterRadius;_OuterRadius;8;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;6784,592;Inherit;False;Property;_CullMode;Cull Mode;25;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;953;4536.619,-1437.512;Inherit;False;Property;_ColorMatte;_ColorMatte;17;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;954;4551,-1250;Inherit;False;Property;_FinalAlphaMatte;_FinalAlphaMatte;12;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;981;6759.973,782.4847;Inherit;False;Property;_FogReceive;안개 적용;0;0;Create;False;0;0;0;True;1;HideInInspector;False;1;1;1;True;_FOG_RCV_ON;Toggle;2;Key0;Key1;Create;True;False;Fragment;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
WireConnection;323;0;317;0
WireConnection;385;0;384;0
WireConnection;337;0;385;0
WireConnection;337;3;465;0
WireConnection;378;0;360;0
WireConnection;360;0;727;0
WireConnection;360;1;731;0
WireConnection;729;0;358;0
WireConnection;729;1;669;0
WireConnection;383;0;729;0
WireConnection;727;0;383;0
WireConnection;727;1;618;0
WireConnection;731;0;383;0
WireConnection;731;1;349;0
WireConnection;358;0;357;0
WireConnection;351;0;378;0
WireConnection;351;1;350;0
WireConnection;422;0;421;0
WireConnection;421;0;378;0
WireConnection;421;1;418;0
WireConnection;345;0;355;0
WireConnection;346;0;345;0
WireConnection;346;1;786;0
WireConnection;307;0;181;0
WireConnection;307;3;178;0
WireConnection;427;0;482;0
WireConnection;427;3;622;0
WireConnection;604;0;601;0
WireConnection;604;1;600;0
WireConnection;604;2;603;0
WireConnection;601;0;484;0
WireConnection;484;0;483;0
WireConnection;482;0;480;0
WireConnection;479;0;692;0
WireConnection;689;0;604;0
WireConnection;689;1;617;0
WireConnection;730;0;604;0
WireConnection;730;1;481;0
WireConnection;692;0;689;0
WireConnection;692;1;730;0
WireConnection;471;0;479;0
WireConnection;471;1;472;0
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
WireConnection;622;0;479;0
WireConnection;622;1;587;0
WireConnection;622;2;568;0
WireConnection;622;3;546;0
WireConnection;622;4;927;0
WireConnection;465;0;422;0
WireConnection;465;1;346;0
WireConnection;465;2;926;0
WireConnection;480;0;471;0
WireConnection;480;1;473;0
WireConnection;480;2;485;0
WireConnection;384;0;351;0
WireConnection;384;1;386;0
WireConnection;384;2;854;0
WireConnection;854;0;387;0
WireConnection;861;0;820;0
WireConnection;863;0;819;0
WireConnection;864;0;858;0
WireConnection;864;3;820;4
WireConnection;865;0;859;0
WireConnection;865;3;819;4
WireConnection;529;0;488;0
WireConnection;825;0;517;0
WireConnection;354;0;444;0
WireConnection;235;0;273;0
WireConnection;235;1;263;0
WireConnection;398;0;399;0
WireConnection;402;0;417;0
WireConnection;399;0;405;0
WireConnection;399;1;401;0
WireConnection;397;0;399;0
WireConnection;393;0;394;0
WireConnection;393;1;395;0
WireConnection;395;0;396;0
WireConnection;395;1;397;0
WireConnection;401;0;792;0
WireConnection;405;0;400;0
WireConnection;625;0;631;0
WireConnection;626;0;793;0
WireConnection;699;0;700;0
WireConnection;317;1;329;0
WireConnection;317;0;331;0
WireConnection;317;2;759;0
WireConnection;267;0;794;0
WireConnection;303;0;416;0
WireConnection;388;0;306;0
WireConnection;872;0;870;0
WireConnection;635;0;634;0
WireConnection;635;1;636;0
WireConnection;627;0;632;0
WireConnection;631;0;697;0
WireConnection;631;1;626;0
WireConnection;624;0;625;0
WireConnection;624;1;627;0
WireConnection;636;0;624;0
WireConnection;636;1;633;0
WireConnection;392;0;393;0
WireConnection;669;0;668;0
WireConnection;246;0;238;0
WireConnection;263;0;300;0
WireConnection;263;1;265;0
WireConnection;294;0;235;0
WireConnection;238;0;280;0
WireConnection;238;1;267;0
WireConnection;300;0;246;0
WireConnection;300;1;303;0
WireConnection;265;0;238;0
WireConnection;309;0;209;0
WireConnection;911;0;816;0
WireConnection;396;0;398;0
WireConnection;396;1;402;0
WireConnection;914;0;913;0
WireConnection;915;0;789;0
WireConnection;915;2;916;0
WireConnection;753;0;701;0
WireConnection;698;0;699;0
WireConnection;595;0;921;0
WireConnection;920;0;917;0
WireConnection;917;0;584;0
WireConnection;917;1;594;0
WireConnection;415;0;301;0
WireConnection;924;0;923;0
WireConnection;181;0;241;0
WireConnection;589;0;271;0
WireConnection;589;1;279;0
WireConnection;589;2;615;0
WireConnection;231;0;589;0
WireConnection;180;0;313;0
WireConnection;180;1;231;0
WireConnection;241;0;180;0
WireConnection;241;1;314;0
WireConnection;241;2;299;0
WireConnection;298;0;231;0
WireConnection;298;1;575;0
WireConnection;291;0;298;0
WireConnection;291;1;295;0
WireConnection;293;0;291;0
WireConnection;588;0;288;0
WireConnection;588;1;614;0
WireConnection;575;0;588;0
WireConnection;178;0;293;0
WireConnection;178;1;284;0
WireConnection;178;2;925;0
WireConnection;507;0;506;2
WireConnection;507;1;510;0
WireConnection;613;0;612;0
WireConnection;278;0;872;1
WireConnection;633;0;631;0
WireConnection;697;0;698;0
WireConnection;697;1;753;0
WireConnection;697;2;702;0
WireConnection;97;0;322;0
WireConnection;97;1;978;0
WireConnection;637;0;635;0
WireConnection;321;0;307;0
WireConnection;326;0;427;0
WireConnection;325;0;337;0
WireConnection;817;2;788;0
WireConnection;787;0;788;0
WireConnection;787;1;915;0
WireConnection;814;0;787;0
WireConnection;814;1;817;0
WireConnection;816;0;814;0
WireConnection;322;0;323;0
WireConnection;322;1;323;1
WireConnection;322;2;323;2
WireConnection;312;0;864;0
WireConnection;311;0;865;0
WireConnection;167;0;548;0
WireConnection;163;0;167;0
WireConnection;163;1;316;0
WireConnection;548;0;874;0
WireConnection;548;1;511;0
WireConnection;874;0;873;0
WireConnection;283;0;163;0
WireConnection;829;0;199;0
WireConnection;859;0;863;0
WireConnection;859;1;860;0
WireConnection;858;0;861;0
WireConnection;790;0;911;0
WireConnection;518;0;826;0
WireConnection;523;0;980;0
WireConnection;523;1;513;0
WireConnection;513;0;514;0
WireConnection;516;0;522;0
WireConnection;516;1;521;0
WireConnection;521;0;518;0
WireConnection;522;0;523;0
WireConnection;490;0;516;0
WireConnection;489;0;490;0
WireConnection;519;0;489;0
WireConnection;444;0;445;0
WireConnection;444;1;453;0
WireConnection;453;0;442;0
WireConnection;442;0;445;1
WireConnection;442;1;454;0
WireConnection;445;0;334;0
WireConnection;334;1;875;0
WireConnection;334;2;338;0
WireConnection;168;0;970;0
WireConnection;168;1;831;0
WireConnection;169;0;168;0
WireConnection;272;0;955;2
WireConnection;958;0;973;2
WireConnection;869;0;973;62
WireConnection;971;0;972;0
WireConnection;971;1;972;2
WireConnection;972;0;973;66
WireConnection;978;0;323;3
WireConnection;978;1;960;0
WireConnection;955;1;169;0
WireConnection;980;0;979;0
WireConnection;976;0;973;66
WireConnection;969;0;971;0
WireConnection;782;0;808;0
WireConnection;315;0;782;0
WireConnection;823;0;822;0
WireConnection;808;0;784;0
WireConnection;808;2;823;0
WireConnection;583;0;920;0
ASEEND*/
//CHKSM=3802489FB7131016930EE47A31264EA11893D2AE