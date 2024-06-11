#ifndef MMN_GLOBAL_TEXTURE_INCLUDED
#define MMN_GLOBAL_TEXTURE_INCLUDED

//GlobalTexture + Global GI holder

float _Global_WindUV;
float4 _Global_pos;
float _Global_CloudDensity;
// float _Global_CloudSpeed;
float _Global_CloudScale;
float _Global_CloudEdgeHardness;
float4 _Global_GILightMulti;
float _ReceiveGIStrength;
float _Global_ContactShadowStrength;

void InitializeGlobalValue()
{
    if (IsNaN(_Global_WindUV))
    {
        _Global_WindUV = 0;
    }

    if (IsNaN(_Global_ContactShadowStrength))
    {
        _Global_ContactShadowStrength = 0.0;
    }
}

TEXTURE2D(_Global_Texture);        SAMPLER(sampler_Global_Texture);

#endif
