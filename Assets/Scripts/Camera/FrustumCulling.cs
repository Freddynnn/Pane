using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class FrustumCulling : MonoBehaviour{
    public Material grassMaterial;
    public bool visualizeFrustum = true;
    public ParticleSystem particleSystem;
    
    private Camera activeCamera;
    private Plane[] frustumPlanes = new Plane[6];
    [SerializeField] private  float bottomPlaneOffset = -10f;
    [SerializeField] private float widenPlaneOffset = 0;
    private ParticleSystem.Particle[] particles;

    void Start() {
        UpdateActiveCamera();
        particles = new ParticleSystem.Particle[particleSystem.main.maxParticles]; // Initialize particle array
    }

    void Update(){
        UpdateActiveCamera();
        CalculateFrustumPlanes();
        SetFrustumPlanes();
        CullParticles();
    }

    void UpdateActiveCamera() {
        if (CinemachineCore.Instance.BrainCount > 0) {
            CinemachineBrain brain = CinemachineCore.Instance.GetActiveBrain(0);
            if (brain != null && brain.OutputCamera != null) {
                activeCamera = brain.OutputCamera;
            }
        }
    }

    void CalculateFrustumPlanes() {
        if (activeCamera != null) {
            frustumPlanes = GeometryUtility.CalculateFrustumPlanes(activeCamera);
            // ExtendBottomPlane();
        }
    }

    // void ExtendBottomPlane() {
    //     // Adjust the bottom plane to extend it downwards in the XZ-plane
    //     Vector3 normal = new Vector3(frustumPlanes[2].normal.x, 0, frustumPlanes[2].normal.z);
    //     frustumPlanes[2] = new Plane(normal, new Vector3(0, -1000, 0)); // Setting a large negative Y distance
    // }

    void SetFrustumPlanes() {
        for (int i = 0; i < 6; i++){
            if (i == 2) { // Bottom plane
                // Adjust the distance to extend the bottom plane downward
                float distance = frustumPlanes[i].distance + bottomPlaneOffset;
                grassMaterial.SetVector("_FrustumPlane" + i, new Vector4(frustumPlanes[i].normal.x, frustumPlanes[i].normal.y, frustumPlanes[i].normal.z, distance));
            } else {
                grassMaterial.SetVector("_FrustumPlane" + i, new Vector4(frustumPlanes[i].normal.x, frustumPlanes[i].normal.y, frustumPlanes[i].normal.z, frustumPlanes[i].distance));
            }
        }
    }

    void CullParticles() {
        int numParticlesAlive = particleSystem.GetParticles(particles); // Get all live particles

        for (int i = 0; i < numParticlesAlive; i++) {
            Vector3 particlePosition = particles[i].position;

            // Create a simple bounds object for the particle
            Bounds particleBounds = new Bounds(particlePosition, Vector3.one * particles[i].GetCurrentSize(particleSystem));
            
            // Modify the left (index 0) and right (index 1) frustum planes
            bool isInsideLeftPlane = frustumPlanes[0].GetDistanceToPoint(particlePosition + frustumPlanes[0].normal * widenPlaneOffset) > 0;
            bool isInsideRightPlane = frustumPlanes[1].GetDistanceToPoint(particlePosition - frustumPlanes[1].normal * (-widenPlaneOffset)) > 0;

            // If the particle is outside either the left or right widened plane, cull it
            if (!isInsideLeftPlane || !isInsideRightPlane) {
                particles[i].remainingLifetime = 0; // Kill the particle
            }
        }

        // Apply the culled particles back to the particle system
        particleSystem.SetParticles(particles, numParticlesAlive);
    }



    // void OnDrawGizmos() {
    //     if (visualizeFrustum && frustumPlanes != null) {
    //         Gizmos.color = Color.red;
    //         for (int i = 0; i < 6; i++) {
    //             Gizmos.DrawLine(activeCamera.transform.position, activeCamera.transform.position + frustumPlanes[i].normal * 5);
    //         }
    //     }
    // }
}
