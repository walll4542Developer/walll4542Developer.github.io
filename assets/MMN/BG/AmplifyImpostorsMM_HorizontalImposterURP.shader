// Amplify Impostors
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

Shader "Amplify Impostors/MM_Horizontal Impostor URP"
{
    Properties
    {
        [NoScaleOffset]_Albedo ("BaseMap", 2D) = "white" { }
        [NoScaleOffset]_Normals ("Normals & Depth", 2D) = "white" { }
        // [NoScaleOffset]_Specular ("Specular & Smoothness", 2D) = "black" {}
        // [NoScaleOffset]_Emission ("Emission & Occlusion", 2D) = "black" {}
        _ClipMask ("Clip", Range(0, 1)) = 0.01
        _TextureBias ("Texture Bias", Float) = -1
        [Toggle(_USE_PARALLAX_ON)] _Use_Parallax ("Use Parallax", Float) = 0
        _Parallax ("Parallax", Range(-1, 1)) = 1
        _AI_ShadowBias ("Shadow Bias", Range(0, 2)) = 0.25
        _AI_ShadowView ("Shadow View", Range(0, 1)) = 1
        [HideInInspector]_FramesX ("Frames X", Float) = 16
        [HideInInspector]_FramesY ("Frames Y", Float) = 16
        [HideInInspector]_DepthSize ("DepthSize", Float) = 1
        [HideInInspector]_ImpostorSize ("Impostor Size", Vector) = (1, 1, 1, 1)
        [HideInInspector]_Offset ("Offset", Vector) = (0, 0, 0, 0)
        [HideInInspector]_AI_SizeOffset ("Size & Offset", Vector) = (0, 0, 0, 0)
        [HideInInspector][Toggle(EFFECT_HUE_VARIATION)] _Hue ("Use SpeedTree Hue", Float) = 0
        [HideInInspector]_HueVariation ("Hue Variation", Color) = (0, 0, 0, 0)
        [HideInInspector][Toggle] _AI_AlphaToCoverage ("Alpha To Coverage", Float) = 0

        _ReceiveShadowStrength ("리시브 셰도우 강도", Range(0, 1)) = 0.5
        _ShadingPow ("음영 날카롭기 조정", Range(0.01, 3)) = 1
        _GIStrength ("음영 밝게하기)", Range(0, 1)) = 0
        _TintColor("틴트칼라", color) = (1,1,1,1)
        _TintStr("틴트 적용 강도", float) = 0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }

        Cull Back
        AlphaToMask[_AI_AlphaToCoverage]

        HLSLINCLUDE
        #pragma target 3.0

        #pragma shader_feature _USE_PARALLAX_ON

        struct SurfaceOutputSimpleLit
        {
            half3 Albedo;
            float3 Normal;
            half Alpha;
        };

        ENDHLSL

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            Name "Base"
            Blend One Zero
            ZWrite On
            ZTest LEqual
            Offset 0, 0
            ColorMask RGBA
            
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fog

            #pragma vertex vert
            #pragma fragment frag

            #define _SPECULAR_SETUP 1

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Includes/EnvironmentHelper.hlsl"
            #include "../Includes/BendingVertex.hlsl"
            #include "../Includes/CustomLighting.hlsl"
            #include "../Includes/BlendingHelper.hlsl"

            #define AI_RENDERPIPELINE
            
            #include "AmplifyImpostors.cginc"

            #pragma shader_feature EFFECT_HUE_VARIATION

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                //float4 texcoord  : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 lightmapUVOrVertexSH : TEXCOORD0;
                half4 fogFactorAndVertexLight : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;
                float4 frameUVs : TEXCOORD3;
                float4 viewPos : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                float4 positionOS : TEXCOORD6;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                HorizontalImpostorVertex(v.vertex, v.normal, o.frameUVs, o.viewPos);

                float3 lwWNormal = TransformObjectToWorldNormal(v.normal);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                // 카메라 바라보는 각도에 따라 버텍스 휘어짐
                // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(v.vertex.xyz);
                
                OUTPUT_LIGHTMAP_UV(v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy);
                OUTPUT_SH(lwWNormal, o.lightmapUVOrVertexSH.xyz);

                half3 vertexLight = VertexLighting(vertexInput.positionWS, lwWNormal);
                half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                o.clipPos = vertexInput.positionCS;
                o.screenPos = ComputeScreenPos(vertexInput.positionCS);
                o.positionOS = v.vertex;

                #ifdef _MAIN_LIGHT_SHADOWS
                    o.shadowCoord = GetShadowCoord(vertexInput);
                #endif
                return o;
            }

            half4 frag(VertexOutput IN, out float outDepth : SV_Depth) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                
                SurfaceOutputSimpleLit o = (SurfaceOutputSimpleLit)0;
                float4 clipPos = 0;
                float3 worldPos = 0;

                HorizontalImpostorFragment(o, clipPos, worldPos, IN.frameUVs, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;
                outDepth = clipPos.z;

                float3 WorldSpaceViewDirection = SafeNormalize(_WorldSpaceCameraPos.xyz - worldPos);

                InputData inputData;
                inputData.positionWS = worldPos;
                inputData.normalWS = o.Normal ;
                inputData.viewDirectionWS = WorldSpaceViewDirection;

                // #ifdef _MAIN_LIGHT_SHADOWS
                //     #if SHADOWS_SCREEN
                //     #else
                //         IN.shadowCoord = TransformWorldToShadowCoord(worldPos);
                //     #endif
                // #endif

                // inputData.shadowCoord = IN.shadowCoord;
                inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), IN.fogFactorAndVertexLight.x);
                inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
                OUTPUT_SH(inputData.normalWS, IN.lightmapUVOrVertexSH.xyz);
                inputData.bakedGI = SAMPLE_GI(IN.lightmapUVOrVertexSH.xy, IN.lightmapUVOrVertexSH.xyz, inputData.normalWS);

                half4 color = 1;
                color.a = o.Alpha;


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

                    // return fadeValue;

                    Unity_Dither_linear(fadeValue, IN.screenPos, lodFade, 0.5);
                    clip(lodFade);
                }
                else
                {
                    fadeValue = 1;
                }


                //비가 왔을때 체크
                color.rgb = lerp(o.Albedo, ((o.Albedo * o.Albedo) + o.Albedo) / 2, _Global_Raining);
                
                //눈이 왔을때 체크
                float snowCheck = saturate(dot(IN.positionOS.rgb, half3(0, 0.1, 0)));
                snowCheck = step(0.4, snowCheck * inputData.normalWS.y * _Global_Snow);
                color.rgb = lerp(color.rgb, 0.7, snowCheck);

                //라이팅
                color.rgb *= UniversalFragmentTreeLeavesImposter(inputData, _ShadingPow, _ReceiveShadowStrength, _GIStrength);

                //틴트적용
                color.rgb = TextureTintBlend(color.rgb, _TintColor.rgb, _TintStr);
                
                // 글로벌 텍스쳐를 통한 하이트 포그 연산
                color = MMN_GlobalTex_HeightFog(
                    color,
                    inputData.positionWS, inputData.normalWS, inputData.fogCoord,
                    _Global_FogHeightOffset,
                    _Global_FogHeightScale,
                    _Global_FogHeightNoiseValue,
                    _Global_FogHeightNoiseSpeed,
                    _Global_FogHeightNoiseScale,
                    float2(0, 0)/*예비로 넣어둔 UV자리*/);

                //원본 포그 연산
                //color.rgb =  MixFog(color.rgb, inputData.fogCoord);
                color.a = 1; // iOS 에서 깜빡거리는 것을 강제로 안정화 시키기 위한 코드 . Clip으로 자르고 있기 때문에 문제없다. 


                return saturate(color);
            }

            ENDHLSL
        }

        // Pass
        // {

        //     Name "ShadowCaster"
        //     Tags { "LightMode" = "ShadowCaster" }

        //     ZWrite On
        //     ZTest LEqual

        //     HLSLPROGRAM
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 2.0

        //     #ifndef UNITY_PASS_SHADOWCASTER
        //         #define UNITY_PASS_SHADOWCASTER
        //     #endif
        //     // #pragma multi_compile_instancing

        //     #pragma vertex vert
        //     #pragma fragment frag

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "../Includes/CustomLighting.hlsl"
        //     #include "../Includes/EnvironmentHelper.hlsl"

        //     #define AI_RENDERPIPELINE

        //     #include "AmplifyImpostors.cginc"

        //     #pragma shader_feature EFFECT_HUE_VARIATION

        //     struct VertexInput
        //     {
        //         float4 vertex : POSITION;
        //         float3 normal : NORMAL;
        //         //float4 texcoord : TEXCOORD0;
        //         UNITY_VERTEX_INPUT_INSTANCE_ID
        //     };

        //     struct VertexOutput
        //     {
        //         float4 clipPos : SV_POSITION;
        //         float4 frameUVs : TEXCOORD3;
        //         float4 viewPos : TEXCOORD4;
        //         float4 screenPos : TEXCOORD5;
        //         UNITY_VERTEX_INPUT_INSTANCE_ID
        //         UNITY_VERTEX_OUTPUT_STEREO
        //     };


        //     VertexOutput vert(VertexInput v)
        //     {
        //         VertexOutput o = (VertexOutput)0;
        //         UNITY_SETUP_INSTANCE_ID(v);
        //         UNITY_TRANSFER_INSTANCE_ID(v, o);
        //         UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                

        //         HorizontalImpostorVertex(v.vertex, v.normal, o.frameUVs, o.viewPos);


        //         o.clipPos = TransformObjectToHClip(v.vertex.xyz);
        //         o.screenPos = ComputeScreenPos(o.clipPos);

        //         return o;
        //     }

        //     half4 frag(VertexOutput IN, out float outDepth : SV_Depth) : SV_TARGET
        //     {
        //         UNITY_SETUP_INSTANCE_ID(IN);
        //         SurfaceOutputSimpleLit o = (SurfaceOutputSimpleLit)0;
        //         float4 clipPos = 0;
        //         float3 worldPos = 0;
        //         HorizontalImpostorFragment(o, clipPos, worldPos, IN.frameUVs, IN.viewPos);
        //         IN.clipPos.zw = clipPos.zw;

        //         //LOD 디더링 기능
        //         float fadeValue;
        //         float lodFade;
        //         if (unity_LODFade.x != 0)
        //         {
        //             if (unity_LODFade.x > 0)
        //             {
        //                 fadeValue = unity_LODFade.x ;
        //             }
        //             else
        //             {
        //                 fadeValue = 1 + unity_LODFade.x;
        //             }

        //             // return fadeValue;

        //             Unity_Dither_linear(fadeValue, IN.screenPos, lodFade, 0.5);
        //             clip(lodFade);
        //         }
        //         else
        //         {
        //             fadeValue = 1;
        //         }

        //         outDepth = clipPos.z ;
        //         return 0;
        //     }
        //     ENDHLSL
        // }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define AI_RENDERPIPELINE

            #include "AmplifyImpostors.cginc"

            // #pragma shader_feature _HEMI_ON
            #pragma shader_feature EFFECT_HUE_VARIATION

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                //float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 frameUVs : TEXCOORD3;
                float4 viewPos : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // OctaImpostorVertex(v.vertex, v.normal, o.uvsFrame1, o.uvsFrame2, o.uvsFrame3, o.octaFrame, o.viewPos);
                HorizontalImpostorVertex(v.vertex, v.normal, o.frameUVs, o.viewPos);

                o.clipPos = TransformObjectToHClip(v.vertex.xyz);
                
                return o;
            }

            half4 frag(VertexOutput IN, out float outDepth : SV_Depth) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputSimpleLit o = (SurfaceOutputSimpleLit)0;
                float4 clipPos = 0;
                float3 worldPos = 0;

                // OctaImpostorFragment(o, clipPos, worldPos, IN.uvsFrame1, IN.uvsFrame2, IN.uvsFrame3, IN.octaFrame, IN.viewPos);
                HorizontalImpostorFragment(o, clipPos, worldPos, IN.frameUVs, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;

                outDepth = clipPos.z;
                return 0;
            }

            ENDHLSL
        }



        // Pass
        // {
        //     Name "DepthOnly"
        //     Tags { "LightMode" = "DepthOnly" }

        //     ZWrite On
        //     ColorMask 0
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     #pragma exclude_renderers gles gles3 glcore
        //     #pragma target 4.5

        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment

        //     // -------------------------------------
        //     // 셰이더 피쳐. 빌드에 안들어갈 수 있으니 에디터 위주 기능에 사용
        //     // #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
        //     // 에디터에서 니어 클리핑을 잠시 안보게 할 수 있는 기능. 에디터 한정이라 셰이더 피쳐로 올립니다
        //     #pragma shader_feature_fragment _ _GLOBAL_NEARHALFTONECLIP_ON

        //     //--------------------------------------
        //     // 멀티컴파일. 빌드에 꼭 들어가지만 셰이더 베리언트가 많아짐
        //     // GPU Instancing
        //     #pragma multi_compile_instancing
        //     #pragma multi_compile _ DOTS_INSTANCING_ON
        //     #pragma multi_compile _ALPHATEST_ON _ALPHATEST_OFF
        //     #pragma multi_compile _ _NEARHALFTONECLIP_ON
        //     // #pragma multi_compile _ _GLOBAL_NEARHALFTONECLIP_ON
        //     #define VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION 1
        //     #define RAYCAST 1
        //     #define LODFADE 1


        //     #include "MMN_SimpleLitInput.hlsl"
        //     #include "MMN_DepthOnlyPass.hlsl"
        //     ENDHLSL
        // }

        Pass
        {
            Name "SceneSelectionPass"
            Tags { "LightMode" = "SceneSelectionPass" }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #define AI_RENDERPIPELINE

            #include "AmplifyImpostors.cginc"

            #pragma shader_feature EFFECT_HUE_VARIATION
            
            int _ObjectId;
            int _PassValue;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                //float4 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct VertexOutput
            {
                float4 clipPos : SV_POSITION;
                float4 frameUVs : TEXCOORD3;
                float4 viewPos : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o = (VertexOutput)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                HorizontalImpostorVertex(v.vertex, v.normal, o.frameUVs, o.viewPos);

                o.clipPos = TransformObjectToHClip(v.vertex.xyz);

                return o;
            }

            half4 frag(VertexOutput IN, out float outDepth : SV_Depth) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                SurfaceOutputSimpleLit o = (SurfaceOutputSimpleLit)0;
                float4 clipPos = 0;
                float3 worldPos = 0;

                HorizontalImpostorFragment(o, clipPos, worldPos, IN.frameUVs, IN.viewPos);
                IN.clipPos.zw = clipPos.zw;

                outDepth = IN.clipPos.z;
                return float4(_ObjectId, _PassValue, 1.0, 1.0);
            }

            ENDHLSL
        }

        //이걸로 라이트맵 안굼
        // 		Pass
        //         {
        //             Name "Meta"
        //             Tags { "LightMode" = "Meta" }

        //             Cull Off

        //             HLSLPROGRAM
        //             // Required to compile gles 2.0 with standard srp library
        //             #pragma prefer_hlslcc gles
        //             #pragma exclude_renderers d3d11_9x

        //             #pragma vertex vert
        //             #pragma fragment frag

        //             #pragma shader_feature _SPECULAR_SETUP
        //             #pragma shader_feature _EMISSION
        //             #pragma shader_feature _METALLICSPECGLOSSMAP
        //             #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //             #pragma shader_feature _SPECGLOSSMAP

        // 			uniform float4 _MainTex_ST;

        // 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        // 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

        // 			#define AI_RENDERPIPELINE

        // 			#include "AmplifyImpostors.cginc"

        // 			#pragma shader_feature EFFECT_HUE_VARIATION

        // 			struct VertexInput
        // 			{
        // 				float4 vertex   : POSITION;
        // 				float3 normal   : NORMAL;
        // 				//float4 texcoord : TEXCOORD0;
        // 				float2 uvLM     : TEXCOORD1;
        // 				float2 uvDLM    : TEXCOORD2;
        // 				UNITY_VERTEX_INPUT_INSTANCE_ID
        // 			};

        // 			struct VertexOutput
        // 			{
        // 				float4 clipPos   : SV_POSITION;
        // 				float4 frameUVs : TEXCOORD3;
        // 				float4 viewPos  : TEXCOORD4;
        // 				UNITY_VERTEX_INPUT_INSTANCE_ID
        // 				UNITY_VERTEX_OUTPUT_STEREO
        // 			};

        // 			VertexOutput vert( VertexInput v )
        // 			{
        // 				VertexOutput o = (VertexOutput)0;
        // 				UNITY_SETUP_INSTANCE_ID( v );
        // 				UNITY_TRANSFER_INSTANCE_ID( v, o );
        // 				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

        // 				SphereImpostorVertex( v.vertex, v.normal, o.frameUVs, o.viewPos );

        // #if AI_LWRP_VERSION > 51300
        // 				o.clipPos = MetaVertexPosition( v.vertex, v.uvLM, v.uvDLM, unity_LightmapST, unity_DynamicLightmapST );
        // #else
        // 				o.clipPos = MetaVertexPosition( v.vertex, v.uvLM, v.uvDLM, unity_LightmapST );
        // #endif
        // 				return o;
        // 			}

        // 			half4 frag( VertexOutput IN, out float outDepth : SV_Depth ) : SV_TARGET
        // 			{
        // 				UNITY_SETUP_INSTANCE_ID( IN );
        // 				SurfaceOutputSimpleLit o = (SurfaceOutputSimpleLit)0;
        // 				float4 clipPos = 0;
        // 				float3 worldPos = 0;

        // 				SphereImpostorFragment( o, clipPos, worldPos, IN.frameUVs, IN.viewPos );
        // 				IN.clipPos.zw = clipPos.zw;

        // 				MetaInput metaInput = (MetaInput)0;
        // 				metaInput.Albedo = o.Albedo;
        // 				metaInput.Emission = o.Emission;

        // 				outDepth = clipPos.z;

        // 				return MetaFragment( metaInput );
        // 			}
        //             ENDHLSL
        //         }

    }
    // FallBack "Hidden/InternalErrorShader"
    // Fallback  "Hidden/Universal Render Pipeline/FallbackError"
    Fallback off
}
