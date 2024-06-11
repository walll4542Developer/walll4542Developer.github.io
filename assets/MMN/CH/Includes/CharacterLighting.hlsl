#ifndef MMN_CHARACTER_LIGHTING
#define MMN_CHARACTER_LIGHTING

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../../Includes/EnvironmentHelper.hlsl"
#include "../../Includes/CustomLighting.hlsl"
#include "CharacterMacro.hlsl"
#include "CharacterData.hlsl"
#include "CharacterLighting_MainLight.hlsl"
#include "CharacterLighting_Additional.hlsl"
#include "CharacterLighting_VerticalGradient.hlsl"
#include "CharacterLighting_Silhouette.hlsl"
#include "CharacterLighting_Shadow.hlsl"
// #include "CharacterLighting_ObjectFog.hlsl"
#include "CharacterLimitBrightForBloom.hlsl"

// 여기에서는 그림자 처리가 된 라이트 컬러를 반환하지 않는다.
// 오직 순수한 라이트 색상만 반환한다.
void InitializeLightData(in InputData inputData, out Light mainLight, out LightingData lightingData)
{
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    float4 shadowMask = inputData.shadowMask;

    mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

    if (_CustomLightMode >= 1.0)
    {
        // NOTE : 유니티에서 transform.rotation * Vector3.back 을 한 값이 올바른 방향이다.
        // 해당 값을 편하게 가져오기 위해 다음 툴을 사용하면 좋다.
        // https://deskcat.io/d/R52592/MM-미술-가방-캐릭터-선택창의-라이트-설정하는-방법
        mainLight.direction = _CustomLightDirection.xyz;
        mainLight.color = _CustomLightColor.rgb;
    }

    // 순수한 라이트 색상만 담아서 내보내기 위한 구조체
    lightingData = (LightingData)0;

    // GI color
    lightingData.giColor = _Global_GILightMulti.rgb;

    // NOTE : 0.5인 이유는 GI 컬러만 확인해보고 싶을 때 1.0이 아닌 0.8 정도의 값만 넣어도 동작하도록 하기 위해서이다.
    if (_CustomLightMode >= 0.5)
    {
        lightingData.giColor = _CustomGIColor.rgb;
    }

    // Main light color
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor += mainLight.color;
    }
}

///////////////////////////////////////////////////////////////////////////////
//                              Process Color                                //
///////////////////////////////////////////////////////////////////////////////

float3 ProcessCharacterColor(InputData inputData,
                             Light mainLight, LightingData lightingData, CharacterData characterData, float verticalGradientRemapped,
                             float shadingType, float flatShadingOff, float2 flatShadingAmount, float3 dyedBaseColor, float silhouetteOff, float4 silhouetteTintColor)
{
    float3 cameraDirWS = -GetViewForwardDir();

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    float receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
                                             characterData.characterCenterPos, characterData.visualHeight,
                                             characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    MainLightShadingInput mainLightInput;
    mainLightInput.normalWS = inputData.normalWS;
    mainLightInput.lightDirection = mainLight.direction;
    mainLightInput.cameraDirection = cameraDirWS;
    mainLightInput.verticalGradientRemapped = verticalGradientRemapped;
    mainLightInput.lightingData = lightingData;
    mainLightInput.flatShadingOff = flatShadingOff;
    mainLightInput.flatShadingAmount = flatShadingAmount;
    mainLightInput.shadingType = shadingType;

    MainLightShadingResult mainLightShadingResult;
    GetMainLightShading(mainLightInput, mainLightShadingResult);

//-----------------------------------------------------------------------------
// Silhouette
//-----------------------------------------------------------------------------
#ifdef _SILHOUETTE_FEATURE
    SilhouetteInput silhouetteInput;
    silhouetteInput.lightDir = mainLight.direction;
    silhouetteInput.lightColor = lightingData.mainLightColor;
    silhouetteInput.normalWS = inputData.normalWS;
    silhouetteInput.cameraDirWS = cameraDirWS;
    silhouetteInput.viewDirectionWS = inputData.viewDirectionWS;
    silhouetteInput.receivedShadow = receivedShadow;
    silhouetteInput.dyedBaseColor = dyedBaseColor;
    silhouetteInput.silhouetteTintColor = silhouetteTintColor.rgb;
    silhouetteInput.shadingType = shadingType;

    SilhouetteResult silhouetteResult = (SilhouetteResult)0;
    if (IS_FALSE(silhouetteOff))
    {
        GetSilhouette(silhouetteInput, silhouetteResult);
    }
#endif

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    float3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

#if defined(_ADDITIONAL_LIGHTS_VERTEX)
    additionalLightShading += inputData.vertexLighting;
#else
    additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, true);
#endif

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    float3 mainLightColor = mainLightShadingResult.finalShading * mainLightShadingResult.mainLightResult;
    float3 ambientColor = mainLightShadingResult.ambientLightResult;

    // 아티스트가 앰비언트와 메인을 더해서 1이 초과되게 지정할 수도 있다. 이것이 물리적으로 맞으나
    // 색이 타는 현상이 생겨서 saturate함
    float3 lightColor = saturate(ambientColor + mainLightColor * receivedShadow);
    lightColor = min(lightColor + additionalLightShading, float3(1.6, 1.6, 1.6));

    float3 resultColor;
    resultColor = dyedBaseColor * lightColor;
