//최종 컬러 값 = 메인 텍스쳐1을 Lerp 값이 변경됨에 따라 메인텍스쳐2로 변경
//Cull Back

Shader "MMN/FX/Moongate"
{
    Properties
    {
        [Toggle]_ALPHATEST ("알파테스트", float) = 0

        [MainTexture] _BaseMap ("베이스맵. 알파 안씁니다", 2D) = "white" { }
        [MainColor] _BaseColor ("틴트칼라", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("틴트강도", Range(-1.0, 1.0)) = 0.0

        [HideInInspector][ToggleUI] _ReceiveShadows ("Receive Shadows", Float) = 1.0
        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0
        [HideInInspector]_Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1


        [Header(Stencil Options)]
        [Space]
        _StencilRef ("Stencil Ref", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass", Int) = 0

        /////////////////////////////////////////////////////////////////////////////////

        [Header(Linear Interpolation Options)]
        [Space]
        _NoiseTexture ("NoiseTexture", 2D) = "white" {}
        [HDR]_OffColor ("Off Color", Color) = (1, 1, 1, 1)
        [HDR]_OnColor ("On Color", Color) = (1, 1, 1, 1)

        _Lerp ("Lerp", Range( -0.7 , 0.7)) = 0.7

        [HDR]_EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.03
    }

    SubShader
    {
        // LOD 300
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "SimpleLit"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPass]
                Fail Keep
                ZFail Keep
            }

            Blend One Zero
            ZWrite On

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            // Universal Pipeline keywords
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float3 normalWS : TEXCOORD2;

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    float4 fogFactorAndVertexLight : TEXCOORD3; // x: fogFactor, yzw: vertex light
                #else
                    float fogFactor : TEXCOORD3;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : TEXCOORD4;
                #endif

                float4 screenPos : TEXCOORD5;
                float cameraDistance : TEXCOORD6; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
                // DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
                float3 vertexSH : TRXCOORD7;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;

            };

            void InitializeInputData(Varyings input, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
                inputData.normalWS = input.normalWS;

                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                viewDirWS = SafeNormalize(viewDirWS);

                inputData.viewDirectionWS = viewDirWS;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                    inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                #else
                    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
                    inputData.vertexLighting = float3(0, 0, 0);
                #endif

                inputData.bakedGI = input.vertexSH;

                #if defined(DEBUG_DISPLAY)
                        inputData.vertexSH = input.vertexSH;
                #endif
            }

            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionCS);
                output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    float3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);
                #else
                    output.fogFactor = fogFactor;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif

                return output;
            }

            float4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                //틴트칼라와 버텍스 칼라
                float3 tintProp = _BaseColor.rgb;
                float tintStrengthProp = _AlbedoTintStrength;
                float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));

                float alpha = 1 ;

                //가까워지면 하프톤으로 사라지게 하는 기능
                // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
                // #if defined(_NEARHALFTONECLIP_ON) && defined(_GLOBAL_NEARHALFTONECLIP_ON)
                //     float halftoneAlpha;
                //     NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
                //     clip(halftoneAlpha);
                // #endif

                //레이케스트 되면 사라지는 기능
                float RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                InputData inputData;
                InitializeInputData(input, inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);

                //라이팅
                float4 color = 0;
                color = UniversalFragmentLightCustom(inputData, diffuse, /* specular */0, /* smoothness */0, /* emission */0, alpha, /* normalTS */ float3(0, 0, 1), /*shadowDimming*/ 0, /*rampY*/ 0, /* _BackfaceReceiveShadowOff */1, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

                /////////////////////////////////////////////////////////////////////////////////

                _EdgeWidth *= 0.4; // 굵기 최대치 조정

                //선형 보간으로 텍스쳐 섞기
                float2 noiseTextureUV = TRANSFORM_TEX(input.uv, _NoiseTexture);
                float4 noiseTextureColor = SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, noiseTextureUV);

                float lerpNoise = lerp(noiseTextureColor.r, -0.3, _Lerp);
                float saturateNoise = saturate(lerpNoise);
                float stepNoise = step(saturateNoise, 0.45);

                float4 offColor = color * _OffColor;
                float4 onColor = color * _OnColor;

                float4 edge = color * saturate((stepNoise - step(saturateNoise, 0.45 - _EdgeWidth))) * _EdgeColor;
                float progress = stepNoise;

                color = lerp(offColor, onColor, progress);
                color += edge;

                //비내리는 텍스쳐 전환
                float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

                //컨텍트 셰도우 연산
                color.rgb *= MMN_RecieveContactShadow(input.positionWS, inputData.shadowCoord);

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

                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/MMN_MoongateShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //-------------------------------------
            // Material Keywords
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------            
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define RAYCAST 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/FX/MMN_MoongateDepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    FallBack off
}
