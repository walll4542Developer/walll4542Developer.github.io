#ifndef MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED
#define MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED

#ifdef _ARBALEST_FEATURE

void ApplyArbalestMagazine(inout half4 resultColor, in half remainedMagazine, in half magazineNumber)
{
    if (remainedMagazine < magazineNumber)
    {
        resultColor.a = 0;
        clip(resultColor.a - 1);
    }
}

#endif // _ARBALEST_FEATURE

#endif // MMN_CHARACTER_APPLY_ARBALEST_MAGAZINE_INCLUDED
