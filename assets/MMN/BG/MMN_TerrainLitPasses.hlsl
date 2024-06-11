#ifndef UNIVERSAL_TERRAIN_LIT_PASSES_INCLUDED
#define UNIVERSAL_TERRAIN_LIT_PASSES_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/CustomLighting.hlsl"


#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
#endif

#ifdef UNITY_INSTANCING_ENABLED
    TEXTURE2D(_TerrainHeightmapTexture);
    TEXTURE2D(_TerrainNormalmapTexture);
    SAMPLER(sampler_TerrainNormalmapTexture);
#endif

UNITY_INSTANCING_BUFFER_START(Terrain)
UNITY_DEFINE_INSTANCED_PROP(float4, _TerrainPatchInstanceData)  // float4(xBase, yBase, skipScale, ~)
UNITY_INSTANCING_BUFFER_END(Terrain)

#ifdef _ALPHATEST_ON
    TEXTURE2D(_TerrainHolesTexture);
    SAMPLER(sampler_TerrainHolesTexture);

    void ClipHoles(float2 uv)
    {
        float hole = SAMPLE_TEXTURE2D(_TerrainHolesTexture, sampler_TerrainHolesTexture, uv).r;
        clip(hole == 0.0f ? - 1 : 1);
    }
#endif


struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uvMainAndLM : TEXCOORD0; // xy: control, zw: lightmap
    #ifndef TERRAIN_SPLAT_BASEPASS
        float4 uvSplat01 : TEXCOORD1; // xy: splat0, zw: splat1
        float4 uvSplat23 : TEXCOORD2; // xy: splat2, zw: splat3
    #endif

    #if defined(_NORMALMAP) && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float4 normal : TEXCOORD3;    // xyz: normal, w: viewDir.x
        float4 tangent : TEXCOORD4;    // xyz: tangent, w: viewDir.y
        float4 bitangent : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
    #else
        float3 normal : TEXCOORD3;
        float3 viewDir : TEXCOORD4;
        float3 vertexSH : TEXCOORD5; // SH
    #endif

    float4 fogFactorAndVertexLight : TEXCOORD6; // x: fogFactor, yzw: vertex light
    float3 positionWS : TEXCOORD7;
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD8;
    #endif
    float4 clipPos : SV_POSITION;
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings IN, float3 normalTS, out InputData input)
{
    input = (InputData)0;

    input.positionWS = IN.positionWS;
    float3 SH = float3(0, 0, 0);

    #if defined(_NORMALMAP) && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float3 viewDirWS = float3(IN.normal.w, IN.tangent.w, IN.bitangent.w);
        input.normalWS = TransformTangentToWorld(normalTS, float3x3(-IN.tangent.xyz, IN.bitangent.xyz, IN.normal.xyz));
        SH = SampleSH(input.normalWS.xyz);
    #elif defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float3 viewDirWS = IN.viewDir;
        float2 sampleCoords = (IN.uvMainAndLM.xy / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
        float3 normalWS = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
        float3 tangentWS = cross(GetObjectToWorldMatrix()._13_23_33, normalWS);
        input.normalWS = TransformTangentToWorld(normalTS, float3x3(-tangentWS, cross(normalWS, tangentWS), normalWS));
        SH = SampleSH(input.normalWS.xyz);
    #else
        float3 viewDirWS = IN.viewDir;
        input.normalWS = IN.normal;
        SH = IN.vertexSH;
    #endif

    #if SHADER_HINT_NICE_QUALITY
        viewDirWS = SafeNormalize(viewDirWS);
    #endif

    input.normalWS = NormalizeNormalPerPixel(input.normalWS);

    input.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        input.shadowCoord = IN.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        input.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    #else
        input.shadowCoord = float4(0, 0, 0, 0);
    #endif

    input.fogCoord = IN.fogFactorAndVertexLight.x;
    input.vertexLighting = IN.fogFactorAndVertexLight.yzw;
    

    input.bakedGI = SAMPLE_GI(IN.uvMainAndLM.zw, SH, input.normalWS) ;
    
    input.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
    input.shadowMask = SAMPLE_SHADOWMASK(IN.uvMainAndLM.zw)
}

#ifndef TERRAIN_SPLAT_BASEPASS

    void SplatmapMix(float4 uvMainAndLM, float4 uvSplat01, float4 uvSplat23, inout float4 splatControl, out float weight, out float3 mixedDiffuse, inout float3 mixedNormal, out float sp_alpha, float3 positionWS, float3 normalWS)
    {
        float4 diffAlbedo[4];

        // UV ????? ????
        // diffAlbedo[0] = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, uvSplat01.xy);
        // diffAlbedo[1] = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat0, uvSplat01.zw);
        // diffAlbedo[2] = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat0, uvSplat23.xy);
        // diffAlbedo[3] = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat0, uvSplat23.zw);
        
        //UV ??????? ???? ????? ???. 0.025?? ??? ????ο? ?ִ? uv?? ????? ???? ??߱? ??? ??
        //Triplaner ????? ???
        float4 splat1_z = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, positionWS.xy * 0.0025 * _V_T2M_Splat1_uvScale);
        float4 splat1_x = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, positionWS.zy * 0.0025 * _V_T2M_Splat1_uvScale);
        float4 splat1_y = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, positionWS.xz * 0.0025 * _V_T2M_Splat1_uvScale);

        diffAlbedo[0] = lerp(splat1_z, splat1_x, abs(normalWS.x));
        diffAlbedo[0] = lerp(diffAlbedo[0], splat1_y, pow(normalWS.y, 3));

        float4 splat2_z = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat0, positionWS.xy * 0.0025 * _V_T2M_Splat2_uvScale);
        float4 splat2_x = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat0, positionWS.zy * 0.0025 * _V_T2M_Splat2_uvScale);
        float4 splat2_y = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat0, positionWS.xz * 0.0025 * _V_T2M_Splat2_uvScale);

        diffAlbedo[1] = lerp(splat2_z, splat2_x, abs(normalWS.x));
        diffAlbedo[1] = lerp(diffAlbedo[1], splat2_y, pow(normalWS.y, 3));


        float4 splat3_z = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat0, positionWS.xy * 0.0025 * _V_T2M_Splat3_uvScale);
        float4 splat3_x = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat0, positionWS.zy * 0.0025 * _V_T2M_Splat3_uvScale);
        float4 splat3_y = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat0, positionWS.xz * 0.0025 * _V_T2M_Splat3_uvScale);

        diffAlbedo[2] = lerp(splat3_z, splat3_x, abs(normalWS.x));
        diffAlbedo[2] = lerp(diffAlbedo[2], splat3_y, pow(normalWS.y, 3));


        float4 splat4_z = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat0, positionWS.xy * 0.0025 * _V_T2M_Splat4_uvScale);
        float4 splat4_x = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat0, positionWS.zy * 0.0025 * _V_T2M_Splat4_uvScale);
        float4 splat4_y = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat0, positionWS.xz * 0.0025 * _V_T2M_Splat4_uvScale);

        diffAlbedo[3] = lerp(splat4_z, splat4_x, abs(normalWS.x));
        diffAlbedo[3] = lerp(diffAlbedo[3], splat4_y, pow(normalWS.y, 3));



        // This might be a bit of a gamble -- the assumption here is that if the diffuseMap has no
        // alpha channel, then diffAlbedo[n].a = 1.0 (and _DiffuseHasAlphaN = 0.0)
        // Prior to coming in, _SmoothnessN is actually set to max(_DiffuseHasAlphaN, _SmoothnessN)
        // This means that if we have an alpha channel, _SmoothnessN is locked to 1.0 and
        // otherwise, the true slider value is passed down and diffAlbedo[n].a == 1.0.
        //???????Ͻ? ?⺻?? 0???? ?α?.
        // defaultSmoothness = float4(diffAlbedo[0].a, diffAlbedo[1].a, diffAlbedo[2].a, diffAlbedo[3].a);
        // defaultSmoothness *= float4(_Smoothness0, _Smoothness1, _Smoothness2, _Smoothness3);
        
        sp_alpha = splatControl.r;// + 0.5; //2nd pass?? ?ĥ?? ??ĸ? ?ġ?? ???? ?????? ????? ??ĸ? ????ֱ? ?????. ????? ?Ⱦ?

        //?????? ????? ??? ????ε? ??? ?????? ???ε?
        #ifndef _TERRAIN_BLEND_HEIGHT
            // 20.0 is the number of steps in inputAlphaMask (Density mask. We decided 20 empirically)
            float4 opacityAsDensity = saturate((float4(diffAlbedo[0].a, diffAlbedo[1].a, diffAlbedo[2].a, diffAlbedo[3].a) - (float4(1.0, 1.0, 1.0, 1.0) - splatControl)) * 20.0);
            opacityAsDensity += 0.001h * splatControl;      // if all weights are zero, default to what the blend mask says
            float4 useOpacityAsDensityParam = {
                _DiffuseRemapScale0.w, _DiffuseRemapScale1.w, _DiffuseRemapScale2.w, _DiffuseRemapScale3.w
            };
            // 1 is off
            splatControl = lerp(opacityAsDensity, splatControl, useOpacityAsDensityParam);
        #endif

        
        
        // ===============================================================================
        // ==                         Texture Calc ?????                              ==
        // ===============================================================================

        // float sp_r = saturate(step(0.5, splatControl.r * diffAlbedo[0].a + pow(splatControl.r, 5)));
        // float sp_r_shadow = saturate(smoothstep(0.5,0.9, splatControl.r * diffAlbedo[0].a + pow(splatControl.r, 5)));
        // float sp_g = saturate(step(0.5, splatControl.g * diffAlbedo[1].a + pow(splatControl.g, 10)));
        // float sp_bOUT = saturate(step(0.4, splatControl.b * diffAlbedo[2].a + pow(splatControl.b, 2)));
        // float sp_bIN = saturate(step(0.8, splatControl.b * diffAlbedo[2].a + pow(splatControl.b, 10)));
        // float sp_a = saturate(step(0.5, splatControl.a * diffAlbedo[3].a + pow(splatControl.a, 10)));


        // mixedDiffuse = 0.0h;


        // // ?? ?????? ?ٽ? ????

        // mixedDiffuse = diffAlbedo[0] * sp_r;
        // mixedDiffuse = mixedDiffuse * saturate(sp_r_shadow + 0.8);//1??° ???????? ?׸???
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[1]*1.1 , (1- sp_r)); //2??° ??????
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[1], sp_g); //2??° ????????? ??? ???
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2]*0.8, sp_bOUT);//
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2] , sp_bIN);//
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[3], sp_a);//



        // ===============================================================================
        // ==                         Texture Calc ????۾?                              ==
        // ===============================================================================

        // float sp_r = saturate(step(0.01, splatControl.r * diffAlbedo[1].a + pow(splatControl.r, 5)));
        float sp_r = saturate(step(0.5 * _V_T2M_Splat2_Vector1, splatControl.r * diffAlbedo[1].a + pow(splatControl.r, 5)));
        float sp_rExpand = saturate(step(0.5 * _V_T2M_Splat2_Vector2, splatControl.r * diffAlbedo[1].a + pow(splatControl.r, 5)));
        // float sp_g = saturate(step(0.01, splatControl.g * diffAlbedo[1].a + pow(splatControl.g, 5)));
        // float sp_b = saturate(step(0.01, splatControl.b * diffAlbedo[2].a + pow(splatControl.b, 5)));
        // float sp_a = saturate(step(0.01, splatControl.a * diffAlbedo[3].a + pow(splatControl.a, 5)));
        float sp_b = saturate(step(0.5 * (-_V_T2M_Splat3_Vector1 + 2), splatControl.b * diffAlbedo[2].a + pow(splatControl.b, 5)));
        float sp_bExpand = saturate(step(0.5 * (-_V_T2M_Splat3_Vector2 + 2), splatControl.b * diffAlbedo[2].a + pow(splatControl.b, 5)));

        float sp_aExpand = saturate(step(0.5 * (-_V_T2M_Splat4_Vector2 + 2), splatControl.a * diffAlbedo[3].a + pow(splatControl.a, 5)));
        float sp_a = saturate(step(0.5 * (-_V_T2M_Splat4_Vector1 + 2), splatControl.a * diffAlbedo[3].a + pow(splatControl.a, 5)));


        mixedDiffuse = diffAlbedo[0].rgb;
        // mixedDiffuse = lerp(diffAlbedo[0].rgb, diffAlbedo[1].rgb, 1 - sp_r);
        //텍스쳐 블렌딩 연산 신형
        //(_V_T2M_Splat2_EdgeColor * 4.2 - 1) * 0.25 : 4.2 는 2.2 감마에 *2-1 을 합친겁니다. 0.2로 강도조절
        mixedDiffuse = lerp(diffAlbedo[1].rgb + (_V_T2M_Splat2_EdgeColor.rgb * 4.2 - 1) * 0.2, diffAlbedo[0].rgb, sp_rExpand);
        mixedDiffuse = lerp(diffAlbedo[1].rgb, mixedDiffuse, sp_r);
        
        /* g ????ũ?? r?? ????? ????? ?????ϴ?.
        mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[1], sp_g); */
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2].rgb, saturate(sp_b));
        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[3].rgb, sp_a);
        //float alpha = 1;

        // mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2].rgb.rgb + (_V_T2M_Splat3_EdgeColor * 4.2 - 1) * 0.1, sp_bExpand);
        mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2].rgb.rgb + (_V_T2M_Splat3_EdgeColor.rgb * 4.2 - 1) * 0.2, sp_bExpand);
        mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[2].rgb, sp_b);

        mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[3].rgb + (_V_T2M_Splat4_EdgeColor.rgb * 4.2 - 1) * 0.2, sp_aExpand);
        mixedDiffuse = lerp(mixedDiffuse, diffAlbedo[3].rgb, sp_a);


        // Now that splatControl has changed, we can compute the final weight and normalize
        weight = dot(splatControl, 1.0h);
        //weight = saturate(sp_r + sp_g + sp_b + sp_a);
        
        #ifdef TERRAIN_SPLAT_ADDPASS
            clip(weight <= 0.1h ? - 1.0h : 1.0h);
            //clip(weight <= sp_b ? 0.0h : 1.0h);
            //clip (sp_r + sp_g + sp_b + sp_a);
        #endif

        #ifndef _TERRAIN_BASEMAP_GEN
            // Normalize weights before lighting and restore weights in final modifier functions so that the overal
            // lighting result can be correctly weighted.
            //splatControl /= (weight + HALF_MIN);
            splatControl = saturate(splatControl);
            //  ???? ?????? ?ִٰ? ??? ???߿? ?־? ????? ?𸣰ڽ??ϴ?. ???̽??? ???? ?κ?̶? ?ϴ? ???ܺ??ϴ?
        #endif
        


        // ===============================================================================
        // ==                         ?븻?? ?????                                      ==
        // ===============================================================================
        #ifdef _NORMALMAP
            float3 nrm = 0.0f;
            nrm += splatControl.r * UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal0, sampler_Normal0, positionWS.xz * 0.0025 * _V_T2M_Splat1_uvScale), _NormalScale0);
            nrm += splatControl.g * UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal1, sampler_Normal0, positionWS.xz * 0.0025 * _V_T2M_Splat2_uvScale), _NormalScale1);
            nrm += splatControl.b * UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal2, sampler_Normal0, positionWS.xz * 0.0025 * _V_T2M_Splat3_uvScale), _NormalScale2);
            nrm += splatControl.a * UnpackNormalScale(SAMPLE_TEXTURE2D(_Normal3, sampler_Normal0, positionWS.xz * 0.0025 * _V_T2M_Splat4_uvScale), _NormalScale3);

            // avoid risk of NaN when normalizing.
            #if HAS_HALF
                nrm.z += 0.01h;
            #else
                nrm.z += 1e-5f;
            #endif

            mixedNormal = normalize(nrm.xyz);
        #endif
    }

