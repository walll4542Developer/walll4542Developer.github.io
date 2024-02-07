#ifndef MMN_CHARACTER_APPLY_FRESNEL_INCLUDED
#define MMN_CHARACTER_APPLY_FRESNEL_INCLUDED

half3 ApplyFresnel(half3 dyedBaseColor, half3 mainLightColor, half3 giColor,
    half3 normalWS, half3 viewDirectionWS,
    half3 fresnelColor, half fresnelRange, half fresnelPower)
{
    half3 lightColor = saturate(mainLightColor + giColor);

    half nDotV = dot(normalWS, viewDirectionWS);
    half fresnelValue = saturate(pow(abs(1.0 - nDotV), fresnelRange));
    half3 fresnelResult = dyedBaseColor * lightColor * fresnelColor * fresnelValue * fresnelPower;
    return fresnelResult;
}

#endif // MMN_CHARACTER_APPLY_FRESNEL_INCLUDED
