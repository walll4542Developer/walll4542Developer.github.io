#ifndef MMN_FX_COMMON_OUTPUTS_INCLUDED
#define MMN_FX_COMMON_OUTPUTS_INCLUDED

#include "Assets/PatchableAssets/Shaders/MMN/Includes/BendingVertex.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/EnvironmentHelper.hlsl"
#include "Assets/PatchableAssets/Shaders/MMN/Includes/CustomLighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

void GetPositionCSForBending(out float4 positionCS, out float4 positionNDC, float3 positionOS)
{
    positionCS = float4(0, 0, 0, 0);
    float4 vertexbending = _Global_VertexPositionOffset;
    float cameraForwardDirMul = _Global_VertexPositionOffset.z;

    float3 positionWS = TransformObjectToWorld(positionOS);
    float3 positionVS = TransformWorldToView(positionWS);
    positionVS = vertexVendingByCamera(positionVS, vertexbending, cameraForwardDirMul);
    positionCS = TransformWViewToHClip(positionVS);

    positionNDC = float4(0, 0, 0, 0);
    float4 ndc = positionCS * 0.5f;
    positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    positionNDC.zw = positionCS.zw;
}

half3 CalculateVertexSH(float4 vertexUV, float3 normalOS, float4 tangentOS)
{
    VertexNormalInputs normalInput = GetVertexNormalInputs(normalOS, tangentOS);
    half3 vertexSH = vertexUV.xyz;
    vertexSH = SampleSHVertex(normalInput.normalWS.xyz);
    return vertexSH;
}

half CalculateFogCoord(float4 positionCS)
{
    half fogFactor = 0;
    fogFactor = ComputeFogFactor(positionCS.z);
    return fogFactor;
}

float2 ScreenRatio()
{
    // x = width
    // y = height
    // z = 1 + 1.0/width
    // w = 1 + 1.0/height
    float2 ratio = 1;

    if(_ScreenParams.x > _ScreenParams.y)
    {
        ratio = float2(1, _ScreenParams.y / _ScreenParams.x);
    }
    else
    {
        ratio = float2(_ScreenParams.x / _ScreenParams.y, 1);
    }

    return ratio;
}

float2 ScreenOffset()
{
    // x = width
    // y = height
    // z = 1 + 1.0/width
    // w = 1 + 1.0/height
    float2 ratio = 1;

    if(_ScreenParams.x > _ScreenParams.y)
    {
        ratio = float2(0, 0.5 * (_ScreenParams.y / _ScreenParams.x));
    }
    else
    {
        ratio = float2(0.5 * (_ScreenParams.x / _ScreenParams.y), 0);
    }

    return ratio;
}

void GlobalVolumeController(inout half4 finalColor, float global_Night2Day, float night2DayEnum)
{
    finalColor = (
        night2DayEnum == 1 ? finalColor * abs(1 - global_Night2Day) :
        night2DayEnum == 2 ? finalColor * global_Night2Day : finalColor
    );
}

// 멀티 라이트 지원을 위한 준비
void InitializeFXLightData(InputData inputData, out Light mainLight, out LightingData lightingData)
{
    uint meshRenderingLayers = GetMeshRenderingLightLayer();
    float4 shadowMask = inputData.shadowMask;

    mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

    // 순수한 라이트 색상만 담아서 내보내기 위한 구조체
    lightingData = (LightingData)0;

    // GI color
    lightingData.giColor = _Global_GILightMulti.rgb;

    // Main light color
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
        lightingData.mainLightColor += mainLight.color;
    }

    // Additional light color
    #if defined(_ADDITIONAL_LIGHTS)
    {
        half shadowDimming = 1; // 셀프 셰도우를 없애기 위함.
        uint pixelLightCount = GetAdditionalLightsCount();

        #if USE_CLUSTERED_LIGHTING
        for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
        {
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
            {
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation * saturate(light.shadowAttenuation + shadowDimming));
                lightingData.additionalLightsColor += attenuatedLightColor;
            }
        }
        #endif

        LIGHT_LOOP_BEGIN(pixelLightCount)
            Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
            if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
            {
                half3 attenuatedLightColor = light.color * (light.distanceAttenuation * saturate(light.shadowAttenuation + shadowDimming));
                lightingData.additionalLightsColor += attenuatedLightColor;
            }
        LIGHT_LOOP_END
    }
    #endif
}

