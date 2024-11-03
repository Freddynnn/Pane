using UnityEngine;

public class PlayerCombat : MonoBehaviour{
    public int damage;
    public float range, attackTime;

    public int stamCost;  
    public int kickForce;  

    // game references
    [SerializeField] private Player p;
    private Animator ani;

    private void Awake(){
        ani = GetComponent<Animator>();
        //p = GetComponent<Player>();
    }

    private void Update(){
        if(p.currHp > 0){
            Attack();
        }
    }

    private void Attack(){
        if (Input.GetMouseButtonDown(0)){
            if (p.readyToAttack && !p.isAttacking && !p.forcedRecharging && p.currStam > 0){
                p.readyToAttack = false;
                // usual attack logic
                ani.SetTrigger("Attack");

                p.useStamina(stamCost + (p.equippedWeapon != null ? p.equippedWeapon.stamCost : 0));
                CheckAttackCollisions();

                // attack rate is based on weapon
                float attackTimeWithWeapon = attackTime + (p.equippedWeapon != null ? p.equippedWeapon.attackTime : 0);
                Debug.Log("Attack Time With Weapon: " + attackTimeWithWeapon);

                Invoke("resetAttack", attackTimeWithWeapon);
            }   
        }
    }


    // reset attack availability 
    private void resetAttack(){
        p.readyToAttack = true;
    }

    private void CheckAttackCollisions(){
        // Define the number of rays in the cone and the angle between them.
        int numRays = 8;
        float coneAngle = 45.0f; 
        float stepAngle = coneAngle / (numRays - 1);

        for (int i = 0; i < numRays; i++){
            // Calculate the rotation of the current ray.
            Quaternion rayRotation = Quaternion.Euler(0, i * stepAngle - coneAngle / 2, 0);

            // Cast a sphere for the current ray.
            RaycastHit[] hits = Physics.SphereCastAll(transform.position, 1.0f, rayRotation * transform.forward, range + (p.equippedWeapon != null ? p.equippedWeapon.range : 0));

            // Iterate through the hits and apply damage to enemies.
            foreach (var hit in hits){
                if (hit.collider.CompareTag("Enemy")){
                    Debug.Log("Enemy hit: " + hit.collider.gameObject);
                    // EnemyBase enemy = hit.collider.GetComponent<EnemyBase>();
                    // if (enemy != null){
                    //     enemy.GetHurt(damage + (p.equippedWeapon != null ? p.equippedWeapon.damage : 0));
                    // }
                }
            }
        }
    }
}
