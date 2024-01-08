Shader /*ase_name*/ "Hidden/Universal/FX" /*end*/
{
	Properties
	{
		[HideInInspector] _Mode("__mode", Float) = -1
		[HideInInspector] _TransitionValue("_TransitionValue", Float) = 1
		[HideInInspector] _FogReceive("_FogReceive", Float) = 0
		/*ase_props*/
	}

	SubShader
	{
		LOD 100
		/*ase_subshader_options:Name=Additional Options
			Option:Vertex Position:Absolute,Relative:Relative
				Absolute:SetDefine:ASE_ABSOLUTE_VERTEX_POS 1
				Absolute:SetPortName:Unlit:3,Vertex Position
				Relative:RemoveDefine:ASE_ABSOLUTE_VERTEX_POS 1
				Relative:SetPortName:Unlit:3,Vertex Offset
		ase_subshader_options:Name=Raycast Define
			Option:Raycast:On,Off:Off
				On:SetDefine:_RAYCAST_ON 1
				Off:RemoveDefine:_RAYCAST_ON 1
		*/

		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"Queue" = "Transparent+0"
            "ShaderModel" = "4.5"
		}

		HLSLINCLUDE
		#pragma target 4.5
		ENDHLSL

		/*ase_pass*/
		Pass
		{
			
			Name "Unlit"
			Tags { }

			Cull [_CullMode]
			Blend [_BlendSrc] [_BlendDst]
			ZTest [_ZTest]
			ZWrite Off
			ColorMask RGBA
			/*ase_stencil*/

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore

			// GPU Instancing

			// Material Keywords

			// Unity defined keywords
			#pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
			#pragma multi_compile_fragment _ DEBUG_DISPLAY

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXCommonOutputs.hlsl"
			#include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FXDebugging.hlsl"

			/*ase_pragma*/

			/*ase_globals*/
			half _Mode = -1;
			half _TransitionValue = 1;
			half _FogReceive = 0;

			struct Attributes
			{
				float4 positionOS : POSITION;
				half3 normalOS : NORMAL;
    			half4 tangentOS : TANGENT;
				float4 texcoord : TEXCOORD0;
				half4 color : COLOR;
				/*ase_vdata:p=p;n=n;t=t;c=c;uv0=tc0*/
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float4 uv0 : TEXCOORD0; 				// xy : uv or shadowCoord    zw : particle system vertex stream
				float4 uv1 : TEXCOORD1; 				// xyzw : custom data
				float4 fogCoord : TEXCOORD2; 		    // x : fogcoord				yzw :
				float3 positionWS : TEXCOORD11;
				float4 positionOS : TEXCOORD12;
				half3 normalWS : TEXCOORD13;
				/*ase_interp(3,):sp=sp;uv0=tc0;wp=tc11;p=tc12;wn=tc13*/
			};

			/*ase_funcs*/

			Varyings vert(Attributes input/*ase_vert_input*/)
			{
				Varyings output = (Varyings)0;

				/*ase_vert_code:input=Attributes;output=Varyings*/
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = input.positionOS.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = /*ase_vert_out:Vertex Offset;Float3;3;-1;_Vertex*/defaultVertexValue/*end*/;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					input.positionOS.xyz = vertexValue;
				#else
					input.positionOS.xyz += vertexValue;
				#endif

				VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);

				input.normalOS = /*ase_vert_out:Vertex Normal;Float3;4;-1;_VNormal*/input.normalOS/*end*/;

				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    			output.normalWS = normalInput.normalWS;
				output.uv0 = input.texcoord; // output.shadowCoord
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.positionOS = input.positionOS;
				output.positionCS = vertexInput.positionCS;
				output.fogCoord.x = CalculateFogCoord(vertexInput.positionCS.z);

				return output;
			}

			half4 frag(Varyings input/*ase_frag_input*/) : SV_Target
			{
				/*ase_frag_code:input=Varyings*/
				half3 color = /*ase_frag_out:color;Float3;0*/half3(1, 1, 1)/*end*/;
				half alpha = /*ase_frag_out:alpha;Float;1*/1/*end*/;

				half4 finalColor = half4(color, alpha);
				ApplyFogColor(finalColor, input.positionWS, input.normalWS, _Mode, _FogReceive, input.fogCoord.x);
				ApplyTransitionValue(finalColor, _Mode, _TransitionValue);

				// 디버그
				#if defined(DEBUG_DISPLAY)
				{
					return FXDebuggingColor(input, Color, Alpha);
				}
				#endif

				return finalColor;
			}
			ENDHLSL
		}
	}
	CustomEditor "MM.Client.Editor.ShaderGUI.MMN_FxBlendModeShaderGUI"
	FallBack Off
}
