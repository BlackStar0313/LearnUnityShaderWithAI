Shader "Custom/LearnPostProcessing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Brightness ("亮度", Range(0, 2)) = 1
		_Contrast ("对比度", Range(0, 2)) = 1
		_Saturation ("饱和度", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        

	 	Cull Off
	    ZWrite Off
		ZTest Always   

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
			float _Brightness;
			float _Contrast;
			float _Saturation;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// 采样原始屏幕颜色
				fixed4 col = tex2D(_MainTex, i.uv);

				// 1. 调整亮度
				fixed3 finalColor = col.rgb * _Brightness;
                
				// 2. 调整饱和度
				fixed luminance = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
				fixed3 luminanceColor = fixed3(luminance, luminance, luminance);
				finalColor = lerp(luminanceColor, finalColor, _Saturation);

				// 3. 调整对比度
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				finalColor = lerp(avgColor, finalColor, _Contrast);

				return fixed4(finalColor, col.a);
			}
			ENDCG
		}
    }
}