#ifndef MMN_CUTSCENE_UVFLOW_INPUT_INCLUDED
#define MMN_CUTSCENE_UVFLOW_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../CH/MMN_Character_Global_Input.hlsl"

TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);

TEXTURE2D(_SecondMap);
SAMPLER(sampler_SecondMap);

TEXTURE2D(_NoiseMap);
SAMPLER(sampler_NoiseMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _SecondMap_ST;
    float4 _NoiseMap_ST;

    float4 _Color;

    float _UVFlowSpeed;
    float _UVFlowPower;
CBUFFER_END

#endif // #ifndef MMN_CUTSCENE_UVFLOW_INPUT_INCLUDED
