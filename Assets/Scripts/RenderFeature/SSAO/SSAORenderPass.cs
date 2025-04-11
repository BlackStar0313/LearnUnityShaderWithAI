using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class SSAORenderPass : ScriptableRenderPass
{
    private Material m_AoMaterial;
    private Material m_BlurMaterial;

    private static readonly int s_IntensityId = Shader.PropertyToID("_AOIntensity");
    private static readonly int s_RadiusId = Shader.PropertyToID("_AORadius");
    private static readonly int s_SampleCountId = Shader.PropertyToID("_SampleCount");
    private static readonly int s_BlurSizeId = Shader.PropertyToID("_BlurSize");
    private bool m_IsVisualizeAO = false;

    internal class PassData { }

    public SSAORenderPass(Material aoMaterial, Material blurMaterial)
    {
        m_AoMaterial = aoMaterial;
        m_BlurMaterial = blurMaterial;
        profilingSampler = new ProfilingSampler("SSAO Blur");
        renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
    }

    public void Init(Material aoMaterial, Material blurMaterial)
    {
        m_AoMaterial = aoMaterial;
        m_BlurMaterial = blurMaterial;
    }

    public void SetUp()
    {
        SSAOVolumeComponent ssaoVolume = VolumeManager.instance.stack.GetComponent<SSAOVolumeComponent>();
        if (ssaoVolume == null || ssaoVolume.Intensity.value <= 0f)
            return;

        m_AoMaterial.SetFloat(s_IntensityId, ssaoVolume.Intensity.value);
        m_AoMaterial.SetFloat(s_RadiusId, ssaoVolume.Radius.value);
        m_AoMaterial.SetFloat(s_SampleCountId, ssaoVolume.SampleCount.value);
        m_BlurMaterial.SetFloat(s_BlurSizeId, ssaoVolume.BlurSize.value);

        m_IsVisualizeAO = ssaoVolume.Visualize.value;
    }

    public void Dispose() { }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        if (resourceData.isActiveTargetBackBuffer || !resourceData.activeColorTexture.IsValid())
            return;

        // 创建降采样描述符（SSAO通常在较低分辨率计算）
        RenderTextureDescriptor aoDesc = cameraData.cameraTargetDescriptor;
        aoDesc.width /= 2;
        aoDesc.height /= 2;
        aoDesc.depthBufferBits = 0;

        // 创建SSAO 纹理
        TextureHandle aoTexutre = UniversalRenderer.CreateRenderGraphTexture(
            renderGraph,
            aoDesc,
            "SSAO Texture",
            false
        );
        // 创建模糊 纹理
        TextureHandle blurTexture = UniversalRenderer.CreateRenderGraphTexture(
            renderGraph,
            aoDesc,
            "Blur Texture",
            false
        );

        // SSAO 生成pass
        RenderGraphUtils.BlitMaterialParameters aoParams = new RenderGraphUtils.BlitMaterialParameters(
            resourceData.activeDepthTexture,
            aoTexutre,
            m_AoMaterial,
            0
        );
        renderGraph.AddBlitPass(aoParams, "SSAO Generation");

        // 水平模糊pass
        RenderGraphUtils.BlitMaterialParameters hBlurXParams = new RenderGraphUtils.BlitMaterialParameters(
            aoTexutre,
            blurTexture,
            m_BlurMaterial,
            0
        );
        renderGraph.AddBlitPass(hBlurXParams, "Horizontal Blur X");

        // 垂直模糊pass
        RenderGraphUtils.BlitMaterialParameters vBlurYParams = new RenderGraphUtils.BlitMaterialParameters(
            blurTexture,
            blurTexture,
            m_BlurMaterial,
            0
        );
        renderGraph.AddBlitPass(vBlurYParams, "Vertical Blur Y");

        //最终合成pass
        if (m_IsVisualizeAO)
        {
            //直接显示AO
            renderGraph.AddCopyPass(aoTexutre, resourceData.activeColorTexture);
        }
        else
        {
            // 与场景颜色融合
            RenderGraphUtils.BlitMaterialParameters blendParams = new RenderGraphUtils.BlitMaterialParameters(
                resourceData.activeColorTexture,
                resourceData.activeColorTexture,
                m_AoMaterial,
                1
            );
            m_AoMaterial.SetTexture("_AOTexture", aoTexutre);
            renderGraph.AddBlitPass(blendParams, "Blend AO");
        }

        // using (var builder = renderGraph.AddRasterRenderPass<PassData>("SSAO Render Pass", out PassData data)) { }
    }
}
