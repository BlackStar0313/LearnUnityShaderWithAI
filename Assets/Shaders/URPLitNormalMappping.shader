Shader "Custom/URPLitNormalMapping"
{
    Properties
    {
      _MainTex("Texture", 2D) = "white" {}
	  [Normal]_NormalMap("Normal Map", 2D) = "bump" {}
	  _NormalStrength("Normal Strength", Range(0, 2)) = 1
	  _BaseColor("Base Color", Color) = (1,1,1,1)
	  _AmbientStrength("Ambient Strength", Range(0, 1)) = 0.1
	  _SpecularColor("Specular Color", Color) = (1,1,1,1)
	  _Glossiness("Glossiness", Range(0, 100)) = 30
    }

    SubShader
    {
        Tags {
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
		}

		pass
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

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				float4 _NormalMap_ST;
				float _NormalStrength;
				float4 _BaseColor;
				float _AmbientStrength;
				float4 _SpecularColor;
				float _Glossiness;
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
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float3 normalWS : NORMAL;
				float4 tangentWS : TEXCOORD2;
				float3 bitangentWS : TEXCOORD3;
			};

			Varyings vert(Attributes input)
			{
				Varyings output;
				output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
				output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);
				

				// 计算TBN 矩阵
				output.normalWS = TransformObjectToWorldNormal(input.normalOS);
				output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
				output.bitangentWS = cross(output.normalWS, output.tangentWS.xyz) * input.tangentOS.w;
				return output;
			}

			half4 frag(Varyings input) : SV_TARGET
			{

				half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
				half3 albedo = texColor.rgb * _BaseColor.rgb;

				// 从法线贴图获取法线
				half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
				half3 normalTS = UnpackNormal(normalMap);  // 解码法线 函数将颜色值转换为(-1,1)范围的法线向量
				normalTS.xy *= _NormalStrength;
				normalTS = normalize(normalTS);

				// 构建TBN矩阵
				float3x3 TBN = float3x3(
					normalize(input.tangentWS.xyz),
					normalize(input.bitangentWS),
					normalize(input.normalWS)
				);
				//从切线空间转换到世界空间
				half3 normalWS = mul(normalTS, TBN);


                Light mainLight = GetMainLight();

                half3 ambient = albedo * _AmbientStrength;

                //Lambert diffuse 
                float NdotL =max(0, dot(normalWS, mainLight.direction)) ;
                half3 diffuse = albedo * mainLight.color * NdotL;
                 
                //Blinn-Phong specular
                //GetWorldSpaceViewDir(input.positionWS) 返回从顶点到摄像机的向量
                float3 viewDir = normalize(GetWorldSpaceViewDir(input.positionWS));
                // 半角向量，刚好是位于光照方向和视线方向的中间,数学上是，两个向量相加，等于由两个向量组成的菱形的对角线。
                float3 halfVector = normalize(mainLight.direction + viewDir);
                float NdotH = max(0, dot(normalWS, halfVector));
                half3 specular = _SpecularColor.rgb * mainLight.color * pow(NdotH, _Glossiness);

                //组合环境光，漫反射和高光
                half3 color = ambient + diffuse + specular;
                return half4(color, 1.0);
			}
			ENDHLSL
		}
    }
}