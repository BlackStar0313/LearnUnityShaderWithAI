using System;
using UnityEngine.Rendering;

[Serializable, VolumeComponentMenu("Custom/ColorGrading")]
public class ColorGradingVolumeComponent : VolumeComponent
{
    public BoolParameter m_EnableColorGrading = new BoolParameter(false);

    public bool IsActive()
    {
        return m_EnableColorGrading.value;
    }
}
