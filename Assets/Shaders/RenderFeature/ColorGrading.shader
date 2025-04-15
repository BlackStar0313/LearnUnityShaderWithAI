Shader "Custom/ColorGrading"
{
	Properties
	{
		_Brightness ("Brightness", Range(-1, 1)) = 0 // 亮度
		_Contrast ("Contrast", Range(-1, 1)) = 0 // 对比度
		_Saturation ("Saturation", Range(-1, 1)) = 0 // 饱和度
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
				float _Brightness;
				float _Contrast;
				float _Saturation;
				float _Temperature;
				float _Tint;
				float4 _ShadowsColor;
				float4 _MidtonesColor;
				float4 _HighlightsColor;
			CBUFFER_END

			half3 ApplyBrightness(half3 color , float brightness)
			{
				return color + brightness;
			}

			half3 ApplyContrast(half3 color , float contrast)
			{
				return lerp(half3(0.5, 0.5, 0.5), color, contrast + 1.0);
			}

			half3 ApplySaturation(half3 color , float saturation)
			{
				half luminance = dot(color, half3(0.299, 0.587, 0.114));
				return lerp(luminance, color, saturation);
			}

			half3 ApplyTemperature(half3 color , float temperature)
			{
				//简单的色温调节 （温度/冷色偏移
				half3 warm  = half3(1.0, 1.0, 1.0);   //暖色
				half3 cool = half3(0.0, 0.0, 0.0);   //冷色
				
				return color * lerp(cool, warm, temperature * 0.5 + 0.5);
			}

			// 分色调整（阴影，中间调，高光）
			half3 ApplyColorBalance(half3 color, half3 shadows, half3 midtones, half3 highlights)
			{
				float luminance = dot(color, half3(0.2126, 0.7152, 0.0722));

				//分类
				float shadowsWeight = 1.0 - smoothstep(0.0, 0.33, luminance);
				float highlightWeight = smoothstep(0.66, 1.0, luminance);
				float midtonesWeight = 1.0 - shadowsWeight - highlightWeight;

				// 混合结果
				half3 result = color ;
				result *= lerp(half3(1,1,1), shadows , shadowsWeight);
				result *= lerp(half3(1,1,1), midtones, midtonesWeight);
				result *= lerp(half3(1,1,1), highlights, highlightWeight);
				
				return result;
			}


			half4 frag(Varyings input) : SV_Target
			{
				half4 baseColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);

				// 依次应用各种颜色调整
				half3 result = baseColor.rgb ;
				result = ApplyBrightness(result, _Brightness);
				result = ApplyContrast(result, _Contrast);
				result = ApplySaturation(result, _Saturation);
				result = ApplyTemperature(result, _Temperature);
				result = ApplyColorBalance(result, _ShadowsColor.rgb, _MidtonesColor.rgb, _HighlightsColor.rgb	);

				return half4(result, baseColor.a);
			}
			ENDHLSL
		}
	}
}