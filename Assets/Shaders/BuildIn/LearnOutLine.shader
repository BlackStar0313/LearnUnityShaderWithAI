Shader "Custom/LearnOutline"
{
    Properties
    {
        _MainTex ("主纹理", 2D) = "white" {}
        _OutlineColor ("描边颜色", Color) = (0,0,0,1)
        _OutlineWidth ("描边宽度", Range(0, 1)) = 0.1
    }
    
    SubShader
    {
        // 确保在透明物体之前渲染
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Geometry"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
           // Cull Front
           // ZWrite On
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float _OutlineWidth;
            float4 _OutlineColor;
            
            v2f vert (appdata v)
            {
                v2f o;
                
                // 沿法线方向扩展顶点
                float3 pos = v.vertex + v.normal * _OutlineWidth;
                o.pos = TransformObjectToHClip(pos);
                return o;;
            }
            
            float4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}