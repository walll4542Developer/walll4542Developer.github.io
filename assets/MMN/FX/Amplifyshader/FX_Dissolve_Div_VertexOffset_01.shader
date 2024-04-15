// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_VertexOffset_01"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.w     VertexOffset Power)][Header(tcd1.x      WaveLength Power)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		_Twist("Twist", Float) = 0
		[Header(Mask Texture)][Space()]_MaskTex("MaskTex", 2D) = "white" {}
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Lerp Color)][Space()]_LerpColor("Lerp Color", Color) = (1,1,1,1)
		_LerpColor_Offset("LerpColor_Offset", Float) = 0
		_LerpColor_Range("LerpColor_Range", Float) = 1
		[Space()]_LerpColor_Intensity("LerpColor_Intensity", Float) = 1
		[Header(Vertex Sin Wave)][Space()]_WaveLength("WaveLength", Float) = 5
		_WaveSpeed("WaveSpeed", Float) = 5
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector]_EffectAlpha("EffectAlpha", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _SubColor;
			float4 _LerpColor;
			float4 _NoiseTex_ST;
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _MaskTex_ST;
			float _SoftParticleNearFadeDistance;
			float _Intensity_Alpha;
			float _LerpColor_Range;
			float _LerpColor_Offset;
			float _NearPlaneInvertDistance;
			float _LerpColor_Intensity;
			float _Color_Range;
			float _ColorGradation;
			float _Twist;
			float _RaycastHarftoneClip;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Use_G_Channel_Alpha;
			float _LightReceive;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _EffectAlpha;
			float _Intensity_Color;
			float _WaveLength;
			float _WaveSpeed;
			float _SpawnTransition;
			float _TransitionValue;
			float _FogReceive;
			float _Mode;
			float _SoftParticle;
			float _SoftParticleFadeOutRange;
			float _SoftParticleFarFadeDistance;
			float _Color_Offset;
			float _NearPlaneAlpha;
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
				float4 ase_color : COLOR;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float2 texCoord126 = input.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (( texCoord126.x * _WaveLength * input.ase_texcoord1.x )).xx;
				float2 panner134 = ( ( _WaveSpeed * ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) ) * float2( 1,1 ) + temp_cast_0);
				
				output.ase_color = input.color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( 4.0 * ( 1.0 - texCoord126.x ) * texCoord126.x ) * float3( sin( panner134 ) ,  0.0 ) * input.normalOS * input.texcoord.w );
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
				float localFXFinalColorOutputs125_g7 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode5 = tex2D( _MainTex, uv_MainTex );
				float lerpResult98 = lerp( tex2DNode5.a , tex2DNode5.g , _Use_G_Channel_Alpha);
				float2 appendResult52 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult118 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + ( uv_NoiseTex.x * _Twist ) )));
				float2 panner49 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult52 + appendResult118);
				float temp_output_22_0 = ( ( lerpResult98 * tex2D( _NoiseTex, panner49 ).g ) - input.uv0.z );
				float2 texCoord105 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult106 = lerp( temp_output_22_0 , texCoord105.x , _ColorGradation);
				float4 lerpResult13_g10 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult106 ) * _Color_Range ) ));
				float4 lerpResult99 = lerp( ( tex2DNode5 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float4 lerpResult13_g12 = lerp( ( _Intensity_Color * lerpResult13_g10 * lerpResult99 ) , ( _LerpColor_Intensity * _LerpColor ) , saturate( ( ( _LerpColor_Offset + lerpResult106 ) * _LerpColor_Range ) ));
				float4 temp_output_193_0 = lerpResult13_g12;
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 appendResult32_g7 = (float4(temp_output_193_0.rgb , saturate( ( (temp_output_193_0).a * input.ase_color.a * ( ( temp_output_22_0 / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) * _EffectAlpha * tex2D( _MaskTex, uv_MaskTex ).g ) )));
				float4 finalColor125_g7 = appendResult32_g7;
				float4 texCoord147_g7 = input.screenPos;
				texCoord147_g7.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g7 = texCoord147_g7;
				float4 positionNDC125_g7 = ScreenPos146_g7;
				float4 texCoord140_g7 = input.fogCoord;
				texCoord140_g7.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g7 = texCoord140_g7;
				float4 fogCoord125_g7 = fogCoord139_g7;
				float3 positionWS125_g7 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g7 = normalizedWorldNormal;
				float nearPlaneAlpha125_g7 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g7 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g7 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g7 = _RaycastMinimumAlpha;
				float lightRatio125_g7 = _LightRatio;
				float lightReceive125_g7 = _LightReceive;
				float near125_g7 = _SoftParticleNearFadeDistance;
				float far125_g7 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g7 = _SoftParticleFadeOutRange;
				float softParticle125_g7 = _SoftParticle;
				float mode125_g7 = _Mode;
				float fogReceive125_g7 = _FogReceive;
				float transitionValue125_g7 = _TransitionValue;
				float spawnTransition125_g7 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g7 , positionNDC125_g7 , fogCoord125_g7 , positionWS125_g7 , normalWS125_g7 , nearPlaneAlpha125_g7 , nearPlaneInvertDistance125_g7 , raycastHarftoneClip125_g7 , raycastMinimumAlpha125_g7 , lightRatio125_g7 , lightReceive125_g7 , near125_g7 , far125_g7 , fadeOutRange125_g7 , softParticle125_g7 , mode125_g7 , fogReceive125_g7 , transitionValue125_g7 , spawnTransition125_g7 );
				float4 break64_g7 = finalColor125_g7;
				float3 appendResult76_g7 = (float3(break64_g7.x , break64_g7.y , break64_g7.z));
				
				float3 color = appendResult76_g7;
				float alpha = break64_g7.w;

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
Node;AmplifyShaderEditor.CommentaryNode;101;-1728,-128;Inherit;False;250.3594;260.6834;Switch;2;98;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1712,48;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;22;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;98;-1648,-80;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;103;-1472,-640;Inherit;False;422.6843;276.8151;Color Gradation;3;106;105;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;105;-1440,-512;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;106;-1216,-592;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-864,-304;Inherit;False;182.0251;190.676;Switch;1;99;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;560,0;Inherit;False;190;387;Rendering Options;4;107;81;82;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1440,-592;Inherit;False;Property;_ColorGradation;Color Gradation;28;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;77;320,-176;Inherit;False;MMN_CommonOutputs;5;;7;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;84;560,-176;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;20;MMN/FX/Amplify shader/FX_Dissolve_Div_VertexOffset_01;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;638472133700682453;0;1;True;False;;False;0
Node;AmplifyShaderEditor.RangedFloatNode;79;576,128;Inherit;False;Property;_BlendDst;Blend Dst;42;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;576,48;Inherit;False;Property;_BlendSrc;Blend Src;41;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;576,208;Inherit;False;Property;_CullMode;Cull Mode;43;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;576,288;Inherit;False;Property;_ZTest;Z Test;44;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;126;-928,1024;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-448,848;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-640,768;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;181;-640,848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;134;-272,992;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-448,992;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-672,1120;Inherit;False;Property;_WaveLength;WaveLength;37;0;Create;True;0;0;0;False;2;Header(Vertex Sin Wave);Space();False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-672,1408;Inherit;False;Property;_WaveSpeed;WaveSpeed;38;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;124;-672,1504;Inherit;False;MMN_Time;-1;;9;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-448,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-1280,-1152;Inherit;False;Property;_MainColor;Main Color;29;0;Create;True;0;0;0;False;0;False;0.5019608,0.5019608,0.5019608,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;29;-1280,-976;Inherit;False;Property;_SubColor;Sub Color;30;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.9292453,0.9942631,1,0.8235294;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-1248,-800;Inherit;False;Property;_Color_Offset;Color_Offset;31;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1248,-720;Inherit;False;Property;_Color_Range;Color_Range;32;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;194;-992,-800;Inherit;False;MMN_ColorLerp;0;;10;1bb351d8c3d782c43b489ac591238e71;0;5;1;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;176;-640,-1120;Inherit;False;Property;_LerpColor;Lerp Color;33;0;Create;True;0;0;0;False;2;Header(Lerp Color);Space();False;1,1,1,1;0.9292453,0.9942631,1,0.8235294;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;179;-640,-864;Inherit;False;Property;_LerpColor_Range;LerpColor_Range;35;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-640,-944;Inherit;False;Property;_LerpColor_Offset;LerpColor_Offset;34;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-640.5001,-1212.6;Inherit;False;Property;_LerpColor_Intensity;LerpColor_Intensity;36;0;Create;True;0;0;0;False;1;Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;118;-2512,16;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;114;-3008,16;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-2640,96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-2768,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2944,240;Inherit;False;Property;_Twist;Twist;26;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;52;-2512,304;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2688,304;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;24;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;-2688,384;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;25;0;Create;True;0;0;0;False;0;False;1;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;97;-2544,496;Inherit;False;MMN_Time;-1;;11;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-2048,96;Inherit;True;Property;_NoiseTex;NoiseTex;23;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;49;-2272,96;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-922.5117,-880.5875;Inherit;False;Property;_Intensity_Color;Intensity_Color;39;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-640,-768;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;99;-832,-256;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-1024,-256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;66;-1232,-48;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;384,848;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;129;176,928;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalVertexDataNode;92;160,1152;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;172;-704,1216;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;93;128,1312;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;193;-208,-768;Inherit;False;MMN_ColorLerp;0;;12;1bb351d8c3d782c43b489ac591238e71;0;5;1;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;9;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-384,-1056;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-1344,240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1536,240;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;121;160,-96;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-224,128;Inherit;False;Property;_EffectAlpha;EffectAlpha;45;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;40;-640,128;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-480,128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;0,-96;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-1600,352;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;43;-896,240;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-704,240;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;40;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;113;-320,272;Inherit;True;Property;_MaskTex;MaskTex;27;0;Create;True;0;0;0;False;2;Header(Mask Texture);Space();False;-1;None;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-2048,-128;Inherit;True;Property;_MainTex;MainTex;21;0;Create;True;0;0;0;False;5;Header(tcd0.z     Dissolve);Header(tcd0.w     VertexOffset Power);Header(tcd1.x      WaveLength Power);Header(Main Texture);Space();False;-1;None;91227f7ffeda1d840a77cc0ddc7d9298;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;46;-224,-96;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
WireConnection;98;0;5;4
WireConnection;98;1;5;2
WireConnection;98;2;100;0
WireConnection;106;0;22;0
WireConnection;106;1;105;1
WireConnection;106;2;104;0
WireConnection;77;9;193;0
WireConnection;77;28;121;0
WireConnection;84;0;77;2
WireConnection;84;1;77;26
WireConnection;84;3;86;0
WireConnection;182;0;183;0
WireConnection;182;1;181;0
WireConnection;182;2;126;1
WireConnection;181;0;126;1
WireConnection;134;0;135;0
WireConnection;134;1;136;0
WireConnection;135;0;126;1
WireConnection;135;1;131;0
WireConnection;135;2;172;1
WireConnection;136;0;137;0
WireConnection;136;1;124;0
WireConnection;194;1;35;0
WireConnection;194;3;29;0
WireConnection;194;7;26;0
WireConnection;194;8;33;0
WireConnection;194;9;106;0
WireConnection;118;0;114;1
WireConnection;118;1;117;0
WireConnection;117;0;114;2
WireConnection;117;1;116;0
WireConnection;116;0;114;1
WireConnection;116;1;115;0
WireConnection;52;0;50;0
WireConnection;52;1;119;0
WireConnection;48;1;49;0
WireConnection;49;0;118;0
WireConnection;49;2;52;0
WireConnection;49;1;97;0
WireConnection;61;0;60;0
WireConnection;61;1;194;0
WireConnection;61;2;99;0
WireConnection;99;0;94;0
WireConnection;99;1;66;0
WireConnection;99;2;100;0
WireConnection;94;0;5;0
WireConnection;94;1;66;0
WireConnection;86;0;182;0
WireConnection;86;1;129;0
WireConnection;86;2;92;0
WireConnection;86;3;93;4
WireConnection;129;0;134;0
WireConnection;193;1;192;0
WireConnection;193;3;61;0
WireConnection;193;7;175;0
WireConnection;193;8;179;0
WireConnection;193;9;106;0
WireConnection;192;0;151;0
WireConnection;192;1;176;0
WireConnection;22;0;54;0
WireConnection;22;1;24;3
WireConnection;54;0;98;0
WireConnection;54;1;48;2
WireConnection;121;0;45;0
WireConnection;40;0;22;0
WireConnection;40;1;43;0
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;45;0;46;0
WireConnection;45;1;66;4
WireConnection;45;2;41;0
WireConnection;45;3;122;0
WireConnection;45;4;113;2
WireConnection;43;0;24;3
WireConnection;46;0;193;0
ASEEND*/
//CHKSM=1B324F3BCF7D9310C0AAB1BBF3F9B138C28CDB9E