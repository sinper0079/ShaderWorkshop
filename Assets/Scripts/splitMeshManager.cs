
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class splitMeshManager : MonoBehaviour
{
    Mesh newMesh;
    public List<int> allIndices = new List<int>();
    public List<int> newIndices = new List<int>();
    public List<int> restIndices = new List<int>();
    public Material material;
    // Use this for initialization
    void Start()
    {
        SplitMesh();
    }

    public void SplitMesh()
    {
        MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
        Mesh mesh = GetComponent<MeshFilter>().mesh;

        int[] indices = mesh.triangles;
        Vector3[] verts = mesh.vertices;

        //list all indices
        for (int i = 0; i < indices.Length; i++)
        {
            allIndices.Add(indices[i]);
            restIndices.Add(indices[i]);
        }

        while (restIndices.Count > 0)
        {
            newIndices.Clear();
            //Get first triangle
            for (int i = 0; i < 3; i++)
            {
                newIndices.Add(restIndices[i]);// 0 1 2
            }


            // loop all rest triangles indices
            for (int i = 1; i < restIndices.Count / 3; i++)
            {
                if (newIndices.Contains(restIndices[(i * 3) + 0]) || newIndices.Contains(restIndices[(i * 3) + 1]) || newIndices.Contains(restIndices[(i * 3) + 2]))
                {
                    for (int q = 0; q < 3; q++)
                    {
                        newIndices.Add(restIndices[(i * 3) + q]);
                    }
                }
            }



            restIndices.Clear();
            for (int n = 0; n < allIndices.Count; n++)
            {
                if (!newIndices.Contains(allIndices[n]))
                {
                    restIndices.Add(allIndices[n]);
                }
            }
            allIndices.Clear();
            for (int i = 0; i < restIndices.Count; i++)
            {
                allIndices.Add(restIndices[i]);
            }

            mesh.triangles = restIndices.ToArray();

             newMesh = new Mesh();
            newMesh.vertices = verts;
            newMesh.triangles = newIndices.ToArray();

            newMesh.RecalculateNormals();

            GameObject newGameObject = new GameObject("newGameObject");
            newGameObject.AddComponent<MeshRenderer>().material = meshRenderer.material;
            newGameObject.AddComponent<MeshFilter>().mesh = newMesh;
            newGameObject.transform.position = this.transform.position;
        }
        // this.gameObject.SetActive(false);
    }

    void Update(){
        Vector3[] vertices = newMesh.vertices;
        Vector3[] normals = newMesh.normals;

        for (var i = 0; i<vertices.Length; i++)
        {
            vertices[i] += normals[i] * Mathf.Sin(Time.time);
        }

        newMesh.vertices = vertices;
        newMesh.RecalculateNormals();
    }
}
