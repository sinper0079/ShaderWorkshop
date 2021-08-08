using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshController : MonoBehaviour
{


    /// <SplitMesh>
    Mesh mesh;
    List<Vector3> vert;
    Vector3[] verts;
    public List<Vector3> newVerts;
    public List<int> newIndices;
    public List<Vector2> newUV;
    Vector3[] OrgVertices;
    public List<Vector3> adjustVertices;
    public bool isSplitMesh;
    public bool isMoveMesh;
    public List<Vector3> Normals;
    public float YOffset = 1;
    public List<Vector2> meshUV;
    

    /// </SplitMesh>

    // Start is called before the first frame update
    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
        for (int i = 0; i < mesh.uv.Length; i++) {
            meshUV.Add(mesh.uv[i]);
        }


        if (isSplitMesh)
        {
            SplitMesh();
            CalCenterPoint();
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
        }
    }

    void CalCenterPoint() {
        Vector2[] tempUv2 = new Vector2[mesh.triangles.Length];
        Vector2[] tempUv3 = new Vector2[mesh.triangles.Length];
        for (var submesh = 0; submesh < mesh.subMeshCount; submesh++)
        {
            mesh.GetTriangles(submesh);

            int[] indices = mesh.GetTriangles(submesh);

            for (int i = 0; i < indices.Length; i += 3)
            {

                var v1 = mesh.vertices[i + 0];
                var v2 = mesh.vertices[i + 1];
                var v3 = mesh.vertices[i + 2];

                var centerPoint = (v1 + v2 + v3) / 3;
          
                for (int n = 0; n < 3; n++)
                {

                    int index = indices[i + n];
                    tempUv2[index].x = centerPoint.x;
                    tempUv2[index].y = centerPoint.y;
                    tempUv3[index].x = centerPoint.z;

                }

            }

        }

        mesh.uv2 = tempUv2;
        mesh.uv3 = tempUv3;

    }


    void SplitMesh() {
        
        verts = mesh.vertices;
        var totalIndex = mesh.triangles.Length;


  

        for (int i = 0; i < totalIndex; i++)
        {
            var indice = mesh.triangles[i];
    
            newVerts.Add(verts[indice]);
            newIndices.Add(i);
 
        }

        mesh.vertices = newVerts.ToArray();
        Vector2[] uvs = new Vector2[mesh.vertices.Length];
        for (int i = 0; i < uvs.Length; i++)
        {
            uvs[i] = new Vector2(mesh.vertices[i].x / 10, mesh.vertices[i].z / 10);
        }


        mesh.triangles = newIndices.ToArray();
        mesh.uv = uvs;
  


        OrgVertices = mesh.vertices;
        mesh.GetNormals(Normals);
    }


    void MoveMesh() {
        adjustVertices.Clear();

        for (var submesh = 0; submesh < mesh.subMeshCount; submesh++)
        {
            mesh.GetTriangles(submesh);

            int[] indices = mesh.GetTriangles(submesh);

            for (int i = 0; i < indices.Length; i += 3)
            {

                var OffSet = Random.Range(0.1f, 0.5f);
                var Dir = (this.transform.position - OrgVertices[i]).normalized;

                for (int n = 0; n < 3; n++)
                {
    
                    int index = indices[i + n];
                   
                    adjustVertices.Add(OrgVertices[index] +new Vector3(0,YOffset* i/100, 0));

                }

            }

        }
        // assign the local vertices array into the vertices array of the Mesh.
        mesh.vertices = adjustVertices.ToArray();
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }


    void FixedUpdate()
    {
        if (isMoveMesh)
            MoveMesh();

    }

}
