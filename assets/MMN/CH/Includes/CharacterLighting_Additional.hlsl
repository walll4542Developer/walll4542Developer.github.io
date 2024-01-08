#ifndef MMN_CHARACTER_LIGHTING_ADDITIONAL
#define MMN_CHARACTER_LIGHTING_ADDITIONAL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


///////////////////////////////////////////////////////////////////////////////
//                            Additional Lights                              //
///////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Vertex light
//-----------------------------------------------------------------------------
half3 AdditionalLightsVertex(float3 positionWS, half3 normalWS)
{
    half3 vertexLightColor = half3(0.0, 0.0, 0.0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 cameraDirWS = -GetViewForwardDir();
        half3 cameraDirWSFlatten = normalize(half3(cameraDirWS.x, cameraDirWS.y * 0.1, cameraDirWS.z));

        uint meshRenderingLayers = GetMeshRenderingLightLayer();
        uint addLightCount = GetAdditionalLightsCount();

        LIGHT_LOOP_BEGIN(addLightCount)
        Light light = GetAdditionalLight(lightIndex, positionWS);

        #ifdef _LIGHT_LAYERS
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            half3 attenuatedLightColor = light.color * light.distanceAttenuation;

            half3 lightDirWSFlatten = normalize(half3(light.direction.x, light.direction.y * 0.65, light.direction.z));

            half cDotL = dot(cameraDirWSFlatten, lightDirWSFlatten);
            half nDotL = dot(lightDirWSFlatten, normalWS);
            half lightVisibility = -cDotL;
            half lightingMask = saturate((1.2 - lightVisibility) * 0.2);

            half volumeShadingDark = saturate(nDotL * 20.0);

            half3 finalColor = volumeShadingDark * lightingMask * attenuatedLightColor * 0.2;
            vertexLightColor += finalColor;
        }
        LIGHT_LOOP_END
    #endif

    return vertexLightColor;
}

//-----------------------------------------------------------------------------
// Pixel light
//-----------------------------------------------------------------------------
void AdditionalLightShading(inout half3 resultColor, Light light, InputData inputData,
    half3 cameraDirWSFlatten, half rimBand)
{
    half shadowDimming = 1.0; // 셀프 셰도우를 없애기 위함.
    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * saturate(light.shadowAttenuation + shadowDimming));
    // half3 cameraDirWS = -GetViewForwardDir();

    half3 lightDirWSFlatten = normalize(half3(light.direction.x, light.direction.y * 0.65, light.direction.z));
    half cDotL = dot(cameraDirWSFlatten, lightDirWSFlatten);
    half nDotL = dot(lightDirWSFlatten, inputData.normalWS);
    half lightVisibility = -cDotL;
    half lightingMask = saturate((1.2 - lightVisibility) * 0.2);

    // 빛 받는 부분은 플랫한 느낌을 유지하기 위해서 이렇게 처리했다
    // half volumeShadingDark = saturate(nDotL + half3(0.9, 0.5, 0.0)) * 0.25;
    // half volumeShadingDark = saturate(nDotL + 0.9) * 0.25;
    //@jp.jung nDotL 이 나오의 코 부분에 음영을 만들어서 아예 플렛하게 처리하도록 만들었다.
    half volumeShadingDark = saturate(1 + 0.9) * 0.25;

    // 다이나믹 라이트는 아래에서 위로 비추는 것들이 좀 있어서 이렇게 처리했음
    // 턱 아래에 림이 생기면 매우 흉하기 때문
    half rimArea = max(0.0, nDotL + inputData.normalWS.y);

    half silhouette = rimBand * rimArea;
    half3 silhouetteColor = (attenuatedLightColor) * 0.3;

    // 일부러 좀 약하게 표현함
    half3 finalColor = volumeShadingDark * lightingMask * attenuatedLightColor;
    finalColor += silhouette * silhouetteColor;

    resultColor += finalColor;
    // resultColor = silhouette;
    // resultColor = saturate(dot(lightDirWSFlatten,inputData.normalWS)*2.0+0.5) * attenuatedLightColor * 0.5;

}

void AdditionalLightShadingSimple(inout half3 resultColor, Light light, InputData inputData,
    half3 cameraDirWSFlatten)
{
    half shadowDimming = 1.0; // 셀프 셰도우를 없애기 위함.
    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * saturate(light.shadowAttenuation + shadowDimming));

    half3 lightDirWSFlatten = normalize(half3(light.direction.x, light.direction.y * 0.65, light.direction.z));
    half cDotL = dot(cameraDirWSFlatten, lightDirWSFlatten);
    half nDotL = dot(lightDirWSFlatten, inputData.normalWS);
    half lightVisibility = -cDotL;
    half lightingMask = saturate((1.2 - lightVisibility) * 0.2);

    // 빛 받는 부분은 플랫한 느낌을 유지하기 위해서 이렇게 처리했다
    // half volumeShadingDark = saturate(nDotL + half3(0.9, 0.5, 0.0)) * 0.25;
    half volumeShadingDark = saturate(nDotL + 0.9) * 0.25;

    half3 finalColor = volumeShadingDark * lightingMask * attenuatedLightColor;
    resultColor += finalColor;
}

half3 AdditionalLightsFragment(InputData inputData, half3 cameraDirWS, bool standardMode)
{
    half3 additionalLightShading = 0; // 최종 결과물에 영향을 주지 않는 값을 기본 값으로 정해야 한다.

    // NOTE : 퀄리티 옵션에 따라 분기를 해야하므로 아래 디파인 블럭 안에 작성 되어야 한다.
    #if defined(_ADDITIONAL_LIGHTS)
    {
        half nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
        half rimBand = saturate((1.0 - nDotV) * 10.0 - 6.0);

        half3 cameraDirWSFlatten = normalize(half3(cameraDirWS.x, cameraDirWS.y * 0.1, cameraDirWS.z));

        uint meshRenderingLayers = GetMeshRenderingLightLayer();
        half4 shadowMask = inputData.shadowMask;
        uint pixelLightCount = GetAdditionalLightsCount();

        // #if USE_CLUSTERED_LIGHTING
        //     for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
        //     {
        //         Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
        //         if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        //         {
        //             if (standardMode)
        //             {
        //                 AdditionalLightShading(additionalLightShading, light, inputData, cameraDirWSFlatten, rimBand);
        //             }
        //             else
        //             {
        //                 AdditionalLightShadingSimple(additionalLightShading, light, inputData, cameraDirWSFlatten);
        //             }
        //         }
        //     }
        // #endif

        LIGHT_LOOP_BEGIN(pixelLightCount)
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);

        #ifdef _LIGHT_LAYERS
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
        #endif
        {
            if (standardMode)
            {
                AdditionalLightShading(additionalLightShading, light, inputData, cameraDirWSFlatten, rimBand);
            }
            else
            {
                AdditionalLightShadingSimple(additionalLightShading, light, inputData, cameraDirWSFlatten);
            }
        }
        LIGHT_LOOP_END
    }
    #endif

    return additionalLightShading;
}

#endif // MMN_CHARACTER_LIGHTING_ADDITIONAL
