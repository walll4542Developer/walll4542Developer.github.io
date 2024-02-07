#ifndef MMN_CUSTOMLIGHTING_INCLUDED
#define MMN_CUSTOMLIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"

//GlobalVariables

TEXTURE2D(_Global_LightRampTexture);
SAMPLER(sampler_Global_LightRampTexture);

///////////////////////////////////////////////////////////////////////////////
//                      Custom Shadow Functions                              //
///////////////////////////////////////////////////////////////////////////////


//구름 그림자를 만듭니다.
inline float MMN_GlobalTex_CloudShadows(float3 positionWS)
{
    float2 worldUV = positionWS.xz * 0.001 * _Global_CloudScale;
    // float4 GlobalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture,frac(worldUV) + frac(_Time.x*_Global_CloudSpeed*0.01 )) ;
    InitializeGlobalValue();
    float4 GlobalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV + _Global_WindUV);

    GlobalTexture.r = saturate(GlobalTexture.r + _Global_CloudDensity);
    GlobalTexture.r = pow(GlobalTexture.r, _Global_CloudEdgeHardness);

    if (unity_OrthoParams.w == 1) //Ortho에서는 사라지게 한다
    return 1;
    else
        return GlobalTexture.r ;
}


// 컨텍트 셰도우 : 일반 버전
inline float MMN_RecieveContactShadow(float3 positionWS)
{
    float CapsuleHeight = 0.5; // 그림자 캡슐의 상하 크기를 말한다
    float ContactShadow = 0;

    float3 diff = _Global_pos.rgb - positionWS ;
    diff.y -= clamp(diff.y, -CapsuleHeight - 1.2, CapsuleHeight - 0.7); //y쪽으로 캡슐을 만들어 준다 . 위 - 아래 높이순
    float diffRange = saturate(dot(diff, diff) / 0.6); //올리면 멀어짐
    float ContactShadowRange = pow(diffRange, 0.5);//올리면 경계가 날카로와짐
    return lerp(1.0, saturate(ContactShadowRange + 0.2), _Global_ContactShadowStrength);//밝기조절

}

//컨텍스 셰도우 : 그림자 안에서만 진한 버전
inline float MMN_RecieveContactShadow(float3 positionWS, float4 shadowCoord)
{
    float CapsuleHeight = 0.5; // 그림자 캡슐의 상하 크기를 말한다
    float ContactShadow = 0;

    Light mainLight = GetMainLight(shadowCoord);
    float attanWithCloudShadow = (mainLight.distanceAttenuation * saturate(min(mainLight.shadowAttenuation, MMN_GlobalTex_CloudShadows(positionWS).r)));

    float3 diff = _Global_pos.rgb - positionWS ;
    diff.y -= clamp(diff.y, -CapsuleHeight - 1.2, CapsuleHeight - 0.7); //y쪽으로 캡슐을 만들어 준다 . 위 - 아래 높이순
    float diffRange = saturate(dot(diff, diff) / 0.3); //올리면 멀어짐
    float ContactShadowRange = pow(diffRange, 0.4);//올리면 경계가 날카로와짐
    // return attanWithCloudShadow;
    return lerp(1.0, saturate(ContactShadowRange + attanWithCloudShadow * 0.3), _Global_ContactShadowStrength);//밝기조절

}


// 라이트맵이 이미 구워진 상태에서 리얼타임 라이트와 셰도우를 받을 수 있게 처리한다. 셰도우 캐스팅은 하지 않고 리시브만 하는 것이다
// 리얼타임 그림자는 Environment 리얼타임 셰도우 칼라 조절값을 받아와 처리도 한다
float3 MMN_SubtractDirectMainLightFromLightmap(Light mainLight, float3 normalWS, float3 bakedGI)
{
    float shadowStrength = GetMainLightShadowStrength(); // 리얼타임 셰도우 강도
    float NdotL = saturate(dot(mainLight.direction, normalWS));
    NdotL = max(NdotL, bakedGI.x) ; // NdotL과 라이트맵중 밝은 것만 취한다
    float3 lambert = mainLight.color * NdotL;
    float3 realtimeShadow = saturate(max(mainLight.shadowAttenuation, _SubtractiveShadowColor.xyz)) ;//리얼타임 그림자 색을, 라이팅 탭에서의 RealtimeShadowColor를 받아 적용한다

    float3 realtimeLightNShadow = lambert * realtimeShadow; //라이트 칼라 * 리얼타임 그림자

    return lerp(saturate(realtimeLightNShadow + 0.5) * bakedGI, bakedGI, mainLight.shadowAttenuation)   ;
}


///////////////////////////////////////////////////////////////////////////////
//                      Final Lighting Functions                             //
///////////////////////////////////////////////////////////////////////////////


struct LightingDataCustom
{
    half3 giColor;
    half3 mainLightColor;
    half3 additionalLightsColor;
    half3 vertexLightingColor;
    half3 emissionColor;
};

