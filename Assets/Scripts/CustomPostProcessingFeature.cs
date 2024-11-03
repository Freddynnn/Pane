using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomPostProcessingFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        private Material material;
        private RenderTargetIdentifier source;
        private RenderTargetHandle temporaryRT;

        public CustomRenderPass(Material material)
        {
            this.material = material;
            temporaryRT.Init("_TemporaryRT");
        }

        public void Setup(RenderTargetIdentifier source)
        {
            this.source = source;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get("CustomPostProcessing");

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            cmd.GetTemporaryRT(temporaryRT.id, opaqueDesc);

            // Blit the original image through the shader
            Blit(cmd, source, temporaryRT.Identifier(), material);
            Blit(cmd, temporaryRT.Identifier(), source);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public override void FrameCleanup(CommandBuffer cmd)
        {
            cmd.ReleaseTemporaryRT(temporaryRT.id);
        }
    }

    public Material material;
    CustomRenderPass pass;

    public override void Create()
    {
        pass = new CustomRenderPass(material);
        pass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var cameraColorTarget = renderer.cameraColorTarget;
        pass.Setup(cameraColorTarget);
        renderer.EnqueuePass(pass);
    }
}
