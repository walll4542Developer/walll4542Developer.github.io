#ifndef MMN_BENDING_VERTEX_INCLUDED
#define MMN_BENDING_VERTEX_INCLUDED

#include "Assets/PatchableAssets/Shaders/MMN/Includes/GlobalTextureHolder.hlsl"


/////////////////////////////////////////////////////////////////////////////////
//                               제어 함수들                                   //
/////////////////////////////////////////////////////////////////////////////////



//풀이나 관목에 닿으면 인터렉션이 일어나게 해 봅시다
float3 InterectionGrass(float3 positionWS, float _GrassPushPower, float4 color)
{
    float CapsuleHeight = 0.5;
    //캐릭터 주변에 원형 마스킹을 만든다
    float3 diff = _Global_pos.rgb - positionWS ;
    diff.y += 0.5;
    diff.y -= clamp(diff.y, -CapsuleHeight, CapsuleHeight); //y쪽으로 캡슐을 만들어 준다
    float diffRange = saturate(dot(diff, diff) / (0.8 * _GrassPushPower + 0.0001)); //올리면 멀어짐
    float pushRange = pow(diffRange, 0.7);//올리면 경계가 날카로와짐
    pushRange = 1 - pushRange;

    float3 sphereDisp = (positionWS - _Global_pos.rgb) ; //내 위치가 월드 0점이 되도록
    sphereDisp *= pushRange; //마스킹을 한다
    float3 posWS = sphereDisp * color.r  ;
    posWS.y = 0;
    return posWS;
}


//바람에 흔들리는 식물 움직임
float3 positionByWind(float3 positionWS, float _WindMultiply, float _WindSpeedMultiply, float windmask)
{
    // float2 uv = positionWS.xz * (_Global_CloudScale * 0.01 * _WindMultiply) + (frac(_Time.x) * _Global_CloudSpeed * 0.01 * _WindSpeedMultiply);
    InitializeGlobalValue();
    float2 uv = positionWS.xz * (_Global_CloudScale * 0.01 * _WindMultiply) + _Global_WindUV * _WindSpeedMultiply;
    float4 GlobalTexture = SAMPLE_TEXTURE2D_LOD(_Global_Texture, sampler_Global_Texture, uv, 0);
    float3 positionWSByWind = positionWS + (GlobalTexture.g * 2 - 1) * 0.15 * windmask ;
    return positionWSByWind;
}


//바람에 흔들리는 식물 움직임 프리뷰용 (픽셀셰이더 프리뷰용)
float4 positionByWind(float3 positionWS, float _WindMultiply, float _WindSpeedMultiply)
{
    // float2 uv = positionWS.xz * (_Global_CloudScale * 0.01 * _WindMultiply) + (frac(_Time.x)  * _Global_CloudSpeed * 0.01 * _WindSpeedMultiply);
    InitializeGlobalValue();
    float2 uv = positionWS.xz * (_Global_CloudScale * 0.01 * _WindMultiply) + _Global_WindUV * _WindSpeedMultiply;;
    float4 GlobalTexture = SAMPLE_TEXTURE2D_LOD(_Global_Texture, sampler_Global_Texture, uv, 0);
    //float3 positionWSByWind = positionWS + (GlobalTexture.r * 2 - 1) * 0.15* color.r ;
    return GlobalTexture;
}


//커브드 월드 바이 카메라 기능.
float3 vertexVendingByCamera(float3 positionVS, float4 vertexbending, float cameraForwardDirMul)
{
    float3 cameraForwardVector = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
    vertexbending.y += cameraForwardVector.y * cameraForwardDirMul;

    //휘어지기
    float zOffset = positionVS.z / (vertexbending.a + 0.000001);//0으로 나누는 사태를 방지하기 위해
    positionVS += float3(vertexbending.xy, 0) * zOffset ;// * zOffset * zOffset ; //커브가 너무 심해서 줄임
    return positionVS;
}


/////////////////////////////////////////////////////////////////////////////////
//                       버텍스 포지션 메트릭스 연산                             //
/////////////////////////////////////////////////////////////////////////////////

float4 _Global_VertexPositionOffset;