// 디버그용 함수
float3 CalculateLightingColorCustom(LightingDataCustom lightingDataCustom, float3 albedo)
{
    float3 lightingColor = 0;

    if (IsOnlyAOLightingFeatureEnabled())
    {
        return lightingDataCustom.giColor; // Contains white + AO

    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        lightingColor += lightingDataCustom.giColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    {
        lightingColor += lightingDataCustom.mainLightColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    {
        lightingColor += lightingDataCustom.additionalLightsColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
    {
        lightingColor += lightingDataCustom.vertexLightingColor;
    }

    lightingColor *= albedo;

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_EMISSION))
    {
        lightingColor += lightingDataCustom.emissionColor;
    }

    return lightingColor;
}

half4 CalculateFinalColorCustom(LightingDataCustom lightingDataCustom, half alpha) //연산이 여기로 먼저 들어옴

{
    half3 finalColor = CalculateLightingColorCustom(lightingDataCustom, 1);

    return half4(finalColor, alpha);
}


// 디버그용 함수 . 나무용. LightingDataCustom 이 LightingData 구조체를 받아 그대로 추가한 것이라서 half 프리시젼을 맞춰야 한다
half3 CalculateLightingColorCustom4Tree(LightingDataCustom lightingDataCustom)
{
    half3 lightingColor = 0;

    if (IsOnlyAOLightingFeatureEnabled())
    {
        return lightingDataCustom.giColor; // Contains white + AO

    }


    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    {
        lightingColor += lightingDataCustom.mainLightColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    {
        lightingColor += lightingDataCustom.additionalLightsColor;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
    {
        lightingColor += lightingDataCustom.vertexLightingColor;
    }

    // lightingColor *= albedo;

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_EMISSION))
    {
        // lightingColor += lightingDataCustom.emissionColor;
        lightingColor += 0;
    }

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        lightingColor += lightingDataCustom.giColor;
    }
    return lightingColor;
}


///////////////////////////////////////////////////////////////////////////////
//                          램버트  함수                                      //
///////////////////////////////////////////////////////////////////////////////


float3 MM_LightingLambert(float3 lightColor, float3 lightDir, float3 normal)
{
    float NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}

float3 MM_LightingHalfLambert(float3 lightColor, float3 lightDir, float3 normal)
{
    float NdotL = dot(normal, lightDir) * 0.5 + 0.5;
    return lightColor * saturate(NdotL);
}

// //램프 텍스쳐 Y = 0.5 고정버전
// float3 MM_LightingRampTex(float3 lightColor, float3 lightDir, float3 normal)
// {
//     float NdotL = saturate(dot(normal, lightDir));
//     float4 RampLight = SAMPLE_TEXTURE2D(_Global_LightRampTexture, sampler_Global_LightRampTexture, float2(NdotL, 0.5));
//     return lightColor * RampLight.rgb;
// }

//램프 텍스쳐 Y 조절버전
float3 MM_LightingRampTex(float3 lightColor, float3 lightDir, float3 normal, float RampY)
{
    float NdotL = saturate(dot(normal, lightDir));
    float4 RampLight = SAMPLE_TEXTURE2D(_Global_LightRampTexture, sampler_Global_LightRampTexture, float2(NdotL, RampY));
    return lightColor * RampLight.rgb;
}

//램버트와 똑같지만 Additional만 따로 제어할 일이 있을 것 같아서 둡니다.
float3 MM_LightingLambertAdditional(float3 lightColor, float3 lightDir, float3 normal)
{
    float NdotL = saturate(dot(normal, lightDir));
    return lightColor * NdotL;
}



///////////////////////////////////////////////////////////////////////////////
//                          스페큘러 함수들 모음                              //
///////////////////////////////////////////////////////////////////////////////


//블린 퐁 스페큘러 연산
float3 LightingSpecularCustomBlinnPhong(float3 lightColor, float3 lightDir, float3 normal, float3 viewDir, float4 specular, float smoothness, float cloudShadow)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    float NdotH = saturate(dot(normal, halfVec));
    float modifier = saturate(pow(NdotH, smoothness * 512));
    float3 specularReflection = specular.rgb * modifier;
    return lightColor * specularReflection * cloudShadow ;
}

// 퐁 스페큘러 연산
float3 LightingSpecularCustomPhong(float3 lightColor, float3 lightDir, float3 normal, float3 viewDir, float4 specular, float smoothness, float cloudShadow)
{
    float3 Reflection = reflect(-lightDir, normal);
    float RdotL = saturate(dot(Reflection, viewDir));
    float modifier = saturate(pow(RdotL, smoothness * 512));
    float3 specularReflection = specular.rgb * modifier;
    return lightColor * specularReflection * cloudShadow /* * (smoothness*5) */;
}

