#ifndef MMN_CHARACTER_DATA
#define MMN_CHARACTER_DATA

struct CharacterData
{
    float3 characterPos;
    half visualHeight;
    float3 characterCenterPos;
    half2 direction2D;
    half3 direction3D;
    half3 headDirection3D;
    half headHeight;

    half topShadow;
    half bottomShadow;
};

CharacterData InitializeCharacterData()
{
    CharacterData data;

    data.characterPos = _CharacterPositionAndVisualHeight.xyz;
    data.visualHeight = _CharacterPositionAndVisualHeight.w;
    data.characterCenterPos = float3(data.characterPos.x, data.characterPos.y + (data.visualHeight * 0.5), data.characterPos.z);
    data.direction2D = _CharacterDirection.xy;
    data.direction3D = normalize(half3(_CharacterDirection.x, 0.0, _CharacterDirection.y));
    data.headDirection3D = _CharacterHeadDirection.xyz;
    data.headHeight = (_CharacterHeadDirection.w <= 0.0001) ? _CharacterPositionAndVisualHeight.w : _CharacterHeadDirection.w;

    data.topShadow = _TopShadow;
    data.bottomShadow = _BottomShadow;

    return data;
}

#endif // MMN_CHARACTER_DATA
