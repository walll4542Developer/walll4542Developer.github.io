#ifndef MMN_CHARACTER_APPLY_FRESNEL_INCLUDED
#define MMN_CHARACTER_APPLY_FRESNEL_INCLUDED

float3 ApplyFresnel(float3 dyedBaseColor, float3 mainLightColor, float3 giColor,
    float3 normalWS, float3 viewDirectionWS,
    float3 fresnelColor, float fresnelRange, float fresnelPower)
{
    float3 lightColor = saturate(mainLightColor + giColor);

    float nDotV = dot(normalWS, viewDirectionWS);
    float fresnelValue = saturate(pow(abs(1.0 - nDotV), fresnelRange));
    float3 fresnelResult = dyedBaseColor * lightColor * fresnelColor * fresnelValue * fresnelPower;
    return fresnelResult;
}

#endif // MMN_CHARACTER_APPLY_FRESNEL_INCLUDED
