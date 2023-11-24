#ifndef MMN_CHARACTER_DATA
#define MMN_CHARACTER_DATA

struct CharacterData
{
    float3 characterPos;
    float visualHeight;
    float3 characterCenterPos;
    float2 characterDirection;

    float topShadow;
    float bottomShadow;
};

CharacterData InitializeCharacterData()
{
    CharacterData data;

    data.characterPos = _CharacterPositionAndVisualHeight.xyz;
    data.visualHeight = _CharacterPositionAndVisualHeight.w;
    data.characterCenterPos = float3(data.characterPos.x, data.characterPos.y + (data.visualHeight * 0.5), data.characterPos.z);
    data.characterDirection = _CharacterDirection.xy;

    data.topShadow = _TopShadow;
    data.bottomShadow = _BottomShadow;

    return data;
}

#endif // MMN_CHARACTER_DATA
