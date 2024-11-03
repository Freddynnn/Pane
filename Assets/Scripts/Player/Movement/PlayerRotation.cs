using UnityEngine;

public class PlayerRotation : MonoBehaviour
{
    private void Update()
    {
        RotateToMouse();
        
        
    }

    private void RotateToMouse()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hitInfo;
        if (Physics.Raycast(ray, out hitInfo, float.MaxValue, LayerMask.GetMask("Ground")))
        {
            if (hitInfo.collider != null)
            {
                Vector3 playerToMouse = hitInfo.point - transform.position;
                playerToMouse.y = 0f;

                Quaternion newQuaternion = Quaternion.LookRotation(playerToMouse);
                transform.rotation = newQuaternion;
            }
        }
    }
}
