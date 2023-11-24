// #ifndef MMN_CHARACTER_OUTLINE_VERTEX_PASS_INCLUDED
// #define MMN_CHARACTER_OUTLINE_VERTEX_PASS_INCLUDED

// #include "CharacterCommonAttributes.hlsl"
// #include "CharacterCommonBasePassVertex.hlsl"


// #ifdef _OUTLINE_FEATURE
// // float3 GetOutlineOffsetOS(float3 positionOS, float3 normalOS, float3 normalWS, float3 lightDirWS)
// // {
// //     const float OUTLINE_NEAR_WIDTH = 0.00012; // 근거리 굵기 : 카메라와 캐릭터 중심과의 거리가 1.5(최대 줌인 시 거리)일 때 적절한 값
// //     const float OUTLINE_FAR_WIDTH = 0.06; // 원거리 굵기 : 카메라와 캐릭터 중심과의 거리가 20.0(최대 줌아웃 시 거리)일 때 적절한 값
// //     const float OUTLINE_CAMERA_DISTANCE = 80.0; // 거리에 따른(근거리/원거리) 굵기에 대한 비율 보정용 값.
// //     const float OUTLINE_BASE_FOV = 36.0; // 이 FOV(Vertical)에서 의도한 굵기가 나온다.
// //     const float OUTLINE_MIN_WIDTH_RATE = -2.0; // 빛의 방향에 따라 굵기가 달라질 때, 최대 - 최소 비율. (값이 크면 비슷해지고, 값이 작으면 차이가 커진다.)
// //     #if defined(_IS_MONSTER)
// //         const float OUTLINE_WIDTH_SCALE = 2.0; // 최종 굵기의 보정값.
// //     #else
// //         const float OUTLINE_WIDTH_SCALE = 1.0; // 최종 굵기의 보정값.
// //     #endif
// //     const float RAD_TO_DEG_DOUBLE = 114.591559; // 2.0 * (180.0 / PI)

// //     float fov = atan(1.0 / unity_CameraProjection._m11) * RAD_TO_DEG_DOUBLE;
// //     float normalizedFov = (fov / OUTLINE_BASE_FOV);
// //     float depth = TransformObjectToHClip(positionOS).w;
// //     float viewDistance = (depth - (_ProjectionParams.y * _ProjectionParams.x)) * normalizedFov;
// //     float normalizedViewDistance = saturate(viewDistance / OUTLINE_CAMERA_DISTANCE);

// //     float maxOutlineWidth = lerp(OUTLINE_NEAR_WIDTH, OUTLINE_FAR_WIDTH, normalizedViewDistance);
// //     float minOutlineWidth = maxOutlineWidth * OUTLINE_MIN_WIDTH_RATE;

// //     float3 cameraDirWS = -GetViewForwardDir();
// //     // float rimArea = saturate(dot(normalWS, normalize(ProjectOnPlane(lightDirWS, cameraDirWS))));
// //     // float rimArea = saturate(dot(normalWS, lightDirWS));
// //     float rimArea = saturate(dot(normalWS, normalize(ProjectOnPlane(lightDirWS * float3(1.0, 0.3, 1.0), cameraDirWS))));

// //     // float nDotL = max(0.0, dot(normalWS, lightDirWS));
// //     // float lightingMask = max(0.0, 0.8 - nDotL);
// //     float lightingMask = 1.0 - rimArea;
// //     // lightingMask = saturate(lightingMask*4.0-2.0);

// //     float outlineWidth = lerp(minOutlineWidth, maxOutlineWidth, lightingMask);
// //     outlineWidth *= _OutlineWidth * OUTLINE_WIDTH_SCALE * 4;
// //     outlineWidth = max(0.0, outlineWidth); // 0보다 작아질 수 없다. 음수가 나오면 아웃라인이 반대로 뚫고 나올 수 있다.

// //     // 오브젝트의 스케일에 따라 아웃라인이 굵어지거나 가늘어지는 것을 보정한다.
// //     float3 scaleOS = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));

// //     float3 offset = normalOS.xyz * outlineWidth / scaleOS;
// //     return offset;
// // }

// float2 GetOutlineOffsetCS(float4 positionCS, float3 normalWS)
// {
//     const float OUTLINE_NEAR_WIDTH = 0.0028; // 근거리 굵기 : 카메라와 캐릭터 중심과의 거리가 1.5(최대 줌인 시 거리)일 때 적절한 값
//     const float OUTLINE_FAR_WIDTH = 0.00034; // 원거리 굵기 : 카메라와 캐릭터 중심과의 거리가 20.0(최대 줌아웃 시 거리)일 때 적절한 값
//     const float OUTLINE_CAMERA_DISTANCE = 20.0; // 로직에서 최대 줌아웃 시 거리
//     const float OUTLINE_MIN_WIDTH_RATE = 0.0; // 빛의 방향에 따라 굵기가 달라질 때, 최대 - 최소 비율. (값이 크면 비슷해지고, 값이 작으면 차이가 커진다.)
//     #ifdef _IS_SKIN
//         const float OUTLINE_WIDTH_SCALE = 1.0; // 최종 굵기의 보정값.
//     #else
//         const float OUTLINE_WIDTH_SCALE = (_ShadingType == MONSTER_SHADING) ? 2.0 : 1.0; // 최종 굵기의 보정값.
//     #endif

