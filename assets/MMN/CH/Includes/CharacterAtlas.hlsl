#ifndef MMN_CHARACTER_ATLAS_HELPER_INCLUDED
#define MMN_CHARACTER_ATLAS_HELPER_INCLUDED

float2 ConvertToAtlasUV(half2 atlasSize, half atlasIndexFromOne, half4 scalePosition, half rotation, float2 originUV)
{
    half atlasColNum = atlasSize.x;
    half atlasRowNum = atlasSize.y;
    half atlasIndex = (atlasIndexFromOne - 1.0) + 0.001;

    half2 offsetScale = scalePosition.xy;
    half2 offsetScaleInv = 1.0 / scalePosition.xy;
    half2 offsetPosition = scalePosition.zw * 0.1;

    half2 atlasScale = half2(1.0 / atlasColNum, 1.0 / atlasRowNum);
    half2 atlasIndex2D = half2(floor(atlasIndex) - atlasColNum * floor(atlasIndex / atlasColNum), floor(atlasIndex / atlasColNum));
    half2 atlasOffset = atlasScale * atlasIndex2D;

    // 기본 크기 및 오프셋 위치 적용함.
    float2 convertedUV = originUV * offsetScaleInv;
    convertedUV += (1.0 - offsetScaleInv) * 0.5;
    convertedUV -= offsetPosition;

    // 회전시킴.
    float s, c;
    sincos(DegToRad(rotation), s, c);
    float2x2 rotationMatrix = float2x2(c, -s, s, c);
    convertedUV -= 0.5;
    convertedUV = mul(convertedUV, rotationMatrix);
    convertedUV += 0.5;

    convertedUV *= atlasScale;

    // 선택한 아틀라스 위치로 조정함.
    convertedUV += atlasOffset;

    // 현재 선택한 아틀라스 범위를 벗어나는 uv를 컷함.
    convertedUV = (convertedUV < atlasOffset) ? atlasOffset : ((convertedUV > (atlasScale + atlasOffset)) ? (atlasScale + atlasOffset) : convertedUV);

    return convertedUV;
}

float2 TransformUV(half4 scalePosition, half rotation, float2 originUV)
{
    half2 offsetScale = scalePosition.xy;
    half2 offsetScaleInv = 1.0 / scalePosition.xy;
    half2 offsetPosition = scalePosition.zw * 0.1;

    // 기본 크기 및 오프셋 위치 적용함.
    float2 convertedUV = originUV * offsetScaleInv;
    convertedUV += (1.0 - offsetScaleInv) * 0.5;
    convertedUV -= offsetPosition;

    // 회전시킴.
    float s, c;
    sincos(DegToRad(rotation), s, c);
    float2x2 rotationMatrix = float2x2(c, -s, s, c);
    convertedUV -= 0.5;
    convertedUV = mul(convertedUV, rotationMatrix);
    convertedUV += 0.5;

    return convertedUV;
}

// 레거시 방식의 눈에서 사용하고 있어서 일단 유지함.
void CalcUvOffsetScale_Legacy(half colNum, half rowNum, half index, out float2 uvOffset, out float2 uvScale)
{
    uvScale = float2(1.0 / colNum, 1.0 / rowNum);
    index = index + 0.1;
    float2 index2d = float2(floor(index) - colNum * floor(index / colNum), floor(index / colNum));
    uvOffset = uvScale * index2d;
}

#endif // MMN_CHARACTER_ATLAS_HELPER_INCLUDED
