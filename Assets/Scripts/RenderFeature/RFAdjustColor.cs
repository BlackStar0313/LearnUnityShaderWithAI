using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class RFAdjustColorRenderFeature : ScriptableRendererFeature
{
    [SerializeField]
    public float Intensity;

    [SerializeField]
    private Shader m_Shader;

    private RFAdjustColorRenderPass m_RenderPass;
    private Material m_Material;

    public override void Create()
    {
        if (m_Shader == null)
        {
            Debug.LogError("Shader is not assigned");
            return;
        }

        var data = new RFAdjustColorData();
        data.Intensity = Intensity;

        m_Material = new Material(m_Shader);
        m_RenderPass = new RFAdjustColorRenderPass(m_Material, data);
        m_RenderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    protected override void Dispose(bool disposing)
    {
        if (Application.isPlaying)
        {
            Destroy(m_Material);
        }
        else
        {
            DestroyImmediate(m_Material);
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_RenderPass);
    }
}

public class RFAdjustColorRenderPass : ScriptableRenderPass
{
    private Material m_Material;
    private RenderTextureDescriptor m_RenderTextureDescriptor;
    private RFAdjustColorData m_Data;

    private static readonly int IntensityId = Shader.PropertyToID("_Intensity");

    public RFAdjustColorRenderPass(Material material, RFAdjustColorData data)
    {
        m_Material = material;
        m_Data = data;
        m_RenderTextureDescriptor = new RenderTextureDescriptor(
            Screen.width,
            Screen.height,
            RenderTextureFormat.Default,
            0
        );
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameContext)
    {
        //read
        UniversalResourceData resourceData = frameContext.Get<UniversalResourceData>();
        UniversalCameraData cameraData = frameContext.Get<UniversalCameraData>();

        if (resourceData.isActiveTargetBackBuffer)
        {
            return;
        }

        TextureHandle srcCamColor = resourceData.activeColorTexture;
        if (!srcCamColor.IsValid())
        {
            return;
        }

        m_RenderTextureDescriptor.width = cameraData.cameraTargetDescriptor.width;
        m_RenderTextureDescriptor.height = cameraData.cameraTargetDescriptor.height;
        m_RenderTextureDescriptor.depthBufferBits = 0;

        //创建临时纹理
        TextureHandle dst = UniversalRenderer.CreateRenderGraphTexture(
            renderGraph,
            m_RenderTextureDescriptor,
            "RFAdjustColorRenderPass",
            false
        );

        m_Material.SetFloat(IntensityId, m_Data.Intensity);

        //write
        //将相机颜色传入 后处理shader进行处理
        RenderGraphUtils.BlitMaterialParameters blitParams = new(srcCamColor, dst, m_Material, 0);
        renderGraph.AddBlitPass(blitParams, "AdjustColor");

        RenderGraphUtils.BlitMaterialParameters paraHorizontal = new(dst, srcCamColor, m_Material, 0);
        renderGraph.AddBlitPass(paraHorizontal, "AdjustColor222222");

        //将处理后的结果写入颜色缓冲区.
        // renderGraph.AddCopyPass(dst, resourceData.activeColorTexture);
        // resourceData.PassColorAttachment(dst);

        // using (var builder = renderGraph.AddRasterRenderPass<FinalCopyPassData>("FinalCopyPass", out var passData))
        // {
        //     builder.SetRenderAttachment(passData.destination, 0);
        //     builder.SetRenderFunc((FinalCopyPassData data, RasterGraphContext context) => Execute(data, context));
        // }
    }

    // private void Execute(FinalCopyPassData data, RasterGraphContext context)
    // {
    //     Blitter.BlitCameraTexture(context.cmd, data.source, data.destination);
    // }
}

public class RFAdjustColorData
{
    public float Intensity;
}

class FinalCopyPassData
{
    public TextureHandle source;
    public TextureHandle destination;
}
