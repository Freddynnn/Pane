using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ColorBlitRendererFeature : ScriptableRendererFeature
{
    public Shader m_Shader;
    public float m_Intensity;
    Material m_Material;
    ColorBlitPass m_RenderPass = null;
 
    // initializes material from given shader & creates instance of ColorBlitPass (when the renderer feature is created)
    public override void Create(){
        m_Material = CoreUtils.CreateEngineMaterial(m_Shader);
        m_Material.renderQueue = 2450;  // ensure render order works for transparents
        m_RenderPass = new ColorBlitPass(m_Material);
    }

    // This method adds the render pass to the rendering pipeline. 
    // It checks if the camera is of type 'Game' and, if so, adds the custom render pass to the renderer's pass queue.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData){
        // Only add the render pass if the camera is of type 'Game' (i.e., not a preview or scene view camera)
        if (renderingData.cameraData.cameraType == CameraType.Game)
            renderer.EnqueuePass(m_RenderPass);
    }

    // This method configures and sets up the render pass before it is executed.
    // It ensures the render pass has access to the opaque color texture and sets the target texture and intensity value.
    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData){
        // Only configure the render pass for 'Game' type cameras
        if (renderingData.cameraData.cameraType == CameraType.Game){
            // Ensure the opaque texture is available to the render pass
            m_RenderPass.ConfigureInput(ScriptableRenderPassInput.Color);
            // Set the target texture and intensity for the render pass
            m_RenderPass.SetTarget(renderer.cameraColorTargetHandle, m_Intensity);
        }
    }

    // This method handles cleanup when the renderer feature is destroyed.
    // It properly disposes of the material to free resources.
    protected override void Dispose(bool disposing){
        // Safely destroy the material when disposing
        CoreUtils.Destroy(m_Material);
    }
}
