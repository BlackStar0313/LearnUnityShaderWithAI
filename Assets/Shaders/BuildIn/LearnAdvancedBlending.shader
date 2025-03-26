Shader "Custom/LearnAdvancedBlending"
{
    Properties
    {
        _MainTex ("主纹理", 2D) = "white" {}
        _Color ("基础颜色", Color) = (1,1,1,0.5)
        [KeywordEnum(Standard, Additive, Multiply, Screen, Overlay)]
        _BlendMode ("混合模式", Float) = 0
        _Intensity ("强度", Range(0.0, 2.0)) = 1.0
    }
    
    SubShader
    {
        Tags { 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"     
            "IgnoreProjector" = "True"      
        }

        ZWrite Off
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _BLENDMODE_STANDARD _BLENDMODE_ADDITIVE _BLENDMODE_MULTIPLY _BLENDMODE_SCREEN _BLENDMODE_OVERLAY
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
            float _Intensity;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv) * _Color;
                texColor.rgb *= _Intensity;

                #if defined(_BLENDMODE_STANDARD)
                    // 标准透明
                    return texColor;
                    
                #elif defined(_BLENDMODE_ADDITIVE)
                    // 加法混合
                    return fixed4(texColor.rgb * texColor.a, texColor.a);
                    
                #elif defined(_BLENDMODE_MULTIPLY)
                    // 乘法混合
                    fixed3 color = lerp(fixed3(1,1,1), texColor.rgb, texColor.a);
                    return fixed4(color, texColor.a);
                    
                #elif defined(_BLENDMODE_SCREEN)
                    // 屏幕混合
                    fixed3 color = 1 - (1 - texColor.rgb) * texColor.a;
                    return fixed4(color, texColor.a);
                    
                #elif defined(_BLENDMODE_OVERLAY)
                    // 叠加混合
                    fixed3 color = texColor.rgb;
                    if (color.r < 0.5) color.r = 2.0 * color.r;
                    else color.r = 1.0 - 2.0 * (1.0 - color.r);
                    if (color.g < 0.5) color.g = 2.0 * color.g;
                    else color.g = 1.0 - 2.0 * (1.0 - color.g);
                    if (color.b < 0.5) color.b = 2.0 * color.b;
                    else color.b = 1.0 - 2.0 * (1.0 - color.b);
                    return fixed4(color, texColor.a);
                    
                #else
                    return texColor;
                #endif
            }
            ENDCG
        }
    }
    
    FallBack "Transparent/Diffuse"
}