#endif

#ifdef _TERRAIN_BLEND_HEIGHT
    void HeightBasedSplatModify(inout float4 splatControl, in float4 masks[4])
    {
        // heights are in mask blue channel, we multiply by the splat Control weights to get combined height
        float4 splatHeight = float4(masks[0].b, masks[1].b, masks[2].b, masks[3].b) * splatControl.rgba;
        float maxHeight = max(splatHeight.r, max(splatHeight.g, max(splatHeight.b, splatHeight.a)));

        // Ensure that the transition height is not zero.
        float transition = max(_HeightTransition, 1e-5);

        // This sets the highest splat to "transition", and everything else to a lower value relative to that, clamping to zero
        // Then we clamp this to zero and normalize everything
        float4 weightedHeights = splatHeight + transition - maxHeight.xxxx;
        weightedHeights = max(0, weightedHeights);

        // We need to add an epsilon here for active layers (hence the blendMask again)
        // so that at least a layer shows up if everything's too low.
        weightedHeights = (weightedHeights + 1e-6) * splatControl;

        // Normalize (and clamp to epsilon to keep from dividing by zero)
        float sumHeight = max(dot(weightedHeights, float4(1, 1, 1, 1)), 1e-6);
        splatControl = weightedHeights / sumHeight.xxxx;
    }