// Screen Space Fake Spacular
float3 LightingFakeScreenSpaceSpecular(float4 specular, float smoothness, float cloudShadow, float4 screenPos)
{

    Light mainLight = GetMainLight();

    float fakespecularScreenSphere = saturate(distance(((screenPos.xy / screenPos.w) - float2(0.7, 0.8)).xy, 0));
    fakespecularScreenSphere = pow((1 - fakespecularScreenSphere), smoothness * 10);

    float fakespecularScreenSphere2 = saturate(distance(((screenPos.xy / screenPos.w) - float2(0.2, 0.3)).xy, 0));
    fakespecularScreenSphere += pow((1 - fakespecularScreenSphere2), smoothness * 10);

    return saturate(mainLight.color * fakespecularScreenSphere * cloudShadow) * specular.rgb  ;
}


//리플렉션 프로브
float3 LightingReflectionProbe(float3 viewDirectionWS, float3 normalWS, float _Glossiness)
{
    real3 reflectVec = reflect(-viewDirectionWS, normalWS);
    real3 Reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, (1 - _Glossiness) * 3), unity_SpecCube0_HDR);
    return Reflectionprobe;
}


///////////////////////////////////////////////////////////////////////////////
//                      라이팅  연산용  함수들                                 //
///////////////////////////////////////////////////////////////////////////////


//버텍스 라이트 연산
float3 MM_VertexLighting(float3 positionWS, float3 normalWS)
{
    float3 vertexLightColor = float3(0.0, 0.0, 0.0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        uint lightsCount = GetAdditionalLightsCount();
        uint meshRenderingLayers = GetMeshRenderingLightLayer();

        LIGHT_LOOP_BEGIN(lightsCount)
        Light light = GetAdditionalLight(lightIndex, positionWS);

        #ifdef _LIGHT_LAYERS
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            float3 lightColor = light.color * light.distanceAttenuation  ;
            vertexLightColor += pow(saturate(dot(normalWS, light.direction)), 0.45) * lightColor * 0.45;
        }
        LIGHT_LOOP_END


        //거리가 멀어지면 버텍스 라이트가 점점 없어지는 처리
        // float3 diff = ((_Global_pos.rgb - positionWS) / 10) ;
        // float diffRange = 1 - saturate(dot(diff, diff));
        // diffRange = diffRange * diffRange * diffRange * diffRange;
        // vertexLightColor *= saturate(diffRange + (1- _Global_pos.w));


    #endif

    return vertexLightColor ;
}




//유니티 2021.2.3 용 신형  램버트 + 스페큘러 연산
float3 CalculateLightingCustom(Light light, InputData inputData, SurfaceData surfaceData, float cloudShadow, float shadowDimming, float halfLambertWeight)
{
    //라이트 칼라
    float3 attenuatedLightColor = light.color ;

    //감쇠와 구름 그림자
    float attanWithCloudShadow = (light.distanceAttenuation * saturate(min(light.shadowAttenuation, cloudShadow) + shadowDimming));
    attenuatedLightColor *= attanWithCloudShadow;


    ///////////////////////////////////////////////////////////////////////////
    //  램버트 연산
    ///////////////////////////////////////////////////////////////////////////
    // #define LIGHT_RAMPTEXLIGHT 1 이라고 쓰면 램프텍스쳐를 사용하는 라이팅이 된다.

    // #if LIGHT_RAMPTEXLIGHT // 램프텍스쳐 라이트를 사용하고 싶은 경우 쓴다
    //     float3 lightColor = MM_LightingRampTex(attenuatedLightColor, light.direction, inputData.normalWS, RampY) ;
    //     lightColor *= surfaceData.albedo ;

    // #else if LIGHT_RampTex_RampYcontrol //램프 라이트 텍스쳐 Y를 콘트롤 하고 싶을때 쓴다
    //     float3 lightColor = MM_LightingRampTex(attenuatedLightColor, light.direction, inputData.normalWS, RampY) ;
    //     lightColor *= surfaceData.albedo ;

    // #else //일반 램버트 라이트를 쓰고 싶은 경우 쓴다
    //     float3 lightColor = MM_LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS) ;
    //     lightColor *= surfaceData.albedo ;
    // #endif

    //  램버트와 하프램버트를 가중치에 따라 제어
    float3 HalfLambertColor = MM_LightingHalfLambert(attenuatedLightColor, light.direction, inputData.normalWS);
    float3 LambertLightColor = MM_LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
    float normalYmask = saturate(inputData.normalWS.y);
    float3 lightColor = lerp(LambertLightColor, HalfLambertColor, halfLambertWeight);
    lightColor *= surfaceData.albedo ;



    ////////////////////////////////////////////////////////////////////////////
    //  스페큘러 연산
    ////////////////////////////////////////////////////////////////////////////

    //내장 원본 스페큘러 연산. 봉인하고 커스텀 연산으로 갑니다.
    // #if defined(_SPECGLOSSMAP) || defined(_SPECULAR_COLOR)
    // float smoothness = exp2(10 * surfaceData.smoothness + 1);
    // lightColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, float4(surfaceData.specular, 1), smoothness);
    // #endif

    #if LIGHT_SPECULAR
        lightColor += LightingSpecularCustomPhong(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, float4(surfaceData.specular, 1), surfaceData.smoothness, cloudShadow);
    #endif

    //스크린 스페이스 페이크 스페큘러 연산.화면에 가짜 스페큘러를 그려주는 연산이지만 봉인
    //lightColor += LightingFakeScreenSpaceSpecular(attenuatedLightColor,  float4(surfaceData.specular,1), surfaceData.smoothness ,cloudShadow, screenPos);


    ///////////////////////////////////////////////////////////////////////////
    //  그림자 곱하기
    ///////////////////////////////////////////////////////////////////////////
    lightColor *= saturate(light.shadowAttenuation + shadowDimming);

    return lightColor;
}