void ApplyShadowAtten(inout half4 finalColor, float4 shadowCoord, float3 positionWS, float lightRatio)
{
    // #ifdef _LIGHTRECEIVE_ON
    //     // 그림자 영향 받음
    //     #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    //         shadowCoord = TransformWorldToShadowCoord(positionWS);
    //     #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    //         shadowCoord = TransformWorldToShadowCoord(positionWS);
    //     #endif

    //     Light mainLight = GetMainLight(shadowCoord);
    //     half shadowAtten = saturate(mainLight.shadowAttenuation + (1 - lightRatio));
    //     // half3 attenuatedLightColor = mainLight.color.rgb * saturate(mainLight.distanceAttenuation * shadowAtten);

    //     finalColor.rgb *= shadowAtten;
    // #endif
}

void ApplyLightColor(inout half4 finalColor, float3 normalWS, float lightRatio)
{
    #ifdef _LIGHTRECEIVE_ON
        // 빛 영향 받음
        // float3 bakedGI = SampleSHPixel(vertexSH, normalWS);
        float3 bakedGI = _Global_GILightMulti.rgb;

        Light mainLight = GetMainLight();
        float3 light = mainLight.color.rgb;
        finalColor.rgb *= lerp(1, saturate(light + bakedGI), lightRatio);
    #endif
}

float3 MainLightColor()
{
    Light mainLight = GetMainLight();
    return mainLight.color;
}

float3 MainLightDirection()
{
    Light mainLight = GetMainLight();
    return mainLight.direction;
}

//이펙트 AlphaBlend 용
//글로벌 텍스쳐를 통한 하이트포그
//UV는 나중에 지역 포그 색 변화에 쓸 때를 대비해서 받습니다.
inline float4 MMN_GlobalTex_HeightFogAlpha(
    float4 color,
    float3 positionWS,
    float3 normalWS,
    float4 fogCoord,
    float fogPower,
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

    //y is height
    float y = saturate(positionWS.y / 100 - _Global_FogHeightOffset -GlobalTexture.r * _Global_FogHeightNoiseValue);
    half fogHeightBottom = saturate(y * _Global_FogHeightScale);
    half fogHeightTop = saturate(-y * _Global_FogHeightScale);
    half fogHeight = max(fogHeightBottom, fogHeightTop);

    //딤포그 단일 버전
    float DimFogRange = 0;
    float3 diff = _Global_pos.rgb - positionWS;
    float diffRange = saturate(dot(diff, diff) / (_Global_DimFog_Range * _Global_DimFog_Range)); //올리면 멀어짐
    diffRange = smoothstep(0.3, 1, diffRange);

    // float DimFogLight = lerp(1.0, 0.75 * (1.0 - dot(normalize(_Global_pos.rgb - half3(0, -1, 0) - positionWS), normalWS)), 0.5);
    float DimFogLight = 1;
    DimFogRange = 1 - PositivePow(diffRange * DimFogLight, _Global_DimFog_Power); //올리면 경계가 날카로와짐
    fogCoord.r = saturate(DimFogRange * fogCoord.r);

    //Final Fog Mixing
    withFogColor = MM_MixFog(color.rgb, fogCoord.r);
    color.rgb = lerp(withFogColor, color.rgb, saturate(fogHeight));

    return color;
}

