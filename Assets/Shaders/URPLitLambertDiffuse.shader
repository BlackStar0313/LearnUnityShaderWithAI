Shader "Custom/URPLitLambertDiffuse"
{
	Properties
	{
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.2
	}

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
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			

			CBUFFER_START(UnityPerMaterial)
				float4 _BaseColor;
				float _AmbientStrength;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 positionCS: SV_POSITION;
				float3 normalWS : NORMAL;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				return output;
			}
			
			half4 frag(Varyings input) : SV_TARGET
			{
				//获取主光源
				Light mainLight = GetMainLight();

				// // 计算Lambert漫反射
				// float NdotL = max(0, dot(input.normalWS, mainLight.direction));
				// 计算半Lambert漫反射(更柔和的阴影)
				float NdotL = dot(input.normalWS, mainLight.direction) * 0.5 + 0.5; // 从[-1,1]映射到[0,1]
				half3 diffuse = _BaseColor.rgb * mainLight.color * NdotL;

				//计算环境光
				half3 ambient = _BaseColor.rgb * _AmbientStrength;
		 

				//组合环境光和漫反射
				half3 finalColor = ambient + diffuse;
				return half4(finalColor, 1.0);
			}

			ENDHLSL
		}
	}
}