float3 adjustFallOff(float x)
{
    return x;//max(0.0,x-float3(0.06,0.07,0.02));

}

//유니티 2021.2.3 용 신형  램버트 + 스페큘러 연산 / Additional 라이트 전용
float3 CalculateLightingCustomAdditionalLight(Light light, InputData inputData, SurfaceData surfaceData, float cloudShadow, float shadowDimming)
{
    float3 attenuatedLightColor = light.color ;
    float3 attanWithCloudShadow = (adjustFallOff(light.distanceAttenuation) * saturate(min(light.shadowAttenuation, cloudShadow) + shadowDimming));
    attenuatedLightColor *= attanWithCloudShadow;

    float3 lightColor = MM_LightingLambertAdditional(attenuatedLightColor, light.direction, inputData.normalWS) ;
    lightColor *= surfaceData.albedo ;

    #if LIGHT_SPECULAR
        lightColor += LightingSpecularCustomPhong(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, float4(surfaceData.specular, 1), surfaceData.smoothness, cloudShadow);
    #endif
    lightColor *= saturate(light.shadowAttenuation + shadowDimming);

    return lightColor;
}


//어두워질수록 채도가 빠집니다. 2022.3.2 봉인
// float3 DesaturationByLighting( float3 albedo , float3 mainLightColor ){
//     float luminance = dot(albedo, float3(0.3,0.59,0.11));
//     return lerp(luminance.rrr,albedo, saturate((mainLightColor.r + mainLightColor.g)/2+0.2));
// }


///////////////////////////////////////////////////////////////////////////////
//                          라이팅   함수   본체                              //
///////////////////////////////////////////////////////////////////////////////


// LOD 를 위한 초 저렴한 라이트 연산 함수
float4 UniversalFragmentLightCustomLOD(InputData inputData, SurfaceData surfaceData)
{
    #if defined(DEBUG_DISPLAY) //텍스쳐 데이터 디버그 디스플레이용
        float4 debugColor;
        if (CanDebugOverrideOutputColor(inputData, surfaceData, debugColor))
        {
            return debugColor;
        }
    #endif

    Light mainLight = GetMainLight();

    inputData.bakedGI *= _Global_GILightMulti.rgb;
    inputData.bakedGI *= surfaceData.albedo;

    // 가짜 GI 트릭. 카메라를 내리면 GI가 푸른빛이 돌게 된다.
    // 이전 공식이 옆면까지 이 계산이 들어가서 Y 각도에만 반응하게 만들었으며, 어두워지지 않도록 휴리스틱하게 색상을 추가 조절하였다
    float3 fakeGIcolorTrick = saturate(_Global_SkyColorTop.rgb * saturate(1 - dot(inputData.viewDirectionWS, float3(0, 1, 0)))) * inputData.bakedGI;
    fakeGIcolorTrick *= _Global_SkyColorTop.rgb * _Global_SkyColorTop.rgb * _Global_SkyColorTop.rgb;
    inputData.bakedGI += saturate(fakeGIcolorTrick) + 0.01 ; //휴리스틱 수치 + 0.01

    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    lightingData.mainLightColor += CalculateLightingCustom(mainLight, inputData, surfaceData, MMN_GlobalTex_CloudShadows(inputData.positionWS).r, /* shadowDimming */0, /* halfLambertWeight */0);
    return CalculateFinalColorCustom(lightingData, surfaceData.alpha);
}

