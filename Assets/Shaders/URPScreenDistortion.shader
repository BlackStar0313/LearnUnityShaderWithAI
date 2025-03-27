Shader "Custom/URPScreenDistortion"
{
	Properties
	{
		_DistortionMap ("Distortion Map", 2D) = "white" {}
		_DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.02
		_Alpha ("Alpha", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"RenderPipeline"="UniversalPipeline"
			"Queue"="Transparent"
		}

		Pass
		{
			Name "ForwardLit"
			
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			// 注：在URP中，屏幕采样通常通过Render Feature实现
            // 这里仅作示例，实际应用需要配合C#脚本

			TEXTURE2D(_DistortionMap);
			SAMPLER(sampler_DistortionMap);

			CBUFFER_START(UnityPerMaterial)
			float4 _DistortionMap_ST;
			float _DistortionStrength;
			float _Alpha;
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
				float4 screenPos : TEXCOORD1;
			};
			
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.screenPos = OUT.positionHCS;

				// 转换UV
				OUT.uv = TRANSFORM_TEX(IN.uv, _DistortionMap);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				float2 distortion = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, IN.uv).rg;
				distortion = distortion * 2 - 1; // 将0-1范围转换为-1到1范围

				// 这里需要屏幕纹理采样，但完整实现需要Render Feature
                // 简化返回扭曲图案
                half4 finalColor = half4(distortion.r * 0.5 + 0.5, distortion.g * 0.5 + 0.5, 0, _Alpha);
                
                return finalColor;
			}
			ENDHLSL
		}
	}
}