//버텍스 포지션 메트릭스 연산 벤딩 * 카메라 상하 가중치 버전 오버로딩
VertexPositionInputs GetVertexPositionInputsForBending(float3 positionOS)
{
    float4 vertexbending = _Global_VertexPositionOffset;
    float cameraForwardDirMul = _Global_VertexPositionOffset.z;

    VertexPositionInputs input;
    input.positionWS = TransformObjectToWorld(positionOS);
    input.positionVS = TransformWorldToView(input.positionWS);
    input.positionVS = vertexVendingByCamera(input.positionVS, vertexbending, cameraForwardDirMul);
    input.positionCS = TransformWViewToHClip(input.positionVS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}

//버텍스 노말 변환 (기본형. 이건 내장된 것과 동일 )
VertexNormalInputs GetVertexNormalInputs(float3 normalOS, float4 tangentOS, float4 vertexbending)
{
    VertexNormalInputs tbn;

    // mikkts space compliant. only normalize when extracting normal at frag.
    float sign = tangentOS.w * GetOddNegativeScale();
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    tbn.tangentWS = TransformObjectToWorldDir(tangentOS.xyz);
    tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
    return tbn;
}


// 버텍스  흔들리는 오브젝트와 나무에 사용
VertexPositionInputs GetVertexPositionInputs4treeShake(float3 positionOS, float4 vertexbending, float cameraForwardDirMul, float4 color, float _WindMultiply, float _WindSpeedMultiply, float _GrassPushPower, half vertexAniOn)
{
    VertexPositionInputs input;
    input.positionWS = TransformObjectToWorld(positionOS);

    if (vertexAniOn == 1)
    {
        //바람에 흔들리는 나뭇잎
        input.positionWS = positionByWind(input.positionWS, _WindMultiply, _WindSpeedMultiply, color.r);

        //사람에 닿으면 밀려나는 인터렉션이 일어나게 해 봅시다.
        input.positionWS += InterectionGrass(input.positionWS, _GrassPushPower, color);
    }
    else
    {

    }

    //버텍스 포지션 메트릭스 연산 벤딩 * 카메라 상하 가중치
    input.positionVS = TransformWorldToView(input.positionWS);
    // input.positionVS = vertexVendingByCamera(input.positionVS, vertexbending, cameraForwardDirMul);
    input.positionCS = TransformWViewToHClip(input.positionVS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}

// 땅 밑으로 적절하게 내립니다.
VertexPositionInputs GetVertexPositionInputsGrassVisualRange(
    float3 positionOS, float4 maskingColor,
    float windMultiply, float windSpeedMultiply, float grassPushPower, half vertexAniOn,
    half grassVisualRange, half visualRangeFactor, half grassVisualActionToggle)
{
    VertexPositionInputs input;

    input.positionWS = TransformObjectToWorld(positionOS);

    // 비율을 구한다음 조건에 따라 풀을 월드 y축으로 내립니다.
    // TODO @박대명 : 여기 아래에 _Global_pos 변수를 작업하신 변수로 바꿔주세요.
    half3 distanceVector = _Global_pos.xyz - input.positionWS.xyz;
    half distanceSquared = dot(distanceVector, distanceVector);
    half visualRangeSquared = (grassVisualRange * grassVisualRange) * visualRangeFactor; // [ + ]

    const half offsetMin = 0.0;
    const half offsetMax = -3.0;
    const half offsetSpeed = 0.5;
    half offset = clamp((distanceSquared - visualRangeSquared) / visualRangeSquared, 0, 1);
    input.positionWS.y += (lerp(offsetMin, offsetMax, offset) * offsetSpeed * grassVisualActionToggle) * _Global_pos.w;
    // 현재 _Global_pos.xyz에 0 값이 들어가 에디터에서 무조건 이 기능이 가동되므로 일단 끕니다.

    if (vertexAniOn == 1)
    {
        // 바람에 흔들리는 나뭇잎
        input.positionWS = positionByWind(input.positionWS, windMultiply, windSpeedMultiply, maskingColor.r);

        // 사람에 닿으면 밀려나는 인터렉션이 일어나게 해 봅시다.
        input.positionWS += InterectionGrass(input.positionWS, grassPushPower, maskingColor);
    }

    //버텍스 포지션 메트릭스 연산 벤딩 * 카메라 상하 가중치
    input.positionVS = TransformWorldToView(input.positionWS);
    input.positionCS = TransformWViewToHClip(input.positionVS);

    float4 ndc = input.positionCS * 0.5f;
    input.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    input.positionNDC.zw = input.positionCS.zw;

    return input;
}


// 버텍스 노말 메트릭스 연산 흔들리는 나무용. 탄젠트 포함버전
VertexNormalInputs GetVertexNormalInputs4treeShake(float3 normalOS, float4 tangentOS, float4 vertexbending, float cameraForwardDirMul, float4 color, float _WindMultiply, float _WindSpeedMultiply, float _GrassPushPower)
{
    VertexNormalInputs tbn;

    // mikkts space compliant. only normalize when extracting normal at frag.
    float sign = tangentOS.w * GetOddNegativeScale();
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    tbn.tangentWS = TransformObjectToWorldDir(tangentOS.xyz);

    tbn.normalWS = positionByWind(tbn.normalWS, _WindMultiply, _WindSpeedMultiply, color.r);
    tbn.tangentWS = positionByWind(tbn.tangentWS, _WindMultiply, _WindSpeedMultiply, color.r);

    tbn.bitangentWS = cross(tbn.normalWS, tbn.tangentWS) * sign;
    return tbn;
}

#endif
