Shader "Custom/RFSwtichColor"
{
    Properties
    {

	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" 
		}

		Pass
		{
			Name "SwitchColor"
			HLSLPROGRAM
          	#pragma vertex Vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

			half4 frag(Varyings input) : SV_Target
			{
				half4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
				half4 addValue = half4(1, 0, 0, 1);
				return color + addValue;
			}
			ENDHLSL
		}
	}

}