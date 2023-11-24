Shader "MMN/CutScene/Sky_DarkNaozone"
{
    Properties
    {
        _StencilRef ("Stencil Ref", Int) = 0
        _MaskMap ("노이즈 텍스쳐(R) 달 (G) 달 알파(B) 헤일로(A)", 2D) = "black" { }
        _DistortionSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _DistortionSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        
        [Space(30)]
        // [HDR]_MainColor ("BaseTexColor", Color) = (1, 1, 1, 1)
        [MainTex] _BaseTex ("구름레이어", 2D) = "black" { }
        _BaseTexSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTexSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion ("디스토션1", float) = 0.1

        [Space(30)]
        [HDR]_HaloColor ("헤일로 칼라", color) = (1, 1, 1, 1)
        _HaloUV ("헤일로 타일링 (XY) 옵셋(ZW)", Vector) = (1, 1, 0, 0)

        [Space(30)]
        [HDR]_RedMoonColor ("달 색상", Color) = (1, 1, 1, 1)
        _MoonUV ("달 타일링 (XY) 옵셋(ZW)", Vector) = (1, 1, 0, 0)

        [Space(30)]
        // [HDR]_MainColor3 ("BaseTexColor3", Color) = (1, 1, 1, 1)
        _BaseTex3 ("별 (A)", 2D) = "black" { }
        _BaseTex3SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTex3SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion3 ("디스토션3. 별 반짝임 간격으로 쓰임 ", Range(0, 1)) = 0.1

        [Space(30)]
        // [HDR]_MainColor4 ("BaseTexColor4", Color) = (1, 1, 1, 1)
        _BaseTex4 ("하늘 (RGB)  ", 2D) = "black" { }
        _BaseTex4SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _BaseTex4SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        // _Distortion4 ("디스토션4", float) = 0.1
        _SkyMultiply ("하늘의 불길한 멀티플라이 ", float) = 2
        _Distortion4 ("디스토션4. 하늘에 노이즈 디스토션", float) = 0.1
        
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent-395" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300
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
                float4 _BaseTex3_ST;
                float4 _BaseTex4_ST;
                float4 _MaskMap_ST;
                
                float4 _RedMoonColor;
                float4 _HaloUV;
                float4 _MoonUV;

                float _Distortion;
                float _Distortion3;
                float _Distortion4;
                
                float _SkyMultiply;
                float4 _HaloColor;
                
                float _DistortionSpeedMultix;
                float _DistortionSpeedMultiy;
                
                float _BaseTexSpeedMultix;
                float _BaseTexSpeedMultiy;
                float _BaseTex3SpeedMultix;
                float _BaseTex3SpeedMultiy;
                float _BaseTex4SpeedMultix;
                float _BaseTex4SpeedMultiy;

            CBUFFER_END


            TEXTURE2D(_MaskMap);        SAMPLER(sampler_MaskMap);
            TEXTURE2D(_BaseTex);        SAMPLER(sampler_BaseTex);
            TEXTURE2D(_BaseTex3);       SAMPLER(sampler_BaseTex3);
            TEXTURE2D(_BaseTex4);       SAMPLER(sampler_BaseTex4);

            SamplerState MMN_linear_repeat_sampler;

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
                half3 normalWS : TEXCOORD2;
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

                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_TRANSFER_INSTANCE_ID(input, output);
                // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

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
                return uv + frac(_Global_WindUV * float2(x, y) * speedmul * 2);
            }
            
            // Used for StandardSimpleLighting shader
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //애니에서 덜컥거리는걸 방지하기 위해 정수로 받게 한다. 아예 int로 받게 해도 되지만 안전을 위해.
                _DistortionSpeedMultix = round(_DistortionSpeedMultix);
                _DistortionSpeedMultiy = round(_DistortionSpeedMultiy);
                _BaseTexSpeedMultix = round(_BaseTexSpeedMultix);
                _BaseTexSpeedMultiy = round(_BaseTexSpeedMultiy);
                _BaseTex3SpeedMultix = round(_BaseTex3SpeedMultix);
                _BaseTex3SpeedMultiy = round(_BaseTex3SpeedMultiy);
                _BaseTex4SpeedMultix = round(_BaseTex4SpeedMultix);
                _BaseTex4SpeedMultiy = round(_BaseTex4SpeedMultiy);

                float2 uv = input.uv;

                // 헤일로 연산 좌우 움직임을 위해서 카메라 디렉션과 닷 처리
                float3 cameraDir = normalize(input.cameraDir);
                float dottest = dot(cameraDir, float3(1, 0, 0)); //90도 돌린곳과 닷 연산

                //////////////////// 텍스쳐 준비/////////////////////////
                
                //마스크맵
                float2 maskMapUV = TRANSFORM_TEX(uvScroll(uv, _DistortionSpeedMultix, _DistortionSpeedMultiy, 0.01), _MaskMap);
                half4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, MMN_linear_repeat_sampler, maskMapUV);
                //구름 텍스쳐
                float2 basemapUV = TRANSFORM_TEX(uvScroll(uv, _BaseTexSpeedMultix, _BaseTexSpeedMultiy, 0.01), _BaseTex);
                half4 basemap = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, basemapUV + maskMap.r * _Distortion * 0.001);
                //달 텍스쳐
                float2 redMoonUV = uv * _MoonUV.xy + _MoonUV.zw;
                half4 redMoon = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, redMoonUV + maskMap.r /* * _Distortion2*/ * 0.001) ;
                //헤일로 텍스쳐
                float2 haloTexUV = uv * _HaloUV.xy + _HaloUV.zw ;
                haloTexUV.x += 0.2 * dottest; //카메라 방향에 따라 헤일로가 좌우로 조금 움직임
                half4 haloTex = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, haloTexUV) ;
                //별 텍스쳐
                half4 basemap3 = SAMPLE_TEXTURE2D(_BaseTex3, sampler_BaseTex3, TRANSFORM_TEX(uv, _BaseTex3)) ;
                //마스크맵을 반짝임으로 이용한다
                //별이 두 배 반짝
                //마스크를 스탭으로, 별이 반짝이게 만들고 0.3을 더해 너무 없어지지 않게 한다
                //별 텍스쳐 RGB는 사실상 쓰지 않는다. 그래서 4번 텍스쳐랑 동시에 쓴다. 여긴 A만 쓴다.
                basemap3.a *= saturate(step(_Distortion3, maskMap.r) + 0.3);
                float2 basemap4UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex4SpeedMultix, _BaseTex4SpeedMultiy, 0.01), _BaseTex4);
                half4 basemap4 = SAMPLE_TEXTURE2D(_BaseTex4, sampler_BaseTex4, basemap4UV + maskMap.r * _Distortion4 * 0.001) ;


                //////////////////// 최종연산 /////////////////////////

                
                float4 color ;
                //하늘을 일단 넣고
                color.rgb = basemap4.rgb + pow(abs(basemap4.rgb), 1.5) * _SkyMultiply;
                //별 칼라는 일단 2로
                color.rgb = lerp(color.rgb, 2, basemap3.a);
                // 달을 더한다
                // redMoon.g = saturate(redMoon.g - (basemap.a)) ;//구름에 가려졌을때 어둡게
                color.rgb = lerp(color.rgb, redMoon.g * _RedMoonColor.rgb, redMoon.b) + pow((redMoon.g * _RedMoonColor.rgb * redMoon.b) /* * _MoonMultiply */, 4);
                //헤일로를 더하고
                color.rgb += _HaloColor.rgb * haloTex.a ;
                //구름을 lerp 한다
                color.rgb = lerp(color.rgb, basemap.rgb, basemap.a);

                color.a = 1;
                
                // if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
                // return 0;
                // else
                    return color;
            };
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"

}
