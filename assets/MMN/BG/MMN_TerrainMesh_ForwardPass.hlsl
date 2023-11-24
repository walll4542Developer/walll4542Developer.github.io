#ifndef UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/bendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"

//샘플러 스테이트 하나가지고 공유합니다
SamplerState TerrianSamplerState_trilinear_repeat_sampler;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
};

struct Varyings
{
    float4 uv : TEXCOORD0;   // xy : uv
    float3 positionWS : TEXCOORD1;    // xyz: positionWS
    float3 normal : TEXCOORD2;
    
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

    float3 viewDir : TEXCOORD8;
    float4 screenPos : TEXCOORD9;
    float4 positionCS : SV_POSITION;
};

void InitializeInputData(Varyings input, /* half3 normalTS, */ out InputData inputData)
{
    
    inputData = (InputData)0;
    
    inputData.positionWS = input.positionWS;
    inputData.positionCS = input.positionCS;

    half3 viewDirWS = input.viewDir;
    inputData.normalWS = NormalizeNormalPerPixel(input.normal);
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
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

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

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Simple Lighting) shader
Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수
    // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);//화면 휘어짐 효과 기능 추가함수
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv.xy = TRANSFORM_TEX(input.texcoord, _T2M_SplatMap_0);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.screenPos = ComputeScreenPos(output.positionCS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.normal = NormalizeNormalPerVertex(normalInput.normalWS);
    output.viewDir = viewDirWS;

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normal.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}

