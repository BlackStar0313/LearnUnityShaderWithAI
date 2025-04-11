using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class EdgeDetectionRenderPass : ScriptableRenderPass
{
    internal class PassData
    {
        public Material Material;
        public TextureHandle DepthTexture;
        public TextureHandle DepthNormalsTexture;
        public TextureHandle SourceTexture;
        public TextureHandle NormalsTexture;
        public TextureHandle TempTarget;
    }

    private Material m_Material;

    //shader 属性ID
    private static readonly int s_EdgeColorId = Shader.PropertyToID("_EdgeColor");
    private static readonly int s_EdgeThicknessId = Shader.PropertyToID("_EdgeThickness");
    private static readonly int s_EdgeThresholdId = Shader.PropertyToID("_EdgeThreshold");

    public void Init(Material material)
    {
        m_Material = material;
        profilingSampler = new ProfilingSampler("EdgeDetectionRenderPass");
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public void SetUp()
    {
        EdgeDetectionVolume volume = VolumeManager.instance.stack.GetComponent<EdgeDetectionVolume>();
        if (!volume)
            return;

        m_Material.SetColor(s_EdgeColorId, volume.EdgeColor.value);
        m_Material.SetFloat(s_EdgeThicknessId, volume.EdgeThickness.value);
        m_Material.SetFloat(s_EdgeThresholdId, volume.EdgeThreshold.value);
    }

    public void Dispose() { }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        using (var builder = renderGraph.AddRasterRenderPass<PassData>("EdgeDetectionRenderPass", out PassData data))
        {
            builder.SetRenderAttachment(resourceData.activeColorTexture, 0);
            builder.UseAllGlobalTextures(true);
            builder.AllowPassCulling(false);
            builder.SetRenderFunc<PassData>((PassData data, RasterGraphContext context) => ExecutePass(data, context));
        }

        // using (var builder = renderGraph.AddRasterRenderPass<PassData>("EdgeDetectionRenderPass", out PassData data))
        // {
        //     //pass data
        //     UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        //     UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        //     if (resourceData.isActiveTargetBackBuffer || !resourceData.activeColorTexture.IsValid())
        //         return;

        //     //创建临时纹理
        //     // RenderTextureDescriptor tempDesc = cameraData.cameraTargetDescriptor;
        //     // tempDesc.depthBufferBits = 0;

        //     // TextureHandle tempTarget = UniversalRenderer.CreateRenderGraphTexture(
        //     //     renderGraph,
        //     //     tempDesc,
        //     //     "EdgeDetectionTempTarget",
        //     //     false
        //     // );

        //     data.Material = m_Material;
        //     data.SourceTexture = resourceData.activeColorTexture;
        //     // data.TempTarget = tempTarget;
        //     data.DepthTexture = resourceData.activeDepthTexture;
        //     data.DepthNormalsTexture = resourceData.cameraNormalsTexture;

        //     //read
        //     // builder.UseTexture(data.SourceTexture);
        //     // builder.UseTexture(data.DepthTexture);
        //     // builder.UseTexture(data.DepthNormalsTexture);
        //     //write
        //     builder.SetRenderAttachment(data.SourceTexture, 0, AccessFlags.ReadWrite);
        //     // builder.SetRenderAttachmentDepth(resourceData.activeDepthTexture, AccessFlags.ReadWrite);

        //     //process
        //     builder.SetRenderFunc<PassData>((PassData data, RasterGraphContext context) => ExecutePass(data, context));
        // }
    }

    private void ExecutePass(PassData data, RasterGraphContext context)
    {
        Blitter.BlitTexture(context.cmd, Vector2.one, m_Material, 0);
    }

    // private void ExecutePass(PassData data, RasterGraphContext context)
    // {
    //     Blitter.BlitTexture(context.cmd, data.SourceTexture, new Vector4(1, 1, 0, 0), data.Material, 0);
    // }
}
