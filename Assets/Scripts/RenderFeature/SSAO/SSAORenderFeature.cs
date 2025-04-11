using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SSAORenderFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Shader m_AoShader;

    [SerializeField]
    private Shader m_BlurShader;

    private Material m_AoMaterial;
    private Material m_BlurMaterial;
    private SSAORenderPass m_SSAORenderPass;

    public override void Create()
    {
        if (m_AoShader == null || m_BlurShader == null)
            return;

        m_AoMaterial = new Material(m_AoShader);
        m_BlurMaterial = new Material(m_BlurShader);
        m_SSAORenderPass = new SSAORenderPass(m_AoMaterial, m_BlurMaterial);
        m_SSAORenderPass.Init(m_AoMaterial, m_BlurMaterial);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (!IsActive(renderingData))
            return;

        SetupRenderPasses(renderer, renderingData);
        renderer.EnqueuePass(m_SSAORenderPass);
    }

    private bool IsActive(RenderingData renderingData)
    {
        if (
            renderingData.cameraData.cameraType == CameraType.Preview
            || renderingData.cameraData.cameraType == CameraType.Reflection
            || UniversalRenderer.IsOffscreenDepthTexture(ref renderingData.cameraData)
        )
            return false;

        if (m_AoMaterial == null || m_BlurMaterial == null)
            return false;

        var stack = VolumeManager.instance.stack;
        var ssaoVolume = stack.GetComponent<SSAOVolumeComponent>();
        return ssaoVolume != null && ssaoVolume.Intensity.value > 0f;
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        m_SSAORenderPass.SetUp();
    }

    protected override void Dispose(bool disposing)
    {
        if (Application.isPlaying)
        {
            Destroy(m_AoMaterial);
            Destroy(m_BlurMaterial);
        }
        else
        {
            DestroyImmediate(m_AoMaterial);
            DestroyImmediate(m_BlurMaterial);
        }
    }
}
