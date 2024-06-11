#ifndef MMN_Night2DayControl_INCLUDED
#define MMN_Night2DayControl_INCLUDED

#include "Assets/PatchableAssets/Shaders/MMN/Includes/WeatherControlHolder.hlsl"


float _Global_Night2Day;


/////////////////////////////////////////////////////////////////////////////////
//                낮 밤에 따른 유리창 빛남 계산                       //
/////////////////////////////////////////////////////////////////////////////////

float3 night2DayControl(float3 _EmissionColorBright, float3 _EmissionColorDark, float _OutsideorInside, float _TempNight2DaySwitchTest)
{
    float night2day = _Global_Night2Day * (1 - _TempNight2DaySwitchTest);
    //안과 밖일때는 반대로 동작
    night2day = abs(night2day - _OutsideorInside);

    float3 windowNightDayColor = lerp(_EmissionColorBright.rgb, _EmissionColorDark.rgb, night2day);
    return windowNightDayColor;
}


#endif