// 유니티 2021.2.3 용 신형 라이트 함수
float4 UniversalFragmentLightCustom(InputData inputData, SurfaceData surfaceData, float shadowDimming, float halfLambertWeight, float _BackfaceReceiveShadowOff, FRONT_FACE_TYPE isFacing, float BackFaceNormalturn)
{
    #if defined(DEBUG_DISPLAY) //텍스쳐 데이터 디버그 디스플레이용
        float4 debugColor;

        if (CanDebugOverrideOutputColor(inputData, surfaceData, debugColor))
        {
            return debugColor;
        }
    #endif

    //2side를 사용할때 뒷면의 노말을 뒤집어준다. 깃발 같은 데서 사용
    BackFaceNormalturn = BackFaceNormalturn * 2 - 1;
    inputData.normalWS = IS_FRONT_VFACE(isFacing, inputData.normalWS, -inputData.normalWS * BackFaceNormalturn);

    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    float4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData); //SSAO
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, aoFactor);

    inputData.bakedGI *= _Global_GILightMulti.rgb;
    inputData.bakedGI *= surfaceData.albedo;

    // 가짜 GI 트릭. 카메라를 내리면 GI가 푸른빛이 돌게 된다.
    // 이전 공식이 옆면까지 이 계산이 들어가서 Y 각도에만 반응하게 만들었으며, 어두워지지 않도록 휴리스틱하게 색상을 추가 조절하였다
    float3 fakeGIcolorTrick = saturate(_Global_SkyColorTop.rgb * saturate(1 - dot(inputData.viewDirectionWS, float3(0, 1, 0)))) * inputData.bakedGI;
    fakeGIcolorTrick *= _Global_SkyColorTop.rgb * _Global_SkyColorTop.rgb * _Global_SkyColorTop.rgb;
    inputData.bakedGI += saturate(fakeGIcolorTrick) ;


    // 어두워질때 채도빼는 기능으로 대체 - 2022.3.2봉인
    //  inputData.bakedGI *= DesaturationByLighting (surfaceData.albedo , mainLight.color);

    if (_BackfaceReceiveShadowOff != 0)
    {
        //뒷면에서 오는 리시트 셰도우를 무시해 버린다
        shadowDimming += 1 - saturate(dot(mainLight.direction, inputData.normalWS)) ;
        shadowDimming = saturate(shadowDimming);
    }

    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor += CalculateLightingCustom(mainLight, inputData, surfaceData, MMN_GlobalTex_CloudShadows(inputData.positionWS).r, shadowDimming, halfLambertWeight);
    }

    //Additional Light
    #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();

        #if USE_CLUSTERED_LIGHTING //클러스터 라이팅. 구현되어 있나? 안 되어 있을텐데 코드가 있음...
            for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
            {
                Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
                if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                {
                    lightingData.additionalLightsColor += CalculateLightingCustomAdditionalLight(light, inputData, surfaceData, /*MMN_GlobalTex_CloudShadows( inputData.positionWS ).r*/1, shadowDimming); //Additional 라이트는 구름 그림자가 필요없음

                }
            }
        #endif

        LIGHT_LOOP_BEGIN(pixelLightCount) //일반 라이팅 루프
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += CalculateLightingCustomAdditionalLight(light, inputData, surfaceData, /*MMN_GlobalTex_CloudShadows( inputData.positionWS ).r*/1, shadowDimming); //Additional 라이트는 구름 그림자가 필요없음
            lightingData.additionalLightsColor = saturate(lightingData.additionalLightsColor);
        }
        LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        lightingData.vertexLightingColor += inputData.vertexLighting * surfaceData.albedo ;
    #endif


    return CalculateFinalColorCustom(lightingData, surfaceData.alpha);
}


//라이트맵 베이크된 상태에서, 라이트맵과 리얼타임 라이트와 셰도우를 받기만 하는 라이팅 함수
//일명 HalfSubtractive 라이트맵 셰이더라고 이름을 지었다.
float4 UniversalFragmentLightCustomBaked(InputData inputData, SurfaceData surfaceData, float shadowDimming, float halfLambertWeight, float _BackfaceReceiveShadowOff, FRONT_FACE_TYPE isFacing, float BackFaceNormalturn)
{
    #if defined(DEBUG_DISPLAY) //텍스쳐 데이터 디버그 디스플레이용
        float4 debugColor;

        if (CanDebugOverrideOutputColor(inputData, surfaceData, debugColor))
        {
            return debugColor;
        }
    #endif

    //2side를 사용할때 뒷면의 노말을 뒤집어준다
    BackFaceNormalturn = BackFaceNormalturn * 2 - 1;
    inputData.normalWS = IS_FRONT_VFACE(isFacing, inputData.normalWS, -inputData.normalWS * BackFaceNormalturn);

    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    float4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData); //SSAO . 구조체로 넘어옵니다. 그래서 삭제하지 않습니다.
    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);

    // MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, aoFactor); // 이것은 라이트맵이 구워졌을때만 가능. 우리는 라이트를 새로 생성하므로 이 함수가 안먹음. 거기다 리얼타임 라이트 계산은 없음
    // #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
    // #if defined(_MIXED_LIGHTING_SUBTRACTIVE)
    inputData.bakedGI = MMN_SubtractDirectMainLightFromLightmap(mainLight, inputData.normalWS, inputData.bakedGI);// 그래서 강제로 가동시킨다.aoFactor 는 디버그 전용이라 가동시키지 않았다. MixRealtimeAndBakedGI 함수를 찾아보도록
    // #endif
    // inputData.bakedGI = 0;

    inputData.bakedGI *= _Global_GILightMulti.rgb;
    inputData.bakedGI *= surfaceData.albedo;


    // if (_BackfaceReceiveShadowOff != 0)
    // {
    //     //뒷면에서 오는 리시트 셰도우를 무시해 버린다
    //     shadowDimming += 1 - saturate(dot(mainLight.direction, inputData.normalWS)) ;
    //     shadowDimming = saturate(shadowDimming);
    // }

    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        // lightingData.mainLightColor += CalculateLightingCustom(mainLight, inputData, surfaceData, MMN_GlobalTex_CloudShadows(inputData.positionWS).r, shadowDimming, halfLambertWeight);
        lightingData.mainLightColor = 0;
    }


    //Additional Light
    #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();

        LIGHT_LOOP_BEGIN(pixelLightCount) //일반 라이팅 루프
        Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += CalculateLightingCustomAdditionalLight(light, inputData, surfaceData, /*MMN_GlobalTex_CloudShadows( inputData.positionWS ).r*/1, shadowDimming); //Additional 라이트는 구름 그림자가 필요없음
            lightingData.additionalLightsColor = saturate(lightingData.additionalLightsColor);
        }
        LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        lightingData.vertexLightingColor += inputData.vertexLighting * surfaceData.albedo ;
    #endif


    return CalculateFinalColorCustom(lightingData, surfaceData.alpha);
}


