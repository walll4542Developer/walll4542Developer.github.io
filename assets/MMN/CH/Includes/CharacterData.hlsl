#ifndef MMN_CHARACTER_DATA
#define MMN_CHARACTER_DATA

struct CharacterData
{
    float3 characterPos;
    float visualHeight;
    float3 characterCenterPos;
    float2 direction2D;
    float3 direction3D;
    float3 headDirection3D;
    float headHeight;

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
    data.headDirection3D = _CharacterHeadDirection.xyz;
    data.headHeight = (_CharacterHeadDirection.w <= 0.0001) ? _CharacterPositionAndVisualHeight.w : _CharacterHeadDirection.w;

    data.topShadow = _TopShadow;
    data.bottomShadow = _BottomShadow;

    return data;
}

#endif // MMN_CHARACTER_DATA
