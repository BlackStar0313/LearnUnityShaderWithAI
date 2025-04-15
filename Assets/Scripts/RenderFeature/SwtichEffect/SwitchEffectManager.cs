using UnityEngine;
using UnityEngine.Rendering;

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

    public void ApplyEffectProfile(int profileIndex)
    {
        if (profileIndex < 0 || profileIndex >= m_VolumeProfiles.Length)
            return;

        m_Volume.profile = m_VolumeProfiles[profileIndex];
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
}