//이펙트 Additive용
//글로벌 텍스쳐를 통한 하이트포그
//UV는 나중에 지역 포그 색 변화에 쓸 때를 대비해서 받습니다.
inline float4 MMN_GlobalTex_HeightFogAdd(
    float4 color,
    float3 positionWS,
    float3 normalWS,
    float4 fogCoord,
    float fogPower,
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

    //y is height
    float y = saturate(positionWS.y / 100 - _Global_FogHeightOffset -GlobalTexture.r * _Global_FogHeightNoiseValue);
    half fogHeightBottom = saturate(y * _Global_FogHeightScale);
    half fogHeightTop = saturate(-y * _Global_FogHeightScale);
    half fogHeight = max(fogHeightBottom, fogHeightTop);

    //딤포그 단일 버전
    float DimFogRange = 0;
    float3 diff = _Global_pos.rgb - positionWS;
    float diffRange = saturate(dot(diff, diff) / (_Global_DimFog_Range * _Global_DimFog_Range)); //올리면 멀어짐
    diffRange = smoothstep(0.3, 1, diffRange);

    // float DimFogLight = lerp(1.0, 0.75 * (1.0 - dot(normalize(_Global_pos.rgb - half3(0, -1, 0) - positionWS), normalWS)), 0.5);
    float DimFogLight = 1;
    DimFogRange = 1 - PositivePow(diffRange * DimFogLight, _Global_DimFog_Power); //올리면 경계가 날카로와짐
    fogCoord.r = saturate(DimFogRange * fogCoord.r);

    //Final Fog Mixing
    withFogColor = MM_MixFogColor(color.rgb, float3(0, 0, 0), fogCoord.r);
    color.rgb = lerp(withFogColor, color.rgb, saturate(fogHeight));

    return color;
}

//이펙트 멀티플라이용
//글로벌 텍스쳐를 통한 하이트포그
//UV는 나중에 지역 포그 색 변화에 쓸 때를 대비해서 받습니다.
inline float4 MMN_GlobalTex_HeightFogMulti(
    float4 color,
    float3 positionWS,
    float3 normalWS,
    float4 fogCoord,
    float fogPower,
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

    //y is height
    float y = saturate(positionWS.y / 100 - _Global_FogHeightOffset -GlobalTexture.r * _Global_FogHeightNoiseValue);
    half fogHeightBottom = saturate(y * _Global_FogHeightScale);
    half fogHeightTop = saturate(-y * _Global_FogHeightScale);
    half fogHeight = max(fogHeightBottom, fogHeightTop);

    //딤포그 단일 버전
    float DimFogRange = 0;
    float3 diff = _Global_pos.rgb - positionWS;
    float diffRange = saturate(dot(diff, diff) / (_Global_DimFog_Range * _Global_DimFog_Range)); //올리면 멀어짐
    diffRange = smoothstep(0.3, 1, diffRange);

    // float DimFogLight = lerp(1.0, 0.75 * (1.0 - dot(normalize(_Global_pos.rgb - half3(0, -1, 0) - positionWS), normalWS)), 0.5);
    float DimFogLight = 1;
    DimFogRange = 1 - PositivePow(diffRange * DimFogLight, _Global_DimFog_Power); //올리면 경계가 날카로와짐
    fogCoord.r = saturate(DimFogRange * fogCoord.r);

    //Final Fog Mixing
    withFogColor = MM_MixFogColorMulti(color.rgb, float3(1, 1, 1), fogCoord.r);
    color.rgb = lerp(withFogColor, color.rgb, saturate(fogHeight));

    return color;
}

