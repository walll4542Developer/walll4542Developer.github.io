Shader "MMN/FX/FX_Opaque_VertexOffset_NoShadow"
{
    Properties
    {
        [Enum(ParticleSystem, 0, Generic, 1)] _OffsetMode ("오프셋 모드 설정", Float) = 0

        [Header(RenderState Options)][Space()]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Z Test", Float) = 4

        [Header(Base Color Settings)][Space()]
        _MainTex (" 메인 텍스처 (RGB : 색상 / A : 알파 컷오프)", 2D) = "white" {}
		_Color ("기본 컬러", Color) = (1, 1, 1, 1)
        _Intensity_Color ("기본 컬러 강도", Float) = 1
        _AlphaCutoff ("알파 컷오프 (메인 텍스처 A 채널 사용)", Range(0, 1)) = 0.5

        [Space(10)][Header(Vertex Movment Settings)][Space()]
        _Sphereofinfluence ("움직임 영향력 범위", Range(0, 0.9)) = 0.9
        _VelocityVector ("움직일 방향 축 설정", Vector) = (0, 1, 0, 0)
        _TimeSpeed ("움직임 속도", Float) = 1
		_Threshold ("움직임 강도", Float) = 10
		_SinScope ("움직임 노이즈 조절", Float) = 20

        [Space(10)][Header(Rendering Options)][Space()]
        [Toggle(_FOG_RCV_ON)] _FogReceive ("안개 적용", Float) = 0
		_FogPower ("안개 받기 정도", Range(0, 1)) = 0
		[Toggle(_LIGHTRECEIVE_ON)] _LightReceive ("빛 적용", Float) = 0
		_LightRatio ("빛 받기 정도", Range(0, 1)) = 1

	    [HideInInspector] _Mode ("__mode", Float) = -1
		[HideInInspector] _TransitionValue ("_TransitionValue", Float) = 1
    }

    SubShader
    {
		Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "ShaderModel" = "4.5"
        }

        Pass
        {
            Name "Base"

			Cull [_CullMode]
			Blend Off
			ZTest [_ZTest]
			ZWrite On
			ColorMask RGBA

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore d3d9
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
			#pragma multi_compile_local _ _FOG_RCV_ON
			#pragma multi_compile_local _ _LIGHTRECEIVE_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // Vertex and Fragment
            #pragma vertex vert
            #pragma fragment frag

            #include "FX_Opaque_VertexOffset_Input.hlsl"
            #include "FX_Opaque_VertexOffset_ForwardPass.hlsl"

            ENDHLSL
        }
     }

    Fallback off
}
