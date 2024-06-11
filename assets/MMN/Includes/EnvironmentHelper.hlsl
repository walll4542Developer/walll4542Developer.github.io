#ifndef MMN_NOISE_HEIGHTFOG_INCLUDED
#define MMN_NOISE_HEIGHTFOG_INCLUDED


#include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/WeatherControlHolder.hlsl"

float4 _Global_SkyColorTop;
float4 _Global_SkyColorMiddle;
float4 _Global_SkyColorBottom;

float _Global_FogHeightOffset;
float _Global_FogHeightScale;
float _Global_FogHeightNoiseValue;
float _Global_FogHeightNoiseSpeed;
float _Global_FogHeightNoiseScale;
float _Global_DimFog_Range; //300이 초기값;
float _Global_DimFog_Power; //0.5가 초기값;


TEXTURE2D(_Dither_Tex);        SAMPLER(sampler_Dither_Tex);



/////////////////////////////////////////////////////////////////////////////////
//                랜덤과 노이즈 함수  - 현재 쓰는 곳은 없음                       //
/////////////////////////////////////////////////////////////////////////////////

inline float unity_noise_randomValue(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float unity_noise_interpolate(float a, float b, float t)
{
    return (1.0 - t) * a + (t * b);
}

inline float unity_valueNoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = unity_noise_randomValue(c0);
    float r1 = unity_noise_randomValue(c1);
    float r2 = unity_noise_randomValue(c2);
    float r3 = unity_noise_randomValue(c3);

    float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
    float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
    float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}


void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
{
    float t = 0.0;

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    Out = t;
}

/////////////////////////////////////////////////////////////////////////////////
//                                가시성 관련 함수들                            //
/////////////////////////////////////////////////////////////////////////////////


// //디더링 셰이더함수 . 셰이더 그래프에서 이식. 4*4 로 색을 돌아가며 칠해주어 패턴을 만든다
// //배열이 갤럭시 20에서 비정상적으로 느려지는 현상이 발견되어 const로 바꾸었습니다.
// //유의미한 차이가 보이지 않아서 일단 봉인합니다.
// void Unity_Dither_float(float In, float4 ScreenPosition, out float Out)
// {
//     float2 uv = (ScreenPosition.xy / ScreenPosition.w) * _ScaledScreenParams.xy;
//     //스타일을 좀 바꿨습니다. 가장 낮은 단계의 디더링은 오래 살아 남아 있도록.
//     //몬헌에서의 가시성이 이런 스타일이길래 따라해 봤습니다.
//     const float DITHER_THRESHOLDS[16] = {
//         1.0 / 17.0, 15.0 / 17.0, 3.0 / 17.0, 15.0 / 17.0,
//         13.0 / 17.0, 6.0 / 17.0, 15.0 / 17.0, 6.0 / 17.0,
//         4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 15.0 / 17.0,
//         16.0 / 17.0, 6.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
//     };
//     uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
//     Out = In - DITHER_THRESHOLDS[index];
// }

// // 디더링 패턴 배열이 갤럭시 20에서 비정상적으로 느려지는 현상때문에 글로벌 텍스쳐 샘플링으로 만든 버전
// // 그렇지만 위 2개의 배열에 const를 사용하면서 문제가 해결되어 이 함수는 사용되지 않은 예정입니다.
// void Dither_Tex(float In, float4 ScreenPosition, out float Out)
// {
//     float2 uv = (ScreenPosition.xy / ScreenPosition.w);
//     uv = frac(uv * _ScaledScreenParams.xy/4);
//     float4 ditherTexture = SAMPLE_TEXTURE2D(_Dither_Tex, sampler_Dither_Tex,uv);
//     uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
//     Out = In - ditherTexture.r;
// }

//리니어한 비율로 사라지는 디더링 패턴입니다.
//배열이 갤럭시 20에서 비정상적으로 느려지는 현상이 발견되어 const로 바꾸었습니다.

//Offset은 얼마나 더 빨리 나타날(사라질) 것이냐를 결정
void Unity_Dither_linear(float In, float4 ScreenPosition, out float Out)
{
    float2 uv = (ScreenPosition.xy / ScreenPosition.w) * _ScaledScreenParams.xy;
    const float DITHER_THRESHOLDS[16] = {
        1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
    };


    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In - DITHER_THRESHOLDS[index];
}



