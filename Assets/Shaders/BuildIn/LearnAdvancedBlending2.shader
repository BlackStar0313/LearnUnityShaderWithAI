Shader "Custom/LearnAdvancedBlending2"
{
   Properties
    {
        //暴露两个属性，分别对应 源混合类型 和 目标混合类型

        //源混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend("Src Blend",int) = 0
        //目标混合类型
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend("DstBlend",int) = 0

        _MainTex ("Texture", 2D) = "white" {}
        _Intensity ("强度", Range(0.0, 2.0)) = 1.0
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}

        //混合
        Blend [_SrcBlend][_DstBlend]
        
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            int _SrcBlend;
            int _DstBlend;
            float _Intensity;
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Intensity;
                return col;
            }
            ENDCG
        }
    }
}