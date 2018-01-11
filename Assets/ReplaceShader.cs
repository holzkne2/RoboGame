using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ReplaceShader : MonoBehaviour {

    public Shader shader;

	void Start ()
    {
        GetComponent<Camera>().SetReplacementShader(shader, "RenderType");
	}
}
