// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_ScreenTransition"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector]_Mode("Mode", Float) = -1
		[HideInInspector]_TransitionValue("TransitionValue", Range( 0 , 1)) = 1
		[HideInInspector]_SpawnTransition("SpawnTransition", Range( 0 , 1)) = 0
		[HideInInspector][PerRendererData]_RaycastHarftoneClip("raycastHarftoneClip", Range( 0 , 1)) = 0
		[HideInInspector]_RaycastMinimumAlpha("raycastMinimumAlpha", Range( 0 , 1)) = 0
		[HideInInspector]_NearPlaneAlpha("nearPlaneAlpha", Range( 0 , 1)) = 0
		[HideInInspector][ToggleUI]_NearPlaneInvertDistance("nearPlaneInvertDistance", Range( 0 , 1)) = 0
		[HideInInspector][ToggleUI][Space(10)]_LightReceive("LightReceive", Range( 0 , 1)) = 0
		[HideInInspector]_LightRatio("lightRatio", Range( 0 , 1)) = 1
		[HideInInspector][ToggleUI]_SoftParticle("SoftParticle", Range( 0 , 1)) = 0
		[HideInInspector]_SoftParticleNearFadeDistance("Soft Particle Near Fade", Float) = 0
		[HideInInspector]_SoftParticleFarFadeDistance("Soft Particle Far Fade", Float) = 1
		[HideInInspector][ToggleUI]_FogReceive("FogReceive", Range( 0 , 1)) = 0
		[HideInInspector]_SoftParticleFadeOutRange("SoftParticleFadeOutRange", Range( 0 , 10)) = 1
		[HideInInspector][Toggle(_RAYCAST_ON)] _Raycast("_Raycast", Float) = 1
		[NoScaleOffset][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_MainTex_ScaleOffset("MainTex_ScaleOffset", Vector) = (1,1,0,0)
		_NoiseSpeed("NoiseSpeed", Float) = 1
		[Header(Main Noise)]_Main_NoisePower("Main_NoisePower", Float) = 1
		[Header(Sub Noise)]_Sub_NoisePower("Sub_NoisePower", Float) = 1
		_Sub_Alpha("Sub_Alpha", Float) = 1
		_Sub_Thickness("Sub_Thickness", Range( -0.25 , 0.25)) = 0
		[Space()]_Step("Step", Range( 0 , 1)) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

	}

	SubShader
	{
		LOD 100



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
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ScaleOffset;
			float _NearPlaneAlpha;
			float _Sub_Alpha;
			float _Main_NoisePower;
			float _NoiseSpeed;
			float _Step;
			float _SpawnTransition;
			float _TransitionValue;
			float _FogReceive;
			float _Sub_Thickness;
			float _Mode;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _LightReceive;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _SoftParticle;
			float _Sub_NoisePower;
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
				float localFXFinalColorOutputs125_g20 = ( 0.0 );
				float3 temp_cast_0 = (0.0).xxx;
				float2 appendResult408 = (float2(_MainTex_ScaleOffset.x , _MainTex_ScaleOffset.y));
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult117 = (float2(ase_screenPosNorm.x , ase_screenPosNorm.y));
				float2 appendResult334 = (float2(( _ScreenParams.x / _ScreenParams.y ) , 1.0));
				float2 appendResult128 = (float2(1.0 , ( _ScreenParams.y / _ScreenParams.x )));
				float temp_output_339_0 = saturate( ceil( ( _ScreenParams.x - _ScreenParams.y ) ) );
				float2 lerpResult336 = lerp( appendResult334 , appendResult128 , temp_output_339_0);
				float2 temp_output_405_0 = ( ( appendResult117 * lerpResult336 ) - ( float2( 0.5,0.5 ) * lerpResult336 ) );
				float2 temp_output_548_0 = ( appendResult408 * temp_output_405_0 );
				float2 gridID517 = floor( temp_output_548_0 );
				float2 temp_output_2_0_g21 = ( gridID517 + float2( 0,0 ) );
				float dotResult4_g21 = dot( temp_output_2_0_g21 , float2( 123.4,234.5 ) );
				float dotResult5_g21 = dot( temp_output_2_0_g21 , float2( 234.5,345.6 ) );
				float2 appendResult8_g21 = (float2(dotResult4_g21 , dotResult5_g21));
				float temp_output_254_0 = ( ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) + 0.001 ) * _NoiseSpeed );
				float2 gridUV546 = frac( temp_output_548_0 );
				float dotResult582 = dot( sin( ( ( sin( appendResult8_g21 ) * 43758.55 ) + temp_output_254_0 ) ) , ( gridUV546 - float2( 0,0 ) ) );
				float2 temp_output_2_0_g11 = ( gridID517 + float2( 1,0 ) );
				float dotResult4_g11 = dot( temp_output_2_0_g11 , float2( 123.4,234.5 ) );
				float dotResult5_g11 = dot( temp_output_2_0_g11 , float2( 234.5,345.6 ) );
				float2 appendResult8_g11 = (float2(dotResult4_g11 , dotResult5_g11));
				float dotResult583 = dot( sin( ( ( sin( appendResult8_g11 ) * 43758.55 ) + temp_output_254_0 ) ) , ( gridUV546 - float2( 1,0 ) ) );
				float2 break589 = gridUV546;
				float lerpResult586 = lerp( dotResult582 , dotResult583 , break589.x);
				float2 temp_output_2_0_g15 = ( gridID517 + float2( 0,1 ) );
				float dotResult4_g15 = dot( temp_output_2_0_g15 , float2( 123.4,234.5 ) );
				float dotResult5_g15 = dot( temp_output_2_0_g15 , float2( 234.5,345.6 ) );
				float2 appendResult8_g15 = (float2(dotResult4_g15 , dotResult5_g15));
				float dotResult584 = dot( sin( ( ( sin( appendResult8_g15 ) * 43758.55 ) + temp_output_254_0 ) ) , ( gridUV546 - float2( 0,1 ) ) );
				float2 temp_output_2_0_g18 = ( gridID517 + float2( 1,1 ) );
				float dotResult4_g18 = dot( temp_output_2_0_g18 , float2( 123.4,234.5 ) );
				float dotResult5_g18 = dot( temp_output_2_0_g18 , float2( 234.5,345.6 ) );
				float2 appendResult8_g18 = (float2(dotResult4_g18 , dotResult5_g18));
				float dotResult585 = dot( sin( ( ( sin( appendResult8_g18 ) * 43758.55 ) + temp_output_254_0 ) ) , ( gridUV546 - float2( 1,1 ) ) );
				float lerpResult587 = lerp( dotResult584 , dotResult585 , break589.x);
				float lerpResult590 = lerp( lerpResult586 , lerpResult587 , break589.y);
				float Noise674 = abs( lerpResult590 );
				float2 appendResult681 = (float2(0.0 , Noise674));
				float2 appendResult410 = (float2(_MainTex_ScaleOffset.z , _MainTex_ScaleOffset.w));
				float temp_output_657_0 = length( temp_output_405_0 );
				float2 appendResult682 = (float2(0.0 , Noise674));
				float4 appendResult32_g20 = (float4(temp_cast_0 , saturate( ( step( _Step , ( tex2D( _MainTex, ( ( appendResult681 * _Main_NoisePower ) + appendResult410 ) ).g * temp_output_657_0 ) ) + ( _Sub_Alpha * saturate( ( -_Step + temp_output_657_0 ) ) * step( ( _Step + _Sub_Thickness ) , ( temp_output_657_0 * tex2D( _MainTex, ( appendResult410 + ( appendResult682 * _Sub_NoisePower ) ) ).g ) ) ) ) )));
				float4 finalColor125_g20 = appendResult32_g20;
				float4 texCoord147_g20 = input.screenPos;
				texCoord147_g20.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g20 = texCoord147_g20;
				float4 positionNDC125_g20 = ScreenPos146_g20;
				float4 texCoord140_g20 = input.fogCoord;
				texCoord140_g20.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g20 = texCoord140_g20;
				float4 fogCoord125_g20 = fogCoord139_g20;
				float3 positionWS125_g20 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g20 = normalizedWorldNormal;
				float nearPlaneAlpha125_g20 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g20 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g20 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g20 = _RaycastMinimumAlpha;
				float lightRatio125_g20 = _LightRatio;
				float lightReceive125_g20 = _LightReceive;
				float near125_g20 = _SoftParticleNearFadeDistance;
				float far125_g20 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g20 = _SoftParticleFadeOutRange;
				float softParticle125_g20 = _SoftParticle;
				float mode125_g20 = _Mode;
				float fogReceive125_g20 = _FogReceive;
				float transitionValue125_g20 = _TransitionValue;
				float spawnTransition125_g20 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g20 , positionNDC125_g20 , fogCoord125_g20 , positionWS125_g20 , normalWS125_g20 , nearPlaneAlpha125_g20 , nearPlaneInvertDistance125_g20 , raycastHarftoneClip125_g20 , raycastMinimumAlpha125_g20 , lightRatio125_g20 , lightReceive125_g20 , near125_g20 , far125_g20 , fadeOutRange125_g20 , softParticle125_g20 , mode125_g20 , fogReceive125_g20 , transitionValue125_g20 , spawnTransition125_g20 );
				float4 break64_g20 = finalColor125_g20;
				float3 appendResult76_g20 = (float3(break64_g20.x , break64_g20.y , break64_g20.z));

				float3 color = appendResult76_g20;
				float alpha = break64_g20.w;

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

	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"

	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;689;-1792,-1280;Inherit;False;1510.91;359.7634;Main Noise;8;681;675;639;136;640;652;388;661;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;688;-1792,-640;Inherit;False;2028.974;575.3922;Sub Noise;15;682;660;676;658;635;670;687;633;666;648;632;324;638;662;659;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;653;-3751.207,-2642.688;Inherit;False;1940.009;1123.571;Noise;29;674;610;577;560;594;589;588;590;587;586;585;584;583;582;580;579;578;581;564;563;562;561;629;253;326;254;593;592;591;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;134;-3728,-896;Inherit;False;1332.466;1109.936;화면비, 화면 중앙;16;115;123;361;332;358;336;126;333;128;334;132;117;133;130;360;405;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;360;-3568,-128;Inherit;False;516;187;화면비 큰 방향  0 가로 1 세로;3;339;338;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;880,-992;Inherit;False;204;375;Rendering Options;4;82;81;79;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;81;912,-784;Inherit;False;Property;_CullMode;Cull Mode;27;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;912,-864;Inherit;False;Property;_BlendDst;Blend Dst;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;912,-704;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-2768,-832;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-2768,-720;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;117;-2992,-832;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;132;-3024,-704;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;334;-3232,-416;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;-3232,-544;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;333;-3408,-416;Inherit;False;Constant;_Float5;Float 4;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-3408,-544;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;336;-2992,-544;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;337;-3520,-80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;338;-3360,-80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;339;-3232,-80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;358;-2992,80;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;332;-3408,-336;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;361;-3248,80;Inherit;False;Constant;_ScreenScaleFactor;ScreenScaleFactor;12;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScreenParams;123;-3696,-544;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;115;-3232,-832;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;591;-3157.207,-2256.688;Inherit;False;MMN_RandomGradient;-1;;11;18c00dca34c155048bdec0b3d57fd44a;0;2;2;FLOAT2;0,0;False;14;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;593;-3157.207,-2160.688;Inherit;False;MMN_RandomGradient;-1;;15;18c00dca34c155048bdec0b3d57fd44a;0;2;2;FLOAT2;0,0;False;14;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-3397.207,-2592.688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;253;-3701.207,-2592.688;Inherit;False;MMN_Time;-1;;17;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;629;-3509.207,-2592.688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;581;-3061.207,-1632.689;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;578;-3061.207,-1920.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;579;-3061.207,-1824.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;580;-3061.207,-1728.689;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;582;-2757.206,-2224.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;583;-2757.206,-2096.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;584;-2757.206,-1968.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;585;-2757.206,-1840.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;586;-2501.207,-2224.688;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;587;-2501.207,-2096.688;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;588;-2949.207,-2480.688;Inherit;False;546;gridUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;589;-2757.206,-2480.688;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;594;-3157.207,-2064.688;Inherit;False;MMN_RandomGradient;-1;;18;18c00dca34c155048bdec0b3d57fd44a;0;2;2;FLOAT2;0,0;False;14;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;560;-3605.207,-2352.688;Inherit;False;517;gridID;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;577;-3349.207,-1920.688;Inherit;False;546;gridUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;674;-2032,-2224;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;912,-944;Inherit;False;Property;_BlendSrc;Blend Src;24;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;662;-1440,-432;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;661;-720,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;388;-512,-1152;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;326;-3557.207,-2464.688;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;18;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;638;-816,-432;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;640;-1632,-1120;Inherit;False;Property;_Main_NoisePower;Main_NoisePower;19;0;Create;True;0;0;0;False;1;Header(Main Noise);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;657;-1152,-832;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;324;-848,-160;Inherit;False;Property;_Sub_Thickness;Sub_Thickness;22;0;Create;True;0;0;0;False;0;False;0;0;-0.25;0.25;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;632;-512,-176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;648;-240,-480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;666;-112,-480;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;633;-160,-352;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;670;-112,-576;Inherit;False;Property;_Sub_Alpha;Sub_Alpha;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;80,-480;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;408;-2544,-1200;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;410;-2544,-1088;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;407;-2800,-1200;Inherit;False;Property;_MainTex_ScaleOffset;MainTex_ScaleOffset;17;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;-2304,-1472;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FloorOpNode;552;-2144,-1472;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;546;-2016,-1392;Inherit;False;gridUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;517;-2016,-1472;Inherit;False;gridID;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;636;304,-1152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;671;432,-1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;77;608,-1152;Inherit;False;MMN_CommonOutputs;0;;20;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT;0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;691;432,-1232;Inherit;False;Constant;_Float2;Float 2;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;880,-1152;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_ScreenTransition;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SamplerNode;136;-1104,-1152;Inherit;True;Property;_MainTex;MainTex;16;1;[NoScaleOffset];Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;658;-1152,-432;Inherit;True;Property;_MainTex1;MainTex;16;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;136;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;676;-1776,-432;Inherit;False;674;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;660;-1664,-320;Inherit;False;Property;_Sub_NoisePower;Sub_NoisePower;20;0;Create;True;0;0;0;False;1;Header(Sub Noise);False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;639;-1408,-1232;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;675;-1760,-1232;Inherit;False;674;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;681;-1568,-1232;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;682;-1600,-432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;659;-1280,-512;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;652;-1248,-1104;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;561;-3349.207,-2352.688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;562;-3349.207,-2256.688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;563;-3349.207,-2160.688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;564;-3349.207,-2064.688;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;547;-2144,-1392;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;592;-3157.207,-2352.688;Inherit;False;MMN_RandomGradient;-1;;21;18c00dca34c155048bdec0b3d57fd44a;0;2;2;FLOAT2;0,0;False;14;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;610;-2160,-2224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;590;-2309.206,-2224.688;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;405;-2608,-832;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;687;-416,-592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-928,-832;Inherit;False;Property;_Step;Step;23;0;Create;True;0;0;0;False;1;Space();False;0;0;0;1;0;1;FLOAT;0
