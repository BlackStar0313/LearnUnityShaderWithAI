Shader "Custom/ColorGrading"
{
	Properties
	{

	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

		Pass
		{
			Name "ColorGrading"

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag 

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

			 
			CBUFFER_START(UnityPerMaterial)

			CBUFFER_END

			half4 frag(Varyings input) : SV_Target
			{
				half4 baseColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);

				half4 addColor = half4(0.5, 0.5, 0.5, 1);
				return baseColor * addColor;
			}

			ENDHLSL
		}
	}
}