#ifndef UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
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
    // float2 dynamicLightmapUV : TEXCOORD2; //리얼타임 라이트맵 안씁니다!
    float4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;

    float3 positionWS : TEXCOORD1;    // xyz: posWS


    // #ifdef _NORMALMAP
    // half4 normalWS : TEXCOORD2;    // xyz: normal, w: viewDir.x
    // half4 tangentWS : TEXCOORD3;    // xyz: tangent, w: viewDir.y
    // half4 bitangentWS : TEXCOORD4;    // xyz: bitangent, w: viewDir.z
    // #else
        half3 normalWS : TEXCOORD2;
    // #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight : TEXCOORD5; // x: fogFactor, yzw: vertex light
    #else
        half fogFactor : TEXCOORD5;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD6;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 7);

    // #ifdef DYNAMICLIGHTMAP_ON
    //     float2  dynamicLightmapUV : TEXCOORD8; // Dynamic lightmap UVs //리얼타임 라이트맵 안씁니다
    // #endif

    float4 screenPos : TEXCOORD8;
    float cameraDistance : TEXCOORD9; //이걸 나중에 positionWS 의 알파로 빼는걸 생각해 봅시다.
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, float3 normalTS, out InputData inputData)
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

    inputData.normalWS = normalize(inputData.normalWS);
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

    // #if defined(DYNAMICLIGHTMAP_ON) //리얼타임 라이트맵 사용금지합니다.
    //     inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
    // #else
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    // #endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

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

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    //원본 버텍스 포지션 변환 함수
    //VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    //아래 개조된 버전. 함수 오버라이드로 되어 있음. 카메라 바라보는 각도에 따라 버텍스 휘어짐
    VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
    
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    // output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv = input.texcoord;
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

    // #ifdef _NORMALMAP
    // half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    // output.normalWS = half4(normalInput.normalWS, viewDirWS.x);
    // output.tangentWS = half4(normalInput.tangentWS, viewDirWS.y);
    // output.bitangentWS = half4(normalInput.bitangentWS, viewDirWS.z);
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
float4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.uv;
    float4 diffuseAlpha = SampleAlbedoAlpha(TRANSFORM_TEX(uv, _BaseMap), TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half3 diffuse = diffuseAlpha.rgb;
    half alpha = diffuseAlpha.a * _BaseColor.a;

    //임시로 두 번째 텍스쳐가 버텍스 알파로 동작하게 만듭니다.
    // float4 diffuse2 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, TRANSFORM_TEX(uv, _BaseMap2));
    // float t2 = 1 - input.color.a;
    // t2 = pow(saturate(t2), _BaseMap2BlendWeight);
    // // t2 = saturate(step(0.5, t2 ));
    // diffuse = lerp(diffuse, diffuse2.rgb, t2);


    //알파 테스트 기능
    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
    #endif

    //거리에 따라 하프톤으로 사라지게 하는 기능
    #if defined(_NEARHALFTONECLIP_ON)
        half halftoneAlpha = 1;
        NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
        clip(halftoneAlpha);
    #endif

    //레이케스트 되면 사라지는 기능
    half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
    clip(RaycasthalftoneAlpha - 0.1);


    //노말과 디테일 노말 섞기
    // float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, TRANSFORM_TEX(uv, _BumpMap)));
    // float4 detailN = SAMPLE_TEXTURE2D(_DetailBumpMap, sampler_DetailBumpMap, TRANSFORM_TEX(uv, _DetailBumpMap));
    // float3 detailnormalTS = UnpackNormal(detailN) * float3(_DetailBumpScale.xx, 1);
    // normalTS = normalize(float3(normalTS.rg + detailnormalTS.rg, normalTS.b * detailnormalTS.b));


    //텍스쳐 연산
    float3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    float4 specular = _SpecColor * diffuseAlpha.a;
    float smoothness = _Glossiness ;

    InputData inputData;
    InitializeInputData(input, /* normalTS */float3(0, 0, 1), inputData);
    SETUP_DEBUG_TEXTURE_DATA(inputData, input.uv, _BaseMap);
    
    //디테일 맵 섞기
    float3 posWS4Detail = input.positionWS * 0.1;
    float4 detailXY = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.xy, _DetailMap));
    float4 detailZY = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.zy, _DetailMap));
    float4 detailXZ = SAMPLE_TEXTURE2D(_DetailMap, sampler_DetailMap, TRANSFORM_TEX(posWS4Detail.xz, _DetailMap));
    float4 detailMap = lerp(detailXY, detailZY, abs(inputData.normalWS.r));
    detailMap = lerp(detailMap, detailXZ, abs(inputData.normalWS.g) * _DetailMapYenable);
    diffuse = lerp(diffuse, detailMap.rgb, detailMap.a);

    //버텍스 칼라는 첫 번째 맵에만 적용
    diffuse *= saturate(input.color.rgb + (1 - _VertexColorWeight));

    //버텍스 칼라만 임시로 보는 기능
    #ifdef _SHOWVERTEXCOLOR_ON
        return float4(saturate(abs(input.color.rgb)), 1);
    #endif


    //세컨드 텍스쳐를 노말 Y 방향으로 더할 때 활성화. 따로 인클루드로 뺄까도 생각해 봤지만 여기에서밖에 안쓰이므로 일단 존재
    #if _SECONDMAP_ON
        // 세컨드 텍스쳐 사용
        float secondTextureMask = 0;
        float vertexAlphaMask = 0;

        secondTextureMask = saturate(inputData.normalWS.y - _SecondMapOffset) ;
        secondTextureMask = pow(secondTextureMask, _SecondMapScale);
        //float sp = saturate(step(0.5, t * secondMap.a + t));

        vertexAlphaMask = 1 - input.color.a;
        secondTextureMask += pow(saturate(vertexAlphaMask), _SecondMapScale);

        // 세컨드 텍스쳐를 구해서 연산한다
        // float4 secondMap = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(uv, _SecondMap));
        float4 secondMapXY = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.xy, _SecondMap));
        float4 secondMapZY = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.zy, _SecondMap));
        float4 secondMapXZ = SAMPLE_TEXTURE2D(_SecondMap, sampler_SecondMap, TRANSFORM_TEX(posWS4Detail.xz, _SecondMap));
        float4 secondMap = lerp(secondMapXY, detailZY, abs(inputData.normalWS.r));
        secondMap = lerp(secondMap, secondMapXZ, abs(inputData.normalWS.g));

        float secondMapMask = saturate(smoothstep(_SecondMapBlendHardness, 1 - _SecondMapBlendHardness, secondTextureMask + secondTextureMask));
        diffuse.rgb = lerp(diffuse.rgb, secondMap.rgb, secondMapMask);

        //스페큘러가 2nd 텍스쳐에서는 고정되게
        alpha = lerp(alpha, secondMap.a, secondMapMask);
    #endif
    
    //전역적으로 틴트칼라 적용하기
    float3 tintProp = _BaseColor.rgb;
    float tintStrengthProp = _AlbedoTintStrength;
    diffuse = TextureTintBlend(diffuse.rgb, tintProp, tintStrengthProp);

    //리플렉션 프로브. 스페큘러 마스킹으로 마스킹된다
    float3 reflectionProbe = LightingReflectionProbe(inputData.viewDirectionWS, inputData.normalWS, _Glossiness);
    emission += reflectionProbe * alpha * _SpecColor.rgb * _Global_GILightMulti.rgb;
    
    //LOD 디더링 기능
    float fadeValue;
    float lodFade;
    if (unity_LODFade.x != 0)
    {
        if (unity_LODFade.x > 0)
        {
            fadeValue = clamp(unity_LODFade.x + unity_LODFade.x, 0, 1) ; //나타날때 빠르게 나타나게 한다
        }
        else
        {
            fadeValue = saturate(1.5 + unity_LODFade.x); //사라질때 1.5만큼 더 늦게 사라지게 한다 
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

    //라이팅 연산
    half4 color = 0;

    //Half Subtractive
    #if HALF_SUBTRACTIVE_LIGHTMAP_ON
        color = UniversalFragmentLightCustomBaked(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */ half3(0, 0, 1), /*shadowDimming*/ 0, _RampY, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);
    #else
        color = UniversalFragmentLightCustom(inputData, diffuse, specular, smoothness, emission, alpha, /* normalTS */float3(0, 0, 1), /*shadowDimming*/0, _RampY, /* _BackfaceReceiveShadowOff */0, /* FRONT_FACE_TYPE isFacing */0.0, /* float _BackFaceNormalturn */0.0);
    #endif


    //레인텍스쳐와 레인 드롭 애니메이션
    half3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color_Rain += MMN_GlobalTex_Raindrop(input.positionWS.rgb, input.normalWS.rgb) * step(0.85, inputData.bakedGI).r * color_Rain;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);
    

    //리플렉션 프로브
    float3 reflectionProbe2 = LightingReflectionProbe(inputData.viewDirectionWS, inputData.normalWS, _Glossiness);
    color.rgb += reflectionProbe2 * alpha * _SpecColor.rgb * _Global_GILightMulti.rgb;

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
