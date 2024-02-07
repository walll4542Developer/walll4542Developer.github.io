#ifndef MMN_CHARACTER_APPLY_FOG_INCLUDED
#define MMN_CHARACTER_APPLY_FOG_INCLUDED

#include "../../Includes/EnvironmentHelper.hlsl"
#include "CharacterLighting.hlsl"


half4 ApplyFog(in half4 resultColor, float3 positionWS, half3 normalWS, half4 fogCoord)
{
    if (_CustomLightMode == 1)
    {
        return resultColor;
    }
    else
    {
        // 하이트 포그  연산
        return MMN_GlobalTex_HeightFog(
            resultColor,
            positionWS, normalWS, fogCoord,
            _Global_FogHeightOffset,
            _Global_FogHeightScale,
            _Global_FogHeightNoiseValue,
            _Global_FogHeightNoiseSpeed,
            _Global_FogHeightNoiseScale,
            float2(0.0, 0.0));
    }
}

#endif // MMN_CHARACTER_APPLY_FOG_INCLUDED
