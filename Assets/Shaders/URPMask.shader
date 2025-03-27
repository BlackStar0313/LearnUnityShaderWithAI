Shader "Custom/URPMask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_SecondTex ("Second Texture", 2D) = "white" {}
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_SecondColor ("Second Color", Color) = (1,1,1,1)
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

			TEXTURE2D(_MaskTex);
			SAMPLER(sampler_MaskTex);

			TEXTURE2D(_SecondTex);
			SAMPLER(sampler_SecondTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float4 _SecondTex_ST;
			float4 _MainColor;
			float4 _SecondColor;
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
				half4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				half4 maskColor = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, IN.uv);
				half4 secondColor = SAMPLE_TEXTURE2D(_SecondTex, sampler_SecondTex, IN.uv);
				
				half4 finalColor = lerp(mainColor, secondColor, maskColor.r);
				return finalColor;
			}
			ENDHLSL
		}
	}
}