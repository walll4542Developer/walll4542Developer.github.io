Shader "MM/FX/AreaIndicator_TEMP_Debug"
{
    Properties
    {
        _UnfilledColor("UnfilledColor", Color) = (1, 1, 1, 1)
        _FilledColor("FilledColor", Color) = (1, 1, 1, 1)

        _Radius("Radius", Float) = 0.5
        _Direction("Direction", vector) = (0, 0, 0, 0)
        _LineWidth("LineWidth", Float) = 0.1
        _FillRate("FillRate", Range(0,1)) = 0.0

        _StencilValue("스탠실 Ref", Integer) = 10
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("스탠실 Comp", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail("스탠실 ZFail", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("스탠실 Pass", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail("스탠실 Fail", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 0
        _Opaque("Opaque 적용", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent-199"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "Indicator"
            Tags { "LightMode" = "Indicator" }

            Stencil
            {
                Ref [_StencilValue]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail [_StencilFail]
                ZFail [_StencilZFail]
            }

            //Blend One OneMinusSrcAlpha
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest [_ZTest]
            Cull Off
            //ColorMask RGB

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 3.0

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50 nolightprobe nolightmap

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            //GlobalVariables
            // half _Global_CloudDensity;
            // half _Global_CloudSpeed;
            // half _Global_CloudScale;
            // half _Global_CloudEdgeHardness;

            #include "../../MMN/Includes/BendingVertex.hlsl"
            #include "../../MMN/FX/Includes/FX_AreaIndicator_CalculateDepth.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                real4 color : COLOR;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;      // World space position
                half fogFactor : TEXCOORD2;
                float4 projectedPosition : TEXCOORD3;
                float3 refPositionWS : TEXCOORD4;   // World space center

                real4 color : COLOR0;               // low-precision, 0–1 range data
                float4 positionCS : SV_POSITION;    // Homogeneous clip space position

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
                real4 _UnfilledColor;
                real4 _FilledColor;
                float _Radius;
                float4 _Direction;
                float _LineWidth;
                float _FillRate;
                float _Opaque;
            CBUFFER_END

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                output.uv = input.texcoord;

                VertexPositionInputs bentVertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
                VertexPositionInputs bentVertexRefInput = GetVertexPositionInputsForBending(float3(0.0, 0.0, 0.0));

                output.positionWS = bentVertexInput.positionWS;
                output.positionCS = bentVertexInput.positionCS;
                output.refPositionWS = bentVertexRefInput.positionWS;
                output.projectedPosition = bentVertexInput.positionNDC;

                output.color = input.color;

                output.fogFactor = ComputeFogFactor(output.positionCS.z);

                return output;
            }

            real4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                
                // NOTE @hanseok 2022-12-13: 1미터 단위로 라인을 그어주기 위해서 추가된 코드입니다.                
                float dist = length(input.refPositionWS.xyz - input.positionWS.xyz);

                // NOTE @hanseok 2022-12-13: 1미터 단위로 라인을 그어주기 위해서 추가된 코드입니다.
                // frac 함수를 통해 소수점 값을 얻어 라인 굵기의 반만큼 보다 작을 경우 라인을 표시해야하는 것으로 인식합니다.
                float forwardSideLine = step(frac(dist), _LineWidth*.5);
                // ceil 함수로 올림을 한 정수의 값에서 기존 값을 뺀 나머지 값이 라인 굵기의 반만큼 보다 작을 경우 라인을 표시해야하는 것으로 인식합니다.
                float backSideLine = step(ceil(dist)-dist, _LineWidth*.5);
                
                // NOTE @hanseok 2022-12-13: AreaIndicator_TEMP_Arc 셰이더의 코드를 그대로 가지고 와서 각도를 구합니다.
                float3 normalizedDirection = normalize(_Direction.xyz);
                float3 pointDirection = input.positionWS.xyz -  input.refPositionWS.xyz;
                float3 normalizedPointDirection = normalize(pointDirection);
                float dotScalar = dot(normalizedDirection, normalizedPointDirection);
                float degree = degrees(acos(dotScalar));

                // NOTE @hanseok 2022-12-13: 30도보다 각도가 작을 때 렌더링 영역이 두껍게 보이는 현상, 180도일 때 라인이 나오지 않는 현상을 해소하기 위해서 아래 예외 처리를 하였습니다.
                float angleLine = degree < 30.0f ? step(degree%30, 1.0) : degree > 179.0 ? 1.0 : step(degree%30, 2.0);                

                // NOTE @hanseok 2022-12-13: 바깥 원 영역일 경우 렌더링 대상에 속합니다.
                float isOutline = (dist <= _Radius && dist > _Radius - _LineWidth) ? 1 : 0;

                // NOTE @hanseok 2022-12-13: 앞쪽, 뒷쪽의 라인에 해당하거나 30도 단위의 각도를 표시해야 할 경우 isDrawLine의 값은 1이 됩니다.
                float isDrawLine = clamp(forwardSideLine + backSideLine + angleLine + isOutline, 0, 1);

                // NOTE @hanseok 2022-12-13: 지정된 영역 안에 해당할 경우에만 렌더링 대상에 속합니다.
                float draw = step(dist, _Radius);
                real4 color = lerp(_FilledColor, _UnfilledColor, step((_Radius - _LineWidth) * _FillRate, dist) * step(dist, _Radius - _LineWidth));

                // NOTE @hanseok 2022-12-13: 지정된 영역 안에서 라인 표시를 해야할 경우에만 알파 값을 가지고 그 이외의 경우에는 알파가 0입니다.
                real4 result = real4(color.rgb, color.a * draw * isDrawLine);

                result.rgb = MixFog(result.rgb, input.fogFactor.x);

                if (_Opaque < 0.5)
                {
                    result.a = CalculateDepthAlpha(input.projectedPosition.xy / input.projectedPosition.w, _ZBufferParams, input.positionWS.xyz, result.a);
                    result.rgb = CalculateGreyScale(result.rgb, result.a);
                }

                return result;
            }

            ENDHLSL
        }
    }
}

