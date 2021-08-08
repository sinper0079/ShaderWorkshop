using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGenerator : MonoBehaviour
{
    public bool isCloned;
    public Vector3[] vertices;
    public int[] triangles;
    public int[] newTriangles;

    Mesh clonedMesh;
    Mesh originalMesh;
    // Start is called before the first frame update
    void Start()
    {
        var meshFilter = GetComponent<MeshFilter>();
        originalMesh = meshFilter.sharedMesh; //1
        clonedMesh = new Mesh(); //2

        clonedMesh.name = "clone";
        clonedMesh.vertices = originalMesh.vertices;
        clonedMesh.triangles = originalMesh.triangles;
        clonedMesh.normals = originalMesh.normals;
        clonedMesh.uv = originalMesh.uv;
        meshFilter.mesh = clonedMesh;  //3

        vertices = clonedMesh.vertices; //4
        triangles = clonedMesh.triangles;
        isCloned = true; //5
        Debug.Log("Init & Cloned");
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