//     float viewDistance = positionCS.w;
//     float normalizedViewDistance = saturate(viewDistance / OUTLINE_CAMERA_DISTANCE);

//     float maxOutlineWidth = lerp(OUTLINE_NEAR_WIDTH, OUTLINE_FAR_WIDTH, normalizedViewDistance) * viewDistance;
//     float minOutlineWidth = maxOutlineWidth * OUTLINE_MIN_WIDTH_RATE;

//     Light mainLight = GetMainLight();
//     float3 cameraDirWS = -GetViewForwardDir();
//     float rimArea = saturate(dot(normalWS, normalize(ProjectOnPlane(mainLight.direction * float3(1.0, 0.3, 1.0), cameraDirWS))));
//     float lightingMask = 1.0 - rimArea;

//     float outlineWidth = lerp(minOutlineWidth, maxOutlineWidth, lightingMask);
//     outlineWidth *= _OutlineWidth * OUTLINE_WIDTH_SCALE;
//     outlineWidth = max(0.0, outlineWidth); // 0보다 작아질 수 없다. 음수가 나오면 아웃라인이 반대로 뚫고 나올 수 있다.

//     float2 normalCS = TransformWorldToHClipDir(normalWS, true).xy;
//     float2 screenOffset = max(_ScreenParams.x, _ScreenParams.y) / _ScreenParams.xy;

//     float2 offset = normalCS * screenOffset * outlineWidth;
//     return offset;
// }
// #endif

// ///////////////////////////////////////////////////////////////////////////////
// //                            Vertex functions                               //
// ///////////////////////////////////////////////////////////////////////////////
// Varyings OutlinePassVertex(Attributes input)
// {
//     Varyings output = (Varyings)0;

//     VECTOR_RIG_DEFORM(input, input.positionOS, input.normalOS, input.texcoord)

//     output.uv.xy = input.texcoord0.xy;
//     output.uv.zw = input.texcoord1.xy;
//     // output.color = input.color;

//     float3 positionOS = CharacterInflateWidth(input.positionOS.xyz, input.normalOS, _InflateWidth);
//     VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

// #ifdef _OUTLINE_FEATURE
//     // ----------------------------------------------------
//     // ObjectSpace에서 확장하는 방법.
//     // ----------------------------------------------------
//     // Light mainLight = GetMainLight();
//     // float3 offsetOS = GetOutlineOffsetOS(positionOS, input.normalOS, normalInput.normalWS, mainLight.direction);

//     // positionOS += offsetOS;
//     // VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);

//     // output.positionWS.xyz = vertexInput.positionWS;
//     // output.positionCS = vertexInput.positionCS;
//     // ----------------------------------------------------

//     // ----------------------------------------------------
//     // ClipSpace에서 확장하는 방법.
//     // ----------------------------------------------------
//     VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);
//     output.positionWS.xyz = vertexInput.positionWS;
//     output.positionCS = vertexInput.positionCS;

//     float2 offset = GetOutlineOffsetCS(vertexInput.positionCS, normalInput.normalWS);
//     output.positionCS.xy += offset;
//     output.positionCS.z *= 0.999; // NOTE @jihun.song: 얼굴처럼 실제 메시와 노멀이 다른 경우 아웃라인이 튀어나와 보일 수 있어서 살짝 납작하게 한다.
//     // TODO: OpenGLES 일 때는 아래에서 z값의 값을 변형해줘야 한다.
//     // #if UNITY_REVERSED_Z
//     //     output.positionCS.z = min(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
//     // #else
//     //     output.positionCS.z = max(output.positionCS.z, output.positionCS.w * UNITY_NEAR_CLIP_VALUE);
//     // #endif
//     // ----------------------------------------------------
// #else
//     VertexPositionInputs vertexInput = GetVertexPositionInputsForBending(positionOS);
// #endif

//     output.normalWS = normalInput.normalWS;
//     float crossSign = input.tangentOS.w * GetOddNegativeScale();
//     output.tangentWS = float4(normalInput.tangentWS, crossSign);
//     output.bitangentWS = normalInput.bitangentWS;
//     output.viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);

//     float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
//     output.fogCoord.x = fogFactor;

//     output.positionNDC = ComputeScreenPos(output.positionCS);

//     return output;
// }

// #endif // #ifndef MMN_CHARACTER_OUTLINE_VERTEX_PASS_INCLUDED
