using UnityEngine;
using UnityEngine.Rendering.Universal;

class RFSwtichColorFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Shader m_Shader;

    private RFSwitchColorPass m_RenderPass;

    public override void Create()
    {
        if (m_Shader == null)
        {
            Debug.LogError("Shader is not assigned");
            return;
        }

        m_RenderPass = new RFSwitchColorPass(m_Shader);
        // m_RenderPass.Init();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        SetupRenderPasses(renderer, renderingData);
        renderer.EnqueuePass(m_RenderPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        m_RenderPass.SetUp();
    }

    protected override void Dispose(bool disposing)
    {
        if (m_RenderPass != null)
        {
            m_RenderPass.Dispose();
        }
    }
}
