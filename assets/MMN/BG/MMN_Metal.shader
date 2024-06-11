Shader "MMN/BG/Metal"
{
    Properties
    {
        [Toggle]_ALPHATEST ("알파테스트", float) = 0
        [Enum(off, 0, front, 1, back, 2)]_Cull ("BackfaceCull", Float) = 2.0
        [PerRendererData]_RaycastHarftoneClip ("레이케스트 하프톤 클립", Range(0, 1)) = 0
        _Cutoff ("Alpha Clipping", Range(0.0, 1.0)) = 0.5
        
        _VertexColorWeight ("버텍스 칼라 영향력 가중치", Range(0, 1)) = 1
        [Toggle]_ShowVertexColor ("Show Vertex Color(확인용)", float) = 0

        _AlbedoTintStrength ("Albedo Tint Strength", Range(-1.0, 1.0)) = 0.0
        [MainColor] _BaseColor ("Base Tint", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap ("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" { }

        [NoScaleOffset]_BumpMap ("Normal Map ", 2D) = "bump" { }

        [HDR]_CubemapColor ("Cubemap Color", Color) = (0, 0, 0, 0)
        _Cubemap ("CubeMap", Cube) = "" { }

        [HDR]_SpecColor ("Specular Color", Color) = (0, 0, 0, 0)
        _Gloss ("Glossiness", Range(0.01, 5)) = 0.5
        _GlossNormalMulti ("GlossinessNormalMulti", Range(1, 10)) = 1

        _GIMulti ("_GIMulti", Color) = (1, 1, 1, 1)

        // Editmode props
        _QueueOffset ("Queue offset", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps ("unity_Lightmaps", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_LightmapsInd ("unity_LightmapsInd", 2DArray) = "" { }
        [HideInInspector][NoScaleOffset]unity_ShadowMasks ("unity_ShadowMasks", 2DArray) = "" { }

        //날씨
        [Toggle]_IsRaindrop ("빗방울이 떨어질까요?/ 눈이 쌓일까요?", float) = 1

        [Header(Stencil Options)]
        [Space]
        _StencilRef ("Stencil Ref", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comp", Int) = 0
        [MaterialEnum(UnityEngine.Rendering.StencilOp)] _StencilPass ("Stencil Pass", Int) = 0
    }

    //LOD 300
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "4.5" }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "BG" }

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
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore d3d9
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _SHOWVERTEXCOLOR_ON
            #pragma shader_feature_local _SHOWVERTEXALPHA_ON

            // -------------------------------------
            // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES


            #pragma multi_compile _ LIGHTMAP_ON
            #define HALF_SUBTRACTIVE_LIGHTMAP_ON 0
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _VertexColorWeight;
                float _AlbedoTintStrength;
                float4 _SpecColor;
                float4 _CubemapColor;
                float4 _GIMulti;
                float _Gloss;
                float _GlossNormalMulti;
                float _Cutoff;
                // float _Surface;
                float _IsRaindrop;
                float _RaycastHarftoneClip;
                float _ALPHATEST;
                float4 _BumpMap_ST;
            CBUFFER_END
            samplerCUBE _Cubemap;   

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
                half2 staticLightmapUV : TEXCOORD1;
                float4 color : COLOR;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;    // xyz: posWS
                float4 normalWS : TEXCOORD2;    // xyz: normal, w: viewDir.x
                float4 tangentWS : TEXCOORD3;    // xyz: tangent, w: viewDir.y
                float4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
                #else
                    float fogFactor : TEXCOORD5;
                #endif

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    float4 shadowCoord : TEXCOORD6;
                #endif

                float4 screenPos : TEXCOORD7;
                float cameraDistance : TEXCOORD8; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 9);
                float4 positionOS : TEXCOORD10;
                float4 color : COLOR;
                float4 positionCS : SV_POSITION;

            };

            void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
            {
                inputData = (InputData)0;
                inputData.positionWS = input.positionWS;

                half3 viewDirWS = float3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
                inputData.tangentToWorld = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
                inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
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

                #if defined(DEBUG_DISPLAY)
                    #if defined(LIGHTMAP_ON)
                        inputData.staticLightmapUV = input.staticLightmapUV;
                    #else
                        inputData.vertexSH = input.vertexSH;
                    #endif
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
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS.xyz = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.positionOS = input.positionOS;

                float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
                output.normalWS = float4(normalInput.normalWS, viewDirWS.x);
                output.tangentWS = float4(normalInput.tangentWS, viewDirWS.y);
                output.bitangentWS = float4(normalInput.bitangentWS, viewDirWS.z);

                output.color = input.color;
                output.screenPos = ComputeScreenPos(output.positionCS);
                output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

                OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
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
                float2 uv = input.uv;
                float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

                //틴트칼라와 버텍스 칼라
                float3 tintProp = _BaseColor.rgb;
                float tintStrengthProp = _AlbedoTintStrength;
                float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight)); 
                float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv), 1);

                float alpha = diffuseAlpha.a * _BaseColor.a;

                #if defined(_ALPHATEST_ON)
                    clip(alpha - _Cutoff);
                    alpha = 1;//없으면 댑스문제로 번쩍거림
                #else
                    alpha = 1;
                #endif

                //레이케스트 되면 사라지는 기능
                float RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
                clip(RaycasthalftoneAlpha - 0.1);

                //버텍스칼라 디버깅
                #ifdef _SHOWVERTEXCOLOR_ON
                    return float4(saturate(abs(input.color.rgb)), 1);
                #endif

                #ifdef _SHOWVERTEXALPHA_ON
                    return float4(saturate(abs(input.color.aaa)), 1);
                #endif

                // float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
                float4 specular = _SpecColor * diffuseAlpha.a;
                float smoothness = _Gloss ;

                InputData inputData;
                InitializeInputData(input, normalTS , inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

                //리플렉션 프로브
                float3 reflectVec = reflect(-inputData.viewDirectionWS, inputData.normalWS);
                float3 Reflectionprobe = texCUBElod(_Cubemap,float4(reflectVec,0)).rgb;
                Reflectionprobe = saturate(Reflectionprobe);

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

                if(_IsRaindrop)
                {
                //눈내리는 텍스쳐 전환
                diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, inputData.normalWS.rgb, inputData.bakedGI);
                }

                //라이팅
                float4 color = 0;
                inputData.bakedGI *= _GIMulti.rgb;

                color = UniversalFragmentLightCustomMetal(inputData, diffuse, specular, smoothness, /* emission */0, alpha, normalTS , _GlossNormalMulti);
                color.rgb += Reflectionprobe * _CubemapColor.rgb * diffuseAlpha.a;// * diffuse.rgb;
            
                
                if(_IsRaindrop)
                {
                //비내리는 텍스쳐 전환
                float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
                color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, inputData.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
                color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);
                }

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

                //원본 포그 연산
                color.a = 1; //간혹 특정기기에서 번쩍거리는 현상 방지를 위한 코드
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            // #include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _VertexColorWeight;
                float _AlbedoTintStrength;
                float4 _SpecColor;
                float4 _CubemapColor;
                float4 _GIMulti;
                float _Gloss;
                float _GlossNormalMulti;
                float _Cutoff;
                float _IsRaindrop;
                float _RaycastHarftoneClip;
                float _ALPHATEST;
                float4 _BumpMap_ST;
            CBUFFER_END
            samplerCUBE _Cubemap;   
            // #include "MMN_SimpleLitShadowCasterPass.hlsl"

            // Shadow Casting Light geometric parameters. These variables are used when applying the shadow Normal Bias and are set by UnityEngine.Rendering.Universal.ShadowUtils.SetupShadowCasterConstantBuffer in com.unity.render-pipelines.universal/Runtime/ShadowUtils.cs
            // For Directional lights, _LightDirection is used when applying shadow Normal Bias.
            // For Spot lights and Point lights, _LightPosition is used to compute the actual light direction because it is different at each shadow caster geometry vertex.
            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };

            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                #if UNITY_REVERSED_Z
                    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
                #endif

                return positionCS;
            }

            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);

                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = GetShadowPositionHClip(input);
                output.screenPos = ComputeScreenPos(output.positionCS);
                return output;
            }

            float4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                
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
                    Unity_Dither_linear(fadeValue, input.screenPos, lodFade, 0.5);
                    clip(lodFade);
                }
                else
                {
                    fadeValue = 1;
                }

                Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                return 0;
            }


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
            #pragma multi_compile_local_fragment _ _ALPHATEST_ON
            // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
            // #pragma multi_compile_fragment _ _NEARHALFTONECLIP_ON
            #define VERTEX_CAMERA_DEPEND_BENDING 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 0
            #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS 0
            #define RAYCAST 1
            #define LODFADE 1

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // #include "MMN_SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _VertexColorWeight;
                float _AlbedoTintStrength;
                float4 _SpecColor;
                float4 _CubemapColor;
                float4 _GIMulti;
                float _Gloss;
                float _GlossNormalMulti;
                float _Cutoff;
                float _IsRaindrop;
                float _RaycastHarftoneClip;
                float _ALPHATEST;
                float4 _BumpMap_ST;
            CBUFFER_END
            samplerCUBE _Cubemap;   

            #include "MMN_DepthOnlyPass.hlsl"
            ENDHLSL
        }


        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple
            #pragma shader_feature EDITOR_VISUALIZATION

            // #include "MMN_SimpleLitInput.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _VertexColorWeight;
                float _AlbedoTintStrength;
                float4 _SpecColor;
                float4 _CubemapColor;
                float4 _GIMulti;
                float _Gloss;
                float _GlossNormalMulti;
                float _Cutoff;
                float _IsRaindrop;
                float _RaycastHarftoneClip;
                float _ALPHATEST;
                float4 _BumpMap_ST;
            CBUFFER_END
            samplerCUBE _Cubemap;   

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UniversalMetaPass.hlsl"

            half4 UniversalFragmentMetaSimple(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                MetaInput metaInput;
                metaInput.Albedo = _BaseColor.rgb * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb;
                metaInput.Emission = 0;

                return UniversalFragmentMeta(input, metaInput);
            }

            ENDHLSL
        }


        
    }


    Fallback off
    CustomEditor "MM.Client.Editor.ShaderGUI.MMN_MetalGUI"
}
