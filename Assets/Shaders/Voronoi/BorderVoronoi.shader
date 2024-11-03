Shader "Custom/VoronoiBorder" {
    Properties {
        _CellSize ("Cell Size", Range(0, 2)) = 2
        _BorderColor ("Border Color", Color) = (0,0,0,1)
        _BaseColor ("Base Color", Color) = (1, 1, 1, 0.5) // Semi-transparent for glass effect
        _ColorVar ("Brightness Variation", Range(0, 5)) = 0.1 
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
        float3 _BorderColor;
        float4 _BaseColor;
        float _ColorVar;
        float _Metallic;
        float _Smoothness;

        struct Input {
            float3 worldPos;
            float3 viewDir; // To handle double-sided normals
            INTERNAL_DATA // Required for WorldNormalVector and WorldReflectionVector usage
        };

        float3 voronoiNoise(float3 value){
            float3 baseCell = floor(value);

            // First pass to find the closest cell
            float minDistToCell = 10;
            float3 toClosestCell;
            float3 closestCell;
            [unroll]
            for(int x1=-1; x1<=1; x1++){
                [unroll]
                for(int y1=-1; y1<=1; y1++){
                    [unroll]
                    for(int z1=-1; z1<=1; z1++){
                        float3 cell = baseCell + float3(x1, y1, z1);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;
                        float distToCell = length(toCell);
                        if(distToCell < minDistToCell){
                            minDistToCell = distToCell;
                            closestCell = cell;
                            toClosestCell = toCell;
                        }
                    }
                }
            }

            // Second pass to find the distance to the closest edge
            float minEdgeDistance = 10;
            [unroll]
            for(int x2=-1; x2<=1; x2++){
                [unroll]
                for(int y2=-1; y2<=1; y2++){
                    [unroll]
                    for(int z2=-1; z2<=1; z2++){
                        float3 cell = baseCell + float3(x2, y2, z2);
                        float3 cellPosition = cell + rand3dTo3d(cell);
                        float3 toCell = cellPosition - value;

                        float3 diffToClosestCell = abs(closestCell - cell);
                        bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
                        if(!isClosestCell){
                            float3 toCenter = (toClosestCell + toCell) * 0.5;
                            float3 cellDifference = normalize(toCell - toClosestCell);
                            float edgeDistance = dot(toCenter, cellDifference);
                            minEdgeDistance = min(minEdgeDistance, edgeDistance);
                        }
                    }
                }
            }

            float random = rand3dTo1d(closestCell);
            return float3(minDistToCell, random, minEdgeDistance);
        }

        void surf (Input i, inout SurfaceOutputStandard o) {
            float4 localPos = mul(unity_WorldToObject, float4(i.worldPos, 1.0));
            float3 value = localPos.xyz / _CellSize; // Use local position for voronoiNoise
            float3 noise = voronoiNoise(value);

            float3 cellColor = _BaseColor.rgb;
            float valueChange = fwidth(value.z) * 0.5;
            float isBorder = 1 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise.z);
            float3 color = lerp(cellColor, _BorderColor, isBorder);

            float brightnessVar = _ColorVar * rand1dTo1d(noise.y);
            float3 colorVariation = color * (1.0 + brightnessVar);

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
