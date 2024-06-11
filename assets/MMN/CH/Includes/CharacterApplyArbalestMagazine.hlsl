#ifndef MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED
#define MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED

#ifdef _ARBALEST_FEATURE

void ApplyArbalestMagazine(inout float4 resultColor, in float remainedMagazine, in float magazineNumber)
{
    if (remainedMagazine < magazineNumber)
    {
        resultColor.a = 0;
        clip(resultColor.a - 1);
    }
}

#endif // _ARBALEST_FEATURE

#endif // MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED
