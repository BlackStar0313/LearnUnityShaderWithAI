Shader "Custom/LearnBasicToonShading"
{
    Properties
    {
        _MainTex ("基础纹理", 2D) = "white" {}
        _Color ("基础颜色", Color) = (1,1,1,1)
        _RampTex ("光照渐变图", 2D) = "white" {} // 控制明暗过渡
        _RampSmooth ("渐变平滑度", Range(0, 1)) = 0.1
        _OutlineColor ("轮廓颜色", Color) = (0,0,0,1)
        _OutlineWidth ("轮廓宽度", Range(0, 0.1)) = 0.01
    }
    
    SubShader
    {
        // 第一个Pass：绘制物体表面
        Pass
        {
            Tags { "LightMode"="ForwardBase" } // 使用前向渲染基础光照
			  // Tags { "RenderType"="Opaque" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            // 定义宏以启用渐变纹理
            #define USE_RAMP_TEXTURE            


            sampler2D _MainTex;
            sampler2D _RampTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _RampSmooth;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // 计算世界空间法线和位置
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
				// 1. 基础纹理采样
				fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
				
				// 2. 准备简化光照计算
				float3 worldNormal = normalize(i.worldNormal);
				float3 lightDir = normalize(float3(1, 1, -1)); // 固定光源方向
				
				// 3. 计算漫反射 (N·L)
				float NdotL = dot(worldNormal, lightDir);
				
				// 4. 使用半兰伯特模型
				float halfLambert = NdotL * 0.5 + 0.5;
				
				// 5. 应用渐变平滑
				float rampValue = smoothstep(halfLambert - _RampSmooth, halfLambert + _RampSmooth, 0.5);
				
				// 6. 使用渐变纹理
				#ifdef USE_RAMP_TEXTURE
					fixed3 ramp = tex2D(_RampTex, float2(rampValue, 0.5)).rgb;
				#else
					// 简化版：仅使用两个颜色区域
					fixed3 ramp = step(0.5, rampValue);
				#endif
				
				// 7. 最终颜色
				fixed3 finalColor = albedo.rgb * ramp;
				
				float rim = 1.0 - saturate(dot(worldNormal, normalize(float3(0,0,1)))); // 视图方向
				rim = smoothstep(0.6, 1.0, rim);
				finalColor += rim * float3(0.3, 0.3, 0.3); // 边缘高光
				
				float3 halfDir = normalize(lightDir + float3(0,0,1));
				float spec = pow(max(0, dot(worldNormal, halfDir)), 20);
				spec = step(0.8, spec); // 卡通化高光
				finalColor += spec * float3(0.3, 0.3, 0.3);
				
				return fixed4(finalColor, albedo.a);
            }
            ENDCG
        }
        
        // 第二个Pass：绘制轮廓线
        Pass
        {
            Cull Front // 渲染背面
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            float _OutlineWidth;
            fixed4 _OutlineColor;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
            };
            
            v2f vert (appdata v)
            {
                v2f o;
                
                // 沿法线方向扩展顶点
                float3 normal = normalize(v.normal);
                float3 extrudedPos = v.vertex.xyz + normal * _OutlineWidth;
                
                o.pos = UnityObjectToClipPos(float4(extrudedPos, 1));
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}