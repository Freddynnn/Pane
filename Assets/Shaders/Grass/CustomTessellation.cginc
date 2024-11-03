// Tessellation programs based on this article by Catlike Coding:
// https://catlikecoding.com/unity/tutorials/advanced-rendering/tessellation/
float _TessellationUniform;

float4 _FrustumPlane0;
float4 _FrustumPlane1;
float4 _FrustumPlane2;
float4 _FrustumPlane3;
float4 _FrustumPlane4;
float4 _FrustumPlane5;

float4 _PlayerPosition;

float _YThreshold;


struct vertexInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv      : TEXCOORD0;
	float distance : TEXCOORD1;
};

struct vertexOutput{
	float4 vertex : SV_POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 uv      : TEXCOORD0;
	float distance : TEXCOORD1; // Added for distance-based attenuation
};

struct TessellationFactors {
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};

vertexInput vert(vertexInput v){
	return v;
}

vertexOutput tessVert(vertexInput v){
	vertexOutput o;
	// Note that the vertex is NOT transformed to clip space here; this is done in the grass geometry shader.
	o.vertex = v.vertex;
	o.normal = v.normal;
	o.tangent = v.tangent;
	o.uv = v.uv;
    // Calculate distance in xz plane from camera
    float2 cameraPosXZ = _PlayerPosition.xz;
    float2 vertexPos = v.vertex.xz;
    o.distance = length(cameraPosXZ - vertexPos);

	return o;
}



bool IsInFrustum(float3 pos){
	if (dot(_FrustumPlane0.xyz, pos) + _FrustumPlane0.w < 0.0) return false;
	if (dot(_FrustumPlane1.xyz, pos) + _FrustumPlane1.w < 0.0) return false;
	if (dot(_FrustumPlane2.xyz, pos) + _FrustumPlane2.w < 0.0) return false;
	if (dot(_FrustumPlane3.xyz, pos) + _FrustumPlane3.w < 0.0) return false;
	if (dot(_FrustumPlane4.xyz, pos) + _FrustumPlane4.w < 0.0) return false;
	if (dot(_FrustumPlane5.xyz, pos) + _FrustumPlane5.w < 0.0) return false;
	return true;
}

bool IsAboveYThreshold(float3 pos, float yThreshold) {
    return pos.y > yThreshold;
}


TessellationFactors patchConstantFunction (InputPatch<vertexInput, 3> patch){
    TessellationFactors f;

    // Frustum culling: check if any of the patch vertices are inside the frustum
    bool anyVertexInFrustum = false;
    for (int i = 0; i < 3; i++) {
        if (IsInFrustum(patch[i].vertex.xyz)) {
            anyVertexInFrustum = true;
            break;
        }
    }

    // Y-axis threshold culling: check if any of the patch vertices are above the Y threshold
    bool anyVertexAboveYThreshold = false;
    float yThreshold = _YThreshold; // Assuming _YThreshold is a uniform variable passed to the shader
    for (int i = 0; i < 3; i++) {
        if (IsAboveYThreshold(patch[i].vertex.xyz, yThreshold)) {
            anyVertexAboveYThreshold = true;
            break;
        }
    }

    // If none of the vertices are inside the frustum or above the Y threshold, set tessellation factors to zero
    if (!anyVertexInFrustum || !anyVertexAboveYThreshold) {
        f.edge[0] = 0.0;
        f.edge[1] = 0.0;
        f.edge[2] = 0.0;
        f.inside = 0.0;
    } else {
        f.edge[0] = _TessellationUniform;
        f.edge[1] = _TessellationUniform;
        f.edge[2] = _TessellationUniform;
        f.inside = _TessellationUniform;
    }
    
    return f;
}


[domain("tri")]
[outputcontrolpoints(3)]
[outputtopology("triangle_cw")]
[partitioning("integer")]
[patchconstantfunc("patchConstantFunction")]

vertexInput hull (InputPatch<vertexInput, 3> patch, uint id : SV_OutputControlPointID){
	vertexInput v = patch[id];
	v.distance = length(v.vertex - _PlayerPosition); // Pass distance through to tessellation evaluation
	return v;
}

[domain("tri")]
vertexOutput domain(TessellationFactors factors, OutputPatch<vertexInput, 3> patch, float3 barycentricCoordinates : SV_DomainLocation){
	vertexInput v;

	#define MY_DOMAIN_PROGRAM_INTERPOLATE(fieldName) v.fieldName = \
		patch[0].fieldName * barycentricCoordinates.x + \
		patch[1].fieldName * barycentricCoordinates.y + \
		patch[2].fieldName * barycentricCoordinates.z;

	MY_DOMAIN_PROGRAM_INTERPOLATE(vertex)
	MY_DOMAIN_PROGRAM_INTERPOLATE(normal)
	MY_DOMAIN_PROGRAM_INTERPOLATE(tangent)
	v.uv = patch[0].uv * barycentricCoordinates.x + patch[1].uv * barycentricCoordinates.y + patch[2].uv * barycentricCoordinates.z;
    v.distance = patch[0].distance * barycentricCoordinates.x + patch[1].distance * barycentricCoordinates.y + patch[2].distance * barycentricCoordinates.z;

	return tessVert(v);
}