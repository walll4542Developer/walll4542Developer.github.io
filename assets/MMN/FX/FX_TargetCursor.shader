Shader "MMN/FX/FX_TargetCursor"
{
    Properties
    {
        [Header(Texture)]
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor ("Color", color) = (1, 1, 1, 1)
        
        [HideInInspector] _IsEnding ("Ending", float) = 0.0
        [HideInInspector] _StartTime ("StartTime", float) = 0.0

        [Space]    
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 8
    }
    SubShader
    {
        Tags 
        { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        ZTest [_ZTest]
        Cull off

        Pass
        {
            Name "Loop"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UnlitPassVertex
            #pragma fragment UnlitPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #define ROTATE_TIME 5.0
            #define ROTATE_COUNT 2.0
            #define SCALE_START 0.35
            #define SCALE_END 0.25
            #define ALPHA_START 0.2

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            
            float4 _BaseMap_ST;
            half4 _BaseColor;
            float _IsEnding;
            float _StartTime;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            float cheapstep(float x)
            {
                return 1.0 - pow(1.0 - x * x, 2.0);
            }

            float2 RotateScaleUV(float2 uv, float degrees, float scale)
            {
				// rotation
                float radian = DegToRad(degrees);
                float s, c;
                sincos(radian, s, c);        
                float2x2 rotationMatrix = float2x2(c, -s, s, c);

				// scale                
                float scaleStart = saturate(pow(scale, 2.0)) * 1.5;
                float scaleEnd = 2.0 - (1.0 - pow(scale, 2.0)) * 0.5;
                float scaleResult = lerp(scaleStart, scaleEnd, _IsEnding);

                uv -= 0.5;
                uv = mul(rotationMatrix, uv);
                uv *= scaleResult;
                uv += 0.5;
                
                return uv;
            }

            float CalcAlpha()
            {
                float startEndAlphaTime = ALPHA_START; //lerp(ALPHA_START, ALPHA_END, _IsEnding);
                float alphaTime = (_Time.y - _StartTime) / startEndAlphaTime;

                float alphaStart = saturate(pow(1.0 - alphaTime, 2.0) * 0.1);
                float alphaEnd = pow(1.0 - alphaTime, 3.0);
                float alphaResult = lerp(alphaStart, alphaEnd, _IsEnding);

                return saturate(alphaResult);
            }

            float2 CalcAnimation(half2 uv)
            {
				// rotation
                float rotateTime = frac(_Time.y / ROTATE_TIME * 2.0);
                float rotateFactor = cheapstep(rotateTime);
                float degress = rotateFactor * 360.0 * ROTATE_COUNT;
                
				// scale
                float startEndScaleTime = lerp(SCALE_START, SCALE_END, _IsEnding);
                float scaleTime = (_Time.y - _StartTime) / startEndScaleTime;
                
                float2 rotateResult = RotateScaleUV(uv, degress, scaleTime);
                return rotateResult;
            }

            void BillboardVert(inout Attributes input)
            {
                float4x4 objectToWorld = GetObjectToWorldMatrix();
                float4x4 worldToView = GetWorldToViewMatrix();

                input.positionOS.xy *= float2(length(objectToWorld._m00_m10_m20), length(objectToWorld._m01_m11_m21));

                float3 right = normalize(worldToView._m00_m01_m02);
                float3 up = float3(0.0, 1.0, 0.0);
                up = normalize(worldToView._m10_m11_m12);
                float3 forward = -normalize(worldToView._m20_m21_m22);

                float4x4 rotationMatrix;
                rotationMatrix = float4x4(
                    right,         0.0,
                    up,            0.0,
                    forward,       0.0,
                    0.0, 0.0, 0.0, 1.0);

                input.positionOS = mul(input.positionOS, rotationMatrix);
                input.positionOS.xyz = mul((float3x3)GetWorldToObjectMatrix(), input.positionOS.xyz);
            }

            Varyings UnlitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                
				// 빌보드 적용
                BillboardVert(input);

                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                return output;
            } 

            half4 UnlitPassFragment(Varyings input) : SV_Target
            {                
                half2 uv = input.uv;
                
				// Rotation + Scale
                float2 resultUV = CalcAnimation(uv);
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, resultUV);

				// Alpha  
                float resultAlpha = CalcAlpha();

				// Result
                half4 finalColor = texColor * _BaseColor;
                finalColor.a *= resultAlpha;

                return finalColor;
            }

            ENDHLSL
        }
    }

    Fallback off
}