// Used for StandardSimpleLighting shader
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv.xy;
    half4 control = saturate(SAMPLE_TEXTURE2D(_T2M_SplatMap_0, sampler_T2M_SplatMap_0, uv));
    half4 splat1 = half4(0, 0, 0, 0);
    half4 splat2 = half4(0, 0, 0, 0);
    half4 splat3 = half4(0, 0, 0, 0);
    half4 splat4 = half4(0, 0, 0, 0);

    // ==========================================================================================
    // 일반 방식의 Terrain 샘플링  : 0.025는 기존 터레인에 있는 uv와 비슷하게 비례를 맞추기 위한 상수 ==
    // ==========================================================================================
    splat1 = SAMPLE_TEXTURE2D(_T2M_Layer_0_Diffuse, TerrianSamplerState_trilinear_repeat_sampler, input.positionWS.xz * 0.0025 * _V_T2M_Splat1_uvScale);
    splat2 = SAMPLE_TEXTURE2D(_T2M_Layer_1_Diffuse, TerrianSamplerState_trilinear_repeat_sampler, input.positionWS.xz * 0.0025 * _V_T2M_Splat2_uvScale);
    splat3 = SAMPLE_TEXTURE2D(_T2M_Layer_2_Diffuse, TerrianSamplerState_trilinear_repeat_sampler, input.positionWS.xz * 0.0025 * _V_T2M_Splat3_uvScale);
    splat4 = SAMPLE_TEXTURE2D(_T2M_Layer_3_Diffuse, TerrianSamplerState_trilinear_repeat_sampler, input.positionWS.xz * 0.0025 * _V_T2M_Splat4_uvScale);

    // ===============================================================================
    // ==                         Texture Calc 신형작업                              ==
    // ===============================================================================

    // 셀 스타일의 스플레팅 아웃라인 계산 신형
    half sp_r = saturate(step(0.5 * _V_T2M_Splat2_Vector1, control.r * splat2.a + pow(control.r, 5)));
    half sp_rExpand = saturate(step(0.5 * _V_T2M_Splat2_Vector2, control.r * splat2.a + pow(control.r, 5)));
    /*g 는 사실상 r이 밀려나는 것으로 구현 가능하므로 안써도 됩니다. 이건 유니티 터레인과 구조를 억지로 맞추려고 이렇게 배치한 것입니다.
    float sp_g = saturate(step(0.01*_V_T2M_Splat2_Vector1, control.g * splat2.a + pow(control.g, 5)));
    float sp_gExpand = saturate(step(0.5*_V_T2M_Splat2_Vector2, control.g * splat2.a + pow(control.g, 5))); */
    
    half sp_b = saturate(step(0.5 * (-_V_T2M_Splat3_Vector1 + 2), control.b * splat3.a + pow(control.b, 5)));
    half sp_bExpand = saturate(step(0.5 * (-_V_T2M_Splat3_Vector2 + 2), control.b * splat3.a + pow(control.b, 5)));
    // -x+2 로 한 것은 첫 번째 스플레팅 공식과 맞추기 위함입니다. 첫 번째 공식은 1번 레이어에 2번 레이어 영역을 계산하게 하는데,
    // 두 번째 공식부터는 3번 레이어에서 3번 레이어 영역을 계산하게 하기 때문입니다. 이것은 유니티 내장 터레인과 공식을 어느정도 맞추기
    // 위한 궁여지책입니다. 기본 수치가 1부터 시작해서, 정 반대로 움직이게s 하기 위한 방식입니다.

    half sp_aExpand = saturate(step(0.5 * (-_V_T2M_Splat4_Vector2 + 2), control.a * splat4.a + pow(control.a, 5)));
    half sp_a = saturate(step(0.5 * (-_V_T2M_Splat4_Vector1 + 2), control.a * splat4.a + pow(control.a, 5)));

    //텍스쳐 블렌딩 연산 신형
    //(_V_T2M_Splat2_EdgeColor * 4.2 - 1) * 0.25 : 4.2 는 2.2 감마에 *2-1 을 합친겁니다. 0.2로 강도조절
    half3 mixedDiffuse = splat1.rgb;
    mixedDiffuse = lerp(splat2.rgb + (_V_T2M_Splat2_EdgeColor.rgb * 4.2 - 1) * 0.2, splat1.rgb, sp_rExpand);
    mixedDiffuse = lerp(splat2.rgb, mixedDiffuse, sp_r);

    /* g 마스크는 r을 뒤집는 것으로 구현합니다.
    mixedDiffuse = lerp(splat2.rgb * _V_T2M_Splat3_EdgeColor, splat1.rgb,  sp_rExpand);
    mixedDiffuse = lerp( splat2.rgb, mixedDiffuse, sp_g); */
    
    mixedDiffuse = lerp(mixedDiffuse, splat3.rgb + (_V_T2M_Splat3_EdgeColor.rgb * 4.2 - 1) * 0.2, sp_bExpand);
    mixedDiffuse = lerp(mixedDiffuse, splat3.rgb, sp_b);
    
    mixedDiffuse = lerp(mixedDiffuse, splat4.rgb + (_V_T2M_Splat4_EdgeColor.rgb * 4.2 - 1) * 0.2, sp_aExpand);
    mixedDiffuse = lerp(mixedDiffuse, splat4.rgb, sp_a);
    mixedDiffuse *= _BaseColor.rgb;

    half alpha = 1;
    
    // ===============================================================================
    // ==                            Lighting Calc                                  ==
    // ===============================================================================
    
    InputData inputData;
    InitializeInputData(input, /* normalTS, */ inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    //눈내리는 텍스쳐 전환,
    half4 snowMask = half4(_SnowMask_R, _SnowMask_G, _SnowMask_B, _SnowMask_A);
    mixedDiffuse.rgb = snowTextureLerpTerrain(input.positionWS, mixedDiffuse.rgb, input.normal.rgb, inputData.bakedGI, control, snowMask);
    
    // 조명 공식
    half4 color = UniversalFragmentLightCustom(inputData, mixedDiffuse, /* specular */0, /* smoothness */0, /* emission */0, alpha, /* normalTS */half3(0, 0, 1), /*shadowDimming*/ 0, /*RampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */1.0, /* float backFaceNormalrecover */1.0);

    // 리플렉션 프로브
    half3 reflectVec = reflect(-inputData.viewDirectionWS, inputData.normalWS);
    half3 Reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, /* (1 - _Glossiness) * */ 0), unity_SpecCube0_HDR);
    
    //림연산
    half rim = (dot(normalize(inputData.normalWS), normalize(inputData.viewDirectionWS)));
    rim = abs(1 - rim);
    rim = saturate(pow(rim, 10));
    
    //비내리는 텍스쳐 전환
    half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color_Rain += MMN_GlobalTex_Raindrop(input.positionWS, input.normal.rgb) * step(0.85, inputData.bakedGI).r * color_Rain;
    rim = min(0.25, rim);
    color_Rain += mixedDiffuse.rgb * rim * Reflectionprobe * 0.5  ;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

    //컨텍트 셰도우 연산
    color *= MMN_RecieveContactShadow(input.positionWS, inputData.shadowCoord);
    
    // ===============================================================================
    // ==                            Fog & CloudShadow Calc                         ==
    // ===============================================================================

    //하이트 포그 글로벌 텍스쳐 연산
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
};

#endif
