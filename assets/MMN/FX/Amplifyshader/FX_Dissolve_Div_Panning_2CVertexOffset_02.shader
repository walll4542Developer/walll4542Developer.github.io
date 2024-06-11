// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Panning_2CVertexOffset_02"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w     VertexOffset Power)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_Main_X_Speed("Main_X_Speed", Float) = 1
		_Main_Y_Speed("Main_Y_Speed", Float) = 1
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseTex_WolrdTilling("NoiseTex_WolrdTilling", Float) = 0.2
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		[Header(Noise Texture)][Space()]_NoiseTex2("NoiseTex2", 2D) = "white" {}
		_Noise_X_Speed2("Noise_X_Speed2", Float) = 1
		_Noise_Y_Speed2("Noise_Y_Speed2", Float) = 1
		[Header(Vertex Texture)][Space()]_VertexTex("VertexTex", 2D) = "white" {}
		_VertexPower("VertexPower", Float) = 1
		_Vertex_X_Speed("Vertex_X_Speed", Float) = 1
		_Vertex_Y_Speed("Vertex_Y_Speed", Float) = 1
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Vertex Sin Wave)][Space()]_WaveLength("WaveLength", Float) = 5
		_WaveSpeed("WaveSpeed", Float) = 5
		_WavePower("WavePower", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1

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
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _VertexTex;
			sampler2D _MainTex;
			sampler2D _NoiseTex2;
			sampler2D _NoiseTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _SubColor;
			float4 _MainColor;
			float4 _VertexTex_ST;
			float4 _NoiseTex2_ST;
			float4 _MainTex_ST;
			float _NearPlaneAlpha;
			float _Color_Offset;
			float _Main_X_Speed;
			float _Main_Y_Speed;
			float _Use_G_Channel_Alpha;
			float _Noise_X_Speed2;
			float _Noise_Y_Speed2;
			float _Noise_X_Speed;
			float _Noise_Y_Speed;
			float _NoiseTex_WolrdTilling;
			float _ColorGradation;
			float _Color_Range;
			float _Intensity_Color;
			float _WavePower;
			float _WaveLength;
			float _WaveSpeed;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _LightReceive;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _Intensity_Alpha;
			float _SoftParticleFadeOutRange;
			float _Mode;
			float _FogReceive;
			float _TransitionValue;
			float _SpawnTransition;
			float _VertexPower;
			float _Vertex_X_Speed;
			float _Vertex_Y_Speed;
			float _SoftParticle;
			float _EffectAlpha;
			CBUFFER_END


			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
    			float4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_color : COLOR;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float2 uv_VertexTex = input.texcoord.xy * _VertexTex_ST.xy + _VertexTex_ST.zw;
				float2 appendResult206 = (float2(_Vertex_X_Speed , _Vertex_Y_Speed));
				float2 appendResult245 = (float2(uv_VertexTex.x , ( uv_VertexTex.y + input.ase_texcoord1.w )));
				float2 panner205 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult206 + appendResult245);
				float2 texCoord284 = input.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (( ( texCoord284.y * _WaveLength ) + input.ase_texcoord1.w )).xx;
				float2 panner288 = ( ( _WaveSpeed * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) ) * float2( 1,1 ) + temp_cast_0);
				
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_color = input.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( ( uv_VertexTex.x * ( 1.0 - uv_VertexTex.x ) * 4.0 ) * input.normalOS * _VertexPower * input.ase_texcoord1.x * tex2Dlod( _VertexTex, float4( panner205, 0, 0.0) ).g ) + ( ( 4.0 * ( 1.0 - texCoord284.y ) * texCoord284.y ) * float3( sin( panner288 ) ,  0.0 ) * cross( input.normalOS , float3(0,0,1) ) * input.texcoord.w * input.ase_texcoord1.y * _WavePower ) );
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
				float2 appendResult218 = (float2(_Main_X_Speed , _Main_Y_Speed));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult241 = (float2(uv_MainTex.x , ( uv_MainTex.y + input.ase_texcoord2.w )));
				float2 panner221 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult218 + appendResult241);
				float4 tex2DNode5 = tex2D( _MainTex, panner221 );
				float lerpResult98 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float2 texCoord181 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_225_0 = saturate( ( 1.0 - texCoord181.x ) );
				float2 appendResult255 = (float2(_Noise_X_Speed2 , _Noise_Y_Speed2));
				float2 uv_NoiseTex2 = input.uv0.xy * _NoiseTex2_ST.xy + _NoiseTex2_ST.zw;
				float2 panner252 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult255 + ( uv_NoiseTex2 + input.ase_texcoord2.w ));
				float4 tex2DNode263 = tex2D( _NoiseTex2, panner252 );
				float temp_output_227_0 = ( ( input.uv0.w + temp_output_225_0 ) * input.ase_color.a * tex2DNode263.g );
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 appendResult247 = (float2(input.positionWS.x , input.positionWS.z));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + ( input.ase_texcoord2.w + ( appendResult247 * _NoiseTex_WolrdTilling ) ));
				float lerpResult229 = lerp( saturate( ( lerpResult98 + temp_output_227_0 ) ) , saturate( ( ( temp_output_225_0 * temp_output_225_0 * temp_output_225_0 * temp_output_225_0 * input.uv0.z ) + ( temp_output_227_0 * tex2D( _NoiseTex, panner49 ).b * tex2DNode263.g ) ) ) , input.ase_texcoord2.z);
				float temp_output_22_0 = ( lerpResult229 - input.uv0.z );
				float2 texCoord105 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult106 = lerp( temp_output_22_0 , texCoord105.x , _ColorGradation);
				float4 lerpResult13_g15 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult106 ) * _Color_Range ) ));
				float4 temp_output_124_0 = lerpResult13_g15;
				float4 lerpResult99 = lerp( ( tex2DNode5 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float4 appendResult32_g20 = (float4(( _Intensity_Color * temp_output_124_0 * lerpResult99 ).rgb , ( ( input.ase_color.a * (temp_output_124_0).a * saturate( ( ( temp_output_22_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) ) * saturate( _EffectAlpha ) )));
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
Node;AmplifyShaderEditor.CommentaryNode;101;-2026.993,-129.2844;Inherit;False;250.3594;260.6834;Switch;2;98;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2003.646,49.71559;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;24;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;98;-1939.646,-79.28438;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-1312,-496;Inherit;False;422.6843;276.8151;Color Gradation;3;106;105;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1280,-448;Inherit;False;Property;_ColorGradation;Color Gradation;36;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;106;-1056,-448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-468.2958,-228.213;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;102;-329.0126,-178;Inherit;False;182.0251;190.676;Switch;1;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-352,-480;Inherit;False;Property;_Intensity_Color;Intensity_Color;44;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;99;-304,-128;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;78;545,-94;Inherit;False;190;475;Rendering Options;4;82;81;79;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-144,-304;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;107;568,297;Inherit;False;Property;_ZTest;Z Test;49;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;561,130;Inherit;False;Property;_BlendDst;Blend Dst;47;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;561,50;Inherit;False;Property;_BlendSrc;Blend Src;46;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;561,210;Inherit;False;Property;_CullMode;Cull Mode;48;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;277.6046,-98.33906;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;15;MMN/FX/Amplify shader/FX_Dissolve_Div_Panning_2CVertexOffset_02;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;638495219933300495;0;1;True;False;;False;0
Node;AmplifyShaderEditor.ColorNode;35;-1072,-1024;Inherit;False;Property;_MainColor;Main Color;37;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-992,368;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;45;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-992,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-800,256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-352,64;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;121;-384,352;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-576,352;Inherit;False;Property;_EffectAlpha;EffectAlpha;50;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;105;-1280,-368;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;29;-1072,-848;Inherit;False;Property;_SubColor;Sub Color;38;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.9292453,0.9942631,1,0.8235294;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1072,-672;Inherit;False;Property;_Color_Offset;Color_Offset;39;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1072,-592;Inherit;False;Property;_Color_Range;Color_Range;40;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;44;-640,256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;124;-768,-592;Inherit;False;MMN_ColorLerp;16;;15;1bb351d8c3d782c43b489ac591238e71;0;5;1;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;46;-635.28,132.0804;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-672,-96;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;225;-2320,656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-2016,576;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;183;-2160,576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;180;-2704,480;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;230;-1568,880;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-2339.646,-127.2844;Inherit;True;Property;_MainTex;MainTex;21;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.w     VertexOffset Power);Header(Main Texture);Space();False;-1;None;91227f7ffeda1d840a77cc0ddc7d9298;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;218;-2877.061,26.86483;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;219;-2890.061,167.8647;Inherit;False;MMN_Time;-1;;16;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-3069.061,26.86483;Inherit;False;Property;_Main_X_Speed;Main_X_Speed;22;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-3066.061,106.8647;Inherit;False;Property;_Main_Y_Speed;Main_Y_Speed;23;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;224;-1696,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;176;-1568,160;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;229;-1408,160;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;43;-1152,368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1152,256;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;221;-2656,-112;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;-3039.405,-288.4063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;240;-3311.405,-288.4063;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;241;-2799.405,-400.4063;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;238;-3311.405,-432.4063;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;159;150.6536,951.5329;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;92;-734.1888,1175.604;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;205;-735.7865,2046.131;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;200;-510.4285,1981.391;Inherit;True;Property;_VertexTex;VertexTex;32;0;Create;True;0;0;0;False;2;Header(Vertex Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;244;-1360,1872;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;210;-1184,2080;Inherit;False;Property;_Vertex_X_Speed;Vertex_X_Speed;34;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-1184,2160;Inherit;False;Property;_Vertex_Y_Speed;Vertex_Y_Speed;35;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;206;-928,2080;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;214;-960,2240;Inherit;False;MMN_Time;-1;;17;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;245;-928,1920;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-1104,1936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;177;-736,1328;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;267;-768,944;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-576,880;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;266;-768,1024;Inherit;False;Constant;_Float0;Float 0;35;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;264;-1024,880;Inherit;False;0;200;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-192,960;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-448,1408;Inherit;False;Property;_VertexPower;VertexPower;33;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;242;-1376,1728;Inherit;False;0;200;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;181;-2864,656;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;185;-2640,656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;226;-2224,384;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-179,65;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;279;-8.361073,-86.83318;Inherit;False;MMN_CommonOutputs;0;;20;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;-1975.6,723.2999;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1392,368;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;283;-2384,736;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-1616,544;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;278;-1568,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-1760,736;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;252;-2432,960;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;255;-2656,1152;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;256;-2688,1296;Inherit;False;MMN_Time;-1;;19;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;-2896,960;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;263;-2240,960;Inherit;True;Property;_NoiseTex2;NoiseTex2;29;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;253;-2848,1152;Inherit;False;Property;_Noise_X_Speed2;Noise_X_Speed2;30;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-2848,1232;Inherit;False;Property;_Noise_Y_Speed2;Noise_Y_Speed2;31;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;270;-3168,832;Inherit;False;0;263;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;49;-2432,1440;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2848,1632;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;27;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-2848,1712;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;28;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-2656,1632;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;97;-2688,1776;Inherit;False;MMN_Time;-1;;18;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;237;-2896,1440;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;246;-3456,1648;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;247;-3264,1648;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;248;-3104,1648;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;48;-2240,1440;Inherit;True;Property;_NoiseTex;NoiseTex;25;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;249;-3360,1808;Inherit;False;Property;_NoiseTex_WolrdTilling;NoiseTex_WolrdTilling;26;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;288;-69.04599,2485.795;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-469.046,2901.795;Inherit;False;Property;_WaveSpeed;WaveSpeed;42;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;292;-469.046,2997.795;Inherit;False;MMN_Time;-1;;9;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;-245.046,2901.795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;294;586.954,2341.795;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;295;378.954,2421.795;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;296;128,2640;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CrossProductOpNode;299;400,2640;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;298;336,2896;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;297;336,3072;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;301;368,3248;Inherit;False;Property;_WavePower;WavePower;43;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;284;-848,2512;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;285;-268.046,2390.795;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;286;-460.046,2310.795;Inherit;False;Constant;_Float1;Float 1;26;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;287;-460.046,2390.795;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;-473.046,2628.795;Inherit;False;Property;_WaveLength;WaveLength;41;0;Create;True;0;0;0;False;2;Header(Vertex Sin Wave);Space();False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;300;128,2784;Inherit;False;Constant;_WaveVector;WaveVector;41;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;232;-3168,1440;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;258;-3168,960;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-180.5187,2596.948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-339.9444,2534.795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;303;-416,2704;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;98;0;5;4
WireConnection;98;1;5;2
WireConnection;98;2;100;0
WireConnection;106;0;22;0
WireConnection;106;1;105;1
WireConnection;106;2;104;0
WireConnection;94;0;5;0
WireConnection;94;1;66;0
WireConnection;99;0;94;0
WireConnection;99;1;66;0
WireConnection;99;2;100;0
WireConnection;61;0;60;0
WireConnection;61;1;124;0
WireConnection;61;2;99;0
WireConnection;84;0;279;2
WireConnection;84;1;279;26
WireConnection;84;3;159;0
WireConnection;40;0;22;0
WireConnection;40;1;43;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;45;0;66;4
WireConnection;45;1;46;0
WireConnection;45;2;44;0
WireConnection;121;0;122;0
WireConnection;44;0;41;0
WireConnection;124;1;35;0
WireConnection;124;3;29;0
WireConnection;124;7;26;0
WireConnection;124;8;33;0
WireConnection;124;9;106;0
WireConnection;46;0;124;0
WireConnection;225;0;185;0
WireConnection;227;0;183;0
WireConnection;227;1;226;4
WireConnection;227;2;263;2
WireConnection;183;0;180;4
WireConnection;183;1;225;0
WireConnection;5;1;221;0
WireConnection;218;0;216;0
WireConnection;218;1;217;0
WireConnection;224;0;98;0
WireConnection;224;1;227;0
WireConnection;176;0;224;0
WireConnection;229;0;176;0
WireConnection;229;1;278;0
WireConnection;229;2;230;3
WireConnection;43;0;24;3
WireConnection;22;0;229;0
WireConnection;22;1;24;3
WireConnection;221;0;241;0
WireConnection;221;2;218;0
WireConnection;221;1;219;0
WireConnection;239;0;238;2
WireConnection;239;1;240;4
WireConnection;241;0;238;1
WireConnection;241;1;239;0
WireConnection;159;0;86;0
WireConnection;159;1;294;0
WireConnection;205;0;245;0
WireConnection;205;2;206;0
WireConnection;205;1;214;0
WireConnection;200;1;205;0
WireConnection;206;0;210;0
WireConnection;206;1;211;0
WireConnection;245;0;242;1
WireConnection;245;1;243;0
WireConnection;243;0;242;2
WireConnection;243;1;244;4
WireConnection;267;0;264;1
WireConnection;265;0;264;1
WireConnection;265;1;267;0
WireConnection;265;2;266;0
WireConnection;86;0;265;0
WireConnection;86;1;92;0
WireConnection;86;2;212;0
WireConnection;86;3;177;1
WireConnection;86;4;200;2
WireConnection;185;0;181;1
WireConnection;120;0;45;0
WireConnection;120;1;121;0
WireConnection;279;9;61;0
WireConnection;279;28;120;0
WireConnection;277;0;225;0
WireConnection;277;1;225;0
WireConnection;277;2;225;0
WireConnection;277;3;225;0
WireConnection;277;4;283;3
WireConnection;282;0;277;0
WireConnection;282;1;231;0
WireConnection;278;0;282;0
WireConnection;231;0;227;0
WireConnection;231;1;48;3
WireConnection;231;2;263;2
WireConnection;252;0;257;0
WireConnection;252;2;255;0
WireConnection;252;1;256;0
WireConnection;255;0;253;0
WireConnection;255;1;254;0
WireConnection;257;0;270;0
WireConnection;257;1;258;4
WireConnection;263;1;252;0
WireConnection;49;0;237;0
WireConnection;49;2;52;0
WireConnection;49;1;97;0
WireConnection;52;0;50;0
WireConnection;52;1;119;0
WireConnection;237;0;232;4
WireConnection;237;1;248;0
WireConnection;247;0;246;1
WireConnection;247;1;246;3
WireConnection;248;0;247;0
WireConnection;248;1;249;0
WireConnection;48;1;49;0
WireConnection;288;0;302;0
WireConnection;288;1;293;0
WireConnection;293;0;291;0
WireConnection;293;1;292;0
WireConnection;294;0;285;0
WireConnection;294;1;295;0
WireConnection;294;2;299;0
WireConnection;294;3;298;4
WireConnection;294;4;297;2
WireConnection;294;5;301;0
WireConnection;295;0;288;0
WireConnection;299;0;296;0
WireConnection;299;1;300;0
WireConnection;285;0;286;0
WireConnection;285;1;287;0
WireConnection;285;2;284;2
WireConnection;287;0;284;2
WireConnection;302;0;289;0
WireConnection;302;1;303;4
WireConnection;289;0;284;2
WireConnection;289;1;290;0
ASEEND*/
//CHKSM=C136DF3596A8CEF654AE0AFE7C89CDCFAAF929D2