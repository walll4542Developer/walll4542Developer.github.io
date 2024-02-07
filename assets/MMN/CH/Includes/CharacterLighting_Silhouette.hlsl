#ifndef MMN_CHARACTER_LIGHTING_SILHOUETTE
#define MMN_CHARACTER_LIGHTING_SILHOUETTE

struct SilhouetteInput
{
    half3 lightDir;
    half3 lightColor;

    half3 normalWS;
    half3 cameraDirWS;

    half nDotV;
    half receivedShadow;
    half3 dyedBaseColor;

    // half silhouetteMask;
    half3 silhouetteTintColor;
};

struct SilhouetteResult
{
    half silhouette;
    half3 silhouetteColor;
};

half3 ProjectOnPlane(half3 vec, half3 normal)
{
    return vec - normal * (dot(vec, normal) / dot(normal, normal));
}

//-----------------------------------------------------------------------------
// Silhouette
//-----------------------------------------------------------------------------
void GetSilhouette(in SilhouetteInput input, out SilhouetteResult result)
{
#ifdef _SILHOUETTE_OFF
    result.silhouette = 0;
    result.silhouetteColor = half3(0, 0, 0);
#else
    half silhouette = 0;
    half3 silhouetteColor = half3(0, 0, 0);

    // 조명을 카메라를 노말로 하는 평면에 프로젝션한 다음 노말과 곱한다. 이렇게 하면 마치 조명이 카메라 사이드를 회전하는 것처럼 보인다.
    // y축 영향은 줄여서 좌우로만 생기도록 유도
    half rimArea = saturate(dot(input.normalWS, normalize(ProjectOnPlane(input.lightDir * half3(1.0, 0.3, 1.0), input.cameraDirWS))));
    half rimBand = saturate((1.0 - input.nDotV) * 10.0 - 6.0);

    silhouette = rimBand * rimArea * (input.receivedShadow * 0.6 + 0.4);

    #if defined(_SHADINGTYPE_MONSTER)
    {
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * half3(5.0, 5.0, 4.0) * 1.0 + half3(0.05, 0.15, 0.25));
    }
    #elif (defined(_SHADINGTYPE_SKINBODY) || defined(_SHADINGTYPE_SKINFACE))
    {
        // 림라이트 경계에 빨간선이 나오게 한다. 다른 피부색에서 잘못 나올 수 있다. 피부색 바꿔가면서 다시 잡아야할 수 있다.
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * half3(5.0, 2.0, 1.0) * 0.5;
    }
    #elif defined(_SHADINGTYPE_DEEP)
    {
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * half3(0.5, 0.0, 0.0));
    }
    #else // _SHADINGTYPE_STANDARD || _SHADINGTYPE_STOCKINGS
    {
        // 옷은 텍스쳐색을 곱하는 것과 그냥 더하는 것 둘 다 해야 함.
        // 텍스쳐색을 곱하는 것은 보통의 디퓨즈라이팅이고 그냥 더하는 것은 리플랙션의 느낌임.
        // 블랙색상의 옷이라면 약간 푸른빛이 돌게 된다.
        silhouetteColor = (input.lightColor * input.silhouetteTintColor.rgb) * (input.dyedBaseColor * half3(5.0, 5.0, 4.0) * 1.0 + half3(0.05, 0.15, 0.25));
    }
    #endif

    result.silhouette = silhouette;// * input.silhouetteMask;
    result.silhouetteColor = silhouetteColor;
#endif
}

#endif // MMN_CHARACTER_LIGHTING_SILHOUETTE
