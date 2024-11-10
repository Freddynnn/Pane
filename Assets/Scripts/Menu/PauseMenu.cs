using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public class PauseMenu : MonoBehaviour{

    public GameObject PausePanel;
    public GameObject camTarget;
    public void Update(){
        if (Input.GetKeyDown(KeyCode.Escape)){
            PauseGame();
            camTarget.SetActive(false);
        }
    }

    public void PauseGame(){
        PausePanel.SetActive(true);
        Time.timeScale = 0;

    }

    public void ContinueGame(){
        PausePanel.SetActive(false);
        Time.timeScale = 1;
        camTarget.SetActive(true);
    }
}
