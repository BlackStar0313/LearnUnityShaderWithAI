Shader "Custom/URPTextureUVAni"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaveAmplitude ("Wave Amplitude", Float) = 0.1
		_WaveFrequency ("Wave Frequency", Float) = 2
		_WaveSpeed ("Wave Speed", Float) = 1
	}

	SubShader
	{
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
            "Queue"="Geometry"
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

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float _WaveAmplitude;
			float _WaveFrequency;
			float _WaveSpeed;
			CBUFFER_END
			
			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				//得到定点的世界坐标系位置
				float4 worldPos = mul(unity_ObjectToWorld, IN.positionOS);
				//计算波浪，用正弦函数模拟，x方向上获取正旋的间隔，y方向上获取正旋的幅度
				float wave = sin(worldPos.x * _WaveFrequency + _Time.y * _WaveSpeed);

				//将波浪效果应用到顶点位置
				IN.positionOS.y += wave * _WaveAmplitude;

				//计算新的顶点位置
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
				return color;
			}
			ENDHLSL
		}
	}

}