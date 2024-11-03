using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleSectionFrustumCulling : MonoBehaviour
{
    private ParticleSystem particleSystem;
    private Camera mainCamera;
    private Plane[] frustumPlanes;
    private ParticleSystem.Particle[] particles;

    void Start()
    {
        particleSystem = GetComponent<ParticleSystem>();
        mainCamera = Camera.main;
        particles = new ParticleSystem.Particle[particleSystem.main.maxParticles];
    }

    void Update()
    {
        // Calculate the camera frustum planes
        frustumPlanes = GeometryUtility.CalculateFrustumPlanes(mainCamera);

        // Get all particles
        int numParticlesAlive = particleSystem.GetParticles(particles);

        for (int i = 0; i < numParticlesAlive; i++)
        {
            Vector3 particlePosition = particles[i].position;
            float particleSize = particles[i].GetCurrentSize(particleSystem); // Get particle size

            // Use the actual particle size to create a more accurate bounding box
            Bounds particleBounds = new Bounds(particlePosition, Vector3.one * particleSize);

            // Check if the particle's bounds are inside the camera's frustum
            bool isVisible = GeometryUtility.TestPlanesAABB(frustumPlanes, particleBounds);

            if (!isVisible)
            {
                // Cull the particle if it's outside the frustum
                particles[i].remainingLifetime = 0;
            }
        }

        // Apply the changes to the particle system
        particleSystem.SetParticles(particles, numParticlesAlive);
    }
}

