Shader "Custom/URPDissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DissolveTex ("Dissolve Texture", 2D) = "white" {	}
		_DissolveThreshold ("Dissolve Threshold", Range(0, 1)) = 0.5
		_EdgeColor ("Edge Color", Color) = (1,1,1,1)
		_EdgeWidth ("Edge Width", Range(0, 1)) = 0.1
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
			"Queue"="Geometry"
		}

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_DissolveTex);
			SAMPLER(sampler_DissolveTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _DissolveTex_ST;
			float4 _EdgeColor;
			float _DissolveThreshold;
			float _EdgeWidth;
			CBUFFER_END
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uvMain : TEXCOORD0;
				float2 uvDissolve : TEXCOORD1;
			};
			
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uvMain = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.uvDissolve = TRANSFORM_TEX(IN.uv, _DissolveTex);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMain);
				half4 dissolveColor = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, IN.uvDissolve);

				float dissolveValue = dissolveColor.r - _DissolveThreshold;
				
				clip(dissolveValue);

				//计算边缘颜色
				if (dissolveValue < _EdgeWidth)
				{
					return _EdgeColor;
				}

				return mainColor;
			}
			ENDHLSL
		}
	}
}