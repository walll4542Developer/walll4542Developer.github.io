#ifndef UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/bendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"

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
    float4 positionOS : TEXCOORD1;

    float3 positionWS : TEXCOORD2;    // xyz: posWS
    float3 normalWS : TEXCOORD3;
    float3 viewDir : TEXCOORD4;
    
    
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

    float4 screenPos : TEXCOORD8;
    float cameraDistance : TEXCOORD9;
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;

    // UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
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
        inputData.vertexLighting = half3(0, 0, 0);
    #endif

    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

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

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    //카메라 바라보는 각도에 따라 버텍스 휘어짐
    //아래는 흔들리게 하기 위한 오버라이드 함수
    VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, input.color, _WindMultiply, _WindSpeedMultiply, _GrassPushPower, /* _VertexAniOn */ 1);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.positionOS = input.positionOS;
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.viewDir = viewDirWS;
    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);
    
    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    //Additional Light를 위한 Vertex Light 연산
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float3 posObjectNormal = (input.positionOS.rgb - half3(0, _CenterPointHeight, 0));
        float3 posWorldNormal = TransformObjectToWorldDir(posObjectNormal);
        posWorldNormal = normalize(posWorldNormal);
        normalInput.normalWS = lerp(normalInput.normalWS, posWorldNormal.rgb, _NormalLerp);
        float3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS) * 0.5; //꽃 등이 빛나서 줄임
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
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;
    half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;
    half alpha = diffuseAlpha.a ;
    
    // 이 셰이더는 평소 사용하지 않고 가시성 처리에서만 사용할 것이기 때문에 아래 기능은 봉인합니다 
    // half nearAlpha = 1;
    // #if defined(_GLOBAL_NEARHALFTONECLIP_ON)
    //     //거리에 따라 사라지게 하는 기능
    //     float cameraDistance = input.cameraDistance / 1.5  ;//사라지는 거리 조절하고 싶으면 여기에 곱셈하세요
    //     nearAlpha = saturate(cameraDistance * cameraDistance - 0.5) ;
    // #endif

    //레이케스트 되면 사라지는 기능
    // half RaycasthalftoneAlpha = RaycastingHalftoneAlphaBlend(input.screenPos, input.screenPos, _RaycastHarftoneClip, 0);

    // // ===============================================================================
    // // ==                            Color Calc                                     ==
    // // ===============================================================================
    half4 color = half4(0, 0, 0, 0);
    half3 posObjectNormal = (input.positionOS.rgb - half3(0, _CenterPointHeight, 0));

    // 이 셰이더는 평소 사용하지 않고 가시성 처리에서만 사용할 것이기 때문에 아래 기능은 봉인합니다
    //센터포지션 임시확인기능 . 모든 둥근 모양의 활엽수는 센터 포지션을 나무 중앙에 두어야 합니다.
    // #ifdef _SHOWCENTERPOSITION_ON
    //     return float4(saturate(abs(posObjectNormal.ggg)), 1);
    // #endif

    // #ifdef _SHOWVERTEXCOLOR_ON
    //     return float4(saturate(abs(input.color.rgb)), 1);
    // #endif

    InputData inputData;
    InitializeInputData(input, /*float3 normalTS*/float3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    //diffuse
    half3 diffuseLightColor = UniversalFragmentTreeLeaves2(
        inputData, diffuse, posObjectNormal, _NormalLerp, _ShadingPow, _ReceiveShadowStrength, /* _ReceiveGIStrength */1);

    //innerAO
    half innerAO = UniversalFragmentTreeLeavesInnerAO(input.positionOS, _CenterPointHeight, _AOarea, _AOintensity, _AOVertical);
    //ambinent top light
    half3 topLight = UniversalFragmentTreeLeavesTopLight(posObjectNormal, _TopLightThickness, /* _TopLightColor */1) * inputData.bakedGI;
    //rim
    half innerAOinvRim = UniversalFragmentTreeLeavesInnerAO(input.positionOS, _CenterPointHeight, _RimArea, _RimRange);
    half3 RimColor = innerAOinvRim * _RimColor.rgb * MMN_GlobalTex_CloudShadows(inputData.positionWS).r * saturate(posObjectNormal.y) * diffuseLightColor * inputData.bakedGI;
    
    //눈내리는 텍스쳐 전환
    half snowMask = 1;
    snowTreeTextureLerp(input.positionWS, diffuse.rgb, inputData.normalWS * 0.5 + 0.5, snowMask);
    
    //포그 전에 마지막으로 모든 결과를 합친다.
    //이 부분 때문에 라이팅 디버그에서 결과가 정확하기 나오진 않지만 이 부분을 다 뜯으려면 너무 커서 일단 여기서 정리합니다.
    color.rgb = diffuseLightColor * diffuse * innerAO + topLight * diffuse + RimColor ;
    // 눈 마스킹. 눈이 온 부분은 림과 탑라이트, AO 연산을 뺀다
    color.rgb = lerp(color.rgb, diffuseLightColor * diffuse, snowMask);

    #if defined(DEBUG_DISPLAY) //디버그 디스플레이용
        half4 debugColor;

        SurfaceData surfaceData;
        surfaceData.albedo = diffuse;
        surfaceData.alpha = alpha;
        surfaceData.emission = 0;
        surfaceData.metallic = 0;
        surfaceData.occlusion = innerAO;
        surfaceData.smoothness = 0;
        surfaceData.specular = 0;
        surfaceData.clearCoatMask = 0;
        surfaceData.clearCoatSmoothness = 1;
        surfaceData.normalTS = lerp(normalize(inputData.normalWS), posObjectNormal, _NormalLerp);

        if (CanDebugOverrideOutputColor(inputData, surfaceData, debugColor))
        {
            return debugColor;
        }
    #endif

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

    //비내리는 텍스쳐 전환
    float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

    //컨텍트 셰도우 연산
    color *= MMN_RecieveContactShadow(input.positionWS);
    
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

    color.a = saturate( diffuseAlpha.a * _BaseColor.a);

    return color;
}

#endif
