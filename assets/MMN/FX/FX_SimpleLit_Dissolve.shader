// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "MMN/FX/SimpleLit_Prop_Dissolve"
{
    // Keep properties of StandardSpecular shader for upgrade reasons.
    Properties
    {
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        // [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [Toggle]_BackFaceNormalturn ("백페이스 노말을 돌려서 뒷면도 노말을 앞으로 생성한다", float) = 0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        _RampY ("RampY", Range(0, 1)) = 0.5

        [ToggleUI] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        _QueueOffset ("Queue offset", Float) = 0.0

        [Header(Stencil Options)]
        [Space]
        _StencilRef ("Stencil Ref", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass", Int) = 0

        [Header(Dissolve Options)]
        _DissolveAmount ("디졸브 진행도", Range(-30.0, 30.0)) = 0.0
        _DissolveDirection ("디졸브 진행방향", Vector) = (0.0, -1.0, 0.0, 0.0)
        [Toggle(_CUSTOMDATA_ON)] _Customdata ("커스텀 데이터 적용", Float) = 0
        _NoiseTex ("디졸브 텍스쳐", 2D) = "white" { }
        _NoiseTexScale ("디졸브 텍스쳐의 크기", Range(0.1, 10.0)) = 4.0
        [Toggle] _NoiseCutoff ("디졸브 컷오프를 켤까요?", Float) = 1.0
        _NoiseCutoffSmoothness ("컷오프의 부드러움", Range(0.0, 0.5)) = 0.1
        [HDR] _DissolveColor ("디졸브 색상", Color) = (0.0, 0.0, 0.0, 0.0)
        _DissolveWidth ("디졸브 두께", Range(0.0, 5.0)) = 1.0
        [HDR] _DissolveEdgeColor ("디졸브 경계의 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        _DissolveEdgeWidth ("디졸브 경계의 두께", Range(0.0, 0.5)) = 0.2
        //사용하지않지만 SRP배쳐때문에 넣기
        [HideInInspector]_VertexAniOn ("버텍스 애니를 켠다", float) = 1
        [HideInInspector]_WindMultiply("_WindMultiply",float) = 0
        [HideInInspector]_WindSpeedMultiply("_WindSpeedMultiply",float) = 0
    }

    SubShader
    {
        HLSLINCLUDE
            #include "Assets/PatchableAssets/Shaders/MMN/FX/includes/FX_SimpleLitDissolveInput.hlsl"
        ENDHLSL

        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }

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
            // Cull[_Cull]

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
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #define HALF_SUBTRACTIVE_LIGHTMAP_ON 0

            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            // #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/CustomLighting.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/Includes/BlendingHelper.hlsl"

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float3 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                float4 texcoord      : TEXCOORD0;
                float4 customdata      : TEXCOORD1;
                float4 color: COLOR;
            };

            struct Varyings
            {
                float4 uv0                           : TEXCOORD0;
                float4 uv1                           : TEXCOORD1;    // xyzw : custom data

                float3 positionWS                   : TEXCOORD2;    // xyz: posWS
                float3 positionOS                   : TEXCOORD3;    // xyz: posOS

                float3 normalWS                  : TEXCOORD4;    // xyz: normal, w: viewDir.x

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    float4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
                #else
                    float fogFactor : TEXCOORD5;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : TEXCOORD6;
                #endif

                float4 screenPos : TEXCOORD7;
                float cameraDistance : TEXCOORD8;
                float3 vertexSH : TRXCOORD9;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
            };

            void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
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

                // inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);

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

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);

                output.uv0.xy = TRANSFORM_TEX(input.texcoord.xy, _BaseMap);
                output.uv1 = input.customdata;
                output.positionOS.xyz = input.positionOS.xyz;
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionCS);
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

            // Used for StandardSimpleLighting shader
            float4 LitPassFragmentSimple(Varyings input, FRONT_FACE_TYPE isFacing : FRONT_FACE_SEMANTIC) : SV_Target
            {
                float2 uv = input.uv0.xy;
                float4 customdata = input.uv1;

                float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                //틴트칼라와 버텍스 칼라
                float3 tintProp = _BaseColor.rgb;
                float tintStrengthProp = _AlbedoTintStrength;
                float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));

                float alpha = diffuseAlpha.a * _BaseColor.a;

                #if defined(_ALPHATEST_ON)
                    clip(alpha - _Cutoff);
                    alpha = 1;//없으면 댑스문제로 번쩍거림
                #else
                    alpha = 1;
                #endif

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
                InitializeInputData(input, /* normalTS */ float3(0, 0, 1), inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //LOD 디더링 기능
                float fadeValue;
                float lodFade;
                if (unity_LODFade.x != 0)
                {
                    if (unity_LODFade.x > 0)
                    {
                        fadeValue = pow(unity_LODFade.x, 1) ;
                    }
                    else
                    {
                        fadeValue = 1 + unity_LODFade.x;
                    }
                    Unity_Dither_linear(fadeValue, input.screenPos, lodFade, 0.5);
                    clip(lodFade);
                }
                else
                {
                    fadeValue = 1;
                }

                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);

                //라이팅
                float4 color = 0;

                color = UniversalFragmentLightCustom(inputData, diffuse, /* specular */0, /* smoothness */0, /* emission */0, alpha, /* normalTS */ float3(0, 0, 1), /*shadowDimming*/ 0, /*rampY*/ 0, /* _BackfaceReceiveShadowOff */1, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

                //비내리는 텍스쳐 전환
                float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

                //디졸브 연산
                float4 dissolveResult = color;
                DissolveColor(dissolveResult, input.positionOS.xyz, input.positionWS.xyz, input.normalWS.xyz, customdata);
                clip(dissolveResult.a - _NoiseCutoff);
                color = dissolveResult;

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

            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/includes/FX_SimpleLitShadowCasterDissolvePass.hlsl"
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
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON            
            #define VERTEX_CAMERA_DEPEND_BENDING 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }



    Fallback off
    // CustomEditor "MM.Client.Editor.ShaderGUI.MMN_SimpleLitGUI"

}
