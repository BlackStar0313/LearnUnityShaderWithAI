Shader "Custom/LearnDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("噪声纹理", 2D) = "white" {}
		_DissolveAmount ("溶解程度", Range(0, 1)) = 0
		_EdgeColor ("边缘颜色", Color) = (1, 0.5, 0, 1)
		_EdgeWidth ("边缘宽度", Range(0, 0.1)) = 0.01
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
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            float _DissolveAmount;
            fixed4 _EdgeColor;
            float _EdgeWidth;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv: TEXCOORD0;
				float2 uvNoise : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//采样纹理和噪声纹理
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 noise = tex2D(_NoiseTex, i.uvNoise);

				//计算溶解程度
				float dissolve = noise.r - _DissolveAmount;

				//边缘检测 ,片元丢弃
				if (dissolve < 0 )
				   discard;   //完全溶解的部分不渲染
				
				//计算边缘颜色
				if (dissolve < _EdgeWidth)
				   return _EdgeColor;


				return col;
			}
			ENDCG
		}
	}
}