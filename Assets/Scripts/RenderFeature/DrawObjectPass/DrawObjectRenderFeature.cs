using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DrawObjectRenderFeature : ScriptableRendererFeature
{
    public DrawObjectRenderPass m_RenderPass;

    public Material overridMaterial;
    public LayerMask filterLayerMask;

    public override void Create()
    {
        m_RenderPass = new DrawObjectRenderPass();
        m_RenderPass.Init(overridMaterial, filterLayerMask);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        m_RenderPass.SetUp();
    }

    protected override void Dispose(bool disposing)
    {
        m_RenderPass.Dispose();
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        SetupRenderPasses(renderer, renderingData);
        renderer.EnqueuePass(m_RenderPass);
        Debug.Log("AddRenderPasses");
    }
}
