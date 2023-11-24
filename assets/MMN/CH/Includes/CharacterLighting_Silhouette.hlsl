#ifndef MMN_CHARACTER_LIGHTING_SILHOUETTE
#define MMN_CHARACTER_LIGHTING_SILHOUETTE

struct SilhouetteInput
{
    float3 lightDir;
    float3 lightColor;

    float3 normalWS;
    float3 cameraDirWS;

    float nDotV;
    float receivedShadow;
    float3 dyedBaseColor;

    // float silhouetteMask;
    float3 silhouetteTintColor;
};

struct SilhouetteResult
{
    float silhouette;
    float3 silhouetteColor;
};

float3 ProjectOnPlane(float3 vec, float3 normal)
{
    return vec - normal * (dot(vec, normal) / dot(normal, normal));
}

//-----------------------------------------------------------------------------
// Silhouette
//-----------------------------------------------------------------------------
void GetSilhouette(in float shadingType, in SilhouetteInput input, out SilhouetteResult result)
{
#ifdef _SILHOUETTE_OFF
    result.silhouette = 0;
    result.silhouetteColor = float3(0, 0, 0);
#else
    float silhouette = 0;
    float3 silhouetteColor = float3(0, 0, 0);

    // 조명을 카메라를 노말로 하는 평면에 프로젝션한 다음 노말과 곱한다. 이렇게 하면 마치 조명이 카메라 사이드를 회전하는 것처럼 보인다.
    // y축 영향은 줄여서 좌우로만 생기도록 유도
    float rimArea = saturate(dot(input.normalWS, normalize(ProjectOnPlane(input.lightDir * float3(1.0, 0.3, 1.0), input.cameraDirWS))));
    float rimBand = saturate((1.0 - input.nDotV) * 10.0 - 6.0);

    silhouette = rimBand * rimArea * (input.receivedShadow * 0.6 + 0.4);

    if (shadingType == MONSTER_SHADING)
    {
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * float3(5.0, 5.0, 4.0) * 1.0 + float3(0.05, 0.15, 0.25));
    }
    else if (shadingType == SKIN_SHADING)
    {
        // 림라이트 경계에 빨간선이 나오게 한다. 다른 피부색에서 잘못 나올 수 있다. 피부색 바꿔가면서 다시 잡아야할 수 있다.
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * float3(5.0, 2.0, 1.0) * 0.5;
    }
    else if (shadingType == DEEP_SHADING)
    {
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * float3(0.5, 0.0, 0.0));
    }
    else //if (shadingType == STANDARD_SHADING)
    {
        // 옷은 텍스쳐색을 곱하는 것과 그냥 더하는 것 둘 다 해야 함.
        // 텍스쳐색을 곱하는 것은 보통의 디퓨즈라이팅이고 그냥 더하는 것은 리플랙션의 느낌임.
        // 블랙색상의 옷이라면 약간 푸른빛이 돌게 된다.
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * float3(5.0, 5.0, 4.0) * 1.0 + float3(0.05, 0.15, 0.25));
    }

    result.silhouette = silhouette;// * input.silhouetteMask;
    result.silhouetteColor = silhouetteColor;
#endif
}

#endif // MMN_CHARACTER_LIGHTING_SILHOUETTE
