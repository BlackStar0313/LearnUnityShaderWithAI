using System.Collections.Generic;
using Unity.Profiling;
using UnityEditor.Rendering.Analytics;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class SwitchEffectManager : MonoBehaviour
{
    [SerializeField]
    private Volume m_Volume;

    [SerializeField]
    private VolumeProfile[] m_VolumeProfiles;

    [SerializeField]
    private string[] m_EffectNames;

    [Header("Performance")]
    [SerializeField]
    private bool m_EnablePerformanceMode = true;
    private float frameTimeAvg = 0f;
    private int frameCount = 0;

    [System.Serializable]
    public class PerformanceData
    {
        public string EffectName;
        public float FrameTimeMs;
        public int DrawCalls;
    }

    [SerializeField]
    private List<PerformanceData> performanceReport = new List<PerformanceData>();

    [SerializeField]
    private bool highQuality = true;

    // 在类成员变量中添加
    private ProfilerRecorder drawCallsRecorder;
    private ProfilerRecorder setPassCallsRecorder;

    [SerializeField]
    private void Start()
    {
        if (m_Volume == null)
            m_Volume = GetComponent<Volume>();

        if (m_Volume == null)
        {
            Debug.LogError("No volume found!!!!");
            return;
        }
    }

    void OnEnable()
    {
        drawCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "Draw Calls Count");
        setPassCallsRecorder = ProfilerRecorder.StartNew(ProfilerCategory.Render, "SetPass Calls Count");
    }

    void OnDisable()
    {
        drawCallsRecorder.Dispose();
        setPassCallsRecorder.Dispose();
    }

    public void ApplyEffectProfile(int profileIndex)
    {
        if (profileIndex < 0 || profileIndex >= m_VolumeProfiles.Length)
            return;

        m_Volume.profile = m_VolumeProfiles[profileIndex];

        this.RecordCurrentPerformance(m_EffectNames[profileIndex]);
    }

    private void Update()
    {
        //简单性能监测
        frameTimeAvg = (frameTimeAvg * frameCount + Time.deltaTime) / (frameCount + 1);
        frameCount = (frameCount + 1) % 30;
    }

    private void OnGUI()
    {
        if (!m_EnablePerformanceMode)
            return;

        GUI.Label(new Rect(Screen.width - 200, 10, 200, 20), $"FPS: {1f / frameTimeAvg:F1}");
        GUI.Label(new Rect(Screen.width - 200, 30, 200, 20), $"Frame Time: {frameTimeAvg * 1000:F2}ms");
    }

    public void RecordCurrentPerformance(string effectName)
    {
        int drawCalls = (int)(drawCallsRecorder.Valid ? drawCallsRecorder.LastValue : 0);

        PerformanceData data = new PerformanceData
        {
            EffectName = effectName,
            FrameTimeMs = frameTimeAvg * 1000f,
            DrawCalls = drawCalls,
        };

        performanceReport.Add(data);
        Debug.Log($"效果 '{effectName}' 性能数据: {data.FrameTimeMs:F2}ms, {data.DrawCalls} 绘制调用");
    }

    public void ToggleQuality()
    {
        highQuality = !highQuality;

        // 修改后的代码 - 使用ScriptableRendererData类型
        var urpAsset = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
        if (urpAsset != null)
        {
            foreach (var rendererData in urpAsset.rendererDataList)
            {
                if (rendererData != null)
                {
                    foreach (var feature in rendererData.rendererFeatures)
                    {
                        // 设置质量
                        if (feature is ColorGradingFeature colorGradingFeature)
                        {
                            colorGradingFeature.SetQuality(highQuality); // 设置降采样因子
                        }
                    }
                }
            }
        }
    }
}
