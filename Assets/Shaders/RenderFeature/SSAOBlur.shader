Shader "Custom/SSAOBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque"  "RenderPipeline" = "UniversalPipeline"}

		ZTest Always
		ZWrite Off 
		Cull Off 

		// Pass 0: 水平模糊
		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert 
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

			CBUFFER_START(UnityPerMaterial)
			    float _BlurSize;
			CBUFFER_END

			float4 frag(Varyings input) : SV_Target
			{
				float2 uv = input.texcoord;
				float2 texelSize = 1.0 / _ScreenParams.xy;

				float weight[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};

				float result = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).r * weight[0];

				for (int i = 1; i < 5; i++)
				{
					float offset = texelSize.x * i * _BlurSize;
					result += SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv + float2(offset, 0)).r * weight[i];
					result += SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv - float2(offset, 0)).r * weight[i];
				}

				return float4(result, result, result, 1);
			}
			ENDHLSL
		}

		// Pass 1: 垂直模糊
		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

			CBUFFER_START(UnityPerMaterial)
			    float _BlurSize;
			CBUFFER_END

			float4 frag(Varyings input) : SV_Target
			{
				float2 uv = input.texcoord;
				float2 texelSize = 1.0 / _ScreenParams.xy;

				float weight[5] = {0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216};

				float result = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).r * weight[0];

				for (int i = 1; i < 5; i++)
				{
					float offset = texelSize.y * i * _BlurSize;
					result += SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv + float2(0, offset)).r * weight[i];
					result += SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv - float2(0, offset)).r * weight[i];
				}

				return float4(result, result, result, 1);
			}
			ENDHLSL
		}
	}
}