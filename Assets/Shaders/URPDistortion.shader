Shader "Custom/URPDistortion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_DistortionTex ("Distortion Texture", 2D) = "white" {}
		_DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.1
		_DistortionSpeed ("Distortion Speed", Vector) = (1, 1, 0, 0)
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

			TEXTURE2D(_DistortionTex);
			SAMPLER(sampler_DistortionTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _DistortionTex_ST;
			float _DistortionStrength;
			float2 _DistortionSpeed;
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
				float2 uvDistortion : TEXCOORD1;
			};
			
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uvMain = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.uvDistortion = TRANSFORM_TEX(IN.uv, _DistortionTex) + _Time.y * _DistortionSpeed;
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 distortionColor = SAMPLE_TEXTURE2D(_DistortionTex, sampler_DistortionTex, IN.uvDistortion);

				float distortion = distortionColor.r * _DistortionStrength;
				float2 distortedUV = IN.uvMain + distortion;

				half4 finalColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, distortedUV);
				return finalColor;
			}
			ENDHLSL
		}
	}
}
