#ifndef MMN_CHARACTER_BASE_PASS_VERTEX_INCLUDED
#define MMN_CHARACTER_BASE_PASS_VERTEX_INCLUDED

#include "CharacterCommonAttributes.hlsl"

#include "CharacterApplyFx.hlsl"
// #include "../../Includes/VectorRigHelper.hlsl"
// #include "../../Includes/BendingVertex.hlsl"
#include "CharacterLighting.hlsl"
#include "CharacterMotionBlurPass.hlsl"


#ifdef _WEAPON_GRADE_FEATURE

float3 GetOutlineOffset(float4 positionCS, float3 normalOS, float3 normalWS, float3 lightDirWS)
{
    const float OUTLINE_NEAR_WIDTH = 0.000175; // 근거리 굵기 : 카메라와 캐릭터 중심과의 거리가 1.5(최대 줌인 시 거리)일 때 적절한 값
    const float OUTLINE_FAR_WIDTH = 0.072; // 원거리 굵기 : 카메라와 캐릭터 중심과의 거리가 20.0(최대 줌아웃 시 거리)일 때 적절한 값
    const float OUTLINE_CAMERA_DISTANCE = 80.0; // 거리에 따른(근거리/원거리) 굵기에 대한 비율 보정용 값.
    const float OUTLINE_BASE_FOV = 36.0; // 이 FOV(Vertical)에서 의도한 굵기가 나온다.
    const float OUTLINE_MIN_WIDTH_RATE = -2.0; // 빛의 방향에 따라 굵기가 달라질 때, 최대 - 최소 비율. (값이 크면 비슷해지고, 값이 작으면 차이가 커진다.)
    #if defined(_IS_MONSTER)
        const float OUTLINE_WIDTH_SCALE = 2.0; // 최종 굵기의 보정값.
    #else
        const float OUTLINE_WIDTH_SCALE = 1.0; // 최종 굵기의 보정값.
    #endif
    const float RAD_TO_DEG_DOUBLE = 114.591559; // 2.0 * (180.0 / PI)

    float fov = atan(1.0 / unity_CameraProjection._m11) * RAD_TO_DEG_DOUBLE;
    float normalizedFov = (fov / OUTLINE_BASE_FOV);
    float depth = positionCS.w;
    // _ProjectionParams = { 1 or -1 (-1 if projection is flipped), near plane, far plane, 1 / far plane }
    float viewDistance = (depth - (_ProjectionParams.y * _ProjectionParams.x)) * normalizedFov;
    float normalizedViewDistance = saturate(viewDistance / OUTLINE_CAMERA_DISTANCE);

    float maxOutlineWidth = lerp(OUTLINE_NEAR_WIDTH, OUTLINE_FAR_WIDTH, normalizedViewDistance);
    float minOutlineWidth = maxOutlineWidth * OUTLINE_MIN_WIDTH_RATE;

    float3 cameraDirWS = -GetViewForwardDir();
    // float rimArea = saturate(dot(normalWS, normalize(ProjectOnPlane(lightDirWS, cameraDirWS))));
    // float rimArea = saturate(dot(normalWS, lightDirWS));
    float rimArea = saturate(dot(normalWS, normalize(ProjectOnPlane(lightDirWS * float3(1.0, 0.3, 1.0), cameraDirWS))));

    // float nDotL = max(0.0, dot(normalWS, lightDirWS));
    // float lightingMask = max(0.0, 0.8 - nDotL);
    float lightingMask = 1.0 - rimArea;
    // lightingMask = saturate(lightingMask*4.0-2.0);

    float outlineWidth = lerp(minOutlineWidth, maxOutlineWidth, lightingMask);
    outlineWidth *= OUTLINE_WIDTH_SCALE;
    outlineWidth = max(0.0, outlineWidth); // 0보다 작아질 수 없다. 음수가 나오면 아웃라인이 반대로 뚫고 나올 수 있다.

    // 오브젝트의 스케일에 따라 아웃라인이 굵어지거나 가늘어지는 것을 보정한다.
    float3 scaleOS = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));

    float3 offset = normalOS.xyz * outlineWidth / scaleOS;
    return offset;
}

#endif

Varyings BasePassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    // VECTOR_RIG_DEFORM(input, input.positionOS, input.normalOS, input.texcoord)

    output.uv.xy = input.texcoord0.xy;
    output.uv.zw = input.texcoord1.xy;

#ifdef _VERTEX_OBJECT_MOTION_BLUR
    // 오브젝트 모션블러(버텍스)를 적용한다
    float3 positionOS = CaculateMotionBlurVertexPositionOS(input.positionOS.xyz, input.normalOS, input.id);
#else
    float3 positionOS = input.positionOS.xyz;
#endif

    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.positionOS = positionOS;

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = float3(normalInput.normalWS);
    float crossSign = float(input.tangentOS.w) * GetOddNegativeScale();
    output.tangentWS = float4(normalInput.tangentWS, crossSign);
    output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    output.positionNDC = vertexInput.positionNDC;

    float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
#ifdef _ADDITIONAL_LIGHTS_VERTEX
    float3 vertexLight = AdditionalLightsVertex(output.positionWS.xyz, output.normalWS);
    output.fogCoord = float4(fogFactor, vertexLight); //fogFactorAndVertexLight
#else
    output.fogCoord = float4(fogFactor, 0.0, 0.0, 0.0);
#endif

#ifdef _WEAPON_GRADE_FEATURE
    // ----------------------------------------------------
    // 아웃라인 용 뎁스 계산을 위한 포지션
    // ----------------------------------------------------
    Light mainLight = GetMainLight();
    float3 offsetOS = GetOutlineOffset(vertexInput.positionCS, input.normalOS, normalInput.normalWS, mainLight.direction);

    positionOS += offsetOS;
    float3 outlinePositionWS = TransformObjectToWorld(positionOS);
    output.outlineNDC = ComputeNormalizedDeviceCoordinates(outlinePositionWS, GetWorldToHClipMatrix());
    // ----------------------------------------------------
#endif

    return output;
}

// 버텍스의 Normal을 그대로 사용하는 경우
void InitializeCharacterInputData(Varyings input, out InputData inputData)
{
    inputData = (InputData)0;
    inputData.positionWS = input.positionWS.xyz;

    inputData.viewDirectionWS = SafeNormalize(input.viewDirWS);

    inputData.normalWS.xyz = SafeNormalize(input.normalWS.xyz);

    inputData.shadowCoord = float4(0, 0, 0, 0);

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
    inputData.vertexLighting = input.fogCoord.yzw;
#else
    inputData.fogCoord = InitializeInputDataFog(float4(inputData.positionWS, 1.0), input.fogCoord.x);
    inputData.vertexLighting = float3(0, 0, 0);
#endif

    inputData.bakedGI = 1.0; //음영을 사용 안하도록

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = float4(1, 1, 1, 1);
}

#endif // #ifndef MMN_CHARACTER_BASE_PASS_VERTEX_INCLUDED
