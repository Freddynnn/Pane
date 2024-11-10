using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamRotation : MonoBehaviour
{
    public Vector2 rotation;
    public float minY, maxY, sensitivity;

    void Start(){;
        // Cursor.lockState = CursorLockMode.Locked;
        rotation.x = 0;
        rotation.y = 0;
    }

    void Update(){
        

        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        // Only update if there is actual mouse movement
        if (mouseX != 0 || mouseY != 0)
        {
            rotation.x += mouseX * sensitivity;
            rotation.y += mouseY * sensitivity;

            // Clamp the y rotation to prevent looking too far up or down
            rotation.y = Mathf.Clamp(rotation.y, minY, maxY);

            transform.localRotation = Quaternion.Euler(-rotation.y, rotation.x, 0);
        }
    }


    // need to rotate the camtarget to the enemy when we are locked 
}
