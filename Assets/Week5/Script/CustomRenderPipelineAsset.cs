using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(menuName = "Rendering/Custom Render Pipeline")]
public class CustomRenderPipelineAsset : RenderPipelineAsset {
    public enum GBufferDebugMode
    {
        None = 0,
        BaseColor = 1,
        PositionWS = 2,
        NormalWS = 3,
        LightOnly = 4,
    };

    public GBufferDebugMode gbufferDebugMode = GBufferDebugMode.None;

    protected override RenderPipeline CreatePipeline () {
		return new CustomRenderPipeline(this);
	}
}