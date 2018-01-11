using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter))]
public class MeshToCloudPoint : MonoBehaviour {

    public ComputeShader shader;
    public Material material;
    AnimationCurve LOD = new AnimationCurve(new Keyframe(0f, 0f, 0f, 6.02f), new Keyframe(0.5008749f, 0.9759322f), new Keyframe(1f, 1f));

    List<Vector3> vertices;
    List<int> indices;
    List<Vector3> normals;

    float[] prob;
    float total;

    int PointCount {get {return 2000 * Mathf.CeilToInt(total) * Mathf.CeilToInt(transform.lossyScale.magnitude);}}

    Vector3[] points;

    ComputeBuffer buffer;
    ComputeBuffer bufferNormal;

	void Start ()
    {
        GenerateCompute();
       // transform.localRotation = Quaternion.LookRotation(Vector3.up, Vector3.up);
	}

    void OnRenderObject()
    {
        bool _continue = Camera.current == Camera.main;
        if (!_continue && UnityEditor.SceneView.currentDrawingSceneView != null)
            _continue = (Camera.current == UnityEditor.SceneView.currentDrawingSceneView.camera);

        if (!_continue)
            return;

        if (!GeometryUtility.TestPlanesAABB(
            GeometryUtility.CalculateFrustumPlanes(Camera.current),
            GetComponent<MeshRenderer>().bounds))
            return;

        material.SetBuffer("_position", buffer);
        material.SetBuffer("_normals", bufferNormal);
        Matrix4x4 M = transform.localToWorldMatrix;
        material.SetMatrix("_world", M);
        Matrix4x4 V = Camera.current.worldToCameraMatrix;
        material.SetMatrix("_it_mv", Matrix4x4.Transpose(Matrix4x4.Inverse(M)));
        material.SetPass(0);
        float d01 = Vector3.Distance(
            GetComponent<MeshRenderer>().bounds.ClosestPoint(Camera.current.transform.position),
            Camera.current.transform.position)
            /
            Camera.current.farClipPlane;
        d01 = 0;
        int drawCount = (int)Mathf.Lerp(buffer.count, 0, LOD.Evaluate(d01));
        //Debug.Log("Live: " + drawCount + " Points: " + PointCount);
        Graphics.DrawProcedural(MeshTopology.Points, drawCount, 1);
    }

    void GenerateCompute()
    {
        if (shader == null)
            return;

        vertices = new List<Vector3>();
        GetComponent<MeshFilter>().sharedMesh.GetVertices(vertices);

        indices = new List<int>();
        for (int i = 0; i < GetComponent<MeshFilter>().sharedMesh.subMeshCount; i++)
        {
            int[] tris = GetComponent<MeshFilter>().sharedMesh.GetTriangles(i);
            for (int j = 0; j < tris.Length; j++)
                indices.Add(tris[j]);
        }

        normals = new List<Vector3>();
        GetComponent<MeshFilter>().sharedMesh.GetNormals(normals);

        prob = new float[indices.Count / 3];

        // Compute Buffers
        ComputeBuffer ComputerVertices = new ComputeBuffer(vertices.Count, sizeof(float) * 3);
        ComputerVertices.SetData(vertices);

        ComputeBuffer ComputeIndices = new ComputeBuffer(indices.Count, sizeof(int));
        ComputeIndices.SetData(indices);

        ComputeBuffer ComputeProb = new ComputeBuffer(prob.Length, sizeof(float));

        ComputeBuffer ComputeNormals = new ComputeBuffer(normals.Count, sizeof(float) * 3);
        ComputeNormals.SetData(normals);

        // Probability
        int probKernal = shader.FindKernel("Probablity");
        shader.SetBuffer(probKernal, "vertices", ComputerVertices);
        shader.SetBuffer(probKernal, "indices", ComputeIndices);
        shader.SetBuffer(probKernal, "prob", ComputeProb);
        shader.Dispatch(probKernal, prob.Length, 1, 1);

        // Get Total
        ComputeProb.GetData(prob);
        total = 0;
        for (int i = 0; i < prob.Length; i++)
            total += prob[i];

        ComputeBuffer ComputePoints = new ComputeBuffer(PointCount, sizeof(float) * 3);
        ComputeBuffer ComputePointNormals = new ComputeBuffer(PointCount, sizeof(float) * 3);

        float[] index_array = new float[PointCount * 3];
        for (int n = 0; n < PointCount * 3; n++)
        {
            index_array[n] = Random.value;
        }

        ComputeBuffer ComputeRandoms = new ComputeBuffer(PointCount * 3, sizeof(float));
        ComputeRandoms.SetData(index_array);

        // Random Points
        int randomPointsKernal = shader.FindKernel("RandomPoints");
        shader.SetInt("probCount", prob.Length);
        shader.SetFloat("total", total);
        shader.SetBuffer(randomPointsKernal, "vertices", ComputerVertices);
        shader.SetBuffer(randomPointsKernal, "indices", ComputeIndices);
        shader.SetBuffer(randomPointsKernal, "prob", ComputeProb);
        shader.SetBuffer(randomPointsKernal, "normals", ComputeNormals);
        shader.SetBuffer(randomPointsKernal, "randoms", ComputeRandoms);
        shader.SetBuffer(randomPointsKernal, "points", ComputePoints);
        shader.SetBuffer(randomPointsKernal, "points_normals", ComputePointNormals);
        shader.Dispatch(randomPointsKernal, PointCount / 16, 1, 1);

        buffer = ComputePoints;
        bufferNormal = ComputePointNormals;

        CleanUp();
    }

