Shader "Custom/URPLitBlinnPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
		_AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.1
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Glossiness ("Glossiness", Range(0, 100)) = 30
    }

    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        pass
        {
            HLSLPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);


            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _AmbientStrength;
                float4 _SpecularColor;
                float _Glossiness;
                float4 _MainTex_ST;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL; 
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : NORMAL;
                float2 uv : TEXCOORD1;
            };

            Varyings vert(Attributes input) 
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                float3 normalWS = normalize(input.normalWS);

                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half3 albedo = texColor.rgb * _BaseColor.rgb;

                Light mainLight = GetMainLight();

                half3 ambient = albedo * _AmbientStrength;

                //Lambert diffuse 
                float NdotL =max(0, dot(normalWS, mainLight.direction)) ;
                half3 diffuse = albedo * mainLight.color * NdotL;
                 
                //Blinn-Phong specular
                //GetWorldSpaceViewDir(input.positionWS) 返回从顶点到摄像机的向量
                float3 viewDir = normalize(GetWorldSpaceViewDir(input.positionWS));
                // 半角向量，刚好是位于光照方向和视线方向的中间,数学上是，两个向量相加，等于由两个向量组成的菱形的对角线。
                float3 halfVector = normalize(mainLight.direction + viewDir);
                float NdotH = max(0, dot(normalWS, halfVector));
                half3 specular = _SpecularColor.rgb * mainLight.color * pow(NdotH, _Glossiness);

                //组合环境光，漫反射和高光
                half3 color = ambient + diffuse + specular;
                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}