Shader "Custom/TwoTextureUvAni"
{
    Properties
    {
        _MainTex ("Texture 1", 2D) = "white" {}
		_SecondTex ("Texture 2", 2D) = "white" {}
		_Speed ("Animation Speed", Float) = 1 // 替换为速度控制
		_Range ("Range", Range(0, 1)) = 0
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
			sampler2D _SecondTex;
			float4 _MainTex_ST;
			float4 _SecondTex_ST;
			float _Speed;
			float _Range;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;

			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv1 = TRANSFORM_TEX(v.uv1, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv2, _SecondTex) + float2(_Time.y * _Speed, 0);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col1 = tex2D(_MainTex, i.uv1);
				fixed4 col2 = tex2D(_SecondTex, i.uv2);
				fixed4 col = lerp(col1, col2, _Range);
				return col;
			}
			ENDCG
		}
	}
}
