#ifndef MMN_FX_SHADOW_CASTER_INPUT_INCLUDED
#define MMN_FX_SHADOW_CASTER_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
CBUFFER_END

#endif // MMN_FX_SHADOW_CASTER_INPUT_INCLUDED