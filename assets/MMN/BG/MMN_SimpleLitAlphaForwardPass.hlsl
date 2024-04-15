#ifndef MMN_SIMPLE_LIT_PASS_INCLUDED
#define MMN_SIMPLE_LIT_PASS_INCLUDED

// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"
#include "../Includes/bendingVertex.hlsl"
#include "../Includes/CustomLighting.hlsl"
#include "../Includes/BlendingHelper.hlsl"

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
    // float4 normalWS                  : TEXCOORD2;    // xyz: normal, w: viewDir.x
    // float4 tangentWS                 : TEXCOORD3;    // xyz: tangent, w: viewDir.y
    // float4 bitangentWS               : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    // #else
        float3 normalWS : TEXCOORD2;
    // #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        float4 fogFactorAndVertexLight : TEXCOORD3; // x: fogFactor, yzw: vertex light
    #else
        float fogFactor : TEXCOORD3;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD4;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

    float4 screenPos : TEXCOORD5;
    float cameraDistance : TEXCOORD6; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
    // UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO

};

void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    // #ifdef _NORMALMAP
    // float3 viewDirWS = float3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
    // inputData.tangentToWorld = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);
    // inputData.normalWS = TransformTangentToWorld(normalTS, inputData.tangentToWorld);
    // #else
        float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
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
        inputData.vertexLighting = float3(0, 0, 0);
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

// Used in Standard (Simple Lighting) shader
Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_TRANSFER_INSTANCE_ID(input, output);
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);//원본 버텍스 포지션 변환 함수

    //카메라 바라보는 각도에 따라 버텍스 휘어짐 (제거)
    //버텍스 알파에 따라  바람에 흔들거림
    VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, 1 - saturate(input.color.aaaa + _VertexAniOn), _WindMultiply, _WindSpeedMultiply, /*float _GrassPushPower*/ 0, _VertexAniOn);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);


    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    // #ifdef _NORMALMAP
    // float3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    // output.normalWS = float4(normalInput.normalWS, viewDirWS.x);
    // output.tangentWS = float4(normalInput.tangentWS, viewDirWS.y);
    // output.bitangentWS = float4(normalInput.bitangentWS, viewDirWS.z);
    // #else
        output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
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
        output.fogFactorAndVertexLight = float4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    return output;
}

// Used for StandardSimpleLighting shader
float4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    // UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;
    float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

    //틴트칼라와 버텍스 칼라
    float3 tintProp = _BaseColor.rgb;
    float tintStrengthProp = _AlbedoTintStrength;
    float3 diffuse = TextureTintBlend(diffuseAlpha.rgb, tintProp, tintStrengthProp) * saturate(input.color.rgb + (1 - _VertexColorWeight));


    float alpha = diffuseAlpha.a;
    // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
    // #if defined(_GLOBAL_NEARHALFTONECLIP_ON)
    //     //거리에 따라 사라지게 하는 기능
    //     float cameraDistance = input.cameraDistance / 1.5  ;//사라지는 거리 조절하고 싶으면 여기에 곱셈하세요
    //     nearAlpha = saturate(cameraDistance * cameraDistance - 0.5) ;
    // #endif

    //레이케스트 되면 사라지는 기능
    float RaycasthalftoneAlpha = RaycastingHalftoneAlphaBlend(input.screenPos, input.screenPos, _RaycastHarftoneClip, 0);


    #ifdef _SHOWVERTEXCOLOR_ON
        return float4(saturate(abs(input.color.rgb)), 1);
    #endif

    #ifdef _SHOWVERTEXALPHA_ON
        return float4(saturate(abs(input.color.aaa)), 1);
    #endif

    // float3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
    // float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv));
    float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    float4 specular = _SpecColor * diffuseAlpha.a;
    float smoothness = _Gloss ;

    InputData inputData;
    InitializeInputData(input, /* normalTS */ float3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    // #ifdef _DBUFFER
    // ApplyDecalToBaseColorAndNormal(input.positionCS, diffuse,  inputData.normalWS);
    // #endif


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

    // float4 color = UniversalFragmentBlinnPhong(inputData, surfaceData);
    float4 color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ float3(0, 0, 1), /*shadowDimming*/ 0, /*RampY*/0.5, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);

    //비내리는 텍스쳐 전환
    float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color_Rain = color_Rain.rgb + MMN_GlobalTex_Raindrop(input.positionWS, input.normalWS) * step(0.85, inputData.bakedGI).r * color_Rain.rgb;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

    //컨텍트 셰도우 연산
    color.rgb *= MMN_RecieveContactShadow(input.positionWS.rgb, inputData.shadowCoord);


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

    color.a = saturate(RaycasthalftoneAlpha * diffuseAlpha.a * _BaseColor.a);
    return color;
};

#endif
