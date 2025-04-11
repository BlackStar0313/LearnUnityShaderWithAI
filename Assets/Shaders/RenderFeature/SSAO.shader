Shader "Custom/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}
        

		ZTest Always 
		ZWrite Off 
		Cull Off 

		// Pass 0: SSAO 生成
		Pass 
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
      		#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
			CBUFFER_START(UnityPerMaterial)
				float _AOIntensity;
				float _AORadius;
				float _SampleCount;
			CBUFFER_END 

			TEXTURE2D(_NoiseTexture);
			SAMPLER(sampler_NoiseTexture);
			float4 _NoiseTexture_TexelSize;
  
			// 视图控件重建
			float3 ViewPosFromDepth(float2 uv)
			{
				float depth = SampleSceneDepth(uv);
				float linearDepth = LinearEyeDepth(depth, _ZBufferParams);

				// 重建视图控件位置
				float4 clipPos = float4(uv * 2.0 - 1.0, depth, 1.0);
				float4 viewPos = mul(unity_CameraInvProjection, clipPos);
				viewPos /= viewPos.w;
				return viewPos.xyz;
			}

			// 生成SSAO 值
			float4 frag(Varyings input) : SV_Target
			{
				
			}
			ENDHLSL
		}
    }
}