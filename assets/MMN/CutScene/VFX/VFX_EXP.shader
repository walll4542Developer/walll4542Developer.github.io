// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/CutScene/VFX/VFX_EXP"
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
		[Header(tcd1.x     Emi_Dissolve_A)][Header(tcd1.y     Emi_Dissolve_B)][Header(tcd1.z     Dissolve)][Header(tcd1.w    Vertex_Val)][Header(tcd3.xyzw     Color)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_Color_A("Color_A", Color) = (1,0.4712042,0,1)
		[HDR]_Color_B("Color_B", Color) = (1,1,1,1)
		_Emi_Opacity("Emi_Opacity", Float) = 1
		_Emi_Range("Emi_Range", Float) = 0.12
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_Opacity("Noise_Opacity", Float) = 7.47
		_Noise_Upanner("Noise_Upanner", Float) = 0
		_Noise_Vpanner("Noise_Vpanner", Float) = 0
		_Opacity("Opacity", Float) = 1
		_VertexTex("VertexTex", 2D) = "white" {}
		_Vertex_Upanner("Vertex_Upanner", Float) = 0
		_Vertex_Vpanner("Vertex_Vpanner", Float) = 0
		_FresnelTex("FresnelTex", 2D) = "white" {}
		_Normal_Val("Normal_Val", Float) = 0
		_Fresnel_Power("Fresnel_Power", Float) = 1
		_Fresnel_Scale("Fresnel_Scale", Float) = 1
		_Normal_Upanner("Normal_Upanner", Float) = 0
		_Normal_Vpanner("Normal_Vpanner", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

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

			#include "../../FX/Includes/FXCommonOutputs.hlsl"
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _VertexTex;
			sampler2D _FresnelTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _VertexTex_ST;
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float4 _Color_A;
			float4 _FresnelTex_ST;
			float4 _Color_B;
			float _Emi_Range;
			float _Noise_Opacity;
			float _Noise_Vpanner;
			float _Noise_Upanner;
			float _Emi_Opacity;
			float _Fresnel_Power;
			float _Fresnel_Scale;
			float _Normal_Val;
			float _Normal_Vpanner;
			float _Normal_Upanner;
			float _NearPlaneAlpha;
			float _Vertex_Upanner;
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
			float _Vertex_Vpanner;
			float _Opacity;
			CBUFFER_END


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord3 : TEXCOORD3;
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
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float2 appendResult28 = (float2(_Vertex_Upanner , _Vertex_Vpanner));
				float2 uv_VertexTex = input.texcoord.xy * _VertexTex_ST.xy + _VertexTex_ST.zw;
				float2 panner26 = ( 1.0 * _Time.y * appendResult28 + uv_VertexTex);
				
				float3 ase_worldTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
				output.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(input.normalOS);
				float ase_vertexTangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				output.ase_texcoord4.xyz = ase_worldBitangent;
				
				output.ase_texcoord2 = input.ase_texcoord3;
				output.ase_color = input.color;
				output.ase_texcoord5 = input.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord3.w = 0;
				output.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( input.normalOS * ( tex2Dlod( _VertexTex, float4( panner26, 0, 0.0) ).r * input.ase_texcoord1.w ) );
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
				float localFXFinalColorOutputs125_g8 = ( 0.0 );
				float4 appendResult95 = (float4(input.ase_texcoord2.x , input.ase_texcoord2.y , input.ase_texcoord2.z , input.ase_texcoord2.w));
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float2 appendResult142 = (float2(_Normal_Upanner , _Normal_Vpanner));
				float2 uv_FresnelTex = input.uv0.xy * _FresnelTex_ST.xy + _FresnelTex_ST.zw;
				float2 panner141 = ( 1.0 * _Time.y * appendResult142 + uv_FresnelTex);
				float3 ase_worldTangent = input.ase_texcoord3.xyz;
				float3 ase_worldBitangent = input.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, input.normalWS.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, input.normalWS.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, input.normalWS.z );
				float3 tanNormal138 = UnpackNormalScale( tex2D( _FresnelTex, panner141 ), 1.0f );
				float3 worldNormal138 = float3(dot(tanToWorld0,tanNormal138), dot(tanToWorld1,tanNormal138), dot(tanToWorld2,tanNormal138));
				float fresnelNdotV33 = dot( ( worldNormal138 * _Normal_Val ), ase_worldViewDir );
				float fresnelNode33 = ( 0.0 + _Fresnel_Scale * pow( 1.0 - fresnelNdotV33, _Fresnel_Power ) );
				float4 Fresnel210 = ( appendResult95 * saturate( fresnelNode33 ) );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float MainTex198 = tex2D( _MainTex, uv_MainTex ).r;
				float2 appendResult75 = (float2(_Noise_Upanner , _Noise_Vpanner));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner72 = ( 1.0 * _Time.y * appendResult75 + uv_NoiseTex);
				float NoiseTex203 = tex2D( _NoiseTex, panner72 ).r;
				float temp_output_85_0 = saturate( ( MainTex198 * ( MainTex198 + NoiseTex203 + _Emi_Range ) ) );
				float4 lerpResult96 = lerp( input.ase_color , _Color_A , saturate( ( _Emi_Opacity * saturate( ( saturate( ( saturate( ( (-2.0 + (input.ase_texcoord5.x - -1.0) * (2.0 - -2.0) / (1.0 - -1.0)) + ( MainTex198 + NoiseTex203 ) ) ) * _Noise_Opacity ) ) * temp_output_85_0 ) ) ) ));
				float4 lerpResult84 = lerp( lerpResult96 , _Color_B , saturate( ( _Emi_Opacity * saturate( ( saturate( ( saturate( ( (-2.0 + (input.ase_texcoord5.y - -1.0) * (2.0 - -2.0) / (1.0 - -1.0)) + ( MainTex198 + NoiseTex203 ) ) ) * _Noise_Opacity ) ) * temp_output_85_0 ) ) ) ));
				float4 temp_output_32_0 = ( Fresnel210 + lerpResult84 );
				float4 appendResult32_g8 = (float4(temp_output_32_0.xyz , ( input.ase_color.a * saturate( ( saturate( ( ( NoiseTex203 + MainTex198 ) + (-2.0 + (input.ase_texcoord5.z - -1.0) * (2.0 - -2.0) / (1.0 - -1.0)) ) ) * _Opacity ) ) )));
				float4 finalColor125_g8 = appendResult32_g8;
				float4 texCoord147_g8 = input.screenPos;
				texCoord147_g8.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g8 = texCoord147_g8;
				float4 positionNDC125_g8 = ScreenPos146_g8;
				float4 texCoord140_g8 = input.fogCoord;
				texCoord140_g8.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g8 = texCoord140_g8;
				float4 fogCoord125_g8 = fogCoord139_g8;
				float3 positionWS125_g8 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g8 = normalizedWorldNormal;
				float nearPlaneAlpha125_g8 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g8 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g8 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g8 = _RaycastMinimumAlpha;
				float lightRatio125_g8 = _LightRatio;
				float lightReceive125_g8 = _LightReceive;
				float near125_g8 = _SoftParticleNearFadeDistance;
				float far125_g8 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g8 = _SoftParticleFadeOutRange;
				float softParticle125_g8 = _SoftParticle;
				float mode125_g8 = _Mode;
				float fogReceive125_g8 = _FogReceive;
				float transitionValue125_g8 = _TransitionValue;
				float spawnTransition125_g8 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g8 , positionNDC125_g8 , fogCoord125_g8 , positionWS125_g8 , normalWS125_g8 , nearPlaneAlpha125_g8 , nearPlaneInvertDistance125_g8 , raycastHarftoneClip125_g8 , raycastMinimumAlpha125_g8 , lightRatio125_g8 , lightReceive125_g8 , near125_g8 , far125_g8 , fadeOutRange125_g8 , softParticle125_g8 , mode125_g8 , fogReceive125_g8 , transitionValue125_g8 , spawnTransition125_g8 );
				float4 break64_g8 = finalColor125_g8;
				float3 appendResult76_g8 = (float3(break64_g8.x , break64_g8.y , break64_g8.z));
				
				float3 color = appendResult76_g8;
				float alpha = break64_g8.w;

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
Node;AmplifyShaderEditor.CommentaryNode;212;-4273.583,539.4305;Inherit;False;2593.129;1291.105;Resister_Local_Var;27;72;75;74;73;70;8;203;36;55;210;10;76;198;95;94;33;34;35;138;145;146;141;139;142;143;144;140;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;-118.228,484.2856;Inherit;False;204;375;Rendering Options;4;6;4;3;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-86.22798,612.2856;Inherit;False;Property;_BlendDst;Blend Dst;36;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-86.22798,692.2855;Inherit;False;Property;_CullMode;Cull Mode;37;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-86.22798,772.2855;Inherit;False;Property;_ZTest;Z Test;38;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;102;-2056.031,-363.1399;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-2251.926,-302.7401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-2710.053,-814.1395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;-2517.094,-815.0139;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-86.22798,532.2856;Inherit;False;Property;_BlendSrc;Blend Src;35;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;5;-313.0525,-287.6716;Inherit;False;MMN_CommonOutputs;0;;8;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT4;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.DynamicAppendNode;147;-508.4745,-395.76;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;148;-781.2856,-398.6477;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-2654.404,-423.9723;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;132;-2478.904,-422.6723;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;185;-2923.618,-816.0416;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;133;-2920.343,-422.5471;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;97;-805.129,-228.9698;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-539.416,-109.9958;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;137;-24.9962,-285.5381;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/CutScene/VFX/VFX_EXP;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;True;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.NormalVertexDataNode;20;-574.0194,18.47536;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-319.8798,114.7027;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;17;-771.7441,-22.42755;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1132.485,190.2368;Inherit;False;Property;_Opacity;Opacity;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-944.6689,-17.99685;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;64;-1120.337,-10.6495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;196;-1265.505,-13.37464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1431.813,-26.94015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-1679.466,34.93093;Inherit;False;198;MainTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;195;-1489.266,128.2069;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-546.8513,325.3296;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;93;-1766.421,257.4615;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;28;-1327.953,616.4454;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1563.953,617.4454;Inherit;False;Property;_Vertex_Upanner;Vertex_Upanner;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-862.0608,414.9261;Inherit;True;Property;_VertexTex;VertexTex;26;0;Create;True;0;0;0;False;0;False;-1;4b0a426888e18e944a33ce4b62518d6b;4b0a426888e18e944a33ce4b62518d6b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1382.035,442.4129;Inherit;False;0;23;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;26;-1103.672,443.3812;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1563.315,710.46;Inherit;False;Property;_Vertex_Vpanner;Vertex_Vpanner;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1033.133,-752.8993;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-2949.107,-558.4583;Inherit;False;Property;_Noise_Opacity;Noise_Opacity;22;0;Create;True;0;0;0;False;0;False;7.47;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;211;-1271.307,-893.5272;Inherit;False;210;Fresnel;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;84;-1326.653,-733.8954;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;120;-1527.165,-604.3555;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-1658.775,-782.8365;Inherit;False;Property;_Color_B;Color_B;18;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-1770.775,-514.5161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;96;-1631.896,-1120.759;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;86;-1919.667,-1097.624;Inherit;False;Property;_Color_A;Color_A;17;1;[HDR];Create;True;0;0;0;False;0;False;1,0.4712042,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;121;-1781.143,-903.5921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;107;-1903.646,-1279.5;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-1953.335,-796.4026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;98;-2127.434,-772.9595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2301.608,-774.3194;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2808.056,-7.973797;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-3040.003,-85.11098;Inherit;False;198;MainTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2202.4,-516.9344;Inherit;False;Property;_Emi_Opacity;Emi_Opacity;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-3598.129,-230.5362;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;184;-3606.906,-487.4308;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;193;-3354.108,-404.5424;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-3830.804,-243.1494;Inherit;False;198;MainTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-3833.858,-160.2275;Inherit;False;203;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-3830.013,-399.6781;Inherit;False;203;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-3827.964,-494.6611;Inherit;False;198;MainTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;194;-3077.576,-258.3155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-3255.995,-813.0764;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;129;-3751.724,-874.252;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;191;-3462.286,-853.3175;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-3203.313,227.5933;Inherit;False;Property;_Emi_Range;Emi_Range;20;0;Create;True;0;0;0;False;0;False;0.12;49.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-2955.721,68.81876;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-3219.328,57.90909;Inherit;False;198;MainTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;204;-3223.6,134.9526;Inherit;False;203;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-2537.293,-9.616291;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-1677.46,-54.74033;Inherit;False;203;NoiseTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;72;-2494.275,859.6873;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-2692.853,1033.25;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2986.853,1143.25;Inherit;False;Property;_Noise_Vpanner;Noise_Vpanner;24;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-3000.853,1059.25;Inherit;False;Property;_Noise_Upanner;Noise_Upanner;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-2841.275,848.6873;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-2268.733,833.3716;Inherit;True;Property;_NoiseTex;NoiseTex;21;0;Create;True;0;0;0;False;0;False;-1;8758393a2f5ab2d48a6b6fe4e2279423;8758393a2f5ab2d48a6b6fe4e2279423;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;-1922.456,855.1625;Inherit;False;NoiseTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2168.463,1385.069;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;55;-2409.851,1550.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-1924.575,1391.136;Inherit;False;Fresnel;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-2508.25,612.5295;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-1928.326,614.0912;Inherit;False;MainTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-2400.897,1285.436;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;94;-2739.295,1263.293;Inherit;False;3;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;33;-2658.017,1549.303;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2884.712,1628.535;Inherit;False;Property;_Fresnel_Scale;Fresnel_Scale;32;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-2890.712,1717.535;Inherit;False;Property;_Fresnel_Power;Fresnel_Power;31;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;138;-3199.22,1366.728;Inherit;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-2878.22,1477.728;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-3135.22,1628.728;Inherit;False;Property;_Normal_Val;Normal_Val;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;141;-3772.268,1407.389;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;139;-3545.268,1369.389;Inherit;True;Property;_FresnelTex;FresnelTex;29;0;Create;True;0;0;0;False;0;False;-1;c9a822540f13f5e42a2626939ac83ddc;c9a822540f13f5e42a2626939ac83ddc;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;142;-3972.585,1513.657;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-4223.583,1545.657;Inherit;False;Property;_Normal_Upanner;Normal_Upanner;33;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-4210.583,1633.657;Inherit;False;Property;_Normal_Vpanner;Normal_Vpanner;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;140;-4047.583,1368.657;Inherit;False;0;139;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-2243.365,589.4305;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;8;Header(tcd1.x     Emi_Dissolve_A);Header(tcd1.y     Emi_Dissolve_B);Header(tcd1.z     Dissolve);Header(tcd1.w    Vertex_Val);Header(tcd3.xyzw     Color);Header(Main Texture);Space();;False;-1;2c933ac860a256244a86f3537bd35582;2c933ac860a256244a86f3537bd35582;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;102;0;115;0
WireConnection;115;0;132;0
WireConnection;115;1;85;0
WireConnection;90;0;185;0
WireConnection;90;1;91;0
WireConnection;130;0;90;0
WireConnection;5;9;32;0
WireConnection;5;28;39;0
WireConnection;147;0;148;0
WireConnection;147;1;148;1
WireConnection;147;2;148;2
WireConnection;148;0;32;0
WireConnection;131;0;133;0
WireConnection;131;1;91;0
WireConnection;132;0;131;0
WireConnection;185;0;192;0
WireConnection;133;0;194;0
WireConnection;39;0;97;4
WireConnection;39;1;17;0
WireConnection;137;0;5;2
WireConnection;137;1;5;26
WireConnection;137;3;31;0
WireConnection;31;0;20;0
WireConnection;31;1;57;0
WireConnection;17;0;67;0
WireConnection;67;0;64;0
WireConnection;67;1;68;0
WireConnection;64;0;196;0
WireConnection;196;0;65;0
WireConnection;196;1;195;0
WireConnection;65;0;207;0
WireConnection;65;1;199;0
WireConnection;195;0;93;3
WireConnection;57;0;23;1
WireConnection;57;1;93;4
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;23;1;26;0
WireConnection;26;0;27;0
WireConnection;26;2;28;0
WireConnection;32;0;211;0
WireConnection;32;1;84;0
WireConnection;84;0;96;0
WireConnection;84;1;87;0
WireConnection;84;2;120;0
WireConnection;120;0;123;0
WireConnection;123;0;124;0
WireConnection;123;1;102;0
WireConnection;96;0;107;0
WireConnection;96;1;86;0
WireConnection;96;2;121;0
WireConnection;121;0;122;0
WireConnection;122;0;124;0
WireConnection;122;1;98;0
WireConnection;98;0;114;0
WireConnection;114;0;130;0
WireConnection;114;1;85;0
WireConnection;60;0;197;0
WireConnection;60;1;59;0
WireConnection;135;0;202;0
WireConnection;135;1;208;0
WireConnection;184;0;201;0
WireConnection;184;1;205;0
WireConnection;193;0;129;2
WireConnection;194;0;193;0
WireConnection;194;1;135;0
WireConnection;192;0;191;0
WireConnection;192;1;184;0
WireConnection;191;0;129;1
WireConnection;59;0;200;0
WireConnection;59;1;204;0
WireConnection;59;2;134;0
WireConnection;85;0;60;0
WireConnection;72;0;70;0
WireConnection;72;2;75;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;8;1;72;0
WireConnection;203;0;8;1
WireConnection;36;0;95;0
WireConnection;36;1;55;0
WireConnection;55;0;33;0
WireConnection;210;0;36;0
WireConnection;198;0;10;1
WireConnection;95;0;94;1
WireConnection;95;1;94;2
WireConnection;95;2;94;3
WireConnection;95;3;94;4
WireConnection;33;0;145;0
WireConnection;33;2;34;0
WireConnection;33;3;35;0
WireConnection;138;0;139;0
WireConnection;145;0;138;0
WireConnection;145;1;146;0
WireConnection;141;0;140;0
WireConnection;141;2;142;0
WireConnection;139;1;141;0
WireConnection;142;0;143;0
WireConnection;142;1;144;0
WireConnection;10;1;76;0
ASEEND*/
//CHKSM=B2D14F1BA9B8E80958B5FD2E67102FF0508D3E44