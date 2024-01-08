// #ifndef MMN_CHARACTER_FX_NOISEALPHATEST_OUTLINE_PASS_INCLUDED
// #define MMN_CHARACTER_FX_NOISEALPHATEST_OUTLINE_PASS_INCLUDED

// #include "CharacterCommonAttributes.hlsl"
// #include "CharacterCommonBasePassVertex.hlsl"

// #include "CharacterLighting.hlsl"
// #include "CharacterDye.hlsl"
// #include "CharacterDithering.hlsl"
// #include "CharacterApplyFx.hlsl"
// #include "CharacterApplyFog.hlsl"
// #include "CharacterDebugging.hlsl"
// #include "CharacterOutlineVertexPass.hlsl"


// ///////////////////////////////////////////////////////////////////////////////
// //                           Fragment functions                              //
// ///////////////////////////////////////////////////////////////////////////////

// half4 OutlinePassFragment(Varyings input) : SV_Target
// {
//     //-----------------------------------------------------------------------------
//     // Diffuse
//     //-----------------------------------------------------------------------------
//     float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
//     half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
//     half3 baseColor = baseMap.rgb;
//     half alpha = baseMap.a;

//     #ifndef _TRANSPARENCY
//         alpha = 1.0;
//     #endif

//     HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

//     half3 dyedBaseColor = baseColor;
//     #ifdef _DYE_FEATURE
//         if (IS_TRUE(_IsDyable))
//         {
//             ApplyDyeColor(dyedBaseColor, _DyeColor1, _DyeColor2, _DyeColor3);
//         }
//     #endif

//     //-----------------------------------------------------------------------------
//     // Initialize data
//     //-----------------------------------------------------------------------------
//     // Input data
//     InputData inputData;
//     InitializeCharacterInputData(input, inputData);
//     SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv.xy, _BaseMap);

//     // Light
//     Light mainLight;
//     LightingData lightingData;
//     InitializeLightData(inputData, mainLight, lightingData);

//     // from script
//     CharacterData characterData = InitializeCharacterData();

//     //-----------------------------------------------------------------------------
//     // Process Color
//     //-----------------------------------------------------------------------------
//     half4 resultColor;
//     resultColor.rgb = ProcessCharacterColor(inputData,
//         mainLight, lightingData, characterData,
//         dyedBaseColor, _SilhouetteOff, _SilhouetteTintColor);

//     ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
//     resultColor = ProcessNoiseAlphaTest(resultColor, input.uv.xy);
//     resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
//     ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

//     resultColor.a = alpha;

//     #ifdef _THIEF_HIDE
//         resultColor.a *= _EffectAlphaValue;
//     #endif

//     //-----------------------------------------------------------------------------
//     // 디버그
//     #if defined(DEBUG_DISPLAY)
//     {
//         return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, dyedBaseColor, alpha);
//     }
//     #endif
//     //-----------------------------------------------------------------------------

//     return resultColor;
// }

// #endif // MMN_CHARACTER_FX_NOISEALPHATEST_OUTLINE_PASS_INCLUDED
