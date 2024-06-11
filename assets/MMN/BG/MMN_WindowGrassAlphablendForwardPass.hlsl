#ifndef MMN_SIMPLE_LIT_PASS_INCLUDED
#define MMN_SIMPLE_LIT_PASS_INCLUDED

#include "../Includes/CustomLighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 texcoord : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    float4 color : COLOR;
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;    // xyz: posWS
    float3 normalWS : TEXCOORD2;
    float fogFactor : TEXCOORD5;
    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);
    float4 screenPos : TEXCOORD8;
    float cameraDistance : TEXCOORD9; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
};


void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
{
    
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(inputData.positionWS);
    inputData.normalWS = input.normalWS;
    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewDirWS = SafeNormalize(viewDirWS);
    inputData.viewDirectionWS = viewDirWS;
    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogFactor);
    inputData.vertexLighting = float3(0, 0, 0);

    #if defined(DEBUG_DISPLAY)
        inputData.vertexSH = input.vertexSH;
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
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    
    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    return output;
}

// Used for StandardSimpleLighting shader
float4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    // 2024-03-07 니어 하프톤 디더링 기능을 더이상 사용하지 않는 정책으로 바뀌어 주석처리합니다. jaehyun.kim
    // #if defined(_GLOBAL_NEARHALFTONECLIP_ON)
    //     //거리에 따라 사라지게 하는 기능
    //     float cameraDistance = input.cameraDistance / 1.5  ;//사라지는 거리 조절하고 싶으면 여기에 곱셈하세요
    //     nearAlpha = saturate(cameraDistance * cameraDistance - 0.5) ;
    // #endif

    //레이케스트 되면 사라지는 기능
    float RaycasthalftoneAlpha = RaycastingHalftoneAlphaBlend(input.screenPos, input.screenPos, _RaycastHarftoneClip, 0);

    InputData inputData;
    InitializeInputData(input, /*normalTS*/float3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);

    float3 reflectVec = reflect(-inputData.viewDirectionWS, inputData.normalWS);
    float3 Reflectionprobe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVec, (1 - _Gloss) * 3), unity_SpecCube0_HDR);
    
    float rim = (dot(inputData.normalWS, inputData.viewDirectionWS));
    rim = 1 - (saturate(rim));
    rim = rim * rim * rim;

    float4 color;
    color = float4(Reflectionprobe * _Global_GILightMulti.rgb * _EmissionColorBright.rgb, saturate(rim + 0.05));

    //하이트 포그  연산
    color = MMN_GlobalTex_HeightFog(
        color,
        input.positionWS, inputData.normalWS, inputData.fogCoord,
        _Global_FogHeightOffset,
        _Global_FogHeightScale,
        _Global_FogHeightNoiseValue,
        _Global_FogHeightNoiseSpeed,
        _Global_FogHeightNoiseScale,
        input.uv);

    color.a = saturate(RaycasthalftoneAlpha * color.a);
    return color;
};

#endif
