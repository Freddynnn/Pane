using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerDash : MonoBehaviour
{
    public int dashDamage, stamCost;
    public float dashSpeed, dashForce, dashTime;
    
    public float maxChargeDuration;
    public float minDashDistance;
    public float maxDashDistance;

    private bool isDashing = false;
    private bool isChargingDash = false;
    private float dashChargeTime = 0f;
    private Vector3 dashEndPosition;
    
    [SerializeField] private Player p;
    
    public int rayCount = 5;
    private Animator ani;

    private void Awake()
    {
        ani = GetComponent<Animator>();
    }

    private void Update(){
        if(p.currHp > 0){
            if (Input.GetKey(KeyCode.Space) && !isDashing){
                isChargingDash = true;
                dashChargeTime += Time.deltaTime;
            }

            if (Input.GetKeyUp(KeyCode.Space) && isChargingDash){
                Dash();
            }
        }
    }

    private void Dash(){
        if (!isDashing && p.readyToAttack && !p.forcedRecharging && p.currStam > 0) {
            p.readyToAttack = false;

            p.useStamina(stamCost);

            // Set the animator trigger to start the dash animation.
            ani.SetTrigger("Dash");

            // Calculate the dash distance based on charge time
            Vector3 dashDirection = transform.forward.normalized;
            float dashDistance = Mathf.Lerp(minDashDistance, maxDashDistance, dashChargeTime / maxChargeDuration);
            Vector3 dashEndPosition = transform.position + dashDirection * dashDistance;

            checkCollisions(dashDirection, dashDistance);

            //// Preserve the original y position, but clamp the x and z position
            dashEndPosition = new Vector3(
                Mathf.Clamp(dashEndPosition.x, p.min_x, p.max_x),
                dashEndPosition.y,
                Mathf.Clamp(dashEndPosition.z, p.min_z, p.max_z)
            );

            Invoke("resetAttack", dashTime);

            // Start the dash coroutine.
            StartCoroutine(PerformDash(dashEndPosition));
        }
    }

    

    private IEnumerator PerformDash(Vector3 dashEndPosition){
        isDashing = true;
        
        float startTime = Time.time;
        float journeyLength = Vector3.Distance(transform.position, dashEndPosition);

        while (Time.time < startTime + dashTime)
        {
            float distanceCovered = (Time.time - startTime) * dashSpeed;
            float fractionOfJourney = distanceCovered / journeyLength;

            transform.position = Vector3.Lerp(transform.position, dashEndPosition, fractionOfJourney);

            yield return null;
        }

        isDashing = false;
        isChargingDash = false;
        dashChargeTime = 0f; // Reset the charge time after dashing.
    }

    // reset attack availability 
    private void resetAttack(){
        p.readyToAttack = true;
    }



    // trigger collision with enemy for when we dash
    private void checkCollisions(Vector3 dashDir, float dashDist)
    {
        // Create an array of ray directions
        Vector3[] rayOrigins  = new Vector3[rayCount];

        // direction to spread the rays along perpendicular line
        Vector3 perpDir = new Vector3(dashDir.z, 0, -dashDir.x).normalized;
        float offsetDist = 1.5f;

        // Fill the ray origins with positions next to the player
        for (int i = 0; i < rayCount; i++){
            rayOrigins[i] = transform.position + perpDir * offsetDist  * (i - rayCount / 2);
        }

        
        // Check for potential collisions for each ray direction
        foreach (Vector3 origin in rayOrigins){
            RaycastHit hit;
            if (Physics.Raycast(origin, dashDir, out hit, dashDist)){
                if (hit.collider.CompareTag("Enemy")){
                    Debug.Log("Dash hit enemy");
                    // // Handle collision with an enemy (e.g., apply damage).
                    // EnemyBase enemy = hit.collider.GetComponent<EnemyBase>();
                    // if (enemy != null){
                    //     enemy.GetKnock(dashDamage, dashDir, dashForce);
                    // }
                    
                }
                else{
                    // Handle collisions with non-enemy objects (e.g., obstacles)
                    // maybe we  dashEndPosition ?
                }
            }
        }
    }

}