//Offset은 얼마나 더 빨리 나타날(사라질) 것이냐를 결정. 이것은 LOD에서 사용됩니다.
void Unity_Dither_linear(float In, float4 ScreenPosition, out float Out, float offset)
{
    float2 uv = (ScreenPosition.xy / ScreenPosition.w) * _ScaledScreenParams.xy;
    const float DITHER_THRESHOLDS[16] = {
        1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0
    };


    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    Out = In + offset -pow(DITHER_THRESHOLDS[index], 0.25)  ;
}



//니어 하프톤 알파 테스팅. 가까워지면 사라집니다.
void NearHarftoneAlphaTesting(float cameraDistance, float4 screenPos, float distanceBias, out float halftoneAlpha)
{
    cameraDistance = cameraDistance * distanceBias;//사라지는 거리 조절하고 싶으면 이걸 조절하세요 기본값은 0.5
    cameraDistance = pow(cameraDistance, 3) ;
    halftoneAlpha = 1;
    Unity_Dither_linear(cameraDistance, screenPos, halftoneAlpha);
    halftoneAlpha *= min(1, halftoneAlpha);
    halftoneAlpha -= saturate(0.5 - unity_OrthoParams.w); //orth에서는 작동안되게 만들어 줍니다. 송지훈 팀장님 감사

}

//레이케스팅 되면 알파 테스팅으로 오브젝트가 사라지는 함수
float RaycastingHalftoneAlpha(float4 InputscreenUV, float4 InputScreenPos, float raycastHarftoneClip)
{
    float RaycasthalftoneAlpha;
    float2 screenUV = InputscreenUV.xy / InputscreenUV.w;
    screenUV -= 0.5;
    if (_ScaledScreenParams.y > _ScaledScreenParams.x)
    {
        screenUV.y *= _ScaledScreenParams.y / _ScaledScreenParams.x; //타원이 아닌, 가로의 크기에 따른 원을 그리기 위해

    }
    else
    {
        screenUV.x *= _ScaledScreenParams.x / _ScaledScreenParams.y; //타원이 아닌, 가로의 크기에 따른 원을 그리기 위해

    }

    screenUV.xy *= 1.5; //1 이상 곱해주면 원이 작아집니다.
    float dist = distance(screenUV.xy, float2(0, 0));
    dist = pow(dist, 4); // 두께를 줄여줍니다
    dist *= (1 - (InputscreenUV.y * InputscreenUV.y)); //절반이상의 상부를 모두 날려버립니다.
    dist = saturate(dist);
    dist += 1.5 - (raycastHarftoneClip * 1.5); //범위를 확장하면 평소에 조금씩 뚫리는걸 막을 수 있습니다.
    Unity_Dither_linear(dist, InputScreenPos, RaycasthalftoneAlpha);
    return RaycasthalftoneAlpha = saturate(RaycasthalftoneAlpha);
}

//레이케스팅 되면 사라지는 함수 알파 블렌딩 버전
float RaycastingHalftoneAlphaBlend(float4 InputscreenUV, float4 InputScreenPos, float raycastHarftoneClip, float raycastMinimumAlpha)
{
    // float2 screenUV = InputscreenUV.xy / InputscreenUV.w;
    // screenUV -= 0.5;
    // if (_ScaledScreenParams.y > _ScaledScreenParams.x)
    // {
    //     screenUV.y *= _ScaledScreenParams.y / _ScaledScreenParams.x; //타원이 아닌, 가로의 크기에 따른 원을 그리기 위해

    // }
    // else
    // {
    //     screenUV.x *= _ScaledScreenParams.x / _ScaledScreenParams.y; //타원이 아닌, 가로의 크기에 따른 원을 그리기 위해

    // }

    // screenUV.xy *= 1.5; //1 이상 곱해주면 원이 작아집니다.
    // float dist = distance(screenUV.xy, float2(0, 0));
    // dist = pow(dist, 4); // 두께를 줄여줍니다
    // dist += (1 - (InputscreenUV.y * InputscreenUV.y)); //절반이상의 상부를 모두 날려버립니다.
    // dist = saturate(dist);
    // dist += 1.5 - (raycastHarftoneClip * 1.5); //범위를 확장하면 평소에 조금씩 뚫리는걸 막을 수 있습니다.
    // dist *= (1 - (InputscreenUV.y * InputscreenUV.y)); //절반이상의 상부를 모두 날려버립니다.

    float dist = lerp(1, 0, raycastHarftoneClip); // 원형 마스킹을 제거했습니다.
    dist = max(raycastMinimumAlpha, dist); // 알파의 최솟값을 결정합니다.

    return dist;
}


