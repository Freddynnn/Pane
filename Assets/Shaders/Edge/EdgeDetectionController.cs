using UnityEngine;

// [ExecuteInEditMode]
public class EdgeDetectionController : MonoBehaviour
{
    public Material edgeDetectionMaterial;

    void Update()
    {
        if (edgeDetectionMaterial != null)
        {
            edgeDetectionMaterial.SetVector("_MainCameraPosition", transform.position);
        }
    }
}