	void Generate()
    {
        vertices = new List<Vector3>();
        GetComponent<MeshFilter>().sharedMesh.GetVertices(vertices);
        indices = new List<int>();
        for (int i = 0; i < GetComponent<MeshFilter>().sharedMesh.subMeshCount; i++)
        {
            int[] tris = GetComponent<MeshFilter>().sharedMesh.GetTriangles(i);
            for (int j = 0; j < tris.Length; j++)
                indices.Add(tris[j]);
        }

        prob = new float[indices.Count / 3];
        WeightProbability();

        points = new Vector3[PointCount];

        RandomPoints();

        buffer = new ComputeBuffer(PointCount, sizeof(float) * 3, ComputeBufferType.Default);
        buffer.SetCounterValue(0);
        buffer.SetData(points);

        CleanUp();
    }

    void CleanUp()
    {
        vertices.Clear();
        indices.Clear();
        normals.Clear();

        prob = new float[0];

        points = new Vector3[0];
    }

    void WeightProbability()
    {
        total = 0;
        for (int i = 0; i < indices.Count / 3; i++)
        {
            Vector3 v1 = vertices[indices[i*3]];
            Vector3 v2 = vertices[indices[i*3 + 1]];
            Vector3 v3 = vertices[indices[i*3 + 2]];

            prob[i] = 0.5f * Vector3.Magnitude(Vector3.Cross(v2 - v1, v3 - v1));
            total += prob[i];
        }
    }

    int Choose()
    {
        float randomValue = Random.value * total;

        for (int i = 0; i < prob.Length; i++)
        {
            if (randomValue < prob[i])
                return i;
            randomValue -= prob[i];
        }
        return prob.Length - 1;
    }

    void RandomPoints()
    {
        Debug.Log("Total: " + total + " Points: " + PointCount);

        for (int n = 0; n < PointCount; n++)
        {
            int index = Choose();
            
            float u = Random.value;
            float v = Random.value;
            if (u + v > 1)
            {
                u = 1 - u;
                v = 1 - v;
            }
            float w = 1 - (u + v);

            Vector3 v1 = vertices[indices[index*3]];
            Vector3 v2 = vertices[indices[index*3 + 1]];
            Vector3 v3 = vertices[indices[index*3 + 2]];

            points[n] = ((v1 * u) + (v2 * v) + (v3 * w));
        }
    }
}
