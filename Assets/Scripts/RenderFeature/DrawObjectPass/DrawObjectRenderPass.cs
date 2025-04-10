using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class DrawObjectRenderPass : ScriptableRenderPass
{
    private Material m_InitOverrideMaterial;
    private LayerMask m_InitFilterLayerMask;
    private Material m_OverrideMaterial;
    private LayerMask m_OverrideFilterLayerMask;

    private class CustomPassData
    {
        internal RendererListHandle rendererList;
    }

    public void Init(Material material, LayerMask layerMask)
    {
        profilingSampler = new ProfilingSampler("DrawObjectRenderPass");
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        m_InitOverrideMaterial = material;
        m_InitFilterLayerMask = layerMask;
    }

    public void SetUp()
    {
        DrawObjectVolume volume = VolumeManager.instance.stack.GetComponent<DrawObjectVolume>();
        m_OverrideMaterial =
            (volume != null && volume.overridMaterail.overrideState)
                ? volume.overridMaterail.value
                : m_InitOverrideMaterial;
        m_OverrideFilterLayerMask =
            (volume != null && volume.filterLayerMask.overrideState)
                ? volume.filterLayerMask.value
                : m_InitFilterLayerMask;

        // m_OverrideMaterial = m_InitOverrideMaterial;
        // m_OverrideFilterLayerMask = m_InitFilterLayerMask;
    }

    public void Dispose() { }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        using (var builder = renderGraph.AddRasterRenderPass<CustomPassData>(passName, out CustomPassData data))
        {
            //pass data
            UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
            UniversalLightData lightData = frameData.Get<UniversalLightData>();

            CullingResults cullingResult = renderingData.cullResults;
            ShaderTagId shaderTagId = new ShaderTagId("UniversalForward");
            SortingCriteria sortingCriteria = cameraData.defaultOpaqueSortFlags;
            DrawingSettings drawingSettings = RenderingUtils.CreateDrawingSettings(
                shaderTagId,
                renderingData,
                cameraData,
                lightData,
                sortingCriteria
            );
            drawingSettings.overrideMaterial = m_OverrideMaterial;

            RenderQueueRange renderQueueRange = RenderQueueRange.all;
            FilteringSettings filteringSettings = new FilteringSettings(renderQueueRange, m_OverrideFilterLayerMask);
            RendererListParams rendererListParams = new RendererListParams(
                cullingResult,
                drawingSettings,
                filteringSettings
            );
            data.rendererList = renderGraph.CreateRendererList(rendererListParams);

            //read
            builder.UseRendererList(data.rendererList);

            //write
            builder.SetRenderAttachment(frameData.Get<UniversalResourceData>().activeColorTexture, 0);
            builder.SetRenderAttachmentDepth(frameData.Get<UniversalResourceData>().activeDepthTexture);

            //process
            builder.SetRenderFunc<CustomPassData>(
                (CustomPassData data, RasterGraphContext context) => ExecutePass(data, context)
            );
        }
    }

    private void ExecutePass(CustomPassData data, RasterGraphContext context)
    {
        //process
        context.cmd.DrawRendererList(data.rendererList);
    }
}
