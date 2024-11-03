using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PickUpController : MonoBehaviour
{
    public WeaponSystem weapon;
    public Rigidbody rb;
    public CapsuleCollider coll;
    public Transform weaponContainer;

    Player player;

    public float pickUpRange;
    public float dropUpForce, dropForwardForce;

    public bool equipped;
    public static bool slotFull;

    private void Start(){
        player = GameObject.FindObjectOfType<Player>();


        if(!equipped){
            weapon.enabled = false;
            rb.isKinematic = false;
            coll.isTrigger = false;
        }

        if(equipped){
            weapon.enabled = true;
            rb.isKinematic = true;
            coll.isTrigger = true;
            slotFull = true;
            player.equippedWeapon = weapon;
        }
    }


    private void Update(){
        Vector3 distanceToPlayer = player.transform.position - transform.position;

        if(!equipped && !slotFull && Input.GetKeyDown(KeyCode.E) && distanceToPlayer.magnitude <= pickUpRange){
            PickUp();
        }

        if(equipped && Input.GetKeyDown(KeyCode.Q)){
            Drop();
        }
    }

    private void PickUp(){
        //weapon.player = player;

        equipped = true;
        slotFull = true;

        transform.SetParent(weaponContainer);
        transform.localPosition = Vector3.zero;
        transform.localRotation = Quaternion.Euler(Vector3.zero);
        transform.localScale = Vector3.one;

        rb.isKinematic = true;
        coll.isTrigger = true;

        weapon.enabled = true;

    }

    private void Drop(){
        equipped = false;
        slotFull = false;

        transform.SetParent(null);

        rb.isKinematic = false;
        coll.isTrigger = false;

        rb.velocity = player.transform.GetComponent<Rigidbody>().velocity;
        rb.AddForce(player.transform.forward * dropForwardForce, ForceMode.Impulse);
        rb.AddForce(player.transform.up * dropUpForce, ForceMode.Impulse);

        // random rotation when tossed 
        float random  = Random.Range(-1f, 1f);
        rb.AddTorque(new Vector3(random, random, random)*10);

        weapon.enabled = false;
    }

}
