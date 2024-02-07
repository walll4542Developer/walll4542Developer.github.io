// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Ice_01"
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
		[HDR]_MainColor("Main Color", Color) = (1,1,1,0)
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Base_Color("Base_Color", Color) = (1,1,1,0)
		[HDR]_Sub_Color("Sub_Color", Color) = (1,1,1,0)
		_Color_Range("Color_Range", Float) = 1
		_Color_Offset("Color_Offset", Float) = 0
		[HDR][Header(Rim Light)][Space()]_RimColor("Rim Color", Color) = (1,1,1,0)
		[ASEEnd]_RimPower("Rim Power", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }

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
			#define ASE_SRP_VERSION 999999

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


			sampler2D _NoiseTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Base_Color;
			float4 _RimColor;
			float4 _NoiseTex_ST;
			float4 _Sub_Color;
			float4 _MainColor;
			float4 _MainTex_ST;
			float _RaycastMinimumAlpha;
			float _NearPlaneAlpha;
			float _NearPlaneInvertDistance;
			float _SoftParticleFadeOutRange;
			float _Color_Offset;
			float _Color_Range;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleNearFadeDistance;
			float _RimPower;
			float _RaycastHarftoneClip;
			float _LightRatio;
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
				float localApplySoftParticle80_g3 = ( 0.0 );
				float localApplyLightColor6_g3 = ( 0.0 );
				float localApplyShadowAtten104_g3 = ( 0.0 );
				half localApplyRaycastingAlpha92_g3 = ( 0.0 );
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float4 lerpResult164 = lerp( _Base_Color , _Sub_Color , ( _Sub_Color.a * saturate( ( _Color_Offset + ( _Color_Range * tex2D( _NoiseTex, ( float3( uv_NoiseTex ,  0.0 ) + ( float3( 0,0,0 ).x * float3( 0,0,0 ).x ) ).xy ).g ) ) ) ));
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult159 = dot( normalizedWorldNormal , ase_worldViewDir );
				float4 lerpResult94 = lerp( lerpResult164 , _RimColor , ( _RimColor.a * saturate( pow( ( 1.0 - dotResult159 ) , _RimPower ) ) * input.ase_color.a ));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 lerpResult109 = lerp( lerpResult94 , _MainColor , ( _MainColor.a * tex2D( _MainTex, uv_MainTex ).g ));
				float4 lerpResult301 = lerp( input.ase_color , lerpResult109 , input.ase_color.a);
				float4 appendResult32_g3 = (float4(lerpResult301.rgb , 1.0));
				half4 finalColor92_g3 = appendResult32_g3;
				half3 positionWS92_g3 = input.positionWS;
				float4 screenPos = input.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half4 screenUV92_g3 = ase_screenPosNorm;
				half4 screenPos92_g3 = ase_screenPosNorm;
				half nearPlane92_g3 = _NearPlaneAlpha;
				half nearPlaneInvertDistance92_g3 = _NearPlaneInvertDistance;
				half raycastHarftoneClip92_g3 = _RaycastHarftoneClip;
				half raycastMinimumAlpha92_g3 = _RaycastMinimumAlpha;
				ApplyRaycastingAlpha( finalColor92_g3 , positionWS92_g3 , screenUV92_g3 , screenPos92_g3 , nearPlane92_g3 , nearPlaneInvertDistance92_g3 , raycastHarftoneClip92_g3 , raycastMinimumAlpha92_g3 );
				float4 finalColor104_g3 = finalColor92_g3;
				float4 shadowCoord104_g3 = input.uv0;
				float3 positionWS104_g3 = input.positionWS;
				float lightRatio104_g3 = _LightRatio;
				ApplyShadowAtten( finalColor104_g3 , shadowCoord104_g3 , positionWS104_g3 , lightRatio104_g3 );
				float4 finalColor6_g3 = finalColor104_g3;
				float3 normalWS6_g3 = input.normalWS;
				float lightRatio6_g3 = _LightRatio;
				ApplyLightColor( finalColor6_g3 , normalWS6_g3 , lightRatio6_g3 );
				float4 finalColor80_g3 = finalColor6_g3;
				float near80_g3 = _SoftParticleNearFadeDistance;
				float far80_g3 = _SoftParticleFarFadeDistance;
				float fadeOutRange80_g3 = _SoftParticleFadeOutRange;
				float localGetPositionCSForBending58_g3 = ( 0.0 );
				float4 positionCS58_g3 = float4( 0,0,0,0 );
				float4 positionNDC58_g3 = float4( 0,0,0,0 );
				float3 positionOS58_g3 = input.positionOS.xyz;
				GetPositionCSForBending( positionCS58_g3 , positionNDC58_g3 , positionOS58_g3 );
				float4 positionNDC80_g3 = positionNDC58_g3;
				ApplySoftParticle( finalColor80_g3 , near80_g3 , far80_g3 , fadeOutRange80_g3 , positionNDC80_g3 );
				float4 break64_g3 = finalColor80_g3;
				float3 appendResult76_g3 = (float3(break64_g3.x , break64_g3.y , break64_g3.z));

				float3 Color = appendResult76_g3;
				float Alpha = break64_g3.w;

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
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI"
	FallBack Off


}
/*ASEBEGIN
Version=18935
3264;207;1610;961;805;477.5;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-2256,208;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-2192,400;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;300;-1548.51,-186.5099;Inherit;False;1013.341;563.7654;Color;9;164;171;102;87;167;165;169;170;89;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-1491.22,551.5157;Inherit;False;532.4556;389.2555;Fresnel;4;162;159;161;158;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;153;-2016,208;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;161;-1459.22,615.5157;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;158;-1459.22,775.5158;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;89;-1520,160;Inherit;False;Property;_Color_Range;Color_Range;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1872,208;Inherit;True;Property;_NoiseTex;NoiseTex;15;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;e1ac02091495a9d4f92c19b48424a482;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;159;-1251.22,615.5157;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;239;-791.3092,439.5158;Inherit;False;895.3737;593.2839;Rim;7;94;204;82;294;90;86;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-1328,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;-1328,160;Inherit;False;Property;_Color_Offset;Color_Offset;19;0;Create;True;0;0;0;False;0;False;0;-0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;162;-1107.22,615.5157;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;165;-1136,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-743.3092,823.5158;Inherit;False;Property;_RimPower;Rim Power;21;0;Create;True;0;0;0;False;0;False;1;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;167;-992,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;86;-567.3091,711.5156;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-1134.346,48;Inherit;False;Property;_Sub_Color;Sub_Color;17;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.2028302,0.5479964,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;90;-407.3095,711.5156;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;-1136,-129;Inherit;False;Property;_Base_Color;Base_Color;16;1;[HDR];Create;True;0;0;0;False;2;Header(Color);Space();False;1,1,1,0;0.5058824,0.9450981,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;294;-432.9539,834.335;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;82;-487.3094,503.5159;Inherit;False;Property;_RimColor;Rim Color;20;1;[HDR];Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1,1,1,0;0.6576862,1.279335,1.720795,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-832,224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;110;-175,-97;Inherit;False;Property;_MainColor;Main Color;14;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.9481131,0.990542,1,0.7843137;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-231.3098,711.5156;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;108;-256,80;Inherit;True;Property;_MainTex;MainTex;13;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;70e7af4d073f9e7479e1f20b727a8fce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;164;-704,48;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;94;-103.3097,487.5159;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;247;80,80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;286;304,-160;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;109;288,48;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;301;560,48;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;304;1056,192;Inherit;False;199;216;Rendering Options;2;308;311;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;303;752,48;Inherit;False;MMN_CommonOutputs;0;;3;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;311;1088,320;Inherit;False;Property;_ZTest;Z Test;23;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;308;1080,235;Inherit;False;Property;_CullMode;Cull Mode;22;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;310;1056,48;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;0;20;MMN/FX/Amplify shader/FX_Ice_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;5;False;0;True;True;0;0;False;-6;0;True;-7;0;1;False;-1;0;False;-1;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;308;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;0;True;311;False;True;0;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;;0;1;Above;MMN/FX/AddPass/ShadowCaster;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;153;0;6;0
WireConnection;153;1;148;0
WireConnection;5;1;153;0
WireConnection;159;0;161;0
WireConnection;159;1;158;0
WireConnection;170;0;89;0
WireConnection;170;1;5;2
WireConnection;162;0;159;0
WireConnection;165;0;169;0
WireConnection;165;1;170;0
WireConnection;167;0;165;0
WireConnection;86;0;162;0
WireConnection;86;1;79;0
WireConnection;90;0;86;0
WireConnection;171;0;87;4
WireConnection;171;1;167;0
WireConnection;204;0;82;4
WireConnection;204;1;90;0
WireConnection;204;2;294;4
WireConnection;164;0;102;0
WireConnection;164;1;87;0
WireConnection;164;2;171;0
WireConnection;94;0;164;0
WireConnection;94;1;82;0
WireConnection;94;2;204;0
WireConnection;247;0;110;4
WireConnection;247;1;108;2
WireConnection;109;0;94;0
WireConnection;109;1;110;0
WireConnection;109;2;247;0
WireConnection;301;0;286;0
WireConnection;301;1;109;0
WireConnection;301;2;286;4
WireConnection;303;9;301;0
WireConnection;310;0;303;2
WireConnection;310;1;303;26
ASEEND*/
//CHKSM=CDF6C37BA6C86248AE5C906320BBD8638DD7DBC0