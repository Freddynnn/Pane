using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class TargetLock : MonoBehaviour
{
    public float rayHorizAngle, rayVertAngle,  maxDistance;
    public int rayCount, rayRows;

    private bool EnemyLocked = false;
    public Animator cinemachineAnimator; 
    public CinemachineVirtualCamera EnemyCam;
    public LayerMask enemyLayerMask;

    private Camera cam; 
    public GameObject camTarget; 
    private CamRotation camRotationScript; 

    // player reference
    public GameObject player;

    private Transform closestEnemy;

    void Start(){
        cam = Camera.main; 
        camRotationScript = camTarget.GetComponent<CamRotation>();
    }

    void Update(){
        if (Input.GetKeyDown(KeyCode.T)) {
            if (!EnemyLocked){ 
                LockOnTarget();
            } else {
                ResetTarget();
            }
        }

        if(EnemyLocked && closestEnemy != null){
            Vector3 directionToEnemy = closestEnemy.position - camTarget.transform.position;
            Quaternion lookRotation = Quaternion.LookRotation(directionToEnemy);
            camTarget.transform.rotation = Quaternion.Slerp(camTarget.transform.rotation, lookRotation, Time.deltaTime * 5f); // Smooth rotation
        }
    }

    void LockOnTarget(){
    closestEnemy = null;
    float smallestAngle = rayHorizAngle;

    Vector3 rayOrigin = player.transform.position + new Vector3(0, 1, 0) + cam.transform.forward * 0.5f;

    for (int row = 0; row < rayRows; row++)
    {
        float verticalAngle = (row / (float)(rayRows - 1)) * rayVertAngle - (rayVertAngle / 2f);
        Quaternion verticalRotation = Quaternion.AngleAxis(verticalAngle, cam.transform.right);

        for (int i = 0; i < rayCount; i++)
        {
            float horizontalAngle = (i / (float)(rayCount - 1)) * rayHorizAngle - (rayHorizAngle / 2f);
            Quaternion horizontalRotation = Quaternion.AngleAxis(horizontalAngle, cam.transform.up);

            Vector3 direction = verticalRotation * horizontalRotation * cam.transform.forward;

            Debug.DrawRay(rayOrigin, direction * maxDistance, Color.red, 1.0f);

            RaycastHit hit;
            if (Physics.Raycast(rayOrigin, direction, out hit, maxDistance, enemyLayerMask))
            {
                if (hit.collider.gameObject.CompareTag("Enemy"))
                {
                    Debug.Log("Enemy found: " + hit.transform.name);

                    Vector3 directionToEnemy = hit.transform.position - rayOrigin;
                    float angleToEnemy = Vector3.Angle(player.transform.forward, directionToEnemy);

                    // if (angleToEnemy < smallestAngle){
                        smallestAngle = angleToEnemy;
                        closestEnemy = hit.transform;
                    // }
                }
            }
        }
    }

    if (closestEnemy != null)
    {
        Debug.Log("Closest enemy locked on: " + closestEnemy.name);
        cinemachineAnimator.Play("TargetEnemy");
        EnemyCam.LookAt = closestEnemy;
        camRotationScript.enabled = false;
        EnemyLocked = true;
    }
}


    void ResetTarget(){
        cinemachineAnimator.Play("FollowPlayer");
        EnemyCam.LookAt = null;
        camRotationScript.enabled = true; 
        // EnemyCam.Follow=null;
        EnemyLocked = false;
    }
}
