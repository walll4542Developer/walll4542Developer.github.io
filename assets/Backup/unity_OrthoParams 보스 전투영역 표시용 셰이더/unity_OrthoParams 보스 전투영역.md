개요

보스 몬스터의 전투 영역을 이펙트를 사용해서 표시하기 위한 셰이더를 제작합니다.

위 예시 이미지는 이펙트 팀에서 제작한 FX_Area_Border_Boss 프리팹 입니다. 

해당 이펙트 프리팹의 셰이더를 수정(FX_Dissolve_Div_Distortion_2C_AddNoise)해서 구현합니다.

작업 계획
먼저 기본적인 스펙을 설정합니다.

형태는 원통 형태의 메시를 사용한 반투명의 배리어 이펙트입니다.
연출은 연기 형태의 텍스쳐가 계속 아래로 흐르며 소프트 파티클이 적용됩니다.
또한 플레이어가 배리어의 경계에 가까이 다가갈수록 접근 불가한 것처럼 경고하는 연출이 있습니다.
메시의 반지름에 비례하여 UV를 타일링해서 UV Seam이 생기지 않도록 제작합니다.
원통 메시는 그래픽스팀에서 제작해주실 예정입니다.
원통 메시가 너무 커서 이펙트가 컬링될 가능성이 있다고 하는데 요 이슈도 그래픽스 팀에서 처리해줄 예정입니다.
타일링된 원통 가메시를 맥스로 제작 해서 전투필드에 올려서 룩을 잡을 계획입니다.
카메라 포지션과 버텍스의 거리를 사용해서 접근 불가한 경고 연출을 처리할 계획입니다.
 

작업 내용
진행 추가 1 (23.05.10)

이제는 하프톤이 아니라 알파 블렌드로 나타나고 사라집니다.

 


사라지는 알파의 최솟값을 추가하여 아예 사라지지 않도록 제어 할 수 있습니다.

진행 추가 0


키 아이디어는 심플합니다. 카메라와 원통형 메시(positionWS) 사이의 거리를 측정한 cameraDistance 값을 사용해서 가까울때만 렌더링 하고 멀어지면 픽셀을 discard 하여 렌더링 하지 않습니다. 

물론 카메라 포지션을 사용하지 않고 특정한 오브젝트의 피벗(Pivot)을 기준으로 거리를 측정할 수도 있습니다.

 



이펙트 셰이더에서 추가된 부분의 전체 그림입니다. 이펙트 팀에서 원하는 방식의 연출으로 쉽게 수정할 수 있도록 ASE 노드로 제작하였습니다.  

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

void ApplyNearAlpha(float distance, float4 screenPos, out float alpha)
{
    alpha = 1;
    distance = pow(distance, 3);
    float2 screenUV = float2(screenPos.x, screenPos.y) * ScreenRatio();
    screenUV = screenUV - 0.5 * ScreenRatio();

    alpha = distance - length(screenUV);
    alpha *= min(1, alpha);
    alpha -= saturate(0.5 - unity_OrthoParams.w); //orth에서는 작동안되게 만들어 줍니다. 송지훈 팀장님 감사
}
위와 같이 니어 하프톤 알파 함수를 응용해서 하프톤으로 나타나고 사라지게 처리 했습니다.

FX팀에서 수정 가능한 부분들
기본적으로 제가 작업한 모든 부분은 FX팀에서 수정해도 무방하게 제작되었습니다.

특정한 오브젝트의 피벗(Pivot)을 기준으로 거리를 계산 하는 것이 룩이 더 나은 경우도 있습니다. 왜냐하면 카메라와 캐릭터의 위치가 완전히 동일한 것이 아니라, 카메라가 엄청 멀리서 넓게 보는 경우도 있기 때문입니다.

예를 들어 WorldPivot에는 스크립트에서 받아온 월드 포지션 값을 넣어서 비교하는 것이 가능합니다.

 



예를 들어 왼쪽 노드를 오른쪽 처럼 수정해서, 캐릭터의 피벗과 원통형 메시(positionWS)의 거리를 이용하여 붉은색으로 접근 불가한 경고 표시를 연출 할 수 있습니다. 

 



위 처럼 노드를 편집할 경우 캐릭터의 피벗을 WorldPivot으로 받아와서 버텍스와 거리를 재서 가까울 때 붉은색으로 접근 불가한 경고 표시를 위처럼 연출 할 수 있습니다. 

 



경고 표시 연출에 대한 적절한 예시를 위해서 단순하게 빨간색 float3(1,0,0)이 나오도록 처리를 했는데요, Warning으로 쓰여져 있는 부분의 노드는 FX팀에서 원하는 연출으로 수정해서 사용하시면 좋을 것 같습니다. 

 



경고 연출에 알파를 사용해야하는 경우에도 finalAlpha로 연결되는 부분의 노드를 수정하시면 됩니다. (기본적으로는 연결을 끊어뒀습니다)

레퍼런스 / 참고자료
https://deskcat.io/d/Q21071/MM-PM-0424-보스-전투영역-연출-기술-논의
https://deskcat.io/d/Q22950/MM-미술-전투-필드-보스-영역-표시