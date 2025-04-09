using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RFSwitchColorMono : MonoBehaviour
{
    private RFSwitchColorPass m_RenderPass;

    [SerializeField]
    private Shader m_Shader;

    public void OnEnable()
    {
        m_RenderPass = new RFSwitchColorPass(m_Shader);
        m_RenderPass.Init();
        RenderPipelineManager.beginCameraRendering += OnBeginCamera;
    }

    private void OnDisable()
    {
        RenderPipelineManager.beginCameraRendering -= OnBeginCamera;
        m_RenderPass.Dispose();
    }

    private void OnBeginCamera(ScriptableRenderContext context, Camera camera)
    {
        m_RenderPass.SetUp();
        var scriptableRender = camera.GetUniversalAdditionalCameraData().scriptableRenderer;
        scriptableRender.EnqueuePass(m_RenderPass);
    }
}