/////////////////////////////////////////////////////////////////////////////////
//                                커스텀 포그 관련 함수들                       //
/////////////////////////////////////////////////////////////////////////////////

//심플노이즈 연산을 통한 하이트포그 . 현재 봉인중
// inline float4 MMN_SimpleNoise_HeightFog
// (float4 color,
// float3 positionWS,
// float4 fogCoord,
// float _Global_FogHeightOffset,
// float _Global_FogHeightScale,
// float _Global_FogHeightNoiseValue,
// float _Global_FogHeightNoiseSpeed,
// float _Global_FogHeightNoiseScale)
// {
//     float noisevalue;
//     float3 withFogColor;
//     Unity_SimpleNoise_float(positionWS.xz + _Time.y * _Global_FogHeightNoiseSpeed , _Global_FogHeightNoiseScale, noisevalue);
//     //y is height
//     float y = saturate(positionWS.y/100 - _Global_FogHeightOffset - noisevalue* _Global_FogHeightNoiseValue);
//     float fogHeightBottom = saturate(y * _Global_FogHeightScale);
//     float fogHeightTop = saturate(-y * _Global_FogHeightScale);
//     float fogHeight = max(fogHeightBottom, fogHeightTop);
//     withFogColor = MixFog(color.rgb, fogCoord.r);
//     //float cloudShadow  = saturate(1- fogCoord.r +noisevalue); //구름 그림자가 거리가 멀어지면 안보이게 합니다
//     color.rgb = lerp(withFogColor,color.rgb  ,fogHeight);
//     return color ;
// }

