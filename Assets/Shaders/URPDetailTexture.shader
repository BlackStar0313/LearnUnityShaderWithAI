Shader "Custom/URPDetailTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainColor ("Main Color", Color) = (1, 1, 1, 1)
		_DetailTex ("Detail Texture", 2D) = "gray" {}
		_DetailStrength ("Detail Strength", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}
	
		Pass
		{
			Name "ForwardLit"
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_DetailTex);
			SAMPLER(sampler_DetailTex);
			
			CBUFFER_START(UnityPerMaterial)
			float4 _MainColor;
			float4 _DetailTex_ST;
			float4 _MainTex_ST;
			float _DetailStrength;
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
				float2 uvDetail : TEXCOORD1;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.uvDetail = TRANSFORM_TEX(IN.uv, _DetailTex);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				//采样基础纹理
				float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _MainColor;
				float4 detailTex = SAMPLE_TEXTURE2D(_DetailTex, sampler_DetailTex, IN.uvDetail);

				// 将细节纹理转换为细节因子（灰度值的2倍减1，范围从[0,1]变为[-1,1]）
				half detailFactor = detailTex.r * 2.0 - 1.0;

				// 使用细节因子调整基础纹理的颜色
				mainTex.rgb += detailFactor * _DetailStrength;

				return mainTex;
			}
			ENDHLSL
		}
	}
}