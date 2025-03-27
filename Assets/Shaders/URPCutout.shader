Shader "Custom/URPCutout"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_Cutoff ("Cutoff", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"RenderPipeline"="UniversalPipeline"
			"Queue"="Transparent"
		}
		
		//保留深度写入
		ZWrite On

		Pass
		{
			Name "ForwardUnlit"
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BaseColor;
			float _Cutoff;
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
				//如果alpha小于cutoff，则不渲染, 丢弃片元
				clip(color.a - _Cutoff);
				return color * _BaseColor;
			}
			ENDHLSL
		}
	}
}
