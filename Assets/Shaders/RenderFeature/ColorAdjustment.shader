   Shader "TestRenderFeature/ColorAdjustment"
   {
       Properties {
          _Intensity ("Intensity", Range(0, 1)) = 0
       }
       
       SubShader
       {
           Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
           
           Pass
           {
               ZWrite Off
               ZTest Always
               Cull Off
               
               HLSLPROGRAM
               #pragma vertex Vert
               #pragma fragment frag
               
               #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
               #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
               
               CBUFFER_START(UnityPerMaterial)
               float _Intensity;
               CBUFFER_END

            //    struct Attributes
            //    {
            //        float4 positionOS : POSITION;
            //        float2 uv : TEXCOORD0;
            //    };
               
            //    struct Varyings
            //    {
            //        float4 positionCS : SV_POSITION;
            //        float2 uv : TEXCOORD0;
            //    };
               
            //    Varyings vert(Attributes input)
            //    {
            //        Varyings output;
            //        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            //        output.uv = input.uv;
            //        return output;
            //    }
               
               half4 frag(Varyings input) : SV_Target
               {
                   // 返回纯红色
                   half4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, input.texcoord);
                   half4 addValue = half4(0.25, 0.25, 0.25, 1);
                   return color + addValue * _Intensity;
               }
               ENDHLSL
           }
       }
   }