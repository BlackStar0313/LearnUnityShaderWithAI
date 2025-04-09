using System.Data.Common;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class RFSwitchColorPass : ScriptableRenderPass
{
    [SerializeField]
    private Shader m_Shader;
    private Material m_Material;

    private class CustomPassData
    {
        internal TextureHandle SrcColor;
        internal Material OverridMaterial;
    }

    public RFSwitchColorPass(Shader shader)
    {
        m_Shader = shader;
    }

    public void Init()
    {
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        m_Material = new Material(m_Shader);
    }

    public void SetUp() { }

    public void Dispose()
    {
        if (Application.isPlaying)
        {
            Object.Destroy(m_Material);
        }
        else
        {
            Object.DestroyImmediate(m_Material);
        }
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        using (var builder = renderGraph.AddRasterRenderPass<CustomPassData>(passName, out CustomPassData data))
        {
            //pass Data
            data.SrcColor = frameData.Get<UniversalResourceData>().activeColorTexture;
            data.OverridMaterial = m_Material;

            //read
            //builder.UseTexture(data.screenColor);
            //write
            builder.SetRenderAttachment(data.SrcColor, 0, AccessFlags.ReadWrite);

            //process
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
