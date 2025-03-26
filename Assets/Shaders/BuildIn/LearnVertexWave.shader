Shader "Custom/LearnVertexWave"
{
	Properties
	{
		_MainTex ("纹理", 2D) = "white" {}
		_WaveAmplitude ("波幅", Range(0, 1)) = 0.1
		_WaveFrequency ("波频率", Range(0, 10)) = 2
		_WaveSpeed ("波速", Range(0, 5)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _WaveAmplitude;
			float _WaveFrequency;
			float _WaveSpeed;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;

				//根据定点位置和时间计算波浪效果
				//得到定点的世界坐标系位置
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				//计算波浪，用正弦函数模拟，x方向上获取正旋的间隔，y方向上获取正旋的幅度
				float wave = sin(worldPos.x * _WaveFrequency + _Time.y * _WaveSpeed);

				//将波浪效果应用到顶点位置
				v.vertex.y += wave * _WaveAmplitude;

				//计算新的顶点位置
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}