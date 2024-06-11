#ifndef MMN_CHARACTER_DATA
#define MMN_CHARACTER_DATA

// NOTE: 아래의 모든 값은 월드 공간 기준입니다.
struct CharacterData
{
    float3 characterPos;
    float visualHeight;
    float3 characterCenterPos;
    float2 direction2D;
    float3 direction3D;
    float3 headDirection3D;
    float headHeight;
    float footHeight;

    float topShadow;
    float bottomShadow;
};

CharacterData InitializeCharacterData()
{
    CharacterData data;

    data.characterPos = _CharacterPositionAndVisualHeight.xyz;
    data.visualHeight = _CharacterPositionAndVisualHeight.w;
    data.characterCenterPos = float3(data.characterPos.x, data.characterPos.y + (data.visualHeight * 0.5), data.characterPos.z);

    data.direction2D = _CharacterDirection.xy;
    data.direction3D = normalize(float3(_CharacterDirection.x, 0.0, _CharacterDirection.y));
    data.footHeight = _CharacterDirection.z;

    data.headDirection3D = _CharacterHeadDirection.xyz;
    data.headHeight = _CharacterHeadDirection.w; // NOTE: 음수 값이 나올 수 있음. 음수라면 머리와 발이 거꾸로 되어 있는 경우일 수 있다. (물구나무 처럼)

    data.topShadow = _TopShadow;
    data.bottomShadow = _BottomShadow;

    return data;
}

#endif // MMN_CHARACTER_DATA
