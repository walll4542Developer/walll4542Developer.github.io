Shader "MMN/CutScene/Sky_AltarOfMorrighan"
{
    Properties
    {
        _StencilRef ("Stencil Ref", Int) = 0
        _MaskMap ("노이즈 텍스쳐(R) 별가루 (G) 헤일로(B) 검은달(A)", 2D) = "black" { }
        // _MaskMap2 ("노이즈 텍스쳐(R) 달 (G) 달 알파(B) 헤일로(A)", 2D) = "black" { }

        [Space(15)]
        [Header(Distortion Speed)]
        [Space(10)]
        // _DistortionSpeedMultix ("디스토션스피드 멀티플라이x. ", float) = 1
        // _DistortionSpeedMultiy ("디스토션 스피드 멀티플라이y. ", float) = 1
        _PolarDistortionSpeedMultix("폴라디스토션 스피드 멀티플라이x. ", float) = 1
        _PolarDistortionSpeedMultiy("폴라디스토션 스피드 멀티플라이x. ", float) = 1

        // [Space(30)]
        // // [HDR]_MainColor ("BaseTexColor", Color) = (1, 1, 1, 1)
        // [MainTex] _BaseTex ("구름레이어", 2D) = "black" { }
        // _BaseTexSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        // _BaseTexSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        // _Distortion ("디스토션1", float) = 0.1
        [Space(15)]
        [Header(BlackMoon)]
        [Space(10)]
        _BlackMoon ("달 타일링_크기조절 (XY) / 달 위치옵셋(ZW)", Vector) = (9.5, 5, -4.4, -2.1)


        [Space(10)]
        [HDR]_HaloColor ("헤일로 색상", color) = (1, 1, 1, 1)
        _HaloSpeedMultix ("헤일로 흐르는 속도 X", float) = 0
        _HaloSpeedMultiy ("헤일로 흐르는 속도 Y", float) = 0


        [HDR]_StarDustColor ("별가루 색상", Color) = (1, 1, 1, 1)


        [Space(30)]
        _SkyTex ("하늘 (RGB)  ", 2D) = "black" { }
        _SkyTexSpeedMultix ("하늘 흐르는 속도 X", float) = 0
        _SkyTexSpeedMultiy ("하늘 흐르는 속도 Y", float) = 0
        _SkyDistortion ("하늘 구겨지는 정도", float) = 0.1

        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0
    }

    SubShader
    {
        LOD 100

        Tags { "Queue" = "Transparent-395" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        ZClip False

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha

            Stencil
            {
                Ref [_StencilRef]
                Comp Equal
                Pass Keep
            }

            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)

                float4 _BaseTex_ST;
                float4 _BaseTex3_ST;
                float4 _SkyTex_ST;
                float4 _MaskMap_ST;

                float4 _StarDustColor;
                float4 _BlackMoon;
                float4 _MoonUV;

                float _Distortion;
                float _Distortion3;
                float _SkyDistortion;

                // float _SkyMultiply;
                float4 _HaloColor;

                // float _DistortionSpeedMultix;
                // float _DistortionSpeedMultiy;

                float _PolarDistortionSpeedMultix;
                float _PolarDistortionSpeedMultiy;

                // float _BaseTexSpeedMultix;
                // float _BaseTexSpeedMultiy;
                // float _BaseTex3SpeedMultix;
                // float _BaseTex3SpeedMultiy;
                float _SkyTexSpeedMultix;
                float _SkyTexSpeedMultiy;
                float _HaloSpeedMultix;
                float _HaloSpeedMultiy;

            CBUFFER_END


            TEXTURE2D(_MaskMap);        SAMPLER(sampler_MaskMap);
            TEXTURE2D(_MaskMap2);        SAMPLER(sampler_MaskMap2);
            TEXTURE2D(_BaseTex);        SAMPLER(sampler_BaseTex);
            TEXTURE2D(_BaseTex3);       SAMPLER(sampler_BaseTex3);
            TEXTURE2D(_SkyTex);       SAMPLER(sampler_SkyTex);

            SamplerState MMN_linear_repeat_sampler;
            SamplerState MMN_linear_clamp_sampler;

            #include "../Includes/bendingVertex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                float2 staticLightmapUV : TEXCOORD1;
                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float3 normalWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
                float3 cameraDir : TEXCOORD4;
                // DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = input.texcoord ;
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.positionCS.z = 0;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                output.cameraDir = normalize(mul((float3x3)unity_CameraToWorld, float3(0, 0, 1)));

                return output;
            }

            float2 uvScroll(float2 uv, float x, float y, float speedmul)
            {
                InitializeGlobalValue();
                return uv + (_Global_WindUV * float2(x, y) * speedmul * 2);
            }

            float2 PolarCoordinates(float2 UV, float2 Center, float LengthScale)
            {
                float2 delta = UV - Center;
                float radius = length(delta) * 2 ;
                float angle = atan2(delta.x, delta.y) * 1.0 / 6.28 * LengthScale;
                return float2(radius, angle);
            }

            float2 Rotate(float2 UV, float2 Center, float Rotation)
            {
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1;
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;
                return UV;
            }

            // Used for StandardSimpleLighting shader
            float4 LitPassFragmentSimple(Varyings input) : SV_Target
            {

                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //애니에서 덜컥거리는걸 방지하기 위해 정수로 받게 한다. 아예 int로 받게 해도 되지만 안전을 위해.
                // _DistortionSpeedMultix = round(_DistortionSpeedMultix);
                // _DistortionSpeedMultiy = round(_DistortionSpeedMultiy);
                _PolarDistortionSpeedMultix = round(_PolarDistortionSpeedMultix);
                _PolarDistortionSpeedMultiy = round(_PolarDistortionSpeedMultiy);
                // _BaseTexSpeedMultix = round(_BaseTexSpeedMultix);
                // _BaseTexSpeedMultiy = round(_BaseTexSpeedMultiy);
                // _BaseTex3SpeedMultix = round(_BaseTex3SpeedMultix);
                // _BaseTex3SpeedMultiy = round(_BaseTex3SpeedMultiy);
                _SkyTexSpeedMultix = round(_SkyTexSpeedMultix);
                _SkyTexSpeedMultiy = round(_SkyTexSpeedMultiy);
                _HaloSpeedMultix = round(_HaloSpeedMultix);
                _HaloSpeedMultiy = round(_HaloSpeedMultiy);

                float2 uv = input.uv;

                // 헤일로 연산 좌우 움직임을 위해서 카메라 디렉션과 닷 처리
                // float3 cameraDir = normalize(input.cameraDir);
                // float dottest = dot(cameraDir, float3(1, 0, 0)); //90도 돌린곳과 닷 연산

                //////////////////// 텍스쳐 준비/////////////////////////

                //폴라 UV 입니다.
                //가로가 긴 UV  비율을 맞추기 위해 가로에 1.5 곱합니다.
                //그래서 틀어진 위치를 보정하고, 보정하는 김에 검은 달 가운데로 위치 시키기 위해 매직넘버를 넣습니다.
                float2 polarUV = PolarCoordinates(uv * float2(1.5, 1), float2(0.76, 0.52), 1) ;

                //마스크맵 UV
                // float2 maskMapUV = TRANSFORM_TEX(uvScroll(uv, _DistortionSpeedMultix, _DistortionSpeedMultiy, 0.01), _MaskMap);
                float2 maskMapPolarUV = TRANSFORM_TEX(uvScroll(polarUV, _PolarDistortionSpeedMultix, _PolarDistortionSpeedMultiy, 0.01), _MaskMap);
                float2 skyMapPolarUV = TRANSFORM_TEX(uvScroll(polarUV, _SkyTexSpeedMultix, _SkyTexSpeedMultiy, 0.01), _MaskMap);
                float2 haloMapPolarUV = TRANSFORM_TEX(uvScroll(polarUV, _HaloSpeedMultix, _HaloSpeedMultiy, 0.01), _MaskMap);

                //마스크맵 만들기
                // float4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, maskMapUV);
                float4 maskMapPolar = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, maskMapPolarUV  * 0.5 /*타일링*/);
                float4 skyMapPolar = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, skyMapPolarUV  * 0.5 /*타일링*/);
                float4 haloMapPolar = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, haloMapPolarUV  * 0.5 /*타일링*/);
                // float4 maskMap2 = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, float2(polarUV.x - _Global_WindUV, polarUV.y));

                float polarNoise = maskMapPolar.r;
                float skyPolarNoise = skyMapPolar.r;
                float haloMapPolarNoise = haloMapPolar.r;
                // float Noise = maskMap.r;


                //하늘
                float2 skymapUV = TRANSFORM_TEX(uv, _SkyTex);
                float4 skymap = SAMPLE_TEXTURE2D(_SkyTex, sampler_SkyTex, skymapUV + skyPolarNoise * _SkyDistortion * 0.003) ;

                //헤일로
                float2 blackMoonUV = uv * _BlackMoon.xy + _BlackMoon.zw;
                InitializeGlobalValue();
                blackMoonUV = Rotate(blackMoonUV, float2(0.5, 0.5), _Global_WindUV * 5);
                float4 halo = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_clamp_sampler, blackMoonUV + haloMapPolarNoise * 0.04/*구겨지는 정도*/);

                //검은 달
                //UV는 헤일로와 같은것을 씁니다.
                float4 blackMoon = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, blackMoonUV + polarNoise* 0.01);

                //별가루
                float2 starDustUV = TRANSFORM_TEX(uvScroll(polarUV , _PolarDistortionSpeedMultix * 3, _PolarDistortionSpeedMultiy, 0.05), _MaskMap);
                float4 starDust = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, starDustUV  + polarNoise * 2 /*구겨지는 정도*/);


                //////////////////// 최종연산 /////////////////////////


                float4 color ;
                //하늘을 일단 넣고
                color.rgb = skymap.rgb;
                //헤일로를 더하고
                color.rgb += halo.bbb * _HaloColor.rgb;
                //검은 달이 나오게 lerp합니다.
                color.rgb = lerp(color.rgb, float3(0, 0, 0), blackMoon.a);
                //다시 헤일로를 더하고
                color.rgb += halo.bbb * 0.1;
                //별가루를 더함
                color.rgb += starDust.g * halo.b * _StarDustColor.rgb;


                color.a = 1;

                // if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
                // return 0;
                // else

                return color ;
            };
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"

}
