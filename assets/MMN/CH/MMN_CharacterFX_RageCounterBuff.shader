Shader "MMN/CH/FX_RageCounterBuff"
{
    Properties
    {
        [Header(Shape Part)]
        [Space(10)]
        _BuffWidth ("굵기", Range(0.0, 10.0)) = 3.5
        _BuffVertexHeight ("높이", Range(0.0, 0.2)) = 0.0
        _BuffVertexAdjustZ ("Z 보정", Range(-0.016, 0.0)) = 0.0

        [NoScaleOffset] _BuffNoiseMap ("노이즈 맵", 2D) = "white" { }
        _BuffNoiseSpeed ("일렁이는 속도", Float) = 10.0
        _BuffBubbleNoiseScaleX ("기포 노이즈 스케일 X", Range(0.01, 10.0)) = 0.5
        _BuffBubbleNoiseScaleY ("기포 노이즈 스케일 Y", Range(0.01, 10.0)) = 0.5
        _BuffBubbleOpacity ("기포 알파 클리핑", Range(0.0, 10.0)) = 1.7

        [Header(Color Part)]
        [Space(10)]
        [HDR] _BuffColor1 ("색상", Color) = (4.0, 0.0, 0.0, 1.0)

        [Header(Dissolve_DO NOT EDIT)]
        [Space(10)]
        [Toggle(_DISSOLVE_FEATURE)] _IsDissolve ("디졸브 켜기", Float) = 0.0
        _DissolveAmount ("진행도", Range(0.0, 2.0)) = 0.0
        _DissolveRange ("범위(xyz: 범위, w: 두께)", Vector) = (1.0, 1.0, 1.0, 6.0)
        [Toggle] _NotUseDirection ("방향 없이 디졸브 할까요?", Float) = 0.0
        _DissolveDirection ("진행 방향 벡터", Vector) = (0.0, -1.0, 0.0, 0.0)
        _DissolvePanningSpeed ("패닝 속도", Range(-1.0, 1.0)) = 0.0
        _DissolveMap ("디졸브 텍스쳐", 2D) = "white" { }
        [Toggle] _DissolveCutoff ("디졸브 컷오프를 켤까요?", Float) = 1.0
        [HDR] _DissolveColor ("디졸브 색상", Color) = (0.0, 0.0, 0.0, 0.0)
        _DissolveWidth ("디졸브 두께", Range(0.0, 1.0)) = 0.3
        [HDR] _DissolveEdgeColor ("디졸브 경계의 색상", Color) = (1.0, 1.0, 1.0, 1.0)
        _DissolveEdgeWidth ("디졸브 경계의 두께", Range(0.0, 1.0)) = 0.05

        [HideInInspector] _StencilValue ("_StencilValue", Integer) = 0

        // NOTE @jihun.song : 로직 스크립트에서 넘어오는 값들.
        // 반드시 수정/추가가 필요할 때 MM_DECLARE_PROPERTIES_FROM_SCRIPT 매크로도 같이 수정해야 합니다!
        // 매크로 이름으로 전체 검색하면 모두 나오니깐 참고하세요.
        // 이 문제(https://deskcat.io/d/Q02981/MM-미술-QA-캐릭터-셰딩-오류)를 해결하기 위해서 CBUFFER에 등록함.
        [HideInInspector] _CharacterPositionAndVisualHeight ("xyz: position, w: visual height", Vector) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] _CharacterDirection ("xy: direction, zw: reserved", Vector) = (0.0, -1.0, 0.0, 0.0)
        [HideInInspector] _CharacterHeadDirection ("xyz: direction, w: height", Vector) = (0.0, 0.0, 1.0, 0.0)
        [HideInInspector] _TopShadow ("_TopShadow", Float) = 0.0
        [HideInInspector] _BottomShadow ("_BottomShadow", Float) = 0.0

        [HideInInspector] _HalftoneClip ("_HalftoneClip", Float) = 0.0

        [HideInInspector] _CustomLightMode ("_CustomLightMode", Float) = 0.0
        [HideInInspector] _CustomLightDirection ("_CustomLightDirection", Vector) = (0.0, 0.0, -1.0, 0.0)
        [HideInInspector] _CustomLightColor ("_CustomLightColor", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] _CustomGIColor ("_CustomGIColor", Color) = (0.768, 0.827, 0.854, 1.0)

        [HideInInspector] _EffectTint ("_EffectTint", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _InnerGlow ("_InnerGlow", Float) = 0.0
        [HideInInspector] _InnerGlowPower ("_InnerGlowPower", Float) = 0.0
        [HideInInspector] _InnerGlowColor ("_InnerGlowColor", Color) = (0.0, 0.0, 0.0, 0.0)

        [HideInInspector] _EffectAlphaValue ("_EffectAlphaValue", Float) = 0.0
        [HideInInspector] _MotionBlurLerpValue ("_MotionBlurLerpValue", Float) = 0.0
        [HideInInspector] _VertexBufferLength ("_VertexBufferLength", Integer) = 0
        //--------------------------------------------------------------------------------
    }

    SubShader
    {
        LOD 100

        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"
            Tags { "LightMode" = "SelectionOutline" }

            Stencil
            {
                // NOTE @jihun.song : 일반적으로 캐릭터가 사용하는 마스크 범위는 [16 ~ 255] 까지 사용 한다.
                // StencilIdAllocator 스크립트에서 해당 범위의 값을 할당해준다.
                Ref [_StencilValue]
                Comp NotEqual
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma multi_compile _ _DISSOLVE_FEATURE
            #pragma multi_compile_vertex _ _VERTEX_OBJECT_MOTION_BLUR

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "MMN_Character_Global_Input.hlsl"
            #include "Includes/CharacterMacro.hlsl"

            //--------------------------------------
            // from Script
            int _StencilValue;

            MM_DECLARE_PROPERTIES_FROM_SCRIPT
            //--------------------------------------

            #include "Includes/CharacterData.hlsl"
            #include "Includes/CharacterApplyDissolve.hlsl"
            #include "Includes/CharacterMotionBlurPass.hlsl"

            float _BuffWidth;
            float _BuffVertexHeight;
            float _BuffVertexAdjustZ;

            TEXTURE2D(_BuffNoiseMap);
            SAMPLER(sampler_BuffNoiseMap);
            float _BuffNoiseSpeed;
            float _BuffBubbleNoiseScaleX;
            float _BuffBubbleNoiseScaleY;
            float _BuffBubbleOpacity;

            float4 _BuffColor1;

        #ifdef _DISSOLVE_FEATURE
            TEXTURE2D(_DissolveMap);
            SAMPLER(sampler_DissolveMap);

            float _DissolveAmount;

            float4 _DissolveRange;
            float _NotUseDirection;
            float3 _DissolveDirection;

            float _DissolvePanningSpeed;
            float4 _DissolveMap_ST;

            float _DissolveCutoff;

            float4 _DissolveColor;
            float _DissolveWidth;
            float4 _DissolveEdgeColor;
            float _DissolveEdgeWidth;
        #endif

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord0 : TEXCOORD0;

            #ifdef _VERTEX_OBJECT_MOTION_BLUR
                uint id : SV_VertexID;
            #endif
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD2;
                float2 uv : TEXCOORD3;

            #ifdef _DISSOLVE_FEATURE
                float3 positionOS : TEXCOORD4;
            #endif
            };


            float3 ProjectOnPlane(float3 vec, float3 planeNormal)
            {
                planeNormal = normalize(planeNormal);
                return (vec - dot(vec, planeNormal) * planeNormal);
            }

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

            #ifdef _VERTEX_OBJECT_MOTION_BLUR
                // 오브젝트 모션블러(버텍스)를 적용한다
                float3 positionOS = CaculateMotionBlurVertexPositionOS(input.positionOS.xyz, input.normalOS, input.id);
            #else
                float3 positionOS = input.positionOS.xyz;
            #endif

                CharacterData characterData = InitializeCharacterData();
                float3 scaleOS = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));

                float3 normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
                output.normalWS = normalWS;

                float3 cameraDirWS = -GetViewForwardDir();
                float nDotProjectedN = max(0.0, dot(normalWS, normalize(ProjectOnPlane(normalWS, cameraDirWS))));
                float vertexExpand = _BuffWidth * nDotProjectedN * 0.05;
                vertexExpand *= characterData.visualHeight; // 캐릭터 크기 보정

                float2 normalBaseOffset = mul((float3x3)GetViewToHClipMatrix(), normalize(mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS.xyz)) * scaleOS).xy;
                normalBaseOffset *= vertexExpand;

                float2 positionBaseOffset = mul((float3x3)GetViewToHClipMatrix(), normalize(mul((float3x3)UNITY_MATRIX_IT_MV, positionOS)) * scaleOS).xy;
                positionBaseOffset *= vertexExpand;

                float3 positionWS = TransformObjectToWorld(positionOS);
                float yOffsetWS = _BuffVertexHeight * characterData.visualHeight * 0.5;
                positionWS.y += yOffsetWS;

                output.viewDirWS = GetWorldSpaceViewDir(positionWS);

                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionCS.xy += lerp(positionBaseOffset, normalBaseOffset, 0.4);
                output.positionCS.z += _BuffVertexAdjustZ * scaleOS.z;

                float uvScale = 0.5 / (1.0 + output.positionCS.z / output.positionCS.w);
                output.uv = output.positionCS.xy * (uvScale * scaleOS.y);

            #ifdef _DISSOLVE_FEATURE
                output.positionWS = positionWS;
                output.positionOS = TransformWorldToObject(positionWS);
            #endif

                return output;
            }

            float4 frag(Varyings input) : SV_Target
            {
                float3 normalWS = normalize(input.normalWS);
                float3 viewDirWS = normalize(input.viewDirWS);
                float nDotV = saturate(dot(normalWS, viewDirWS));

                float bubbleArea = pow(nDotV, _BuffBubbleOpacity);

                float bubbleMoveUp = frac(_Time.x * _BuffNoiseSpeed);
                float2 bubbleNoiseUV = float2(0.0, bubbleMoveUp);
                float bubbleNoise = SAMPLE_TEXTURE2D(_BuffNoiseMap, sampler_BuffNoiseMap, input.uv.xy * float2(_BuffBubbleNoiseScaleX, _BuffBubbleNoiseScaleY) + bubbleNoiseUV).r;
                bubbleNoise = bubbleArea - (1.0 - bubbleNoise);

                float4 resultColor = _BuffColor1;
                resultColor.a *= saturate(bubbleNoise * 10.0);
                clip(resultColor.a - 0.5);

            #ifdef _DISSOLVE_FEATURE
                CharacterData characterData = InitializeCharacterData();

                DissolveInput dissolveInput;
                dissolveInput.range = _DissolveRange;
                dissolveInput.notUseDirection = _NotUseDirection;
                dissolveInput.direction = _DissolveDirection.xyz;
                dissolveInput.panningSpeed = _DissolvePanningSpeed;
                dissolveInput.dissolveMap = _DissolveMap;
                dissolveInput.dissolveMapSampler = sampler_DissolveMap;
                dissolveInput.dissolveMapST = _DissolveMap_ST;
                dissolveInput.useCutoff = _DissolveCutoff;
                dissolveInput.mainColor = _DissolveColor;
                dissolveInput.mainWidth = _DissolveWidth;
                dissolveInput.edgeColor = _DissolveEdgeColor;
                dissolveInput.edgeWidth = _DissolveEdgeWidth;
                dissolveInput.positionWS = input.positionWS;
                dissolveInput.positionOS = input.positionOS;
                dissolveInput.normalWS = SafeNormalize(input.normalWS.xyz);
                dissolveInput.characterData = characterData;
                resultColor.rgb = ApplyDissolve(resultColor.rgb, _DissolveAmount, dissolveInput);
            #endif

                return resultColor;
            }
            ENDHLSL
        }
    }
}
