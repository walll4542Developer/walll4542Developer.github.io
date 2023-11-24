// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/BG/Special/L2BigTreeHLODAlphaBlend"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

        // Editmode props
        [HideInInspector] _QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.01
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
            // Blend[_SrcBlend][_DstBlend]
            Blend SrcAlpha OneMinusSrcAlpha
            // ZWrite[_ZWrite]
            ZWrite Off
            Cull[_Cull]

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            // #include "../Includes/bendingVertex.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _VertexColorWeight;
                half _AlbedoTintStrength;
                half _Cutoff;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float2 staticLightmapUV : TEXCOORD1;
                // float2 dynamicLightmapUV    : TEXCOORD2; //리얼타임 라이트맵 안씁니다!
                float4 color : COLOR;
                // UNITY_VERTEX_INPUT_INSTANCE_ID

            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;

                float3 positionWS                   : TEXCOORD1;    // xyz: posWS
                half3 normalWS                      : TEXCOORD2;
                    half fogFactor : TEXCOORD3;

                // #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                //     float4 shadowCoord : TEXCOORD4;
                // #endif
                
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

                float4 screenPos : TEXCOORD5;
                float3 camForward_n : TEXCOORD6;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
            };

            void InitializeInputData(Varyings input, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                inputData.normalWS = half3(0,1,0); //이 나무의 조명은 강제로 위로 보도록
                inputData.shadowCoord = float4(0, 0, 0, 0);
                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
                inputData.vertexLighting = half3(0, 0, 0);
                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

                #if defined(DEBUG_DISPLAY)
                        inputData.vertexSH = input.vertexSH;
                #endif
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                  Vertex and Fragment functions                            //
            ///////////////////////////////////////////////////////////////////////////////

            // Used in Standard (Simple Lighting) shader
            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.camForward_n = NormalizeNormalPerVertex(mul((float3x3)unity_CameraToWorld, float3(0, 0, 1)));//카메라의 앞 방향

                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionCS);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    half3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                #else
                    output.fogFactor = fogFactor;
                #endif

                return output;
            }

            // Used for StandardSimpleLighting shader
            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                
                //틴트칼라와 버텍스 칼라
                float3 tintProp = _BaseColor.rgb;
                half tintStrengthProp = _AlbedoTintStrength;
                float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));
                half alpha = diffuseAlpha.a;
 
                InputData inputData;
                InitializeInputData(input, inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //LOD 디더링 기능
                float fadeValue;
                float lodFade;
                if (unity_LODFade.x != 0)
                {
                    if (unity_LODFade.x > 0)
                    {
                        fadeValue = unity_LODFade.x ;
                    }
                    else
                    {
                        fadeValue = 1 + unity_LODFade.x;
                    }
                    Unity_Dither_linear(fadeValue, input.screenPos, lodFade);
                    clip(lodFade);
                }
                else
                {
                    fadeValue = 1;
                }

                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);

                // half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
                half4 color = UniversalFragmentLightCustom(inputData, diffuse, /* specular */0, /* smoothness */0, /* emission */0, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, /*RampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

                //비내리는 텍스쳐 전환
                half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS, input.normalWS) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);


                //하이트 포그  연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    input.positionWS, inputData.normalWS, inputData.fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    uv);

                //기울어졌을때 알파가 빠지도록 만들자 
                input.camForward_n = NormalizeNormalPerPixel(input.camForward_n);
                half tiltAlpha = abs(dot( input.normalWS, input.camForward_n));
                // tiltAlpha = saturate(tiltAlpha * tiltAlpha);

                color.a = saturate(alpha * _BaseColor.a * tiltAlpha);
                return color;
            };
            ENDHLSL
        }
    }
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitAlphaGUI"
}
