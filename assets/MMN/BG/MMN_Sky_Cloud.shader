Shader "MMN/BG/Sky_Clouds"
{
    Properties
    {
        [Header(Distortion Mask _______________________)]
        [Space(10)]
        _MaskMap ("Mask Map", 2D) = "black" { }
        _DistortionSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        _DistortionSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        
        [Space(20)]
        [Header(Clouds ________________________________)]
        [Space(10)]
        // [HDR]_MainColor ("BaseTexColor", Color) = (1, 1, 1, 1)
        [MainTex] _BaseTex ("BaseTex", 2D) = "black" { }
        _BaseTexSpeedMultix ("스피드 멀티플라이x. ", float) = 0
        // _BaseTexSpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion ("디스토션1", float) = 0.1
        [Toggle]_YTiling ("Y 타일링을 할 것인지?", float) = 1

        [Space(20)]
        // [HDR]_MainColor2 ("BaseTexColor2", Color) = (1, 1, 1, 1)
        _BaseTex2 ("BaseTex2", 2D) = "black" { }
        _BaseTex2SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        // _BaseTex2SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion2 ("디스토션2", float) = 0.1
        [Toggle]_YTiling2 ("Y 타일링을 할 것인지?", float) = 1

        [Space(20)]
        // [HDR]_MainColor3 ("BaseTexColor3", Color) = (1, 1, 1, 1)
        _BaseTex3 ("BaseTex3", 2D) = "black" { }
        _BaseTex3SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        // _BaseTex3SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion3 ("디스토션3", float) = 0.1
        [Toggle]_YTiling3 ("Y 타일링을 할 것인지?", float) = 1

        [Space(30)]
        [Header(Dark Clouds__________________________)]
        [Space(10)]
        // [HDR]_MainColor4 ("BaseTexColor4", Color) = (1, 1, 1, 1)
        _BaseTex4 ("먹구름 전용", 2D) = "black" { }
        _BaseTex4SpeedMultix ("스피드 멀티플라이x. ", float) = 0
        // _BaseTex4SpeedMultiy ("스피드 멀티플라이y. ", float) = 0
        _Distortion4 ("디스토션4", float) = 0.1
        [Toggle]_YTiling4 ("Y 타일링을 할 것인지?", float) = 1

        [Space(30)]
        [Header(Stars_ UV2__________________________)]
        [Space(10)]

        [Header(Texture)]
        _StarMap ("Emission Map.", 2D) = "black" { }
        _StarSpeedMultix ("스피드 멀티플라이x. 글로벌 볼륨값에 곱해짐", float) = 0
        _StarSpeedMultiy ("스피드 멀티플라이y. 글로벌 볼륨값에 곱해짐", float) = 0
        [HDR]_StarColor ("Emission Color", Color) = (1, 1, 1, 1)
        // _StarDistortion ("디스토션 적용값", float) = 0.0
        
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent-399" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300
        ZClip False

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "SkyLit" }

            // Use same blending / depth states as Standard shader
            // Blend[_SrcBlend][_DstBlend]
            Blend SrcAlpha OneMinusSrcAlpha
            // Blend One Zero
            
            // Blend one OneMinusSrcAlpha
            // Blend One OneMinusSrcAlpha, SrcAlpha One
            // Blend One Zero, One One
            // ZWrite[_ZWrite]
            // Ztest LEqual
            
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
                float4 _StarMap_ST;

                float4 _MaskMap_ST;
                float _Distortion;
                float _Distortion2;
                float _Distortion3;
                float _Distortion4;
                // float _StarDistortion;
                
                float _DistortionSpeedMultix;
                float _DistortionSpeedMultiy;
                
                float _BaseTexSpeedMultix;
                // float _BaseTexSpeedMultiy;
                float _BaseTex2SpeedMultix;
                // float _BaseTex2SpeedMultiy;
                float _BaseTex3SpeedMultix;
                // float _BaseTex3SpeedMultiy;
                float _BaseTex4SpeedMultix;
                // float _BaseTex4SpeedMultiy;
                float _StarSpeedMultix;
                float _StarSpeedMultiy;

                float _YTiling;
                float _YTiling2;
                float _YTiling3;
                float _YTiling4;

                float4 _StarColor;
            CBUFFER_END

            //Global Property
            half4 _Global_CloudColor;
            half4 _Global_CloudColor2;
            half4 _Global_CloudColor3;
            half4 _Global_CloudColor4;
            float4 _GlobalSkyUnlitColor;
            
            // half _Global_CloudDensity;
            // half _Global_CloudSpeed;
            // half _Global_CloudScale;
            // half _Global_CloudEdgeHardness;
            half _Global_Night2Day;

            TEXTURE2D(_MaskMap);        SAMPLER(sampler_MaskMap);
            TEXTURE2D(_BaseTex);        SAMPLER(sampler_BaseTex);
            TEXTURE2D(_BaseTex2);       SAMPLER(sampler_BaseTex2);
            TEXTURE2D(_BaseTex3);       SAMPLER(sampler_BaseTex3);
            TEXTURE2D(_BaseTex4);       SAMPLER(sampler_BaseTex4);
            TEXTURE2D(_StarMap);       SAMPLER(sampler_StarMap);

            #include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float4 color : COLOR;
                float2 staticLightmapUV : TEXCOORD1;
                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float3 positionWS : TEXCOORD2;    // xyz: posWS
                half3 normalWS : TEXCOORD3;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 4);
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

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수
                // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);//카메라 상하 가중치
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = input.texcoord ;
                output.uv2 = input.texcoord1 ;
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
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                //애니에서 덜컥거리는걸 방지하기 위해 정수로 받게 한다. 아예 int로 받게 해도 되지만 그게 제대로 안될 수도 있으니 안전을 위해.
                //마스크맵만은 가로세로로 애니메이션이 다 가능할 것이기 때문에 둘다 정수로 제한하고, 나머지 구름들은 가로로만 흘러갈 것이기 때문에 가로만 정수로 제한한다.
                _MaskMap_ST.xy = round(_MaskMap_ST.xy);
                _BaseTex_ST.x = round(_BaseTex_ST.x);
                _BaseTex2_ST.x = round(_BaseTex2_ST.x);
                _BaseTex3_ST.x = round(_BaseTex3_ST.x);
                _BaseTex4_ST.x = round(_BaseTex4_ST.x);

                float2 uv = input.uv;
                float2 uv2 = input.uv2;

                //마스크맵. 타일링이나 스피드가 가로 세로 제한이 없고 자유롭다.
                float2 maskMapUV = TRANSFORM_TEX(uvScroll(uv, _DistortionSpeedMultix, _DistortionSpeedMultiy, 0.01), _MaskMap);
                half4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, maskMapUV);

                //구름 텍스쳐들. 가로로만 타일링이 제한되고, Y 쪽으로는 타일링을 껐다 켤 수 있다.
                float2 basemapUV = TRANSFORM_TEX(uvScroll(uv, _BaseTexSpeedMultix, 0, 0.01), _BaseTex);
                basemapUV.y = _YTiling ? basemapUV.y : saturate(basemapUV.y);
                half4 basemap = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, basemapUV + maskMap.r * _Distortion * 0.001) * _Global_CloudColor;

                float2 basemap2UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex2SpeedMultix, 0, 0.01), _BaseTex2);
                basemap2UV.y = _YTiling2 ? basemap2UV.y : saturate(basemap2UV.y);
                half4 basemap2 = SAMPLE_TEXTURE2D(_BaseTex2, sampler_BaseTex2, basemap2UV + maskMap.r * _Distortion2 * 0.001) * _Global_CloudColor2;
                
                float2 basemap3UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex3SpeedMultix, 0, 0.01), _BaseTex3);
                basemap3UV.y = _YTiling3 ? basemap3UV.y : saturate(basemap3UV.y);
                half4 basemap3 = SAMPLE_TEXTURE2D(_BaseTex3, sampler_BaseTex3, basemap3UV + maskMap.r * _Distortion3 * 0.001) * _Global_CloudColor3;
                
                float2 basemap4UV = TRANSFORM_TEX(uvScroll(uv, _BaseTex4SpeedMultix, 0, 0.01), _BaseTex4);
                basemap4UV.y = _YTiling4 ? basemap4UV.y : saturate(basemap4UV.y);
                half4 basemap4 = SAMPLE_TEXTURE2D(_BaseTex4, sampler_BaseTex4, basemap4UV + maskMap.r * _Distortion4 * 0.001) * _Global_CloudColor4;

                //별 텍스쳐. 구름이 미세하게 알파가 있어도 별이 숨겨질 수 있도록 셰이더를 합쳤다.
                float2 starMapUV = TRANSFORM_TEX(uvScroll(uv2, _StarSpeedMultix, _StarSpeedMultiy, 0), _StarMap);
                half4 starColor = SAMPLE_TEXTURE2D(_StarMap, sampler_StarMap, starMapUV) * _StarColor * _GlobalSkyUnlitColor;



                //Light 연산/////////////////////////////////////////
                Light light = GetMainLight();
                float3 bakedGI = SampleSHPixel(input.vertexSH, normalize(input.normalWS)) * _Global_GILightMulti.rgb  ;
                
                
                
                //구름 텍스쳐 RGB 연산///////////////////////////////////////
                // float3 basemapav = (basemap4+ basemap3+basemap2+basemap)/4;
                // return basemap4;
                // float3 basemap4ColorBackground = lerp(_Global_CloudColor4.rgb + bakedGI * 0.5, basemap4.rgb, basemap4.a);
                basemap4.rgb = lerp(_Global_CloudColor4.rgb, basemap4.rgb * _Global_CloudColor4.rgb, _Global_CloudColor4.a);

                //4번 구름만 먹구름 전용이자 다른 구름의 외각 색깔입니다. 다른 구름의 외각 색이 검게 혹은 희게 나올 때 4번 구름의 색상을
                //볼륨에서 수정해주면 됩니다.
                //그렇지만 다른 구름의 레이어 순서는 거꾸로입니다. 3번이 제일 낮고, 2번이 그다음 1번이 제일 높습니다.
                //4번이 제일 높지만 ... 1번으로 할 걸 그랬습니다 (?) 지금 바꾸자니 일이 커서 약간 이상하지만 이렇게 놓았습니다.
                basemap.rgb = lerp(basemap4.rgb, basemap.rgb, basemap.a);
                basemap.rgb = lerp(basemap.rgb, basemap2.rgb, basemap2.a);
                basemap.rgb = lerp(basemap.rgb, basemap3.rgb, basemap3.a);

                half4 color ;
                
                //구름 알파 연산//////////////////////////////////
                //현재 알파 두 방식의 차이는 없다
                //4번 텍스쳐가 먹구름이라서, 4번 텍스쳐가 활성화 되면 1 2 3 텍스쳐가 비활성화 되도록 한다.
                //반대로 4번 텍스쳐가 비활성화 되면 단색으로 처리하도록 해서 블렌딩에 찌꺼기가 남지 않도록 한다
                
                // color.a = saturate(basemap3.a + basemap4.a + basemap2.a + basemap.a) ;
                color.a = max(basemap3.a, max(basemap2.a, max(basemap4.a, basemap.a))) ;
                color.a = lerp(color.a, basemap4.a, _Global_CloudColor4.a);

                /////////////////칼라 연산////////////////////////
                
                color.rgb = lerp(bakedGI * 0.8 * color.a, light.color + bakedGI * color.a * 0.5, basemap.r) * basemap.rgb;
                color.rgb = lerp(color.rgb, light.color + bakedGI * basemap.rgb * 0.5, _Global_CloudColor4.a) ;
                // color.rgb = light.color + bakedGI * basemap.rgb* 0.5;

                //별 연산
                //구름이 없는 부분에만 별을 더한다. 구름의 알파가 매우 연하더라도 별은 비쳐보이지 않게 계산한다
                float staraDimmer = color.a * 5;
                starColor = starColor * saturate(1 - staraDimmer);
                color += starColor;


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
