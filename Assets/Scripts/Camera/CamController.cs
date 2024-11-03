using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject player;
    public Vector3 cameraOffset;
    public float smoothSpeed = 5f; 

    private void LateUpdate()
    {
        // Calculate the desired target position.
        Vector3 targetPosition = player.transform.position + cameraOffset;

        // The smoothness is controlled by the smoothSpeed variable.
        transform.position = Vector3.Lerp(transform.position, targetPosition, smoothSpeed * Time.deltaTime);
    }
}
