Shader "Custom/EdgeDetectionShader"{
    Properties{
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector] _CameraColorTexture("Texture", 2D) = "white" {}
        _EdgeThreshold ("Edge Threshold", Range(0, 1)) = 0.1
        _MaxDistance ("Max Distance", Float) = 10.0
       
    }
    SubShader{
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        ENDHLSL

        Pass{
            ZTest Always
            ZWrite Off
            Cull Off


            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct Attributes{
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings{
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_TexelSize;
            float _EdgeThreshold;
            float _MaxDistance;
            float4 _MainCameraPosition;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
            CBUFFER_END

            Varyings vert(Attributes IN){
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target{
                float2 uv = IN.uv;
                float depth = SampleSceneDepth(uv);
                float3 worldPos = ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);
                float3 cameraPos = _MainCameraPosition.xyz;
                float distanceToCamera = distance(worldPos, cameraPos);

                // Sample texture colors
                float3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv).rgb;
                float3 left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_MainTex_TexelSize.x, 0)).rgb;
                float3 right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(_MainTex_TexelSize.x, 0)).rgb;
                float3 up = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, _MainTex_TexelSize.y)).rgb;
                float3 down = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, -_MainTex_TexelSize.y)).rgb;

                float3 gradX = left - right;
                float3 gradY = up - down;
                float edgeStrength = length(gradX) + length(gradY);

                if (edgeStrength > _EdgeThreshold){
                    // Calculate edge color based on distance
                    float t = saturate(distanceToCamera / _MaxDistance);
                    float3 edgeColor = lerp(float3(1, 0, 0), float3(0, 0, 1), t); // Red to Blue
                    // return float4(edgeColor, 1);
                    return float4(0,0,0,0);
                }
                else{
                    return float4(1, 1, 1, 1); 
                    // return float4(color, 1);
                }
            }
            ENDHLSL
        }
    }
}