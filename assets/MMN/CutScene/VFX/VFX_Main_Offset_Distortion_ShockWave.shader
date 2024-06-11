// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/CutScene/VFX/VFX_Main_Offset_Distortion_ShockWave"
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
		[Header(tcd1.x     MainTex_X_Offset)][Header(tcd1.y     MainTex_Y_Offset)][Header(tcd1.z     Dissolve)][Header(tcd1.w     Distortion)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[HDR][Header(Color)][Space()]_Main_Color("Main_Color", Color) = (1,1,1,1)
		[HDR]_Sub_Color("Sub_Color", Color) = (0.5,0.5,0.5,1)
		_Color_Offset("Color_Offset", Float) = 1
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
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
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _Main_Color;
			float4 _Sub_Color;
			float4 _MaskTex_ST;
			float _NearPlaneAlpha;
			float _Intensity_Color;
			float _Color_Range;
			float _Color_Offset;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _SpawnTransition;
			float _TransitionValue;
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
			float _FogReceive;
			float _Intensity_Alpha;
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

				output.ase_texcoord2 = input.ase_texcoord1;
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
				float localFXFinalColorOutputs125_g36 = ( 0.0 );
				float2 appendResult14 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner13 = ( 1.0 * _Time.y * appendResult14 + uv_NoiseTex);
				float4 tex2DNode8 = tex2D( _NoiseTex, panner13 );
				float2 appendResult11 = (float2(tex2DNode8.r , tex2DNode8.g));
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult18 = (float2(( uv_MainTex.x + input.ase_texcoord2.x ) , ( uv_MainTex.y + input.ase_texcoord2.y )));
				float4 tex2DNode9 = tex2D( _MainTex, ( ( appendResult11 * input.ase_texcoord2.w ) + appendResult18 ) );
				float4 lerpResult43 = lerp( _Sub_Color , _Main_Color , saturate( ( saturate( pow( tex2DNode9.g , _Color_Offset ) ) * _Color_Range ) ));
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float4 appendResult32_g36 = (float4(( ( lerpResult43 * _Intensity_Color ) * input.ase_color ).rgb , ( input.ase_color.a * saturate( ( saturate( ( ( tex2DNode8.r + input.ase_texcoord2.z ) * tex2D( _MaskTex, uv_MaskTex ).r * tex2DNode9.g ) ) * _Intensity_Alpha ) ) )));
				float4 finalColor125_g36 = appendResult32_g36;
				float4 texCoord147_g36 = input.screenPos;
				texCoord147_g36.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g36 = texCoord147_g36;
				float4 positionNDC125_g36 = ScreenPos146_g36;
				float4 texCoord140_g36 = input.fogCoord;
				texCoord140_g36.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g36 = texCoord140_g36;
				float4 fogCoord125_g36 = fogCoord139_g36;
				float3 positionWS125_g36 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g36 = normalizedWorldNormal;
				float nearPlaneAlpha125_g36 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g36 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g36 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g36 = _RaycastMinimumAlpha;
				float lightRatio125_g36 = _LightRatio;
				float lightReceive125_g36 = _LightReceive;
				float near125_g36 = _SoftParticleNearFadeDistance;
				float far125_g36 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g36 = _SoftParticleFadeOutRange;
				float softParticle125_g36 = _SoftParticle;
				float mode125_g36 = _Mode;
				float fogReceive125_g36 = _FogReceive;
				float transitionValue125_g36 = _TransitionValue;
				float spawnTransition125_g36 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g36 , positionNDC125_g36 , fogCoord125_g36 , positionWS125_g36 , normalWS125_g36 , nearPlaneAlpha125_g36 , nearPlaneInvertDistance125_g36 , raycastHarftoneClip125_g36 , raycastMinimumAlpha125_g36 , lightRatio125_g36 , lightReceive125_g36 , near125_g36 , far125_g36 , fadeOutRange125_g36 , softParticle125_g36 , mode125_g36 , fogReceive125_g36 , transitionValue125_g36 , spawnTransition125_g36 );
				float4 break64_g36 = finalColor125_g36;
				float3 appendResult76_g36 = (float3(break64_g36.x , break64_g36.y , break64_g36.z));

				float3 color = appendResult76_g36;
				float alpha = break64_g36.w;

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
Node;AmplifyShaderEditor.CommentaryNode;2;808.0756,43.37338;Inherit;False;204;375;Rendering Options;4;6;5;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;840.0756,171.3734;Inherit;False;Property;_BlendDst;Blend Dst;30;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;840.0756,331.3734;Inherit;False;Property;_ZTest;Z Test;28;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;840.0756,251.3734;Inherit;False;Property;_CullMode;Cull Mode;31;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;18;-1815.73,-290.116;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;-1607.73,-320.116;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1981.73,-276.116;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1970.73,-170.116;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-2522.377,-661.853;Inherit;True;Property;_NoiseTex;NoiseTex;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;13;-2751.331,-634.0158;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-2949.331,-453.0159;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;11;-2223.33,-636.0158;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1841.236,-567.1761;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2248.107,-382.1143;Inherit;False;Property;_Noise_Strength;Noise_Strength;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;20;-2291.73,-106.116;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;25;-923.1069,-439.1143;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-759.0922,-435.1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-576.1069,-437.1143;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;42;-416.0922,-439.1552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-654.0922,-886.1552;Inherit;False;Property;_Sub_Color;Sub_Color;23;1;[HDR];Create;True;0;0;0;False;0;False;0.5,0.5,0.5,1;0.5,0.5,0.5,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;29;-1087.23,-344.3341;Inherit;False;Property;_Color_Offset;Color_Offset;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;-243.0922,-728.1552;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-760.2305,-341.3341;Inherit;False;Property;_Color_Range;Color_Range;25;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;46.46979,-596.8709;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;705.5893,-251.7935;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;16;MMN/CutScene/VFX/VFX_Main_Offset_Distortion_ShockWave;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.FunctionNode;7;428.2896,-247.4354;Inherit;False;MMN_CommonOutputs;0;;36;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,0,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-947.3534,-46.52815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;33;-1264,-43.46889;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-750.3071,72.45262;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-278.3387,103.1181;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;36;-472.3388,98.11805;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;37;-97.33862,105.1181;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;47;46.74355,-268.4415;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;258.9113,-361.9421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;263.9113,-107.9421;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-2270.73,-270.116;Inherit;False;0;9;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;12;-3020.331,-641.0158;Inherit;False;0;8;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-1226.997,183.8816;Inherit;True;Property;_MaskTex;MaskTex;21;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-1512.492,204.0073;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-516.3387,223.1181;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;27;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;840.0756,91.37338;Inherit;False;Property;_BlendSrc;Blend Src;29;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-655.0922,-654.1552;Inherit;False;Property;_Main_Color;Main_Color;22;1;[HDR];Create;True;0;0;0;False;3;Header(Color);Space();;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-178.8147,-459.3893;Inherit;False;Property;_Intensity_Color;Intensity_Color;26;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-3161.331,-450.0159;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3141.331,-360.0159;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-1365.848,-347.0565;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;5;;;;;;0;0;False;6;Header(tcd1.x     MainTex_X_Offset);Header(tcd1.y     MainTex_Y_Offset);Header(tcd1.z     Dissolve);Header(tcd1.w     Distortion);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;18;0;21;0
WireConnection;18;1;22;0
WireConnection;17;0;23;0
WireConnection;17;1;18;0
WireConnection;21;0;19;1
WireConnection;21;1;20;1
WireConnection;22;0;19;2
WireConnection;22;1;20;2
WireConnection;8;1;13;0
WireConnection;13;0;12;0
WireConnection;13;2;14;0
WireConnection;14;0;15;0
WireConnection;14;1;16;0
WireConnection;11;0;8;1
WireConnection;11;1;8;2
WireConnection;23;0;11;0
WireConnection;23;1;20;4
WireConnection;25;0;9;2
WireConnection;25;1;29;0
WireConnection;41;0;25;0
WireConnection;26;0;41;0
WireConnection;26;1;30;0
WireConnection;42;0;26;0
WireConnection;43;0;40;0
WireConnection;43;1;44;0
WireConnection;43;2;42;0
WireConnection;45;0;43;0
WireConnection;45;1;46;0
WireConnection;1;0;7;2
WireConnection;1;1;7;26
WireConnection;7;9;48;0
WireConnection;7;28;49;0
WireConnection;31;0;8;1
WireConnection;31;1;33;3
WireConnection;28;0;31;0
WireConnection;28;1;10;1
WireConnection;28;2;9;2
WireConnection;35;0;36;0
WireConnection;35;1;38;0
WireConnection;36;0;28;0
WireConnection;37;0;35;0
WireConnection;48;0;45;0
WireConnection;48;1;47;0
WireConnection;49;0;47;4
WireConnection;49;1;37;0
WireConnection;10;1;50;0
WireConnection;9;1;17;0
ASEEND*/
//CHKSM=CF40C1D7EF1727DE0C75DBE6F1D39C55719BA9CD