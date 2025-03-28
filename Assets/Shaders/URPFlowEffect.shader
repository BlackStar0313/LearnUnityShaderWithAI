Shader "Custom/URPFlowEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_FlowTex ("Flow Texture", 2D) = "gray" {}
		_FlowSpeed ("Flow Speed", Range(0, 5)) = 1
		_FlowStrength ("Flow Strength", Range(0, 1)) = 0.1
		_FlowOffset ("Flow Offset", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags {
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

			TEXTURE2D(_FlowTex);
			SAMPLER(sampler_FlowTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _FlowTex_ST;
			float _FlowSpeed;
			float _FlowStrength;
			float _FlowOffset;
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
				float2 flowUV: TEXCOORD1;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);
				output.flowUV = TRANSFORM_TEX(input.uv, _FlowTex);
				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				//采样流向图
				half2 flowVector = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, input.flowUV).rg;
				flowVector = flowVector * 2.0 - 1.0; //归一化到[-1,1]

				//计算流动方向
				float flowTime = frac(_Time.y * _FlowSpeed);

				//创建两个相位，用于混合，避免循环跳变
				float phase0 = flowTime;
				float phase1 = frac(flowTime + 0.5);

				//计算混合权重
				float blendWeight = abs((phase0 - 0.5) * 2.0);

				//计算两个采样UV
				float2 uvOffset0 = flowVector * _FlowStrength * phase0;
				float2 uvOffset1 = flowVector * _FlowStrength * phase1;

				float2 uv0 = input.uv - uvOffset0;
				float2 uv1 = input.uv - uvOffset1;

				//采样两个相位纹理
				half4 baseColor0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv0);
				half4 baseColor1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv1);

				//混合颜色
				half4 finalColor = lerp(baseColor0, baseColor1, blendWeight) * _BaseColor;
				return finalColor;
			}
			ENDHLSL
		}
	}
}