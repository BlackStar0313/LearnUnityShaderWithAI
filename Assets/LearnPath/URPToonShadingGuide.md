# URP卡通渲染着色器开发指南

既然您已经完成了基础光照模型和PBR着色器的学习，是时候开始探索卡通渲染(Toon Shading)了。根据您的学习计划，我将指导您如何在URP环境下实现卡通渲染效果。

## 卡通渲染原理

卡通渲染的核心理念是：
1. **色阶量化**：将连续的光照值量化为有限的几个色阶
2. **硬边界**：在不同色阶之间创建明显的边界
3. **轮廓线**：强调物体轮廓

## 实现步骤

### 1. 创建基础着色器结构

首先创建一个新的着色器文件：`URPToonShading.shader`

```hlsl
Shader "Custom/URPToonShading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _ShadowColor ("Shadow Color", Color) = (0.5,0.5,0.5,1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
        _ShadowSmoothness ("Shadow Smoothness", Range(0, 0.2)) = 0.01
        [Toggle] _UseRamp ("Use Ramp Texture", Float) = 0
        _RampTex ("Ramp Texture", 2D) = "white" {}
        [Normal] _NormalMap ("Normal Map", 2D) = "bump" {}
        _OutlineWidth ("Outline Width", Range(0, 0.1)) = 0.01
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    
    SubShader
    {
        Tags { 
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        
        // 主Pass - 卡通光照
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            // 这里添加顶点和片元着色器
            
            ENDHLSL
        }
        
        // 第二Pass - 轮廓线（稍后实现）
    }
}
```

### 2. 实现卡通光照计算

编写顶点和片元着色器，实现卡通光照效果：

```hlsl
// 属性和缓冲区声明
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_RampTex);
SAMPLER(sampler_RampTex);

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    float4 _NormalMap_ST;
    float4 _BaseColor;
    float4 _ShadowColor;
    float _ShadowThreshold;
    float _ShadowSmoothness;
    float _UseRamp;
    float4 _OutlineColor;
    float _OutlineWidth;
CBUFFER_END

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : NORMAL;
    float4 tangentWS : TEXCOORD2;
    float3 bitangentWS : TEXCOORD3;
};

Varyings vert(Attributes input)
{
    Varyings output;
    
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.uv = TRANSFORM_TEX(input.uv, _MainTex);
    
    // 计算TBN矩阵相关参数
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
    output.bitangentWS = cross(output.normalWS, output.tangentWS.xyz) * input.tangentOS.w;
    
    return output;
}

half4 frag(Varyings input) : SV_TARGET
{
    // 采样主纹理
    half4 albedoMap = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    half3 albedo = albedoMap.rgb * _BaseColor.rgb;
    
    // 采样并应用法线贴图
    half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
    half3 normalTS = UnpackNormal(normalMap);
    
    // 构建TBN矩阵
    float3x3 TBN = float3x3(
        normalize(input.tangentWS.xyz),
        normalize(input.bitangentWS),
        normalize(input.normalWS)
    );
    half3 normalWS = normalize(mul(normalTS, TBN));
    
    // 获取光照信息
    Light mainLight = GetMainLight(TransformWorldToShadowCoord(input.positionWS));
    float lightIntensity = dot(normalWS, mainLight.direction);
    
    // 卡通阴影计算 - 使用平滑步进创建硬边界
    float toonRamp = smoothstep(_ShadowThreshold - _ShadowSmoothness, 
                               _ShadowThreshold + _ShadowSmoothness, 
                               lightIntensity);
                               
    // 可选：使用渐变纹理
    if(_UseRamp > 0.5) {
        toonRamp = SAMPLE_TEXTURE2D(_RampTex, sampler_RampTex, float2(lightIntensity, 0.5)).r;
    }
    
    // 阴影颜色应用
    half3 shadowedColor = albedo * _ShadowColor.rgb;
    half3 litColor = albedo * mainLight.color;
    
    // 最终颜色混合 - 在明暗区域之间插值
    half3 finalColor = lerp(shadowedColor, litColor, toonRamp);
    
    // 添加基础环境光，避免阴影区域太黑
    half3 ambient = half3(0.1, 0.1, 0.1) * albedo;
    finalColor += ambient;
    
    return half4(finalColor, 1.0);
}
```

