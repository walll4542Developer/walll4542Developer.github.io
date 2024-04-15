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

float OnePassOutlineWidth(InputData inputData, float3 lightDir, float shadingType)
{
    float outlineWidth = 0.0;

    float rimArea;
    float rimBand;

    float3 cameraDirWS = -GetViewForwardDir();
    float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);

    #if (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE))
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 13.3);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    #elif (defined(_SHADINGTYPE_STANDARD) || defined(_SHADINGTYPE_STOCKINGS))
    {
        if (shadingType == _SHADINGTYPE_MONSTER_VALUE)
        {
            rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
            rimBand = saturate((1 - nDotV) * 20.0 - 14.0);

            outlineWidth = rimArea * rimBand * 4.0;
        }
        else if (shadingType == _SHADINGTYPE_DEEP_VALUE)
        {
            rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
            rimBand = saturate((1 - nDotV) * 20.0 - 14.0);

            outlineWidth = rimArea * rimBand * 4.0;
        }
        else // _SHADINGTYPE_STANDARD || _SHADINGTYPE_STOCKINGS
        {
            rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * float3(1.0, 0.3, 1.0), cameraDirWS))));
            rimBand = saturate((1 - nDotV) * 20.0 - 14.0);

            outlineWidth = rimArea * rimBand * 4.0;
        }
    }
    #endif

    outlineWidth = saturate(outlineWidth);

    return outlineWidth;
}

float3 OnePassOutlineColor(float outlineColorMode, float shadingType)
{
    float3 outlineColor = float3(0.6, 0.53, 0.69) * 0.6;

    if (outlineColorMode == OUTLINE_COLOR_MULTIPLY)
    {
        #if (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE))
        {
            outlineColor = float3(0.75, 0.53, 0.69) * 0.45;
        }
        #elif defined(_SHADINGTYPE_STOCKINGS)
        {
            // 스타킹은 아웃라인을 조금 밝게 표현함.
            outlineColor = float3(0.56, 0.53, 0.69) * 1.2;
        }
        #elif defined(_SHADINGTYPE_STANDARD)
        {
            if (shadingType == _SHADINGTYPE_MONSTER_VALUE)
            {
                outlineColor = float3(0.6, 0.53, 0.69) * 0.4;
            }
            else if (shadingType == _SHADINGTYPE_DEEP_VALUE)
            {
                outlineColor = float3(0.6, 0.53, 0.69) * 0.4;
            }
            else // _SHADINGTYPE_STANDARD
            {
                outlineColor = float3(0.6, 0.53, 0.69) * 0.6;
            }
        }
        #endif

        outlineColor *= _OutlineColor.rgb;
    }
    else if (outlineColorMode == OUTLINE_COLOR_OVERRIDE)
    {
        outlineColor = _OutlineColor.rgb;
    }

    return outlineColor;
}

float3 OnePassOutline(InputData inputData, float3 lightDir, float outlineColorMode, float shadingType)
{
    float outlineWidth = OnePassOutlineWidth(inputData, lightDir, shadingType);
    float3 outlineColor = OnePassOutlineColor(outlineColorMode, shadingType);

    return lerp(float3(1.0, 1.0, 1.0), outlineColor, outlineWidth);
}

#endif // _OUTLINE_FEATURE

#endif // MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED
