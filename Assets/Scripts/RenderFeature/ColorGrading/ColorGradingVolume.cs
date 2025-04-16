using System;
using UnityEngine;
using UnityEngine.Rendering;

[Serializable, VolumeComponentMenu("Custom/ColorGrading")]
public class ColorGradingVolumeComponent : VolumeComponent
{
    public BoolParameter m_EnableColorGrading = new BoolParameter(false);

    //基础颜色调整
    public ClampedFloatParameter Brightness = new ClampedFloatParameter(0.0f, -1.0f, 1.0f);
    public ClampedFloatParameter Contrast = new ClampedFloatParameter(0f, -1.0f, 1.0f);
    public ClampedFloatParameter Saturation = new ClampedFloatParameter(0f, -1f, 1f);

    //色温调整
    public ClampedFloatParameter Temperature = new ClampedFloatParameter(0f, -1f, 1f);
    public ClampedFloatParameter Tint = new ClampedFloatParameter(0f, -1f, 1f);

    // 色彩平衡（分色条控制)
    public ColorParameter ShadowsColor = new ColorParameter(Color.white);
    public ColorParameter MidtonesColor = new ColorParameter(Color.white);
    public ColorParameter HighlightsColor = new ColorParameter(Color.white);

    public bool IsActive()
    {
        return m_EnableColorGrading.value;
    }
}
