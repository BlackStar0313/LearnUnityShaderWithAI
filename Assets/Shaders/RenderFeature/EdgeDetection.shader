Shader "Custom/EdgeDetection"
{
    Properties
    {
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_EdgeThickness ("Edge Thickness", Range(0, 5)) = 1  //边缘厚度
        _EdgeThreshold ("Edge Threshold", Range(0, 1)) = 0.1 //边缘阈值
    }

	SubShader
	{
		Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}

		ZTest Always
		ZWrite Off
		Cull Off

		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float4 _EdgeColor;
			float _EdgeThickness;
			float _EdgeThreshold;
			CBUFFER_END

			float4 frag(Varyings input) : SV_Target
			{
				float2 uv = input.texcoord;
				float4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

				//采样深度纹理
				float depth = SampleSceneDepth(uv);	

				//偏移UV采样深度，计算边缘
				float2 offset = _EdgeThickness * (1.0 / _ScreenSize.xy);
				float d1 = SampleSceneDepth(uv + float2(-offset.x , 0)); 
				float d2 = SampleSceneDepth(uv + float2(offset.x , 0));
				float d3 = SampleSceneDepth(uv + float2(0, offset.y));
				float d4 = SampleSceneDepth(uv + float2(0, -offset.y));

				//计算深度差异
				float depthDiff = abs(d1 - d2) + abs(d3 - d4);


				// 采样法线纹理(增强的边缘检测)
				float3 normal = SampleSceneNormals(uv);
				float3 n1 = SampleSceneNormals(uv + float2(-offset.x , 0));
				float3 n2 = SampleSceneNormals(uv + float2(offset.x , 0));
				float3 n3 = SampleSceneNormals(uv + float2(0, offset.y));
				float3 n4 = SampleSceneNormals(uv + float2(0, -offset.y));

				//计算法线差异
				float normalDiff = length(n1 - n2) + length(n3 - n4);
				
		        //合并发现和深度的边缘检测结果。
				float edge = step(_EdgeThreshold , depthDiff + normalDiff);


				// 调试模式 - 强制显示边缘
				return float4(1, 0, 0, 1) * edge + color * (1 - edge);
				
				// 混合原始颜色和边缘颜色
				return lerp(color, _EdgeColor, edge);
			}

			ENDHLSL
		}
	}

}