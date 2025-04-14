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
    private Texture2D m_NoiseTexture;

    public override void Create()
    {
        if (m_AoShader == null || m_BlurShader == null)
            return;

        m_AoMaterial = new Material(m_AoShader);
        m_BlurMaterial = new Material(m_BlurShader);

        CreateNoiseTexture();

        m_SSAORenderPass = new SSAORenderPass(m_AoMaterial, m_BlurMaterial);
        m_SSAORenderPass.Init(m_AoMaterial, m_BlurMaterial);
    }

    private void CreateNoiseTexture()
    {
        if (m_NoiseTexture != null)
            return;

        int textureSize = 4; // 4x4噪声纹理通常足够
        m_NoiseTexture = new Texture2D(textureSize, textureSize, TextureFormat.RGBA32, false);

        // 生成随机向量
        for (int y = 0; y < textureSize; y++)
        {
            for (int x = 0; x < textureSize; x++)
            {
                // 创建随机向量 (x,y,0)
                Vector3 randomVec = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0);
                randomVec.Normalize();

                m_NoiseTexture.SetPixel(
                    x,
                    y,
                    new Color(randomVec.x * 0.5f + 0.5f, randomVec.y * 0.5f + 0.5f, randomVec.z * 0.5f + 0.5f, 1f)
                );
            }
        }

        m_NoiseTexture.Apply();
        m_AoMaterial.SetTexture("_NoiseTexture", m_NoiseTexture);
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
