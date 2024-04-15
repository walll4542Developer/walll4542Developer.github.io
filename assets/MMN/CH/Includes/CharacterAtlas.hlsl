#ifndef MMN_CHARACTER_ATLAS_HELPER_INCLUDED
#define MMN_CHARACTER_ATLAS_HELPER_INCLUDED

float2 ConvertToAtlasUV(float2 atlasSize, float atlasIndexFromOne, float4 scalePosition, float rotation, float2 originUV)
{
    float atlasColNum = atlasSize.x;
    float atlasRowNum = atlasSize.y;
    float atlasIndex = (atlasIndexFromOne - 1.0) + 0.001;

    float2 offsetScale = scalePosition.xy;
    float2 offsetScaleInv = 1.0 / scalePosition.xy;
    float2 offsetPosition = scalePosition.zw * 0.1;

    float2 atlasScale = float2(1.0 / atlasColNum, 1.0 / atlasRowNum);
    float2 atlasIndex2D = float2(floor(atlasIndex) - atlasColNum * floor(atlasIndex / atlasColNum), floor(atlasIndex / atlasColNum));
    float2 atlasOffset = atlasScale * atlasIndex2D;

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

float2 TransformUV(float4 scalePosition, float rotation, float2 originUV)
{
    float2 offsetScale = scalePosition.xy;
    float2 offsetScaleInv = 1.0 / scalePosition.xy;
    float2 offsetPosition = scalePosition.zw * 0.1;

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
void CalcUvOffsetScale_Legacy(float colNum, float rowNum, float index, out float2 uvOffset, out float2 uvScale)
{
    uvScale = float2(1.0 / colNum, 1.0 / rowNum);
    index = index + 0.1;
    float2 index2d = float2(floor(index) - colNum * floor(index / colNum), floor(index / colNum));
    uvOffset = uvScale * index2d;
}

#endif // MMN_CHARACTER_ATLAS_HELPER_INCLUDED
