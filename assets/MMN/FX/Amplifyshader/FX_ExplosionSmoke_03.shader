// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_ExplosionSmoke_03"
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
		[Header(tcd0.z      Dissolve)][Header(tcd0.w     Emissive Dissolve)][Header(tcd1.x       AlpSub Sensitivity)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle]_Use_Polar_UV("Use_Polar_UV", Float) = 0
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		_Polar_Radial("Polar_Radial", Float) = 1
		_Polar_Lengh("Polar_Lengh", Float) = 1
		[Space()]_Alp_X_Speed("Alp_ X_Speed", Float) = 0
		_Alp_Y_Speed("Alp_Y_Speed", Float) = 0
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		[Space(10)]_Distortion_Offset("Distortion_Offset", Float) = -0.5
		[Space()]_Noise_X_Speed("Noise_X_Speed", Float) = 0
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		_Pivot("Pivot", Float) = 0.5
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[Header(Emissiv Color)][Space()]_Emissiv_MainColor("Emissiv_Main Color", Color) = (1,1,1,1)
		_Emissiv_SubColor("Emissiv_Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
		[Header(Smoke Color)][Space()]_Smoke_MainColor("Smoke_Main Color", Color) = (1,1,1,1)
		_Smoke_SubColor("Smoke_Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset2("Color_Offset2", Float) = 0
		_Color_Range2("Color_Range2", Float) = 1
		[Header(Intensity)][Space()]_Emissiv_Color("Emissiv_Color", Float) = 1
		_Emissiv_Alpha("Emissiv_Alpha", Float) = 1
		[Space()]_Smoke_Alpha("Smoke_Alpha", Float) = 1
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
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _AlphaTex;
			sampler2D _NoiseTex;
			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float4 _Smoke_MainColor;
			float4 _Smoke_SubColor;
			float4 _Emissiv_MainColor;
			float4 _Emissiv_SubColor;
			float4 _AlphaTex_ST;
			float4 _NoiseTex_ST;
			float _NearPlaneAlpha;
			float _Polar_Radial;
			float _Polar_Lengh;
			float _Noise_X_Speed;
			float _Noise_Y_Speed;
			float _Color_Range2;
			float _Emissiv_Color;
			float _Color_Offset;
			float _Color_Range;
			float _Emissiv_Alpha;
			float _Use_G_Channel_Alpha;
			float _Distortion_Offset;
			float _Alp_Y_Speed;
			float _Alp_X_Speed;
			float _Use_Polar_UV;
			float _NearPlaneInvertDistance;
			float _RaycastHarftoneClip;
			float _RaycastMinimumAlpha;
			float _LightRatio;
			float _LightReceive;
			float _SoftParticleNearFadeDistance;
			float _SoftParticleFarFadeDistance;
			float _SoftParticleFadeOutRange;
			float _SoftParticle;
			float _Mode;
			float _FogReceive;
			float _TransitionValue;
			float _SpawnTransition;
			float _Color_Offset2;
			float _Pivot;
			float _Smoke_Alpha;
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
				float4 ase_texcoord2 : TEXCOORD2;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				output.ase_color = input.color;
				output.ase_texcoord2 = input.ase_texcoord1;
				output.ase_texcoord3 = input.ase_texcoord2;
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
				float localFXFinalColorOutputs125_g10 = ( 0.0 );
				float Use_Polar337 = _Use_Polar_UV;
				float lerpResult335 = lerp( 1.0 , saturate( pow( length( ( input.uv0.xy - float2( 0.5,0.5 ) ) ) , _Pivot ) ) , Use_Polar337);
				float2 appendResult245 = (float2(_Alp_X_Speed , _Alp_Y_Speed));
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 panner247 = ( 1.0 * _Time.y * appendResult245 + uv_AlphaTex);
				float2 CenteredUV15_g11 = ( input.uv0.xy - float2( 0.5,0.5 ) );
				float2 break17_g11 = CenteredUV15_g11;
				float2 appendResult23_g11 = (float2(( length( CenteredUV15_g11 ) * _Polar_Radial * 2.0 ) , ( atan2( break17_g11.x , break17_g11.y ) * ( 1.0 / TWO_PI ) * _Polar_Lengh )));
				float2 panner244 = ( 1.0 * _Time.y * appendResult245 + appendResult23_g11);
				float2 lerpResult237 = lerp( panner247 , panner244 , _Use_Polar_UV);
				float2 appendResult181 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner180 = ( 1.0 * _Time.y * appendResult181 + uv_NoiseTex);
				float temp_output_167_0 = ( ( tex2D( _NoiseTex, panner180 ).g + _Distortion_Offset ) * input.ase_texcoord2.x );
				float Noise299 = tex2D( _AlphaTex, ( lerpResult237 + temp_output_167_0 ) ).g;
				float temp_output_223_0 = ( ( lerpResult335 * Noise299 ) - input.uv0.w );
				float4 lerpResult296 = lerp( _Smoke_SubColor , _Smoke_MainColor , saturate( ( ( _Color_Offset2 + temp_output_223_0 ) * _Color_Range2 ) ));
				float4 Smoke_Color310 = lerpResult296;
				float3 appendResult176 = (float3(input.ase_texcoord2.z , input.ase_texcoord2.w , input.ase_texcoord3.x));
				float temp_output_207_0 = ( ( lerpResult335 * Noise299 ) - input.uv0.z );
				float4 lerpResult284 = lerp( _Emissiv_SubColor , _Emissiv_MainColor , saturate( ( ( _Color_Offset + temp_output_207_0 ) * _Color_Range ) ));
				float4 Emissiv_Color309 = lerpResult284;
				float temp_output_220_0 = saturate( ( temp_output_207_0 * _Emissiv_Alpha ) );
				float4 lerpResult212 = lerp( ( input.ase_color * Smoke_Color310 ) , ( float4( appendResult176 , 0.0 ) * _Emissiv_Color * Emissiv_Color309 ) , temp_output_220_0);
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float myVarName363 = 0.0;
				float2 lerpResult360 = lerp( ( uv_MainTex + myVarName363 ) , uv_MainTex , Use_Polar337);
				float4 tex2DNode5 = tex2D( _MainTex, lerpResult360 );
				float MainTextuer_A192 = tex2DNode5.a;
				float MainTextuer_G190 = tex2DNode5.g;
				float lerpResult104 = lerp( MainTextuer_A192 , MainTextuer_G190 , _Use_G_Channel_Alpha);
				float MainTexture198 = lerpResult104;
				float lerpResult318 = lerp( (Smoke_Color310).a , (Emissiv_Color309).a , temp_output_220_0);
				float4 appendResult32_g10 = (float4(lerpResult212.rgb , ( saturate( ( MainTexture198 * saturate( temp_output_223_0 ) * lerpResult318 * _Smoke_Alpha * input.ase_color.a ) ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g10 = appendResult32_g10;
				float4 texCoord147_g10 = input.screenPos;
				texCoord147_g10.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g10 = texCoord147_g10;
				float4 positionNDC125_g10 = ScreenPos146_g10;
				float4 texCoord140_g10 = input.fogCoord;
				texCoord140_g10.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g10 = texCoord140_g10;
				float4 fogCoord125_g10 = fogCoord139_g10;
				float3 positionWS125_g10 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g10 = normalizedWorldNormal;
				float nearPlaneAlpha125_g10 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g10 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g10 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g10 = _RaycastMinimumAlpha;
				float lightRatio125_g10 = _LightRatio;
				float lightReceive125_g10 = _LightReceive;
				float near125_g10 = _SoftParticleNearFadeDistance;
				float far125_g10 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g10 = _SoftParticleFadeOutRange;
				float softParticle125_g10 = _SoftParticle;
				float mode125_g10 = _Mode;
				float fogReceive125_g10 = _FogReceive;
				float transitionValue125_g10 = _TransitionValue;
				float spawnTransition125_g10 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g10 , positionNDC125_g10 , fogCoord125_g10 , positionWS125_g10 , normalWS125_g10 , nearPlaneAlpha125_g10 , nearPlaneInvertDistance125_g10 , raycastHarftoneClip125_g10 , raycastMinimumAlpha125_g10 , lightRatio125_g10 , lightReceive125_g10 , near125_g10 , far125_g10 , fadeOutRange125_g10 , softParticle125_g10 , mode125_g10 , fogReceive125_g10 , transitionValue125_g10 , spawnTransition125_g10 );
				float4 break64_g10 = finalColor125_g10;
				float3 appendResult76_g10 = (float3(break64_g10.x , break64_g10.y , break64_g10.z));

				float3 color = appendResult76_g10;
				float alpha = break64_g10.w;

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
Node;AmplifyShaderEditor.CommentaryNode;302;-2896,18.9819;Inherit;False;2187.938;1441.303;;26;303;299;68;264;237;235;167;274;158;275;160;181;180;183;182;179;240;244;247;245;246;248;67;241;337;362;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;197;-2885.18,-673.2988;Inherit;False;982.2286;599.0385;;8;190;192;5;196;194;104;106;198;MainTexture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;97;2432,-240;Inherit;False;204;375;Rendering Options;4;101;100;98;108;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;190;-2296.421,-614.7953;Inherit;False;MainTextuer_G;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-2287.862,-533.864;Inherit;False;MainTextuer_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;-2512.563,-240.5815;Inherit;False;190;MainTextuer_G;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-2512.311,-310.9617;Inherit;False;192;MainTextuer_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;198;-2148.381,-321.9952;Inherit;False;MainTexture;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;104;-2303.311,-301.0582;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-2508.727,-156.5797;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;276;-88.86508,274.2712;Inherit;False;1098.079;616.705;2Color;9;309;277;281;283;284;282;280;279;278;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-2577.277,-539.4219;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;5;Header(tcd0.z      Dissolve);Header(tcd0.w     Emissive Dissolve);Header(tcd1.x       AlpSub Sensitivity);Header(Main Texture);Space();False;-1;a4ad7995aaa9b01478d8073a5a1e2ade;a4ad7995aaa9b01478d8073a5a1e2ade;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;290;-100.36,961.7409;Inherit;False;1108.201;611.1066;2Color;9;310;291;292;298;297;296;295;294;293;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;108;2464,48;Inherit;False;Property;_ZTest;Z Test;32;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;2464,-112;Inherit;False;Property;_BlendDst;Blend Dst;29;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;2464,-32;Inherit;False;Property;_CullMode;Cull Mode;31;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;278;119.1363,802.2712;Inherit;False;Property;_Color_Range;Color_Range;36;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;279;119.1363,690.2711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;279.136,690.2711;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;282;423.1352,690.2711;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;284;631.1353,594.2711;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;283;359.1359,322.2711;Inherit;False;Property;_Emissiv_SubColor;Emissiv_Sub Color;34;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;281;359.1359,498.2709;Inherit;False;Property;_Emissiv_MainColor;Emissiv_Main Color;33;0;Create;True;0;0;0;False;2;Header(Emissiv Color);Space();False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;293;107.6422,1377.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;294;267.6411,1377.74;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;295;411.6403,1377.74;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;-2851.223,198.9808;Inherit;False;Property;_Polar_Lengh;Polar_Lengh;21;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-2849.557,121.9135;Inherit;False;Property;_Polar_Radial;Polar_Radial;20;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-2835.32,346.2756;Inherit;False;Property;_Alp_X_Speed;Alp_ X_Speed;22;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-2835.607,430.6396;Inherit;False;Property;_Alp_Y_Speed;Alp_Y_Speed;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;245;-2632.323,394.5286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;67;-2832,560;Inherit;False;0;68;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;244;-2464,128;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;247;-2464,480;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;237;-2176,288;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;223;-109.2361,29.42197;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;297;347.6413,1009.741;Inherit;False;Property;_Smoke_SubColor;Smoke_Sub Color;38;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;298;347.6413,1185.74;Inherit;False;Property;_Smoke_MainColor;Smoke_Main Color;37;0;Create;True;0;0;0;False;2;Header(Smoke Color);Space();False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;292;108.6422,1489.741;Inherit;False;Property;_Color_Range2;Color_Range2;40;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;277;-72.86508,690.2711;Inherit;False;Property;_Color_Offset;Color_Offset;35;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;291;-84.35995,1378.74;Inherit;False;Property;_Color_Offset2;Color_Offset2;39;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;160;-1645.521,1077.794;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;275;-1527.86,864.1075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;158;-1827.051,766.289;Inherit;True;Property;_NoiseTex;NoiseTex;24;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;deb77c82677e5f24ab8089d31f577714;deb77c82677e5f24ab8089d31f577714;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;-1411.752,895.1589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;264;-1360.422,648.5948;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;68;-1247.064,770.19;Inherit;True;Property;_AlphaTex;AlphaTex;19;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;04b22506c10d2d94f983b5a17dfef117;d837d530b5931a647abf5aa9974b95c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;-941.0581,807.2478;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;303;-1843.211,639.3826;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;212;1808,-560;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;66;1424,-752;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;312;1392,-576;Inherit;False;310;Smoke_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;1632,-608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;753.9169,1280.493;Inherit;False;Smoke_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;769.0785,592.5984;Inherit;False;Emissiv_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;178;910,-472;Inherit;False;2;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;175;910,-632;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;176;1118,-536;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;286;1118,-392;Inherit;False;Property;_Emissiv_Color;Emissiv_Color;41;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;1326,-472;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;1085,-299.9471;Inherit;False;309;Emissiv_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;317;1714.696,-222.8708;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;144,-176;Inherit;False;Property;_Emissiv_Alpha;Emissiv_Alpha;42;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;352,-288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;220;496,-288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;94;2192,-384;Inherit;False;MMN_CommonOutputs;0;;10;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;101;2464,-192;Inherit;False;Property;_BlendSrc;Blend Src;28;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;103;2448,-384;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_ExplosionSmoke_03;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;1762.198,-24.085;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;2082.196,7.915015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;188;1954.198,183.9149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;1762.198,183.9149;Inherit;False;Property;_EffectAlpha;EffectAlpha;44;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;308;1938.198,23.91501;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;296;599.8875,1163.218;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;306;1215.198,151.9149;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;1007.198,151.9149;Inherit;False;310;Smoke_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;1007.198,215.915;Inherit;False;309;Emissiv_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;307;1215.198,215.915;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;1524.497,-31.58511;Inherit;False;198;MainTexture;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;321;28.50526,25.01052;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;1463.199,443.8997;Inherit;False;Property;_Smoke_Alpha;Smoke_Alpha;43;0;Create;True;0;0;0;False;1;Space();False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;318;1438.794,278.0079;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;322;-2672,128;Inherit;False;Polar Coordinates;-1;;11;7dab8e02884cf104ebefaa2e788e4162;0;4;1;FLOAT2;0,0;False;2;FLOAT2;0.5,0.5;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;207;-128.3575,-286.8159;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;-495.5828,-287.3782;Inherit;False;299;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;-2301.042,605.6611;Inherit;False;Property;_Use_Polar_UV;Use_Polar_UV;18;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;337;-2115.511,593.8256;Inherit;False;Use_Polar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;335;-440.6284,-534.5421;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;-769.6504,-398.0402;Inherit;False;337;Use_Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;24;-505.4061,-155.7017;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;301;-639.7858,60.75285;Inherit;False;299;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;328;-647.8026,-536.1224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;-226.5117,-392.6426;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;347;-279.5117,31.35736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;348;-976.3086,-606.0697;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;324;-1221.281,-636.9789;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;326;-1586.282,-615.9789;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;327;-1388.467,-615.3204;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;180;-2036.074,760.8851;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;182;-2360.906,907.8054;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;26;0;Create;True;0;0;0;False;1;Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-2360.108,989.9046;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;181;-2185.834,914.6618;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;179;-2289,759;Inherit;False;0;158;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;-1198.881,1016.327;Inherit;False;Noise2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;-3230.895,-445.5863;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;363;-3466.881,-383.6725;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3467.738,-594.2101;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;360;-2988.895,-591.5862;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;364;-3225.881,-304.6725;Inherit;False;337;Use_Polar;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-1903.786,1033.965;Inherit;False;Property;_Distortion_Offset;Distortion_Offset;25;0;Create;True;0;0;0;False;1;Space(10);False;-0.5;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-1224.706,-317.5276;Inherit;False;Property;_Pivot;Pivot;30;0;Create;True;0;0;0;False;0;False;0.5;1;0;0;0;1;FLOAT;0
WireConnection;190;0;5;2
WireConnection;192;0;5;4
WireConnection;198;0;104;0
WireConnection;104;0;196;0
WireConnection;104;1;194;0
WireConnection;104;2;106;0
WireConnection;5;1;360;0
WireConnection;279;0;277;0
WireConnection;279;1;207;0
WireConnection;280;0;279;0
WireConnection;280;1;278;0
WireConnection;282;0;280;0
WireConnection;284;0;283;0
WireConnection;284;1;281;0
WireConnection;284;2;282;0
WireConnection;293;0;291;0
WireConnection;293;1;223;0
WireConnection;294;0;293;0
WireConnection;294;1;292;0
WireConnection;295;0;294;0
WireConnection;245;0;248;0
WireConnection;245;1;246;0
WireConnection;244;0;322;0
WireConnection;244;2;245;0
WireConnection;247;0;67;0
WireConnection;247;2;245;0
WireConnection;237;0;247;0
WireConnection;237;1;244;0
WireConnection;237;2;235;0
WireConnection;223;0;347;0
WireConnection;223;1;24;4
WireConnection;275;0;158;2
WireConnection;275;1;274;0
WireConnection;158;1;180;0
WireConnection;167;0;275;0
WireConnection;167;1;160;1
WireConnection;264;0;303;0
WireConnection;264;1;167;0
WireConnection;68;1;264;0
WireConnection;299;0;68;2
WireConnection;303;0;237;0
WireConnection;212;0;304;0
WireConnection;212;1;287;0
WireConnection;212;2;317;0
WireConnection;304;0;66;0
WireConnection;304;1;312;0
WireConnection;310;0;296;0
WireConnection;309;0;284;0
WireConnection;176;0;175;3
WireConnection;176;1;175;4
WireConnection;176;2;178;1
WireConnection;287;0;176;0
WireConnection;287;1;286;0
WireConnection;287;2;311;0
WireConnection;317;0;220;0
WireConnection;219;0;207;0
WireConnection;219;1;221;0
WireConnection;220;0;219;0
WireConnection;94;9;212;0
WireConnection;94;28;187;0
WireConnection;103;0;94;2
WireConnection;103;1;94;26
WireConnection;231;0;232;0
WireConnection;231;1;321;0
WireConnection;231;2;318;0
WireConnection;231;3;229;0
WireConnection;231;4;66;4
WireConnection;187;0;308;0
WireConnection;187;1;188;0
WireConnection;188;0;189;0
WireConnection;308;0;231;0
WireConnection;296;0;297;0
WireConnection;296;1;298;0
WireConnection;296;2;295;0
WireConnection;306;0;314;0
WireConnection;307;0;313;0
WireConnection;321;0;223;0
WireConnection;318;0;306;0
WireConnection;318;1;307;0
WireConnection;318;2;220;0
WireConnection;322;3;240;0
WireConnection;322;4;241;0
WireConnection;207;0;345;0
WireConnection;207;1;24;3
WireConnection;337;0;235;0
WireConnection;335;1;328;0
WireConnection;335;2;338;0
WireConnection;328;0;348;0
WireConnection;345;0;335;0
WireConnection;345;1;300;0
WireConnection;347;0;335;0
WireConnection;347;1;301;0
WireConnection;348;0;324;0
WireConnection;348;1;341;0
WireConnection;324;0;327;0
WireConnection;327;0;326;0
WireConnection;180;0;179;0
WireConnection;180;2;181;0
WireConnection;181;0;182;0
WireConnection;181;1;183;0
WireConnection;362;0;167;0
WireConnection;361;0;6;0
WireConnection;361;1;363;0
WireConnection;360;0;361;0
WireConnection;360;1;6;0
WireConnection;360;2;364;0
ASEEND*/
//CHKSM=4A60B207973356EDE317CDE23F79EC48D20175EC