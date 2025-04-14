using UnityEngine;

public class NoiseTextureGenerator : MonoBehaviour
{
    [SerializeField]
    private int textureSize = 4;

    [SerializeField]
    private string textureName = "SSAONoise";

    [ContextMenu("Generate Noise Texture")]
    void GenerateNoiseTexture()
    {
        var texture = new Texture2D(textureSize, textureSize, TextureFormat.RGB24, false);
        texture.filterMode = FilterMode.Point;
        texture.wrapMode = TextureWrapMode.Repeat;

        for (int y = 0; y < textureSize; y++)
        {
            for (int x = 0; x < textureSize; x++)
            {
                // 生成随机方向
                Vector3 randomDir = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), 0).normalized;

                // 映射到[0,1]范围
                Color color = new Color(
                    randomDir.x * 0.5f + 0.5f,
                    randomDir.y * 0.5f + 0.5f,
                    randomDir.z * 0.5f + 0.5f
                );

                texture.SetPixel(x, y, color);
            }
        }

        texture.Apply();

#if UNITY_EDITOR
        // 保存纹理为资源
        string path = $"Assets/Textures/{textureName}.asset";
        UnityEditor.AssetDatabase.CreateAsset(texture, path);
        UnityEditor.AssetDatabase.SaveAssets();
        UnityEditor.AssetDatabase.Refresh();
        Debug.Log($"Noise texture saved to {path}");
#endif
    }
}
