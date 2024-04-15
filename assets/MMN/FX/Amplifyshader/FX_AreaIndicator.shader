// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_AreaIndicator"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector]_Mode("Mode", Float) = -1
		[Header(Indicator Options)][Space(10)][KeywordEnum(Rectangle,Arc,Circle,Debug)] _Type("Type", Float) = 0
		[HideInInspector]_LineWidth("_LineWidth", Float) = 0.1
		[HideInInspector]_Radius("_Radius", Float) = 0.5
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
		[HideInInspector][HDR]_ColorMatte("_ColorMatte", Color) = (1,1,1,1)
		[HideInInspector][HDR]_MainColor("MainColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_SubColor("SubColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_UnfilledColor("_UnfilledColor", Color) = (1,1,1,1)
		[HideInInspector][HDR]_FilledColor("_FilledColor", Color) = (1,1,1,1)
		[HideInInspector]_Direction("_Direction", Vector) = (1,0,1,0)
		[HideInInspector]_ColorBlendT("_ColorBlendT", Range( 0 , 1)) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][ToggleUI]_FogReceive("FogReceive", Range( 0 , 1)) = 0

	}

	SubShader
	{
		LOD 100

		

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

			// Unity defined keywords
			#pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			#include "../Includes/FXCommonOutputs.hlsl"
			#pragma multi_compile_local _TYPE_RECTANGLE _TYPE_ARC _TYPE_CIRCLE _TYPE_DEBUG


			sampler2D _MainTex;
			float _DimmingFactor;
			float _IsControlPlayer;
			CBUFFER_START( UnityPerMaterial )
			float4 _SubColor;
			float4 _MainColor;
			float4 _ColorMatte;
			float4 _UnfilledColor;
			float4 _Direction;
			float4 _FilledColor;
			float _LineWidth;
			float _Radius;
			float _Angle;
			float _OuterRadius;
			float _InnerRadius;
			float _FinalAlpha;
			float _StartAnimSpeed;
			float _FillRate;
			float _GaugeAnimDamping;
			float _Mode;
			float _GradationLength;
			float _IntensityColor;
			float _MinAlpha;
			float _Tiling;
			float _FinalAlphaMatte;
			float _ColorBlendT;
			float _IsHostile;
			float _FogReceive;
			CBUFFER_END


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
				
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
				float4 uv1 : TEXCOORD1; 				// xyzw : custom data
				float4 screenPos : TEXCOORD6;			// xyzw : ScreenSpace
				float4 fogCoord : TEXCOORD7; 		    // x : fogcoord				yzw :
				float3 positionWS : TEXCOORD8;
				float4 positionOS : TEXCOORD9;
				float3 normalWS : TEXCOORD10;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord2 = screenPos;
				
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

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord;
				output.positionWS = vertexInput.positionWS;
				output.positionOS = input.positionOS;
				output.positionCS = vertexInput.positionCS;
				output.screenPos = ComputeScreenPos(vertexInput.positionCS);
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				float localApplyFogColor982 = ( 0.0 );
				float3 appendResult861 = (float3(_UnfilledColor.rgb));
				float4 appendResult864 = (float4(( appendResult861 * float3( 1,1,1 ) ) , _UnfilledColor.a));
				float4 MainColor312 = appendResult864;
				float localApplyScreenSpaceDecal36_g16 = ( 0.0 );
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g16 = ase_screenPosNorm;
				float2 decalUV36_g16 = float2( 0,0 );
				float boundingBox36_g16 = 0.0;
				float4 decalWorldSpace36_g16 = float4( 0,0,0,0 );
				ApplyScreenSpaceDecal( screenPos36_g16 , decalUV36_g16 , boundingBox36_g16 , decalWorldSpace36_g16 );
				float4 temp_output_973_66 = decalWorldSpace36_g16;
				float4 break972 = temp_output_973_66;
				float3 appendResult971 = (float3(break972.x , break972.z , break972.y));
				float3 DecalWorldSpace969 = appendResult971;
				float Tiling829 = _Tiling;
				float DotPattern272 = tex2D( _MainTex, frac( ( DecalWorldSpace969 * Tiling829 ) ).xy ).g;
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
				float DimmingFactor1073 = ( _DimmingFactor * _IsControlPlayer );
				float lerpResult1102 = lerp( 1.0 , 2.0 , DimmingFactor1073);
				float ColorForDimming1100 = lerpResult1102;
				float3 appendResult181 = (float3(( lerpResult241 * ColorForDimming1100 ).xyz));
				float smoothstepResult808 = smoothstep( 0.0 , ( 1.0 - _StartAnimSpeed ) , Progress309);
				float StartAnim315 = saturate( smoothstepResult808 );
				float RactangleWidthAlpha283 = step( abs( ( UV869.x - 0.5 ) ) , StartAnim315 );
				float FinalAlpha924 = _FinalAlpha;
				float4 appendResult307 = (float4(appendResult181 , ( saturate( ( ( temp_output_231_0 * saturate( max( ObjectPositionY278 , MinAlpha613 ) ) ) + RactangleProgression294 ) ) * RactangleWidthAlpha283 * FinalAlpha924 )));
				float4 TypeRectangle321 = appendResult307;
				float InnerRadius583 = saturate( ( _InnerRadius / _OuterRadius ) );
				float OuterRadius595 = 1.0;
				float2 temp_cast_4 = (0.5).xx;
				float2 CenteredUV15_g13 = ( UV869 - temp_cast_4 );
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
				float3 appendResult482 = (float3(( lerpResult480 * ColorForDimming1100 ).xyz));
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
				float3 appendResult385 = (float3(( lerpResult384 * ColorForDimming1100 ).xyz));
				float4 appendResult337 = (float4(appendResult385 , ( saturate( ( temp_output_378_0 + ArcProgression637 ) ) * step( PolarCoord354.x , StartAnim315 ) * FinalAlpha924 )));
				float4 TypeCircle325 = appendResult337;
				float Radius1022 = _Radius;
				float LineWidth1003 = _LineWidth;
				float temp_output_1040_0 = ( Radius1022 - LineWidth1003 );
				float3 objToWorld1062 = mul( GetObjectToWorldMatrix(), float4( float3(0,0,0), 1 ) ).xyz;
				float3 appendResult1084 = (float3(WorldSpaceDegree976.xyz));
				float LengthPosition1059 = length( ( objToWorld1062 - appendResult1084 ) );
				float4 lerpResult1036 = lerp( SubColor311 , MainColor312 , ( step( ( Progress309 * temp_output_1040_0 ) , LengthPosition1059 ) * step( LengthPosition1059 , temp_output_1040_0 ) ));
				float4 break1054 = lerpResult1036;
				float3 appendResult1053 = (float3(break1054.x , break1054.y , break1054.z));
				float temp_output_1005_0 = ( LineWidth1003 * 0.5 );
				float distance1028 = LengthPosition1059;
				float radius1028 = Radius1022;
				float degree1028 = Degree519;
				float lineWidth1028 = LineWidth1003;
				float2 localAreaindicatorForDebug1028 = AreaindicatorForDebug( distance1028 , radius1028 , degree1028 , lineWidth1028 );
				float2 break1045 = localAreaindicatorForDebug1028;
				float4 appendResult994 = (float4(appendResult1053 , ( break1054.w * step( LengthPosition1059 , Radius1022 ) * saturate( ( step( frac( LengthPosition1059 ) , temp_output_1005_0 ) + step( ( ceil( LengthPosition1059 ) - LengthPosition1059 ) , temp_output_1005_0 ) + break1045.x + break1045.y ) ) )));
				float4 TypeDebug995 = appendResult994;
				#if defined(_TYPE_RECTANGLE)
				float4 staticSwitch317 = TypeRectangle321;
				#elif defined(_TYPE_ARC)
				float4 staticSwitch317 = TypeArc326;
				#elif defined(_TYPE_CIRCLE)
				float4 staticSwitch317 = TypeCircle325;
				#elif defined(_TYPE_DEBUG)
				float4 staticSwitch317 = TypeDebug995;
				#else
				float4 staticSwitch317 = TypeRectangle321;
				#endif
				float4 break323 = staticSwitch317;
				float3 appendResult322 = (float3(break323.x , break323.y , break323.z));
				float BoundingBox958 = boundingBox36_g16;
				float4 appendResult987 = (float4(appendResult322 , ( break323.w * BoundingBox958 )));
				float4 finalColor982 = appendResult987;
				float3 positionWS982 = input.positionWS;
				float3 normalWS982 = input.normalWS;
				float mode982 = _Mode;
				float fogReceive982 = _FogReceive;
				float4 texCoord986 = input.fogCoord;
				texCoord986.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord982 = texCoord986;
				ApplyFogColor( finalColor982 , positionWS982 , normalWS982 , mode982 , fogReceive982 , fogCoord982 );
				float4 break993 = finalColor982;
				float3 appendResult991 = (float3(break993.x , break993.y , break993.z));
				
				float3 color = appendResult991;
				float alpha = break993.w;

				float4 finalColor = float4(color, alpha);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, color, alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}
	
	
	
	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;1107;7152,-448;Inherit;False;692;259;ColorForDimming;4;1081;1100;1104;1102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1071;3648,2832;Inherit;False;1124;931;Alpha;20;1029;1031;1045;1019;1020;1055;1028;1033;1032;1006;1015;1000;1014;1005;1001;1004;1066;1009;1067;1068;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1065;1380,2400;Inherit;False;1013.921;326;WorldLengthPosition;6;1070;1063;1062;1061;1059;1057;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1052;3648,2272;Inherit;False;1431.04;526.8188;Color;14;1036;1051;1050;1037;1041;1035;1034;1069;1053;1054;1042;1039;1038;1040;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;977;7152,-976;Inherit;False;884;507;Decal;7;958;869;973;971;972;969;976;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;900;1264,16;Inherit;False;1133;308;Ractangle Width Alpha;8;283;316;874;511;873;163;167;548;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;867;6160,-1216;Inherit;False;881;1108;Script;25;1119;1072;1073;209;1021;1002;1022;1003;594;584;306;488;921;517;913;309;583;825;595;917;920;914;388;529;1120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;866;5696,-1680;Inherit;False;1330;438;Color;13;312;311;820;819;861;863;859;858;860;864;865;186;240;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;7152,-1680;Inherit;False;1260.2;668.7999;Animation;16;822;808;823;784;315;782;790;816;814;787;817;788;916;789;915;911;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;797;4016,1440;Inherit;False;1204;678;Alpha;16;606;585;586;607;587;622;596;547;568;546;796;795;567;566;758;927;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;774;720,352;Inherit;False;1672.742;380.5703;Ractangle Progression;13;416;303;267;280;238;246;265;300;263;273;235;294;794;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;770;368,1536;Inherit;False;2037;406;Arc Progression;19;635;636;625;632;627;624;633;631;626;634;637;697;698;699;753;701;700;702;793;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;766;736,1968;Inherit;False;1666;406;Circle Progression;14;396;398;402;399;397;394;393;395;392;401;400;405;417;792;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;733;3091.902,928;Inherit;False;2169.098;451.9316;Color;20;484;480;471;485;692;730;689;479;473;472;482;481;617;603;600;483;601;604;1109;1108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;732;3227,128;Inherit;False;2034;404;Color;21;1098;1106;854;384;358;350;668;669;387;349;351;357;731;727;618;383;729;360;378;386;385;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;525;976,1040;Inherit;False;1433;480;Degree;13;519;489;490;522;521;516;513;523;514;826;518;980;979;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;864,752;Inherit;False;1546;264;Polar Coordinate;9;354;444;453;454;442;338;445;334;875;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;367;4400,560;Inherit;False;860.0341;337.2867;Alpha;9;346;355;345;418;421;465;422;786;1105;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;305;3452.656,-672;Inherit;False;1803.344;425.8906;Color;13;1111;299;241;180;231;589;615;279;271;313;314;1110;181;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;304;4133.879,-224;Inherit;False;1122.121;322.2227;Alpha;11;925;178;284;295;575;588;614;293;288;291;298;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;282;1603,-320;Inherit;False;794;313;Object Position Y;6;278;510;506;507;870;872;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;275;1360,-640;Inherit;False;1036.427;289.9003;Dot Pattern;6;272;970;831;169;168;955;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;76;8240,400;Inherit;False;204;375;Rendering Options;4;79;78;77;129;;1,1,1,1;0;0
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
Node;AmplifyShaderEditor.OneMinusNode;267;1200,560;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;303;1200,640;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;872;2032,-240;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;2048,1600;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;400;1056,2080;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;627;1232,1824;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;634;1856,1584;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;631;1392,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;992,1824;Inherit;False;415;GragationLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;624;1696,1664;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;636;1888,1664;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;392;2160,2032;Inherit;False;CircleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;246;1536,480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;273;1840,400;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;1872,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;2160,416;Inherit;False;RactangleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;416;960,640;Inherit;False;415;GragationLength;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;238;1376,479;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;300;1680,480;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;265;1712,608;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;794;992,560;Inherit;False;790;GaugeAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;396;1680,2096;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;753;592,1696;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;752,1600;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;1856,-241;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;507;1823,-172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;1663,-108;Inherit;False;Constant;_13;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;701;416,1696;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;793;1024,1744;Inherit;False;790;GaugeAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;416,1824;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;633;1728,1792;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;697;944,1600;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;637;2201,1599;Inherit;False;ArcProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;167;1872,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;163;2016,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;1824,192;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;548;1728,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;1520,96;Inherit;False;Constant;_14;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;874;1568,176;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;2144,80;Inherit;False;RactangleWidthAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;280;1152,480;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;1488,1168;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;516;1824,1296;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;522;1664,1168;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ACosOpNode;490;1936,1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;489;2048,1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;444;2048,816;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;453;1920,896;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;1792,896;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;445;1664,816;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;454;1648,912;Inherit;False;Constant;_1;1;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;334;1424,816;Inherit;False;Polar Coordinates;-1;;13;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;1232,912;Inherit;False;Constant;_16;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;169;1776,-544;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;955;1888,-576;Inherit;True;Property;_MainTex;메인 텍스쳐;4;1;[NoScaleOffset];Create;False;0;0;0;False;2;Header(Color Design Options);Space(10);False;-1;e65f70cb4b8718c4f9047e3eab4db5e1;e65f70cb4b8718c4f9047e3eab4db5e1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;980;1328,1136;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;985;7216,800;Inherit;False;292;259;fogCoord;1;986;Vertex Data;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;518;1472,1392;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;354;2192,816;Inherit;False;PolarCoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;1216,816;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;506;1631,-252;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;514;1088,1232;Inherit;False;Constant;_0;0;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;513;1264,1232;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;1057;2016,2528;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1061;1424,2448;Inherit;False;Constant;_2;0;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;1062;1600,2448;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1063;1856,2528;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;519;2192,1296;Inherit;False;Degree;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;521;1632,1392;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;979;1072,1136;Inherit;False;976;WorldSpaceDegree;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;826;1296,1391;Inherit;False;825;Direction;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1059;2160,2528;Inherit;False;LengthPosition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;2160,-240;Inherit;False;ObjectPositionY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;873;1376,175;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;272;2176,-512;Inherit;False;DotPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;831;1424,-464;Inherit;False;829;Tiling;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;970;1408,-544;Inherit;False;969;DecalWorldSpace;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;1616,-544;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;20;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;1084;1664,2608;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1070;1424,2608;Inherit;False;976;WorldSpaceDegree;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;385;5104,176;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;337;5408,384;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;422;4928,608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;4800,608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;4544,608;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;4656,704;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;355;4464,704;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;346;4928,688;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;307;5408,-288;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;482;5088,976;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;4256,1504;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;4384,1600;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;586;4720,1504;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;607;4432,1504;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;587;4848,1504;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;596;4384,1680;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;4400,1760;Inherit;False;519;Degree;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;568;4720,1664;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;546;4720,1760;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;796;4416,1840;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;5056,1504;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;5120,608;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;786;4608,800;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;5904,320;Inherit;False;326;TypeArc;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;5904,240;Inherit;False;321;TypeRectangle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;861;6160,-1632;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;863;6160,-1456;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;864;6576,-1632;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;865;6576,-1456;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;6800,-1008;Inherit;False;Angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;388;6800,-1088;Inherit;False;ColorBlendT;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;911;8048,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;914;6800,-592;Inherit;False;IsHostile;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;915;7440,-1504;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;920;6592,-848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;917;6448,-848;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;5888,-928;Inherit;False;GragationLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;924;5888,-992;Inherit;False;FinalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;5088,-464;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;4672,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;4816,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;4224,-144;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;293;4960,-176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;614;4256,-64;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;588;4416,-144;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;4528,-144;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;295;4544,-64;Inherit;False;294;RactangleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;4816,-64;Inherit;False;283;RactangleWidthAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;5104,-176;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;5536,-928;Inherit;False;Property;_GradationLength;게이지 차오르는 그라데이션의 길이;8;0;Create;False;0;0;0;True;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;923;5536,-1008;Inherit;False;Property;_FinalAlpha;알파의 최종값;6;1;[HideInInspector];Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;916;7216,-1392;Inherit;False;914;IsHostile;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;613;5888,-1088;Inherit;False;MinAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;5552,-288;Inherit;False;TypeRectangle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;5616,384;Inherit;False;TypeCircle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;817;7616,-1456;Inherit;False;3;0;FLOAT;-0.1;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;787;7616,-1552;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;814;7776,-1552;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;816;7904,-1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;322;6896,240;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;612;5536,-1088;Inherit;False;Property;_MinAlpha;알파의 최솟값;7;0;Create;False;0;0;0;False;0;False;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;5536,-848;Inherit;False;Property;_Tiling;점 패턴의 밀도;9;1;[IntRange];Create;False;0;0;0;True;0;False;10;0;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;829;5888,-848;Inherit;False;Tiling;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;240;5712,-1456;Inherit;False;Property;_SubColor;SubColor;20;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;820;5936,-1632;Inherit;False;Property;_UnfilledColor;_UnfilledColor;21;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;859;6416,-1456;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;858;6416,-1632;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;8192,-1568;Inherit;False;GaugeAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;958;7760,-848;Inherit;False;BoundingBox;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;978;7152,320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;960;6912,384;Inherit;False;958;BoundingBox;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;782;8048,-1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;8192,-1296;Inherit;False;StartAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;823;7696,-1232;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;808;7856,-1296;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;784;7680,-1312;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;987;7328,240;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;986;7264,848;Inherit;False;7;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;989;7328,336;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;988;7328,480;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;990;7360,624;Inherit;False;Property;_Mode;Mode;0;1;[HideInInspector];Create;False;0;0;0;True;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;983;7232,704;Inherit;False;Property;_FogReceive;FogReceive;29;2;[HideInInspector];[ToggleUI];Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;993;7920,240;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;991;8080,240;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;129;8272,688;Inherit;False;Property;_ZTest;Z Test;28;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;8272,528;Inherit;False;Property;_BlendDst;Blend Dst;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;8272,448;Inherit;False;Property;_BlendSrc;Blend Src;25;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;8272,608;Inherit;False;Property;_CullMode;Cull Mode;27;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;8240,240;Float;False;True;-1;2;;100;14;MMN/FX/Amplify shader/FX_AreaIndicator;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=100;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;1;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;10;True;_StencilValue;255;False;;255;False;;1;True;_StencilComp;1;False;;1;False;;0;True;_StencilZFail;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;3;d3d11;metal;vulkan;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.DynamicAppendNode;427;5392,1168;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;5536,1168;Inherit;False;TypeArc;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;759;5904,400;Inherit;False;325;TypeCircle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;996;5904,480;Inherit;False;995;TypeDebug;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;6800,-928;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;927;4672,1856;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;795;4240,1840;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;4064,1920;Inherit;False;529;Angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;566;4240,1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;758;4208,2016;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;825;6800,-768;Inherit;False;Direction;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;583;6800,-848;Inherit;False;InnerRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;6800,-1632;Inherit;False;MainColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;6800,-1456;Inherit;False;SubColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;6800,-1168;Inherit;False;Progress;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;788;7424,-1600;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1040;3904,2576;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1038;3696,2544;Inherit;False;1022;Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1039;3696,2624;Inherit;False;1003;LineWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1042;3888,2496;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1054;4768,2368;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;994;5376,2800;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;995;5520,2800;Inherit;False;TypeDebug;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;1053;4928,2368;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1069;3888,2688;Inherit;False;1059;LengthPosition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1034;4320,2400;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1035;4320,2320;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1041;4080,2512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1037;4240,2544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1050;4240,2656;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1051;4384,2592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1036;4560,2320;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;913;6448,-592;Inherit;False;Property;_IsHostile;_IsHostile;11;2;[HideInInspector];[Toggle];Create;False;0;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;517;6560,-768;Inherit;False;Property;_Direction;_Direction;23;0;Create;False;0;0;0;True;1;HideInInspector;False;1,0,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;921;6592,-928;Inherit;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;6448,-1008;Inherit;False;Property;_Angle;_Angle;13;1;[HideInInspector];Create;False;0;0;0;True;0;False;360;1;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;6448,-1088;Inherit;False;Property;_ColorBlendT;_ColorBlendT;24;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;584;6192,-880;Inherit;False;Property;_InnerRadius;_InnerRadius;12;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;6192,-800;Inherit;False;Property;_OuterRadius;_OuterRadius;10;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;819;5936,-1456;Inherit;False;Property;_FilledColor;_FilledColor;22;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;860;6160,-1376;Inherit;False;Property;_IntensityColor;게이지 컬러 인텐시티;5;0;Create;False;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;7424,-1232;Inherit;False;Property;_StartAnimSpeed;시작 모션의 속도 값;16;0;Create;False;0;0;0;False;2;Header(Animation Options);Space(10);False;0.9;15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;789;7168,-1504;Inherit;False;Property;_GaugeAnimDamping;게이지 차오르는 모션의 댐핑 값;17;0;Create;False;0;0;0;False;0;False;10;15;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1029;4480,3296;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1031;4592,3296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1045;4272,3424;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;1019;3712,3568;Inherit;False;519;Degree;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1020;3712,3488;Inherit;False;1022;Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1055;3712,3648;Inherit;False;1003;LineWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;1028;4032,3408;Inherit;False; ;2;File;4;True;distance;FLOAT;0;In;;Half;False;True;radius;FLOAT;0;In;;Half;False;True;degree;FLOAT;0;In;;Half;False;True;lineWidth;FLOAT;0;In;;Half;False;AreaindicatorForDebug;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1006;3920,3184;Inherit;False;Constant;_Float4;Float 4;29;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1015;4096,3280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1000;4272,2992;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1014;4272,3280;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1005;4096,3104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;1001;4096,2992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1004;3888,3104;Inherit;False;1003;LineWidth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;1009;3984,3280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1067;3744,3296;Inherit;False;1059;LengthPosition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1068;3712,3408;Inherit;False;1059;LengthPosition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;972;7440,-656;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;971;7600,-656;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1003;6800,-512;Inherit;False;LineWidth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1022;6800,-432;Inherit;False;Radius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1002;6576,-512;Inherit;False;Property;_LineWidth;_LineWidth;2;1;[HideInInspector];Create;False;0;0;0;True;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1021;6576,-432;Inherit;False;Property;_Radius;_Radius;3;1;[HideInInspector];Create;False;0;0;0;True;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;186;5712,-1632;Inherit;False;Property;_MainColor;MainColor;19;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;973;7200,-928;Inherit;False;MMN_Decal;-1;;16;e77bca24c8bef3c4f881df7c049f144a;0;0;3;FLOAT2;62;FLOAT;2;FLOAT4;66
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;7760,-928;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;209;6448,-1168;Inherit;False;Property;_FillRate;_FillRate;15;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1066;3696,2992;Inherit;False;1059;LengthPosition;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;969;7760,-656;Inherit;False;DecalWorldSpace;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;976;7760,-752;Inherit;False;WorldSpaceDegree;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1033;3696,2896;Inherit;False;1022;Radius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1032;4272,2880;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1046;5072,2864;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;954;5408,-1456;Inherit;False;Property;_FinalAlphaMatte;_FinalAlphaMatte;14;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;953;5408,-1632;Inherit;False;Property;_ColorMatte;_ColorMatte;18;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;323;6544,240;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StaticSwitch;317;6272,240;Inherit;False;Property;_Type;Type;1;0;Create;False;0;0;0;True;2;Header(Indicator Options);Space(10);False;1;0;0;True;;KeywordEnum;4;Rectangle;Arc;Circle;Debug;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;925;4880,16;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;386;4272,336;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;378;4272,176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;4144,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;729;3616,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;383;3744,176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;618;3744,256;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;727;3984,176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;731;3984,288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;357;3280,176;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;4592,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;349;3744,336;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;387;4272,416;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;669;3456,288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;668;3280,288;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;350;4272,256;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;358;3456,176;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;384;4784,176;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;854;4752,336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1098;4944,176;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SmoothstepOpNode;604;3616,976;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;601;3472,976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;483;3152,976;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;600;3152,1056;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;3152,1136;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;617;3616,1104;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;481;3616,1184;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;472;4256,1072;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;473;4256,1152;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;479;4256,976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;689;3888,976;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;730;3888,1072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;692;4128,976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;485;4256,1232;Inherit;False;637;ArcProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;4448,976;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;480;4624,976;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;484;3328,976;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1109;4928,976;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1108;4688,1136;Inherit;False;1100;ColorForDimming;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1110;4928,-464;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;241;4672,-464;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1111;4688,-336;Inherit;False;1100;ColorForDimming;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;4032,-624;Inherit;False;311;SubColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;4032,-528;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;3680,-512;Inherit;False;272;DotPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;279;3664,-432;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;615;3696,-352;Inherit;False;613;MinAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;589;3968,-432;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;231;4080,-432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;4400,-464;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;299;4400,-368;Inherit;False;294;RactangleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;982;7648,224;Inherit;False; ;7;File;6;True;finalColor;FLOAT4;0,0,0,0;InOut;;Half;False;True;positionWS;FLOAT3;0,0,0;In;;Half;False;True;normalWS;FLOAT3;0,0,0;In;;Half;False;True;mode;FLOAT;0;In;;Half;False;True;fogReceive;FLOAT;0;In;;Half;False;True;fogCoord;FLOAT4;0,0,0,0;In;;Float;False;ApplyFogColor;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;7;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT4;2
Node;AmplifyShaderEditor.LerpOp;1102;7424,-384;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1073;6784,-336;Inherit;False;DimmingFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1105;4928,800;Inherit;False;924;FinalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1106;4720,416;Inherit;False;1100;ColorForDimming;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1100;7600,-384;Inherit;False;ColorForDimming;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1104;7168,-384;Inherit;False;Constant;_DimmingColorIntensity;DimmingColorIntensity;30;0;Create;False;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1081;7200,-288;Inherit;False;1073;DimmingFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1120;6624,-336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1119;6336,-256;Inherit;False;Global;_IsControlPlayer;_IsControlPlayer;34;1;[HideInInspector];Create;True;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1072;6336,-336;Inherit;False;Global;_DimmingFactor;_DimmingFactor;2;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0.0486654;0;1;0;1;FLOAT;0
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
WireConnection;267;0;794;0
WireConnection;303;0;416;0
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
WireConnection;246;0;238;0
WireConnection;263;0;300;0
WireConnection;263;1;265;0
WireConnection;294;0;235;0
WireConnection;238;0;280;0
WireConnection;238;1;267;0
WireConnection;300;0;246;0
WireConnection;300;1;303;0
WireConnection;265;0;238;0
WireConnection;396;0;398;0
WireConnection;396;1;402;0
WireConnection;753;0;701;0
WireConnection;698;0;699;0
WireConnection;507;0;506;2
WireConnection;507;1;510;0
WireConnection;633;0;631;0
WireConnection;697;0;698;0
WireConnection;697;1;753;0
WireConnection;697;2;702;0
WireConnection;637;0;635;0
WireConnection;167;0;548;0
WireConnection;163;0;167;0
WireConnection;163;1;316;0
WireConnection;548;0;874;0
WireConnection;548;1;511;0
WireConnection;874;0;873;0
WireConnection;283;0;163;0
WireConnection;523;0;980;0
WireConnection;523;1;513;0
WireConnection;516;0;522;0
WireConnection;516;1;521;0
WireConnection;522;0;523;0
WireConnection;490;0;516;0
WireConnection;489;0;490;0
WireConnection;444;0;445;0
WireConnection;444;1;453;0
WireConnection;453;0;442;0
WireConnection;442;0;445;1
WireConnection;442;1;454;0
WireConnection;445;0;334;0
WireConnection;334;1;875;0
WireConnection;334;2;338;0
WireConnection;169;0;168;0
WireConnection;955;1;169;0
WireConnection;980;0;979;0
WireConnection;518;0;826;0
WireConnection;354;0;444;0
WireConnection;513;0;514;0
WireConnection;1057;0;1063;0
WireConnection;1062;0;1061;0
WireConnection;1063;0;1062;0
WireConnection;1063;1;1084;0
WireConnection;519;0;489;0
WireConnection;521;0;518;0
WireConnection;1059;0;1057;0
WireConnection;278;0;872;1
WireConnection;272;0;955;2
WireConnection;168;0;970;0
WireConnection;168;1;831;0
WireConnection;1084;0;1070;0
WireConnection;385;0;1098;0
WireConnection;337;0;385;0
WireConnection;337;3;465;0
WireConnection;422;0;421;0
WireConnection;421;0;378;0
WireConnection;421;1;418;0
WireConnection;345;0;355;0
WireConnection;346;0;345;0
WireConnection;346;1;786;0
WireConnection;307;0;181;0
WireConnection;307;3;178;0
WireConnection;482;0;1109;0
WireConnection;586;0;607;0
WireConnection;586;1;585;0
WireConnection;607;0;606;0
WireConnection;587;0;586;0
WireConnection;568;0;607;0
WireConnection;568;1;596;0
WireConnection;546;0;547;0
WireConnection;546;1;796;0
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
WireConnection;465;2;1105;0
WireConnection;861;0;820;0
WireConnection;863;0;819;0
WireConnection;864;0;858;0
WireConnection;864;3;820;4
WireConnection;865;0;859;0
WireConnection;865;3;819;4
WireConnection;529;0;488;0
WireConnection;388;0;306;0
WireConnection;911;0;816;0
WireConnection;914;0;913;0
WireConnection;915;0;789;0
WireConnection;915;2;916;0
WireConnection;920;0;917;0
WireConnection;917;0;584;0
WireConnection;917;1;594;0
WireConnection;415;0;301;0
WireConnection;924;0;923;0
WireConnection;181;0;1110;0
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
WireConnection;613;0;612;0
WireConnection;321;0;307;0
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
WireConnection;829;0;199;0
WireConnection;859;0;863;0
WireConnection;859;1;860;0
WireConnection;858;0;861;0
WireConnection;790;0;911;0
WireConnection;958;0;973;2
WireConnection;978;0;323;3
WireConnection;978;1;960;0
WireConnection;782;0;808;0
WireConnection;315;0;782;0
WireConnection;823;0;822;0
WireConnection;808;0;784;0
WireConnection;808;2;823;0
WireConnection;987;0;322;0
WireConnection;987;3;978;0
WireConnection;993;0;982;2
WireConnection;991;0;993;0
WireConnection;991;1;993;1
WireConnection;991;2;993;2
WireConnection;97;0;991;0
WireConnection;97;1;993;3
WireConnection;427;0;482;0
WireConnection;427;3;622;0
WireConnection;326;0;427;0
WireConnection;595;0;921;0
WireConnection;566;0;567;0
WireConnection;825;0;517;0
WireConnection;583;0;920;0
WireConnection;312;0;864;0
WireConnection;311;0;865;0
WireConnection;309;0;209;0
WireConnection;1040;0;1038;0
WireConnection;1040;1;1039;0
WireConnection;1054;0;1036;0
WireConnection;994;0;1053;0
WireConnection;994;3;1046;0
WireConnection;995;0;994;0
WireConnection;1053;0;1054;0
WireConnection;1053;1;1054;1
WireConnection;1053;2;1054;2
WireConnection;1041;0;1042;0
WireConnection;1041;1;1040;0
WireConnection;1037;0;1041;0
WireConnection;1037;1;1069;0
WireConnection;1050;0;1069;0
WireConnection;1050;1;1040;0
WireConnection;1051;0;1037;0
WireConnection;1051;1;1050;0
WireConnection;1036;0;1035;0
WireConnection;1036;1;1034;0
WireConnection;1036;2;1051;0
WireConnection;1029;0;1000;0
WireConnection;1029;1;1014;0
WireConnection;1029;2;1045;0
WireConnection;1029;3;1045;1
WireConnection;1031;0;1029;0
WireConnection;1045;0;1028;0
WireConnection;1028;0;1068;0
WireConnection;1028;1;1020;0
WireConnection;1028;2;1019;0
WireConnection;1028;3;1055;0
WireConnection;1015;0;1009;0
WireConnection;1015;1;1067;0
WireConnection;1000;0;1001;0
WireConnection;1000;1;1005;0
WireConnection;1014;0;1015;0
WireConnection;1014;1;1005;0
WireConnection;1005;0;1004;0
WireConnection;1005;1;1006;0
WireConnection;1001;0;1066;0
WireConnection;1009;0;1067;0
WireConnection;972;0;973;66
WireConnection;971;0;972;0
WireConnection;971;1;972;2
WireConnection;971;2;972;1
WireConnection;1003;0;1002;0
WireConnection;1022;0;1021;0
WireConnection;869;0;973;62
WireConnection;969;0;971;0
WireConnection;976;0;973;66
WireConnection;1032;0;1066;0
WireConnection;1032;1;1033;0
WireConnection;1046;0;1054;3
WireConnection;1046;1;1032;0
WireConnection;1046;2;1031;0
WireConnection;323;0;317;0
WireConnection;317;1;329;0
WireConnection;317;0;331;0
WireConnection;317;2;759;0
WireConnection;317;3;996;0
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
WireConnection;351;0;378;0
WireConnection;351;1;350;0
WireConnection;669;0;668;0
WireConnection;358;0;357;0
WireConnection;384;0;351;0
WireConnection;384;1;386;0
WireConnection;384;2;854;0
WireConnection;854;0;387;0
WireConnection;1098;0;384;0
WireConnection;1098;1;1106;0
WireConnection;604;0;601;0
WireConnection;604;1;600;0
WireConnection;604;2;603;0
WireConnection;601;0;484;0
WireConnection;479;0;692;0
WireConnection;689;0;604;0
WireConnection;689;1;617;0
WireConnection;730;0;604;0
WireConnection;730;1;481;0
WireConnection;692;0;689;0
WireConnection;692;1;730;0
WireConnection;471;0;479;0
WireConnection;471;1;472;0
WireConnection;480;0;471;0
WireConnection;480;1;473;0
WireConnection;480;2;485;0
WireConnection;484;0;483;0
WireConnection;1109;0;480;0
WireConnection;1109;1;1108;0
WireConnection;1110;0;241;0
WireConnection;1110;1;1111;0
WireConnection;241;0;180;0
WireConnection;241;1;314;0
WireConnection;241;2;299;0
WireConnection;589;0;271;0
WireConnection;589;1;279;0
WireConnection;589;2;615;0
WireConnection;231;0;589;0
WireConnection;180;0;313;0
WireConnection;180;1;231;0
WireConnection;982;1;987;0
WireConnection;982;2;989;0
WireConnection;982;3;988;0
WireConnection;982;4;990;0
WireConnection;982;5;983;0
WireConnection;982;6;986;0
WireConnection;1102;1;1104;0
WireConnection;1102;2;1081;0
WireConnection;1073;0;1120;0
WireConnection;1100;0;1102;0
WireConnection;1120;0;1072;0
WireConnection;1120;1;1119;0
ASEEND*/
//CHKSM=84B390FB019E55453DD44BDF4AEF9713D1F10737