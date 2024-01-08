#ifndef UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED
#define UNIVERSAL_DEPTH_ONLY_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../Includes/bendingVertex.hlsl"
#include "../Includes/EnvironmentHelper.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord : TEXCOORD0;
    half4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
    float4 color : COLOR;
    float4 screenPos : TEXCOORD1;
    float3 viewDir : TEXCOORD2;
    float cameraDistance : TEXCOORD3; //Test
    float4 positionWS : TEXCOORD4;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    // UNITY_VERTEX_OUTPUT_STEREO

};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    // UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);


    #if VERTEX_CAMERA_DEPEND_BENDING
        VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(input.positionOS.xyz);
        output.positionCS = vertexInput.positionCS;

    #elif VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION
        VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, 1 - saturate(input.color.aaaa + _VertexAniOn), _WindMultiply, _WindSpeedMultiply, /*float _GrassPushPower*/ 0, 1);
        output.positionCS = vertexInput.positionCS;

    #elif VERTEX_CAMERA_DEPEND_BENDING_N_WIND_ANIMATION_GRASS
        VertexPositionInputs vertexInput = GetVertexPositionInputs4treeShake(input.positionOS.xyz, _Global_VertexPositionOffset, _Global_VertexPositionOffset.z, input.color, _WindMultiply, _WindSpeedMultiply, _GrassPushPower, /* _VertexAniOn */ 1);
        output.positionCS = vertexInput.positionCS;

    #else
        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

    #endif

    output.viewDir = GetWorldSpaceViewDir(vertexInput.positionWS);
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.cameraDistance = distance(GetCameraPositionWS(), vertexInput.positionWS);
    output.positionWS.xyz = vertexInput.positionWS;

    return output;
}

half4 DepthOnlyFragment(Varyings input) : SV_TARGET
{
    // UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    UNITY_SETUP_INSTANCE_ID(input);

    half4 diffuseAlpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    half alpha = diffuseAlpha.a * _BaseColor.a;

    #if defined(_GLOBAL_NEARHALFTONECLIP_ON) && defined(_NEARHALFTONECLIP_ON)
        {
            //가까워지면 하프톤으로 사라지게 하는 기능
            half halftoneAlpha;
            float cameraDistance = input.cameraDistance  ;
            NearHarftoneAlphaTesting(cameraDistance, input.screenPos, 0.5, halftoneAlpha);
            clip(halftoneAlpha);
        }
    #endif

    #if defined(_ALPHATEST_ON)
        clip(alpha - _Cutoff);
        alpha = 1;//없으면 댑스문제로 번쩍거림
    #else
        alpha = 1;
    #endif

    #if RAYCAST
        //레이케스트 되면 사라지는 기능
        half RaycasthalftoneAlpha;
        float dist = distance((input.screenPos.xy / input.screenPos.w - 0.5), float2(0, 0));
        dist = saturate(dist);
        dist = pow(dist, 1.5);
        // dist = pow(dist,10);
        dist = saturate(dist);
        dist += 2 - (_RaycastHarftoneClip * 2);
        Unity_Dither_linear(dist, input.screenPos, RaycasthalftoneAlpha);
        RaycasthalftoneAlpha = saturate(RaycasthalftoneAlpha);
        clip(RaycasthalftoneAlpha - _Cutoff);
    #endif

    #if LODFADE
        //LOD 디더링 기능
        float fadeValue;
        float lodFade;
        if (unity_LODFade.x != 0)
        {
            if (unity_LODFade.x > 0)
            {
                fadeValue = unity_LODFade.x ;
            }
            else
            {
                fadeValue = 1 + unity_LODFade.x;
            }
            Unity_Dither_linear(fadeValue, input.screenPos, lodFade);
            clip(lodFade);
        }
        else
        {
            fadeValue = 1;
        }
    #endif

    #if TREELODFADE
        //LOD 디더링 기능
        float fadeValue;
        float lodFade;
        if (unity_LODFade.x != 0)
        {
            if (unity_LODFade.x > 0)
            {
                fadeValue = pow(unity_LODFade.x, 1) ;
            }
            else
            {
                fadeValue = 1 + unity_LODFade.x;
            }
            Unity_Dither_linear(fadeValue, input.screenPos, lodFade, 0.5);
            clip(lodFade);
        }
        else
        {
            fadeValue = 1;
        }
    #endif

    return 0;
}
#endif
