#ifndef MMN_CHARACTER_DEBUGGING_INCLUDED
#define MMN_CHARACTER_DEBUGGING_INCLUDED

#if defined(DEBUG_DISPLAY)

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

bool CalculateColorForDebugMaterial_Character(in InputData inputData, in SurfaceData surfaceData, inout half4 debugColor)
{
    // Debug materials...
    switch(_DebugMaterialMode)
    {
        case DEBUGMATERIALMODE_NONE:
            return false;

        case DEBUGMATERIALMODE_ALBEDO:
            debugColor = half4(surfaceData.albedo, 1);
            return true;

        case DEBUGMATERIALMODE_SPECULAR:
            debugColor = half4(surfaceData.albedo * surfaceData.emission, 1);
            return true;

        case DEBUGMATERIALMODE_ALPHA:
            debugColor = half4(surfaceData.alpha.rrr, 1);
            return true;

        case DEBUGMATERIALMODE_SMOOTHNESS:
            debugColor = half4(surfaceData.smoothness.rrr, 1);
            return true;

        case DEBUGMATERIALMODE_AMBIENT_OCCLUSION:
            debugColor = half4(surfaceData.occlusion.rrr, 1);
            return true;

        case DEBUGMATERIALMODE_EMISSION:
            debugColor = half4(surfaceData.albedo + surfaceData.specular, 1);
            return true;

        case DEBUGMATERIALMODE_NORMAL_WORLD_SPACE:
            debugColor = half4(inputData.normalWS.xyz * 0.5 + 0.5, 1);
            return true;

        case DEBUGMATERIALMODE_NORMAL_TANGENT_SPACE:
            debugColor = half4(surfaceData.normalTS.xyz * 0.5 + 0.5, 1);
            return true;

        case DEBUGMATERIALMODE_METALLIC:
            debugColor = half4(surfaceData.metallic.rrr, 1);
            return true;

        default:
            return TryGetDebugColorInvalidMode(debugColor);
    }
}

bool CalculateColorForDebug_Character(in InputData inputData, in SurfaceData surfaceData, inout half4 debugColor)
{
    if (CalculateColorForDebugSceneOverride(debugColor))
    {
        return true;
    }
    else if (CalculateColorForDebugMaterial_Character(inputData, surfaceData, debugColor))
    {
        return true;
    }
    else if (CalculateValidationColorForDebug(inputData, surfaceData, debugColor))
    {
        return true;
    }
    else
    {
        return false;
    }
}

half4 CharacterDebuggingColor(InputData inputData, Light mainLight, LightingData lightingData,
    CharacterData characterData, half3 dyedBaseColor, half alpha)
{
    half4 debugColor = half4(0, 0, 0, 0);

    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = dyedBaseColor;
    surfaceData.alpha = alpha;

    surfaceData.smoothness = abs(distance(characterData.characterPos, inputData.positionWS.xyz));

    half receivedShadow = GetReceivedShadow(mainLight.direction, inputData.positionWS.xyz,
        characterData.characterCenterPos, characterData.visualHeight,
        characterData.topShadow, characterData.bottomShadow);
    surfaceData.occlusion = receivedShadow;

    if (_DebugMaterialMode == DEBUGMATERIALMODE_LIGHTING_COMPLEXITY)
    {
        debugColor = CalculateDebugLightingComplexityColor(inputData, surfaceData);
    }
    else
    {
        if (_DebugLightingMode == DEBUGLIGHTINGMODE_SHADOW_CASCADES)
        {
            debugColor.rgb = CalculateDebugShadowCascadeColor(inputData);
            return debugColor;
        }
        else
        {
            UpdateSurfaceAndInputDataForDebug(surfaceData, inputData);
        }

        if (CalculateColorForDebug_Character(inputData, surfaceData, debugColor))
        {
            debugColor.a = alpha;
            return debugColor;
        }
    }

    // TODO: 아래는 커스텀해서 사용하자.
    // if (IsOnlyAOLightingFeatureEnabled())
    // {
    //     return half4(lightColor, 1);
    // }

    debugColor.rgb *= dyedBaseColor;

    if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_GLOBAL_ILLUMINATION))
    {
        debugColor.rgb += lightingData.giColor;
    }

    // if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_MAIN_LIGHT))
    // {
    //     debugColor.rgb *= lightColor;
    // }

    // if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_ADDITIONAL_LIGHTS))
    // {
    //     debugColor.rgb += lightingData.additionalLightsColor;
    // }

    // if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_VERTEX_LIGHTING))
    // {
    //     debugColor.rgb += lightingData.vertexLightingColor;
    // }

    // if (IsLightingFeatureEnabled(DEBUGLIGHTINGFEATUREFLAGS_EMISSION))
    // {
    //     debugColor.rgb += lightingData.emissionColor;
    // }

    return debugColor;
}

#endif // defined(DEBUG_DISPLAY)

#endif // MMN_CHARACTER_DEBUGGING_INCLUDED