#ifdef _SILHOUETTE_FEATURE
    resultColor += silhouetteResult.silhouetteColor * (silhouetteResult.silhouette * receivedShadow);
#endif

    // 조명을 강하게 받았을 때 최대 1.5까지 밝아질 수 있다
    resultColor = min(resultColor, float3(1.5, 1.5, 1.5));

    return resultColor;
}

// 메탈 재질도 처리가능한 버전
float3 ProcessCharacterColorFull(InputData inputData,
                                 Light mainLight, LightingData lightingData, CharacterData characterData, FRONT_FACE_TYPE isFacing, float backFaceDarkenAmount, float verticalGradientRemapped,
                                 float shadingType, float2 flatShadingAmount, float3 dyedBaseColor, float silhouetteOff, float4 silhouetteTintColor,
                                 float isMetal, float smoothness, float smoothnessMask, float specularStrength, float4 metalTintColor)
{
    float3 normalWS = IS_FRONT_VFACE(isFacing, inputData.normalWS, -inputData.normalWS);
    float3 cameraDirWS = -GetViewForwardDir();

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    float receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
                                             characterData.characterCenterPos, characterData.visualHeight,
                                             characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    MainLightShadingInput mainLightInput;
    mainLightInput.normalWS = normalWS;
    mainLightInput.lightDirection = mainLight.direction;
    mainLightInput.cameraDirection = cameraDirWS;
    mainLightInput.verticalGradientRemapped = verticalGradientRemapped;
    mainLightInput.lightingData = lightingData;
    mainLightInput.flatShadingOff = 0.0;
    mainLightInput.flatShadingAmount = flatShadingAmount;
    mainLightInput.shadingType = shadingType;

    MainLightShadingResult mainLightShadingResult;
    GetMainLightShading(mainLightInput, mainLightShadingResult);

//-----------------------------------------------------------------------------
// Silhouette
//-----------------------------------------------------------------------------
#ifdef _SILHOUETTE_FEATURE
    SilhouetteInput silhouetteInput;
    silhouetteInput.lightDir = mainLight.direction;
    silhouetteInput.lightColor = lightingData.mainLightColor;
    silhouetteInput.normalWS = normalWS;
    silhouetteInput.cameraDirWS = cameraDirWS;
    silhouetteInput.viewDirectionWS = inputData.viewDirectionWS;
    silhouetteInput.receivedShadow = receivedShadow;
    silhouetteInput.dyedBaseColor = dyedBaseColor;
    silhouetteInput.silhouetteTintColor = silhouetteTintColor.rgb;
    silhouetteInput.shadingType = shadingType;

    SilhouetteResult silhouetteResult = (SilhouetteResult)0;
    if (IS_FALSE(silhouetteOff))
    {
        GetSilhouette(silhouetteInput, silhouetteResult);
    }
#endif

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    float3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

#if defined(_ADDITIONAL_LIGHTS_VERTEX)
    additionalLightShading += inputData.vertexLighting;
#else
    additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, true);
#endif

    //-----------------------------------------------------------------------------
    // Specular / Reflection
    //-----------------------------------------------------------------------------
    float3 specularReflection = float3(0.0, 0.0, 0.0);
#ifdef _METAL_FEATURE
    {
        // NOTE @jihun.song
        // 텍스쳐의 마스크 값이 0이면 마스킹이 아닌 상태(완전한 금속 재질),
        // 1이면 마스킹이 된 상태(금속이 아닌 재질)로 색칠을 해뒀기 때문에
        // 셰이더 안에서 사용할 때에는 직관성을 위해 역수로 사용한다.
        smoothness = smoothness * (1.0 - smoothnessMask);
        // smoothness = 1.0;

        // dyedBaseColor = float3(0.5,0.2,0.0);
        float dyedBaseColorLuminance = dot(dyedBaseColor, float3(0.2126729, 0.7151522, 0.0721750));

        float3 reflectionVec = reflect(float3(-inputData.viewDirectionWS), float3(normalWS));
        float reflectionMapLodBias = (1.0 - smoothness) * 7.0;
        float3 originReflectionColor = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectionVec, reflectionMapLodBias), unity_SpecCube0_HDR);
        // originReflectionColor = saturate(originReflectionColor); // NTOE @jihun.song : 너무 밝게 나오는 것을 방지하기 위한 안전장치.
        // 음수가 나오는 처리를 해야 전반사 느낌을 낼 수 있다.
        // 재질 밝기가 높으면 더 감산하도록 한다.
        originReflectionColor = originReflectionColor * 1.0 - dyedBaseColorLuminance * 0.3 - 0.1;
        originReflectionColor = min(1.2, originReflectionColor);
        float3 grayReflectionColor = dot(originReflectionColor, float3(0.2126729, 0.7151522, 0.0721750)).xxx;

        // 라이트의 블루 부분이 낮아지거나 비가 오면 반사 색상을 그레이스케일로 바꾼다.
        float3 specularLightColor = saturate(lightingData.mainLightColor * receivedShadow + lightingData.giColor);
        float mainLightBrightness = saturate(specularLightColor.b * (1.0 - _Global_Raining));
        float3 reflectionColor = lerp(grayReflectionColor, originReflectionColor, mainLightBrightness);
        float3 reflectionResult = reflectionColor * metalTintColor.rgb * specularLightColor;
        // return reflectionResult;

        float3 floatVec = SafeNormalize(float3(mainLight.direction) + float3(inputData.viewDirectionWS));
        float nDotH = saturate(dot(float3(normalWS), floatVec));
        float specularPower = pow(nDotH, smoothness * smoothness * 512.0);
        float specular = max(0.0, specularPower * smoothness * mainLightBrightness * 12.0);
        float3 specularResult = (specular.xxx * metalTintColor.rgb * specularLightColor) * specularStrength.xxx;
        // return specularResult;

        // 광택이 높으면 전반사가 일어나게 된다.
        // 뒷부분은 휘도에 따라 광택을 좀 죽여주는 처리이다. 블랙일 때 최소값 0.2를 보장
        specularReflection = (reflectionResult + specularResult) * lerp(dyedBaseColor, 1.0, smoothness) * (dyedBaseColorLuminance * 1.0 + 0.2);
        // return specularReflection;

