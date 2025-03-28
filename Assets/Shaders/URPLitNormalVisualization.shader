//通过法线方向来可视化模型曲面
Shader "Custom/URPLitNormalVisualization"
{
	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}

		pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float3 normalWS : NORMAL;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				//将法线从 【-1,1】 映射到 【0,1】
				float3 normalColor = normalize(input.normalWS) * 0.5 + 0.5;
				return float4(normalColor, 1.0);
			}

			ENDHLSL
		}
	}
}