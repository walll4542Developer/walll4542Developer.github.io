#ifndef MMN_CHARACTER_LIGHTING_MAINLIGHT
#define MMN_CHARACTER_LIGHTING_MAINLIGHT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


struct MainLightShadingInput
{
    float3 normalWS;
    float3 lightDirection;
    float3 cameraDirection;
    float verticalGradientRemapped;
    LightingData lightingData;
    float flatShadingOff;
    float shadingType;
};

struct MainLightShadingResult
{
    float finalShading;
    float3 mainLightResult;
    float3 ambientLightResult;
};

//-----------------------------------------------------------------------------
// Main light shading
//-----------------------------------------------------------------------------
float3 CalculateFakeSSS(float3 mainLightColor, float3 giColor)
{
    float mainLightLuminance = min(1.0, Luminance(mainLightColor.rgb));
    float giLuminance = min(1.0, Luminance(giColor.rgb));

    // 피부는 어두운 쪽에 주광의 조명이 밝으면(낮) 붉은 톤, 어두우면(밤) 푸른 톤을 추가한다.
    float3 fakeSSS = normalize(lerp(float3(0.9, 0.9, 1.22), float3(1.06, 0.7, 0.48), mainLightLuminance));
    fakeSSS *= (1.0 - giLuminance + 1.0); // GI가 밝으면(낮, 1에 근접) 배율을 낮춰서 fakeSSS를 강하게(어둡게, 진하게) 만들고, 반대로 GI가 어두우면(밤, 0에 근접) 약하게(밝게, 연하게) 만듬.

    // 일부 실내에서 주광의 밝기보다 GI의 밝기가 큰 경우 부자연스러운 톤이 나오는 것을 보정하는 수식이다. 일반적인 경우에도 적당히 적용될만한 수식이다.
    fakeSSS += ((giLuminance * 0.6) - (mainLightLuminance * 0.5));

    float3 adjustBright = (1.0 - max(fakeSSS.r, max(fakeSSS.g, fakeSSS.b)));
    fakeSSS += adjustBright;

    return fakeSSS;
}

void GetMainLightShading(in MainLightShadingInput input,
    out MainLightShadingResult result)
{
    // Desc.
    // finalShading
    //  - 캐릭터의 명암의 모양을 담당.
    // mainLightResult
    //  - 명암에서 어두운 쪽을 제외한 부분의 톤과 컬러를 담당.
    // ambientLightResult
    //  - 셰딩의 톤과 컬러에서 기반을 담당.
    //  - Dark에서 설정한 컬러와 톤은 GI 컬러와 곱해져서 앰비언트 라이트의 역할을 한다.
    float finalShading = 1.0;
    float3 mainLightResult = 1.0;
    float3 ambientLightResult = 0.0;

    #if (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE) || defined(_SHADINGTYPE_STOCKINGS))
    {
        // 피부에 쓰는 nDotL은 볼 아래에 그림자가 생기는 현상을 막기 위해서 노멀의 y방향을 줄여서 쓴다.
        float3 skinNormal = normalize((input.cameraDirection * 0.8 + input.normalWS) * float3(1.0, 0.15, 1.0));
        float snDotL = dot(skinNormal, input.lightDirection);
        float snDotC = dot(skinNormal, input.cameraDirection);
        float cDotL = dot(input.cameraDirection, input.lightDirection);
        float nDotC = dot(input.normalWS, input.cameraDirection);

        float lightSideShading = saturate(snDotL * 30.0 + 15.0 * min(0.6, cDotL * 2.2));
        float darkSideShading = 0.4 * saturate(1.0 - cDotL);
        finalShading = max(lightSideShading, darkSideShading);

        const float flatteness = 0.64; // 이 값이 커질 수록 음영이 사라진다.
        finalShading = lerp(finalShading, finalShading + flatteness, input.verticalGradientRemapped * (1.0 - input.flatShadingOff));

        float3 fakeSSS = CalculateFakeSSS(input.lightingData.mainLightColor.rgb, input.lightingData.giColor.rgb);

        mainLightResult = lerp(snDotL * 0.3 + 0.5, 1.0, input.verticalGradientRemapped);
        ambientLightResult = lerp(nDotC + 0.15, 1.0, input.verticalGradientRemapped) * fakeSSS;

        float lightingMask = 1.0 - saturate((nDotC) * -cDotL) * 0.75;
        finalShading = min(lightingMask, finalShading);
    }
    #elif defined(_SHADINGTYPE_STANDARD)
    {
        float nDotL = dot(input.normalWS, input.lightDirection);
        float nDotC = dot(input.normalWS, input.cameraDirection);

        // 의상 및 헤어에 쓰는 nDotL은 음영이 아래에 생기는 것을 완화하기 위해서 라이트의 y 방향을 줄여서 쓴다.
        float3 flattenLightDirection = normalize(input.lightDirection * float3(1.0, 0.26, 1.0));
        float3 standardNormal = normalize((input.cameraDirection * 0.5 + input.normalWS));
        float standardNDotL = dot(standardNormal, flattenLightDirection);

        if (input.shadingType == _SHADINGTYPE_MONSTER_VALUE)
        {
            finalShading = saturate(nDotL * 30.0 + 6.0);

            mainLightResult = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped);
            // 다리쪽으로 갈 수록 어두워지는 효과를 준다. 몬스터의 중량감을 더해주기 위함임.
            ambientLightResult = lerp(nDotC + 0.15, nDotC * 0.65 + 0.5, input.verticalGradientRemapped);
        }
        else if (input.shadingType == _SHADINGTYPE_DEEP_VALUE)
        {
            finalShading = saturate(nDotL * 30.0 + 6.0);

            // 심층 몬스터. 라이팅을 어둡게 하고 있음. 이거 나중에 김동건이 봐야 함.
            mainLightResult = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped) * 0.5;
            ambientLightResult = lerp(nDotC + 0.15, nDotC * 0.65 + 0.5, input.verticalGradientRemapped) * 0.5;
        }
        else // _SHADINGTYPE_STANDARD
        {
            finalShading = saturate(standardNDotL * 30.0 + 6.0);

            const float flatteness = 0.3; // 이 값이 커질 수록 음영이 사라진다.
            finalShading = lerp(finalShading, finalShading + flatteness, input.verticalGradientRemapped * (1.0 - input.flatShadingOff));

            mainLightResult = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped);
            ambientLightResult = lerp(nDotC + 0.15, nDotC * 0.65 + 0.5, input.verticalGradientRemapped);
            // ambientLightResult = nDotC * 0.5 + 0.5;
        }
    }
    #endif

    result.finalShading = saturate(finalShading);
    result.mainLightResult = saturate(mainLightResult * input.lightingData.mainLightColor);
    //line 81 :: ambientLightResult = lerp(input.lightingData.giColor.rgb * nDotC * 0.7, 0.35, input.verticalGradientRemapped) + fakeSSS * 0.5;
    //위에서 ambientLightResult에 input.lightingData.giColor를 계산 후 아래에서 result에 다시 input.lightingData.giColor를 곱하고 있는 상태
    result.ambientLightResult = saturate(ambientLightResult * input.lightingData.giColor);
}

#endif // MMN_CHARACTER_LIGHTING_MAINLIGHT
