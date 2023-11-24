#ifndef UNIVERSAL_SIMPLE_LIT_DEPTH_NORMALS_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_DEPTH_NORMALS_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/bendingVertex.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float3 normal       : NORMAL;
    float4 color        : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS      : SV_POSITION;
    float4 color           : COLOR;
    float2 uv              : TEXCOORD1;

    // #ifdef _NORMALMAP
        half4 normalWS    : TEXCOORD2;    // xyz: normal, w: viewDir.x
        half4 tangentWS   : TEXCOORD3;    // xyz: tangent, w: viewDir.y
        half4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    // #else
    //     half3 normalWS    : TEXCOORD2;
    //     half3 viewDir     : TEXCOORD3;
    // #endif
    float4 screenPos    : TEXCOORD5;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv         = TRANSFORM_TEX(input.texcoord, _BaseMap);
    // output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    //카메라 바라보는 각도에 따라 버텍스 휘어짐
    //버텍스 알파에 따라  바람에 흔들거림
    VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, 1 - saturate(input.color.a + _VertexAniOff), _WindMultiply, _WindSpeedMultiply, /*float _GrassPushPower*/ 0);

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangentOS); //노말도 해야 할 것 같은데 일단 두고 봅니다 

    output.positionCS = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.screenPos = ComputeScreenPos(output.positionCS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    // half3 viewDirWS = distance ( GetCameraPositionWS() ,vertexInput.positionWS );
    // #if defined(_NORMALMAP)
        output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
        output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
        output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
    // #else
    //     output.normalWS = half3(NormalizeNormalPerVertex(normalInput.normalWS));
    // #endif

    return output;
}

half4 DepthNormalsFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
     half4 diffuseAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
     half alpha = diffuseAlpha.a * _BaseColor.a;

    // #if defined(_GBUFFER_NORMALS_OCT)
    //     float3 normalWS = normalize(input.normalWS);
    //     float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
    //     float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
    //     half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
    //     return half4(packedNormalWS, 0.0);
    // #else
    float2 uv = input.uv;

    // #if defined(_NORMALMAP)
        half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
        half3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz));
    // #else
    //     half3 normalWS = input.normalWS;
    // #endif

    normalWS = NormalizeNormalPerPixel(normalWS);

    float3 viewDir = float3(input.normalWS.a,input.tangentWS.a,input.bitangentWS.a);

    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
    #endif

    //거리에 따라 하프톤으로 사라지게 하는 기능
    #if defined(_NEARHALFTONECLIP_ON) && defined(_GLOBAL_NEARHALFTONECLIP_ON)
        //  거리에 따라 하프톤으로 사라지게 하는 기능
        float cameraDistance = distance(viewDir, 0);
        cameraDistance = cameraDistance *0.5 ;//사라지는 거리 조절하고 싶으면 여기에 곱셈하세요
        half halftoneAlpha;
        Unity_Dither_linear(cameraDistance, input.screenPos, halftoneAlpha);
        halftoneAlpha *= min(1, halftoneAlpha);
        clip (halftoneAlpha - _Cutoff );
    #endif

    // //레이케스트 되면 사라지는 기능 
    half RaycasthalftoneAlpha;
    float dist = distance((input.screenPos.xy/input.screenPos.w - 0.5),float2(0,0));
    dist = saturate(dist);
    dist = pow(dist,1.5);
    // dist = pow(dist,10);
    dist = saturate(dist);
    dist += 2 - (_RaycastHarftoneClip *2);
    Unity_Dither_linear(dist, input.screenPos, RaycasthalftoneAlpha);
    RaycasthalftoneAlpha = saturate(RaycasthalftoneAlpha);


    clip (RaycasthalftoneAlpha - _Cutoff);


    //LOD 디더링 기능
    float fadeValue;
    float lodFade;
    if(unity_LODFade.x != 0){
        if(unity_LODFade.x > 0){
        fadeValue = unity_LODFade.x ;	
        }
        else{
        fadeValue = 1 + unity_LODFade.x;
        }
        Unity_Dither_linear(fadeValue, input.screenPos, lodFade);
        clip(lodFade);
    }
    else{
        fadeValue = 1;
    } 
    
    return half4(normalWS, 0.0);
    // #endif
}

#endif