void ApplyFogColor(inout half4 finalColor, float3 positionWS, float3 normalWS, float blendMode, float fogPower, float fogCoord)
{
    #ifdef _FOG_RCV_ON
        if (blendMode == 1 || blendMode == 2)
        {
            //하이트 포그  연산 ADD
            finalColor = MMN_GlobalTex_HeightFogAdd(
                finalColor,
                positionWS, normalWS, fogCoord, fogPower,
                _Global_FogHeightOffset,
                _Global_FogHeightScale,
                _Global_FogHeightNoiseValue,
                _Global_FogHeightNoiseSpeed,
                _Global_FogHeightNoiseScale,
                float2(0, 0));
        }
        // else if (blendMode <= 6)
        // {
        //     // 하이트 포그  연산 Multi
        //     finalColor= MMN_GlobalTex_HeightFogMulti(
        //     finalColor,
        //     positionWS, normalWS, fogCoord, fogPower,
        //     _Global_FogHeightOffset,
        //     _Global_FogHeightScale,
        //     _Global_FogHeightNoiseValue,
        //     _Global_FogHeightNoiseSpeed,
        //     _Global_FogHeightNoiseScale,
        //     float2(0,0));
        // }
        else
        {
            // 하이트 포그 연산 AlphaBlend
            finalColor = MMN_GlobalTex_HeightFogAlpha(
                finalColor,
                positionWS, normalWS, fogCoord, fogPower,
                _Global_FogHeightOffset,
                _Global_FogHeightScale,
                _Global_FogHeightNoiseValue,
                _Global_FogHeightNoiseSpeed,
                _Global_FogHeightNoiseScale,
                float2(0, 0));
        }
        // 원본 포그 코드
        // finalColor.rgb = MixFog(finalColor.rgb, fogCoord);                             // NOTE: for normal blend mode
        // finalColor.rgb = MixFogColor(finalColor.rgb, half3(0.0, 0.0, 0.0), fogCoord);  // NOTE: for additive blend mode
        // finalColor.rgb = MixFogColor(finalColor.rgb, real3(1.0, 1.0, 1.0), fogCoord);  // NOTE: for multiply blend mode
    #endif
}

// 환경 이펙트가 레이캐스트로 사라질 때 이펙트의 블렌드모드에 따라 트랜지션 되는 값을 다르게 합니다.
void ApplyTransitionValue(inout half4 finalColor, float blendMode, float transitionValue)
{
    if (blendMode == 1 || blendMode == 2)
    {
        // AdditiveColor, AdditiveAlpha
        finalColor.rgb *= saturate(transitionValue);
    }
    // else if (blendMode <= 6)
    // {
    //     // Multiply
    //     finalColor.rgb *= saturate(transitionValue);
    // }
    else
    {
        // AlphaBlend
        finalColor.a *= saturate(transitionValue);
    }
}

void ApplySoftParticle(inout half4 finalColor, float near, float far, float fadeOutRange, float4 positionNDC)
{
    #ifdef _SOFTPARTICLE_ON
        float fade = 1;
        float rawDepth = SampleSceneDepth(positionNDC.xy / positionNDC.w);
        float sceneZ = LinearEyeDepth(rawDepth, _ZBufferParams);
        float thisZ = LinearEyeDepth(positionNDC.z / positionNDC.w, _ZBufferParams);
        fade = saturate(far * fadeOutRange * ((sceneZ - near) - thisZ));

        finalColor.a *= fade;
    #endif
}

void ApplyNearPlaneAlpha(inout half alpha, half distance, float4 screenPos, half nearPlaneInvertDistance, half nearPlane, half raycastMinimumAlpha)
{
    // float2 screenUV = float2(screenPos.x, screenPos.y) * ScreenRatio(); // 원형 비율 계산
    // screenUV = screenUV - 0.5 * ScreenRatio();

    half distanceAlpha = distance; //- length(screenUV); // 원형 마스킹
    distanceAlpha = max(0, 0.5 * distanceAlpha);

    alpha = saturate(distanceAlpha * nearPlane); // nearPlane 기본 값은 0.5입니다.
    alpha = lerp(alpha, 1 - alpha, nearPlaneInvertDistance); // 경우에 따라서 반전합니다.
    alpha = max(raycastMinimumAlpha, alpha); // 알파의 최솟값을 결정합니다.

    half clipAlpha = smoothstep(0.1, 1, distance); // 카메라의 니어 플레인에 닿기 직전에 최솟값을 무시하고 사라지게 합니다.
    alpha *= clipAlpha;

    alpha = lerp(alpha, 1, unity_OrthoParams.w); // ortho에서는 작동안되게 만들어 줍니다.
}

