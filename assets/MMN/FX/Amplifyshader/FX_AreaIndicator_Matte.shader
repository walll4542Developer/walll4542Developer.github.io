// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_AreaIndicator_Matte"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector]_Mode("Mode", Float) = -1
		[Header(Indicator Options)][Space(10)][KeywordEnum(Rectangle,Arc,Circle)] _Type("Type", Float) = 0
		_GradationLength("게이지 차오르는 그라데이션의 길이", Range( 0 , 1)) = 1
		[HideInInspector]_DimmingFactor("_DimmingFactor", Range( 0 , 1)) = 0
		[HideInInspector]_OuterRadius("_OuterRadius", Float) = 1
		[HideInInspector][Toggle]_IsHostile("_IsHostile", Range( 0 , 1)) = 0
		[HideInInspector]_InnerRadius("_InnerRadius", Float) = 0
		[HideInInspector]_Angle("_Angle", Range( 0 , 360)) = 360
		[HideInInspector]_FillRate("_FillRate", Range( 0 , 1)) = 1
		[HideInInspector]_FinalAlphaMatte("_FinalAlphaMatte", Range( 0 , 1)) = 1
		[Header(Animation Options)][Space(10)]_StartAnimSpeed("시작 모션의 속도 값", Range( 0 , 1)) = 0.9
		[HideInInspector][HDR]_ColorMatte("_ColorMatte", Color) = (1,1,1,1)
		[HideInInspector]_Direction("_Direction", Vector) = (1,0,1,0)
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][ToggleUI]_FogReceive("FogReceive", Range( 0 , 1)) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10

	}

	SubShader
	{
		LOD 100



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent+99" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL


		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="Decal" }

			Cull Front
			Blend SrcAlpha OneMinusSrcAlpha
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
			#pragma multi_compile_local _TYPE_RECTANGLE _TYPE_ARC _TYPE_CIRCLE


			CBUFFER_START( UnityPerMaterial )
			float4 _ColorMatte;
			float4 _Direction;
			float _IsHostile;
			float _GradationLength;
			float _DimmingFactor;
			float _StartAnimSpeed;
			float _FillRate;
			float _InnerRadius;
			float _OuterRadius;
			float _Angle;
			float _FinalAlphaMatte;
			float _Mode;
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
				float localApplyFogColor993 = ( 0.0 );
				float3 appendResult861 = (float3(_ColorMatte.rgb));
				float3 MainColor312 = appendResult861;
				float localApplyScreenSpaceDecal36_g16 = ( 0.0 );
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 screenPos36_g16 = ase_screenPosNorm;
				float2 decalUV36_g16 = float2( 0,0 );
				float boundingBox36_g16 = 0.0;
				float4 decalWorldSpace36_g16 = float4( 0,0,0,0 );
				ApplyScreenSpaceDecal( screenPos36_g16 , decalUV36_g16 , boundingBox36_g16 , decalWorldSpace36_g16 );
				float2 UV869 = decalUV36_g16;
				float ObjectPositionY278 = UV869.y;
				float Progress309 = _FillRate;
				float smoothstepResult808 = smoothstep( 0.0 , ( 1.0 - _StartAnimSpeed ) , Progress309);
				float StartAnim315 = saturate( smoothstepResult808 );
				float RactangleWidthAlpha283 = step( abs( ( UV869.x - 0.5 ) ) , StartAnim315 );
				float4 appendResult307 = (float4(MainColor312 , ( saturate( ( saturate( ObjectPositionY278 ) + 1.0 ) ) * RactangleWidthAlpha283 )));
				float4 TypeRectangle321 = appendResult307;
				float2 temp_cast_1 = (0.5).xx;
				float2 CenteredUV15_g17 = ( UV869 - temp_cast_1 );
				float2 break17_g17 = CenteredUV15_g17;
				float2 appendResult23_g17 = (float2(( length( CenteredUV15_g17 ) * 1.0 * 2.0 ) , ( atan2( break17_g17.x , break17_g17.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float2 appendResult444 = (float2(appendResult23_g17.x , 1.0));
				float2 PolarCoord354 = appendResult444;
				float InnerRadius583 = saturate( ( _InnerRadius / _OuterRadius ) );
				float OuterRadius595 = 1.0;
				float4 temp_output_970_66 = decalWorldSpace36_g16;
				float4 WorldSpaceDegree974 = temp_output_970_66;
				float3 appendResult977 = (float3(WorldSpaceDegree974.xyz));
				float3 objToWorld513 = mul( GetObjectToWorldMatrix(), float4( float3(0,0,0), 1 ) ).xyz;
				float3 normalizeResult522 = normalize( ( appendResult977 - objToWorld513 ) );
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
				float FinalAlphaMatte958 = _FinalAlphaMatte;
				float BoundingBox964 = boundingBox36_g16;
				float4 appendResult987 = (float4(appendResult322 , ( break323.w * FinalAlphaMatte958 * BoundingBox964 )));
				float4 finalColor993 = appendResult987;
				float3 positionWS993 = input.positionWS;
				float3 normalWS993 = input.normalWS;
				float mode993 = _Mode;
				float fogReceive993 = _FogReceive;
				float4 texCoord988 = input.fogCoord;
				texCoord988.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord993 = texCoord988;
				ApplyFogColor( finalColor993 , positionWS993 , normalWS993 , mode993 , fogReceive993 , fogCoord993 );
				float4 break994 = finalColor993;
				float3 appendResult995 = (float3(break994.x , break994.y , break994.z));

				float3 color = appendResult995;
				float alpha = break994.w;

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
Node;AmplifyShaderEditor.CommentaryNode;984;3424,1008;Inherit;False;1396;483.0002;Alpha;11;337;422;421;345;346;465;786;418;355;955;325;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;983;3152.985,165.2852;Inherit;False;1667.999;802.9998;Alpha;18;427;606;585;586;607;587;596;547;568;546;567;566;796;795;758;622;957;326;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;982;3323.08,-306.4;Inherit;False;1499.52;440.1226;Alpha;10;291;293;178;284;288;575;945;956;307;321;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;979;6365.93,-976.6282;Inherit;False;877;465.6282;Decal;7;998;997;996;869;964;970;974;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;900;1906.655,-66.65092;Inherit;False;1133;308;Ractangle Width Alpha;8;283;316;874;511;873;163;167;548;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;867;5316.898,-1232;Inherit;False;863.1021;796.6328;Script;17;1000;999;517;594;584;921;488;209;913;583;914;825;595;529;917;920;309;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;866;5516,-1696;Inherit;False;662;342;Color;5;820;861;948;958;312;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;821;6300,-1696;Inherit;False;1264.2;679.7999;Animation;18;415;301;782;822;808;823;784;315;790;816;814;787;817;788;916;789;915;911;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;770;1877.655,1083.349;Inherit;False;1162;409;Circle Progression;9;699;700;702;753;697;701;698;625;637;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;525;1623.33,590.7515;Inherit;False;1421;482;Degree;13;519;489;490;521;516;522;977;975;514;826;518;513;523;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;446;1498.654,299.3489;Inherit;False;1546;264;Polar Coordinate;7;354;444;338;445;334;875;947;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;282;2279.33,-401.2485;Inherit;False;758;310;Object Position Y;6;278;872;506;510;507;870;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;76;7264,384;Inherit;False;189.2998;429.6001;Rendering Options;4;129;79;962;961;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;323;5696,224;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;759;5056,384;Inherit;False;325;TypeCircle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;5056,304;Inherit;False;326;TypeArc;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;329;5056,224;Inherit;False;321;TypeRectangle;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;317;5424,224;Inherit;False;Property;_Type;Type;1;0;Create;False;0;0;0;True;2;Header(Indicator Options);Space(10);False;1;0;0;True;;KeywordEnum;3;Rectangle;Arc;Circle;Create;True;True;All;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;5952,-1184;Inherit;False;Progress;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;911;7200,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;915;6592,-1520;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;920;5744,-864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;917;5600,-864;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;916;6368,-1420;Inherit;False;914;IsHostile;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;788;6576,-1616;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;817;6768,-1472;Inherit;False;3;0;FLOAT;-0.1;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;787;6768,-1568;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;814;6928,-1568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;816;7056,-1568;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;790;7344,-1584;Inherit;False;GaugeAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;861;5776,-1648;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;529;5953,-1024;Inherit;False;Angle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;595;5952,-944;Inherit;False;OuterRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;825;5952,-784;Inherit;False;Direction;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;914;5952,-612.0161;Inherit;False;IsHostile;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;958;5918.415,-1454.861;Inherit;False;FinalAlphaMatte;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;5952,-1648;Inherit;False;MainColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;315;7344,-1312;Inherit;False;StartAnim;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;784;6832,-1328;Inherit;False;309;Progress;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;823;6848,-1248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;808;7008,-1328;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;782;7184,-1328;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;974;6975.93,-750.6282;Inherit;False;WorldSpaceDegree;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;415;6946.931,-1126.792;Inherit;False;GragationLength;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;583;5952,-868.0161;Inherit;False;InnerRadius;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;970;6415.93,-926.6282;Inherit;False;MMN_Decal;-1;;16;e77bca24c8bef3c4f881df7c049f144a;0;0;3;FLOAT2;62;FLOAT;2;FLOAT4;66
Node;AmplifyShaderEditor.RegisterLocalVarNode;964;6976,-832;Inherit;False;BoundingBox;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;869;6976,-912;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;3933.08,-91.2775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;293;4077.08,-91.2775;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;4221.08,-91.2775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;3933.08,20.72252;Inherit;False;283;RactangleWidthAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;288;3373.08,-91.2775;Inherit;False;278;ObjectPositionY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;3677.08,-91.2775;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;945;3741.08,20.72252;Inherit;False;Constant;_One1;One;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;956;4196.6,-256.4;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;307;4436.6,-192.4;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;427;4434.983,263.2852;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;606;3394.985,343.2852;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;585;3522.985,439.2852;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;586;3858.985,343.2852;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;607;3570.985,343.2852;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;587;3986.985,343.2852;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;596;3522.985,519.285;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;547;3538.985,599.285;Inherit;False;519;Degree;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;568;3858.985,503.285;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;546;3858.985,599.285;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;567;3202.985,759.285;Inherit;False;529;Angle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;566;3378.985,759.285;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;796;3554.985,679.285;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;795;3378.985,679.285;Inherit;False;Constant;_Float0;Float 0;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;758;3346.985,855.285;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;4194.983,343.2852;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;957;4178.984,215.2852;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;337;4368,1120;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;422;3936,1184;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;421;3808,1184;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;345;3664,1280;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.StepOpNode;346;3936,1264;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;4128,1184;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;786;3616,1376;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;3552,1184;Inherit;False;637;CircleProgression;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;355;3472,1280;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;955;4096,1056;Inherit;False;312;MainColor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;321;4580.6,-191.4;Inherit;False;TypeRectangle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;326;4578.983,264.3604;Inherit;False;TypeArc;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;4576,1120;Inherit;False;TypeCircle;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;444;2661.654,364.3489;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;334;2037.655,364.3489;Inherit;False;Polar Coordinates;-1;;17;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;1877.655,460.349;Inherit;False;Constant;_16;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;445;2277.654,364.3489;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;947;2490.655,459.349;Inherit;False;Constant;_Float5;Float 5;29;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;625;2650.654,1147.349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;698;2266.654,1147.349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;701;1930.655,1243.349;Inherit;False;583;InnerRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;753;2106.655,1243.349;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;702;1930.655,1371.349;Inherit;False;595;OuterRadius;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;699;2138.654,1147.349;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;697;2442.654,1267.349;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;354;2826.654,363.3489;Inherit;False;PolarCoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;167;2514.655,-2.650905;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;163;2658.654,-2.650905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;548;2370.654,-2.650905;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;511;2162.655,13.3491;Inherit;False;Constant;_14;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;2466.655,108.349;Inherit;False;315;StartAnim;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;874;2210.654,93.34902;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;283;2786.654,-2.650905;Inherit;False;RactangleWidthAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;637;2835.654,1146.349;Inherit;False;CircleProgression;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;873;2018.655,92.34902;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;875;1861.655,364.3489;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;2087.33,718.7516;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;513;1863.33,782.7516;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;518;2071.33,942.7516;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;826;1895.33,942.7516;Inherit;False;825;Direction;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;514;1687.33,782.7516;Inherit;False;Constant;_0;0;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;977;1911.33,670.7515;Inherit;False;FLOAT3;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;522;2231.33,718.7516;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;516;2407.33,846.7516;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;521;2231.33,942.7516;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ACosOpNode;490;2519.33,846.7516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DegreesOpNode;489;2631.33,846.7516;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;519;2775.33,846.7516;Inherit;False;Degree;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;700;1930.655,1149.349;Inherit;False;354;PolarCoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;507;2487.33,-257.2484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;2327.33,-193.2485;Inherit;False;Constant;_13;1/2;16;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;506;2295.33,-337.2485;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;872;2695.33,-337.2485;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;278;2823.33,-337.2485;Inherit;False;ObjectPositionY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;870;2519.33,-337.2485;Inherit;False;869;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;975;1670.33,670.7515;Inherit;False;974;WorldSpaceDegree;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;322;5856,224;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;960;6144,304;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;959;5856,352;Inherit;False;958;FinalAlphaMatte;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;966;5856,432;Inherit;False;964;BoundingBox;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;986;6240,816;Inherit;False;292;259;fogCoord;1;988;Vertex Data;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;988;6288,864;Inherit;False;7;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;989;6352,352;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;990;6352,496;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;991;6384,640;Inherit;False;Property;_Mode;Mode;0;1;[HideInInspector];Create;False;0;0;0;True;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;992;6256,720;Inherit;False;Property;_FogReceive;FogReceive;15;2;[HideInInspector];[ToggleUI];Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;987;6384,224;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;993;6672,224;Inherit;False; ;7;File;6;True;finalColor;FLOAT4;0,0,0,0;InOut;;Half;False;True;positionWS;FLOAT3;0,0,0;In;;Half;False;True;normalWS;FLOAT3;0,0,0;In;;Half;False;True;mode;FLOAT;0;In;;Half;False;True;fogReceive;FLOAT;0;In;;Half;False;True;fogCoord;FLOAT4;0,0,0,0;In;;Float;False;ApplyFogColor;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;7;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT4;2
Node;AmplifyShaderEditor.BreakToComponentsNode;994;6944,224;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;995;7104,224;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;7264,224;Float;False;True;-1;2;;100;14;MMN/FX/Amplify shader/FX_AreaIndicator_Matte;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=99;True;5;False;0;True;True;2;5;False;_BlendSrc;10;False;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;True;True;1;False;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;10;True;_StencilValue;255;False;;255;False;;1;True;_StencilComp;1;False;;1;False;;0;True;_StencilZFail;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;7;False;_ZTest;False;True;1;LightMode=Decal;False;True;3;d3d11;metal;vulkan;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;962;7296,448;Inherit;False;Property;_BlendSrc;Blend Src;17;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;7296,608;Inherit;False;Property;_CullMode;Cull Mode;14;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;961;7296,528;Inherit;False;Property;_BlendDst;Blend Dst;18;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;7296,688;Inherit;False;Property;_ZTest;Z Test;16;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;913;5603.732,-608.1879;Inherit;False;Property;_IsHostile;_IsHostile;5;2;[HideInInspector];[Toggle];Create;False;0;0;0;True;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;789;6320,-1521;Inherit;False;Property;_GaugeAnimDamping;게이지 차오르는 모션의 댐핑 값;11;0;Create;False;0;0;0;False;0;False;10;15;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;822;6576,-1248;Inherit;False;Property;_StartAnimSpeed;시작 모션의 속도 값;10;0;Create;False;0;0;0;False;2;Header(Animation Options);Space(10);False;0.9;15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;301;6594.931,-1126.792;Inherit;False;Property;_GradationLength;게이지 차오르는 그라데이션의 길이;2;0;Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;948;5616,-1456;Inherit;False;Property;_FinalAlphaMatte;_FinalAlphaMatte;9;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;820;5552,-1648;Inherit;False;Property;_ColorMatte;_ColorMatte;12;2;[HideInInspector];[HDR];Create;False;0;0;0;True;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;488;5600,-1024;Inherit;False;Property;_Angle;_Angle;7;1;[HideInInspector];Create;False;0;0;0;True;0;False;360;1;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;921;5744,-944;Inherit;False;Constant;_Float1;Float 1;28;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;584;5344,-896;Inherit;False;Property;_InnerRadius;_InnerRadius;6;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;594;5344,-816;Inherit;False;Property;_OuterRadius;_OuterRadius;4;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;517;5712,-784;Inherit;False;Property;_Direction;_Direction;13;0;Create;False;0;0;0;True;1;HideInInspector;False;1,0,1,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;996;6656,-672;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;997;6816,-672;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;998;6976,-672;Inherit;False;DecalWorldSpace;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;999;5952,-528;Inherit;False;DimmingFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1000;5664,-528;Inherit;False;Property;_DimmingFactor;_DimmingFactor;3;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;5600,-1185;Inherit;False;Property;_FillRate;_FillRate;8;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;0;0;1;0;1;FLOAT;0
WireConnection;323;0;317;0
WireConnection;317;1;329;0
WireConnection;317;0;331;0
WireConnection;317;2;759;0
WireConnection;309;0;209;0
WireConnection;911;0;816;0
WireConnection;915;0;789;0
WireConnection;915;2;916;0
WireConnection;920;0;917;0
WireConnection;917;0;584;0
WireConnection;917;1;594;0
WireConnection;817;2;788;0
WireConnection;787;0;788;0
WireConnection;787;1;915;0
WireConnection;814;0;787;0
WireConnection;814;1;817;0
WireConnection;816;0;814;0
WireConnection;790;0;911;0
WireConnection;861;0;820;0
WireConnection;529;0;488;0
WireConnection;595;0;921;0
WireConnection;825;0;517;0
WireConnection;914;0;913;0
WireConnection;958;0;948;0
WireConnection;312;0;861;0
WireConnection;315;0;782;0
WireConnection;823;0;822;0
WireConnection;808;0;784;0
WireConnection;808;2;823;0
WireConnection;782;0;808;0
WireConnection;974;0;970;66
WireConnection;415;0;301;0
WireConnection;583;0;920;0
WireConnection;964;0;970;2
WireConnection;869;0;970;62
WireConnection;291;0;575;0
WireConnection;291;1;945;0
WireConnection;293;0;291;0
WireConnection;178;0;293;0
WireConnection;178;1;284;0
WireConnection;575;0;288;0
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
WireConnection;622;0;587;0
WireConnection;622;1;568;0
WireConnection;622;2;546;0
WireConnection;337;0;955;0
WireConnection;337;3;465;0
WireConnection;422;0;421;0
WireConnection;421;1;418;0
WireConnection;345;0;355;0
WireConnection;346;0;345;0
WireConnection;346;1;786;0
WireConnection;465;0;422;0
WireConnection;465;1;346;0
WireConnection;321;0;307;0
WireConnection;326;0;427;0
WireConnection;325;0;337;0
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
WireConnection;167;0;548;0
WireConnection;163;0;167;0
WireConnection;163;1;316;0
WireConnection;548;0;874;0
WireConnection;548;1;511;0
WireConnection;874;0;873;0
WireConnection;283;0;163;0
WireConnection;637;0;625;0
WireConnection;523;0;977;0
WireConnection;523;1;513;0
WireConnection;513;0;514;0
WireConnection;518;0;826;0
WireConnection;977;0;975;0
WireConnection;522;0;523;0
WireConnection;516;0;522;0
WireConnection;516;1;521;0
WireConnection;521;0;518;0
WireConnection;490;0;516;0
WireConnection;489;0;490;0
WireConnection;519;0;489;0
WireConnection;507;0;506;2
WireConnection;507;1;510;0
WireConnection;872;0;870;0
WireConnection;278;0;872;1
WireConnection;322;0;323;0
WireConnection;322;1;323;1
WireConnection;322;2;323;2
WireConnection;960;0;323;3
WireConnection;960;1;959;0
WireConnection;960;2;966;0
WireConnection;987;0;322;0
WireConnection;987;3;960;0
WireConnection;993;1;987;0
WireConnection;993;2;989;0
WireConnection;993;3;990;0
WireConnection;993;4;991;0
WireConnection;993;5;992;0
WireConnection;993;6;988;0
WireConnection;994;0;993;2
WireConnection;995;0;994;0
WireConnection;995;1;994;1
WireConnection;995;2;994;2
WireConnection;97;0;995;0
WireConnection;97;1;994;3
WireConnection;996;0;970;66
WireConnection;997;0;996;0
WireConnection;997;1;996;2
WireConnection;997;2;996;1
WireConnection;998;0;997;0
WireConnection;999;0;1000;0
ASEEND*/
//CHKSM=A42E00FDB0E59BFA4DEB56779F12D05AE53982D7