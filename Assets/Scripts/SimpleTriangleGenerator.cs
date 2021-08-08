using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class SimpleTriangleGenerator : MonoBehaviour
{
    public float width = 1;
    public float height = 1;
    public bool isEditor;
    public Material material;
    public Mesh mesh;
    public float OffsetX = 1;

    public void Start()
    {
        if (!isEditor)
        {
            GenerateMesh();
        }
    }

     public void GenerateMesh() {
            MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
            meshRenderer.sharedMaterial = material;

            MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();

            mesh = new Mesh();

        //Vector3[] vertices = new Vector3[6]
        //{
        //new Vector3(1, 0, 0),
        //new Vector3(0, 0, 0),
        //new Vector3(0, 0, 1),
        //new Vector3(1, 0, 0),
        //new Vector3(0, 0, 1),
        //new Vector3(1, 0, 1),
        //};

        Vector3[] vertices = new Vector3[4]
        {
        new Vector3(0, 0, 0),
        new Vector3(1, 0, 0),
        new Vector3(0, 0, 1),
        new Vector3(1, 0, 1),
        };

        mesh.vertices = vertices;

            //int[] tris = new int[6]
            //{
            //// lower left triangle
            //0, 1, 2,
            //// upper right triangle
            //3, 4, 5
            //};


        int[] tris = new int[6]
        {
            // lower left triangle
            1, 0, 2,2,3,1
            // upper right triangle
        };
            mesh.triangles = tris;
        
            meshFilter.mesh = mesh;
            meshFilter.mesh.RecalculateNormals();

        for (int submesh = 0; submesh < mesh.subMeshCount; submesh++)
        {


            int[] indices = mesh.GetTriangles(submesh);

            for (int i = 0; i < indices.Length; i += 3)
            {
                Debug.Log(i);
            }

        }
            

    }

    void Update()
    {

        
        //Vector3[] vertices = mesh.vertices;
        //Vector3[] normals = mesh.normals;

        //for (var i = 0; i < vertices.Length; i++)
        //{
        //    vertices[i] += normals[i] * Mathf.Sin(Time.time);
        //}

        //mesh.vertices = vertices;


    }




}
