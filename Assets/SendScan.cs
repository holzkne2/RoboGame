using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendScan : MonoBehaviour {

    public Material material;
    public float speed = 0.2f;

    private float distance = 0f;

    public RenderTexture shadowMap;
    private Camera camera;

    void Start()
    {
        Scan();
    }

    void LateUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Scan();
        }
        material.SetFloat("_ScanDistance", distance);
        distance += Time.deltaTime * speed;
        distance = Mathf.Clamp01(distance);
    }
	
    void Scan()
    {
        Vector3 pos = transform.position;
        if (camera == null)
        {
            GameObject go = new GameObject("Shadowmap", typeof(Camera));
            go.hideFlags = HideFlags.HideAndDontSave;
            camera = go.GetComponent<Camera>();
            camera.farClipPlane = Camera.main.farClipPlane;
            camera.enabled = false;
            camera.allowMSAA = false;
            camera.depthTextureMode = DepthTextureMode.Depth;
            camera.fieldOfView = 180;
        }
        camera.transform.position = pos;
        shadowMap.dimension = UnityEngine.Rendering.TextureDimension.Cube;
        Debug.Log(camera.RenderToCubemap(shadowMap));
        material.SetTexture("_ShadowMap", shadowMap);

        material.SetVector("_ScanPosition", new Vector4(pos.x, pos.y, pos.z, 1));
        distance = 0.05f;
    }

    void OnDisable()
    {
        DestroyImmediate(camera.gameObject);
    }
}
