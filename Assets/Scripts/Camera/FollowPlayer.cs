using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowPlayer : MonoBehaviour
{
    public GameObject player;
    private Vector3 targetOffset;

    void Start(){
        targetOffset = transform.position - player.transform.position;
    }

    void Update(){
        // Keep the particle system emitter following the player
        transform.position = player.transform.position + targetOffset;
    }
}