//유니티 2021.2.3 용 나뭇잎용 라이팅
float3 UniversalFragmentTreeLeaves2(InputData inputData, SurfaceData surfaceData, float3 posObjectNormal, float _NormalLerp, float _ShadingPow, float _ReceiveShadowStrength, float _GIStrength)
{

    //라이트 연산용 기본 변수들
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    float4 shadowMask = CalculateShadowMask(inputData);
    // Light mainLight = GetMainLight(inputData.shadowCoord);
    // Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

    float3 posWorldNormal = TransformObjectToWorldDir(posObjectNormal);
    posWorldNormal = normalize(posWorldNormal);
    float3 worldNormal = normalize(inputData.normalWS);
    float3 lightDir = normalize(mainLight.direction);
    float3 viewDir = normalize(inputData.viewDirectionWS);
    float NdotL = dot(lightDir, lerp(worldNormal, posWorldNormal.rgb, _NormalLerp));

    //나무 라이팅 연산 + 구름 그림자 =================
    MixRealtimeAndBakedGI(mainLight, worldNormal, inputData.bakedGI, float4(0, 0, 0, 0));
    // float stepShadow = step(0.65, NdotL);
    float shadowAtten = saturate(mainLight.shadowAttenuation + (1 - _ReceiveShadowStrength));
    float3 attenuatedLightColor = mainLight.color * saturate(mainLight.distanceAttenuation * shadowAtten);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        float clampedNdotL = clamp(pow(saturate(NdotL), _ShadingPow), 0.01, 1);
        clampedNdotL = saturate(clampedNdotL + _GIStrength);//음영부분 너무 어두우면 밝게 만들 수 있다 . 투과의 느낌이랄까.
        lightingData.mainLightColor += clampedNdotL * attenuatedLightColor * MMN_GlobalTex_CloudShadows(inputData.positionWS).r ;
    }

    lightingData.giColor = inputData.bakedGI * _Global_GILightMulti.rgb ;
    // 나뭇잎은 아래로 향하면 어두워지게 함. 대부분 둥글고 차폐가 일어나는 재질이므로 이렇게 하면 더 보기 좋다.
    lightingData.giColor *= inputData.normalWS.y * 0.4 + 0.6;

    //additional light
    #if defined(_ADDITIONAL_LIGHTS)
        uint pixelLightCount = GetAdditionalLightsCount();

        #if USE_CLUSTERED_LIGHTING //클러스터 라이팅. 구현되어 있나? ->  구현되어 있지 않았다!!
            for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                {
                    lightingData.additionalLightsColor += CalculateLightingCustomAdditionalLight(light, inputData, surfaceData, /*MMN_GlobalTex_CloudShadows( inputData.positionWS ).r*/1, /*shadowDimming*/0); //Additional 라이트는 구름 그림자가 필요없음

                }
            }
        #endif

        LIGHT_LOOP_BEGIN(pixelLightCount) //일반 라이팅 루프
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
        if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        {
            lightingData.additionalLightsColor += CalculateLightingCustomAdditionalLight(light, inputData, surfaceData, /*MMN_GlobalTex_CloudShadows( inputData.positionWS ).r*/1, /*shadowDimming*/0); //Additional 라이트는 구름 그림자가 필요없음
            lightingData.additionalLightsColor = saturate(lightingData.additionalLightsColor);
        }
        LIGHT_LOOP_END
    #endif

    #if defined(_ADDITIONAL_LIGHTS_VERTEX)
        lightingData.vertexLightingColor += inputData.vertexLighting * surfaceData.albedo;
    #endif

    return CalculateLightingColorCustom4Tree(lightingData);
}



