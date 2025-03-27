Shader "Custom/URPTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", Float) = 1
    }
	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
			"RenderPipeline"="UniversalPipeline"
			"Queue" = "Geometry"
		}


		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode"="UniversalForward" }
			
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			//包裹材质属性
			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _Color;
			float _Intensity;
			CBUFFER_END

			//顶点着色器输入结构 命名约定  Attributes 而非 appdata
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			//顶点着色器输出结构 命名约定 Varyings 而非 v2f
			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//顶点着色器
			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				//将顶点位置从对象空间转换为裁剪空间 TransformObjectToHClip 内置函数 而非 UnityObjectToClipPos
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);	
				//将uv从对象空间转换为纹理空间 TRANSFORM_TEX 内置函数 而非 TRANSFORM_TEX
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				return OUT;
			}

			//片段着色器
			half4 frag(Varyings IN) : SV_Target
			{
				//采样纹理 使用SAMPLE_TEXTURE2D 而非 tex2D
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				//应用颜色和强度
				color *= _Color * _Intensity;
				return color;
			}
			ENDHLSL
		}
	}
}