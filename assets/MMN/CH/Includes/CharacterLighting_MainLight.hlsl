#ifndef MMN_CHARACTER_LIGHTING_MAINLIGHT
#define MMN_CHARACTER_LIGHTING_MAINLIGHT

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


struct MainLightShadingInput
{
    half3 normalWS;
    half3 lightDirection;
    half3 cameraDirection;
    half cameraDistance;
    half cDotL;
    half nDotV;
    half verticalGradientRemapped;
    half lightingMask;
    half3 dyedBaseColor;
    LightingData lightingData;
    half flatShadingOff;
};

struct MainLightShadingResult
{
    half finalShading;
    half3 volumeShadingLight;
    half3 volumeShadingDark;
};

//-----------------------------------------------------------------------------
// Main light shading
//-----------------------------------------------------------------------------
void GetMainLightShading(in MainLightShadingInput input,
    out MainLightShadingResult result)
{
    // Desc.
    // volumeShadingLight
    //  - 명암에서 어두운 쪽을 제외한 부분의 톤과 컬러를 담당.
    //  - 단, volumeShadingDark가 반영된 앰비언트 라이트와 더한 상태임을 주목할 것.
    // volumeShadingDark
    //  - 셰딩의 톤과 컬러에서 기반을 담당.
    //  - Dark에서 설정한 컬러와 톤은 GI 컬러와 곱해져서 앰비언트 라이트의 역할을 한다.
    half flatShading = 1.0;
    half3 volumeShadingLight = 1.0;
    half3 volumeShadingDark = 0.0;

    half3 flattenNormal = normalize(input.normalWS * half3(1.0, 0.15, 1.0));
    half3 skinNormal = normalize(input.cameraDirection * 1.5 + input.normalWS * half3(1.0, 0.15, 1.0));

    half nDotL = dot(input.normalWS, input.lightDirection);
    half nDotV = dot(flattenNormal, input.cameraDirection);

    // 피부에 쓰는 nDotL은 볼 아래에 그림자가 생기는 현상을 막기 위해서 y방향을 줄여서 쓴다.
    half snDotL = dot(skinNormal, input.lightDirection);
    half snDotV = dot(skinNormal, input.cameraDirection);

    #if defined(_SHADINGTYPE_MONSTER)
    {
        flatShading = saturate(nDotL * 30.0 + 6.0);

        volumeShadingLight = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped);
        volumeShadingDark = lerp(nDotV * 0.5, nDotV * 0.5 + 1.2, input.verticalGradientRemapped);
    }
    #elif (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE) || defined(_SHADINGTYPE_STOCKINGS))
    {
        // @jp.jung 카메라가 근접하게 되면 값을 돌려서 얼굴에는 그림자가 지지 않도록 한다. 드라마에서 근접 반사판 같은 느낌
        half cameraDistance = saturate(input.cameraDistance / 3 - 0.8); // 3.8 미터(?) 부터 그림자가 서서히 돌고 0.8 미터가 되면 완전히 그림자 지지 않음
        snDotL = input.flatShadingOff >= 0.5 ? snDotL : lerp(snDotV, snDotL, saturate(cameraDistance + (1.0 - input.verticalGradientRemapped))); // 하체는 기존과 동일하게 연산할 수 있도록 verticalGradientRemapped을 사용한다.

        flatShading = max(saturate(snDotL * 30.0 + 15.0 * min(0.6, input.cDotL * 2.2)), 0.4 * saturate(1.0 - input.cDotL) * input.verticalGradientRemapped);

        half mainLightLuminance = min(1.0, Luminance(input.lightingData.mainLightColor.rgb));
        half giLuminance = min(1.0, Luminance(input.lightingData.giColor.rgb));

        // 피부는 어두운 쪽에 주광의 조명이 밝으면(낮) 붉은 톤, 어두우면(밤) 푸른 톤을 추가한다.
        half3 fakeSS = normalize(lerp(half3(0.9, 0.9, 1.2), half3(1.1, 0.6, 0.4), mainLightLuminance));
        fakeSS *= (1.0 - giLuminance + 1.0); // GI가 밝으면(낮, 1에 근접) 배율을 낮춰서 fakeSS를 강하게(어둡게, 진하게) 만들고, 반대로 GI가 어두우면(밤, 0에 근접) 약하게(밝게, 연하게) 만듬.

        // 일부 실내에서 주광의 밝기보다 GI의 밝기가 큰 경우 부자연스러운 톤이 나오는 것을 보정하는 수식이다. 일반적인 경우에도 적당히 적용될만한 수식이다.
        fakeSS += ((giLuminance * 0.6) - (mainLightLuminance * 0.5));

        half3 adjustBright = (1.0 - max(fakeSS.r, max(fakeSS.g, fakeSS.b)));
        fakeSS += adjustBright;

        nDotV = lerp(1, nDotV, saturate(cameraDistance));// @jp.jung 카메라가 근접하게 되면 값을 돌려서 얼굴에는 그림자가 지지 않도록 한다
        volumeShadingLight = lerp(snDotL * 0.3 + 0.5, 1.0, input.verticalGradientRemapped);
        volumeShadingDark = lerp(nDotV * 0.3 + 0.3 + fakeSS, nDotV * 0.3 + 0.5 + fakeSS, input.verticalGradientRemapped);
    }
    #elif defined(_SHADINGTYPE_DEEP)
    {
        flatShading = saturate(nDotL * 30.0 + 6.0);

        volumeShadingLight = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped) * 0.5;
        volumeShadingDark = lerp(nDotV * 0.5, nDotV * 0.5 + 1.2, input.verticalGradientRemapped) * 0.5;
    }
    #else // _SHADINGTYPE_STANDARD
    {
        flatShading = saturate(nDotL * 30.0 + 6.0);

        volumeShadingLight = lerp(nDotL * 0.5 + 0.3, 1.0, input.verticalGradientRemapped);
        volumeShadingDark = lerp(nDotV * 0.5 + input.dyedBaseColor * 0.45, nDotV * 0.5 + 1.2, input.verticalGradientRemapped);
    }
    #endif

    half finalShading = min(input.lightingMask, flatShading);

    result.finalShading = saturate(finalShading);
    result.volumeShadingLight = volumeShadingLight;
    result.volumeShadingDark = volumeShadingDark;
}

#endif // MMN_CHARACTER_LIGHTING_MAINLIGHT
