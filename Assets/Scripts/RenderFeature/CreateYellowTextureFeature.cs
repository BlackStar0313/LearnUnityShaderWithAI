using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class CreateYellowTextureFeature : ScriptableRendererFeature
{
    CreateYellowTexture customPass;

    public override void Create()
    {
        customPass = new CreateYellowTexture();
        customPass.renderPassEvent = RenderPassEvent.AfterRendering;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(customPass);
    }

    class CreateYellowTexture : ScriptableRenderPass
    {
        class PassData
        {
            internal TextureHandle cameraColorTexture;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameContext)
        {
            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Create yellow texture", out var passData))
            {
                // 获取当前相机的颜色目标
                UniversalResourceData resourceData = frameContext.Get<UniversalResourceData>();
                TextureHandle cameraColorTarget = resourceData.activeColorTexture;

                // Create texture properties that match the screen size
                RenderTextureDescriptor textureProperties = new RenderTextureDescriptor(
                    Screen.width,
                    Screen.height,
                    RenderTextureFormat.Default,
                    0
                );

                // Create a temporary texture
                TextureHandle texture = UniversalRenderer.CreateRenderGraphTexture(
                    renderGraph,
                    textureProperties,
                    "My texture",
                    false
                );

                builder.SetRenderAttachment(cameraColorTarget, 0, AccessFlags.Write);

                builder.AllowPassCulling(false);
                // 保存对颜色目标的引用，以便在执行函数中使用
                passData.cameraColorTexture = cameraColorTarget;

                builder.SetRenderFunc((PassData data, RasterGraphContext context) => ExecutePass(data, context));
            }
        }

        static void ExecutePass(PassData data, RasterGraphContext context)
        {
            // 使用非常明显的颜色
            Color brightMagenta = new Color(1, 0, 1, 1);
            Debug.Log($"执行黄色渲染 - 目标纹理有效: {data.cameraColorTexture.IsValid()}");

            // Clear the render target to yellow
            context.cmd.ClearRenderTarget(true, true, brightMagenta);
        }
    }
}
