using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FindTriangles : MonoBehaviour
{

    Mesh mesh;
    public List<Vector3> vert;
    public List<int> indicesList;
    public List<int> triangleList;
    // Start is called before the first frame update
    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;

        mesh.GetVertices(vert);

        for (int i = 0; i < mesh.triangles.Length; i++) {
            indicesList.Add(mesh.triangles[i]);
        
        }
        for (int submesh = 0; submesh < mesh.subMeshCount; submesh++)
        {
            var IntArray = mesh.GetIndices(submesh);
           
            //for (int i = 0;i< IntArray.Length; i++) {
            //    indicesList.Add (IntArray[i]);
            //}


            int[] indices = mesh.GetTriangles(submesh);

            for (int i = 0; i < indices.Length; i += 3)
            {
                triangleList.Add (indices[i]);

            }

        }
    }



}
