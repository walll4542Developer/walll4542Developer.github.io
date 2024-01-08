#ifndef MMN_CHARACTER_SKIN_FACE_PASS_INCLUDED
#define MMN_CHARACTER_SKIN_FACE_PASS_INCLUDED

#include "CharacterCommonAttributes.hlsl"
#include "CharacterCommonBasePassVertex.hlsl"

#include "CharacterLighting.hlsl"
#include "CharacterOnePassOutline.hlsl"
#include "CharacterAtlas.hlsl"
#include "CharacterDye.hlsl"
#include "CharacterParallaxMapping.hlsl"
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
    // 입
    //-----------------------------------------------------------------------------
    #ifdef _MOUTHPUSH_FEATURE
        // 입 밀어넣기 (Parallax)
        const half3 upVector = half3(0.0, 1.0, 0.0);
        half3 cameraDirWS = -GetViewForwardDir();
        half3 mouthNormal = characterData.headDirection3D;

        half adjustHorizontal = abs(dot(mouthNormal, cameraDirWS));
        half adjustVertical = abs(dot(upVector, cameraDirWS));

        half strengthLimit = lerp(_MouthPushStrength * 0.2, _MouthPushStrength, adjustHorizontal);
        half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, mouthNormal, inputData.viewDirectionWS);
        half2 parallaxOffset = GetParallaxOffset1Step(strengthLimit, viewDirTS);

        half offsetSign = (parallaxOffset.x > 0.0) ? 1.0 : -1.0;
        half offsetLimit = lerp(0.16, 0.52, adjustHorizontal);
        parallaxOffset.x = offsetSign * min(offsetLimit, abs(parallaxOffset.x));

        parallaxOffset = lerp(parallaxOffset, half2(parallaxOffset.x * 0.3, parallaxOffset.y), adjustVertical);
        parallaxOffset = lerp(parallaxOffset, half2(0.0, parallaxOffset.y), adjustHorizontal);
    #else
        half2 parallaxOffset = 0;
    #endif

    // 기본 입
    _MouthMapScalePosition.zw -= parallaxOffset * half2(10.0, 0.0);
    _MouthShowType = step(0.1, _MouthShowType);
    float2 mouthMapUV = TransformUV(_MouthMapScalePosition, _MouthMapRotation, input.uv.zw);
    half4 mouthMap = SAMPLE_TEXTURE2D_BIAS(_MouthMap, _MouthMap_linear_clamp_sampler, mouthMapUV, -1.2);
    half3 mouthColor = mouthMap.rgb;
    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyable))
        {
            mouthColor = ApplySkinColor(mouthColor, _DyeColor1.rgb);
        }
    #endif
    dyedBaseColor = lerp(dyedBaseColor, mouthColor, mouthMap.a * (1.0 - _MouthShowType));

    // 이모션 용 입
    _EmotionMouthMapScalePosition.zw -= parallaxOffset * half2(10.0, 0.0);
    float2 emotionMouthMapUV = ConvertToAtlasUV(_EmotionMouthMapAtlasSize.xy, _EmotionMouthMapAtlasSize.z, _EmotionMouthMapScalePosition, _EmotionMouthMapAtlasSize.w, input.uv.zw);
    half4 emotionMouthMap = SAMPLE_TEXTURE2D_BIAS(_EmotionMouthMap, sampler_EmotionMouthMap, emotionMouthMapUV, -1.2);
    half3 emotionMouthColor = emotionMouthMap.rgb;
    dyedBaseColor = lerp(dyedBaseColor, emotionMouthColor, emotionMouthMap.a * _MouthShowType);

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
    // 수염
    //-----------------------------------------------------------------------------
    float2 beardUV = TransformUV(_BeardMapScalePosition, _BeardMapRotation, input.uv.xy);
    half4 beardMap = SAMPLE_TEXTURE2D(_BeardMap, sampler_BeardMap, beardUV);
    half3 beardColor = beardMap.rgb;

    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyableBeard))
        {
            ApplyDyeColor(beardColor, _BeardDyeColor1, _BeardDyeColor2, _BeardDyeColor3);
        }
    #endif
    dyedBaseColor = lerp(dyedBaseColor, beardColor, beardMap.a);

    //-----------------------------------------------------------------------------
    // 악세서리 (예비용)
    //-----------------------------------------------------------------------------
    float2 accessoryUV = TransformUV(_AccessoryMapScalePosition, _AccessoryMapRotation, input.uv.xy);
    half4 accessoryMap = SAMPLE_TEXTURE2D(_AccessoryMap, sampler_AccessoryMap, accessoryUV);
    half3 accessoryColor = accessoryMap.rgb;

    #ifdef _DYE_FEATURE
        if (IS_TRUE(_IsDyableAccessory))
        {
            ApplyDyeColor(accessoryColor, _AccessoryDyeColor1, _AccessoryDyeColor2, _AccessoryDyeColor3);
        }
    #endif
    dyedBaseColor = lerp(dyedBaseColor, accessoryColor, accessoryMap.a);

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

#endif // MMN_CHARACTER_SKIN_FACE_PASS_INCLUDED
