// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_Dissolve_Div_2C_FakeHeight"
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
		[Header(tcd0.z     Dissolve)][Header(tcd0.wlx     AlphaTex Offset)][Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_Use_G_Channel_Alpha("Use_G_Channel_Alpha", Float) = 0
		_ParallaxScale("Parallax Scale", Range( -0.5 , 0)) = -0.05
		[Header(Alpha Texture)][Space()]_AlphaTex("AlphaTex", 2D) = "white" {}
		[Header(Color)][Space()]_MainColor("Main Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_SubColor("Sub Color", Color) = (1,1,1,1)
		[Space(5)]_Color_Offset("Color_Offset", Float) = 0
		_Color_Range("Color_Range", Float) = 1
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
			#define ASE_NEEDS_VERT_TANGENT
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _AlphaTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _AlphaTex_ST;
			float4 _MainTex_ST;
			float4 _MainColor;
			float4 _SubColor;
			float _NearPlaneAlpha;
			float _Color_Range;
			float _ParallaxScale;
			float _Use_G_Channel_Alpha;
			float _Color_Offset;
			float _Intensity_Color;
			float _SpawnTransition;
			float _Intensity_Alpha;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float3 ase_worldTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
				output.ase_texcoord2.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(input.normalOS);
				float ase_vertexTangentSign = input.tangentOS.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				output.ase_texcoord3.xyz = ase_worldBitangent;

				output.ase_color = input.color;

				//setting value to unused interpolator channels and avoid initialization warnings
				output.ase_texcoord2.w = 0;
				output.ase_texcoord3.w = 0;
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
				float localFXFinalColorOutputs125_g6 = ( 0.0 );
				float2 uv_MainTex = input.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode147 = tex2D( _MainTex, uv_MainTex );
				float lerpResult164 = lerp( tex2DNode147.a , tex2DNode147.g , _Use_G_Channel_Alpha);
				float3 ase_worldTangent = input.ase_texcoord2.xyz;
				float3 ase_worldBitangent = input.ase_texcoord3.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, input.normalWS.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, input.normalWS.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, input.normalWS.z );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 uv_AlphaTex = input.uv0.xy * _AlphaTex_ST.xy + _AlphaTex_ST.zw;
				float2 appendResult153 = (float2(input.uv0.w , 0.0));
				float4 tex2DNode143 = tex2D( _AlphaTex, ( uv_AlphaTex + appendResult153 ) );
				float4 tex2DNode150 = tex2D( _MainTex, ( ( lerpResult164 * _ParallaxScale * ase_tanViewDir * tex2DNode143.g ) + float3( uv_MainTex ,  0.0 ) ).xy );
				float lerpResult165 = lerp( tex2DNode150.a , tex2DNode150.g , _Use_G_Channel_Alpha);
				float4 lerpResult134 = lerp( _SubColor , _MainColor , saturate( ( ( _Color_Offset + ( ( lerpResult165 * tex2DNode143.g ) - input.uv0.z ) ) * _Color_Range ) ));
				float4 lerpResult166 = lerp( ( lerpResult134 * tex2DNode150 ) , lerpResult134 , _Use_G_Channel_Alpha);
				float4 appendResult32_g6 = (float4(( _Intensity_Color * lerpResult166 * input.ase_color ).rgb , ( ( saturate( ( ( ( ( lerpResult164 * tex2DNode143.g ) - input.uv0.z ) / ( 1.0 - input.uv0.z ) ) * _Intensity_Alpha ) ) * input.ase_color.a * (lerpResult134).a ) * saturate( _EffectAlpha ) )));
				float4 finalColor125_g6 = appendResult32_g6;
				float4 texCoord147_g6 = input.screenPos;
				texCoord147_g6.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g6 = texCoord147_g6;
				float4 positionNDC125_g6 = ScreenPos146_g6;
				float4 texCoord140_g6 = input.fogCoord;
				texCoord140_g6.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g6 = texCoord140_g6;
				float4 fogCoord125_g6 = fogCoord139_g6;
				float3 positionWS125_g6 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g6 = normalizedWorldNormal;
				float nearPlaneAlpha125_g6 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g6 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g6 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g6 = _RaycastMinimumAlpha;
				float lightRatio125_g6 = _LightRatio;
				float lightReceive125_g6 = _LightReceive;
				float near125_g6 = _SoftParticleNearFadeDistance;
				float far125_g6 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g6 = _SoftParticleFadeOutRange;
				float softParticle125_g6 = _SoftParticle;
				float mode125_g6 = _Mode;
				float fogReceive125_g6 = _FogReceive;
				float transitionValue125_g6 = _TransitionValue;
				float spawnTransition125_g6 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g6 , positionNDC125_g6 , fogCoord125_g6 , positionWS125_g6 , normalWS125_g6 , nearPlaneAlpha125_g6 , nearPlaneInvertDistance125_g6 , raycastHarftoneClip125_g6 , raycastMinimumAlpha125_g6 , lightRatio125_g6 , lightReceive125_g6 , near125_g6 , far125_g6 , fadeOutRange125_g6 , softParticle125_g6 , mode125_g6 , fogReceive125_g6 , transitionValue125_g6 , spawnTransition125_g6 );
				float4 break64_g6 = finalColor125_g6;
				float3 appendResult76_g6 = (float3(break64_g6.x , break64_g6.y , break64_g6.z));

				float3 color = appendResult76_g6;
				float alpha = break64_g6.w;

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
Node;AmplifyShaderEditor.TexCoordVertexDataNode;144;-3072,320;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-3136,-80;Inherit;False;0;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;146;-3072,192;Inherit;False;0;143;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;153;-2848,496;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;171;-2463.621,-236;Inherit;False;247.3999;295.4105;Switch;2;168;164;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;147;-2912,-80;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;4;Header(tcd0.z     Dissolve);Header(tcd0.wlx     AlphaTex Offset);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-2736,160;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-2438.321,-37.08946;Inherit;False;Property;_Use_G_Channel_Alpha;Use_G_Channel_Alpha;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;143;-2608,160;Inherit;True;Property;_AlphaTex;AlphaTex;19;0;Create;True;0;0;0;False;2;Header(Alpha Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;115;-2512,-528;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;164;-2374,-186;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2624,-608;Inherit;False;Property;_ParallaxScale;Parallax Scale;18;0;Create;True;0;0;0;False;0;False;-0.05;-0.03;-0.5;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-2256,-608;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;118;-2256,-448;Inherit;False;0;147;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-2080,-608;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;170;-1588,-450;Inherit;False;171;178;Switch;1;165;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;150;-1936,-624;Inherit;True;Property;_TextureSample0;Texture Sample 0;16;0;Create;True;0;0;0;False;3;Header(tcd0.z     Dissolve);Header(Main Texture);Space();False;-1;None;None;True;0;False;white;Auto;False;Instance;147;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;165;-1568,-400;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1388.66,-400;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;122;-1456,352;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;123;-1200.234,-682.5151;Inherit;False;Property;_Color_Offset;Color_Offset;22;0;Create;True;0;0;0;False;1;Space(5);False;0;-0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;124;-1184.234,-810.5151;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;-1024.234,-810.5151;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1024.234,-698.5151;Inherit;False;Property;_Color_Range;Color_Range;23;0;Create;True;0;0;0;False;0;False;1;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;-1440,80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-864.2339,-810.5151;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;-848.2339,-1210.515;Inherit;False;Property;_SubColor;Sub Color;21;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;133;-848.2339,-1002.515;Inherit;False;Property;_MainColor;Main Color;20;0;Create;True;0;0;0;False;2;Header(Color);Space();False;0.5019608,0.5019608,0.5019608,1;0,0.5344336,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;157;-1232,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;127;-1200,416;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;130;-720.2339,-810.5151;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;132;-1008,80;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;134;-576.2339,-906.5151;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;131;-1008,192;Inherit;False;Property;_Intensity_Alpha;Intensity_Alpha;25;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;169;-232.652,-401.7209;Inherit;False;155.8086;173.2852;Switch;1;166;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-800,80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;-528,-432;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;138;-224,-16;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;137;-656,80;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;139;-153.3807,-527.7629;Inherit;False;Property;_Intensity_Color;Intensity_Color;24;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;136;-144,-208;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;166;-218.3667,-351.7209;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;32,0;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;48,-384;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;76;466.8058,-15.3958;Inherit;False;204;375;Rendering Options;3;79;78;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;77;497.8061,112.6044;Inherit;False;Property;_BlendDst;Blend Dst;27;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;498.8062,192.6046;Inherit;False;Property;_CullMode;Cull Mode;28;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;496,272;Inherit;False;Property;_ZTest;Z Test;29;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;498.8062,32.6042;Inherit;False;Property;_BlendSrc;Blend Src;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;112;209.0196,-170.6923;Inherit;False;MMN_CommonOutputs;0;;6;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;491.5001,-193.2001;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/FX/Amplify shader/FX_Dissolve_Div_2C_FakeHeight;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;203.6666,59.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;174;77.16653,231.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-111.8335,233.5;Inherit;False;Property;_EffectAlpha;EffectAlpha;30;1;[HideInInspector];Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;153;0;144;4
WireConnection;147;1;149;0
WireConnection;151;0;146;0
WireConnection;151;1;153;0
WireConnection;143;1;151;0
WireConnection;164;0;147;4
WireConnection;164;1;147;2
WireConnection;164;2;168;0
WireConnection;117;0;164;0
WireConnection;117;1;114;0
WireConnection;117;2;115;0
WireConnection;117;3;143;2
WireConnection;119;0;117;0
WireConnection;119;1;118;0
WireConnection;150;1;119;0
WireConnection;165;0;150;4
WireConnection;165;1;150;2
WireConnection;165;2;168;0
WireConnection;142;0;165;0
WireConnection;142;1;143;2
WireConnection;124;0;142;0
WireConnection;124;1;122;3
WireConnection;126;0;123;0
WireConnection;126;1;124;0
WireConnection;159;0;164;0
WireConnection;159;1;143;2
WireConnection;128;0;126;0
WireConnection;128;1;125;0
WireConnection;157;0;159;0
WireConnection;157;1;122;3
WireConnection;127;0;122;3
WireConnection;130;0;128;0
WireConnection;132;0;157;0
WireConnection;132;1;127;0
WireConnection;134;0;129;0
WireConnection;134;1;133;0
WireConnection;134;2;130;0
WireConnection;135;0;132;0
WireConnection;135;1;131;0
WireConnection;161;0;134;0
WireConnection;161;1;150;0
WireConnection;138;0;134;0
WireConnection;137;0;135;0
WireConnection;166;0;161;0
WireConnection;166;1;134;0
WireConnection;166;2;168;0
WireConnection;141;0;137;0
WireConnection;141;1;136;4
WireConnection;141;2;138;0
WireConnection;140;0;139;0
WireConnection;140;1;166;0
WireConnection;140;2;136;0
WireConnection;112;9;140;0
WireConnection;112;28;173;0
WireConnection;97;0;112;2
WireConnection;97;1;112;26
WireConnection;173;0;141;0
WireConnection;173;1;174;0
WireConnection;174;0;175;0
ASEEND*/
//CHKSM=EA5BAD2D476119CCFED8CD6A30B833675E982473