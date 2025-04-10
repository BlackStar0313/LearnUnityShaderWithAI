using UnityEngine.Rendering;

[System.Serializable, VolumeComponentMenu("Custom/DrawObjectVolume")]
public class DrawObjectVolume : VolumeComponent
{
    public MaterialParameter overridMaterail = new MaterialParameter(null);
    public LayerMaskParameter filterLayerMask = new LayerMaskParameter(0);
}
