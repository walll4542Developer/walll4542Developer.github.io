#ifndef BASE_PASS_INCLUDED
#define BASE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;

    float4 color : COLOR;

    //VECTOR_RIG_ATTRIBUTES(2, 3, 4, 5, 6)

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION; // Homogeneous clip space position
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    half2 diffuseTexcoord : TEXCOORD0;
    half2 shadeByNormalTexcoord : TEXCOORD1;
    float4 positionWS : TEXCOORD2;
    float3 normalWS : TEXCOORD3;
    float4 positionOS : TEXCOORD4;
    float fogCoord : TEXCOORD5; // x: fogFactor

    float4 shadowCoord: TEXCOORD6;

    float4 color : COLOR;

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

TEXTURE2D(_MaskTex);
SAMPLER(sampler_MaskTex);

TEXTURE2D(_BumpTex);
SAMPLER(sampler_BumpTex);

TEXTURE2D(_ToonShade);
SAMPLER(sampler_ToonShade);

TEXTURE2D(_RampTex);
SAMPLER(sampler_RampTex);

half4 _MainTex_ST;
half4 _MaskTex_ST;

real4 _Color;
real4 _SpecColor;
real _Min;
real _Max;
real _Softness;
real _Lerp;
real _SpecularRange;
real _Pow;
real _Glossiness;

real _NormalStrength;

real _Flatness;
real _ReceiveShadowStrength;

#ifndef _TRANSPARENCY
    half _CutoutThreshold;
#endif

float2 ComputeScreenUV(float4 Pos, float2 Texel)
{
    float2 uv = float2(Pos.xy / Pos.w + 0.000000001);
    uv *= _ScreenParams.xy * Texel;
    return uv;
}

half InitializeShadowcoordData(Varyings input, float _ReceiveShadowStrength)
{
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        input.shadowCoord = TransformWorldToShadowCoord(input.positionWS.xyz);
    #else
        input.shadowCoord = float4(1, 1, 1, 0);
    #endif

    Light mainLight = GetMainLight(input.shadowCoord);
    half shadowAtten = saturate(mainLight.shadowAttenuation + (1- _ReceiveShadowStrength)); //_ReceiveShadowStrength

    return shadowAtten;
}

// 메테리얼단위로 리시브 셰도우 옵션이 적용
// 

Varyings vert(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    //VECTOR_RIG_DEFORM(input, input.positionOS, input.normalOS, input.texcoord)

    //VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    output.positionWS.xyz = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.positionOS = input.positionOS;
    output.normalOS = input.normalOS;
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentOS = input.tangentOS;
    output.color = input.color;

    output.diffuseTexcoord = TRANSFORM_TEX(input.texcoord, _MainTex);
    
    half3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, normalize(input.normalOS));
    viewNormal = normalize(viewNormal) * half3(0.5, 0.5, 0.5) + half3(0.5, 0.5, 0.5);
    output.shadeByNormalTexcoord = viewNormal.xy;

    output.fogCoord.x = ComputeFogFactor(output.positionCS.z);

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = TransformWorldToShadowCoord(output.positionWS.xyz);
    #endif

    return output;
}

float4 frag(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 resultColor;


    //Albedo Texture
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.diffuseTexcoord);
    #ifndef _TRANSPARENCY
        if (mainTex.a < _CutoutThreshold) discard;
    #endif
    resultColor = mainTex;

    //Normal Texture
    float3 normalWS;
    float3 bumpTex = UnpackNormal(SAMPLE_TEXTURE2D(_BumpTex, sampler_BumpTex, input.diffuseTexcoord));
    bumpTex.rg = saturate(bumpTex.rg * _NormalStrength);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    float3x3 transposeTBN = transpose(float3x3(normalInputs.tangentWS, normalInputs.bitangentWS, normalInputs.normalWS));
    normalWS = normalize(mul(transposeTBN, bumpTex));

    //SDF

    //Half-Lambert
    float nDotL = dot(normalize(normalWS), _MainLightPosition.xyz);
    float halfLambert = saturate(nDotL * 0.5 + 0.5);

    //Receive Shadow
    half shadowAtten = InitializeShadowcoordData(input, _ReceiveShadowStrength);
    #if !defined(_RECEIVE_SHADOWS_OFF)
        #if _RECEIVESHADOW_ON
        halfLambert *= shadowAtten;
        #endif
    #endif

    //Threshold Texture
    float4 maskTex = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.diffuseTexcoord);
    float thresholdTex = step(1 - maskTex.g, halfLambert);

    //Ramp Texture
    float4 rampTex;
    #ifdef _SHADOWMODE_VERTEX
        _Softness = input.color.r;
        rampTex = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, _Softness));
        resultColor.rgb = lerp(resultColor.rgb * _Color.rgb, resultColor.rgb, saturate(rampTex.r * (2 * maskTex.g)));
        #else
            _Softness *= 0.5;
            rampTex = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(halfLambert, 1));
            resultColor.rgb = lerp(resultColor.rgb * _Color.rgb, resultColor.rgb, saturate(smoothstep(_Softness, 1-_Softness, rampTex.r) * (2 * maskTex.g)));
    #endif
    //resultColor.rgb = lerp(resultColor.rgb * _Color.rgb, resultColor.rgb, thresholdTex);
    
    //Fresnel
    float3 viewDirWS = normalize(GetCameraPositionWS() - input.positionWS.xyz);
    float nDotV = saturate(dot(normalize(normalWS), viewDirWS));
    
    //Specular
    float3 reflectionVector = normalize(2 * dot(_MainLightPosition.xyz, normalize(normalWS) ) * normalize(normalWS) - _MainLightPosition.xyz);
    //reflectionVector = reflect(_MainLightPosition.xyz, normalize(normalWS));
    float rDotV = dot(reflectionVector, viewDirWS);
    rDotV = saturate(rDotV);
    rDotV = pow(rDotV, _SpecularRange);

    float3 cubeReflectionVector = reflect(-viewDirWS, normalWS);
    float3 reflectionProbe = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, cubeReflectionVector, (1 - _Glossiness) * 3), unity_SpecCube0_HDR);

    #ifdef _SPECULARMODE_PHONG
        rDotV = ceil(rDotV);
        resultColor.rgb = lerp(resultColor.rgb, _SpecColor.rgb, rDotV * maskTex.b);
        #elif _SPECULARMODE_RIM
            resultColor.rgb = lerp(resultColor.rgb, _SpecColor, pow(nDotV, _Pow) * maskTex.b);
        #elif _SPECULARMODE_CUBEMAP
            resultColor.rgb = lerp(resultColor.rgb, reflectionProbe * _SpecColor, rDotV * maskTex.b);
    #endif

    //flat
    float flat = saturate( (input.positionOS.z + _Flatness - 1) / _Flatness);

    //fog
    MixFog(resultColor.rgb, input.fogCoord);

    //resultColor.rgb = input.color.rgb;

    resultColor.a = 1;

    return resultColor;
}

#endif // BASE_PASS_INCLUDED
