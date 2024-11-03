using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class CamEffect : MonoBehaviour
{
    public Material material;
    public RenderTexture sourceRenderTexture; // Camera's render texture
    public RenderTexture resultRenderTexture; // Render texture to store the result

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        // This will handle the camera's final output
        if (material == null) {
            Debug.Log("Material is null. Blitting without effect.");
            Graphics.Blit(src, dest); // No effect
            return;
        }

        Debug.Log("Material is assigned. Applying effect.");
        
        // Apply shader to the source Render Texture
        Graphics.Blit(sourceRenderTexture, resultRenderTexture, material);

        // Optionally, Blit the result to the screen
        Graphics.Blit(resultRenderTexture, dest);
    }
}
