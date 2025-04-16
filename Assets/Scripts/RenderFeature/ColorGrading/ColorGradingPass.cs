using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class ColorGradingPass : ScriptableRenderPass
{
    private class CustomPassData
    {
        internal TextureHandle SrcColor;
        internal TextureHandle tempColor; //临时渲染目标
        internal Material OverridMaterial;
    }

    private Material m_Material;
    private int m_DownsampleFactor = 1; //降采样因子

    public void Init(Material material)
    {
        m_Material = material;
        profilingSampler = new ProfilingSampler("ColorGradingPass");
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetUp()
    {
        var volume = VolumeManager.instance.stack.GetComponent<ColorGradingVolumeComponent>();

        if (volume != null && volume.IsActive())
        {
            m_Material.SetFloat("_Brightness", volume.Brightness.value);
            m_Material.SetFloat("_Contrast", volume.Contrast.value);
            m_Material.SetFloat("_Saturation", volume.Saturation.value);
            m_Material.SetFloat("_Temperature", volume.Temperature.value);
            m_Material.SetFloat("_Tint", volume.Tint.value);
            m_Material.SetColor("_ShadowsColor", volume.ShadowsColor.value);
            m_Material.SetColor("_MidtonesColor", volume.MidtonesColor.value);
            m_Material.SetColor("_HighlightsColor", volume.HighlightsColor.value);
        }
    }

    public void SetDownsampleFactor(int downsampleFactor)
    {
        m_DownsampleFactor = downsampleFactor;
    }

    public void Dispose() { }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        if (m_DownsampleFactor <= 1)
        {
            using (var builder = renderGraph.AddRasterRenderPass<CustomPassData>(passName, out CustomPassData data))
            {
                data.SrcColor = resourceData.activeColorTexture;
                data.OverridMaterial = m_Material;

                builder.SetRenderAttachment(resourceData.activeColorTexture, 0, AccessFlags.ReadWrite);
                builder.SetRenderFunc<CustomPassData>(
                    (CustomPassData data, RasterGraphContext context) => ExcutePass(data, context)
                );
            }
        }
        else
        {
            // 降采样版本
            RenderTextureDescriptor lowResDesc = cameraData.cameraTargetDescriptor;
            lowResDesc.width /= m_DownsampleFactor;
            lowResDesc.height /= m_DownsampleFactor;
            lowResDesc.depthBufferBits = 0; // 确保没有深度位
            lowResDesc.colorFormat = RenderTextureFormat.ARGB32; // 明确指定颜色格式

            // 创建临时纹理
            TextureHandle tempTexture = UniversalRenderer.CreateRenderGraphTexture(
                renderGraph,
                lowResDesc,
                "ColorGrading_Temp",
                false
            );

            // 第一步：从相机颜色纹理到临时纹理的降采样处理
            RenderGraphUtils.BlitMaterialParameters blitParamsDown = new(
                resourceData.activeColorTexture,
                tempTexture,
                m_Material,
                0
            );
            renderGraph.AddBlitPass(blitParamsDown, "ColorGrading_Downsample");

            // 第二步：从临时纹理上采样回相机颜色纹理
            RenderGraphUtils.BlitMaterialParameters blitParamsUp = new(
                tempTexture,
                resourceData.activeColorTexture,
                m_Material,
                0
            );
            renderGraph.AddBlitPass(blitParamsUp, "ColorGrading_Upsample");

            // // 创建降采样描述符和纹理
            // RenderTextureDescriptor lowResDesc = cameraData.cameraTargetDescriptor;
            // lowResDesc.width /= m_DownsampleFactor;
            // lowResDesc.height /= m_DownsampleFactor;
            // lowResDesc.depthBufferBits = 0;
            // lowResDesc.colorFormat = RenderTextureFormat.ARGB32;

            // // 创建临时纹理
            // TextureHandle tempTexture = UniversalRenderer.CreateRenderGraphTexture(
            //     renderGraph,
            //     lowResDesc,
            //     "ColorGrading_Temp",
            //     false
            // );

            // // 第一步：降采样Pass - 从原始分辨率到低分辨率
            // using (
            //     var builder = renderGraph.AddRasterRenderPass<CustomPassData>(
            //         "ColorGrading_DownsamplePass",
            //         out CustomPassData data
            //     )
            // )
            // {
            //     // 设置源和目标纹理
            //     data.SrcColor = resourceData.activeColorTexture;
            //     data.tempColor = tempTexture;
            //     data.OverridMaterial = m_Material;

            //     // 设置资源访问权限
            //     builder.UseTexture(resourceData.activeColorTexture, AccessFlags.Read);
            //     builder.SetRenderAttachment(tempTexture, 0, AccessFlags.Write);

            //     // 设置渲染函数
            //     builder.SetRenderFunc<CustomPassData>(
            //         (CustomPassData data, RasterGraphContext context) =>
            //         {
            //             // 使用Blitter在低分辨率下渲染效果
            //             Blitter.BlitTexture(
            //                 context.cmd,
            //                 data.SrcColor,
            //                 new Vector4(1, 1, 0, 0),
            //                 data.OverridMaterial,
            //                 0
            //             );
            //         }
            //     );
            // }

            // // 第二步：上采样Pass - 从低分辨率回到原始分辨率
            // using (
            //     var builder = renderGraph.AddRasterRenderPass<CustomPassData>(
            //         "ColorGrading_UpsamplePass",
            //         out CustomPassData data
            //     )
            // )
            // {
            //     // 设置源和目标纹理
            //     data.SrcColor = tempTexture;
            //     data.OverridMaterial = m_Material;

            //     // 设置资源访问权限
            //     builder.UseTexture(tempTexture, AccessFlags.Read);
            //     builder.SetRenderAttachment(resourceData.activeColorTexture, 0, AccessFlags.Write);

            //     // 设置渲染函数
            //     builder.SetRenderFunc<CustomPassData>(
            //         (CustomPassData data, RasterGraphContext context) =>
            //         {
            //             // 上采样回原始分辨率，使用同样的材质可能会再次应用效果
            //             // 所以可以传null替代材质或使用另一个只做采样的Pass
            //             Blitter.BlitTexture(context.cmd, data.SrcColor, new Vector4(1, 1, 0, 0), null, 0);
            //         }
            //     );
            // }
        }
    }

    private void ExecuteDownSamplePass(CustomPassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, data.SrcColor, new Vector4(1, 1, 0, 0), data.OverridMaterial, 0);
    }

    private void ExecuteUpsamplePass(CustomPassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, data.tempColor, new Vector4(1, 1, 0, 0), null, 0);
    }

    private void ExcutePass(CustomPassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, data.SrcColor, new Vector4(1, 1, 0, 0), data.OverridMaterial, 0);
    }
}
