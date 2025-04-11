using UnityEngine;
using UnityEngine.Rendering;

[System.Serializable, VolumeComponentMenu("Custom/EdgeDetection")]
public class EdgeDetectionVolume : VolumeComponent
{
    public ClampedFloatParameter EdgeThreshold = new ClampedFloatParameter(0.1f, 0f, 1f);
    public ColorParameter EdgeColor = new ColorParameter(Color.black);
    public ClampedFloatParameter EdgeThickness = new ClampedFloatParameter(1f, 0f, 5f);
    public BoolParameter EnableEdgeDetection = new BoolParameter(true);
}
