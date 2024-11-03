Shader "ColorBlitInvert"
{
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "RenderPipeline" = "UniversalPipeline"
            // "Queue"="Transparent"
        }
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "ColorBlitPass"

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            #pragma vertex Vert
            #pragma fragment frag

            TEXTURE2D_X(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            float _Intensity;

            half4 frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float4 color = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, input.texcoord);
                
                // Invert the color channels
                float4 invertedColor = float4(1.0 - color.rgb, color.a);

                // Optionally, adjust the intensity of the invert effect
                return lerp(color, invertedColor, _Intensity);
            }
            ENDHLSL
        }
    }
}
