#ifndef UNIVERSAL_FLOORREFLECTION_FORWARD_PASS_INCLUDED
#define UNIVERSAL_FLOORREFLECTION_FORWARD_PASS_INCLUDED

#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/BendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"
#include "../Includes/BlendingHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    float4 color : COLOR;

};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;    // xyz: posWS
    float3 normalWS : TEXCOORD2;

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float4 fogFactorAndVertexLight : TEXCOORD3; // x: fogFactor, yzw: vertex light
    #else
        float fogFactor : TEXCOORD3;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD4;
    #endif

    float4 screenPos : TEXCOORD5;
    float cameraDistance : TEXCOORD6; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
    inputData.normalWS = input.normalWS;

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

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
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

half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    float2 uv = input.uv;
    float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    
    //틴트칼라와 버텍스 칼라
    float3 tintProp = _BaseColor.rgb;
    float tintStrengthProp = _AlbedoTintStrength;
    float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));

    float alpha = diffuseAlpha.a * _BaseColor.a;
    
    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
        alpha = 1;//없으면 댑스문제로 번쩍거림
    #else
        alpha = 1;
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

    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;

    //Emission 을 밤낮에 따라 켜지게 꺼지게 혹은 계속 유지하게 하는 기능
    #define NightOnly 1
    #define DayOnly 2
    if (_Night2DayEnum == NightOnly)
    {
        emission *= abs(1 - _Global_Night2Day);
    }
    else if (_Night2DayEnum == DayOnly)
    {
        emission *= _Global_Night2Day;
    }
    else
    {
        emission = emission;
    }

    half4 specular = _SpecColor * diffuseAlpha.a;
    half smoothness = _Gloss;

    InputData inputData;
    InitializeInputData(input, /* normalTS */ half3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    //라이팅
    half4 color = 0;

    //Half Subtractive
    #if HALF_SUBTRACTIVE_LIGHTMAP_ON
        color = UniversalFragmentLightCustomBaked(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, /*rampY*/ _RampY, _BackfaceReceiveShadowOff, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);
    #else
        color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, /*rampY*/ _RampY, _BackfaceReceiveShadowOff, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);
    #endif

    //플로어 리플렉션 기능
    float3 reflectVec = reflect(-inputData.viewDirectionWS, inputData.normalWS);
    float reflectionMapLodBias = (1.0 - _Gloss) * 8;
    half3 planarReflectionColor = SAMPLE_TEXTURE2D_LOD(_CubeMap, sampler_CubeMap, reflectVec, reflectionMapLodBias).rgb;
    half3 planarReflectionResult = planarReflectionColor * _SpecColor.rgb;

    color.rgb = lerp(color.rgb, planarReflectionResult, _Lerp);

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

    return color;
}
#endif // UNIVERSAL_FLOORREFLECTION_FORWARD_PASS_INCLUDED
