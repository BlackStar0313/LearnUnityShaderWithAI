Shader "Custom/TwoTextureBlend"
{
    Properties
    {
        _MainTex ("Texture 1", 2D) = "white" {}
        _SecondTex ("Texture 2", 2D) = "white" {}
        _BlendAmount ("Blend Amount", Range(0, 1)) = 0.5 // 混合程度滑块
        _Color ("Tint", Color) = (1,1,1,1)
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

            // 声明变量
            sampler2D _MainTex;
            sampler2D _SecondTex;
            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            float _BlendAmount;
            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv1 : TEXCOORD0;    // 第一个纹理的UV
                float2 uv2 : TEXCOORD1;    // 第二个纹理的UV
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 计算两个纹理的UV坐标
                o.uv1 = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _SecondTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样两个纹理
                fixed4 tex1 = tex2D(_MainTex, i.uv1);
                fixed4 tex2 = tex2D(_SecondTex, i.uv2);
                
                // 使用lerp进行线性插值混合
                fixed4 finalColor = lerp(tex1, tex2, _BlendAmount);
                
                // 应用颜色调整
                return finalColor * _Color;
            }
            ENDCG
        }
    }
}