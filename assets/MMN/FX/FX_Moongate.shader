//최종 컬러 값 = 메인 텍스쳐1을 Lerp 값이 변경됨에 따라 메인텍스쳐2로 변경
//Cull Back

Shader "MMN/FX/Moongate"
{
    Properties
    {
        [Toggle]_NEARHALFTONECLIP ("니어 클립", float) = 0
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        [HideInInspector][Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [HideInInspector][PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        [HideInInspector]_VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [HideInInspector][Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0

        [HideInInspector]_Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [HideInInspector][HDR]_SpecColor ("Specular Color", Color) = (0, 0, 0, 0)
        [HideInInspector]_Smoothness ("Smoothness", Range(0.0, 1.0)) = 0
        [HideInInspector]_Gloss ("Glossiness", Range(0.01, 5)) = 1
        [HideInInspector]_RampY ("RampY", Range(0, 1)) = 0.5
        [HideInInspector][Toggle]_BackfaceReceiveShadowOff ("백페이스 리시브 셰도우 끄기", float) = 0

        [HideInInspector]_SpecGlossMap ("Specular Map", 2D) = "white" { }
        [HideInInspector]_SmoothnessSource ("Smoothness Source", Float) = 0.0
        [HideInInspector]_SpecularHighlights ("Specular Highlights", Float) = 1.0

        // [HideInInspector] _BumpScale ("Scale", Float) = 1.0
        // [NoScaleOffset] _BumpMap ("Normal Map", 2D) = "bump" { }

        [HideInInspector][HDR] _EmissionColor ("Emission Color", Color) = (0, 0, 0)
        [HideInInspector][NoScaleOffset]_EmissionMap ("Emission Map", 2D) = "white" { }
        [HideInInspector][Enum(Always, 0, NightOnly, 1, DayOnly, 2)] _Night2DayEnum ("언제 Emission이 켜지게 할까요", float) = 0

        // Blending state
        [HideInInspector] _Surface ("__surface", Float) = 0.0
        [HideInInspector] _Blend ("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip ("__clip", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        // [HideInInspector] _ZWrite ("__zw", Float) = 1.0
        // [HideInInspector] _Cull ("__cull", Float) = 2.0

        [HideInInspector][ToggleUI] _ReceiveShadows ("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector]_QueueOffset ("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex ("BaseMap", 2D) = "white" { }
        [HideInInspector] _Color ("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess ("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource ("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource ("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }


        //흔들리기. 버텍스 알파에 대응한다.
        [HideInInspector]_WindMultiply ("Wind Multiply(바람 디테일)", Range(0, 20)) = 2 //잘게 흔들리게 됩니다.
        [HideInInspector]_WindSpeedMultiply ("Wind Speed Multiply(바람 속도 가중치)", Range(0, 40)) = 7 //빠르게 흔들리게 됩니다.
        [HideInInspector][Toggle]_ShowVertexAlpha ("Show Vertex Alpha(확인용)", float) = 0
        //버텍스 애니를 강제로 끄기. 셰이더 피쳐나 멀티컴파일로 분리하면 SRP 버퍼가 가동이 안될수 있어서 강제 포함
        [HideInInspector][Toggle]_VertexAniOn ("버텍스 애니를 강제로 끈다", float) = 1
        [HideInInspector][Toggle]_UseVertexAnimation ("버텍스 애니 기능 통채로 끄기", float) = 0 //GUI에서만 쓰는 기능이라 프로퍼티에서만 유지합니다.

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
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "SimpleLit"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }
        LOD 300

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

            // Use same blending / depth states as Standard shader
            Blend[_SrcBlend][_DstBlend]
            // ZWrite[_ZWrite]
            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
            #pragma shader_feature _ _GLOBAL_NEARHALFTONECLIP_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            // Universal Pipeline keywords
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ SHADOWS_SHADOWMASK //이걸빼면 더 어두워짐
            // #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            // #pragma multi_compile _ _CLUSTERED_RENDERING
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma instancing_options renderinglayer
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            // #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"

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
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                // #ifdef _NORMALMAP
                // half4 normalWS : TEXCOORD2;    // xyz: normal, w: viewDir.x
                // half4 tangentWS : TEXCOORD3;    // xyz: tangent, w: viewDir.y
                // half4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
                // #else
                    float3 normalWS : TEXCOORD2;
                // #endif

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
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
                // UNITY_VERTEX_OUTPUT_STEREO

            };

            void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                // 노말맵을 봉인합니다
                // #ifdef _NORMALMAP
                // half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                // inputData.tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                // inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
                // #else
                    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
                inputData.normalWS = input.normalWS;
                // #endif

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
                    inputData.vertexLighting = half3(0, 0, 0);
                #endif

                inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);

                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                // inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

                #if defined(DEBUG_DISPLAY)
                    // #if defined(DYNAMICLIGHTMAP_ON)//리얼타임 라이트맵 사용금지입니다.
                    // inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
                    // #endif
                    #if defined(LIGHTMAP_ON)
                        inputData.staticLightmapUV = input.staticLightmapUV;
                    #else
                        inputData.vertexSH = input.vertexSH;
                    #endif
                #endif
            }

            Varyings LitPassVertexSimple(Attributes input)
            {
                Varyings output = (Varyings)0;

                // UNITY_SETUP_INSTANCE_ID(input);
                // UNITY_TRANSFER_INSTANCE_ID(input, output);
                // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                //카메라 바라보는 각도에 따라 버텍스 휘어짐 (제거)
                //버텍스 알파에 따라  바람에 흔들거림
                VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, 1 - saturate(input.color.aaaa + _VertexAniOn), _WindMultiply, _WindSpeedMultiply, /*float _GrassPushPower*/ 0, 1);

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;

                // #ifdef _NORMALMAP
                // half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                // output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
                // output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
                // output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
                // #else
                    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                // #endif

                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionCS);
                output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
                // #ifdef DYNAMICLIGHTMAP_ON //리얼타임 라이트맵 안씁니다
                //     output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                // #endif
                OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    float3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                #else
                    output.fogFactor = fogFactor;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = GetShadowCoord(vertexInput);
                #endif

                return output;
            }

            half4 LitPassFragmentSimple(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
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
                #if defined(_NEARHALFTONECLIP_ON) && defined(_GLOBAL_NEARHALFTONECLIP_ON)
                    float halftoneAlpha;
                    NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
                    clip(halftoneAlpha);
                #endif

                //레이케스트 되면 사라지는 기능
                half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                //버텍스칼라 디버깅
                #ifdef _SHOWVERTEXCOLOR_ON
                    return float4(saturate(abs(input.color.rgb)), 1);
                #endif

                #ifdef _SHOWVERTEXALPHA_ON
                    return float4(saturate(abs(input.color.aaa)), 1);
                #endif

                // half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
                // half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
                half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;

                //Emission 을 밤낮에 따라 켜지게 꺼지게 혹은 계속 유지하게 하는 기능
                #define NightOnly 1
                #define DayOnly 2
                if (_Night2DayEnum == NightOnly)
                {
                    emission *= abs(1 - _Global_Night2Day);
                }
                else if (_Night2DayEnum == DayOnly)
                {
                    emission *= _Global_Night2Day;
                }
                else
                {
                    emission = emission;
                }

                half4 specular = _SpecColor * diffuseAlpha.a;
                half smoothness = _Gloss ;

                InputData inputData;
                InitializeInputData(input, /* normalTS */ half3(0, 0, 1), inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //데칼기능
                //#ifdef _DBUFFER
                //    ApplyDecalToBaseColorAndNormal(input.positionCS, diffuse,  inputData.normalWS);
                //    ApplyDecalToBaseColor(input.positionCS, diffuse);
                //#endif

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
                half4 color = 0;
                // half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
                color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, /*rampY*/ _RampY, _BackfaceReceiveShadowOff, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

                /////////////////////////////////////////////////////////////////////////////////

                _EdgeWidth *= 0.4; // 굵기 최대치 조정

                //선형 보간으로 텍스쳐 섞기
                float2 noiseTextureUV = TRANSFORM_TEX(input.uv, _NoiseTexture);
                half4 noiseTextureColor = SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, noiseTextureUV);

                half lerpNoise = lerp(noiseTextureColor.r, -0.3, _Lerp);
                half saturateNoise = saturate(lerpNoise);
                half stepNoise = step(saturateNoise, 0.45);

                half4 offColor = color * _OffColor;
                half4 onColor = color * _OnColor;

                half4 edge = color * saturate((stepNoise - step(saturateNoise, 0.45 - _EdgeWidth))) * _EdgeColor;
                half progress = stepNoise;

                color = lerp(offColor, onColor, progress);
                color += edge;

                // return float4(edge.xxx, 1);

                //비내리는 텍스쳐 전환
                half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

                //컨텍트 셰도우 연산
                color *= MMN_RecieveContactShadow(input.positionWS, inputData.shadowCoord);

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

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_SimpleLitShadowCasterPass.hlsl"
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
            #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

            //--------------------------------------
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define VERTEX_CAMERA_DEPEND_BENDING 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            #include "Assets/PatchableAssets/Shaders/MMN/FX/Includes/FX_Moongate_Input.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/BG/MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    FallBack off
    //CustomEditor "MM.Client.Editor.ShaderGUI.ShadowReceiveShaderGUI"
}
