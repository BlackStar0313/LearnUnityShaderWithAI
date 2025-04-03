Shader "Custom/URPMultiPass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1, 1, 1, 1)
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline Width", Range(0, 0.1)) = 0.01
		[Toggle] _UseSecondLayer("Use Second Layer", Float) = 0
		_SecondLayerColor("Second Layer Color", Color) = (1, 1, 1, 1)
		_PulseSpeed("Pulse Speed", Range(0, 10)) = 1
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
			"Queue" = "Transparent"
		}

		// 第一个pass 基础渲染
		Pass
		{
			Name "Base"
			Tags
			{
				"LightMode" = "UniversalForward"
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalWS : TEXCOORD1;
				float3 positionWS : TEXCOORD2;
			};


			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BaseColor;
			float _PulseSpeed;
			float4 _OutlineColor;
			float _OutlineWidth;
			float _UseSecondLayer;
			float4 _SecondLayerColor;
			CBUFFER_END

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
				half3 color = texColor.rgb * _BaseColor.rgb;

				// 简单光照
				Light mainLight = GetMainLight();
				float NdotL = saturate(dot(input.normalWS, mainLight.direction));
				color *= mainLight.color * NdotL;

				return half4(color, 1);
			}
			ENDHLSL
		}
		
		

		// 第三个pass 额外效果层
		Pass
		{
			Name "ExtraEffects"
			Tags {"LightMode" = "SRPDefaultUnlit"}

			Blend SrcAlpha OneMinusSrcAlpha //开启透明通道
			ZWrite Off //关闭深度写入
			ZTest LEqual //开启深度测试

			Cull Back // 确保剔除模式一致

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normalWS : NORMAL;
				float3 positionWS : TEXCOORD1;
			};

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _BaseColor;
				float4 _OutlineColor;
				float _OutlineWidth;
				float _UseSecondLayer;
				float4 _SecondLayerColor;
				float _PulseSpeed;
			CBUFFER_END

			Varyings vert(Attributes input)
			{
				Varyings output;

				float3 positionOS = input.positionOS.xyz + input.normalOS * 0.001;
				output.positionCS = TransformObjectToHClip(positionOS);
				output.positionWS = TransformObjectToWorld(positionOS);
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.uv = TRANSFORM_TEX(input.uv , _MainTex);
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				// return half4(1, 0, 0, 0.5);  // 明显的半透明红色
				if (_UseSecondLayer < 0.5)
				{
					return half4(0, 0, 0, 0);
				}

				// 脉冲效果
				float pulse = sin(_Time.y * _PulseSpeed) * 0.5 + 0.5;

				//基于视角的边缘效果
				float3 viewDir = normalize(GetWorldSpaceViewDir(input.positionWS));
				float edgeFactor = 1.0 - saturate(dot(viewDir, input.normalWS));

				// 组合效果
				half4 finalColor = _SecondLayerColor;
				finalColor.a *= edgeFactor * pulse;
				return finalColor;
			}
			ENDHLSL
		}


		// 第二个pass 轮廓渲染
		Pass
		{
			Name "Outline"
			Tags {"LightMode" = "SRPDefaultUnlit"}
			Cull Front

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float _OutlineWidth;
			CBUFFER_END

			Varyings vert(Attributes input)
			{
				Varyings output;
				float3 positionOS = input.positionOS.xyz + input.normalOS * _OutlineWidth;
				output.positionCS = TransformObjectToHClip(positionOS);
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				return _OutlineColor;
			}
			ENDHLSL
		}
		
	}
}