#ifndef MMN_FX_FRESNELEFFECT
#define MMN_FX_FRESNELEFFECT

float3 ApplyFresnelEffect(float3 normalWS, float3 viewDirectionWS,
    float3 fresnelColor, float fresnelRange, float fresnelPower)
{
    float nDotV = dot(normalWS, viewDirectionWS);
    float fresnelValue = saturate(pow(abs(1.0 - nDotV), fresnelRange));
    float3 fresnelResult = fresnelColor * fresnelValue * fresnelPower;
    return fresnelResult;
}

#endif