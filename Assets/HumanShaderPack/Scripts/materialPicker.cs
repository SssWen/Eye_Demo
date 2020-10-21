using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class materialPicker : MonoBehaviour {

    [Tooltip("Material Selection")]
    public Material[] MaterialList;
    private Material pick;
    private int n = 0;


        // Use this for initialization
    void Start () {
        n = 0;

       

    }
	
	// Update is called once per frame
	void Update () {
        pick = MaterialList[n];//MaterialList[Random.Range(0, MaterialList.Length)];

        GetComponentInChildren<Renderer>().material = pick;

        if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            if (n < MaterialList.Length-1) n++;

        }

        if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            if (n > 0) n--;
        }

        
    }



}