float GetCameraDistance(float3 positionWS)
{
    return distance(GetCameraPositionWS(), positionWS);
}

float3 GetCameraPosition()
{
    return GetCameraPositionWS();
}

void ApplyRaycastingAlpha(
    inout half4 finalColor, float3 positionWS, half4 screenUV, half4 screenPos,
    half nearPlane, half nearPlaneInvertDistance,
    half raycastHarftoneClip, half raycastMinimumAlpha)
{
    half alpha = 1;
    half cameraDistance = GetCameraDistance(positionWS);

    if(nearPlane != 0)
    {
        ApplyNearPlaneAlpha(alpha, cameraDistance, screenPos, nearPlaneInvertDistance, nearPlane, raycastMinimumAlpha);
        finalColor.a *= saturate(alpha);
    }

    #ifdef _RAYCAST_ON
        half raycastAlpha = 0;
        raycastAlpha = RaycastingHalftoneAlphaBlend(screenUV, screenPos, raycastHarftoneClip, raycastMinimumAlpha);
        finalColor.a *= saturate(raycastAlpha);
    #endif
}

half DepthFade(float distance, float4 positionCS, float4 positionNDC)
{
    float rawDepth = SampleSceneDepth(positionNDC.xy / positionNDC.w);
    float sceneZ = LinearEyeDepth(rawDepth, _ZBufferParams);
    half distanceDepth = saturate((sceneZ - LinearEyeDepth(positionCS.z, _ZBufferParams)) / distance + 0.001);
    return distanceDepth;
}

float4 FragComputeScreenPos(float4 positionCS)
{
    float4 screenPos = ComputeScreenPos(positionCS);
    screenPos = screenPos / screenPos.w; // == positionNDC.xy / w
    return screenPos;
}

half3 SceneColor(float4 positionNDC)
{
    float2 screenPos = positionNDC.xy / positionNDC.w;
    half3 sceneColor = SampleSceneColor(screenPos);
    return sceneColor;
}

void DefineAlpha (inout float alpha, float cutoff)
{
    #if !defined(_ALPHATEST_ON) && !defined(_ALPHABLEND_ON)
        alpha = 1.0;
    #elif defined(_ALPHATEST_ON)
        clip(alpha - cutoff);
        alpha = 1.0;
    #endif
}

half Triplanar(float3 normalWS, float3 triplanarTex)
{
    half triplanarX = triplanarTex.r;
    half triplanarY = triplanarTex.g;
    half triplanarZ = triplanarTex.b;

    float3 normalBlend = abs(normalWS);
    normalBlend /= (normalBlend.x + normalBlend.y + normalBlend.z);

    half nx = triplanarX * normalBlend.x;
    half ny = triplanarY * normalBlend.y;
    half nz = triplanarZ * normalBlend.z;

    half triplanar = nx + ny + nz;
    return triplanar;
}

float2x2 RotateMatrix(float degrees)
{
    degrees *= 360;
    float degree2Rad = PI * 2 / 360;
    float rotationRadians = degrees * degree2Rad;
    float c = cos(rotationRadians);
    float s = sin(rotationRadians);
    float2x2 rotateMatrix = float2x2(c, -s, s, c);
    return rotateMatrix;
}

float2 Rotate(float2 uv, float degrees, float offset)
{
    float2x2 rotateMatrix = RotateMatrix(degrees);
    uv.x -= offset;
    uv = mul(uv, rotateMatrix);
    uv.x += offset;
    return uv;
}

float PolarCoord(float2 uv, float curveCount)
{
    float2 polarCoord = float2(float(atan2(uv.x, uv.y)), length(uv));
    uv = float2(polarCoord.x, 0);
    uv.x = sin(uv.x * curveCount);

    return uv.x;
}