//remap 함수
float Remap_float(float In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

float3 MM_Lerp(float3 a, float3 b, float t)
{
    return (a * (1.0 - t)) + (b * t);
}

//커스텀 Add 포그 함수
float3 MM_AddFogColor(float3 fragColor, float3 fogColor, float fogFactor)
{
    #if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
        float fogIntensity = ComputeFogIntensity(fogFactor);
        float3 addFogColor = (fogColor + fragColor);
        fragColor = lerp(fragColor, addFogColor, (1.0 - fogIntensity));//add
    #endif
    return fragColor;
}

//ADD 포그와 일반 FOG를 FOG 칼라에 따라 믹스합니다.
float3 MM_MixFog(float3 fragColor, float fogFactor)
{
    float3 normalFogColor = MixFogColor(fragColor, unity_FogColor.rgb, fogFactor);
    float3 addFogColor = MM_AddFogColor(fragColor, unity_FogColor.rgb, fogFactor);
    float lerpFogfactor = (unity_FogColor.r + unity_FogColor.g + unity_FogColor.b) / 3 ;

    //30%~60% 색상을 지나면 ADD 연산 포그가 된다.
    float lerpFogfactor1 = Remap_float(lerpFogfactor, float2(0.3, 0.6), float2(0, 1));
    lerpFogfactor1 = saturate(lerpFogfactor1);
    float3 finalFogColor = lerp(normalFogColor, addFogColor, lerpFogfactor1);

    //다시 90%~100% 색상을 지나면 Normal 연산 포그가 된다.
    float lerpFogfactor2 = Remap_float(lerpFogfactor, float2(0.9, 1.0), float2(0, 1));
    lerpFogfactor2 = saturate(lerpFogfactor2);
    finalFogColor = lerp(finalFogColor, normalFogColor, lerpFogfactor2);

    return finalFogColor;
}

//ADD 포그와 일반 FOG를 FOG 칼라에 따라 믹스합니다.
float3 MM_MixFogColor(float3 fragColor, float3 fogColor, float fogFactor)
{
    float3 normalFogColor = MixFogColor(fragColor, fogColor.rgb, fogFactor);
    float3 addFogColor = MM_AddFogColor(fragColor, fogColor.rgb, fogFactor);
    float lerpFogfactor = (unity_FogColor.r + unity_FogColor.g + unity_FogColor.b) / 3 ;

    //30%~60% 색상을 지나면 ADD 연산 포그가 된다.
    float lerpFogfactor1 = Remap_float(lerpFogfactor, float2(0.3, 0.6), float2(0, 1));
    lerpFogfactor1 = saturate(lerpFogfactor1);
    float3 finalFogColor = lerp(normalFogColor, addFogColor, lerpFogfactor1);

    //다시 90%~100% 색상을 지나면 Normal 연산 포그가 된다.
    float lerpFogfactor2 = Remap_float(lerpFogfactor, float2(0.9, 1.0), float2(0, 1));
    lerpFogfactor2 = saturate(lerpFogfactor2);
    finalFogColor = lerp(finalFogColor, normalFogColor, lerpFogfactor2);

    return finalFogColor;
}


//ADD 포그와 일반 FOG를 FOG 칼라에 따라 믹스합니다.
//Multi 이펙트일때는 이걸 써야 한다
float3 MM_MixFogColorMulti(float3 fragColor, float3 fogColor, float fogFactor)
{
    float3 normalFogColor = MixFogColor(fragColor, fogColor.rgb, fogFactor);
    float3 addFogColor = MixFogColor(fragColor, fogColor.rgb, fogFactor);
    float lerpFogfactor = (unity_FogColor.r + unity_FogColor.g + unity_FogColor.b) / 3 ;

    //30%~60% 색상을 지나면 ADD 연산 포그가 된다.
    float lerpFogfactor1 = Remap_float(lerpFogfactor, float2(0.3, 0.6), float2(0, 1));
    lerpFogfactor1 = saturate(lerpFogfactor1);
    float3 finalFogColor = lerp(normalFogColor, addFogColor, lerpFogfactor1);

    //다시 90%~100% 색상을 지나면 Normal 연산 포그가 된다.
    float lerpFogfactor2 = Remap_float(lerpFogfactor, float2(0.9, 1.0), float2(0, 1));
    lerpFogfactor2 = saturate(lerpFogfactor2);
    finalFogColor = lerp(finalFogColor, normalFogColor, lerpFogfactor2);

    return finalFogColor;
}


//글로벌 텍스쳐를 통한 하이트포그 : 일반 블렌딩 버전
//UV는 나중에 지역 포그 색 변화에 쓸 때를 대비해서 받습니다.
inline float4 MMN_GlobalTex_HeightFog(
    float4 color,
    float3 positionWS,
    float3 normalWS,
    float4 fogCoord,
    float _Global_FogHeightOffset,
    float _Global_FogHeightScale,
    float _Global_FogHeightNoiseValue,
    float _Global_FogHeightNoiseSpeed,
    float _Global_FogHeightNoiseScale,
    float2 uv)
{
    float3 withFogColor;
    InitializeGlobalValue();
    float2 worldUV = positionWS.xz * _Global_FogHeightNoiseScale * 0.01 + _Global_WindUV * _Global_FogHeightNoiseSpeed * 0.01;
    float4 GlobalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV);

    // 최저사양에서 포그 처리
    #if defined(_GLOBAL_OPTION_VERY_LOW)

        float DimFogRange = 0;
        float3 diff = _Global_pos.rgb - positionWS;
        float diffRange = saturate(dot(diff, diff) / (_Global_DimFog_Range * _Global_DimFog_Range));
        diffRange = smoothstep(0.3, 1, diffRange);

        float DimFogLight = 1;
        DimFogRange = 1 - PositivePow(diffRange * DimFogLight, _Global_DimFog_Power);
        fogCoord.r = saturate(DimFogRange * fogCoord.r);

        //Final Fog Mixing
        withFogColor = MixFogColor(color.rgb, unity_FogColor.rgb, fogCoord.r);
        color.rgb = withFogColor;

    #else

        //y is height
        float y = saturate(positionWS.y / 100 - _Global_FogHeightOffset -GlobalTexture.r * _Global_FogHeightNoiseValue);
        float fogHeightBottom = saturate(y * _Global_FogHeightScale);
        float fogHeightTop = saturate(-y * _Global_FogHeightScale);
        float fogHeight = max(fogHeightBottom, fogHeightTop);

        // //딤포그 어레이 버전
        // // #if defined(_DIM_FOG_ON)
        //     float DimFogRange = 0;
        //     // #if defined (_DIM_FOG_ARRAY_ON)
        //     //     for(uint i = 0 ; i < 4; i++ )
        //     //     {
        //     //         float3 diff = _Global_pos[i].rgb - positionWS ;
        //     //         float diffRange = saturate(dot(diff, diff)/_Global_DimFog_Range); //올리면 멀어짐
        //     //         DimFogRange += 1-pow(diffRange,_Global_DimFog_Power);//올리면 경계가 날카로와짐
        //     //     }
        //     // #else
        //     float3 diff = _Global_pos.rgb - positionWS ;
        //     float diffRange = saturate(dot(diff, diff)/_Global_DimFog_Range); //올리면 멀어짐
        //     DimFogRange = 1-pow(diffRange,_Global_DimFog_Power);//올리면 경계가 날카로와짐
        //     // #endif
        //     fogCoord.r = saturate(DimFogRange * fogCoord.r);
        // // #endif


        //딤포그 단일 버전
        // _Global_DimFog_Range *= 0.8; // 이 값 조정은 볼륨에 저장된 값을 수정하지 않고 적용하려고 하는 것이다.
        // _Global_DimFog_Power *= 1.0;
        float DimFogRange = 0;
        float3 diff = _Global_pos.rgb - positionWS ;
        float diffRange = saturate(dot(diff, diff) / (_Global_DimFog_Range * _Global_DimFog_Range)); //올리면 멀어짐
        float DimFogLight = lerp(1.0, 0.75  *(1.0 - dot(normalize(_Global_pos.rgb - float3(0, -1, 0) - positionWS), normalWS)),0.5);
        DimFogLight = max(0.0, DimFogLight);
        DimFogRange = 1 - pow(diffRange * DimFogLight, _Global_DimFog_Power);//올리면 경계가 날카로와짐
        fogCoord.r = saturate(DimFogRange * fogCoord.r);

        //Final Fog Mixing
        withFogColor = MM_MixFog(color.rgb, fogCoord.r);
        color.rgb = lerp(withFogColor, color.rgb, fogHeight);
        // color.rgb = diffRange * DimFogLight;
        // color.rgb = saturate(DimFogRange * fogCoord.r);
        // color.rgb = diffRange * DimFogLight;

    #endif

    return color;
}

