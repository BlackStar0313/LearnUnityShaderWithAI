using UnityEngine.Rendering;

public class ColorGradingVolumeComponent : VolumeComponent
{
    public BoolParameter m_EnableColorGrading = new BoolParameter(false);

    public bool IsActive()
    {
        return m_EnableColorGrading.value;
    }
}
