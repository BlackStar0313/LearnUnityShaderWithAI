Shader "Custom/URPBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)

		//混合
		[Enum(UnityEngine.Rendering.BlendMode)]
		_SrcBlend ("Src Blend", int) = 5 // srcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)]
		_DstBlend ("Dst Blend", int) = 10 // oneMinusSrcAlpha
    }

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"RenderPipeline"="UniversalPipeline"
			"Queue"="Transparent"
		}

		Blend [_SrcBlend] [_DstBlend]
		ZWrite Off
		
		Pass
		{
			Name "Blend"
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BaseColor;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				return color * _BaseColor;
			}
			ENDHLSL
		}
	}
}