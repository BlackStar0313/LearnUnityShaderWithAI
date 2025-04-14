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

		Pass
		{
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

			half4 frag(Varyings input) : SV_Target
			{
				return half4(1, 0, 0, 1);
			}
			ENDHLSL
		}

		// // Pass 0: SSAO 生成
		// Pass 
		// {
		// 	HLSLPROGRAM
		// 	#pragma vertex Vert
		// 	#pragma fragment frag

		// 	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
      	// 	#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
		// 	CBUFFER_START(UnityPerMaterial)
		// 		float _AOIntensity;
		// 		float _AORadius;
		// 		float _SampleCount;
		// 	CBUFFER_END 

		// 	TEXTURE2D(_NoiseTexture);
		// 	SAMPLER(sampler_NoiseTexture);
		// 	float4 _NoiseTexture_TexelSize;
  
		// 	// 视图控件重建
		// 	float3 ViewPosFromDepth(float2 uv)
		// 	{
		// 		float depth = SampleSceneDepth(uv);
		// 		float linearDepth = LinearEyeDepth(depth, _ZBufferParams);

		// 		// 重建视图控件位置
		// 		float4 clipPos = float4(uv * 2.0 - 1.0, depth, 1.0);
		// 		float4 viewPos = mul(unity_CameraInvProjection, clipPos);
		// 		viewPos /= viewPos.w;
		// 		return viewPos.xyz;
		// 	}

		// 	// 生成SSAO 值
		// 	float4 frag(Varyings input) : SV_Target
		// 	{
		// 		float2 uv = input.texcoord;
				 
				
		// 		//获取当前像素的视图控件位置和法线
		// 		float3 viewPos = ViewPosFromDepth(uv);
		// 		float3 viewNormal = normalize(cross(ddy(viewPos), ddx(viewPos)));

		// 		// 生成随机旋转矢量
		// 		float2 noiseScale = _ScreenParams.xy / 4.0; 
		// 		float2 noiseUV = uv * noiseScale;
		// 		float3 randomVec = SAMPLE_TEXTURE2D(_NoiseTexture, sampler_NoiseTexture, noiseUV).xyz * 2.0 - 1.0;

		// 		// 创建TBN矩阵用于旋转采样方向
		// 		float3 tangent = normalize(randomVec - viewNormal * dot(randomVec, viewNormal));
		// 		float3 bitangent = cross(viewNormal, tangent);
		// 		float3x3 TBN = float3x3(tangent, bitangent, viewNormal);

		// 		// 执行 SSAO 采样
		// 		float occlusion = 0.0;
		// 		float sampleCount = _SampleCount;

		// 		for (int i = 0; i < sampleCount; i++)
		// 		{
        //             // 生成半球采样方向
        //             float angle = (i * PI * 2.0) / sampleCount;
        //             float r = sqrt((i + 1.0) / sampleCount);
        //             float2 offset = float2(cos(angle), sin(angle)) * r;
                    
        //             // 转换到视图空间
        //             float3 sampleDir = mul(TBN, float3(offset, sqrt(1 - dot(offset, offset))));
                    
        //             // 采样点的位置
        //             float3 samplePos = viewPos + sampleDir * _AORadius;
                    
        //             // 将采样点投影回屏幕空间
        //             float4 samplePosSS = mul(unity_CameraProjection, float4(samplePos, 1.0));
        //             samplePosSS.xy /= samplePosSS.w;
        //             samplePosSS.xy = samplePosSS.xy * 0.5 + 0.5;
                    
        //             // 采样深度
        //             float sampleDepth = SampleSceneDepth(samplePosSS.xy);
        //             float sampleLinearDepth = LinearEyeDepth(sampleDepth, _ZBufferParams);
                    
        //             // 获取采样点的视图空间位置
        //             float3 sampleViewPos = ViewPosFromDepth(samplePosSS.xy);
                    
        //             // 计算遮挡因子
        //             float distZ = viewPos.z - sampleViewPos.z;
        //             float rangeCheck = smoothstep(0.0, 1.0, _AORadius / abs(distZ));
        //             occlusion += (sampleViewPos.z <= samplePos.z ? 1.0 : 0.0) * rangeCheck;
		// 		}

		// 		// 计算最终AO值
		// 		occlusion = 1.0 - (occlusion / sampleCount) * _AOIntensity;
					
		// 		// 返回AO值
		// 		return float4(occlusion, occlusion, occlusion, 1);
		// 	}
		// 	ENDHLSL
		// }

		// Pass
		// {
		// 	HLSLPROGRAM
		// 	#pragma vertex Vert
		// 	#pragma fragment frag

		// 	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		// 	#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

		// 	TEXTURE2D(_AOTexture);
		// 	SAMPLER(sampler_AOTexture);
 
		// 	float4 frag(Varyings input) : SV_Target
		// 	{
		// 		float2 uv = input.texcoord;

		// 		// 获取场景颜色和AO
		// 		float4 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
		// 		float ao = SAMPLE_TEXTURE2D(_AOTexture, sampler_AOTexture, uv).r;

		// 		// 混合场景颜色和AO
		// 		return float4(sceneColor.rgb * ao , sceneColor.a);
		// 	}
		// 	ENDHLSL
	}
}