### 3. 添加轮廓线Pass

卡通渲染的一个重要特征是轮廓线。添加第二个Pass来实现这一效果：

```hlsl
// 在第一个Pass后添加
Pass
{
    Name "Outline"
    Tags { }
    
    Cull Front // 剔除正面，只渲染背面
    
    HLSLPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    CBUFFER_START(UnityPerMaterial)
        float _OutlineWidth;
        float4 _OutlineColor;
    CBUFFER_END
    
    struct Attributes
    {
        float4 positionOS : POSITION;
        float3 normalOS : NORMAL;
    };
    
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
    };
    
    Varyings vert(Attributes input)
    {
        Varyings output;
        
        // 沿法线方向扩展顶点
        float3 positionOS = input.positionOS.xyz + input.normalOS * _OutlineWidth;
        output.positionCS = TransformObjectToHClip(positionOS);
        
        return output;
    }
    
    half4 frag(Varyings input) : SV_TARGET
    {
        return _OutlineColor;
    }
    
    ENDHLSL
}
```

### 4. 添加ShadowCaster Pass

为使卡通模型能够正确投射阴影，添加ShadowCaster Pass：

```hlsl
// 在其他Pass后添加
Pass
{
    Name "ShadowCaster"
    Tags { "LightMode" = "ShadowCaster" }
    
    ZWrite On
    ZTest LEqual
    ColorMask 0
    
    HLSLPROGRAM
    #pragma vertex ShadowPassVertex
    #pragma fragment ShadowPassFragment
    
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
    ENDHLSL
}
```

## 高级技巧与增强

1. **多级色阶**：扩展您的卡通着色器以支持多级色阶

```hlsl
// 添加属性
_MidToneThreshold ("Mid Tone Threshold", Range(0, 1)) = 0.75
_MidToneColor ("Mid Tone Color", Color) = (0.7,0.7,0.7,1)

// 修改片元着色器中的色阶计算
float midToneRamp = smoothstep(_MidToneThreshold - _ShadowSmoothness, 
                             _MidToneThreshold + _ShadowSmoothness, 
                             lightIntensity);
                             
half3 midToneColor = albedo * _MidToneColor.rgb;
half3 finalColor = lerp(shadowedColor, midToneColor, toonRamp);
finalColor = lerp(finalColor, litColor, midToneRamp);
```

2. **高光色阶**：添加卡通式高光

```hlsl
// 添加高光属性
_SpecularColor ("Specular Color", Color) = (1,1,1,1)
_SpecularThreshold ("Specular Threshold", Range(0.1, 1)) = 0.8
_SpecularSmoothness ("Specular Smoothness", Range(0, 0.2)) = 0.05

// 片元着色器中添加高光计算
float3 viewDir = normalize(GetWorldSpaceViewDir(input.positionWS));
float3 halfVector = normalize(mainLight.direction + viewDir);
float NdotH = max(0, dot(normalWS, halfVector));

float specularRamp = smoothstep(_SpecularThreshold - _SpecularSmoothness,
                               _SpecularThreshold + _SpecularSmoothness,
                               NdotH);
                               
half3 specular = _SpecularColor.rgb * specularRamp;
finalColor += specular;
```

3. **基于深度的改进轮廓线**

对于更高级的轮廓线效果，可以考虑基于深度重建实现轮廓线，这需要通过Render Feature实现。

## 测试与调整

创建此着色器后，您应该：

1. 应用到简单模型上测试基本效果
2. 测试不同光照方向下的阴影效果
3. 调整阈值参数找到最佳视觉效果
4. 尝试使用渐变纹理代替硬编码阈值
5. 尝试不同风格的轮廓线厚度和颜色

## 下一步学习

成功实现卡通渲染后，您可以：

1. 学习多Pass渲染中的数据传递
2. 探索更多NPR(非真实感渲染)技术
3. 开始URP Render Features开发，以实现后处理轮廓线

完成这个卡通渲染着色器后，您将掌握URP着色器开发的核心概念，并为进阶到Render Features学习做好充分准备。 