float3 Rotation(float3 positionOS, float degrees, float offset)
{
    return float3(Rotate(positionOS.xy, degrees, offset), positionOS.z);
}

float CurvedPath(float3 positionWS, float4 charPosition, float intensity, float curveCount)
{
    float biCurveCount = 1 * curveCount;
    float3 uv = (positionWS - charPosition.xyz);
    // float4 noiseTex = SAMPLE_TEXTURE2D_LOD(_MainTex, sampler_MainTex, uv.xz, 0); // 텍스쳐로 굴곡을 줄 경우
    float curve = PolarCoord(uv.xz, biCurveCount) * (intensity / (1 + biCurveCount * 0.5));
    // 굴곡 수가 많을 수록 커브의 휘어짐 강도를 약하게 함
    return curve;
}

float CurvedAngle(float3 positionWS, float4 charPosition, float rotation, float curveCount)
{
    float biCurveCount = 1 * curveCount;
    float3 uv = (positionWS - charPosition.xyz);
    float curve = PolarCoord(uv.xz, biCurveCount) * rotation;
    return curve;
}

void ApplyScreenSpaceDecal(in float4 screenPos, out float2 decalUV, out float boundingBox, out float4 decalWorldSpace)
{
    float2 screenUV = screenPos.xy * 2 - 1;
    float rawDepth = SampleSceneDepth(screenPos.xy / screenPos.w);

    float3 negateScreenPos = float3(screenUV.x, -1 * screenUV.y, rawDepth);

    decalWorldSpace = mul(UNITY_MATRIX_I_VP, float4(negateScreenPos, 1));
    decalWorldSpace.xyz = decalWorldSpace.xyz / decalWorldSpace.w;
    float3 decalObjectSpace = TransformWorldToObject(decalWorldSpace.xyz);

    float3 a = step(-0.5, decalObjectSpace);
    float3 b = 1 - (step(0.5, decalObjectSpace));

    boundingBox = all(a * b);
    decalUV = (decalObjectSpace + 0.5).xy;
}

void ApplyScreenSpaceDecal(in float4 screenPos, out float2 decalUV, out float boundingBox)
{
    float4 decalWorldSpace;
    ApplyScreenSpaceDecal(screenPos, decalUV, boundingBox, decalWorldSpace);
}

void InterectionBorderFX(float3 positionWS, float3 globalPosition, float radius, out float3 offset, out float alpha)
{
    float3 objectScale = float3(length(GetObjectToWorldMatrix()[0].xyz), length(GetObjectToWorldMatrix()[1].xyz), length(GetObjectToWorldMatrix()[2].xyz));

    globalPosition.y += 0.75; // 높이를 보정합니다.

    // 기존의 버텍스 미는 방식 백업
    // float3 direction = globalPosition - positionWS; // globalPosition 이 0점인 좌표계이자 positionWS 과의 방향
    // float3 pushDirection = -1 * normalize(direction);
    // float dist = distance(globalPosition, positionWS);

    // float diff = radius - dist;
    // diff = smoothstep(0, 1, diff) * (radius / 2);
    // float3 push = diff * pushDirection;

    // float range = dist / (radius + 0.001); // push 값을 마스킹 합니다.
    // range = 1 - saturate(range);

    // alpha = saturate(1 - saturate(range * 1.35));

    // offset = (range * push) / objectScale;

    // 신규 버텍스 당기기
    float3 direction = globalPosition - positionWS;
    float3 pushDirection = 1 * normalize(direction);
    float dist = distance(globalPosition, positionWS);

    float range = dist / (radius + 0.001);
    range = (1 - saturate(range));
    range = pow(range, 0.8 + 0.001);

    offset = pushDirection * dist * range / objectScale;
    alpha = 1;
} 

#endif // #ifndef MMN_FX_COMMON_OUTPUTS_INCLUDED
