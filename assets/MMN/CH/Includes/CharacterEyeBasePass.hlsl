#ifndef MMN_CHARACTER_EYE_BASE_PASS_INCLUDED
#define MMN_CHARACTER_EYE_BASE_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterDithering.hlsl"
#include "CharacterApplyFx.hlsl"
#include "CharacterApplyFog.hlsl"
#include "CharacterApplyDissolve.hlsl"
#include "CharacterDebugging.hlsl"


half4 BasePassFragment(Varyings input) : SV_Target
{
    //-----------------------------------------------------------------------------
    // Diffuse
    //-----------------------------------------------------------------------------
    float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    half3 baseColor = baseMap.rgb;
    half alpha = baseMap.a;

    #ifdef _TRANSPARENCY
        alpha *= _AlphaOverride;
    #endif

    HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

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
    // Process Color
    //-----------------------------------------------------------------------------
    half4 resultColor;
    resultColor.rgb = ProcessCharacterColorSimple(inputData,
        mainLight, lightingData, characterData,
        baseColor);

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

    #ifdef _THIEF_HIDE
        resultColor.a *= _EffectAlphaValue;
    #endif

    //-----------------------------------------------------------------------------
    // 디버그
    //-----------------------------------------------------------------------------
    #if defined(DEBUG_SHADING_OFF)
    {
        return half4(baseColor, resultColor.a);
    }
    #endif

    #if defined(DEBUG_DISPLAY)
    {
        return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, baseColor, alpha);
    }
    #endif
    //-----------------------------------------------------------------------------

    return resultColor;
}

#endif // #ifndef MMN_CHARACTER_EYE_BASE_PASS_INCLUDED
