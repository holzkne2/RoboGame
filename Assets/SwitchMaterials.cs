using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwitchMaterials : MonoBehaviour {

    public Material material;
	
	void Start () {
		MeshRenderer[] objs = GameObject.FindObjectsOfType<MeshRenderer>() as MeshRenderer[];
        for (int i = 0; i < objs.Length; i++)
        {
            objs[i].sharedMaterial = material;
        }
	}
}