#endif



// void SplatmapFinalColor(inout float4 color, float fogCoord , float sp_alpha , float3 positionWS)
// {
//     color.rgb *= color.a;

//     #ifndef TERRAIN_GBUFFER // Technically we don't need fogCoord, but it is still passed from the vertex shader.

//     #ifdef TERRAIN_SPLAT_ADDPASS
//         color.rgb = MixFogColor(color.rgb, float3(0,0,0), fogCoord);
//     #else
//         color.rgb = MixFog(color.rgb, fogCoord);
//     #endif

//     #endif
// }


//??? ???? ??? ?κ?
void SplatmapFinalColor(inout float4 color, float fogCoord, float sp_alpha, float3 positionWS, float3 normalWS)
{
    color.rgb *= color.a; // ?? ?κ?? 2nd pass?? ?????? ?κ?
    
    #ifndef TERRAIN_GBUFFER // Technically we don't need fogCoord, but it is still passed from the vertex shader.

        float3 withFogColor;

        #ifdef TERRAIN_SPLAT_ADDPASS
            withFogColor = MixFogColor(color.rgb, float3(0, 0, 0), fogCoord);
            
            // ??׿? ?????? ?????? ?? ?κ?. ????? ????ο????? ?״?? ?߿??? ??????ٰ?,
            // 4?????? ????? ??̴??? ?????? ???? ?ǹ̰? ?????ϴ?.
        #else
            color = MMN_GlobalTex_HeightFog(
                color,
                positionWS, normalWS, fogCoord,
                _Global_FogHeightOffset,
                _Global_FogHeightScale,
                _Global_FogHeightNoiseValue,
                _Global_FogHeightNoiseSpeed,
                _Global_FogHeightNoiseScale,
                float2(0, 0)); //?? ?? uv ?? ???? ?? ??? ????
                //???? ??? ????
                //color.rgb =  MixFog(color.rgb, fogCoord);
        #endif
    #endif
    
    
    //color.rgb = noisevalue;

    }

    void TerrainInstancing(inout float4 positionOS, inout float3 normal, inout float2 uv)
{
    #ifdef UNITY_INSTANCING_ENABLED
        float2 patchVertex = positionOS.xy;
        float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);

        float2 sampleCoords = (patchVertex.xy + instanceData.xy) * instanceData.z; // (xy + float2(xBase,yBase)) * skipScale
        float height = UnpackHeightmap(_TerrainHeightmapTexture.Load(int3(sampleCoords, 0)));

        positionOS.xz = sampleCoords * _TerrainHeightmapScale.xz;
        positionOS.y = height * _TerrainHeightmapScale.y;

        #ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
            normal = float3(0, 1, 0);
        #else
            normal = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb * 2 - 1;
        #endif
        uv = sampleCoords * _TerrainHeightmapRecipSize.zw;
    #endif
}

void TerrainInstancing(inout float4 positionOS, inout float3 normal)
{
    float2 uv = {
        0, 0
    };
    TerrainInstancing(positionOS, normal, uv);
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard Terrain shader
Varyings SplatmapVert(Attributes v)
{
    Varyings o = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TerrainInstancing(v.positionOS, v.normalOS, v.texcoord);

    //VertexPositionInputs Attributes = GetVertexPositionInputs(v.positionOS.xyz);//???? ????? ????? ??ȯ ???
    //?Ʒ? ?????? ????. ??? ??????̵? ?Ǿ? ???(positionOS , _Global_VertexPositionOffset , cameraForwardDirMul)
    VertexPositionInputs Attributes = GetVertexPositionInputsForBending(v.positionOS.xyz);

    o.uvMainAndLM.xy = v.texcoord;
    o.uvMainAndLM.zw = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
    #ifndef TERRAIN_SPLAT_BASEPASS
        o.uvSplat01.xy = TRANSFORM_TEX(v.texcoord, _Splat0);
        o.uvSplat01.zw = TRANSFORM_TEX(v.texcoord, _Splat1);
        o.uvSplat23.xy = TRANSFORM_TEX(v.texcoord, _Splat2);
        o.uvSplat23.zw = TRANSFORM_TEX(v.texcoord, _Splat3);
    #endif

    float3 viewDirWS = GetWorldSpaceViewDir(Attributes.positionWS);
    #if !SHADER_HINT_NICE_QUALITY
        viewDirWS = SafeNormalize(viewDirWS);
    #endif

    #if defined(_NORMALMAP) && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float4 vertexTangent = float4(cross(float3(0, 0, 1), v.normalOS), 1.0);
        VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, vertexTangent);

        o.normal = float4(normalInput.normalWS, viewDirWS.x);
        o.tangent = float4(normalInput.tangentWS, viewDirWS.y);
        o.bitangent = float4(normalInput.bitangentWS, viewDirWS.z);
    #else
        o.normal = TransformObjectToWorldNormal(v.normalOS);
        o.viewDir = viewDirWS;
        o.vertexSH = SampleSH(o.normal);
    #endif
    o.fogFactorAndVertexLight.x = ComputeFogFactor(Attributes.positionCS.z);
    o.fogFactorAndVertexLight.yzw = MM_VertexLighting(Attributes.positionWS, o.normal.xyz);
    o.positionWS = Attributes.positionWS;
    o.clipPos = Attributes.positionCS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        o.shadowCoord = GetShadowCoord(Attributes);
    #endif

    return o;
}

void ComputeMasks(out float4 masks[4], float4 hasMask, Varyings IN)
{
    masks[0] = 0.5h;
    masks[1] = 0.5h;
    masks[2] = 0.5h;
    masks[3] = 0.5h;

    #ifdef _MASKMAP
        masks[0] = lerp(masks[0], SAMPLE_TEXTURE2D(_V_T2M_Splat1_mask, sampler_V_T2M_Splat1_mask, IN.uvSplat01.xy), hasMask.x);
        masks[1] = lerp(masks[1], SAMPLE_TEXTURE2D(_V_T2M_Splat2_mask, sampler_V_T2M_Splat1_mask, IN.uvSplat01.zw), hasMask.y);
        masks[2] = lerp(masks[2], SAMPLE_TEXTURE2D(_V_T2M_Splat3_mask, sampler_V_T2M_Splat1_mask, IN.uvSplat23.xy), hasMask.z);
        masks[3] = lerp(masks[3], SAMPLE_TEXTURE2D(_V_T2M_Splat4_mask, sampler_V_T2M_Splat1_mask, IN.uvSplat23.zw), hasMask.w);
    #endif

    masks[0] *= _MaskMapRemapScale0.rgba;
    masks[0] += _MaskMapRemapOffset0.rgba;
    masks[1] *= _MaskMapRemapScale1.rgba;
    masks[1] += _MaskMapRemapOffset1.rgba;
    masks[2] *= _MaskMapRemapScale2.rgba;
    masks[2] += _MaskMapRemapOffset2.rgba;
    masks[3] *= _MaskMapRemapScale3.rgba;
    masks[3] += _MaskMapRemapOffset3.rgba;
}

// Used in Standard Terrain shader
// #ifdef TERRAIN_GBUFFER
//     FragmentOutput SplatmapFragment(Varyings IN)
// #else
    float4 SplatmapFragment(Varyings IN) : SV_TARGET
// #endif

{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);
    #ifdef _ALPHATEST_ON
        ClipHoles(IN.uvMainAndLM.xy);
    #endif

    float3 normalTS = float3(0.0h, 0.0h, 1.0h);

    
    #ifdef TERRAIN_SPLAT_BASEPASS
        float3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMainAndLM.xy).rgb;
        // float smoothness = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMainAndLM.xy).a;
        // float metallic = SAMPLE_TEXTURE2D(_MetallicTex, sampler_MetallicTex, IN.uvMainAndLM.xy).r;
        float alpha = 1;
        // float occlusion = 1;
    #else

        float4 hasMask = float4(_LayerHasMask0, _LayerHasMask1, _LayerHasMask2, _LayerHasMask3);
        float4 masks[4];
        ComputeMasks(masks, hasMask, IN);

        float2 splatUV = (IN.uvMainAndLM.xy * (_Control_TexelSize.zw - 1.0f) + 0.5f) * _Control_TexelSize.xy;
        float4 splatControl = SAMPLE_TEXTURE2D(_Control, sampler_Control, splatUV);

        #ifdef _TERRAIN_BLEND_HEIGHT
            // disable Height Based blend when there are more than 4 layers (multi-pass breaks the normalization)
            if (_NumLayersCount <= 4)
                HeightBasedSplatModify(splatControl, masks);
        #endif

        InputData inputData;
        

        float weight;
        float3 mixedDiffuse;
        
        float sp_alpha;
        SplatmapMix(IN.uvMainAndLM, IN.uvSplat01, IN.uvSplat23, splatControl, weight, mixedDiffuse, normalTS, sp_alpha, IN.positionWS.rgb, IN.normal);
        float3 albedo = mixedDiffuse.rgb;

        InitializeInputData(IN, normalTS, inputData);
        
        // float4 defaultMetallic = float4(_Metallic0, _Metallic1, _Metallic2, _Metallic3);
        // float4 defaultOcclusion = float4(_MaskMapRemapScale0.g, _MaskMapRemapScale1.g, _MaskMapRemapScale2.g, _MaskMapRemapScale3.g) +
        // float4(_MaskMapRemapOffset0.g, _MaskMapRemapOffset1.g, _MaskMapRemapOffset2.g, _MaskMapRemapOffset3.g);

        // float4 maskSmoothness = float4(masks[0].a, masks[1].a, masks[2].a, masks[3].a);
        // defaultSmoothness = lerp(defaultSmoothness, maskSmoothness, hasMask);
        // float smoothness = dot(splatControl, defaultSmoothness);

        // float4 maskMetallic = float4(masks[0].r, masks[1].r, masks[2].r, masks[3].r);
        // defaultMetallic = lerp(defaultMetallic, maskMetallic, hasMask);
        // float metallic = dot(splatControl, defaultMetallic);

        // float4 maskOcclusion = float4(masks[0].g, masks[1].g, masks[2].g, masks[3].g);
        // defaultOcclusion = lerp(defaultOcclusion, maskOcclusion, hasMask);
        // float occlusion = dot(splatControl, defaultOcclusion);
        float alpha = weight;
    #endif


    // ===============================================================================
    // ==                            SpecualrMap Calc                               ==
    // ===============================================================================


    float4 spec1 = float4(0, 0, 0, 0); float4 spec2 = float4(0, 0, 0, 0); float4 spec3 = float4(0, 0, 0, 0); float4 spec4 = float4(0, 0, 0, 0);

    // ???ŧ?? ?????. ???ŧ???? ??????? ???ֶ? Triplaner?? ????? ?ʾҽ??ϴ?. ??? ????ŷ ????? ????ؼ? Ȱ?? ????մϴ?.
    
    spec1 = SAMPLE_TEXTURE2D(_V_T2M_Splat1_mask, sampler_V_T2M_Splat1_mask, inputData.positionWS.xz * 0.0025 * _V_T2M_Splat1_uvScale);
    spec2 = SAMPLE_TEXTURE2D(_V_T2M_Splat2_mask, sampler_V_T2M_Splat1_mask, inputData.positionWS.xz * 0.0025 * _V_T2M_Splat2_uvScale);
    spec3 = SAMPLE_TEXTURE2D(_V_T2M_Splat3_mask, sampler_V_T2M_Splat1_mask, inputData.positionWS.xz * 0.0025 * _V_T2M_Splat3_uvScale);
    spec4 = SAMPLE_TEXTURE2D(_V_T2M_Splat4_mask, sampler_V_T2M_Splat1_mask, inputData.positionWS.xz * 0.0025 * _V_T2M_Splat4_uvScale);

    // ????? r?? ???? ?ֽ??ϴ?.
    float3 specCalc = spec1.rgb * splatControl.r;
    specCalc += spec2.rgb * splatControl.g;
    specCalc += spec3.rgb * splatControl.b;
    specCalc += spec4.rgb * splatControl.a;

    // ===============================================================================
    // ==                            Lighting Calc                                  ==
    // ===============================================================================

    float4 specular = _SpecColor * specCalc.r;
    float smoothness = _Glossiness;

    //??????
    float rim = (dot(normalize(inputData.normalWS), normalize(inputData.viewDirectionWS)));
    rim = abs(1 - rim);
    rim = saturate(pow(rim, 5));
    float3 rimcolor = albedo.rgb * rim * 0.1;
    

    //G????? ???? ?ʴ´?
    // #ifdef TERRAIN_GBUFFER

    //     BRDFData brdfData;
    //     // InitializeBRDFData(albedo, metallic, /* specular */ float3(0.0h, 0.0h, 0.0h), smoothness, alpha, brdfData);
    //     InitializeBRDFData(albedo, 0, /* specular */ float3(0.0h, 0.0h, 0.0h), 0.4, alpha, brdfData);

    //     float4 color;
    //     color.rgb = GlobalIllumination(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS);
    //     color.a = alpha;

    //     SplatmapFinalColor(color, inputData.fogCoord, sp_alpha, inputData.positionWS);

    //     return BRDFDataToGbuffer(brdfData, inputData, smoothness, color.rgb);

    // #else

    //PBR???? ????
    // float4 color = UniversalFragmentPBR(inputData, albedo, metallic, /* specular */ float3(0.0h, 0.0h, 0.0h), 0.4, occlusion, /* emission */ float3(0, 0, 0), alpha);

    // Ŀ??? ???? ?????? ?ٲ۴?
    // float4 color = UniversalFragmentLightCustom(inputData, albedo, specular, smoothness, rimcolor, alpha);
    float4 color = UniversalFragmentLightCustom(inputData, albedo, specular, smoothness, rimcolor, alpha, /* normalTS */ float3(0, 0, 1), /* shadowDimming */ 0, /*RampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);
    

    SplatmapFinalColor(color, inputData.fogCoord, sp_alpha, inputData.positionWS, inputData.normalWS);
    
    return float4(color.rgb, 1.0h);
    // #endif

}

// Shadow pass

// x: global clip space bias, y: normal world space bias
float3 _LightDirection;

struct AttributesLean
{
    float4 position : POSITION;
    float3 normalOS : NORMAL;
    #ifdef _ALPHATEST_ON
        float2 texcoord : TEXCOORD0;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VaryingsLean
{
    float4 clipPos : SV_POSITION;
    #ifdef _ALPHATEST_ON
        float2 texcoord : TEXCOORD0;
    #endif
    UNITY_VERTEX_OUTPUT_STEREO
};

VaryingsLean ShadowPassVertex(AttributesLean v)
{
    VaryingsLean o = (VaryingsLean)0;
    UNITY_SETUP_INSTANCE_ID(v);
    TerrainInstancing(v.position, v.normalOS);

    float3 positionWS = TransformObjectToWorld(v.position.xyz);
    float3 normalWS = TransformObjectToWorldNormal(v.normalOS);

    float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

    #if UNITY_REVERSED_Z
        clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
    #else
        clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
    #endif

    o.clipPos = clipPos;

    #ifdef _ALPHATEST_ON
        o.texcoord = v.texcoord;
    #endif

    return o;
}

float4 ShadowPassFragment(VaryingsLean IN) : SV_TARGET
{
    #ifdef _ALPHATEST_ON
        ClipHoles(IN.texcoord);
    #endif
    return 0;
}

// Depth pass

VaryingsLean DepthOnlyVertex(AttributesLean v)
{
    VaryingsLean o = (VaryingsLean)0;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TerrainInstancing(v.position, v.normalOS);
    o.clipPos = TransformObjectToHClip(v.position.xyz);
    #ifdef _ALPHATEST_ON
        o.texcoord = v.texcoord;
    #endif
    return o;
}

float4 DepthOnlyFragment(VaryingsLean IN) : SV_TARGET
{
    #ifdef _ALPHATEST_ON
        ClipHoles(IN.texcoord);
    #endif
    #ifdef SCENESELECTIONPASS
        // We use depth prepass for scene selection in the editor, this code allow to output the outline correctly
        return float4(_ObjectId, _PassValue, 1.0, 1.0);
    #endif
    return 0;
}


// DepthNormal pass
struct AttributesDepthNormal
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct VaryingsDepthNormal
{
    float4 uvMainAndLM : TEXCOORD0; // xy: control, zw: lightmap
    #ifndef TERRAIN_SPLAT_BASEPASS
        float4 uvSplat01 : TEXCOORD1; // xy: splat0, zw: splat1
        float4 uvSplat23 : TEXCOORD2; // xy: splat2, zw: splat3
    #endif

    #if defined(_NORMALMAP) && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float4 normal : TEXCOORD3;    // xyz: normal, w: viewDir.x
        float4 tangent : TEXCOORD4;    // xyz: tangent, w: viewDir.y
        float4 bitangent : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
    #else
        float3 normal : TEXCOORD3;
    #endif

    float4 clipPos : SV_POSITION;
    UNITY_VERTEX_OUTPUT_STEREO
};

VaryingsDepthNormal DepthNormalOnlyVertex(AttributesDepthNormal v)
{
    VaryingsDepthNormal o = (VaryingsDepthNormal)0;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TerrainInstancing(v.positionOS, v.normalOS, v.texcoord);

    VertexPositionInputs Attributes = GetVertexPositionInputs(v.positionOS.xyz);

    o.uvMainAndLM.xy = v.texcoord;
    o.uvMainAndLM.zw = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
    #ifndef TERRAIN_SPLAT_BASEPASS
        o.uvSplat01.xy = TRANSFORM_TEX(v.texcoord, _Splat0);
        o.uvSplat01.zw = TRANSFORM_TEX(v.texcoord, _Splat1);
        o.uvSplat23.xy = TRANSFORM_TEX(v.texcoord, _Splat2);
        o.uvSplat23.zw = TRANSFORM_TEX(v.texcoord, _Splat3);
    #endif

    #if defined(_NORMALMAP) && !defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
        float3 viewDirWS = GetWorldSpaceViewDir(Attributes.positionWS);
        #if !SHADER_HINT_NICE_QUALITY
            viewDirWS = SafeNormalize(viewDirWS);
        #endif
        float4 vertexTangent = float4(cross(float3(0, 0, 1), v.normalOS), 1.0);
        VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, vertexTangent);

        o.normal = float4(normalInput.normalWS, viewDirWS.x);
        o.tangent = float4(normalInput.tangentWS, viewDirWS.y);
        o.bitangent = float4(normalInput.bitangentWS, viewDirWS.z);
    #else
        o.normal = TransformObjectToWorldNormal(v.normalOS);
    #endif

    o.clipPos = Attributes.positionCS;
    return o;
}

float4 DepthNormalOnlyFragment(VaryingsDepthNormal IN) : SV_TARGET
{
    #ifdef _ALPHATEST_ON
        ClipHoles(IN.uvMainAndLM.xy);
    #endif

    float3 normalWS = IN.normal.xyz;
    return float4(PackNormalOctRectEncode(TransformWorldToViewDir(normalWS, true)), 0.0, 0.0);
}


#endif