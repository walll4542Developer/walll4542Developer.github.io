Shader "MMN/Special/CameraFade & Vignetting"
{
	Properties
	{
		[HideInInspector] _Mode("BlendMode", Float) = -1
		[Enum(Fade, 0, Vignetting, 1)]_ScreenFXMode("Screen FX Mode", Float) = 0
		_VignettingSmooth("Vignetting Smooth", Range(0, 1)) = 1
		_VignettingRange("Vignetting Range", Range(0, 1)) = 1

		_Color("BaseColor", Color) = (1, 1, 1, 1)
		_Intensity_Color("Intensity_Color", Float) = 1
		_Intensity_Alpha("Intensity_Alpha", Float) = 1

		[Header(Rendering Options)]
		[Space()]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("Blend Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
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
				half _Mode;
				half _ScreenFXMode;

				half _Intensity_Color;
				half _Intensity_Alpha;
				half4 _Color;

				half _VignettingSmooth;
				half _VignettingRange;
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
				half4 color 		: COLOR;
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

			void ScreenRatio(inout float2 ratio)
			{
				// x = width
				// y = height
				// z = 1 + 1.0/width
				// w = 1 + 1.0/height

				if(_ScreenParams.x > _ScreenParams.y)
				{
					ratio = float2(1, _ScreenParams.y / _ScreenParams.x);
				}
				else
				{
					ratio = float2(_ScreenParams.x / _ScreenParams.y, 1);
				}
			}

			half4 frag(Varyings input) : SV_Target
			{
				// 프로퍼티 범위 조절
				_VignettingSmooth = 1 - _VignettingSmooth;
				_VignettingSmooth *= 0.5;
				_VignettingRange *= 2;
				_VignettingRange += 0.85;

				half3 color = 1;
				half alpha = 1;

				half3 fadeColor = _Color.rgb * _Intensity_Color * input.color.rgb;
				half fadeAlpha = saturate(_Intensity_Alpha * _Color.a * input.color.a);

				// float2 ratio = 1;
				// ScreenRatio(ratio);

				float2 screenUV = float2(input.screenPos.xy);
				screenUV = (screenUV / input.screenPos.w + 0.0001) - 0.5;

				// screenUV = abs(screenUV);
				// screenUV = pow(screenUV, 0.5);
				// half quadMask = max(screenUV.x, screenUV.y);
				// quadMask = 1 - saturate(smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, quadMask));
				
				// Quad Mask
				half2 quadMaskUV = 1 - saturate(abs(screenUV) * _VignettingRange);
				half quadMask = saturate(quadMaskUV.x * quadMaskUV.y + 0.45); // MagicNumber
				quadMask = 1 - saturate(smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, quadMask));

				// // Length Mask
				// half lengthMask = length(screenUV) - _VignettingRange;
				// lengthMask = smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, lengthMask);

				// // Default Mask
				// half defualtMask = saturate(abs(screenUV.y) + abs(screenUV.x) + _VignettingRange);
				// defualtMask = smoothstep(_VignettingSmooth, 1 - _VignettingSmooth, defualtMask);

				half3 vignettingColor = quadMask;
				half vignettingAlpha = quadMask;

				color = lerp(fadeColor, vignettingColor * fadeColor, _ScreenFXMode);
				alpha = lerp(fadeAlpha, vignettingAlpha * fadeAlpha, _ScreenFXMode);

				half4 finalColor = half4(color, alpha);

				return finalColor;
			}
			ENDHLSL
		}
	}
	Fallback off
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_ScreenFxGUI"
}