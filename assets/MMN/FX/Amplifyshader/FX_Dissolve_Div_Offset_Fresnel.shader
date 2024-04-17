// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_Offset_Fresnel"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.wlx     MainTex Offset)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		[Toggle]_Fresnel_OneMinus("Fresnel_One Minus", Float) = 0
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		[Header(Noise Texture)][Space()]_NoiseTex("NoiseTex", 2D) = "white" {}
		_Noise_X_Speed("Noise_X_Speed", Float) = 1
		_Noise_Y_Speed("Noise_Y_Speed", Float) = 1
		_DefaultValues("Default Values", Float) = 0
		[Header(Fresnel)][Space(5)]_RimMin("RimMin", Range( 0 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 1)) = 1
		_Twist("Twist", Float) = 0
		[Enum(Alpha,0,UV,1)][Header(Color)][Space()]_ColorGradation("Color Gradation", Float) = 0
		_MainColor("Main Color", Color) = (1,1,1,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		_Color_Range("Color_Range", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		_Intensity_Alpha("Intensity_Alpha", Float) = 1
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


			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaTex_ST;
			float4 _NoiseTex_ST;
			float4 _MainColor;
			float4 _SubColor;
			float4 _MainTex_ST;
			float _NearPlaneAlpha;
			float _Color_Range;
			float _ColorGradation;
			float _DefaultValues;
			float _Fresnel_OneMinus;
			float _RimMax;
			float _RimMin;
			float _Twist;
			float _Noise_Y_Speed;
			float _Noise_X_Speed;
			float _Color_Offset;
			float _Use_G_Channel_Alpha;
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
			float _Intensity_Alpha;
			float _EffectAlpha;
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
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

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
				float localFXFinalColorOutputs125_g14 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 appendResult407 = (float2(input.uv0.w , 0.0));
				float4 tex2DNode418 = tex2D( _MainTex, ( uv_MainTex + appendResult407 ) );
				float4 lerpResult446 = lerp( ( tex2DNode418 * input.ase_color ) , input.ase_color , _Use_G_Channel_Alpha);
				float lerpResult421 = lerp( tex2DNode418.a , tex2DNode418.g , _Use_G_Channel_Alpha);
				float2 appendResult414 = (float2(_Noise_X_Speed , _Noise_Y_Speed));
				float2 uv_NoiseTex = input.uv0.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 appendResult413 = (float2(uv_NoiseTex.x , ( uv_NoiseTex.y + ( uv_NoiseTex.x * _Twist ) )));
				float2 panner417 = ( ( frac( ( _TimeParameters.x * 0.001 ) ) * 1000.0 ) * appendResult414 + appendResult413);
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult231 = dot( input.normalWS , ase_worldViewDir );
				float smoothstepResult232 = smoothstep( _RimMin , _RimMax , dotResult231);
				float Fresmel347 = smoothstepResult232;
				float lerpResult455 = lerp( Fresmel347 , ( 1.0 - Fresmel347 ) , _Fresnel_OneMinus);
				float temp_output_464_0 = saturate( ( input.uv0.z + _DefaultValues ) );
				float temp_output_428_0 = ( ( lerpResult421 * tex2D( _NoiseTex, panner417 ).g * tex2D( _AlphaTex, uv_AlphaTex ).g * lerpResult455 ) - temp_output_464_0 );
				float2 texCoord426 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult430 = lerp( temp_output_428_0 , texCoord426.x , _ColorGradation);
				float4 lerpResult442 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + lerpResult430 ) * _Color_Range ) ));
				float4 appendResult32_g14 = (float4(( _Intensity_Color * lerpResult446 * lerpResult442 ).rgb , ( ( input.ase_color.a * saturate( ( ( temp_output_428_0 / ( ( 1.0 - temp_output_464_0 ) + 0.0001 ) ) * _Intensity_Alpha ) ) * (lerpResult442).a ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g14 = appendResult32_g14;
				float4 texCoord147_g14 = input.screenPos;
				texCoord147_g14.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g14 = texCoord147_g14;
				float4 positionNDC125_g14 = ScreenPos146_g14;
				float4 texCoord140_g14 = input.fogCoord;
				texCoord140_g14.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g14 = texCoord140_g14;
				float4 fogCoord125_g14 = fogCoord139_g14;
				float3 positionWS125_g14 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g14 = normalizedWorldNormal;
				float nearPlaneAlpha125_g14 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g14 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g14 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g14 = _RaycastMinimumAlpha;
				float lightRatio125_g14 = _LightRatio;
				float lightReceive125_g14 = _LightReceive;
				float near125_g14 = _SoftParticleNearFadeDistance;
				float far125_g14 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g14 = _SoftParticleFadeOutRange;
				float softParticle125_g14 = _SoftParticle;
				float mode125_g14 = _Mode;
				float fogReceive125_g14 = _FogReceive;
				float transitionValue125_g14 = _TransitionValue;
				float spawnTransition125_g14 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g14 , positionNDC125_g14 , fogCoord125_g14 , positionWS125_g14 , normalWS125_g14 , nearPlaneAlpha125_g14 , nearPlaneInvertDistance125_g14 , raycastHarftoneClip125_g14 , raycastMinimumAlpha125_g14 , lightRatio125_g14 , lightReceive125_g14 , near125_g14 , far125_g14 , fadeOutRange125_g14 , softParticle125_g14 , mode125_g14 , fogReceive125_g14 , transitionValue125_g14 , spawnTransition125_g14 );
				float4 break64_g14 = finalColor125_g14;
				float3 appendResult76_g14 = (float3(break64_g14.x , break64_g14.y , break64_g14.z));

				float3 color = appendResult76_g14;
				float alpha = break64_g14.w;

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
Node;AmplifyShaderEditor.WorldNormalVector;229;526.2099,2072.473;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;404;177.7608,1665.351;Inherit;False;Property;_Twist;Twist;26;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;403;95.30081,1393.211;Inherit;False;0;422;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;234;630.2833,2488.93;Inherit;False;Property;_RimMax;RimMax;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;610.5522,2392.693;Inherit;False;Property;_RimMin;RimMin;24;0;Create;True;0;0;0;False;2;Header(Fresnel);Space(5);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;405;337.7608,1665.351;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;231;710.2634,2100.402;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;410;489.3008,1753.211;Inherit;False;Property;_Noise_X_Speed;Noise_X_Speed;21;0;Create;True;0;0;0;False;0;False;1;-0.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;232;953.7593,2172.206;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;408;489.3008,1833.211;Inherit;False;Property;_Noise_Y_Speed;Noise_Y_Speed;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;409;481.7608,1617.351;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;413;626.7608,1461.351;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;412;1277.816,1030.773;Inherit;False;238.7762;259.8605;Switch;2;421;419;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;414;665.3008,1753.211;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;415;695.3218,1877.273;Inherit;False;MMN_Time;-1;;13;0b8d84477b7a4ee4a9eab0aed6158b6e;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;347;1166.801,2167.144;Inherit;False;Fresmel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;417;857.3008,1625.211;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;454;1174.609,2700.478;Inherit;False;Property;_Fresnel_OneMinus;Fresnel_One Minus;18;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;453;1260.178,2312.221;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;455;1536.21,2170.778;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;420;1065.759,1718.773;Inherit;True;Property;_AlphaTex;AlphaTex;19;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;422;1078.759,1278.773;Inherit;True;Property;_NoiseTex;NoiseTex;20;0;Create;True;0;0;0;False;2;Header(Noise Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;423;985.7591,486.7732;Inherit;False;422.6843;276.8151;Color Gradation;3;430;427;426;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;424;1654.759,1310.773;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;427;1017.759,534.7733;Inherit;False;Property;_ColorGradation;Color Gradation;27;1;[Enum];Create;True;2;Header(Color);Space();2;Alpha;0;UV;1;0;False;2;Header(Color);Space();False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;426;1017.759,614.7733;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;428;1854.735,1229.093;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;429;1431.736,194.8563;Inherit;False;873.9635;616.705;2Color;8;442;440;439;438;435;433;432;431;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;430;1241.759,534.7733;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;431;1447.736,610.8558;Inherit;False;Property;_Color_Offset;Color_Offset;31;0;Create;True;0;0;0;False;1;Space(5);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;434;1878.759,1422.773;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;458;1904.426,1755.238;Inherit;False;Constant;_Float2;Float 0;23;0;Create;True;0;0;0;False;0;False;0.0001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;1639.736,722.856;Inherit;False;Property;_Color_Range;Color_Range;33;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;432;1639.736,610.8558;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;457;2036.426,1520.238;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;435;1799.736,610.8558;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;437;2001.592,1088.351;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;436;2102.759,1310.773;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;438;1879.736,242.8563;Inherit;False;Property;_SubColor;Sub Color;29;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;441;2102.759,1422.773;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;37;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;439;1943.736,610.8558;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;440;1879.736,418.8558;Inherit;False;Property;_MainColor;Main Color;28;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;442;2151.736,514.8558;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;445;2291.759,1311.773;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;443;2006.397,922.0243;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;444;2169.735,870.6019;Inherit;False;187.9032;189.0854;Switch;1;446;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;448;2450.501,549.6831;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;449;2417.735,697.9764;Inherit;False;Property;_Intensity_Color;Intensity_Color;34;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;447;2470.759,1310.773;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;446;2198.397,920.6019;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;451;2646.759,1310.773;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;450;2653.152,1108.752;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;77;3374.185,1311.773;Inherit;False;204;375;Rendering Options;4;81;80;78;402;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;81;3406.185,1439.773;Inherit;False;Property;_BlendDst;Blend Dst;32;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;3407.283,1519.773;Inherit;False;Property;_CullMode;Cull Mode;35;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;402;3408,1600;Inherit;False;Property;_ZTest;Z Test;36;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;3406.185,1359.773;Inherit;False;Property;_BlendSrc;Blend Src;30;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;401;3350.406,1096.11;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Dissolve_Div_Offset_Fresnel;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;8;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SaturateNode;460;2811.064,1517.036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;461;2622.064,1519.036;Inherit;False;Property;_EffectAlpha;EffectAlpha;38;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;2938.564,1343.036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;452;3086.594,1106.685;Inherit;False;MMN_CommonOutputs;0;;14;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;230;528.4008,2221.135;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;419;1297.759,1206.773;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;421;1377.759,1078.773;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;406;249.44,1152.979;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;407;498.44,1162.979;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;658.4401,1034.979;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;418;799.4401,1026.979;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.wlx     MainTex Offset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;411;261.8291,1008.493;Inherit;False;0;418;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;464;1758.638,1540.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;463;1487.261,1718.841;Inherit;False;Property;_DefaultValues;Default Values;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;462;1678.261,1673.841;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;425;1437.359,1509.674;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;405;0;403;1
WireConnection;405;1;404;0
WireConnection;231;0;229;0
WireConnection;231;1;230;0
WireConnection;232;0;231;0
WireConnection;232;1;233;0
WireConnection;232;2;234;0
WireConnection;409;0;403;2
WireConnection;409;1;405;0
WireConnection;413;0;403;1
WireConnection;413;1;409;0
WireConnection;414;0;410;0
WireConnection;414;1;408;0
WireConnection;347;0;232;0
WireConnection;417;0;413;0
WireConnection;417;2;414;0
WireConnection;417;1;415;0
WireConnection;453;0;347;0
WireConnection;455;0;347;0
WireConnection;455;1;453;0
WireConnection;455;2;454;0
WireConnection;422;1;417;0
WireConnection;424;0;421;0
WireConnection;424;1;422;2
WireConnection;424;2;420;2
WireConnection;424;3;455;0
WireConnection;428;0;424;0
WireConnection;428;1;464;0
WireConnection;430;0;428;0
WireConnection;430;1;426;1
WireConnection;430;2;427;0
WireConnection;434;0;464;0
WireConnection;432;0;431;0
WireConnection;432;1;430;0
WireConnection;457;0;434;0
WireConnection;457;1;458;0
WireConnection;435;0;432;0
WireConnection;435;1;433;0
WireConnection;436;0;428;0
WireConnection;436;1;457;0
WireConnection;439;0;435;0
WireConnection;442;0;438;0
WireConnection;442;1;440;0
WireConnection;442;2;439;0
WireConnection;445;0;436;0
WireConnection;445;1;441;0
WireConnection;443;0;418;0
WireConnection;443;1;437;0
WireConnection;448;0;442;0
WireConnection;447;0;445;0
WireConnection;446;0;443;0
WireConnection;446;1;437;0
WireConnection;446;2;419;0
WireConnection;451;0;437;4
WireConnection;451;1;447;0
WireConnection;451;2;448;0
WireConnection;450;0;449;0
WireConnection;450;1;446;0
WireConnection;450;2;442;0
WireConnection;401;0;452;2
WireConnection;401;1;452;26
WireConnection;460;0;461;0
WireConnection;459;0;451;0
WireConnection;459;1;460;0
WireConnection;452;9;450;0
WireConnection;452;28;459;0
WireConnection;421;0;418;4
WireConnection;421;1;418;2
WireConnection;421;2;419;0
WireConnection;407;0;406;4
WireConnection;416;0;411;0
WireConnection;416;1;407;0
WireConnection;418;1;416;0
WireConnection;464;0;462;0
WireConnection;462;0;425;3
WireConnection;462;1;463;0
ASEEND*/
//CHKSM=4B0AA3B33ADAD520E499544516695E18B139049C