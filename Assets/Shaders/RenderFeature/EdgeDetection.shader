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
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert   // vertex shader 是在Blit.hlsl中定义的
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"  //采样场景深度
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl" //采样场景法线
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl" //采样场景颜色

			CBUFFER_START(UnityPerMaterial)
			float4 _EdgeColor;
			float _EdgeThickness;
			float _EdgeThreshold;
			CBUFFER_END

			// Edge detection kernel that works by taking the sum of the squares of the differences between diagonally adjacent pixels (Roberts Cross).
            float RobertsCross(float3 samples[4])
            {
                const float3 difference_1 = samples[1] - samples[2];
                const float3 difference_2 = samples[0] - samples[3];
                return sqrt(dot(difference_1, difference_1) + dot(difference_2, difference_2));
            }

            // The same kernel logic as above, but for a single-value instead of a vector3.
            float RobertsCross(float samples[4])
            {
                const float difference_1 = samples[1] - samples[2];
                const float difference_2 = samples[0] - samples[3];
                return sqrt(difference_1 * difference_1 + difference_2 * difference_2);
            }
            
            // Helper function to sample scene normals remapped from [-1, 1] range to [0, 1].
            float3 SampleSceneNormalsRemapped(float2 uv)
            {
                return SampleSceneNormals(uv) * 0.5 + 0.5;
            }

            // Helper function to sample scene luminance.
            float SampleSceneLuminance(float2 uv)
            {
                float3 color = SampleSceneColor(uv);
                return color.r * 0.3 + color.g * 0.59 + color.b * 0.11;
            }

			half4 frag(Varyings IN) : SV_TARGET
            {
                // Screen-space coordinates which we will use to sample.
                float2 uv = IN.texcoord;
                float2 texel_size = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
                
                // Generate 4 diagonally placed samples.
                const float half_width_f = floor(_EdgeThickness * 0.5);
                const float half_width_c = ceil(_EdgeThickness * 0.5);

                float2 uvs[4];
                uvs[0] = uv + texel_size * float2(half_width_f, half_width_c) * float2(-1, 1);  // top left
                uvs[1] = uv + texel_size * float2(half_width_c, half_width_c) * float2(1, 1);   // top right
                uvs[2] = uv + texel_size * float2(half_width_f, half_width_f) * float2(-1, -1); // bottom left
                uvs[3] = uv + texel_size * float2(half_width_c, half_width_f) * float2(1, -1);  // bottom right
                
                float3 normal_samples[4];
                float depth_samples[4], luminance_samples[4];
                
                for (int i = 0; i < 4; i++) {
                    depth_samples[i] = SampleSceneDepth(uvs[i]);
                    normal_samples[i] = SampleSceneNormalsRemapped(uvs[i]);
                    luminance_samples[i] = SampleSceneLuminance(uvs[i]);
                }
                
                // Apply edge detection kernel on the samples to compute edges.
                float edge_depth = RobertsCross(depth_samples);
                float edge_normal = RobertsCross(normal_samples);
                float edge_luminance = RobertsCross(luminance_samples);
                
				
                // Threshold the edges (discontinuity must be above certain threshold to be counted as an edge). The sensitivities are hardcoded here.
                float depth_threshold = 1 / 400.0f;
                edge_depth = edge_depth > depth_threshold ? _EdgeThreshold : 0;
                
                float normal_threshold = 1 / 4.0f;
                edge_normal = edge_normal > normal_threshold ? _EdgeThreshold : 0;
                
                float luminance_threshold = 1 / 0.5f;
                edge_luminance = edge_luminance > luminance_threshold ? _EdgeThreshold : 0;
                
                // Combine the edges from depth/normals/luminance using the max operator.
                float edge = max(edge_depth, max(edge_normal, edge_luminance));
                
                // Color the edge with a custom color.
                return edge * _EdgeColor;
            }

			// float4 frag(Varyings input) : SV_Target
			// {
			// 	float2 uv = input.texcoord;
			// 	float4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

			// 	//采样深度纹理
			// 	float depth = SampleSceneDepth(uv);	

			// 	//偏移UV采样深度，计算边缘
			// 	float2 offset = _EdgeThickness * (1.0 / _ScreenSize.xy);
			// 	float d1 = SampleSceneDepth(uv + float2(-offset.x , 0)); 
			// 	float d2 = SampleSceneDepth(uv + float2(offset.x , 0));
			// 	float d3 = SampleSceneDepth(uv + float2(0, offset.y));
			// 	float d4 = SampleSceneDepth(uv + float2(0, -offset.y));

			// 	//计算深度差异
			// 	float depthDiff = abs(d1 - d2) + abs(d3 - d4);


			// 	// 采样法线纹理(增强的边缘检测)
			// 	float3 normal = SampleSceneNormals(uv);
			// 	float3 n1 = SampleSceneNormals(uv + float2(-offset.x , 0));
			// 	float3 n2 = SampleSceneNormals(uv + float2(offset.x , 0));
			// 	float3 n3 = SampleSceneNormals(uv + float2(0, offset.y));
			// 	float3 n4 = SampleSceneNormals(uv + float2(0, -offset.y));

			// 	//计算法线差异
			// 	float normalDiff = length(n1 - n2) + length(n3 - n4);
				
		    //     //合并发现和深度的边缘检测结果。
			// 	float edge = step(_EdgeThreshold , depthDiff + normalDiff);


			// 	// 调试模式 - 强制显示边缘
			// 	return float4(1, 0, 0, 1) * edge + color * (1 - edge);
				
			// 	// 混合原始颜色和边缘颜色
			// 	return lerp(color, _EdgeColor, edge);
			// }

			ENDHLSL
		}
	}

}