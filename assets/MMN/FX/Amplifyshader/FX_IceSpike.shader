// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "MMN/FX/Amplify shader/FX_IceSpike"
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
		[HideInInspector]_WorldPivot("_WorldPivot", Vector) = (0,0,0,0)
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "white" {}
		[HDR][Header(Rim Light)][Space()]_RimColor("Rim Color", Color) = (1,1,1,0)
		_RimPower1("Rim Power", Float) = 1
		[Header(Intensity)][Space()]_Intensity_Color("Intensity_Color", Float) = 1
		[IntRange][Header(Curved Path)][Space()]_CurveCount("Curve Count", Range( 0 , 10)) = 1
		_CurveIntensity("Curve Intensity", Range( 0 , 1)) = 0
		_Rotation("Curve Rotation", Range( 0 , 0.1)) = 0
		_Offset("Offset to X axis", Range( -1 , 1)) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0

	}

	SubShader
	{
		LOD 100



		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" "DisableBatching"="True" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL


		Pass
		{
			Name "Unlit"


			Cull [_CullMode]
			Blend Off
			ZTest [_ZTest]
			ZWrite On
			ColorMask RGBA


			HLSLPROGRAM
			#define ASE_ABSOLUTE_VERTEX_POS 1
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
			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _RimColor;
			float4 _WorldPivot;
			float _Intensity_Color;
			float _CurveIntensity;
			float _CurveCount;
			float _Rotation;
			float _Offset;
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
			float _RimPower1;
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


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float OffsettoXaxis58 = _Offset;
				float3 appendResult32 = (float3(( OffsettoXaxis58 + input.positionOS.xyz.x ) , input.positionOS.xyz.y , input.positionOS.xyz.z));
				float3 positionOS29 = appendResult32;
				float3 ase_worldPos = TransformObjectToWorld( (input.positionOS).xyz );
				float3 positionWS28 = ase_worldPos;
				float4 CharPosition55 = _WorldPivot;
				float4 charPosition28 = CharPosition55;
				float rotation28 = _Rotation;
				float CurveCount60 = _CurveCount;
				float curveCount28 = CurveCount60;
				float localCurvedAngle28 = CurvedAngle( positionWS28 , charPosition28 , rotation28 , curveCount28 );
				float degrees29 = localCurvedAngle28;
				float offset29 = OffsettoXaxis58;
				float3 localRotation29 = Rotation( positionOS29 , degrees29 , offset29 );
				float3 objToWorld68 = mul( GetObjectToWorldMatrix(), float4( localRotation29, 1 ) ).xyz;
				float3 positionWS22 = objToWorld68;
				float4 charPosition22 = CharPosition55;
				float intensity22 = _CurveIntensity;
				float curveCount22 = CurveCount60;
				float localCurvedPath22 = CurvedPath( positionWS22 , charPosition22 , intensity22 , curveCount22 );
				float3 appendResult37 = (float3(objToWorld68.x , ( objToWorld68.y + localCurvedPath22 ) , objToWorld68.z));
				float3 worldToObj69 = mul( GetWorldToObjectMatrix(), float4( appendResult37, 1 ) ).xyz;

				output.ase_color = input.color;
				output.ase_normal = input.normalOS;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = worldToObj69;
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
				float localFXFinalColorOutputs125_g1 = ( 0.0 );
				float2 texCoord71 = input.uv0.xy * float2( 1,1 ) + float2( 0,0 );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - input.positionWS );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float dotResult79 = dot( input.ase_normal , ase_worldViewDir );
				float4 appendResult32_g1 = (float4(( ( input.ase_color * tex2D( _MainTex, texCoord71 ) * _Intensity_Color ) + ( input.ase_color.a * saturate( pow( ( 1.0 - saturate( dotResult79 ) ) , _RimPower1 ) ) * _RimColor ) ).rgb , 1.0));
				float4 finalColor125_g1 = appendResult32_g1;
				float4 texCoord147_g1 = input.screenPos;
				texCoord147_g1.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g1 = texCoord147_g1;
				float4 positionNDC125_g1 = ScreenPos146_g1;
				float4 texCoord140_g1 = input.fogCoord;
				texCoord140_g1.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g1 = texCoord140_g1;
				float4 fogCoord125_g1 = fogCoord139_g1;
				float3 positionWS125_g1 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g1 = normalizedWorldNormal;
				float nearPlaneAlpha125_g1 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g1 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g1 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g1 = _RaycastMinimumAlpha;
				float lightRatio125_g1 = _LightRatio;
				float lightReceive125_g1 = _LightReceive;
				float near125_g1 = _SoftParticleNearFadeDistance;
				float far125_g1 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g1 = _SoftParticleFadeOutRange;
				float softParticle125_g1 = _SoftParticle;
				float mode125_g1 = _Mode;
				float fogReceive125_g1 = _FogReceive;
				float transitionValue125_g1 = _TransitionValue;
				float spawnTransition125_g1 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g1 , positionNDC125_g1 , fogCoord125_g1 , positionWS125_g1 , normalWS125_g1 , nearPlaneAlpha125_g1 , nearPlaneInvertDistance125_g1 , raycastHarftoneClip125_g1 , raycastMinimumAlpha125_g1 , lightRatio125_g1 , lightReceive125_g1 , near125_g1 , far125_g1 , fadeOutRange125_g1 , softParticle125_g1 , mode125_g1 , fogReceive125_g1 , transitionValue125_g1 , spawnTransition125_g1 );
				float4 break64_g1 = finalColor125_g1;
				float3 appendResult76_g1 = (float3(break64_g1.x , break64_g1.y , break64_g1.z));

				float3 color = appendResult76_g1;
				float alpha = break64_g1.w;

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
Node;AmplifyShaderEditor.RangedFloatNode;10;-1136,1264;Inherit;False;Property;_Offset;Offset to X axis;24;0;Create;False;0;0;0;True;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;77;-800,880;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;78;-800,1040;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-848,1264;Inherit;False;OffsettoXaxis;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1216,2208;Inherit;False;Property;_CurveCount;Curve Count;21;1;[IntRange];Create;False;0;0;0;True;2;Header(Curved Path);Space();False;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;30;-832,1408;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-992,1664;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;79;-608,880;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-976,1872;Inherit;False;CharPosition;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-944,2208;Inherit;False;CurveCount;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1216,2112;Inherit;False;Property;_Rotation;Curve Rotation;23;0;Create;False;0;0;0;True;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-640,1408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-592,1824;Inherit;False;58;OffsettoXaxis;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;80;-464,880;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;28;-640,1664;Inherit;False; ;1;File;4;True;positionWS;FLOAT3;0,0,0;In;;Inherit;False;True;charPosition;FLOAT4;0,0,0,0;In;;Inherit;False;True;rotation;FLOAT;0;In;;Inherit;False;True;curveCount;FLOAT;0;In;;Inherit;False;CurvedAngle;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;4;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-496,1424;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;39;-96,1360;Inherit;False;778;371;PositionWS;4;37;38;22;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;82;-320,864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-448,976;Inherit;False;Property;_RimPower1;Rim Power;19;0;Create;True;0;0;0;False;0;False;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;29;-352,1424;Inherit;False; ;3;File;3;True;positionOS;FLOAT3;0,0,0;In;;Inherit;False;True;degrees;FLOAT;0;In;;Inherit;False;True;offset;FLOAT;0;In;;Inherit;False;Rotation;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;71;-416,624;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-368,1792;Inherit;False;Property;_CurveIntensity;Curve Intensity;22;0;Create;False;0;0;0;True;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-288,1712;Inherit;False;55;CharPosition;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;83;-160,864;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-288,1872;Inherit;False;60;CurveCount;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;68;-64,1424;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;72;-192,624;Inherit;True;Property;_MainTex;MainTex;17;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;c5fab1eb02e03e24491e663d25569187;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;73;-64,432;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;128,784;Inherit;False;Property;_Intensity_Color;Intensity_Color;20;0;Create;True;0;0;0;False;2;Header(Intensity);Space();False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;-16,880;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;22;160,1568;Inherit;False; ;1;File;4;True;positionWS;FLOAT3;0,0,0;In;;Inherit;False;True;charPosition;FLOAT4;0,0,0,0;In;;Inherit;False;True;intensity;FLOAT;0;In;;Inherit;False;True;curveCount;FLOAT;0;In;;Inherit;False;CurvedPath;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;4;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;84;-96,1008;Inherit;False;Property;_RimColor;Rim Color;18;1;[HDR];Create;True;0;0;0;False;2;Header(Rim Light);Space();False;1,1,1,0;0.1058651,0.3705692,0.5754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;352,624;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;384,1488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;128,880;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;560,880;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;512,1456;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;20;992,1040;Inherit;False;227;234;Rendering Options;2;15;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;1041,1088;Inherit;False;Property;_CullMode;Cull Mode;26;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2;736,880;Inherit;False;MMN_CommonOutputs;0;;1;08656d87d50d792418fb85b40434f915;0;2;9;COLOR;1,1,1,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.TransformPositionNode;69;728.22,1154.111;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;15;1040,1168;Inherit;False;Property;_ZTest;Z Test;25;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;992,880;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxOpaqueShaderGUI;100;14;MMN/FX/Amplify shader/FX_IceSpike;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;4;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=True=DisableBatching;True;5;False;0;True;True;0;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;1;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;0;638223181704556226;0;1;True;False;;False;0
Node;AmplifyShaderEditor.Vector4Node;5;-1184,1872;Inherit;False;Property;_WorldPivot;_WorldPivot;16;1;[HideInInspector];Create;False;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;58;0;10;0
WireConnection;79;0;77;0
WireConnection;79;1;78;0
WireConnection;55;0;5;0
WireConnection;60;0;7;0
WireConnection;31;0;58;0
WireConnection;31;1;30;1
WireConnection;80;0;79;0
WireConnection;28;0;3;0
WireConnection;28;1;55;0
WireConnection;28;2;9;0
WireConnection;28;3;60;0
WireConnection;32;0;31;0
WireConnection;32;1;30;2
WireConnection;32;2;30;3
WireConnection;82;0;80;0
WireConnection;29;0;32;0
WireConnection;29;1;28;0
WireConnection;29;2;59;0
WireConnection;83;0;82;0
WireConnection;83;1;81;0
WireConnection;68;0;29;0
WireConnection;72;1;71;0
WireConnection;85;0;83;0
WireConnection;22;0;68;0
WireConnection;22;1;54;0
WireConnection;22;2;8;0
WireConnection;22;3;61;0
WireConnection;75;0;73;0
WireConnection;75;1;72;0
WireConnection;75;2;74;0
WireConnection;38;0;68;2
WireConnection;38;1;22;0
WireConnection;86;0;73;4
WireConnection;86;1;85;0
WireConnection;86;2;84;0
WireConnection;76;0;75;0
WireConnection;76;1;86;0
WireConnection;37;0;68;1
WireConnection;37;1;38;0
WireConnection;37;2;68;3
WireConnection;2;9;76;0
WireConnection;69;0;37;0
WireConnection;1;0;2;2
WireConnection;1;1;2;26
WireConnection;1;3;69;0
ASEEND*/
//CHKSM=A1EDC694EF50EC9C4174022F61B2CDB2210C787D