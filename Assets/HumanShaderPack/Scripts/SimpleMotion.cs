using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleMotion : MonoBehaviour {

    private float xx;
    private float yy;
    public float height = 0.1f;
    public float width = 0.1f;
    private float nw;
    private float nh;
    public float wspeed = 0.1f;
    public float hspeed = 0.1f;

    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        transform.Translate(Vector3.left * Time.deltaTime * xx );
        transform.Translate(Vector3.up * Time.deltaTime * yy);
        xx = Mathf.Sin(nw) * width ;// * width;
        nw+=wspeed;
        yy = Mathf.Cos(nh) * height;// * width;
        nh-= hspeed;


    }
}