WireConnection;130;0;117;0
WireConnection;130;1;336;0
WireConnection;133;0;132;0
WireConnection;133;1;336;0
WireConnection;117;0;115;1
WireConnection;117;1;115;2
WireConnection;334;0;332;0
WireConnection;334;1;333;0
WireConnection;128;0;333;0
WireConnection;128;1;126;0
WireConnection;126;0;123;2
WireConnection;126;1;123;1
WireConnection;336;0;334;0
WireConnection;336;1;128;0
WireConnection;336;2;339;0
WireConnection;337;0;123;1
WireConnection;337;1;123;2
WireConnection;338;0;337;0
WireConnection;339;0;338;0
WireConnection;358;0;361;1
WireConnection;358;1;361;2
WireConnection;358;2;339;0
WireConnection;332;0;123;1
WireConnection;332;1;123;2
WireConnection;591;2;562;0
WireConnection;591;14;254;0
WireConnection;593;2;563;0
WireConnection;593;14;254;0
WireConnection;254;0;629;0
WireConnection;254;1;326;0
WireConnection;629;0;253;0
WireConnection;581;0;577;0
WireConnection;578;0;577;0
WireConnection;579;0;577;0
WireConnection;580;0;577;0
WireConnection;582;0;592;0
WireConnection;582;1;578;0
WireConnection;583;0;591;0
WireConnection;583;1;579;0
WireConnection;584;0;593;0
WireConnection;584;1;580;0
WireConnection;585;0;594;0
WireConnection;585;1;581;0
WireConnection;586;0;582;0
WireConnection;586;1;583;0
WireConnection;586;2;589;0
WireConnection;587;0;584;0
WireConnection;587;1;585;0
WireConnection;587;2;589;0
WireConnection;589;0;588;0
WireConnection;594;2;564;0
WireConnection;594;14;254;0
WireConnection;674;0;610;0
WireConnection;662;0;682;0
WireConnection;662;1;660;0
WireConnection;661;0;136;2
WireConnection;661;1;657;0
WireConnection;388;0;121;0
WireConnection;388;1;661;0
WireConnection;638;0;657;0
WireConnection;638;1;658;2
WireConnection;657;0;405;0
WireConnection;632;0;121;0
WireConnection;632;1;324;0
WireConnection;648;0;687;0
WireConnection;648;1;657;0
WireConnection;666;0;648;0
WireConnection;633;0;632;0
WireConnection;633;1;638;0
WireConnection;635;0;670;0
WireConnection;635;1;666;0
WireConnection;635;2;633;0
WireConnection;408;0;407;1
WireConnection;408;1;407;2
WireConnection;410;0;407;3
WireConnection;410;1;407;4
WireConnection;548;0;408;0
WireConnection;548;1;405;0
WireConnection;552;0;548;0
WireConnection;546;0;547;0
WireConnection;517;0;552;0
WireConnection;636;0;388;0
WireConnection;636;1;635;0
WireConnection;671;0;636;0
WireConnection;77;9;691;0
WireConnection;77;28;671;0
WireConnection;84;0;77;2
WireConnection;84;1;77;26
WireConnection;136;1;652;0
WireConnection;658;1;659;0
WireConnection;639;0;681;0
WireConnection;639;1;640;0
WireConnection;681;1;675;0
WireConnection;682;1;676;0
WireConnection;659;0;410;0
WireConnection;659;1;662;0
WireConnection;652;0;639;0
WireConnection;652;1;410;0
WireConnection;561;0;560;0
WireConnection;562;0;560;0
WireConnection;563;0;560;0
WireConnection;564;0;560;0
WireConnection;547;0;548;0
WireConnection;592;2;561;0
WireConnection;592;14;254;0
WireConnection;610;0;590;0
WireConnection;590;0;586;0
WireConnection;590;1;587;0
WireConnection;590;2;589;1
WireConnection;405;0;130;0
WireConnection;405;1;133;0
WireConnection;687;0;121;0
ASEEND*/
//CHKSM=5B153C6FE708D207A06A1E124775D6707CBB78BD