///////////////////////////////////////////////////////////////////////////////
//                      Rain Drop Functions                                 //
///////////////////////////////////////////////////////////////////////////////


float MMN_GlobalTex_RaindropCalc(float3 positionWS, float3 normalWS, float timing)
{
    float2 worldUV = positionWS.xz * 0.35 ;
    float4 GlobalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV);

    float GlobalTextureBpow = pow(saturate(GlobalTexture.b), 0.45); //노이즈의 흰 부분을 넓힌다
    float4 GlobalTextureScroll = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, (worldUV.yx + GlobalTextureBpow * 0.2 + frac((_Time.x * 5) + timing)));
    //마스크와 베이스 텍스쳐가 같은 좌표라 반복 파동이 보여서 worldUV의 UV는 다르게 처리
    float rain = GlobalTextureScroll.b * GlobalTextureScroll.b * GlobalTexture.b * GlobalTexture.b  ;
    // GlobalTextureScroll.b 를 곱하면 거품이 약해지고 GlobalTexture.b 를 곱하면 크기가 작아집니다
    rain = step(0.25, rain);
    return normalWS.y * normalWS.y * rain;
}

//패턴을 보이지 않게 하기 위해서 섞음
float MMN_GlobalTex_Raindrop(float3 positionWS, float3 normalWS)
{
    float a = MMN_GlobalTex_RaindropCalc(positionWS * 0.7 , normalWS, 0);
    float b = MMN_GlobalTex_RaindropCalc(positionWS * 1.0 + float3(0.3, 0, 0.3), normalWS, 0.3);
    float c = MMN_GlobalTex_RaindropCalc(positionWS * 1.2 + float3(0.6, 0, 0.6), normalWS, 0.6);
    // return a;
    return a + b + c;
}
///////////////////////////////////////////////////////////////////////////////
//                      비로 젖은 재질 전환 함수                               //
///////////////////////////////////////////////////////////////////////////////

