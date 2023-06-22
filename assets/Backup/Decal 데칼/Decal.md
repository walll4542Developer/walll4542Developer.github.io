유니티 이전 버전에서 데칼은 에디터에서만 작동하고 빌드하면 렌더링이 안되는 유니티 버그가 있었죠. 

최근에 유니티 버전업을 했으니 URP 빌트인 데칼이 지금은 잘 되는지 확인해 볼 수가 있게 되었습니다.

 



(텍스쳐는 요렇게 알파가 있는 것을 사용했습니다)

빌트인 데칼은 렌더러 피처쪽에서 뎁스노말(DepthNormal) 패스를 사용 해야만 렌더링이 가능한데,

MM에서는 뎁스노말 패스를 사용하지 않으니 작동이 안됩니다… 주르륵…

게다가 빌트인 데칼은 특정 레이어의 오브젝트 위에는 렌더링 되지 않게 해주는 레이어 마스크 기능도 없어서

차라리 데칼 셰이더를 처음부터 새로 만들기로 했습니다.

작업 계획
시중에 많이 알려져있는 스크린 스페이스 데칼 방식을 사용해서 제작합니다.

D 버퍼를 쓰지 않아서 제작하기 쉽고 간단하고 가볍습니다.
구조가 간단해서 확장성이 좋고 추가 스펙이 생겨도 대응할 수 있기 때문입니다.
스크린 스페이스 데칼은 셰이더가 적용된 큐브를 배치해서 사용 할 수 있어야 합니다.


큐브를 배치 했을 때 큐브의 밑면 중에서 바닥에 닿는 경계 부분의 픽셀을 검출해내야 하고, 그 픽셀에만 데칼 텍스쳐가 입혀지는 것을 계산해야 합니다.

 



저희는 카메라 뎁스를 이용하여 씬 전체의 깊이 값을 알아낼 수 있고, 이를 바탕으로 경계면이 어디인지 판단 할 수 있습니다. 그렇게 알아낸 경계면을 마젠타로 표시했습니다. 이제 마젠타로 칠한 부분의 픽셀만 살리고 나머지 픽셀은 버려야합니다.

 



그건 어떻게 판단하냐면 큐브를 오브젝트 스페이스로 계산하면 됩니다.

유니티에서 큐브를 만들면 1.0 * 1.0 * 1.0 크기의 정육면체가 생성이 되고, 피벗은 자동으로 중심에 위치하게 되어있습니다.

따라서 정육면체 버텍스 위치에 해당하는 오브젝트 스페이스의 좌표에서 xyz 각 축마다 범위는 -0.5 ~ 0,5가 되는 것입니다.

예를 들어 float3(0.1, -0.1, -0.5)는 마젠타로 표시한 경계면 픽셀 내부에 있다는 것을 알 수 있으며, float3(0.4, 0.8, -0.5)는 y축이 0.8이 되어 경계면 외부에 있다고 알 수 있습니다.

 



UV 매핑은 더 쉽습니다. 오브젝트 포지션 값중 Y축을 제거하고 그대로 UV로 사용하면 됩니다. 

큐브의 오브젝트 포지션 중에서 X와 Z축만 남기고 각 축의 범위는 -0.5 ~ 0.5 라는 것을 위에서 알았으니까

단순히 0.5만큼 더하면 0 ~ 1이 되겠군요. UV가 완성되었습니다.

작업 내용
                 float2 screenUV = input.screenPos.xy / input.screenPos.w * 2 - 1;
				float rawDepth = SampleSceneDepth(input.screenPos.xy / input.screenPos.w);
				float3 negateScreenPos = float3(screenUV.x, -1 * screenUV.y, rawDepth);
계획대로 먼저 스크린 UV를 중앙 정렬한 다음 y축을 반전하고 카메라 뎁스 텍스쳐인 `rawDepth` 와 묶습니다.

(y축을 반전하는 이유는 데칼이 경계면 바닥을 향하게 하기 위해서입니다)

 



				float4 decalWorldSpace = mul(UNITY_MATRIX_I_VP, float4(negateScreenPos, 1));
				float3 decalObjectSpace = TransformWorldToObject(decalWorldSpace.xyz / decalWorldSpace.w);
스크린 스페이스 포지션과 뎁스를 월드 포지션으로 트랜스폼하면 카메라 뎁스 또한 월드 스페이스가 됩니다.

그리고 스크린 스페이스 포지션을 뎁스 값으로 나누면 스크린 스페이스에 깊이가 추가됩니다.

이제 쓸모없는 픽셀을 잘라내기 위해서 큐브를 오브젝트 포지션으로 트랜스폼 합니다.

				float3 a = step(-0.5, decalObjectSpace);
				float3 b = 1 - (step(0.5, decalObjectSpace));
				float boundingBox = all(a * b);
xyz 각 축의 범위는 -0.5 ~ 0.5라는 것을 알고 있으니 step()함수를 사용해서 0.5 이상, -0.5 미만의 픽셀을 값은 0으로 만들어 잘라냅니다.

 

				float2 uv = (decalObjectSpace + 0.5).xy;
				float4 decalBaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);

				float3 color = decalBaseMap.rgb;
				float alpha = boundingBox * decalBaseMap.a;
그리고 오브젝트 스페이스를 0.5만큼 더한 값을 uv로 사용하면 마무리 됩니다.

결과물


아쉽게도 이 상태 그대로 빌드에서 사용할 수는 없습니다.

특정 레이어의 오브젝트 위에는 렌더링 되지 않게 해주는 레이어 마스크 기능이 빠져있어서

위 움짤 처럼 캐릭터 위나 모닥불 프랍 위에도 데칼이 그려지는 것을 볼 수 있습니다.

또한 세로가 긴 배경 오브젝트의 위에도 데칼이 늘어져서 그려지는 현상도 해결해야 합니다.

 

그래서 차후 레이어 마스크 기능을 추가하고 셰이더를 개선하는 작업을 진행할 예정입니다.

레퍼런스 / 참고자료
유니티 URP 데칼 : https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@16.0/manual/renderer-feature-decal.html 