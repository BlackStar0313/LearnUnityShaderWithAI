using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ColorGradingFeature : ScriptableRendererFeature
{
    [SerializeField]
    private Shader m_Shader;

    private Material m_Material;

    private ColorGradingPass m_ColorGradingPass;

    public override void Create()
    {
        if (m_Shader == null)
        {
            Debug.LogError("Shader is not assigned");
            return;
        }

        m_Material = new Material(m_Shader);

        m_ColorGradingPass = new ColorGradingPass();
        m_ColorGradingPass.Init(m_Material);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var volume = VolumeManager.instance.stack.GetComponent<ColorGradingVolumeComponent>();
        if (!volume.IsActive())
        {
            return;
        }

        SetupRenderPasses(renderer, renderingData);
        renderer.EnqueuePass(m_ColorGradingPass);
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData)
    {
        m_ColorGradingPass.SetUp();
    }

    protected override void Dispose(bool disposing)
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
}
