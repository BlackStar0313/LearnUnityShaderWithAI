Shader "Custom/LearnBasicTransparent"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,0.5)
	}

	SubShader
	{
		Tags 
		{ 
			"Queue"="Transparent"          // 渲染顺序
			"RenderType"="Transparent"     // 渲染类型
			"IgnoreProjector" = "True" // 忽略投影器
		}

		// 关闭深度写入，但进行深度测试
		ZWrite Off 

		// 设置混合模式
		// 最终颜色 = 源因子 × 源颜色 + 目标因子 × 目标颜色
		// 源因子：源颜色
		// 目标因子：目标颜色
		// 源颜色：当前片元的颜色
		// 目标颜色：已经存在于颜色缓冲区的颜色
		Blend SrcAlpha OneMinusSrcAlpha 

		Pass
		{
			CGPROGRAM	
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				return col;	
			}
			ENDCG
		}
	}
}