Shader "Custom/LearnTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // 声明一个纹理属性
        _Color ("Tint", Color) = (1,1,1,1)    // 颜色调整
        _Intensity ("Intensity", Range(0, 1)) = 1.0 // 强度调节滑块
    }
    
    SubShader
    {
        // Tags用于定义Shader的渲染属性和分类
        // RenderType="Opaque" 表示这是一个不透明物体的shader
        // Unity使用RenderType来对不同类型的物体进行分类和渲染
        // 其他常见的RenderType值包括:
        // - Transparent: 透明物体
        // - TransparentCutout: 透明度裁剪
        // - Background: 背景
        // - Overlay: 叠加层
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // 声明变量
            sampler2D _MainTex;    // 纹理采样器
            float4 _MainTex_ST;    // 纹理的缩放和偏移
            fixed4 _Color;         // 颜色
            float _Intensity;      // 强度

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;    // 新增：UV坐标输入
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;    // 新增：UV坐标传递
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 计算UV坐标（考虑缩放和偏移）
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样纹理
                fixed4 texColor = tex2D(_MainTex, i.uv);
                // 将纹理颜色与tint颜色和强度相乘
                return texColor * _Color * _Intensity;
            }
            ENDCG
        }
    }
}
