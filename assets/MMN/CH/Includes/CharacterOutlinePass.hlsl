// #ifndef MMN_CHARACTER_OUTLINE_PASS_INCLUDED
// #define MMN_CHARACTER_OUTLINE_PASS_INCLUDED

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

// float4 OutlinePassFragment(Varyings input) : SV_Target
// {
//     //-----------------------------------------------------------------------------
//     // Diffuse
//     //-----------------------------------------------------------------------------
//     float2 uv = TRANSFORM_TEX(input.uv.xy, _BaseMap);
//     float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
//     float3 baseColor = baseMap.rgb;
//     float alpha = baseMap.a;

//     #ifdef _ALPHA_TEST
//         clip(alpha - _Cutoff);
//     #endif

//     #ifndef _TRANSPARENCY
//         alpha = 1.0;
//     #endif

//     HalftoneAlphaClip(_HalftoneClip, input.positionNDC);

//     float3 dyedBaseColor = baseColor;
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
//     float4 resultColor = 0;

//     #ifdef _OUTLINE_FEATURE
//         resultColor.rgb = ProcessCharacterColorOutline(inputData,
//             mainLight, lightingData, characterData,
//             dyedBaseColor, _OutlineColor, _OutlineColorMode);
//     #endif

//     ApplyFx_BeforeFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);
//     resultColor = ApplyFog(resultColor, inputData.positionWS.xyz, inputData.normalWS, inputData.fogCoord);
//     ApplyFx_AfterFog(resultColor.rgb, inputData.viewDirectionWS, inputData.normalWS);

//     resultColor.a = alpha;

//     #ifdef _THIEF_HIDE
//         resultColor.a *= _EffectAlphaValue;
//     #endif

//     //-----------------------------------------------------------------------------
//     // 디버그
//     //-----------------------------------------------------------------------------
//     #if defined(DEBUG_DISPLAY)
//     {
//         return CharacterDebuggingColor(inputData, mainLight, lightingData, characterData, dyedBaseColor, alpha);
//     }
//     #endif
//     //-----------------------------------------------------------------------------

//     return resultColor;
// }

// #endif // MMN_CHARACTER_OUTLINE_PASS_INCLUDED
