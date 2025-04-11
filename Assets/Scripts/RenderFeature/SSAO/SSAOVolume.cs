using UnityEngine.Rendering;

[System.Serializable, VolumeComponentMenu("Custom/SSAO")]
public class SSAOVolumeComponent : VolumeComponent
{
    public ClampedFloatParameter Intensity = new ClampedFloatParameter(1f, 0f, 4f);
    public ClampedFloatParameter Radius = new ClampedFloatParameter(0.5f, 0.1f, 1f);
    public ClampedFloatParameter SampleCount = new ClampedFloatParameter(16f, 4f, 32f);
    public ClampedFloatParameter BlurSize = new ClampedFloatParameter(1f, 0f, 4f);
    public BoolParameter Visualize = new BoolParameter(false);
}
