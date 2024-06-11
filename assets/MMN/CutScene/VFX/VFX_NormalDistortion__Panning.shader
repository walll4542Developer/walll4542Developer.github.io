// Made with Amplify Shader Editor v1.9.3.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "MMN/VFX/Amplify shader/FX_NormalDistortion_Panning"
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
		[Header(Main Texture)][Space()]_MainTex("MainTex", 2D) = "black" {}
		_ScreenTile("메인 텍스쳐 타일링", Vector) = (1,1,0,0)
		[Toggle]_NormalTexture("NormalTexture", Float) = 0
		_Distortion_Power("Distortion_Power", Float) = 1
		_Main_X_Speed("Main_X_Speed", Float) = 0
		_Main_Y_Speed("Main_Y_Speed", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		[Toggle]_IsScreenMasking("스크린 마스킹 사용하기", Float) = 0
		_Opacity("Opacity", Float) = 1
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)][Header(Rendering Options)][Space()]_BlendSrc("Blend Src", Float) = 5
		[HideInInspector][Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4

	}

	SubShader
	{
		LOD 300

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent-499" }

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="Distortion" }

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
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MaskTex_ST;
			float2 _ScreenTile;
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
			float _Distortion_Power;
			float _Main_X_Speed;
			float _Main_Y_Speed;
			float _NormalTexture;
			float _NearPlaneAlpha;
			float _IsScreenMasking;
			float _Opacity;
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
				float4 ase_color : COLOR;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord2 = screenPos;
				
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
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 break289 = ase_screenPosNorm;
				float2 appendResult288 = (float2(break289.x , break289.y));
				float2 RawScreenPosition295 = appendResult288;
				float2 appendResult272 = (float2(_Main_X_Speed , _Main_Y_Speed));
				float2 localScreenRatio301 = ScreenRatio(  );
				float2 _Vertical = float2(0.5,0);
				float2 ifLocalVar291 = 0;
				if( _ScreenParams.x <= _ScreenParams.y )
				ifLocalVar291 = _Vertical;
				else
				ifLocalVar291 = float2( 0,0.5 );
				float2 localScreenOffset298 = ScreenOffset(  );
				float2 RatioScreenUV299 = ( ( ( localScreenRatio301 * RawScreenPosition295 ) + ifLocalVar291 ) - localScreenOffset298 );
				float2 panner271 = ( 1.0 * _Time.y * appendResult272 + ( RatioScreenUV299 * _ScreenTile ));
				float4 tex2DNode5 = tex2D( _MainTex, panner271 );
				float3 lerpResult264 = lerp( ( float3(0,1,0) * tex2DNode5.g ) , UnpackNormalScale( tex2DNode5, 1.0 ) , _NormalTexture);
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 lerpResult326 = lerp( uv_MaskTex , RatioScreenUV299 , _IsScreenMasking);
				float DistortionValue402 = ( input.ase_color.a * _Distortion_Power * lerpResult264 * saturate( ( tex2D( _MaskTex, lerpResult326 ).r * _Opacity ) ) ).y;
				float ifLocalVar379 = 0;
				if( _ScreenParams.x >= _ScreenParams.y )
				ifLocalVar379 = DistortionValue402;
				else
				ifLocalVar379 = ( DistortionValue402 * ( _ScreenParams.y / _ScreenParams.x ) );
				float temp_output_344_0 = ( DistortionValue402 * ( _ScreenParams.x / _ScreenParams.y ) );
				float ifLocalVar343 = 0;
				if( _ScreenParams.x >= _ScreenParams.y )
				ifLocalVar343 = temp_output_344_0;
				else
				ifLocalVar343 = DistortionValue402;
				float2 appendResult400 = (float2(ifLocalVar379 , ifLocalVar343));
				float2 screenPos311 = ( RawScreenPosition295 + appendResult400 );
				float3 localSceneColor311 = SceneColor( screenPos311 );
				float4 appendResult32_g14 = (float4(localSceneColor311 , 1.0));
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
			#pragma multi_compile_fragment __ _RAYCAST_ON


			sampler2D _MainTex;
			sampler2D _MaskTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MaskTex_ST;
			float2 _ScreenTile;
			float _NearPlaneAlpha;
			float _NormalTexture;
			float _Main_Y_Speed;
			float _Main_X_Speed;
			float _Distortion_Power;
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
			float _IsScreenMasking;
			float _Opacity;
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
				float4 ase_color : COLOR;
			};

			
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				float4 ase_clipPos = TransformObjectToHClip((input.positionOS).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				output.ase_texcoord2 = screenPos;
				
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
				float localFXFinalColorOutputs125_g13 = ( 0.0 );
				float4 screenPos = input.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 break289 = ase_screenPosNorm;
				float2 appendResult288 = (float2(break289.x , break289.y));
				float2 RawScreenPosition295 = appendResult288;
				float2 appendResult272 = (float2(_Main_X_Speed , _Main_Y_Speed));
				float2 localScreenRatio301 = ScreenRatio(  );
				float2 _Vertical = float2(0.5,0);
				float2 ifLocalVar291 = 0;
				if( _ScreenParams.x <= _ScreenParams.y )
				ifLocalVar291 = _Vertical;
				else
				ifLocalVar291 = float2( 0,0.5 );
				float2 localScreenOffset298 = ScreenOffset(  );
				float2 RatioScreenUV299 = ( ( ( localScreenRatio301 * RawScreenPosition295 ) + ifLocalVar291 ) - localScreenOffset298 );
				float2 panner271 = ( 1.0 * _Time.y * appendResult272 + ( RatioScreenUV299 * _ScreenTile ));
				float4 tex2DNode5 = tex2D( _MainTex, panner271 );
				float3 lerpResult264 = lerp( ( float3(0,1,0) * tex2DNode5.g ) , UnpackNormalScale( tex2DNode5, 1.0 ) , _NormalTexture);
				float2 uv_MaskTex = input.uv0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float2 lerpResult326 = lerp( uv_MaskTex , RatioScreenUV299 , _IsScreenMasking);
				float DistortionValue402 = ( input.ase_color.a * _Distortion_Power * lerpResult264 * saturate( ( tex2D( _MaskTex, lerpResult326 ).r * _Opacity ) ) ).y;
				float ifLocalVar379 = 0;
				if( _ScreenParams.x >= _ScreenParams.y )
				ifLocalVar379 = DistortionValue402;
				else
				ifLocalVar379 = ( DistortionValue402 * ( _ScreenParams.y / _ScreenParams.x ) );
				float temp_output_344_0 = ( DistortionValue402 * ( _ScreenParams.x / _ScreenParams.y ) );
				float ifLocalVar343 = 0;
				if( _ScreenParams.x >= _ScreenParams.y )
				ifLocalVar343 = temp_output_344_0;
				else
				ifLocalVar343 = DistortionValue402;
				float2 appendResult400 = (float2(ifLocalVar379 , ifLocalVar343));
				float2 screenPos311 = ( RawScreenPosition295 + appendResult400 );
				float3 localSceneColor311 = SceneColor( screenPos311 );
				float4 appendResult32_g13 = (float4(( float3(0,0,0) * localSceneColor311 ) , 0.0));
				float4 finalColor125_g13 = appendResult32_g13;
				float4 texCoord147_g13 = input.screenPos;
				texCoord147_g13.xy = input.screenPos.xy * float2( 1,1 ) + float2( 0,0 );
				float4 ScreenPos146_g13 = texCoord147_g13;
				float4 positionNDC125_g13 = ScreenPos146_g13;
				float4 texCoord140_g13 = input.fogCoord;
				texCoord140_g13.xy = input.fogCoord.xy * float2( 1,1 ) + float2( 0,0 );
				float4 fogCoord139_g13 = texCoord140_g13;
				float4 fogCoord125_g13 = fogCoord139_g13;
				float3 positionWS125_g13 = input.positionWS;
				float3 normalizedWorldNormal = normalize( input.normalWS );
				float3 normalWS125_g13 = normalizedWorldNormal;
				float nearPlaneAlpha125_g13 = _NearPlaneAlpha;
				float nearPlaneInvertDistance125_g13 = _NearPlaneInvertDistance;
				float raycastHarftoneClip125_g13 = _RaycastHarftoneClip;
				float raycastMinimumAlpha125_g13 = _RaycastMinimumAlpha;
				float lightRatio125_g13 = _LightRatio;
				float lightReceive125_g13 = _LightReceive;
				float near125_g13 = _SoftParticleNearFadeDistance;
				float far125_g13 = _SoftParticleFarFadeDistance;
				float fadeOutRange125_g13 = _SoftParticleFadeOutRange;
				float softParticle125_g13 = _SoftParticle;
				float mode125_g13 = _Mode;
				float fogReceive125_g13 = _FogReceive;
				float transitionValue125_g13 = _TransitionValue;
				float spawnTransition125_g13 = _SpawnTransition;
				FXFinalColorOutputs( finalColor125_g13 , positionNDC125_g13 , fogCoord125_g13 , positionWS125_g13 , normalWS125_g13 , nearPlaneAlpha125_g13 , nearPlaneInvertDistance125_g13 , raycastHarftoneClip125_g13 , raycastMinimumAlpha125_g13 , lightRatio125_g13 , lightReceive125_g13 , near125_g13 , far125_g13 , fadeOutRange125_g13 , softParticle125_g13 , mode125_g13 , fogReceive125_g13 , transitionValue125_g13 , spawnTransition125_g13 );
				float4 break64_g13 = finalColor125_g13;
				float3 appendResult76_g13 = (float3(break64_g13.x , break64_g13.y , break64_g13.z));
				
				float3 color = appendResult76_g13;
				float alpha = break64_g13.w;

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
Version=19303
Node;AmplifyShaderEditor.CommentaryNode;302;2096,-1520;Inherit;False;1524;691;ScreenUV;14;288;289;290;291;292;293;294;295;296;297;298;299;300;301;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;290;2144,-1376;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;289;2336,-1376;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;288;2480,-1392;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;2624,-1392;Inherit;False;RawScreenPosition;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;292;2640,-1120;Inherit;False;Constant;_Horizontal;Horizontal;28;0;Create;True;0;0;0;False;0;False;0,0.5;0,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;294;2640,-992;Inherit;False;Constant;_Vertical;Vertical;28;0;Create;True;0;0;0;False;0;False;0.5,0;0.5,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CustomExpressionNode;301;2752,-1472;Inherit;False; ;2;File;0;ScreenRatio;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;0;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenParams;293;2624,-1296;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;2880,-1392;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ConditionalIfNode;291;2864,-1280;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;3056,-1392;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;298;3056,-1200;Inherit;False; ;2;File;0;ScreenOffset;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;297;3232,-1296;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;331;-1520,-288;Inherit;False;468;291;원하시는대로 수정해주세요!;3;330;327;351;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;299;3376,-1312;Inherit;False;RatioScreenUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;324;-928,256;Inherit;False;442.2906;308.0162;Switch;2;326;325;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-1392,112;Inherit;False;Property;_Main_Y_Speed;Main_Y_Speed;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;330;-1472,-160;Inherit;False;Property;_ScreenTile;메인 텍스쳐 타일링;17;0;Create;False;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;351;-1488,-240;Inherit;False;299;RatioScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;273;-1392,32;Inherit;False;Property;_Main_X_Speed;Main_X_Speed;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-912,480;Inherit;False;Property;_IsScreenMasking;스크린 마스킹 사용하기;23;1;[Toggle];Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-1152,464;Inherit;False;299;RatioScreenUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;276;-1152,336;Inherit;False;0;275;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;327;-1232,-240;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;272;-1184,32;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;326;-624,336;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;271;-960,-48;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;266;-224,-192;Inherit;False;369.2906;308.0162;Switch;2;264;265;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;275;-432,208;Inherit;True;Property;_MaskTex;MaskTex;22;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;278;-128,304;Inherit;False;Property;_Opacity;Opacity;24;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-768,-64;Inherit;True;Property;_MainTex;MainTex;16;0;Create;True;0;0;0;False;2;Header(Main Texture);Space();False;-1;None;None;True;0;True;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;404;-672,-224;Inherit;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;32,224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-192,0;Inherit;False;Property;_NormalTexture;NormalTexture;18;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-416,-192;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;184;-448,-64;Inherit;False;Tangent;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;264;0,-144;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-48,-272;Inherit;False;Property;_Distortion_Power;Distortion_Power;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;66;-16,-448;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;285;192,224;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;480,-128;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;410;974,-498;Inherit;False;916;803;Ratio;10;346;381;348;373;401;344;376;343;379;375;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;409;640,-128;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ScreenParams;346;1024,96;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenParams;381;1024,-96;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;402;752,-128;Inherit;False;DistortionValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;348;1248,96;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;373;1248,-32;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;401;1168,-256;Inherit;False;402;DistortionValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;344;1456,32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenParams;375;1424,-448;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;376;1456,-112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;343;1680,-16;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;379;1680,-208;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;400;2144,-48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;313;2064,-128;Inherit;False;295;RawScreenPosition;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;2320,-80;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;76;3152,80;Inherit;False;204;375;Rendering Options;4;79;78;77;267;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;311;2448,-80;Float;False; ;3;File;1;True;screenPos;FLOAT2;0,0;In;;Float;False;SceneColor;False;False;0;d2b180d66d3b6594ba4923958c85921a;False;1;0;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;411;2694.005,61.37;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;287;2704,-240;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;284;2896,-240;Inherit;False;MMN_CommonOutputs;0;;13;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.RangedFloatNode;77;3184,208;Inherit;False;Property;_BlendDst;Blend Dst;26;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;3184,288;Inherit;False;Property;_CullMode;Cull Mode;27;2;[HideInInspector];[Enum];Fetch;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;3184,128;Inherit;False;Property;_BlendSrc;Blend Src;25;2;[HideInInspector];[Enum];Fetch;True;0;1;UnityEngineRenderingBlendMode;0;1;UnityEngine.Rendering.BlendMode;True;2;Header(Rendering Options);Space();False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;3184,368;Inherit;False;Property;_ZTest;Z Test;28;2;[HideInInspector];[Enum];Fetch;True;0;2;Default;2;Always;6;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;280;2704,-112;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;119;2896,-80;Inherit;False;MMN_CommonOutputs;0;;14;08656d87d50d792418fb85b40434f915;0;2;9;FLOAT3;1,0,0;False;28;FLOAT;1;False;2;FLOAT3;2;FLOAT;26
Node;AmplifyShaderEditor.Vector3Node;283;2480,-240;Inherit;False;Constant;_TempColor;TempColor;12;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;279;3152,-240;Float;False;True;0;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;100;14;MMN/VFX/Amplify shader/FX_NormalDistortion_Panning;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;0;True;_ZTest;False;True;0;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;97;3152,-80;Float;False;True;-1;2;MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI;300;14;MMN/VFX/Amplify shader/FX_NormalDistortion_Panning;308ae98526c03914f8dfddbb03a3d101;True;Unlit;0;0;Unlit;4;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=-499;True;5;False;0;False;True;1;0;True;_BlendSrc;0;True;_BlendDst;0;1;False;;0;False;;False;False;False;False;True;False;False;False;False;False;False;False;True;0;True;_CullMode;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;True;True;2;False;;True;0;True;_ZTest;False;True;1;LightMode=Distortion;False;True;9;d3d11;metal;vulkan;xboxone;xboxseries;playstation;ps4;ps5;switch;0;;0;0;Standard;1;Vertex Position;1;0;0;1;True;False;;False;0
WireConnection;289;0;290;0
WireConnection;288;0;289;0
WireConnection;288;1;289;1
WireConnection;295;0;288;0
WireConnection;300;0;301;0
WireConnection;300;1;295;0
WireConnection;291;0;293;1
WireConnection;291;1;293;2
WireConnection;291;2;292;0
WireConnection;291;3;294;0
WireConnection;291;4;294;0
WireConnection;296;0;300;0
WireConnection;296;1;291;0
WireConnection;297;0;296;0
WireConnection;297;1;298;0
WireConnection;299;0;297;0
WireConnection;327;0;351;0
WireConnection;327;1;330;0
WireConnection;272;0;273;0
WireConnection;272;1;274;0
WireConnection;326;0;276;0
WireConnection;326;1;322;0
WireConnection;326;2;325;0
WireConnection;271;0;327;0
WireConnection;271;2;272;0
WireConnection;275;1;326;0
WireConnection;5;1;271;0
WireConnection;277;0;275;1
WireConnection;277;1;278;0
WireConnection;363;0;404;0
WireConnection;363;1;5;2
WireConnection;184;0;5;0
WireConnection;264;0;363;0
WireConnection;264;1;184;0
WireConnection;264;2;265;0
WireConnection;285;0;277;0
WireConnection;130;0;66;4
WireConnection;130;1;129;0
WireConnection;130;2;264;0
WireConnection;130;3;285;0
WireConnection;409;0;130;0
WireConnection;402;0;409;1
WireConnection;348;0;346;1
WireConnection;348;1;346;2
WireConnection;373;0;381;2
WireConnection;373;1;381;1
WireConnection;344;0;401;0
WireConnection;344;1;348;0
WireConnection;376;0;401;0
WireConnection;376;1;373;0
WireConnection;343;0;375;1
WireConnection;343;1;375;2
WireConnection;343;2;344;0
WireConnection;343;3;344;0
WireConnection;343;4;401;0
WireConnection;379;0;375;1
WireConnection;379;1;375;2
WireConnection;379;2;401;0
WireConnection;379;3;401;0
WireConnection;379;4;376;0
WireConnection;400;0;379;0
WireConnection;400;1;343;0
WireConnection;359;0;313;0
WireConnection;359;1;400;0
WireConnection;311;0;359;0
WireConnection;287;0;283;0
WireConnection;287;1;311;0
WireConnection;284;9;287;0
WireConnection;284;28;280;0
WireConnection;119;9;311;0
WireConnection;279;0;284;2
WireConnection;279;1;284;26
WireConnection;97;0;119;2
WireConnection;97;1;119;26
ASEEND*/
//CHKSM=F5D79AB672BA681F7ED831D6219FB3D16623FC9B