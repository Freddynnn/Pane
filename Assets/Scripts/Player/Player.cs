using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Player : MonoBehaviour
{
    public int currHp, maxHp;
    private bool invincible;

    // default values for just using hands 
    public int damage;
    public float attackDist;   
    
    // stamina variables
    public float currStam, maxStam, rechargeAmount;
    public bool isAttacking, readyToAttack, rechargingStamina, forcedRecharging;

    // Stamina Timer variables
    private float timeSinceAttack = 0f;
    private float timeToCharge = 1.0f; //start recharging stamina after 1 sec of not attacking
    private float rechargeRate = 0.5f;
    private float rechargeTimer = 0f;

    // min/max x and z positions to keep player in arena
    public int min_x = 103;
    public int max_x = 148;
    public int min_z = 80;
    public int max_z = 125;

    // game references
    public Slider slider_hp;
    private Animator ani;
    public WeaponSystem equippedWeapon;  
    //public Slider slider_stam;
    

    private void Awake()
    {
        ani = GetComponent<Animator>();
        currHp = maxHp;
        slider_hp.value = currHp;
        readyToAttack = true;
        
        // set stamina values
        currStam = maxStam;
        rechargeAmount = maxStam/8;
        //slider_stam.value = currStam;

        invincible = true;
    }

    private void Update()
    {
        // recharging stamina from idle time logic
        timeSinceAttack += Time.deltaTime;
        if(timeSinceAttack >= timeToCharge && currStam < maxStam && !rechargingStamina) {
            rechargingStamina = true;
        }

        if (rechargingStamina){
            rechargeTimer += Time.deltaTime;

            // Increment currStam  by "rechargeRate" seconds
            if (rechargeTimer >= rechargeRate){
                rechargeStamina();
            }
            
        }
    }
        
    // reduce stamina based on usage cost
    public void useStamina(int stamCost){
        rechargingStamina = false;
        timeSinceAttack = 0f;
        
        currStam -= stamCost;

        // if we run out of stamina, enforce full charge
        if (currStam <= 0){
            currStam = 0;
            forceRechargeStamina();
        }
    }

    // primary function for recharging stamina
    public void rechargeStamina(){
        currStam += rechargeAmount;
        rechargeTimer = 0f; 
    
        // Ensure currStam doesn't exceed maxStam
        if (currStam >= maxStam){
            currStam = maxStam;

            // ensure forced recharge is off once fully charged
            forcedRecharging = false;
        }
    }

    
    // when stamina is fully used, force a full recharge
    public void forceRechargeStamina(){
        forcedRecharging = true;
    }



    // logic for player taking damage (invincible until boss fight)
    public void GetHurt(int damage)
    {
        if (!invincible){
            currHp -= damage;
            slider_hp.value = currHp;
            if (currHp <= damage)
            {
                ani.SetBool("isDie", true);
            }
        }
    }
}
