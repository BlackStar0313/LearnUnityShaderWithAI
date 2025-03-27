Shader "Custom/URPAdvancedBlending"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SecondTex ("Second Texture", 2D) = "white" {}
		_BaseColor ("Base Color", Color) = (1,1,1,1)
		_SecondColor ("Second Color", Color) = (1,1,1,1)


		[Space(10)]
		[Header(Blend)]
		_BlendFactor ("Blend Factor", Range(0, 1)) = 0.5
		[Toggle(_USE_MASK_ON)] _UseMask ("Use Mask Texture", Float) = 0
		_MaskTex ("Mask Texture", 2D) = "white" {}

		[Space(10)]
		[Header(Animation)]
		[Toggle(_USE_ANIMATION_ON)] _UseAnimation ("Use Animation", Float) = 0
		_MoveSpeed ("Move Speed", Vector) = (0.1,0,0,0)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"RenderPipeline"="UniversalPipeline"
			"Queue"="Geometry"
		}

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode"="UniversalForward" }

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma shader_feature_local _USE_MASK_ON
			#pragma shader_feature_local _USE_ANIMATION_ON
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			TEXTURE2D(_SecondTex);
			SAMPLER(sampler_SecondTex);

			TEXTURE2D(_MaskTex);
			SAMPLER(sampler_MaskTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			float4 _SecondTex_ST;
			float4 _MaskTex_ST;
			float4 _BaseColor;
			float4 _SecondColor;
			float4 _MoveSpeed;
			float _BlendFactor;
			float _UseMask;
			float _UseAnimation;
			CBUFFER_END

			struct Attributes
			{
				float4 positionOS : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
				float2 uvMain : TEXCOORD0;
				float2 uvSecond : TEXCOORD1;
				float2 uvMask : TEXCOORD2;
			};

			Varyings vert(Attributes IN)
			{
				Varyings OUT;
				OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.uvMain = TRANSFORM_TEX(IN.uv, _MainTex);
				#if _USE_ANIMATION_ON
					OUT.uvSecond = TRANSFORM_TEX(IN.uv, _SecondTex) + _MoveSpeed * _Time.y;
				#else 
					OUT.uvSecond = TRANSFORM_TEX(IN.uv, _SecondTex);
				#endif
				OUT.uvMask = TRANSFORM_TEX(IN.uv, _MaskTex);
				return OUT;
			}

			half4 frag(Varyings IN) : SV_Target
			{
				half4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvMain);
				half4 secondColor = SAMPLE_TEXTURE2D(_SecondTex, sampler_SecondTex, IN.uvSecond);
				half4 maskColor = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, IN.uvMask);

				float blendFactor = _BlendFactor;

				#if _USE_MASK_ON
					blendFactor = maskColor.r * _BlendFactor;
				#endif

				half4 finalColor = lerp(mainColor, secondColor, blendFactor);
				return finalColor;
			}
			ENDHLSL
		}
	}
}