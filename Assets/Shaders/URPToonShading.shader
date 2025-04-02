Shader "Custom/URPToonShading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1, 1, 1, 1)
		_ShadowColor ("Shadow Color", Color) = (0.5, 0.5, 0.5, 1)
		_ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
		_ShadowSmoothness ("Shadow Smoothness", Range(0, 0.2)) = 0.01
		[Toggle] _UseRamp ("Use Ramp", Float) = 0
		_RampTex ("Ramp Texture", 2D) = "white" {}
		[Normal] _NormalMap ("Normal Map", 2D) = "bump" {}
		_OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.01
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}
		
		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_RampTex);
			SAMPLER(sampler_RampTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _BaseColor;
			float4 _ShadowColor;
			float4 _NormalMap_ST;
			float4 _RampTex_ST;
			float _UseRamp;
			float4 _OutlineColor;
			float _OutlineWidth;
			float _ShadowThreshold;
			float _ShadowSmoothness;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 tangentOS : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float3 normalWS : TEXCOORD2;
				float4 tangentWS : TEXCOORD3;
				float3 bitangentWS : TEXCOORD4;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);

				// 计算TBN矩阵
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
				output.bitangentWS = cross(output.normalWS, output.tangentWS.xyz) * input.tangentOS.w;

				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
				half3 albedoColor = albedo.rgb * _BaseColor.rgb;

				//法线贴图
				half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
				half3 normalTS = UnpackNormal(normalMap);

				// 构建TBN矩阵
				float3x3 TBN = float3x3(
					normalize(input.tangentWS.xyz),
					normalize(input.bitangentWS),
					normalize(input.normalWS)
				);
				half3 normalWS = mul(normalTS, TBN);

				// lambert 漫反射
				Light mainLight = GetMainLight();
				float lightIntensity = dot(normalWS , mainLight.direction);

				// 卡通阴影计算   使用平滑步进创建硬边界
				float toonRamp = smoothstep(_ShadowThreshold - _ShadowSmoothness, _ShadowThreshold + _ShadowSmoothness, lightIntensity);

				// 渐变纹理
				if (_UseRamp > 0.5) {
					toonRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(toonRamp, 0.5)).r;
				}
				
				// 阴影颜色
				half3 shadowedColor = albedoColor * _ShadowColor.rgb ;
				half3 litColor = albedoColor * mainLight.color; 

				// 最终颜色混合  - 在明暗区域之间差值
				half3 finalColor = lerp(shadowedColor, litColor, toonRamp);

				//添加基础环境光
				half3 ambient = half3(0.1, 0.1, 0.1) * albedoColor;
				finalColor += ambient;

				return half4(finalColor, 1);
				
			}
			ENDHLSL
		}

		// 第二个Pass - 轮廓线
		Pass
		{
			Name "Outline"
			Tags {}
			Cull Front //踢出正面  只渲染背面
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float4 _OutlineColor;
			float _OutlineWidth;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;

				// 法线方向外扩点
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

		// // 第三个Pass - 投射阴影
		// UsePass "Universal Render Pipeline/Lit/ShadowCaster"
	}
}