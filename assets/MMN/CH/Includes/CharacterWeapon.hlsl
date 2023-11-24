#ifndef MMN_CHARACTER_WEAPON_INCLUDED
#define MMN_CHARACTER_WEAPON_INCLUDED

#ifdef _WEAPON_GRADE_FEATURE
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float OutlineByDepth(float4 positionNDC, float2 outlineNDC)
{
    float2 originDepthUV = positionNDC.xy / positionNDC.w;
    float originDepth = Linear01DepthFromNear(SampleSceneDepth(originDepthUV), _ZBufferParams);
    float outlineDepth = Linear01DepthFromNear(SampleSceneDepth(outlineNDC.xy), _ZBufferParams);
    float depthDelta = max(0.0, originDepth - outlineDepth);

    // 뎁스 차이가 미묘하기 때문에 차이를 증폭시켜줘야 한다.
    // 증폭하는 비율은 (far - near) 거리의 제곱에 비례하고, near 값의 역수에 비례한다.
    // _ProjectionParams = { 1 or -1 (-1 if projection is flipped), near plane, far plane, 1 / far plane }
    float frustumSize = (_ProjectionParams.z - _ProjectionParams.y);
    float amplificationRatio = frustumSize * frustumSize * (10.0 / min(1.0, _ProjectionParams.y));
    float amplifiedDepth = depthDelta * amplificationRatio;

    float outlineWidth = 1.0 - step(0.4, amplifiedDepth);
    return outlineWidth;
}

float OutlineByRim(float4 positionNDC, InputData inputData, Light mainLight)
{
    float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
    return step(0.75, nDotV * 0.5 + 0.58);


    // float nDotV = dot(inputData.normalWS, inputData.viewDirectionWS);
    // float nDotL = dot(inputData.normalWS, mainLight.direction);

    // float outline = (1.0 - nDotV) > 0.75 ? 1.0 : 0.0;
    // float outlineWidth = 1.0 - ((max(-nDotL + 0.4, 0.0)) * outline);

    // return outlineWidth;
}

float4 OnePassWeaponOutlineAnimation(float4 baseColor, float4 weaponGradeColor, float outlineWidth)
{
    float3 weapon = lerp(weaponGradeColor.rgb, baseColor.rgb, outlineWidth);

    float speed = 2.0;
    float time = sin(_Time.y * speed) * 0.5 + 0.5;

    float animationByGrade = 1.0;
    if (weaponGradeColor.a >= 3.0 && weaponGradeColor.a < 4.0) // only Epic item
    {
        animationByGrade = 0.7;
    }
    else if (weaponGradeColor.a >= 4.0 && weaponGradeColor.a < 5.0) // only Legendary item
    {
        animationByGrade = 0.85;
    }
    else if (weaponGradeColor.a >= 5.0) // GEqual Mythic item
    {
        animationByGrade = 1.0;
    }
    else
    {
        animationByGrade = 0.0;
    }

    float4 animatedColor = float4(lerp(baseColor.rgb, weapon.rgb, time * animationByGrade), baseColor.a);
    return animatedColor;
}

float4 OnePassWeaponOutline(float4 baseColor, float4 weaponGradeColor, float4 positionNDC, float2 outlineNDC, InputData inputData, Light mainLight)
{
    float outlineByDepth = OutlineByDepth(positionNDC, outlineNDC);
    float outlineByRim = OutlineByRim(positionNDC, inputData, mainLight);
    float outlineWidth = min(outlineByRim, outlineByDepth);

    float4 finalColor = OnePassWeaponOutlineAnimation(baseColor, weaponGradeColor, outlineWidth);
    return finalColor;
}

#endif // _WEAPON_GRADE_FEATURE

#endif // MMN_CHARACTER_WEAPON_INCLUDED
