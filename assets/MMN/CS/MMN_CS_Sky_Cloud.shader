Shader "MMN/CutScene/Sky_Clouds"
{
    Properties
    {
        _StencilRef("Stencil Ref", Int) = 0
        _MaskMap ("Mask Map", 2D) = "black" { }
        _DistortionSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _DistortionSpeedMultiy ("스피드 멀티플라이y. ", float) = 0

        [Space(30)]
        // [HDR]_MainColor ("BaseTexColor", Color) = (1, 1, 1, 1)
        [MainTex] _BaseTex ("BaseTex", 2D) = "black" { }
        _BaseTexSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTexSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion ("디스토션1", float) = 0.1

        [Space(30)]
        // [HDR]_MainColor2 ("BaseTexColor2", Color) = (1, 1, 1, 1)
        _BaseTex2 ("BaseTex2", 2D) = "black" { }
        _BaseTex2SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTex2SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion2 ("디스토션2", float) = 0.1

        [Space(30)]
        // [HDR]_MainColor3 ("BaseTexColor3", Color) = (1, 1, 1, 1)
        _BaseTex3 ("BaseTex3", 2D) = "black" { }
        _BaseTex3SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTex3SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion3 ("디스토션3", float) = 0.1

        [Space(30)]
        // [HDR]_MainColor4 ("BaseTexColor4", Color) = (1, 1, 1, 1)
        _BaseTex4 ("BaseTex4", 2D) = "black" { }
        _BaseTex4SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTex4SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion4 ("디스토션4", float) = 0.1

        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        [HideInInspector] _Color ("Alpha", Color) = (1, 1, 1, 1)
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

            // Use same blending / depth states as Standard shader
            // Blend[_SrcBlend][_DstBlend]
            Blend SrcAlpha OneMinusSrcAlpha
            // Blend One Zero

            // Blend one OneMinusSrcAlpha
            // Blend One OneMinusSrcAlpha, SrcAlpha One
            // Blend One Zero, One One
            // ZWrite[_ZWrite]
            // Ztest LEqual

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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseTex_ST;
                float4 _BaseTex2_ST;
                float4 _BaseTex3_ST;
                float4 _BaseTex4_ST;

                float4 _MaskMap_ST;
                float _Distortion;
                float _Distortion2;
                float _Distortion3;
                float _Distortion4;

                float _DistortionSpeedMultix;
                float _DistortionSpeedMultiy;

                float _BaseTexSpeedMultix;
                float _BaseTexSpeedMultiy;
                float _BaseTex2SpeedMultix;
                float _BaseTex2SpeedMultiy;
                float _BaseTex3SpeedMultix;
                float _BaseTex3SpeedMultiy;
                float _BaseTex4SpeedMultix;
                float _BaseTex4SpeedMultiy;

                float4 _Color;
            CBUFFER_END

            //Global Property
            float4 _Global_CloudColor;
            float4 _Global_CloudColor2;
            float4 _Global_CloudColor3;
            float4 _Global_CloudColor4;

            // float _Global_CloudDensity;
            // float _Global_CloudSpeed;
            // float _Global_CloudScale;
            // float _Global_CloudEdgeHardness;
            float _Global_Night2Day;

            TEXTURE2D(_MaskMap);        SAMPLER(sampler_MaskMap);
            TEXTURE2D(_BaseTex);        SAMPLER(sampler_BaseTex);
            TEXTURE2D(_BaseTex2);       SAMPLER(sampler_BaseTex2);
            TEXTURE2D(_BaseTex3);       SAMPLER(sampler_BaseTex3);
            TEXTURE2D(_BaseTex4);       SAMPLER(sampler_BaseTex4);

            #include "../Includes/bendingVertex.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                float2 staticLightmapUV : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float3 normalWS : TEXCOORD2;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수
                VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);//카메라 상하 가중치
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = input.texcoord ;
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.positionCS.z = 0;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
                return output;
            }

            float2 uvScroll(float2 uv, float x, float y, float speedmul)
            {
                InitializeGlobalValue();
                return uv + frac(_Global_WindUV * float2(x, y) * speedmul * 2);
            }

            // Used for StandardSimpleLighting shader
            float4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);


                //애니에서 덜컥거리는걸 방지하기 위해 정수로 받게 한다. 아예 int로 받게 해도 되지만 안전을 위해.
                _DistortionSpeedMultix = round(_DistortionSpeedMultix);
                _DistortionSpeedMultiy = round(_DistortionSpeedMultiy);
                _BaseTexSpeedMultix = round(_BaseTexSpeedMultix);
                _BaseTexSpeedMultiy = round(_BaseTexSpeedMultiy);
                _BaseTex2SpeedMultix = round(_BaseTex2SpeedMultix);
                _BaseTex2SpeedMultiy = round(_BaseTex2SpeedMultiy);
                _BaseTex3SpeedMultix = round(_BaseTex3SpeedMultix);
                _BaseTex3SpeedMultiy = round(_BaseTex3SpeedMultiy);
                _BaseTex4SpeedMultix = round(_BaseTex4SpeedMultix);
                _BaseTex4SpeedMultiy = round(_BaseTex4SpeedMultiy);

                float2 uv = input.uv;

                float2 maskMapUV = TRANSFORM_TEX(uvScroll(uv, _DistortionSpeedMultix, _DistortionSpeedMultiy, 0.01), _MaskMap);
                float4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, maskMapUV);

                float2 basemapUV = TRANSFORM_TEX(uvScroll(uv, _BaseTexSpeedMultix, _BaseTexSpeedMultiy, 0.01), _BaseTex);
                float4 basemap = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, basemapUV + maskMap.r * _Distortion * 0.001) * _Global_CloudColor;

                float2 basemap2UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex2SpeedMultix, _BaseTex2SpeedMultiy, 0.01), _BaseTex2);
                float4 basemap2 = SAMPLE_TEXTURE2D(_BaseTex2, sampler_BaseTex2, basemap2UV + maskMap.r * _Distortion2 * 0.001) * _Global_CloudColor2;

                float2 basemap3UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex3SpeedMultix, _BaseTex3SpeedMultiy, 0.01), _BaseTex3);
                float4 basemap3 = SAMPLE_TEXTURE2D(_BaseTex3, sampler_BaseTex3, basemap3UV + maskMap.r * _Distortion3 * 0.001) * _Global_CloudColor3;

                float2 basemap4UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex4SpeedMultix, _BaseTex4SpeedMultiy, 0.01), _BaseTex4);
                float4 basemap4 = SAMPLE_TEXTURE2D(_BaseTex4, sampler_BaseTex4, basemap4UV + maskMap.r * _Distortion4 * 0.001) * _Global_CloudColor4;


                //검은 테두리를 흰색으로 감쇄시킨다. 리소스를 수정하는게 더 좋지만 psd작업 편의를 위해
                // #define preAddInvAlpha 0.4
                // basemap.rgb += (1-basemap.a) * preAddInvAlpha;
                // basemap2.rgb += (1-basemap2.a) * preAddInvAlpha;
                // basemap3.rgb += (1-basemap3.a) * preAddInvAlpha;
                // basemap4.rgb += (1-basemap4.a) * preAddInvAlpha;


                ///////////////Light 연산
                Light light = GetMainLight();
                float3 bakedGI = SampleSHPixel(input.vertexSH, normalize(input.normalWS)) * _Global_GILightMulti.rgb  ;

                //구름 텍스쳐 연산
                // float3 basemapav = (basemap4+ basemap3+basemap2+basemap)/4;
                basemap4.rgb = lerp(_Global_CloudColor4.rgb + bakedGI * 0.5, basemap4.rgb, basemap4.a);
                // basemap4.rgb = lerp(_Global_CloudColor4.rgb,basemap4.rgb, basemap4.a); //아웃라인 칼라 수동조정
                basemap3.rgb = lerp(basemap4.rgb, basemap3.rgb, basemap3.a);
                basemap2.rgb = lerp(basemap3.rgb, basemap2.rgb, basemap2.a);
                basemap.rgb = lerp(basemap2.rgb, basemap.rgb, basemap.a);

                float4 color ;

                //구름 알파 연산
                //현재 두 방식의 차이는 없다
                // color.a =  saturate(basemap3.a + basemap4.a + basemap2.a +  basemap.a) ;
                color.a = max(basemap4.a, max(basemap3.a, max(basemap2.a, basemap.a))) ;
                // color.a = 1;

                /////////////////칼라 연산////////////////////////
                color.rgb = lerp(bakedGI * 0.8 * color.a, light.color + bakedGI * color.a * 0.5, basemap.r) * basemap.rgb;
                // color.rgb =  basemap.rgb ;
                // color.rgb = bakedGI.rgb* _Global_GILightMulti.rgb  ;

                color.a = color.a * _Color.a;

                if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
                    return 0;
                else
                    return color;

            };
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"

}
