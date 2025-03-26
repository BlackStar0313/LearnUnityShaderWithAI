Shader "Custom/TextureWithMask"
{
    Properties
    {
        _MainTex ("第一纹理", 2D) = "white" {}
        _SecondTex ("第二纹理", 2D) = "white" {}
        _MaskTex ("遮罩纹理", 2D) = "white" {} // 新增遮罩纹理
        _MaskStrength ("遮罩强度", Range(0, 1)) = 1 // 控制遮罩的影响程度
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
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            float4 _MaskTex_ST;
            float _MaskStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float2 uvMask : TEXCOORD2; // 遮罩的UV坐标
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _SecondTex);
               // o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex);
			    // 在顶点着色器中添加动态UV偏移
                o.uvMask = TRANSFORM_TEX(v.uv, _MaskTex) + float2(_Time.y * 0.1, 0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样三个纹理
                fixed4 tex1 = tex2D(_MainTex, i.uv1);
                fixed4 tex2 = tex2D(_SecondTex, i.uv2);
                
                // 采样遮罩纹理
                fixed4 mask = tex2D(_MaskTex, i.uvMask);
                
                // 使用遮罩的红色通道来控制混合
                // 可以选择任意通道：mask.r, mask.g, mask.b 或 mask.a
                float blendFactor = mask.r * _MaskStrength;
                
                // 使用遮罩值进行混合
                fixed4 finalColor = lerp(tex1, tex2, blendFactor);
                
                return finalColor;
            }
            ENDCG
        }
    }
}