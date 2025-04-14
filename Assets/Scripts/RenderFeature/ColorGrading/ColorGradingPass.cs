using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class ColorGradingPass : ScriptableRenderPass
{
    private class CustomPassData
    {
        internal TextureHandle SrcColor;
        internal Material OverridMaterial;
    }

    private Material m_Material;

    public void Init(Material material)
    {
        m_Material = material;
        profilingSampler = new ProfilingSampler("ColorGradingPass");
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetUp() { }

    public void Dispose() { }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        using (var builder = renderGraph.AddRasterRenderPass<CustomPassData>(passName, out CustomPassData data))
        {
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

            data.SrcColor = resourceData.activeColorTexture;
            data.OverridMaterial = m_Material;

            builder.SetRenderAttachment(resourceData.activeColorTexture, 0, AccessFlags.ReadWrite);
            builder.SetRenderFunc<CustomPassData>(
                (CustomPassData data, RasterGraphContext context) => ExecutePass(data, context)
            );
        }
    }

    private void ExecutePass(CustomPassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, data.SrcColor, new Vector4(1, 1, 0, 0), data.OverridMaterial, 0);
    }
}
