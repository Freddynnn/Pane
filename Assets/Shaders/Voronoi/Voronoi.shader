Shader "Custom/Voronoi3D" {
    Properties {
        _CellSize ("Cell Size", Range(0, 2)) = 2
        _BaseColor ("Base Color", Color) = (1, 1, 1, 0.5) // Semi-transparent for glass effect
        _ColorVar ("Brightness Variation", Range(0, 2)) = 0.1 
        _Metallic ("Metallic", Range(0, 1)) = 0.9 // High metallic value for reflective effect
        _Smoothness ("Smoothness", Range(0, 1)) = 0.8 // High smoothness for shiny surface
    }
    SubShader {
        Tags{ "RenderType"="Transparent" "Queue"="Transparent" }

        // Disable back-face culling
        Cull Off

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows alpha:fade
        #pragma target 3.0

        #include "Random.cginc"

        float _CellSize;
        float4 _BaseColor;
        float _ColorVar;
        float _Metallic;
        float _Smoothness;

        struct Input {
            float3 worldPos;
            float3 viewDir; // To handle double-sided normals
            INTERNAL_DATA // Required for WorldNormalVector and WorldReflectionVector usage
        };

        float3 voronoiNoise(float3 value) {
            float3 baseCell = floor(value);

            // First pass to find the closest cell
            float minDistToCell = 10;
            float3 toClosestCell;
            float3 closestCell;
            [unroll]
            for (int x1 = -1; x1 <= 1; x1++) {
                [unroll]
                for (int y1 = -1; y1 <= 1; y1++) {
                    [unroll]
                    for (int z1 = -1; z1 <= 1; z1++) {
                        float3 cell = baseCell + float3(x1, y1, z1);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;
                        float distToCell = length(toCell);
                        if (distToCell < minDistToCell) {
                            minDistToCell = distToCell;
                            closestCell = cell;
                            toClosestCell = toCell;
                        }
                    }
                }
            }

            float random = rand3dTo1d(closestCell);
            return float3(minDistToCell, random, 0); // Simplified to remove border logic
        }

        void surf (Input i, inout SurfaceOutputStandard o) {
            // Convert world position to local position
            float4 localPos = mul(unity_WorldToObject, float4(i.worldPos, 1.0));
            float3 value = i.worldPos.xyz / _CellSize;

            float3 noise = voronoiNoise(value);

            float brightnessVar = _ColorVar * rand1dTo1d(noise.y);
            float3 colorVariation = _BaseColor.rgb * (1.0 + brightnessVar);

            o.Albedo = colorVariation;
            o.Alpha = _BaseColor.a;

            // Set metallic and smoothness for reflective glass effect
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            // Adjust normals for double-sided rendering
            float3 worldNormal = WorldNormalVector(i, o.Normal);
            if (dot(worldNormal, i.viewDir) < 0) {
                o.Normal = -o.Normal;
            }
        }
        ENDCG
    }
    FallBack "Standard"
}
