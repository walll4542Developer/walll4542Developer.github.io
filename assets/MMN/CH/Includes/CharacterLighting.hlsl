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
    half4 shadowMask = inputData.shadowMask;

    mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

    if (_CustomLightMode == 1)
    {
        // NOTE : 유니티에서 transform.rotation * Vector3.back 을 한 값이 올바른 방향이다.
        mainLight.direction = _CustomLightDirection.xyz;
        mainLight.color = _CustomLightColor.rgb;
    }

    // 순수한 라이트 색상만 담아서 내보내기 위한 구조체
    lightingData = (LightingData)0;

    // GI color
    lightingData.giColor = _Global_GILightMulti.rgb;

    if (_CustomLightMode == 1)
    {
        // NOTE: 티르코네일 낮 기준의 giColor
        lightingData.giColor = half3(0.7686275, 0.827451, 0.854902);
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

half3 ProcessCharacterColor(InputData inputData,
    Light mainLight, LightingData lightingData, CharacterData characterData,
    half3 dyedBaseColor, half silhouetteOff, half4 silhouetteTintColor, half flatShadingOff = 0.0)
{
    //-----------------------------------------------------------------------------
    // Main light shade source
    //-----------------------------------------------------------------------------
    half3 cameraDirWS = -GetViewForwardDir();
    // half3 lightDirWSFlatten = normalize(half3(mainLight.direction.x, mainLight.direction.y * 0.65, mainLight.direction.z));
    // half3 cameraDirWSFlatten = normalize(half3(cameraDirWS.x, cameraDirWS.y * 0.1, cameraDirWS.z));
    half cDotL = dot(cameraDirWS, mainLight.direction);
    half nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
    half sunVisibility = -cDotL; // -1(sun behind me) ~ 1(facing the sun)
    half lightingMask = saturate((1.2 - sunVisibility) * 1.02);
    half cameraDistance = distance(GetCameraPositionWS(), characterData.characterPos);

    half verticalGradientRemapped = GetVerticalGradientRemapped(inputData.positionWS.xyz, characterData);

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    half receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
        characterData.characterCenterPos, characterData.visualHeight,
        characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    MainLightShadingInput mainLightInput;
    mainLightInput.normalWS = inputData.normalWS;
    mainLightInput.lightDirection = mainLight.direction;
    mainLightInput.cameraDirection = cameraDirWS;
    mainLightInput.cameraDistance = cameraDistance;
    mainLightInput.cDotL = cDotL;
    mainLightInput.nDotV = nDotV;
    mainLightInput.verticalGradientRemapped = verticalGradientRemapped;
    mainLightInput.lightingMask = lightingMask;
    mainLightInput.dyedBaseColor = dyedBaseColor;
    mainLightInput.lightingData = lightingData;
    mainLightInput.flatShadingOff = flatShadingOff;

    MainLightShadingResult mainLightResult;
    GetMainLightShading(mainLightInput, mainLightResult);

    //-----------------------------------------------------------------------------
    // Silhouette
    //-----------------------------------------------------------------------------
    #ifdef _SILHOUETTE_FEATURE
        SilhouetteInput silhouetteInput;
        silhouetteInput.lightDir = mainLight.direction;
        silhouetteInput.lightColor = lightingData.mainLightColor;
        silhouetteInput.normalWS = inputData.normalWS;
        silhouetteInput.cameraDirWS = cameraDirWS;
        silhouetteInput.nDotV = nDotV;
        silhouetteInput.receivedShadow = receivedShadow;
        silhouetteInput.dyedBaseColor = dyedBaseColor;
        silhouetteInput.silhouetteTintColor = silhouetteTintColor.rgb;

        SilhouetteResult silhouetteResult = (SilhouetteResult)0;
        if (IS_FALSE(silhouetteOff))
        {
            GetSilhouette(silhouetteInput, silhouetteResult);
        }
    #endif

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    half3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        additionalLightShading += inputData.vertexLighting;
    #else
        additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, true);
    #endif

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    half3 mainLightColor = lightingData.mainLightColor * mainLightResult.finalShading * mainLightResult.volumeShadingLight;
    half3 ambientColor = lightingData.giColor * mainLightResult.volumeShadingDark;
    ambientColor = lerp(ambientColor, saturate(ambientColor), receivedShadow);

    // 아티스트가 앰비언트와 메인을 더해서 1이 초과되게 지정할 수도 있다. 이것이 물리적으로 맞으나
    // 색이 타는 현상이 생겨서 saturate함
    half3 lightColor = saturate(ambientColor + mainLightColor * receivedShadow);
    lightColor = lightColor + additionalLightShading;

    half3 resultColor;
    resultColor = dyedBaseColor * lightColor;
    #ifdef _SILHOUETTE_FEATURE
        resultColor += silhouetteResult.silhouetteColor * (silhouetteResult.silhouette * receivedShadow);
    #endif

    // 조명을 강하게 받았을 때 최대 1.5까지 밝아질 수 있다
    resultColor = min(resultColor, 1.5);

    return resultColor;
}

