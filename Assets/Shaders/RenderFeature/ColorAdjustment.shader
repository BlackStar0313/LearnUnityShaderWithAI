   Shader "TestRenderFeature/ColorAdjustment"
   {
       Properties {}
       
       SubShader
       {
           Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
           
           Pass
           {
               ZWrite Off
               ZTest Always
               Cull Off
               
               HLSLPROGRAM
               #pragma vertex vert
               #pragma fragment frag
               
               #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
               
               struct Attributes
               {
                   float4 positionOS : POSITION;
                   float2 uv : TEXCOORD0;
               };
               
               struct Varyings
               {
                   float4 positionCS : SV_POSITION;
                   float2 uv : TEXCOORD0;
               };
               
               Varyings vert(Attributes input)
               {
                   Varyings output;
                   output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                   output.uv = input.uv;
                   return output;
               }
               
               half4 frag(Varyings input) : SV_Target
               {
                   // 返回纯红色
                   return half4(1, 0, 0, 1);
               }
               ENDHLSL
           }
       }
   }