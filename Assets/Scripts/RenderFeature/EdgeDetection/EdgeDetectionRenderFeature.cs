using UnityEngine;
using UnityEngine.Rendering.Universal;

public class EdgeDetectionRenderFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Shader m_Shader;

    private EdgeDetectionRenderPass m_RenderPass;
    private Material m_Material;

    public override void Create()
    {
        if (m_Shader == null)
        {
            Debug.LogError("EdgeDetectionRenderFeature: Shader is not assigned");
            return;
        }

        m_Material = new Material(m_Shader);
        m_RenderPass = new EdgeDetectionRenderPass();
        m_RenderPass.Init(m_Material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (!IsActive(renderingData))
        {
            return;
        }
        m_RenderPass.SetUp();
        renderer.EnqueuePass(m_RenderPass);
    }

    private bool IsActive(RenderingData renderingData)
    {
        if (m_Material == null)
            return false;

        return true;
    }

    protected override void Dispose(bool disposing)
    {
        if (m_Material != null)
        {
            if (Application.isPlaying)
                Object.Destroy(m_Material);
            else
                Object.DestroyImmediate(m_Material);
        }
    }
}
