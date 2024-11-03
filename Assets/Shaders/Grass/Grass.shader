Shader "Custom/GrassURP"
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

        _TessellationUniform("Tessellation Uniform", Range(1, 10)) = 1

		// [Header(GrassMap Parameters)]
		// _GrassMap("Grass Visibility Map", 2D) = "white" {}
		// _GrassThreshold("Grass Visibility Threshold", Range(-0.1, 1)) = 0.5
		// _GrassFalloff("Grass Visibility Fade-In Falloff", Range(0, 0.5)) = 0.05

        [Header(Wind Parameters)]
        _WindDistortionMap("Wind Distortion Map", 2D) = "white" {}
        _WindFrequency("Wind Frequency", Vector) = (0.05, 0.05, 0, 0)
        _WindStrength("Wind Strength", Float) = 1

        [Header(Distance Attenuation)]
        // _MaxDistance("Maximum Distance", Float) = 100.0
        _SpawnDistance("Guaranteed Spawn Distance", Float) = 20.0
        _CullDistance("Culling Distance", Float) = 30.0
        _PlayerPosition("Player Position", Vector) = (0, 0, 0, 0)
        _YThreshold("Y Threshold", Float) = 1.0
    }

    HLSLINCLUDE
	// #include "UnityCG.cginc"
	// #include "Autolight.cginc"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "CustomTessellation.cginc"

    #define UNITY_PI 3.14159265359
    #define UNITY_TWO_PI 6.28318530718
    #define BLADE_SEGMENTS 3

	// Returns a number in the 0...1 range
    float rand(float3 co){
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

	// sampler2D _GrassMap;
	// float4 _GrassMap_ST;
	// float  _GrassThreshold;
	// float  _GrassFalloff;

	// float _MaxDistance;
	float _SpawnDistance; 
	float _CullDistance; 

	float3x3 AngleAxis3x3(float angle, float3 axis){
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

    struct geometryOutput
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

	// Helper function to stop repeating in Geometry Shader
    geometryOutput VertOutput(float3 pos, float2 uv){
        geometryOutput o;
        // o.pos = TransformObjectToHClip(pos);  
		o.pos = mul(UNITY_MATRIX_MVP, float4(pos, 1.0));
        o.uv = uv;
        return o;
    }

    geometryOutput GenerateGrassVertex(float3 vertexPosition, float width, float height, float forward, float2 uv, float3x3 transformMatrix){
        float3 tangentPoint = float3(width, forward, height);
        float3 localPosition = vertexPosition + mul(transformMatrix, tangentPoint);
        return VertOutput(localPosition, uv);
    }

    // GEOMETRY SHADER
	[maxvertexcount(BLADE_SEGMENTS * 2 + 1)]  // says the shader emits at MOST (3)*2 + 1 vertices
	void geo(triangle vertexOutput input[3] : SV_POSITION, inout TriangleStream<geometryOutput>triStream){

		// float grassVisibility = tex2Dlod(_GrassMap, float4(input[0].uv, 0, 0)).r;

		// if (grassVisibility >= _GrassThreshold){

		float3 pos = input[0].vertex;
		// float distance = length(pos - _PlayerPosition);

		// Check attenuation based on vertex distance from player
		float distance = input[0].distance;
		float attenuation = 1.0;

		if (distance < _SpawnDistance) {
            attenuation = 1.0; // Full probability of spawning within guaranteed distance
        } else if (distance < _CullDistance) {
            float t = (distance - _SpawnDistance) / (_CullDistance - _SpawnDistance);
            attenuation = smoothstep(1.0, 0.0, t); // Gradual transition from full to zero attenuation
        } else {
            attenuation = 0.0; // No grass beyond the culling distance
        }
        

		// Apply a probability check based on attenuation
		if (rand(pos) < attenuation){

			float3 vNormal = input[0].normal;
			float4 vTangent = input[0].tangent;
			float3 vBinormal = cross(vNormal, vTangent) * vTangent.w;

			float3x3 tangentToLocal = float3x3(
				vTangent.x, vBinormal.x, vNormal.x,
				vTangent.y, vBinormal.y, vNormal.y,
				vTangent.z, vBinormal.z, vNormal.z
			);

			// use pos of vertex to get randomized rotation matrix 
			float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));

			// again use pos for a blade bending matrix (Pi/2 gives us 0-90 degrees for the bend)
			float3x3 bendRotationMatrix = AngleAxis3x3(rand(pos.zzx) * _BendRotationRandom * (UNITY_PI/2), float3(-1, 0, 0));

			// using wind texture to simulate wind movement
			float2 uv = pos.xz * _WindDistortionMap_ST.xy + _WindDistortionMap_ST.zw + _WindFrequency * _Time.y;
			
			// rescale from 0:1 range to a -1:1 range, & construct a directional vector
			float2 windSample = (tex2Dlod(_WindDistortionMap, float4(uv, 0, 0)).xy * 2 - 1) * _WindStrength;
			float3 wind = normalize(float3(windSample.x, windSample.y, 0));
			float3x3 windRotation = AngleAxis3x3(UNITY_PI * windSample, wind);


			// combine tangent, random direction rotation and wind rotation matrices
			float3x3 transformationMatrix = mul(mul(mul(tangentToLocal, windRotation), facingRotationMatrix), bendRotationMatrix);
			
			// 2nd transformation matrix to ensure blade base stays attached to surface
			float3x3 transformationMatrixFacing = mul(tangentToLocal, facingRotationMatrix);
			

			// adjusting height and width of the grass blades
			float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
			float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
			float forward = rand(pos.yyz) * _BladeForward;

			// separating each blade into segments to allow for curving
			for (int i = 0; i < BLADE_SEGMENTS; i++){
				float t = i / (float)BLADE_SEGMENTS;
				float segmentHeight = height * t;
				float segmentWidth = width * (1 - t);
				float segmentForward = pow(t, _BladeCurve) * forward;

				float3x3 transformMatrix = i == 0 ? transformationMatrixFacing : transformationMatrix;
				
				// construct each vertex building up the blade
				triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
				triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
			}

			// insert vertex at the tip of the blade
			triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), transformationMatrix));

		}
	}
	

    // void geo(triangle geometryOutput input[3], inout TriangleStream<geometryOutput> triStream){
    //     float3 pos = input[0].pos.xyz;
    //     float3x3 facingRotationMatrix = AngleAxis3x3(rand(pos) * UNITY_TWO_PI, float3(0, 0, 1));

    //     float height = (rand(pos.zyx) * 2 - 1) * _BladeHeightRandom + _BladeHeight;
    //     float width = (rand(pos.xzy) * 2 - 1) * _BladeWidthRandom + _BladeWidth;
    //     float forward = rand(pos.yyz) * _BladeForward;

    //     for (int i = 0; i < BLADE_SEGMENTS; i++)
    //     {
    //         float t = i / (float)BLADE_SEGMENTS;
    //         float segmentHeight = height * t;
    //         float segmentWidth = width * (1 - t);
    //         float segmentForward = pow(t, _BladeCurve) * forward;

    //         float3x3 transformMatrix = i == 0 ? facingRotationMatrix : facingRotationMatrix;
    //         triStream.Append(GenerateGrassVertex(pos, segmentWidth, segmentHeight, segmentForward, float2(0, t), transformMatrix));
    //         triStream.Append(GenerateGrassVertex(pos, -segmentWidth, segmentHeight, segmentForward, float2(1, t), transformMatrix));
    //     }

    //     triStream.Append(GenerateGrassVertex(pos, 0, height, forward, float2(0.5, 1), facingRotationMatrix));
    // }

    ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }

        Pass
        {
            Name "ForwardPass"
			Cull Off // Disable backface culling
            ZWrite On // Adjust as needed
            ZTest LEqual // Adjust as needed
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geo
            #pragma target 4.6
            #pragma hull hull
            #pragma domain domain
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _TopColor;
            float4 _BottomColor;
            float _TranslucentGain;

            float4 frag(geometryOutput i) : SV_Target
            {
                return lerp(_BottomColor, _TopColor, i.uv.y);
            }
            ENDHLSL
        }
    }
}
