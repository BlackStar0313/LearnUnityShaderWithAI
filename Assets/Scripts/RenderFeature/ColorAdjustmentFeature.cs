using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;

public class ColorAdjustmentFeature : ScriptableRendererFeature
{
    // 配置参数类
    [System.Serializable]
    public class Settings
    {
        public float brightness = 1.0f;
        public float contrast = 1.0f;
        public float saturation = 1.0f;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }

    // 公开配置参数
    public Settings settings = new Settings();
    private ColorAdjustmentPass m_RenderPass;

    [SerializeField]
    private Material m_Material; // 直接引用材质

    // 添加公开的shader字段
    [SerializeField]
    private Shader shader;

    // 创建初始化方法
    public override void Create()
    {
        if (shader == null)
        {
            Debug.LogError("请指定ColorAdjustment着色器!");
            return;
        }
        // m_Material = new Material(shader);
        if (m_Material == null)
        {
            Debug.LogError("无法创建材质!");
            return;
        }
        m_RenderPass = new ColorAdjustmentPass(m_Material, settings);
        m_RenderPass.renderPassEvent = settings.renderPassEvent;
    }

    // 添加渲染通道方法
    public override void AddRenderPasses(
        ScriptableRenderer renderer,
        ref RenderingData renderingData
    )
    {
        // 不要调用renderer.EnqueuePass(m_RenderPass)!
        // 在Unity 6中，你不需要做任何事情，因为渲染通道会通过RecordRenderGraph添加

        // // 只需进行一些基本检查
        // if (m_Material == null)
        // {
        //     Debug.LogError("ColorAdjustmentFeature: 材质为空");
        //     return;
        // }

        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            renderer.EnqueuePass(m_RenderPass);
        }
    }

    // 资源清理方法
    protected override void Dispose(bool disposing)
    {
        // 正确销毁材质
        if (disposing)
        {
            if (m_Material != null)
            {
                if (Application.isPlaying)
                    Destroy(m_Material);
                else
                    DestroyImmediate(m_Material);
            }
        }
    }
}

public class ColorAdjustmentPass : ScriptableRenderPass
{
    private Material m_Material;
    private ColorAdjustmentFeature.Settings m_Settings;
    private string m_ProfilerTag = "Color Adjustment Pass";

    // Shader属性ID
    private static readonly int s_BrightnessId = Shader.PropertyToID("_Brightness");
    private static readonly int s_ContrastId = Shader.PropertyToID("_Contrast");
    private static readonly int s_SaturationId = Shader.PropertyToID("_Saturation");
    private static readonly string s_TempTargetName = "_TempColorAdjustTarget";

    public ColorAdjustmentPass(Material material, ColorAdjustmentFeature.Settings settings)
    {
        m_Material = material;
        m_Settings = settings;
    }

    // 使用RenderGraph API实现渲染
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        Debug.Log(
            "ColorAdjustment Pass执行中: "
                + "亮度="
                + m_Settings.brightness
                + ", 对比度="
                + m_Settings.contrast
                + ", 饱和度="
                + m_Settings.saturation
        );

        // 获取资源数据
        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();

        // 如果是后台缓冲区，跳过处理
        if (resourceData.isActiveTargetBackBuffer)
            return;

        // 获取相机数据
        UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

        // 创建临时纹理描述符
        var tempDesc = cameraData.cameraTargetDescriptor;
        tempDesc.depthBufferBits = 0; // 不需要深度缓冲

        // 获取源纹理和创建临时纹理
        TextureHandle sourceTexture = resourceData.activeColorTexture;
        TextureHandle tempTarget = UniversalRenderer.CreateRenderGraphTexture(
            renderGraph,
            tempDesc,
            s_TempTargetName,
            false
        );

        // 添加渲染过程
        using (var builder = renderGraph.AddRenderPass<PassData>(m_ProfilerTag, out var passData))
        {
            // 关键修改：正确设置输入/输出
            builder.UseColorBuffer(tempTarget, 0);
            builder.ReadTexture(sourceTexture);

            // 设置数据
            passData.material = m_Material;
            passData.brightness = m_Settings.brightness;
            passData.contrast = m_Settings.contrast;
            passData.saturation = m_Settings.saturation;
            passData.brightnessId = s_BrightnessId;
            passData.contrastId = s_ContrastId;
            passData.saturationId = s_SaturationId;
            passData.sourceTexture = sourceTexture;
            passData.tempTarget = tempTarget;
            passData.finalTarget = resourceData.activeColorTexture;

            // 设置渲染函数
            builder.SetRenderFunc(
                (PassData data, RenderGraphContext context) =>
                {
                    // 设置材质属性
                    data.material.SetFloat(data.brightnessId, data.brightness);
                    data.material.SetFloat(data.contrastId, data.contrast);
                    data.material.SetFloat(data.saturationId, data.saturation);

                    // 使用Blitter替代CommandBuffer.Blit
                    Blitter.BlitCameraTexture(
                        context.cmd,
                        data.sourceTexture,
                        data.tempTarget,
                        data.material,
                        0
                    );

                    // 将结果从临时纹理复制回最终目标
                    Blitter.BlitCameraTexture(context.cmd, data.tempTarget, data.finalTarget);
                }
            );
        }
    }

    // 传递数据类
    class PassData
    {
        // 材质和属性
        public Material material;
        public float brightness;
        public float contrast;
        public float saturation;
        public int brightnessId;
        public int contrastId;
        public int saturationId;

        // 纹理句柄
        public TextureHandle sourceTexture;
        public TextureHandle tempTarget;
        public TextureHandle finalTarget;
    }
}
