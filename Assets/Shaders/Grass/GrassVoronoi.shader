Shader "Custom/GrassVoronoi"
{
    Properties
    {
        [Header(Shading)]
        _TopColor("Top Color", Color) = (1,1,1,1)
        _BottomColor("Bottom Color", Color) = (1,1,1,1)
        _TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
        _BendRotationRandom("Bend Rotation Random", Range(0, 1)) = 0.2

        [Header(Blade Dimensions)]
        _BladeWidth("Blade Width", Float) = 0.05
        _BladeWidthRandom("Blade Width Random", Float) = 0.02
        _BladeHeight("Blade Height", Float) = 0.5
        _BladeHeightRandom("Blade Height Random", Float) = 0.3
        _BladeForward("Blade Forward Amount", Float) = 0.38
        _BladeCurve("Blade Curvature Amount", Range(1, 4)) = 2

        _TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1

        [Header(GrassMap Parameters)]
        _GrassMap("Grass Visibility Map", 2D) = "white" {}
        _GrassThreshold("Grass Visibility Threshold", Range(-0.1, 1)) = 0.5
        _GrassFalloff("Grass Visibility Fade-In Falloff", Range(0, 0.5)) = 0.05

        [Header(Wind Parameters)]
        _WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
        _WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
        _WindStrength("Wind Strength", Float) = 1

        [Header(Voronoi Parameters)]
        _CellSize("Cell Size", Range(0, 2)) = 2
        _ColorVar("Brightness Variation", Range(0, 5)) = 0.1

        [Header(Glass Effects)]
        _MainTex("Texture", 2D) = "white" {}
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeThickness("Silhouette Dropoff Rate", float) = 1.0
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Autolight.cginc"
    #include "CustomTessellation.cginc"
    #include "Random.cginc"

    #define BLADE_SEGMENTS 3

    // Simple noise function
    float rand(float3 co)
    {
        return frac(sin(dot(co.xyz, float3(12.9898, 78.233, 53.539))) * 43758.5453);
    }

    float _BendRotationRandom;
    float _BladeHeight;
    float _BladeHeightRandom;
    float _BladeWidth;
    float _BladeWidthRandom;
    float _BladeForward;
    float _BladeCurve;

    sampler2D _WindDistortionMap;
    float4 _WindDistortionMap_ST;
    float2 _WindFrequency;
    float _WindStrength;

    sampler2D _GrassMap;
    float4 _GrassMap_ST;
    float  _GrassThreshold;
    float  _GrassFalloff;

    float _CellSize;
    float _ColorVar;

    struct geometryOutput {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 localPos : TEXCOORD1; // Pass local position to fragment shader
    };

    float3x3 AngleAxis3x3(float angle, float3 axis)
    {
        float c, s;
        sincos(angle, s, c);

        float t = 1 - c;
        float x = axis.x;
        float y = axis.y;
        float z = axis.z;

        return float3x3(
            t * x * x + c, t * x * y - s * z, t * x * z + s * y,
            t * x * y + s * z, t * y * y + c, t * y * z - s * x,
            t * x * z - s * y, t * y * z + s * x, t * z * z + c
        );
    }

    geometryOutput VertexOutput(float3 pos, float2 uv, float3 localPos)
    {
        geometryOutput o;
        o.pos = UnityObjectToClipPos(pos);
        o.uv = uv;
        o.localPos = localPos; // Pass local position
        return o;
    }

    geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix)
    {
        float3 tangentPoint = float3(width, forward, height);
        float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
        return VertexOutput(localPosition, uv, localPosition);
    }

    float3 voronoiNoise(float3 value)
    {
        float3 baseCell = floor(value);

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

    [maxvertexcount(BLADE_SEGMENTS * 2 + 1)] 
    void geo(triangle vertexOutput input[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
    {
        float3 pos = input[0].vertex;

        float3 vNormal = input[0].normal;
        float4 vTangent = input[0].tangent;
        float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

        float3x3 tangentToLocal = float3x3(
            vTangent.x, vBinormal.x, vNormal.x,
            vTangent.y, vBinormal.y, vNormal.y,
            vTangent.z, vBinormal.z, vNormal.z
        );

        float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));
        float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * UNITY_PI * 0.5, float3(-1, 0, 0));
        float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
        float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
        float3 wind = normalize(float3(windSample.x, windSample.y, 0));
        float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);
        float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
        float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);

        float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
        float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
        float forward = rand(pos.yyz) * _BladeForward;

        for (int i = 0; i < BLADE_SEGMENTS; i++)
        {
            float t = i / (float)BLADE_SEGMENTS;
            float segmentHeight = height * t;
            float segmentWidth = width * (1 - t);
            float segmentForward = pow(t, _BladeCurve) * forward;
            float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;

            triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
            triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
        }

        triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));
    }

    ENDCG

    SubShader
    {
        Cull Off

        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geo
            #pragma target 4.6
            #pragma hull hull
            #pragma domain domain

            #include "Lighting.cginc"

            float4 _TopColor;
            float4 _BottomColor;
            float _TranslucentGain;
            

            float4 frag(geometryOutput i, fixed facing : VFACE) : SV_Target
            {
                float3 localPos = i.localPos / _CellSize;
                float3 voronoi = voronoiNoise(localPos);
                float cellColor = lerp(0.7, 1.0, rand3dTo1d(voronoi.y) * _ColorVar);

                // Adjusting color based on Y position
                float yFactor = (i.localPos.y * 0.8); // Invert for darker cells at lower Y
                cellColor += yFactor;

                float4 color = lerp(_BottomColor, _TopColor, i.uv.y);
                color.rgb *= cellColor;

                return color;
            }

            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geo
            #pragma fragment frag
            #pragma hull hull
            #pragma domain domain
            #pragma target 4.6
            #pragma multi_compile_shadowcaster

            float4 frag(geometryOutput i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }
    }
}
