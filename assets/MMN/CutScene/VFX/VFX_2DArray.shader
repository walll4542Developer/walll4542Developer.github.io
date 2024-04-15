Shader "MMN/VFX/FX_2DArray"
{
	Properties
	{
		[Header(Texture Array 2D Options)]
		[Space(10)]
		_MainTex2DArray("메인 텍스쳐 어레이", 2DArray) = "white" {}
		[IntRange]_ArrayIndex("어레이 인덱스", Range(0, 31)) = 0
		[Header(Mask Options)]
		[Space(10)]
		[Enum(Circle, 0, Quad, 1)]_MaskShape("마스크 형태", Float) = 0
		_MaskColor("마스크 색상", Color) = (0, 0, 0, 0)
		_MaskFeather("마스크 페더", Range(0, 1)) = 1
		_MaskSize("마스크 크기", Range(0, 1)) = 0.5
		[Toggle]_UseAlpha("마스크를 알파로 사용하시겠습니까?", Float) = 0
		[Header(Rendering Options)]
		[Space(10)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendSrc("Blend Src", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("Blend Dst", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Z Test", Float) = 4
	}

	SubShader
	{
		LOD 100

		Tags 
		{ 
			"RenderPipeline"="UniversalPipeline" 
			"RenderType"="Transparent" 
			"Queue"="Transparent" 
		}

		Pass
		{
			Name "Unlit"
			
			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			
			HLSLPROGRAM
			#pragma target 4.5
			#pragma exclude_renderers glcore gles gles3
			#pragma require 2darray

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"

			TEXTURE2D_ARRAY(_MainTex2DArray);
			SAMPLER(sampler_MainTex2DArray);

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex2DArray_ST;
				float4 _MaskColor;
				float _ArrayIndex;
				float _MaskSize;
				float _MaskFeather;
				float _UseAlpha;
				float _MaskShape;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv0 : TEXCOORD0;
			};

			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;
				
				VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
				output.uv0 = TRANSFORM_TEX(input.texcoord.xy, _MainTex2DArray);
				output.positionCS = vertexInput.positionCS;

				return output;
			}

			float4 frag(Varyings input) : SV_Target
			{
				// 셰이더 프로퍼티 범위 값 수정
				_MaskFeather *= 0.5; 	// 0 ~ 0.5 범위로 만듬
				_MaskSize *= 2; 		// -1 ~ 1 범위로 만듬
				_MaskSize -= 1; 

				float2 uv = input.uv0.xy;
				float4 mainTex2DArray = SAMPLE_TEXTURE2D_ARRAY_LOD(_MainTex2DArray, sampler_MainTex2DArray, uv.xy, _ArrayIndex, 0);
			
				float2 maskUV = uv;
				float mask = 0;

				// Circle Mask
				float2 circleMaskUV = uv - 0.5;
				float circleMask = 1 - saturate(length(circleMaskUV) + _MaskSize);
				circleMask = saturate(smoothstep(_MaskFeather, 1 - _MaskFeather, circleMask));

				// Quad Mask
				float2 quadMaskUV = 1 - saturate(abs(uv - 0.5) * 2);
				float quadMask = saturate(quadMaskUV.x * quadMaskUV.y + _MaskSize);
				quadMask = saturate(smoothstep(_MaskFeather, 1 - _MaskFeather, quadMask));

				// Mask Shape
				maskUV = lerp(circleMaskUV, quadMaskUV, _MaskShape);
				mask = lerp(circleMask, quadMask, _MaskShape);
				
				// Final Color
				float3 color = lerp(_MaskColor.rgb, mainTex2DArray.rgb, mask);
				color = lerp(color, mainTex2DArray.rgb, _UseAlpha);
				float alpha = lerp(1, mask, _UseAlpha);
				float4 finalColor = float4(color, alpha);

				return finalColor;
			}
			ENDHLSL
		}
	}
	FallBack Off
}