float3 wetTextureLerp(float3 positionWS, float3 dryColor, float3 wetColor)
{
    float3 color;
    float2 worldUV = positionWS.xz ;
    float4 GlobalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.02);
    float wetness = smoothstep(GlobalTexture.r, GlobalTexture.r + 0.3, _Global_Raining);

    color = lerp(dryColor, wetColor, wetness);
    return color;
}

///////////////////////////////////////////////////////////////////////////////
//                      눈 전환 함수들                                        //
///////////////////////////////////////////////////////////////////////////////


float3 snowTextureLerp(float3 positionWS, float3 dryColor, float3 normalWS, float3 bakedGI)
{
    float3 color;
    float2 worldUV = positionWS.xz ;
    float4 globalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.015);
    float4 snowTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.1);

    float wetness = globalTexture.r * snowTexture.r + pow(globalTexture.r, 5);
    wetness = saturate(wetness);
    wetness = step((1 - _Global_Snow) + 0.1, wetness);

    float3 snowColor = lerp(snowTexture.aaa, dryColor, 0.1) ;
    float normalY = saturate(normalWS.y);

    color = lerp(dryColor, snowColor, saturate(wetness * step(0.4, normalY)));
    color = lerp(dryColor, color, step(0.7, bakedGI).r);
    return color;
}

float3 snowTextureOnly(float3 positionWS, float3 dryColor, float3 normalWS)
{
    float3 color;
    float2 worldUV = positionWS.xz ;
    float4 snowTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.1);

    float wetness = snowTexture.r ;
    wetness = step((1 - _Global_Snow), wetness);

    float3 snowColor = lerp(snowTexture.aaa, dryColor, 0.1) ;
    float normalY = saturate(normalWS.y);

    color = lerp(dryColor, snowColor, saturate(wetness * step(0.4, normalY)));
    return color;
}

float3 snowTextureLerpTerrain(float3 positionWS, float3 dryColor, float3 normalWS, float3 bakedGI, float4 control, float4 snowMask)
{
    float3 color;
    float2 worldUV = positionWS.xz ;
    float4 globalTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.015);
    float4 snowTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.1);

    control = 1 - control;
    snowMask = 1 - snowMask;
    float4 snowControlMask = saturate(control + snowMask);

    float wetness = globalTexture.r * snowTexture.r + pow(globalTexture.r, 2);
    wetness = saturate(wetness) * snowControlMask.r * snowControlMask.g * snowControlMask.b * snowControlMask.a;
    wetness = step((1 - _Global_Snow) + 0.2, wetness);

    float3 snowColor = lerp(snowTexture.aaa, dryColor, 0.1) ;
    float normalY = saturate(normalWS.y);

    color = lerp(dryColor, snowColor, saturate(wetness * step(0.4, normalY)));
    color = lerp(dryColor, color, step(0.7, bakedGI).r);
    return color;
}


void snowTreeTextureLerp(float3 positionWS, inout float3 diffuseColor, float3 normalWS, inout float snowMask)
{
    float2 worldUV = positionWS.xz ;
    float4 snowTexture = SAMPLE_TEXTURE2D(_Global_Texture, sampler_Global_Texture, worldUV * 0.1);
    float3 snowColor = lerp(snowTexture.aaa, diffuseColor, 0.1) ;
    float normalY = saturate(normalWS.y);
    snowMask = saturate(step(1 - _Global_Snow + 0.15, normalY));
    diffuseColor = lerp(diffuseColor, snowColor, snowMask);
}


#endif
