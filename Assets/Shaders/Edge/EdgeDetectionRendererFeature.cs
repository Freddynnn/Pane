using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class EdgeDetectionRendererFeature : ScriptableRendererFeature{
    [System.Serializable]
    public class EdgeDetectionSettings{
        public Material edgeDetectionMaterial; // edge detection material assigned in inspector
        // [Range(0.1f, 5f)] public float edgeThickness = 1.0f; // slider that controls edge thickness
        public LayerMask excludeLayerMask; // New variable for layers to exclude
    }

    public EdgeDetectionSettings settings = new EdgeDetectionSettings();
    private EdgeDetectionPass edgeDetectionPass;

    // initializes render pass and sets up execution order (when created)
    public override void Create(){
        edgeDetectionPass = new EdgeDetectionPass(settings.edgeDetectionMaterial, settings.excludeLayerMask);
        
        // Specifies that the render pass should run after rendering transparent objects (configurable)
        edgeDetectionPass.renderPassEvent = RenderPassEvent.AfterRenderingTransparents; 
    }

    // add render pass to URP  renderer's pipeline if edge detection material exists
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData){
        if (settings.edgeDetectionMaterial != null){
            // Update the edge detection material's edge thickness based on user settings
            // settings.edgeDetectionMaterial.SetFloat("_EdgeThickness", settings.edgeThickness);

            // Enqueue the edge detection pass to be executed
            renderer.EnqueuePass(edgeDetectionPass);
        }
    }

    class EdgeDetectionPass : ScriptableRenderPass{
        private Material edgeDetectionMaterial;
        private RenderTargetIdentifier source;
        private RenderTargetHandle destination;
        private LayerMask excludeLayerMask;

        // The constructor initializes the edge detection material and the layer mask for excluded layers
        public EdgeDetectionPass(Material material, LayerMask excludeLayerMask){
            edgeDetectionMaterial = material;
            this.excludeLayerMask = excludeLayerMask;

            // Initialize a render target handle to store the intermediate result
            destination.Init("_EdgeDetectionTexture");
        }

        // This function is executed during the render pass. It handles the edge detection and rendering.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData){
            // Create a command buffer for rendering operations
            CommandBuffer cmd = CommandBufferPool.Get("Edge Detection");

            // Get the current camera's color buffer (the target to apply the effect on)
            RenderTargetIdentifier cameraColorTarget = renderingData.cameraData.renderer.cameraColorTarget;

            // Set up a filtering setting that excludes objects from the specified layers
            FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all, ~excludeLayerMask); // Use bitwise NOT to exclude layers

            // Set up the drawing settings for rendering objects based on transparency and sorting criteria
            DrawingSettings drawingSettings = CreateDrawingSettings(new ShaderTagId("UniversalForward"), ref renderingData, SortingCriteria.CommonTransparent);

            // Draw renderers while excluding objects on the specified layers
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

            // Create a temporary render target to store the edge detection effect
            cmd.GetTemporaryRT(destination.id, Screen.width, Screen.height, 0, FilterMode.Bilinear);

            // Apply the edge detection material, blitting the camera color target to the temporary render target
            cmd.Blit(cameraColorTarget, destination.Identifier(), edgeDetectionMaterial);

            // Blit the result back from the temporary render target to the camera color target
            cmd.Blit(destination.Identifier(), cameraColorTarget);

            // Execute the command buffer to apply all the commands
            context.ExecuteCommandBuffer(cmd);

            // Release the command buffer and temporary render target to free up resources
            CommandBufferPool.Release(cmd);
        }
    }
}
