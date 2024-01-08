#ifndef MMN_SIMPLE_LIT_PASS_INCLUDED
#define MMN_SIMPLE_LIT_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/BendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"
#include "../Includes/BlendingHelper.hlsl"
#include "../Includes/Night2DayControl.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    half3 normalOS : NORMAL;
    half4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    half4 color : COLOR;
    // UNITY_VERTEX_INPUT_INSTANCE_ID

};

struct Varyings
{
    float2 uv : TEXCOORD0;

    float3 positionWS : TEXCOORD1;    // xyz: posWS

    half3 normalWS : TEXCOORD2;

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
    float4 screenPos : TEXCOORD8;
    float cameraDistance : TEXCOORD9; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    half4 color : COLOR;
    float4 positionCS : SV_POSITION;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO

};


void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    // #ifdef _NORMALMAP
    // half3 viewDirWS = half3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
    // inputData.tangentToWorld = half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    // inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
    // #else
        half3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
    inputData.normalWS = input.normalWS;
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
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    #if defined(DEBUG_DISPLAY)
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

// Used in Standard (Simple Lighting) shader
Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_TRANSFER_INSTANCE_ID(input, output);
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    //카메라 바라보는 각도에 따라 버텍스 휘어짐
    VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
    //카메라 바라보는 각도에 따른 휘어짐 + 버텍스 칼라로 흔들림
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    
    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    // #ifdef _NORMALMAP
    // output.normal = half4(normalInput.normalWS, viewDirWS.x);
    // output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
    // output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);
    // #else
        output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    // #endif

    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}

// Used for StandardSimpleLighting shader
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;
    half4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    float3 diffuse = diffuseAlpha.rgb * (_BaseColor.rgb * 0.5) * saturate(input.color.rgb + (1 - _VertexColorWeight));
    half alpha = diffuseAlpha.a * _BaseColor.a;
    
    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
        alpha = 1;//없으면 댑스문제로 번쩍거림
    #else
        alpha = 1;
    #endif

    //거리에 따라 하프톤으로 사라지게 하는 기능
    #if defined(_NEARHALFTONECLIP_ON) && defined(_GLOBAL_NEARHALFTONECLIP_ON)
        half halftoneAlpha = 1;
        NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
        clip(halftoneAlpha);
    #endif
    

    //레이케스트 되면 사라지는 기능
    half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
    clip(RaycasthalftoneAlpha - 0.1);

    #ifdef _SHOWVERTEXCOLOR_ON
        return float4(saturate(abs(input.color.rgb)), 1);
    #endif

    #ifdef _SHOWVERTEXALPHA_ON
        return float4(saturate(abs(input.color.aaa)), 1);
    #endif
    
    //밤 낮 변환 Emission
    half3 emissionColor = night2DayControl(_EmissionColorBright.rgb, _EmissionColorDark.rgb, _OutsideInside, _TempNight2DaySwitchTest);
    //버텍스 알파가 0가 되면 켜져도 꺼진것처럼 됩니다.
    emissionColor = lerp(_EmissionColorDark.rgb, emissionColor, input.color.a);

    //emission  연산 및 specular와 smoothness세팅
    half3 emission = diffuse * emissionColor * alpha * diffuseAlpha.a;
    half4 specular = _SpecColor;// * diffuseAlpha.a;
    half smoothness = _Gloss ;

    InputData inputData;
    InitializeInputData(input, /*normalTS*/half3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    // #ifdef _DBUFFER
    //     ApplyDecalToBaseColorAndNormal(input.positionCS, diffuse,  inputData.normalWS);
    // #endif

    //리플렉션 프로브
    float3 reflectVec = reflect(-inputData.viewDirectionWS, inputData.normalWS);
    float3 Reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, (1 - _Gloss) * 3), unity_SpecCube0_HDR);
    emission += Reflectionprobe * alpha * diffuse.rgb * _SpecColor.rgb * _Global_GILightMulti.rgb;

    //LOD 디더링 기능
    float fadeValue;
    float lodFade;
    if (unity_LODFade.x != 0)
    {
        if (unity_LODFade.x > 0)
        {
            fadeValue = unity_LODFade.x ;
        }
        else
        {
            fadeValue = 1 + unity_LODFade.x;
        }
        Unity_Dither_linear(fadeValue, input.screenPos, lodFade);
        clip(lodFade);
    }
    else
    {
        fadeValue = 1;
    }
    //눈내리는 텍스쳐 전환
    diffuse.rgb = snowTextureLerp(input.positionWS.rgb, diffuse.rgb, input.normalWS.rgb, inputData.bakedGI);

    half4 color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /*normalTS*/half3(0, 0, 1), /*shadowDimming*/0, /*rampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

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
};

#endif
