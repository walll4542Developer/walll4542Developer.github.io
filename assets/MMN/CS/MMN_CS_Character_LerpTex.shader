// 크로우크루아흐 연출시 역광 받는용에서 사용하기 위해서 만든 셰이더

Shader "MMN/CutScene/Standard_LerpTex"
{
    Properties
    {
        [Enum(Standard, 0, Monster, 1)] _ShadingType ("셰딩 타입", Float) = 0.0

        [Header(Texture)]
        [Space(10)]
        _BaseMap ("베이스 맵", 2D) = "white" {}
        _TintColor ("틴트 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        [NoScaleOffset]_BaseMap2 ("베이스 맵2", 2D) = "white" {}
        _LerpTex ("베이스맵 Lerp (_LerpTex)", Range(0, 1)) = 0.0

        [Header(Silhouette)]
        [Space(10)]
        [Toggle] _SilhouetteOff ("실루엣 끄기", Float) = 0.0
        _SilhouetteTintColor ("실루엣 틴트", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Outline)]
        [Space(10)]
        [ToggleOff(_OUTLINE_FEATURE)] _OutlineOff ("아웃라인 끄기", Float) = 0.0
        _OutlineColor ("아웃라인 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        [Enum(Multiply, 0, Override, 1)] _OutlineColorMode ("아웃라인 색상 적용 방식", Float) = 0.0
        _OutlineWidth ("아웃라인 두께", Range(0, 3)) = 1.0

        // NTOE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (1.0, 0.0, 0.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InflateWidth ("_InflateWidth", Float) = 0.0
        [HideInInspector] _InflateColor ("_InflateColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength("_VertexBufferLength", Integer) = 0
        
        [HideInInspector] _StencilValue("_StencilValue", Integer) = 0
    }

    Subshader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        HLSLINCLUDE
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #undef _TRANSPARENCY
            #undef _ALPHA_TEST
            #undef _IS_SKIN
            #undef _DYE_FEATURE
            #define _SILHOUETTE_FEATURE

            #include "MMN_CS_Character_LerpTex_Input.hlsl"
        ENDHLSL

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "UniversalForward" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp Always
                Pass Replace
                Fail Keep
                ZFail Keep
            }

            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _OUTLINE_FEATURE
            #pragma multi_compile _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            // -------------------------------------
            // 작업 공정의 편의를 위한 Keywords

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex BasePassVertex
            #pragma fragment BasePassFragment

            //--------------------------------------
            // Fragment
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterCommonAttributes.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterCommonBasePassVertex.hlsl"

            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterLighting.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterOnePassOutline.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterDye.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterDithering.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterApplyFx.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterApplyFog.hlsl"
            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterDebugging.hlsl"

            float4 BasePassFragment(Varyings input) : SV_Target
            {
                //-----------------------------------------------------------------------------
                // Diffuse
                //-----------------------------------------------------------------------------
                float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                // 두 번째 텍스쳐가 연산되게 한다. 림라이트를 위한.
                float4 baseMap2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, uv);

                float3 baseColor = lerp(baseMap.rgb, baseMap2.rgb, _LerpTex);
                float alpha = baseMap.a;

                //-----------------------------------------------------------------------------
                // Initialize data
                //-----------------------------------------------------------------------------
                // Input data
                InputData inputData;
                InitializeCharacterInputData(input, inputData);
                SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv.xy, _BaseMap);

                // Light
                Light mainLight;
                LightingData lightingData;
                InitializeLightData(inputData, mainLight, lightingData);

                // from script
                CharacterData characterData = InitializeCharacterData();

                //-----------------------------------------------------------------------------
                // Process Color
                //-----------------------------------------------------------------------------
                float4 resultColor;
                resultColor.rgb = ProcessCharacterColor(inputData,
                    mainLight, lightingData, characterData,
                    baseColor, _ShadingType, _SilhouetteOff, _SilhouetteTintColor);

                #if defined(_OUTLINE_FEATURE)
                    float3 outlineColor = OnePassOutline(_ShadingType, inputData, mainLight.direction, _OutlineColorMode);
                    resultColor.rgb *= outlineColor;
                #endif

                //lerp 가 되면 빛 계산을 하지 않아 음영을 지지 않게 한다
                resultColor.rgb = lerp(resultColor.rgb, baseColor.rgb, _LerpTex);

                ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
                resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
                ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

                //림 텍스쳐를 2번째 텍스쳐 알파에 넣고, 림 연산과 더해서 Emission에 더하기
                resultColor.rgb += lerp(0.0, baseMap2.a, _LerpTex).xxx;
                resultColor.rgb = saturate(resultColor.rgb);
                resultColor.rgb *= _TintColor.rgb;

                resultColor.a = alpha;

                //-----------------------------------------------------------------------------
                // 디버그
                //-----------------------------------------------------------------------------
                #if defined(DEBUG_DISPLAY)
                {
                    return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, baseColor, alpha);
                }
                #endif
                //-----------------------------------------------------------------------------

                return resultColor;
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

            HLSLPROGRAM
            //--------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ColorMask 0

            HLSLPROGRAM
            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex DepthPassVertex
            #pragma fragment DepthPassFragment

            #include "Assets/PatchableAssets/Shaders/MMN/CH/Includes/CharacterDepthOnlyPass.hlsl"
            ENDHLSL
        }
    }
}
