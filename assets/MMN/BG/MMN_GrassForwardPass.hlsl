#ifndef MMN_GRASS_FORWARDLIT_PASS_INCLUDED
#define MMN_GRASS_FORWARDLIT_PASS_INCLUDED

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
    float4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1; // xyz: positionWS
    float3 normalWS : TEXCOORD2;
    float3 viewDir : TEXCOORD3;

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight : TEXCOORD4; // x: fogFactor, yzw: vertex light
    #else
        half fogFactor : TEXCOORD4;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        float4 shadowCoord : TEXCOORD5;
    #endif

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 6); //SH 연산은 받을 필요 있음

    float4 screenPos : TEXCOORD7;
    float cameraDistance : TEXCOORD8;
    float4 color : COLOR;
    float4 positionCS : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO

};

void InitializeInputData(Varyings input, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    inputData.normalWS = NormalizeNormalPerPixel(input.normalWS);
    inputData.viewDirectionWS = SafeNormalize(input.viewDir);

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

    // inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    inputData.bakedGI = input.vertexSH;
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
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, input.color, _WindMultiply, _WindSpeedMultiply, _GrassPushPower, /* _VertexAniOn */ 1);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.viewDir = GetWorldSpaceViewDir(vertexInput.positionWS);

    output.color = input.color;
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);

    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = MM_VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
    #else
        output.fogFactor = fogFactor;
    #endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput); //값없음
    #endif

    return output;
}


// Used for StandardSimpleLighting shader
float4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    // BatchingConfig.DEFAULT_LOD_FADE_DISTANCE와 수치를 맞춰야합니다.
    // MonoBehaviour Script에서 내 캐릭터의 정확한 좌표를 현재 참조할 수가 없어서,
    // 수치를 조절해 대략적으로 맞춘 상태입니다.
    // 2022.07.14 박대명
    float toPlayerDistance = length(_Global_pos.xyz - input.positionWS.xyz);
    if (toPlayerDistance > _CullDistance)
    {
        discard;
    }

    //글로벌 텍스쳐
    InitializeGlobalValue();
    float4 globalGrassTex = SAMPLE_TEXTURE2D(_Global_Grass_Texture, sampler_Global_Grass_Texture, input.positionWS.xz * 0.01 * _Global_Grass_TextureSP.rg + _Global_Grass_TextureSP.ba + (_Time.x * _Global_WindUV * 0.01 * _TextureBlendingScroll));
    
    //글로벌 텍스쳐 미리보기 기능 가동
    #ifdef _SHOWGLOBALTEXTURE_ON
        return globalGrassTex;
    #endif
    
    // 텍스쳐
    float2 uv = input.uv;
    float4 diffuseAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

    // 탑칼라는 글로벌 텍스쳐의 영향을 받음 // 디퓨즈 텍스쳐도 걍 곱함
    float3 tintProp = globalGrassTex.rgb;
    float3 topColor = TextureTintBlend(_TopColor.rgb, tintProp, /*tintStrengthProp*/0.5)  ;
    topColor = lerp(_TopColor.rgb, topColor, _GlobalTextureBlending);

    // 조합해서 풀 기본 색상 결정
    float3 diffuse = diffuseAlpha.rgb * _BaseColor.rgb;
    diffuse = saturate(lerp(diffuse, topColor, input.color.g));
    

    float alpha = diffuseAlpha.a * _BaseColor.a;
    clip(alpha - _Cutoff);
    alpha = 1;

    half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    float4 specular = _SpecColor * input.color.g ;
    float smoothness = _Glossiness ;

    InputData inputData;
    InitializeInputData(input, inputData);

    // #ifdef _DBUFFER
    // ApplyDecalToBaseColorAndNormal(input.positionCS, diffuse,  inputData.normalWS);
    // #endif

    #if defined(_NEARHALFTONECLIP_ON)&&(_GLOBAL_NEARHALFTONECLIP_ON)
        //거리에 따라 하프톤으로 사라지게 하는 기능. 니어클리핑
        half halftoneAlpha;
        NearHarftoneAlphaTesting(input.cameraDistance, input.screenPos, 0.5, halftoneAlpha);
        clip(halftoneAlpha);
    #endif

    //레이케스트 되면 사라지는 기능
    half RaycasthalftoneAlpha = RaycastingHalftoneAlpha(input.screenPos, input.screenPos, _RaycastHarftoneClip);
    clip(RaycasthalftoneAlpha - 0.1);

    inputData.bakedGI = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _InstancingColor).rgb;
    
    //눈내리는 텍스쳐 전환
    diffuse.rgb = snowTextureLerp(input.positionWS, diffuse.rgb, input.normalWS, inputData.bakedGI);
    
    //그림자 영역 밝기 조절이 들어간 오버라이드 라이팅 함수 . 
    float shadowDim = saturate(lerp( _ShadowDimming , 0 ,  _Global_Raining));//비가 오면 _ShadowDimming 을 효과없게 한다. 비가올때 풀이 도드라지기 때문 
    
    // inputData.bakedGI = pow( inputData.bakedGI,2);
    
    float4 color = UniversalFragmentLightCustom
    (
        inputData, 
        diffuse, 
        specular, 
        smoothness, 
        emission, 
        alpha, 
        /*normalTS*/ float3(0, 0, 1), 
        0, 
        /*RampY*/0.5, 
        /* _BackfaceReceiveShadowOff */0, 
        /* FRONT_FACE_TYPE isFacing */0.0, 
        /* float _BackFaceNormalturn */0.0
    );

    

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

    //비내리는 텍스쳐 전환
    float3 color_Rain = ((color.rgb * color.rgb) + color.rgb) / 2;
    color.rgb = wetTextureLerp(input.positionWS, color.rgb, color_Rain.rgb);

    //컨텍트 셰도우 연산
    color *= MMN_RecieveContactShadow(input.positionWS, inputData.shadowCoord);
    
    // ===============================================================================
    // ==                            Fog & CloudShadow Calc                         ==
    // ===============================================================================

    color = MMN_GlobalTex_HeightFog
    (
        color,
        input.positionWS, inputData.normalWS, inputData.fogCoord,
        _Global_FogHeightOffset,
        _Global_FogHeightScale,
        _Global_FogHeightNoiseValue,
        _Global_FogHeightNoiseSpeed,
        _Global_FogHeightNoiseScale,
        uv
    );


    return color;
}
#endif