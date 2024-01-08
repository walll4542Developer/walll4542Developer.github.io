#ifndef MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED
#define MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

#ifdef _OUTLINE_FEATURE
// half OutlineByDepth(half4 positionNDC, half2 outlineNDC)
// {
//     half2 originDepthUV = positionNDC.xy / positionNDC.w;
//     half originDepth = Linear01DepthFromNear(SampleSceneDepth(originDepthUV), _ZBufferParams);
//     half outlineDepth = Linear01DepthFromNear(SampleSceneDepth(outlineNDC.xy), _ZBufferParams);
//     half depthDelta = max(0.0, originDepth - outlineDepth);

//     // 뎁스 차이가 미묘하기 때문에 차이를 증폭시켜줘야 한다.
//     // 증폭하는 비율은 (far - near) 거리의 제곱에 비례하고, near 값의 역수에 비례한다.
//     // _ProjectionParams = { 1 or -1 (-1 if projection is flipped), near plane, far plane, 1 / far plane }
//     half frustumSize = (_ProjectionParams.z - _ProjectionParams.y);
//     half amplificationRatio = frustumSize * frustumSize * (10.0 / min(1.0, _ProjectionParams.y));
//     half amplifiedDepth = depthDelta * amplificationRatio;

//     half outlineWidth = 1.0 - step(0.4, amplifiedDepth);
//     return 1.0;//outlineWidth;
// }

// half OutlineByRim(half4 positionNDC, InputData inputData, Light mainLight)
// {
//     half nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
//     return step(0.75, nDotV * 0.5 + 0.58);


//     // half nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
//     // half nDotL = dot(inputData.normalWS, mainLight.direction);

//     // half outline = (1.0 - nDotV) > 0.75 ? 1.0 : 0.0;
//     // half outlineWidth = 1.0 - ((max(-nDotL + 0.4, 0.0)) * outline);

//     // return outlineWidth;
// }

// half OnePassOutline(half4 positionNDC, half2 outlineNDC, InputData inputData, Light mainLight)
// {
//     half outlineByDepth = OutlineByDepth(positionNDC, outlineNDC);
//     half outlineByRim = OutlineByRim(positionNDC, inputData, mainLight);
//     half outlineWidth = max(outlineByRim, outlineByDepth);

//     return saturate(outlineWidth);
// }

half OnePassOutlineWidth(InputData inputData, half3 lightDir)
{
    half outlineWidth = 0.0;

    half rimArea;
    half rimBand;

    half3 cameraDirWS = -GetViewForwardDir();
    half nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);

    #if defined(_SHADINGTYPE_MONSTER)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * half3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    #elif (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE))
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * half3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.0);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    #elif defined(_SHADINGTYPE_DEEP)
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * half3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    #else // _SHADINGTYPE_STANDARD || _SHADINGTYPE_STOCKINGS
    {
        rimArea = saturate(dot(inputData.normalWS, -normalize(ProjectOnPlane(lightDir * half3(1.0, 0.3, 1.0), cameraDirWS))));
        rimBand = saturate((1 - nDotV) * 20.0 - 14.5);

        outlineWidth = rimArea * rimBand * 4.0;
    }
    #endif

    outlineWidth = saturate(outlineWidth);

    return outlineWidth;
}

half3 OnePassOutlineColor(half outlineColorMode)
{
    half3 outlineColor;

    if (outlineColorMode == OUTLINE_COLOR_MULTIPLY)
    {
        #if defined(_SHADINGTYPE_MONSTER)
        {
            outlineColor = half3(0.6, 0.53, 0.69) * 0.5;
        }
        #elif (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE))
        {
            outlineColor = half3(0.75, 0.53, 0.69) * 0.8;
        }
        #elif defined(_SHADINGTYPE_DEEP)
        {
            outlineColor = half3(0.6, 0.53, 0.69) * 0.5;
        }
        #elif defined(_SHADINGTYPE_STOCKINGS)
        {
            // 스타킹은 아웃라인을 조금 밝게 표현함.
            outlineColor = half3(0.56, 0.53, 0.69) * 1.4;
        }
        #else // _SHADINGTYPE_STANDARD
        {
            outlineColor = half3(0.6, 0.53, 0.69) * 0.8;
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

half3 OnePassOutline(InputData inputData, half3 lightDir, half outlineColorMode)
{
    half outlineWidth = OnePassOutlineWidth(inputData, lightDir);
    half3 outlineColor = OnePassOutlineColor(outlineColorMode);

    return lerp(half3(1.0, 1.0, 1.0), outlineColor, outlineWidth);
}

#endif // _OUTLINE_FEATURE

#endif // MMN_CHARACTER_ONE_PASS_OUTLINE_INCLUDED