// 메탈 재질도 처리가능한 버전
half3 ProcessCharacterColorFull(InputData inputData,
    Light mainLight, LightingData lightingData, CharacterData characterData, FRONT_FACE_TYPE isFacing, half backFaceDarkenAmount,
    half3 dyedBaseColor, half silhouetteOff, half4 silhouetteTintColor,
    half isMetal, half smoothness, half smoothnessMask, half specularStrength, half4 metalTintColor)
{
    //-----------------------------------------------------------------------------
    // Main light shade source
    //-----------------------------------------------------------------------------
    half3 normalWS = IS_FRONT_VFACE(isFacing, inputData.normalWS, -inputData.normalWS);
    half3 cameraDirWS = -GetViewForwardDir();
    // half3 lightDirWSFlatten = normalize(half3(mainLight.direction.x, mainLight.direction.y * 0.65, mainLight.direction.z));
    // half3 cameraDirWSFlatten = normalize(half3(cameraDirWS.x, cameraDirWS.y * 0.1, cameraDirWS.z));
    half cDotL = dot(cameraDirWS, mainLight.direction);
    half nDotV = dot(normalWS, inputData.viewDirectionWS);
    half sunVisibility = -cDotL; // -1(sun behind me) ~ 1(facing the sun)
    half lightingMask = saturate((1.2 - sunVisibility) * 1.02);
    half cameraDistance = distance(GetCameraPositionWS(), characterData.characterPos);

    half verticalGradientRemapped = GetVerticalGradientRemapped(inputData.positionWS.xyz, characterData);

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    half receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
        characterData.characterCenterPos, characterData.visualHeight,
        characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    MainLightShadingInput mainLightInput;
    mainLightInput.normalWS = normalWS;
    mainLightInput.lightDirection = mainLight.direction;
    mainLightInput.cameraDirection = cameraDirWS;
    mainLightInput.cameraDistance = cameraDistance;
    mainLightInput.cDotL = cDotL;
    mainLightInput.nDotV = nDotV;
    mainLightInput.verticalGradientRemapped = verticalGradientRemapped;
    mainLightInput.lightingMask = lightingMask;
    mainLightInput.dyedBaseColor = dyedBaseColor;
    mainLightInput.lightingData = lightingData;
    mainLightInput.flatShadingOff = 0.0;

    MainLightShadingResult mainLightResult;
    GetMainLightShading(mainLightInput, mainLightResult);

    //-----------------------------------------------------------------------------
    // Silhouette
    //-----------------------------------------------------------------------------
    #ifdef _SILHOUETTE_FEATURE
        SilhouetteInput silhouetteInput;
        silhouetteInput.lightDir = mainLight.direction;
        silhouetteInput.lightColor = lightingData.mainLightColor;
        silhouetteInput.normalWS = normalWS;
        silhouetteInput.cameraDirWS = cameraDirWS;
        silhouetteInput.nDotV = nDotV;
        silhouetteInput.receivedShadow = receivedShadow;
        silhouetteInput.dyedBaseColor = dyedBaseColor;
        silhouetteInput.silhouetteTintColor = silhouetteTintColor.rgb;

        SilhouetteResult silhouetteResult = (SilhouetteResult)0;
        if (IS_FALSE(silhouetteOff))
        {
            GetSilhouette(silhouetteInput, silhouetteResult);
        }
    #endif

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    half3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        additionalLightShading += inputData.vertexLighting;
    #else
        additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, true);
    #endif

    //-----------------------------------------------------------------------------
    // Specular / Reflection
    //-----------------------------------------------------------------------------
    half3 specularReflection = half3(0.0, 0.0, 0.0);
    #ifdef _METAL_FEATURE
    {
        // NOTE @jihun.song
        // 텍스쳐의 마스크 값이 0이면 마스킹이 아닌 상태(완전한 금속 재질),
        // 1이면 마스킹이 된 상태(금속이 아닌 재질)로 색칠을 해뒀기 때문에
        // 셰이더 안에서 사용할 때에는 직관성을 위해 역수로 사용한다.
        smoothness = smoothness * (1.0 - smoothnessMask);

        half3 reflectionVec = reflect(half3(-inputData.viewDirectionWS), half3(normalWS));
        half reflectionMapLodBias = (1.0 - smoothness) * 7.0;
        half3 originReflectionColor = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectionVec, reflectionMapLodBias), unity_SpecCube0_HDR);
        originReflectionColor = saturate(originReflectionColor); // NTOE @jihun.song : 너무 밝게 나오는 것을 방지하기 위한 안전장치.
        half3 grayReflectionColor = dot(originReflectionColor, half3(0.2126729, 0.7151522, 0.0721750)).xxx;

        // 라이트의 블루 부분이 낮아지거나 비가 오면 반사 색상을 그레이스케일로 바꾼다.
        half3 specularLightColor = saturate(lightingData.mainLightColor * receivedShadow + lightingData.giColor);
        half mainLightBrightness = saturate(specularLightColor.b * (1.0 - _Global_Raining));
        half3 reflectionColor = lerp(grayReflectionColor, originReflectionColor, mainLightBrightness);
        half3 reflectionResult = reflectionColor * metalTintColor.rgb * specularLightColor * smoothness;
        // return reflectionResult;

        half3 halfVec = SafeNormalize(half3(mainLight.direction) + half3(inputData.viewDirectionWS));
        half nDotH = saturate(dot(half3(normalWS), halfVec));
        half specularPower = pow(nDotH, smoothness * smoothness * 512.0);
        half specular = max(0.0, specularPower * smoothness * mainLightBrightness * 12.0);
        half3 specularResult = (specular.xxx * reflectionResult * metalTintColor.rgb * specularLightColor) * specularStrength.xxx;
        // return specularResult;

        specularReflection = (reflectionResult + specularResult) * dyedBaseColor;
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
    mainLightResult.finalShading *= IS_FRONT_VFACE(isFacing, 1.0, backFaceDarkenAmount);

    #ifdef _SILHOUETTE_FEATURE
        silhouetteResult.silhouetteColor *= IS_FRONT_VFACE(isFacing, 1.0, 0.0);  // 뒷면일 때 실루엣은 없는 것이 나아보임.
    #endif

    dyedBaseColor *= IS_FRONT_VFACE(isFacing, 1.0, backFaceDarkenAmount);

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    half3 mainLightColor = lightingData.mainLightColor * mainLightResult.finalShading * mainLightResult.volumeShadingLight;
    half3 ambientColor = lightingData.giColor * mainLightResult.volumeShadingDark;

    // 아티스트가 앰비언트와 메인을 더해서 1이 초과되게 지정할 수도 있다. 이것이 물리적으로 맞으나
    // 색이 타는 현상이 생겨서 saturate함
    half3 lightColor = saturate(ambientColor + mainLightColor * receivedShadow);
    // 조명을 강하게 받았을 때 최대 2.6까지 밝아질 수 있다
    lightColor = min(lightColor + additionalLightShading, half3(2.6, 2.6, 2.6));

    half3 resultColor;
    resultColor = dyedBaseColor * lightColor;
    #ifdef _SILHOUETTE_FEATURE
        resultColor += silhouetteResult.silhouetteColor * (silhouetteResult.silhouette * receivedShadow);
    #endif
    resultColor += specularReflection;

    // 조명을 강하게 받았을 때 최대 1.5까지 밝아질 수 있다
    resultColor = min(resultColor, 1.5);

    return resultColor;
}

// 눈 등에서 간단하게 셰이딩해야 할 때 사용한다.
half3 ProcessCharacterColorSimple(InputData inputData,
    Light mainLight, LightingData lightingData, CharacterData characterData,
    half3 dyedBaseColor)
{
    //-----------------------------------------------------------------------------
    // Base shade source
    //-----------------------------------------------------------------------------
    half3 cameraDirWS = -GetViewForwardDir();
    // half3 lightDirWSFlatten = normalize(half3(mainLight.direction.x, mainLight.direction.y * 0.65, mainLight.direction.z));
    // half3 cameraDirWSFlatten = normalize(half3(cameraDirWS.x, cameraDirWS.y * 0.1, cameraDirWS.z));
    half cDotL = dot(cameraDirWS, mainLight.direction);
    half sunVisibility = -cDotL; // -1(sun behind me) ~ 1(facing the sun)
    half lightingMask = saturate((1.2 - sunVisibility) * 1.02);//min(1.0, 1.0 - (sunVisibility * 0.7));

    //-----------------------------------------------------------------------------
    // Received shadow
    // receivedShadow : 0이면 그림자를 받는 상태, 1이면 그림자를 받지 않는 상태.
    //                  [0, 1] 값이 머리와 발 끝의 그림자 수신 여부에 따라 그라디언트로 출력됨.
    //-----------------------------------------------------------------------------
    half receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
        characterData.characterCenterPos, characterData.visualHeight,
        characterData.topShadow, characterData.bottomShadow);

    //-----------------------------------------------------------------------------
    // Main light shading
    //-----------------------------------------------------------------------------
    half finalShading = min(lightingMask, 1.0);
    finalShading = saturate(finalShading);

    //-----------------------------------------------------------------------------
    // Additional light shading
    //-----------------------------------------------------------------------------
    half3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        additionalLightShading += inputData.vertexLighting;
    #else
        additionalLightShading = AdditionalLightsFragment(inputData, cameraDirWS, false);
    #endif

    //-----------------------------------------------------------------------------
    // Result
    //-----------------------------------------------------------------------------
    half3 mainLightColor = lightingData.mainLightColor * finalShading;
    half3 ambientColor = lightingData.giColor;

    half3 lightColor = saturate(ambientColor + mainLightColor * receivedShadow + 0.14 /*눈을 살짝 밝게*/);
    lightColor = saturate(lightColor + additionalLightShading);

    half3 resultColor;
    resultColor = dyedBaseColor * lightColor;

    return resultColor;
}

#endif // MMN_CHARACTER_LIGHTING
