Shader "Custom/URPLitSimplePBR"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		[Normal]_NormalMap ("Normal Map", 2D) = "bump" {}
		_MetallicGlossMap ("Metallic Gloss Map", 2D) = "white" {}
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0.5 
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
            
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_NormalMap);
			SAMPLER(sampler_NormalMap);
			TEXTURE2D(_MetallicGlossMap);
			SAMPLER(sampler_MetallicGlossMap);

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _NormalMap_ST;
				float4 _MetallicGlossMap_ST;
				float4 _BaseColor;
				float _Metallic;
				float _Smoothness;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float3 normalOS : NORMAL ;
				float4 tangentOS : TANGENT;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionCS: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 positionWS: TEXCOORD1;
				float3 normalWS: NORMAL;
				float4 tangentWS: TEXCOORD2;
				float3 bitangentWS: TEXCOORD3;
			};


			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);

				//计算TBN矩阵相关参数
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
				output.bitangentWS = cross(output.normalWS, output.tangentWS.xyz) * input.tangentOS.w;
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{
				half4 albedoMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
				half3 albedo = albedoMap.rgb * _BaseColor.rgb;

				//从法线贴图获取法线
				half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
				half3 normalTS = UnpackNormal(normalMap);

				//构建TBN矩阵
				float3x3 TBN = float3x3(
					normalize(input.tangentWS.xyz),
					normalize(input.bitangentWS),
					normalize(input.normalWS)
				);
				half3 normalWS = mul(normalTS, TBN); 
				normalWS = normalize(normalWS);

				//从金属光泽贴图获取金属光泽参数
				half4 metallicGlossMap = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MetallicGlossMap, input.uv);
				half metallic = metallicGlossMap.r * _Metallic;
				half smoothness = metallicGlossMap.a * _Smoothness;

				//准备输入数据
				InputData inputData = (InputData)0;
				inputData.positionWS = input.positionWS;
				inputData.normalWS = normalWS;
				inputData.viewDirectionWS = normalize(GetWorldSpaceViewDir(input.positionWS));
				inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				
				// inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
				inputData.shadowMask = half4(1, 1, 1, 1);
				inputData.fogCoord = 0;
				inputData.vertexLighting = half3(0, 0, 0);
				inputData.bakedGI =  albedo; // SampleSH(normalWS); // 使用球谐光照采样环境光
				// inputData.tangentToWorld = CreateTangentToWorld(normalWS, input.tangentWS.xyz, input.tangentWS.w);

				//准备表面数据
				SurfaceData surfaceData = (SurfaceData)0;
				surfaceData.albedo = albedo;
				surfaceData.metallic = metallic;
				surfaceData.smoothness = smoothness;
				surfaceData.normalTS = normalTS;
				surfaceData.emission = half3(0, 0, 0); 
				surfaceData.occlusion = 1;
				surfaceData.alpha = 1;
				surfaceData.clearCoatMask = 0;
				surfaceData.clearCoatSmoothness = 0;

				//使用UniversalForward渲染
				half4 color = UniversalFragmentPBR(inputData, surfaceData);
				
				
				return color;
			}

			ENDHLSL
		}
	}
}