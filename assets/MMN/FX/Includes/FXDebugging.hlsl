#ifndef MMN_FX_DEBUGGING_INCLUDED
#define MMN_FX_DEBUGGING_INCLUDED

#if defined(DEBUG_DISPLAY)

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#define FXDebuggingColor(input, color, alpha) FXDebugColor(input.normalWS, input.positionWS, input.positionOS, input.positionCS, input.fogCoord, color, alpha);

// bool CanDebugOverrideOutputColor(inout InputData inputData, inout SurfaceData surfaceData, inout half4 debugColor)
// {
//     if (_DebugMaterialMode == DEBUGMATERIALMODE_LIGHTING_COMPLEXITY)
//     {
//         debugColor = CalculateDebugLightingComplexityColor(inputData, surfaceData);
//         return true;
//     }
//     else
//     {
//         if (_DebugLightingMode == DEBUGLIGHTINGMODE_SHADOW_CASCADES)
//         {
//             surfaceData.albedo = CalculateDebugShadowCascadeColor(inputData);
//         }
//         else
//         {
//             if (UpdateSurfaceAndInputDataForDebug(surfaceData, inputData))
//             {
//                 // If we've modified any data we'll need to re-sample the GI to ensure that everything works correctly...
//                 #if defined(DYNAMICLIGHTMAP_ON)
//                 inputData.bakedGI = SAMPLE_GI(inputData.staticLightmapUV, inputData.dynamicLightmapUV.xy, inputData.vertexSH, inputData.normalWS);
//                 #else
//                 inputData.bakedGI = SAMPLE_GI(inputData.staticLightmapUV, inputData.vertexSH, inputData.normalWS);
//                 #endif
//             }
//         }

//         return CalculateColorForDebug(inputData, surfaceData, debugColor);
//     }
// }

half4 FXDebugColor(in float3 normalWS, in half3 positionWS, in float4 positionOS, in float4 positionCS, in half4 fogCoord, half3 color, half alpha)
{
    half4 debugColor = half4(0, 0, 0, 0);

    // initializeSurfaceData
    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = color;
    surfaceData.alpha = alpha;
    surfaceData.specular = 0;
    surfaceData.normalTS = 0;
    surfaceData.emission = 0;
    surfaceData.metallic = 0;
    surfaceData.smoothness = 1;
    surfaceData.occlusion = 1;
    surfaceData.clearCoatMask       = 0;
    surfaceData.clearCoatSmoothness = 1;

    // InitializeInputData
    InputData inputData = (InputData)0;
    inputData.positionWS = positionWS;
    inputData.normalWS = normalWS;
    inputData.fogCoord = fogCoord.x;

    if (_DebugMaterialMode == DEBUGMATERIALMODE_LIGHTING_COMPLEXITY)
    {
        debugColor = CalculateDebugLightingComplexityColor(inputData, surfaceData);
    }
    else
    {
        if (_DebugLightingMode == DEBUGLIGHTINGMODE_SHADOW_CASCADES)
        {
            surfaceData.albedo = CalculateDebugShadowCascadeColor(inputData);
        }
        else
        {
            UpdateSurfaceAndInputDataForDebug(surfaceData, inputData);
        }

        if (CalculateColorForDebug(inputData, surfaceData, debugColor))
        {
            debugColor.a = alpha;
            return debugColor;
        }
    }
    return debugColor;
}

half4 FXDebugColor(in float3 normalWS, in half3 positionWS, in half4 fogCoord, half3 color, half alpha)
{
    half4 debugColor = half4(0, 0, 0, 0);

    // initializeSurfaceData
    SurfaceData surfaceData = (SurfaceData)0;
    surfaceData.albedo = color;
    surfaceData.alpha = alpha;
    surfaceData.specular = 0;
    surfaceData.normalTS = 0;
    surfaceData.emission = 0;
    surfaceData.metallic = 0;
    surfaceData.smoothness = 1;
    surfaceData.occlusion = 1;
    surfaceData.clearCoatMask       = 0;
    surfaceData.clearCoatSmoothness = 1;

    // InitializeInputData
    InputData inputData = (InputData)0;
    inputData.positionWS = positionWS;
    inputData.normalWS = normalWS;
    inputData.fogCoord = fogCoord.x;

    if (_DebugMaterialMode == DEBUGMATERIALMODE_LIGHTING_COMPLEXITY)
    {
        debugColor = CalculateDebugLightingComplexityColor(inputData, surfaceData);
    }
    else
    {
        if (_DebugLightingMode == DEBUGLIGHTINGMODE_SHADOW_CASCADES)
        {
            surfaceData.albedo = CalculateDebugShadowCascadeColor(inputData);
        }
        else
        {
            UpdateSurfaceAndInputDataForDebug(surfaceData, inputData);
        }

        if (CalculateColorForDebug(inputData, surfaceData, debugColor))
        {
            debugColor.a = alpha;
            return debugColor;
        }
    }
    return debugColor;
}

#endif // defined(DEBUG_DISPLAY)
#endif // MMN_FX_DEBUGGING_INCLUDED
