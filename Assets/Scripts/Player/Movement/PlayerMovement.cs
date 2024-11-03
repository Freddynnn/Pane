using UnityEngine;
using System.Collections;

public class PlayerMovement : MonoBehaviour
{
    public float moveSpeed, rotationSpeed;
    private Animator ani;
    private Rigidbody body;
    private bool canMove = true, targetLocked = false;
    private float standTime = 3.5f;

    public Transform CamTarget;
    public Material grassMaterial; 
    AudioSource walkSound, grassWalkSound;

    private void Awake()
    {
        ani = GetComponent<Animator>();
        ani.applyRootMotion = false;
        
        body = GetComponent<Rigidbody>();
        
        AudioSource[] audioSources = GetComponents<AudioSource>();
        if (audioSources.Length > 0){
            walkSound = audioSources[0]; 
        }
        if (audioSources.Length > 1){
            grassWalkSound = audioSources[1]; 
        }
    }

    private void Update(){
        grassMaterial.SetVector("_PlayerPosition", transform.position);


        bool isSitting = ani.GetBool("isSitting");
        bool isMoving= ani.GetBool("isMoving");


        // if(GameMgr.Ins.Player.currHp > 0){
        if(canMove){
            Move();
        }

        if(!isMoving){
            if (Input.GetKeyDown(KeyCode.L)){
            // ani.SetBool("isMoving", false);

            if(isSitting){
                StartCoroutine(WaitToStand());
                ani.SetBool("isSitting", false);    
            } else if(!isSitting){
                canMove = false;
                ani.SetBool("isSitting", true);    
            }
            // ani.SetBool("isSitting", !isSitting);
        }
        }
    }

     IEnumerator WaitToStand(){
        yield return new WaitForSeconds(standTime);
        canMove = true;
    }

    
    private void Move(){
        float horizontalInput = Input.GetAxis("Horizontal");
        float verticalInput = Input.GetAxis("Vertical");

        // Vector3 movementDirection = new Vector3(horizontalInput * moveSpeed, 0, verticalInput * moveSpeed);

        // Get the forward and right vectors of the CamTarget in world space
        Vector3 camForward = CamTarget.forward;
        Vector3 camRight = CamTarget.right;

        // Project the movement direction onto the CamTarget's forward and right vectors
        Vector3 movementDirection = (camForward * verticalInput) + (camRight * horizontalInput);
        movementDirection.y = 0f; // no vertical movement

        // Normalize the movement direction to ensure consistent speed regardless of diagonal movement
        movementDirection.Normalize();
        body.velocity = movementDirection * moveSpeed;
        
        
        // if not locked on target
         if (!targetLocked){
            if (movementDirection != Vector3.zero){
                Quaternion targetRotation = Quaternion.LookRotation(movementDirection);
                transform.rotation = Quaternion.RotateTowards(transform.rotation, targetRotation, rotationSpeed * Time.deltaTime);
            }
        }

        // Activate the movement sound
        if (movementDirection == Vector3.zero){
            ani.SetBool("isMoving", false);
            if (walkSound.isPlaying){
                walkSound.Stop();
                grassWalkSound.Stop();
            }
        } else {
            ani.SetBool("isMoving", true);
            if (!walkSound.isPlaying){
                walkSound.Play(0);
                grassWalkSound.Play(0);
            }
        }

        // if (horizontalInput!=0){
        //     Debug.Log("Horiz Input: " + horizontalInput);
        //     Debug.Log("ismoving" + (movementDirection != Vector3.zero));
        // }
        // if (verticalInput!=0){
        //     Debug.Log("Vertical input: " + verticalInput);
        //     Debug.Log("ismoving" + (movementDirection != Vector3.zero));
        // }


        // Calculate the angle between the character's forward vector and the movement vector
        float angle = Vector3.SignedAngle(transform.forward, movementDirection, Vector3.up);

        // Debug.Log("Angle: " + angle);

        // Set animator parameters based on the angle
        if (angle >= -45f && angle < 45f){
            // forward
            ani.SetFloat("h", 0);
            ani.SetFloat("v", 1);
        } else if (angle >= 45f && angle < 135f){
            // right.
            ani.SetFloat("h", 1);
            ani.SetFloat("v", 0);
        } else if (angle >= -135f && angle < -45f){
            // left.
            ani.SetFloat("h", -1);
            ani.SetFloat("v", 0);
        } else {
            // backward.
            ani.SetFloat("h", 0);
            ani.SetFloat("v", -1);
        } 
    }
}
