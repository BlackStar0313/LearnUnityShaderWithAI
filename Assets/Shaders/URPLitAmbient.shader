//简单环境光
Shader "Custom/URPLitAmbient"
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

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseColor;
			float _AmbientStrength;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
			};

			struct Varyings
			{
				float4 positionHCS: SV_POSITION;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				half3 ambient = _BaseColor.rgb * _AmbientStrength;
				return half4(ambient, 1.0);
			}
			ENDHLSL
		}		
	}
}