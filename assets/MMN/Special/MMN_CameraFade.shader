Shader "MMN/Special/CameraFade & Vignetting"
{
	Properties
	{
		[HideInInspector] _Mode ("BlendMode", Float) = -1.0
		[Enum(Fade, 0, Vignetting, 1)] _ScreenFXMode ("Screen FX Mode", Float) = 0.0
		_VignettingSmooth ("Vignetting Smooth", Range(0.0, 1.0)) = 1.0
		_VignettingRange ("Vignetting Range", Range(0.0, 1.0)) = 1.0

		_Color ("BaseColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_Intensity_Color ("Intensity_Color", Float) = 1.0
		_Intensity_Alpha ("Intensity_Alpha", Float) = 1.0 

		[Header(Rendering Options)]
		[Space()]
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend Src", Float) = 5.0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend Dst", Float) = 10.0
	}

	SubShader
	{
		LOD 100
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"Queue" = "Transparent+1050"
		}

		HLSLINCLUDE
			#pragma target 4.5
		ENDHLSL

		Pass
		{
			Name "Unlit"

            Tags { "LightMode" = "ScreenSpaceRenderObjects" }

			Cull back
			Blend [_BlendSrc] [_BlendDst]
			ZTest Always
			ZWrite Off
			ColorMask RGBA

			HLSLPROGRAM
			#pragma exclude_renderers glcore gles gles3

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float _Mode;
				float _ScreenFXMode;

				float _Intensity_Color;
				float _Intensity_Alpha;
				float4 _Color;

				float _VignettingSmooth;
				float _VignettingRange;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS 	: POSITION;
				float4 color 		: COLOR;
				float4 uv			: TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS 	: SV_POSITION;
				float4 color 		: COLOR;
				float4 uv 			: TEXCOORD0;
				float4 screenPos 	: TEXCOORD1;
				float3 positionWS	: TEXCOORD2;
			};


			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				output.positionCS = vertexInput.positionCS;
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.color = input.color;
				output.uv = input.uv;
				output.screenPos = ComputeScreenPos(output.positionCS);

				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				// 프로퍼티 범위 조절
				_VignettingSmooth = 1 - _VignettingSmooth;
				_VignettingSmooth *= 0.5;
				_VignettingRange *= 2;
				_VignettingRange += 0.85;

				float3 color = 1;
				float alpha = 1;

				float3 fadeColor = _Color.rgb * _Intensity_Color * input.color.rgb;
				float fadeAlpha = saturate(_Intensity_Alpha * _Color.a * input.color.a);

				float2 screenUV = float2(input.screenPos.xy);
				screenUV = (screenUV / input.screenPos.w + 0.0001) - 0.5;

				// screenUV = abs(screenUV);
				// screenUV = pow(screenUV, 0.5);
				// float quadMask = max(screenUV.x, screenUV.y);
				// quadMask = 1 - saturate(smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, quadMask));
				
				// Quad Mask
				float2 quadMaskUV = 1 - saturate(abs(screenUV) * _VignettingRange);
				float quadMask = saturate(quadMaskUV.x * quadMaskUV.y + 0.45); // MagicNumber
				quadMask = 1 - saturate(smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, quadMask));

				// // Length Mask
				// float lengthMask = length(screenUV) - _VignettingRange;
				// lengthMask = smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, lengthMask);

				// // Default Mask
				// float defualtMask = saturate(abs(screenUV.y) + abs(screenUV.x) + _VignettingRange);
				// defualtMask = smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, defualtMask);

				float3 vignettingColor = quadMask;
				float vignettingAlpha = quadMask;

				color = lerp(fadeColor, vignettingColor * fadeColor, _ScreenFXMode);
				alpha = lerp(fadeAlpha, vignettingAlpha * fadeAlpha, _ScreenFXMode);

				float4 finalColor = float4(color, alpha);

				return finalColor;
			}
			ENDHLSL
		}
	}
	Fallback Off
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_ScreenFxGUI"
}