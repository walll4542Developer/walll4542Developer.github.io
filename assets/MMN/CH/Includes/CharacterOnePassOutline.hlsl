#ifndef MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED
#define MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

#ifdef _OUTLINE_FEATURE
// float OutlineByDepth(float4 positionNDC, float2 outlineNDC)
// {
//     float2 originDepthUV = positionNDC.xy / positionNDC.w;
//     float originDepth = Linear01DepthFromNear(SampleSceneDepth(originDepthUV), _ZBufferParams);
//     float outlineDepth = Linear01DepthFromNear(SampleSceneDepth(outlineNDC.xy), _ZBufferParams);
//     float depthDelta = max(0.0, originDepth - outlineDepth);

//     // 뎁스 차이가 미묘하기 때문에 차이를 증폭시켜줘야 한다.
//     // 증폭하는 비율은 (far - near) 거리의 제곱에 비례하고, near 값의 역수에 비례한다.
//     // _ProjectionParams = { 1 or -1 (-1 if projection is flipped), near plane, far plane, 1 / far plane }
//     float frustumSize = (_ProjectionParams.z - _ProjectionParams.y);
//     float amplificationRatio = frustumSize * frustumSize * (10.0 / min(1.0, _ProjectionParams.y));
//     float amplifiedDepth = depthDelta * amplificationRatio;

//     float outlineWidth = 1.0 - step(0.4, amplifiedDepth);
//     return 1.0;//outlineWidth;
// }

// float OutlineByRim(float4 positionNDC, InputData inputData, Light mainLight)
// {
//     float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
//     return step(0.75, nDotV * 0.5 + 0.58);


//     // float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
//     // float nDotL = dot(inputData.normalWS, mainLight.direction);

//     // float outline = (1.0 - nDotV) > 0.75 ? 1.0 : 0.0;
//     // float outlineWidth = 1.0 - ((max(-nDotL + 0.4, 0.0)) * outline);

//     // return outlineWidth;
// }

// float OnePassOutline(float4 positionNDC, float2 outlineNDC, InputData inputData, Light mainLight)
// {
//     float outlineByDepth = OutlineByDepth(positionNDC, outlineNDC);
//     float outlineByRim = OutlineByRim(positionNDC, inputData, mainLight);
//     float outlineWidth = max(outlineByRim, outlineByDepth);

//     return saturate(outlineWidth);
// }

float OnePassOutlineWidth(float shadingType, InputData inputData, float3 lightDir)
{
    float outlineWidth = 0.0;

    float rimArea;
    float rimBand;

    float3 cameraDirWS = -GetViewForwardDir();
    float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);

    if (shadingType == MONSTER_SHADING)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    else if (shadingType == SKIN_SHADING)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.0);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    else if (shadingType == DEEP_SHADING)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    else //if (shadingType == STANDARD_SHADING)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }

    outlineWidth = saturate(outlineWidth);

    return outlineWidth;
}

float3 OnePassOutlineColor(float shadingType, float outlineColorMode)
{
    float3 outlineColor;

    if (outlineColorMode == OUTLINE_COLOR_MULTIPLY)
    {
        if (shadingType == MONSTER_SHADING)
        {
            outlineColor = float3(0.6, 0.53, 0.69) * 0.5;
        }
        else if (shadingType == SKIN_SHADING)
        {
            outlineColor = float3(0.75, 0.53, 0.69) * 0.8;
        }
        else if (shadingType == DEEP_SHADING)
        {
            outlineColor = float3(0.6, 0.53, 0.69) * 0.5;
        }
        else if (shadingType == STOCKINGS_SHADING)
        {
            // 스타킹은 아웃라인을 조금 밝게 표현함.
            outlineColor = float3(0.56, 0.53, 0.69) * 1.4;
        }
        else //if (shadingType == STANDARD_SHADING)
        {
            outlineColor = float3(0.6, 0.53, 0.69) * 0.8;
        }

        outlineColor *= _OutlineColor.rgb;
    }
    else if (outlineColorMode == OUTLINE_COLOR_OVERRIDE)
    {
        outlineColor = _OutlineColor.rgb;
    }

    return outlineColor;
}

float3 OnePassOutline(float shadingType, InputData inputData, float3 lightDir, float outlineColorMode)
{
    float outlineWidth = OnePassOutlineWidth(shadingType, inputData, lightDir);
    float3 outlineColor = OnePassOutlineColor(shadingType, outlineColorMode);

    return lerp(float3(1.0, 1.0, 1.0), outlineColor, outlineWidth);
}

#endif // _OUTLINE_FEATURE

#endif // MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED
