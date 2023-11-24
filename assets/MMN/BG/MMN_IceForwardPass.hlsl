#ifndef UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/BendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"
#include "../Includes/BlendingHelper.hlsl"
#include "../Includes/ParallaxMapping.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    // float2 dynamicLightmapUV    : TEXCOORD2; //리얼타임 라이트맵 안씁니다!
    float4 color : COLOR;
    // UNITY_VERTEX_INPUT_INSTANCE_ID

};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;    // xyz: posWS
    // #ifdef _NORMALMAP
    half4 normalWS : TEXCOORD2;    // xyz: normal, w: viewDir.x
    half4 tangentWS : TEXCOORD3;    // xyz: tangent, w: viewDir.y
    half4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    // #else
    // float3 normalWS : TEXCOORD2;
    // #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        float fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6;
    #endif

    float4 screenPos : TEXCOORD7;
    float cameraDistance : TEXCOORD8; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 9);
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO

};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    // 노말맵을 봉인합니다
    // #ifdef _NORMALMAP
    half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
    // inputData.tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    // inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
    // #else
    // float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
    inputData.normalWS = input.normalWS.rgb;
    // #endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewDirWS = SafeNormalize(viewDirWS);

    inputData.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactorAndVertexLight.x);
        inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
    #else
        inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
        inputData.vertexLighting = half3(0, 0, 0);
    #endif

    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    // inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
        // #if defined(DYNAMICLIGHTMAP_ON)//리얼타임 라이트맵 사용금지입니다.
        // inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
        // #endif
        #if defined(LIGHTMAP_ON)
            inputData.staticLightmapUV = input.staticLightmapUV;
        #else
            inputData.vertexSH = input.vertexSH;
        #endif
    #endif
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// 버텍스 셰이더
Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_TRANSFER_INSTANCE_ID(input, output);
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    //카메라 바라보는 각도에 따라 버텍스 휘어짐 (제거)
    //버텍스 알파에 따라  바람에 흔들거림
    VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, 1 - saturate(input.color.aaaa + _VertexAniOn), _WindMultiply, _WindSpeedMultiply, /*float _GrassPushPower*/ 0, /* _VertexAniOn */ 1);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);


    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    // #ifdef _NORMALMAP
    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
    output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
    output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
    // #else
    // output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    // #endif

    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    // #ifdef DYNAMICLIGHTMAP_ON //리얼타임 라이트맵 안씁니다
    //     output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    // #endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}

// Ice 픽셀셰이더
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{

    float2 uv = input.uv;
    float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    
    //틴트칼라와 버텍스 칼라
    float3 tintProp = _BaseColor.rgb;
    float tintStrengthProp = _AlbedoTintStrength;
    float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));

    //알파테스트
    float alpha = diffuseAlpha.a * _BaseColor.a;
    
    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
    #endif

    //가까워지면 하프톤으로 사라지게 하는 기능
    #if defined(_NEARHALFTONECLIP_ON) && defined(_GLOBAL_NEARHALFTONECLIP_ON)
        float halftoneAlpha;
        NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
        clip(halftoneAlpha);
    #endif

    //레이케스트 되면 사라지는 기능
    half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
    clip(RaycasthalftoneAlpha - 0.1);

    //버텍스칼라 디버깅
    #ifdef _SHOWVERTEXCOLOR_ON
        return float4(saturate(abs(input.color.rgb)), 1);
    #endif

    #ifdef _SHOWVERTEXALPHA_ON
        return float4(saturate(abs(input.color.aaa)), 1);
    #endif

    
    // half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
    // half3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
    // Emission과 Emission 을 밤낮에 따라 켜지게 꺼지게 혹은 계속 유지하게 하는 기능
    // half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    // #define NightOnly 1
    // #define DayOnly 2
    // if (_Night2DayEnum == NightOnly)
    // {
    //     emission *= abs(1 - _Global_Night2Day);
    // }
    // else if (_Night2DayEnum == DayOnly)
    // {
    //     emission *= _Global_Night2Day;
    // }
    // else
    // {
    //     emission = emission;
    // }

    //Specualr
    half4 specular = _SpecColor * diffuseAlpha.a;
    half smoothness = _Gloss ;


    //패럴렉스 테스트
    float3 unnormalizedviewDirectionWS = GetWorldSpaceViewDir(input.positionWS.rgb);
    float3 viewDirTS = GetTangentSpaceViewDir(input.tangentWS, input.normalWS, unnormalizedviewDirectionWS);
    half3 parallaxTex = SAMPLE_TEXTURE2D(_ParallaxMap, sampler_ParallaxMap, uv).rgb;
    float2 parallaxUV = ParallaxMapping(parallaxTex.g * 0.1, viewDirTS, _Gloss);

    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, parallaxUV).rgb;
    return float4(emission, 1);


    InputData inputData;
    InitializeInputData(input, /* normalTS */ half3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    //데칼기능
    //#ifdef _DBUFFER
    //    ApplyDecalToBaseColorAndNormal(input.positionCS, diffuse,  inputData.normalWS);
    //    ApplyDecalToBaseColor(input.positionCS, diffuse);
    //#endif

    //LOD 디더링 기능
    float fadeValue;
    float lodFade;
    if (unity_LODFade.x != 0)
    {
        if (unity_LODFade.x > 0)
        {
            fadeValue = pow(unity_LODFade.x, 1) ;
        }
        else
        {
            fadeValue = 1 + unity_LODFade.x;
        }
        Unity_Dither_linear(fadeValue, input.screenPos, lodFade, 0.5);
        clip(lodFade);
    }
    else
    {
        fadeValue = 1;
    }
    
    //눈내리는 텍스쳐 전환
    diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);
    
    half4 color = 0;
    // half4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
    color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, /*RampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

    //비내리는 텍스쳐 전환
    half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

    //컨텍트 셰도우 연산
    color *= MMN_RecieveContactShadow(input.positionWS, inputData.shadowCoord);

    //하이트 포그  연산
    color = MMN_GlobalTex_HeightFog(
        color,
        input.positionWS, inputData.normalWS, inputData.fogCoord,
        _Global_FogHeightOffset,
        _Global_FogHeightScale,
        _Global_FogHeightNoiseValue,
        _Global_FogHeightNoiseSpeed,
        _Global_FogHeightNoiseScale,
        uv);

    //원본 포그 연산
    //color.rgb =  MixFog(color.rgb, inputData.fogCoord);
    return color;
}
#endif