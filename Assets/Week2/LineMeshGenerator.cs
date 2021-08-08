using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineMeshGenerator : MonoBehaviour
{
    Vector3 LastPos;
    Vector3 tempLastPos;
    public float maxDist = 10;
    public float GenerateDist = 0.1f;
    float totalDist;
    public List<Vector3> ListPos;
    public List<Vector3> ListUpVec;
    public List<Vector3> LeftPosList;
    public List<Vector3> RightPosList;
    public float lineWidth = 5;
    public Material material;
    Mesh mesh;
    // Start is called before the first frame update
    void Start()
    {
        LastPos = transform.position;
        ListPos.Add(transform.position);
        var go = new GameObject();
        go.AddComponent<MeshRenderer>();
        go.AddComponent<MeshFilter>();
        go.GetComponent<MeshRenderer>().material = material;
        mesh = new Mesh();
        go.GetComponent<MeshFilter>().mesh= mesh;
     
    }

    // Update is called once per frame
    void Update()
    {
        var Dist = Vector3.Distance(transform.position, LastPos);
        if (Dist >= GenerateDist)
        {
            Debug.Log("Dist" + Dist + "GenerateDist" + GenerateDist);
            LastPos = transform.position;
            if (ListPos.Count > 2)
            {
                var lastPos = ListPos[ListPos.Count - 2];
                var moveDir = (transform.position - lastPos).normalized;
                transform.rotation = Quaternion.LookRotation(moveDir);
            }
            ListUpVec.Add(transform.up);
            var leftPos = transform.position - transform.right * lineWidth;
            var rightPos = transform.position + transform.right * lineWidth;
            //Debug.DrawLine(transform.position, rightPos, Color.red, 20);
            //Debug.DrawLine(transform.position, leftPos, Color.red, 20);
            //adjust to move direction 
   


            LeftPosList.Add(leftPos);
            RightPosList.Add(rightPos);
            ListPos.Add(transform.position);
            totalDist += Dist;

            if (totalDist > maxDist)
            {
                LeftPosList.RemoveAt(0);
                RightPosList.RemoveAt(0);
                ListPos.RemoveAt(0);
            }

              
      
           GenerateMesh();
        }
    }




    void GenerateMesh()
    {
        mesh.Clear();
        if (LeftPosList.Count >= 2 && RightPosList.Count >= 2 && LeftPosList.Count == RightPosList.Count)
        {
            var index = LeftPosList.Count;
           
            Vector3[] verts = new Vector3[index * 2];
            for (var i = 0; i < index * 2; i += 2)
            {
                if (i == 0)
                {
                    verts[i] = LeftPosList[i];
                }
                else
                {
                    verts[i] = LeftPosList[i / 2];
                }
            }
            for (var i = 1; i < index * 2; i += 2)
            {
                if (i == 1)
                {
                    verts[i] = RightPosList[i - 1];

                }
                else
                {

                    verts[i] = RightPosList[(i - 1) / 2];
                }
            }
            mesh.vertices = verts;
            var totalTriangle = verts.Length - 2;
            var indicesIndex = totalTriangle * 3;

            int[] indices = new int[indicesIndex];
            for (var i = 0; i < indicesIndex; i += 6)
            {
                if (i == 0)
                {
                    indices[0] = 0;
                    indices[1] = 2;
                    indices[2] = 3;
                    indices[3] = 0;
                    indices[4] = 3;
                    indices[5] = 1;
                }
                else
                {
                    indices[i] = indices[i - 6] + 2;
                    indices[i + 1] = indices[i + 1 - 6] + 2;
                    indices[i + 2] = indices[i + 2 - 6] + 2;
                    indices[i + 3] = indices[i + 3 - 6] + 2;
                    indices[i + 4] = indices[i + 4 - 6] + 2;
                    indices[i + 5] = indices[i + 5 - 6] + 2;

                   // Debug.Log(indices[i] + "," + indices[i + 1] + "," + indices[i + 2] + "," + indices[i + 3] + "," + indices[i + 4] + "," + indices[i + 5]);
                }
            }

            mesh.triangles = indices;

  
            mesh.RecalculateNormals();
        }
    }
}