//나뭇잎용 라이팅 임포스터 전용
float3 UniversalFragmentTreeLeavesImposter(InputData inputData, float _ShadingPow, float _ReceiveShadowStrength, float _GIStrength)
{
    Light mainLight = GetMainLight(inputData.shadowCoord);


    float3 lightDir = normalize(mainLight.direction);
    float3 viewDir = normalize(inputData.viewDirectionWS);
    float NdotL = dot(lightDir, inputData.normalWS);
    float3 diffuseColor = float3(0, 0, 0);

    //나무 라이팅 연산 + 구름 그림자 =================
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, float4(0, 0, 0, 0));
    // float stepShadow = step(0.65, NdotL);
    float shadowAtten = saturate(mainLight.shadowAttenuation + (1 - _ReceiveShadowStrength));
    float3 attenuatedLightColor = mainLight.color * saturate(mainLight.distanceAttenuation * shadowAtten);
    float powerdNdotL = pow(saturate(NdotL), _ShadingPow);
    powerdNdotL = saturate(saturate(powerdNdotL) + _GIStrength);
    diffuseColor = clamp(powerdNdotL, 0.001, 1) * attenuatedLightColor * MMN_GlobalTex_CloudShadows(inputData.positionWS).r ;


    //Additional Light =================  // 깜빡이는 이상증상을 보여서 잠시 diable 처리.그런데 임포스터는 어차피 필요 없을 것으로 생각.
    // #ifdef _ADDITIONAL_LIGHTS
    //     uint pixelLightCount = GetAdditionalLightsCount();
    //     for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    //     {
    //         Light light = GetAdditionalLight(lightIndex, inputData.normalWS, /*shadowMask*/float4(1,1,1,1));
    //         // #if defined(_SCREEN_SPACE_OCCLUSION)
    //         //     light.color *= aoFactor.directAmbientOcclusion;
    //         // #endif
    //         float3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.distanceAttenuation * light.shadowAttenuation);
    //         diffuseColor += MM_LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
    //         // specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
    //     }
    // #endif

    // #ifdef _ADDITIONAL_LIGHTS_VERTEX
    //     diffuseColor += inputData.vertexLighting;
    // #endif

    ////GI 연산을 맨 마지막에 해서 강하게 영향받게 합니다. 투과스러운 느낌이 나게 해줌
    // 나뭇잎은 아래로 향하면 어두워지게 함. 대부분 둥글고 차폐가 일어나는 재질이므로 이렇게 하면 더 보기 좋다.
    float3 modifiedGI = inputData.bakedGI * _Global_GILightMulti.rgb;
    modifiedGI *= inputData.normalWS.y * 0.4 + 0.6;
    diffuseColor.rgb += modifiedGI  ;

    return diffuseColor;
}


///////////////////////////////////////////////////////////////////////////////
//         구형 라이팅 함수를 신형으로 호환시키기 위한 함수                      //
///////////////////////////////////////////////////////////////////////////////


// Deprecated: Use the version which takes "SurfaceData" instead of passing all of these arguments...

float4 UniversalFragmentLightCustomLOD(InputData inputData, float3 diffuse, float4 specularGloss, float smoothness, float3 emission, float alpha, float3 normalTS)
{
    SurfaceData surfaceData;

    surfaceData.albedo = diffuse;
    surfaceData.alpha = alpha;
    surfaceData.emission = emission;
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.smoothness = smoothness;
    surfaceData.specular = specularGloss.rgb;
    surfaceData.clearCoatMask = 0;
    surfaceData.clearCoatSmoothness = 1;
    surfaceData.normalTS = normalTS;

    return UniversalFragmentLightCustomLOD(inputData, surfaceData);
}




float4 UniversalFragmentLightCustom(InputData inputData, float3 diffuse, float4 specularGloss, float smoothness, float3 emission, float alpha, float3 normalTS, float shadowDimming, float halfLambertWeight, float _BackfaceReceiveShadowOff, FRONT_FACE_TYPE isFacing, float BackFaceNormalturn)
{
    SurfaceData surfaceData;

    surfaceData.albedo = diffuse;
    surfaceData.alpha = alpha;
    surfaceData.emission = emission;
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.smoothness = smoothness;
    surfaceData.specular = specularGloss.rgb;
    surfaceData.clearCoatMask = 0;
    surfaceData.clearCoatSmoothness = 1;
    surfaceData.normalTS = normalTS;

    return UniversalFragmentLightCustom(inputData, surfaceData, shadowDimming, halfLambertWeight, _BackfaceReceiveShadowOff, isFacing, BackFaceNormalturn);
}