#ifdef _SILHOUETTE_FEATURE
        // 메탈 일 때 Silhouette 튠 해줌.
        silhouetteResult.silhouetteColor += metalTintColor.rgb * (silhouetteResult.silhouette * smoothness * mainLightBrightness);
#endif
    }
#endif

    //-----------------------------------------------------------------------------
    // 2-Side 일 때 살짝 어둡게 처리함.
    //-----------------------------------------------------------------------------
    mainLightShadingResult.finalShading *= IS_FRONT_VFACE(isFacing, 1.0, backFaceDarkenAmount);

#ifdef _SILHOUETTE_FEATURE
    silhouetteResult.silhouetteColor *= IS_FRONT_VFACE(isFacing, 1.0, 0.0); // 뒷면일 때 실루엣은 없는 것이 나아보임.
#endif

    dyedBaseColor *= IS_FRONT_VFACE(isFacing, 1.0, backFaceDarkenAmount);

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    float3 mainLightColor = mainLightShadingResult.finalShading * mainLightShadingResult.mainLightResult;
    float3 ambientColor = mainLightShadingResult.ambientLightResult;

    // 아티스트가 앰비언트와 메인을 더해서 1이 초과되게 지정할 수도 있다. 이것이 물리적으로 맞으나
    // 색이 타는 현상이 생겨서 saturate함
    float3 lightColor = saturate(ambientColor + mainLightColor * receivedShadow);
    lightColor = min(lightColor + additionalLightShading, float3(1.6, 1.6, 1.6));

    float3 resultColor;
    resultColor = dyedBaseColor * lightColor;
#ifdef _SILHOUETTE_FEATURE
    resultColor += silhouetteResult.silhouetteColor * (silhouetteResult.silhouette * receivedShadow);
#endif
    resultColor += specularReflection;

    // 조명을 강하게 받았을 때 최대 1.5까지 밝아질 수 있다
    resultColor = min(resultColor, float3(1.5, 1.5, 1.5));

    return resultColor;
}

// 눈 등에서 간단하게 셰이딩해야 할 때 사용한다.
float3 ProcessCharacterColorSimple(InputData inputData,
                                   Light mainLight, LightingData lightingData, CharacterData characterData,
                                   float3 dyedBaseColor)
{
    //-----------------------------------------------------------------------------
    // Base shade source
    //-----------------------------------------------------------------------------
    float3 cameraDirWS = -GetViewForwardDir();
    float cDotL = dot(cameraDirWS, mainLight.direction);
    float sunVisibility = -cDotL;                                // -1(sun behind me) ~ 1(facing the sun)
    float lightingMask = saturate((1.2 - sunVisibility) * 1.02); // min(1.0, 1.0 - (sunVisibility * 0.7));

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    float receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
                                             characterData.characterCenterPos, characterData.visualHeight,
                                             characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    float finalShading = min(lightingMask, 1.0);
    finalShading = saturate(finalShading);

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    float3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

#if defined(_ADDITIONAL_LIGHTS_VERTEX)
    additionalLightShading += inputData.vertexLighting;
#else
    additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, false);
#endif

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    float3 mainLightColor = lightingData.mainLightColor * finalShading;
    float3 ambientColor = lightingData.giColor;

    float3 lightColor = saturate(ambientColor + mainLightColor * (receivedShadow + 0.14) /*눈을 살짝 밝게*/);
    lightColor = saturate(lightColor + additionalLightShading);

    float3 resultColor;
    resultColor = dyedBaseColor * lightColor;

    return resultColor;
}

#endif // MMN_CHARACTER_LIGHTING
