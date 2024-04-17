// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_AlphaTest_01"
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
		[Header(tcd0.z     Dissolve)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[HDR][Header(Facing Alpha)][Space()]_AlphaColor("AlphaColor", Color) = (1,1,1,1)
		[Enum(Default,0,Only Front,1,Only Back,2)]_Face_Alpha("Face_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		_Noise_LocalTiling("Noise_LocalTiling", Vector) = (1,1,0,0)
		[HDR]_LineColor("Line Color", Color) = (1,1,1,0)
		_LineThickness("Line Thickness", Range( 0 , 1)) = 0.005
		_CutOff("CutOff", Range( -1 , 2)) = 0
		[HDR][Header(Rim Light)][Space()]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower("Rim Power", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 100



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="AlphaTest" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		UsePass "MMN/FX/AddPass/ShadowCaster"

		Pass
		{
			Name "Unlit"


			Cull [_CullMode]
			Blend Off
			ZTest [_ZTest]
			ZWrite On
			ColorMask RGBA


			HLSLPROGRAM
			#define ASE_SRP_VERSION 120110

			#pragma exclude_renderers glcore gles gles3

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
			#define ASE_NEEDS_FRAG_COLOR
			#define ASE_NEEDS_FRAG_NORMAL
			#define ASE_NEEDS_FRAG_POSITION
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaColor;
			float4 _LineColor;
			float4 _RimColor;
			float4 _MainTex_ST;
			float2 _Noise_LocalTiling;
			float _CutOff;
			float _LineThickness;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _RimPower;
			float _Intensity_Color;
			float _SpawnTransition;
			float _TransitionValue;
			float _FogReceive;
			float _Mode;
			float _SoftParticle;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _LightReceive;
			float _LightRatio;
			float _RaycastMinimumAlpha;
			float _RaycastHarftoneClip;
			float _NearPlaneInvertDistance;
			float _Face_Alpha;
			float _NearPlaneAlpha;
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
				float4 ase_color : COLOR;
				float3 ase_normal : NORMAL;
			};

			float3 ASESafeNormalize(float3 inVec)
			{
				float dp3 = max(1.175494351e-38, dot(inVec, inVec));
				return inVec* rsqrt(dp3);
			}


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				output.ase_color = input.color;
				output.ase_normal = input.normalOS;
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

			float4 frag(Varyings input, bool ase_vface : SV_IsFrontFace) : SV_Target
			{
				float localFXFinalColorOutputs125_g9 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float3 appendResult111 = (float3(input.ase_normal.xy , input.ase_normal.z));
				float3 objToWorldDir135 = ASESafeNormalize( mul( GetObjectToWorldMatrix(), float4( appendResult111, 0 ) ).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult77 = dot( objToWorldDir135 , ase_worldViewDir );
				float temp_output_126_0 = ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 );
				float2 appendResult125 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 appendResult168 = (float2(input.positionOS.xyz.z , input.positionOS.xyz.y));
				float2 panner127 = ( temp_output_126_0 * appendResult125 + ( _Noise_LocalTiling * appendResult168 ));
				float3 break205 = abs( input.ase_normal );
				float2 appendResult195 = (float2(input.positionOS.xyz.z , input.positionOS.xyz.x));
				float2 panner169 = ( temp_output_126_0 * appendResult125 + ( _Noise_LocalTiling * appendResult195 ));
				float2 appendResult202 = (float2(input.positionOS.xyz.x , input.positionOS.xyz.y));
				float2 panner200 = ( temp_output_126_0 * appendResult125 + ( _Noise_LocalTiling * appendResult202 ));
				float temp_output_279_0 = ( input.ase_color.a * ( ( tex2D( _NoiseTex, panner127 ).g * break205.x ) + ( tex2D( _NoiseTex, panner169 ).g * break205.y ) + ( tex2D( _NoiseTex, panner200 ).g * break205.z ) ) );
				float temp_output_265_0 = ( _CutOff + input.uv0.z );
				float lerpResult272 = lerp( 1.0 , saturate( ase_vface ) , saturate( _Face_Alpha ));
				float lerpResult276 = lerp( lerpResult272 , ( 1.0 - lerpResult272 ) , saturate( ( _Face_Alpha - 1.0 ) ));
				clip( temp_output_279_0 - temp_output_265_0);
				float4 appendResult32_g9 = (float4(( ( input.ase_color * tex2DNode5 * _Intensity_Color ) + ( input.ase_color.a * saturate( pow( ( 1.0 - saturate( abs( dotResult77 ) ) ) , _RimPower ) ) * _RimColor ) + ( _LineColor * step( ( temp_output_279_0 - _LineThickness ) , temp_output_265_0 ) ) + ( tex2DNode5.a * lerpResult276 * _AlphaColor * _AlphaColor.a ) ).rgb , 1.0));
				float4 finalColor125_g9 = appendResult32_g9;
				float4 texCoord147_g9 = input.screenPos;
				texCoord147_g9.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g9 = texCoord147_g9;
				float4 positionNDC125_g9 = ScreenPos146_g9;
				float4 texCoord140_g9 = input.fogCoord;
				texCoord140_g9.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g9 = texCoord140_g9;
				float4 fogCoord125_g9 = fogCoord139_g9;
				float3 positionWS125_g9 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g9 = normalizedWorldNormal;
				float nearPlaneAlpha125_g9 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g9 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g9 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g9 = _RaycastMinimumAlpha;
				float lightRatio125_g9 = _LightRatio;
				float lightReceive125_g9 = _LightReceive;
				float near125_g9 = _SoftParticleNearFadeDistance;
				float far125_g9 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g9 = _SoftParticleFadeOutRange;
				float softParticle125_g9 = _SoftParticle;
				float mode125_g9 = _Mode;
				float fogReceive125_g9 = _FogReceive;
				float transitionValue125_g9 = _TransitionValue;
				float spawnTransition125_g9 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g9 , positionNDC125_g9 , fogCoord125_g9 , positionWS125_g9 , normalWS125_g9 , nearPlaneAlpha125_g9 , nearPlaneInvertDistance125_g9 , raycastHarftoneClip125_g9 , raycastMinimumAlpha125_g9 , lightRatio125_g9 , lightReceive125_g9 , near125_g9 , far125_g9 , fadeOutRange125_g9 , softParticle125_g9 , mode125_g9 , fogReceive125_g9 , transitionValue125_g9 , spawnTransition125_g9 );
				float4 break64_g9 = finalColor125_g9;
				float3 appendResult76_g9 = (float3(break64_g9.x , break64_g9.y , break64_g9.z));

				float3 color = appendResult76_g9;
				float alpha = break64_g9.w;

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

	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"

	Fallback Off
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.PosVertexDataNode;163;-1552,960;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;103;-1696,32;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-1312,1408;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-1312,1488;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;253;-1317,821;Inherit;False;Property;_Noise_LocalTiling;Noise_LocalTiling;22;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;202;-1312,1184;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;168;-1312,960;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;195;-1312,1072;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;126;-1152,1600;Inherit;False;MMN_Time;-1;;6;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-1120,960;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-1120,1184;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;-1120,1072;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;209;-848,1680;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;111;-1504,32;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;125;-1120,1408;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;76;-1296,208;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;135;-1344,32;Inherit;False;Object;World;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;200;-928,1376;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;169;-928,1168;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;203;-672,1680;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;127;-928,960;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;166;-720,1168;Inherit;True;Property;_TextureSample0;Texture Sample 0;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;128;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;77;-1088,160;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;128;-720,960;Inherit;True;Property;_NoiseTex;NoiseTex;19;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;205;-544,1680;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;201;-720,1376;Inherit;True;Property;_TextureSample1;Texture Sample 1;19;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;128;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-352,1376;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-352,960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-352,1168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FaceVariableNode;246;-940.5446,-307.1276;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;-988.5446,-163.1275;Inherit;False;Property;_Face_Alpha;Face_Alpha;18;1;[Enum];Create;True;0;3;Default;0;Only Front;1;Only Back;2;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;234;-960,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;269;-813.7964,-311.0046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-813.7964,-71.00454;Inherit;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;79;-848,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;268;-813.7964,-232.0044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;271;-813.7964,-407.0046;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;208;-176,960;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;278;-226.7441,768;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;81;-704,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-160,1168;Inherit;False;Property;_CutOff;CutOff;25;0;Create;True;0;0;0;False;0;False;0;0;-1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;237;-208,528;Inherit;False;Property;_LineThickness;Line Thickness;24;0;Create;True;0;0;0;False;0;False;0.005;0.006;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-848,304;Inherit;False;Property;_RimPower;Rim Power;27;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;279;-32,864;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;272;-669.7963,-343.0045;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;273;-669.7963,-151.0045;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;259;-112,1280;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;245;96,528;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-820.3663,-706.3204;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;82;-544,160;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;274;-509.7961,-151.0045;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;265;128,1168;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;275;-509.7961,-279.0044;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;85;-512,304;Inherit;False;Property;_RimColor;Rim Color;26;1;[HDR];Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1,1,1,0;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;83;-400,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;276;-317.7961,-343.0045;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;238;176,336;Inherit;False;Property;_LineColor;Line Color;23;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.273585,0.6305643,2,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;251;123,-80;Inherit;False;Property;_AlphaColor;AlphaColor;17;1;[HDR];Create;True;0;0;0;False;2;Header(Facing Alpha);Space();False;1,1,1,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;241;256,528;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-260.3664,-626.3205;Inherit;False;Property;_Intensity_Color;Intensity_Color;28;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-468.3664,-898.3204;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-596.3663,-706.3204;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;c5fab1eb02e03e24491e663d25569187;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-52.36653,-706.3204;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;400,336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-256,160;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;363,-160;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;100;368,960;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;89;992,288;Inherit;False;195;261;Rendering Options;2;91;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;560,144;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;99;1008,448;Inherit;False;Property;_ZTest;Z Test;30;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;88;720,144;Inherit;False;MMN_CommonOutputs;0;;9;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;91;1008,352;Inherit;False;Property;_CullMode;Cull Mode;29;1;[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;992,144;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;100;14;MMN/FX/Amplify shader/FX_AlphaTest_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=AlphaTest=Queue=0;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;202;0;163;1
WireConnection;202;1;163;2
WireConnection;168;0;163;3
WireConnection;168;1;163;2
WireConnection;195;0;163;3
WireConnection;195;1;163;1
WireConnection;254;0;253;0
WireConnection;254;1;168;0
WireConnection;256;0;253;0
WireConnection;256;1;202;0
WireConnection;255;0;253;0
WireConnection;255;1;195;0
WireConnection;111;0;103;0
WireConnection;111;2;103;3
WireConnection;125;0;121;0
WireConnection;125;1;122;0
WireConnection;135;0;111;0
WireConnection;200;0;256;0
WireConnection;200;2;125;0
WireConnection;200;1;126;0
WireConnection;169;0;255;0
WireConnection;169;2;125;0
WireConnection;169;1;126;0
WireConnection;203;0;209;0
WireConnection;127;0;254;0
WireConnection;127;2;125;0
WireConnection;127;1;126;0
WireConnection;166;1;169;0
WireConnection;77;0;135;0
WireConnection;77;1;76;0
WireConnection;128;1;127;0
WireConnection;205;0;203;0
WireConnection;201;1;200;0
WireConnection;207;0;201;2
WireConnection;207;1;205;2
WireConnection;204;0;128;2
WireConnection;204;1;205;0
WireConnection;206;0;166;2
WireConnection;206;1;205;1
WireConnection;234;0;77;0
WireConnection;269;0;246;0
WireConnection;79;0;234;0
WireConnection;268;0;267;0
WireConnection;208;0;204;0
WireConnection;208;1;206;0
WireConnection;208;2;207;0
WireConnection;81;0;79;0
WireConnection;279;0;278;4
WireConnection;279;1;208;0
WireConnection;272;0;271;0
WireConnection;272;1;269;0
WireConnection;272;2;268;0
WireConnection;273;0;267;0
WireConnection;273;1;270;0
WireConnection;245;0;279;0
WireConnection;245;1;237;0
WireConnection;82;0;81;0
WireConnection;82;1;80;0
WireConnection;274;0;273;0
WireConnection;265;0;102;0
WireConnection;265;1;259;3
WireConnection;275;0;272;0
WireConnection;83;0;82;0
WireConnection;276;0;272;0
WireConnection;276;1;275;0
WireConnection;276;2;274;0
WireConnection;241;0;245;0
WireConnection;241;1;265;0
WireConnection;5;1;6;0
WireConnection;65;0;66;0
WireConnection;65;1;5;0
WireConnection;65;2;60;0
WireConnection;239;0;238;0
WireConnection;239;1;241;0
WireConnection;87;0;66;4
WireConnection;87;1;83;0
WireConnection;87;2;85;0
WireConnection;247;0;5;4
WireConnection;247;1;276;0
WireConnection;247;2;251;0
WireConnection;247;3;251;4
WireConnection;100;1;279;0
WireConnection;100;2;265;0
WireConnection;84;0;65;0
WireConnection;84;1;87;0
WireConnection;84;2;239;0
WireConnection;84;3;247;0
WireConnection;88;9;84;0
WireConnection;88;28;100;0
WireConnection;98;0;88;2
WireConnection;98;1;88;26
ASEEND*/
//CHKSM=86D4BBCB14C740B3308F20695DFB84D070132770