// Deprecated: Use the version which takes "SurfaceData" instead of passing all of these arguments...
float4 UniversalFragmentLightCustomBaked(InputData inputData, float3 diffuse, float4 specularGloss, float smoothness, float3 emission, float alpha, float3 normalTS, float shadowDimming, float halfLambertWeight, float _BackfaceReceiveShadowOff, FRONT_FACE_TYPE isFacing, float BackFaceNormalturn)
{
    SurfaceData surfaceData;

    surfaceData.albedo = diffuse;
    surfaceData.alpha = alpha;
    surfaceData.emission = emission;
    surfaceData.metallic = 0;
    surfaceData.occlusion = 1;
    surfaceData.smoothness = smoothness;
    surfaceData.specular = specularGloss.rgb;
    surfaceData.clearCoatMask = 0;
    surfaceData.clearCoatSmoothness = 1;
    surfaceData.normalTS = normalTS;


    return UniversalFragmentLightCustomBaked(inputData, surfaceData, shadowDimming, halfLambertWeight, _BackfaceReceiveShadowOff, isFacing, BackFaceNormalturn);
}


// fake Specular를 위한 처리
// float4 UniversalFragmentLightCustom(InputData inputData, float3 diffuse, float4 specularGloss, float smoothness, float3 emission, float alpha, float3 normalTS , float shadowDimming, float4 screenPos)
// {
//     SurfaceData surfaceData;

//     surfaceData.albedo = diffuse;
//     surfaceData.alpha = alpha;
//     surfaceData.emission = emission;
//     surfaceData.metallic = 0;
//     surfaceData.occlusion = 1;
//     surfaceData.smoothness = smoothness;
//     surfaceData.specular = specularGloss.rgb;
//     surfaceData.clearCoatMask = 0;
//     surfaceData.clearCoatSmoothness = 1;
//     surfaceData.normalTS = normalTS;

//     return UniversalFragmentLightCustom(inputData, surfaceData, shadowDimming, screenPos);
// }


// 나뭇잎용
float3 UniversalFragmentTreeLeaves2(InputData inputData, float3 diffuse, float3 posObjectNormal, float _NormalLerp, float _ShadingPow, float _ReceiveShadowStrength, float _ReceiveGIStrength)
{
    SurfaceData surfaceData;

    surfaceData.albedo = diffuse;
    surfaceData.specular = 0;
    surfaceData.metallic = 0;
    surfaceData.smoothness = 0;
    surfaceData.normalTS = float3(0, 0, 1);
    surfaceData.emission = float3(0, 0, 0);
    surfaceData.occlusion = 1;
    surfaceData.alpha = 1;
    surfaceData.clearCoatMask = 0;
    surfaceData.clearCoatSmoothness = 1;

    return UniversalFragmentTreeLeaves2(inputData, surfaceData, posObjectNormal, _NormalLerp, _ShadingPow, _ReceiveShadowStrength, _ReceiveGIStrength);
}


///////////////////////////////////////////////////////////////////////////////
//                     나뭇잎용 추가 라이팅 함수들 모음                         //
///////////////////////////////////////////////////////////////////////////////



//Inner AO 계산
float UniversalFragmentTreeLeavesInnerAO(float4 positionOS, float _CenterPointHeight, float _AOarea, float _AOintensity, float _AOVertical)
{
    positionOS.g = positionOS.g * _AOVertical ;
    float innerAO = distance(positionOS.rgb, float3(0, _CenterPointHeight * _AOVertical, 0));
    innerAO = saturate(pow(max(0, innerAO / _AOarea), _AOintensity));
    return innerAO;
}

//Inner AO 계산 _AOVertical 계산 없는 오버라이드. 림라이트용으로 쓴다.
float UniversalFragmentTreeLeavesInnerAO(float4 positionOS, float _CenterPointHeight, float _AOarea, float _AOintensity)
{
    positionOS.g = positionOS.g ;
    float innerAO = distance(positionOS.rgb, float3(0, _CenterPointHeight, 0));
    innerAO = saturate(pow(max(0, innerAO / _AOarea), _AOintensity));
    return innerAO;
}

//Top Light for Tree . 나무가 음영지역에 있을때 윗부분 (스카이 방향) 에 특성한 칼라를 넣어준다.
float3 UniversalFragmentTreeLeavesTopLight(float3 posObjectNormal, float _TopLightThickness, float4 _TopLightColor)
{

    // float3 posObjectNormal = positionOS.rgb - float3(0, _CenterPointHeight,0);
    float3 normalizePosObjectNormal = posObjectNormal / _TopLightThickness ;
    float toplight = saturate(normalizePosObjectNormal.y);
    // toplight = pow(toplight,2);

    return float3(toplight * _TopLightColor.rgb * _Global_GILightMulti.rgb);
}


#endif
