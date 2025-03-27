Shader "Custom/URPNoiseEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1, 1, 1, 1)
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseScale ("Noise Scale", Range(0.01, 10.0)) = 1.0
		_NoiseStrength ("Noise Strength", Range(0, 1)) = 0.1
		_NoiseSpeed ("Noise Speed", Vector) = (1, 1, 0, 0)
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
			Name "ForwardUnlit"
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_NoiseTex);
			SAMPLER(sampler_NoiseTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float _NoiseScale;
			float _NoiseStrength;
			float2 _NoiseSpeed;
			half4 _Color;
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
				float3 worldPos : TEXCOORD1; 
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.worldPos = mul(unity_ObjectToWorld, IN.positionOS).xyz;
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Color;

				//创建动态噪声UV
				float2 noiseUV = IN.worldPos.xz * _NoiseScale + _Time.y * _NoiseSpeed;

				//采样噪声纹理
				float noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, noiseUV).r;

				//添加噪声效果
				color.rgb += (noise - 0.5) * _NoiseStrength;
				return color;
			}
			ENDHLSL
		}
	}	
}
	