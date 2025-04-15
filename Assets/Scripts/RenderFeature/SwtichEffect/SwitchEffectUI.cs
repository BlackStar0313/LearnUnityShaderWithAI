using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class SwitchEffectUI : MonoBehaviour
{
    [SerializeField]
    private SwitchEffectManager m_EffectManager;

    [SerializeField]
    private TextMeshProUGUI currentEffectText;

    [SerializeField]
    private List<Button> m_EffectButtons = new List<Button>();

    [SerializeField]
    private List<string> m_EffectNames = new List<string>();

    private void Start()
    {
        for (int i = 0; i < m_EffectButtons.Count; i++)
        {
            int index = i;
            m_EffectButtons[i].onClick.AddListener(() => ApplyEffect(index));
        }

        if (m_EffectButtons.Count > 0)
            ApplyEffect(0);
    }

    private void ApplyEffect(int index)
    {
        m_EffectManager.ApplyEffectProfile(index);

        if (currentEffectText != null && index < m_EffectNames.Count)
        {
            currentEffectText.text = $"Cur Effect: {m_EffectNames[index]}";
        }
    }
}
