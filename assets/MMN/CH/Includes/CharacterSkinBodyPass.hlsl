#ifndef MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED
#define MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterAtlas.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterApplyFresnel.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterDebugging.hlsl"


half4 BasePassFragment(Varyings input) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Skin diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

    half3 baseColor = baseMap.rgb;
    half alpha = 1.0;
    #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY)
        alpha = baseMap.a * _AlphaOverride;
    #endif

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

    half3 dyedBaseColor = baseColor;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            ApplyDyeColor(dyedBaseColor, _DyeColor1, _DyeColor2, _DyeColor3);
        }
    #endif

    #ifdef _TINTCOLOR_FEATURE
        dyedBaseColor *= _TintColor.rgb;
    #endif

    //-----------------------------------------------------------------------------
    // Initialize data
    //-----------------------------------------------------------------------------
    // Input data
    InputData inputData;
    InitializeCharacterInputData(input, inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv.xy, _BaseMap);

    // Light
    Light mainLight;
    LightingData lightingData;
    InitializeLightData(inputData, mainLight, lightingData);

    // from script
    CharacterData characterData = InitializeCharacterData();

    //-----------------------------------------------------------------------------
    // 문신 / 횽터
    //-----------------------------------------------------------------------------
    float2 tattooUV = TransformUV(_TattooMapScalePosition, _TattooMapRotation, input.uv.xy);
    half4 tattooMap = SAMPLE_TEXTURE2D(_TattooMap, sampler_TattooMap, tattooUV);
    half3 tattooColor = tattooMap.rgb;

    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            if (IS_TRUE(_IsScarMode))
            {
                tattooColor = ApplySkinColorForScar(tattooColor, _DyeColor1.rgb);
            }
            else
            {
                tattooColor = ApplySkinColorForTattoo(tattooColor, _DyeColor1.rgb);
            }
        }
    #endif
    dyedBaseColor = lerp(dyedBaseColor, tattooColor, tattooMap.a);

    //-----------------------------------------------------------------------------
    // Process Color
    //-----------------------------------------------------------------------------
    half4 resultColor;
    resultColor.rgb = ProcessCharacterColor(inputData,
        mainLight, lightingData, characterData,
        dyedBaseColor, _SilhouetteOff, _SilhouetteTintColor, _FlatShadingOff);

    #ifdef _OUTLINE_FEATURE
        half3 outlineColor = OnePassOutline(inputData, mainLight.direction, _OutlineColorMode);

        #ifdef DEBUG_OUTLINE_OFF
            outlineColor = half3(1, 1, 1);
        #endif

        resultColor.rgb *= outlineColor;
    #endif

    #ifdef _FRESNEL_FEATURE
        half3 fresnelColor = ApplyFresnel(dyedBaseColor, lightingData.mainLightColor, lightingData.giColor,
            inputData.normalWS, inputData.viewDirectionWS, _FresnelColor.rgb, _FresnelRange, _FresnelPower);
        resultColor.rgb += fresnelColor;
    #endif

    #ifdef _DISSOLVE_FEATURE
        DissolveInput dissolveInput;
        dissolveInput.range = _DissolveRange;
        dissolveInput.notUseDirection = _NotUseDirection;
        dissolveInput.direction = _DissolveDirection.xyz;
        dissolveInput.panningSpeed = _DissolvePanningSpeed;
        dissolveInput.dissolveMap = _DissolveMap;
        dissolveInput.dissolveMapSampler = sampler_DissolveMap;
        dissolveInput.dissolveMapST = _DissolveMap_ST;
        dissolveInput.useCutoff = _DissolveCutoff;
        dissolveInput.mainColor = _DissolveColor;
        dissolveInput.mainWidth = _DissolveWidth;
        dissolveInput.edgeColor = _DissolveEdgeColor;
        dissolveInput.edgeWidth = _DissolveEdgeWidth;
        dissolveInput.positionWS = inputData.positionWS;
        dissolveInput.positionOS = input.positionOS;
        dissolveInput.normalWS = inputData.normalWS;
        dissolveInput.characterData = characterData;
        resultColor.rgb = ApplyDissolve(resultColor.rgb, _DissolveAmount, dissolveInput);
    #endif

    ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
    resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
    ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

    resultColor.a = alpha;

    #if defined(_ALPHA_OVERRIDE_FEATURE) && defined(_TRANSPARENCY) && defined(_GRADIENT_ALPHA_FEATURE)
        if (IS_TRUE(_IsGradientAlpha))
        {
            half visualHeight = (_GradientAlphaHeight <= 0.001) ? characterData.visualHeight : _GradientAlphaHeight;
            half gradientAlpha = (inputData.positionWS.y - characterData.characterPos.y) / max(visualHeight, 0.001);
            resultColor.a *= saturate(max(gradientAlpha, 0.1));
        }
    #endif

    #ifdef _THIEF_HIDE
        resultColor.a *= _EffectAlphaValue;
    #endif

    //-----------------------------------------------------------------------------
    // 디버그
    //-----------------------------------------------------------------------------
    #if defined(DEBUG_SHADING_OFF)
    {
        #if !defined(DEBUG_OUTLINE_OFF) && defined(_OUTLINE_FEATURE)
            dyedBaseColor *= outlineColor;
        #endif

        return half4(dyedBaseColor, resultColor.a);
    }
    #endif

    #if defined(DEBUG_DISPLAY)
    {
        return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, dyedBaseColor, alpha);
    }
    #endif
    //-----------------------------------------------------------------------------

    return resultColor;
}

#endif // MMN_CHARACTER_SKIN_BODY_PASS_INCLUDED
