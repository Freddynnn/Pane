using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowPlayer : MonoBehaviour{
     public GameObject player;
    public float speed, stopDistance;
    
    void Update(){
        if (player != null){
            // Calculate the distance between the enemy and the player
            float distance = Vector3.Distance(transform.position, player.transform.position);

            // Only move towards the player if the distance is greater than the stop distance
            if (distance > stopDistance){
                // Calculate the direction from the enemy to the player
                Vector3 direction = (player.transform.position - transform.position).normalized;

                // Move the enemy towards the player
                transform.position = Vector3.MoveTowards(transform.position, player.transform.position, speed * Time.deltaTime);
            }
        }
    }
}
