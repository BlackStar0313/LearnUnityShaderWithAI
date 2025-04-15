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
