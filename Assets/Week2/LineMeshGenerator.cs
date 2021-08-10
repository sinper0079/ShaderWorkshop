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
    public bool isForceRotate;
    public List<Vector3> ListPos;

    public List<Vector3> LeftPosList;
    public List<Vector3> RightPosList;
    public float removeTailTime = 0.4f;
    float currentRemoveTailTime;
    public bool isSpreadTail;
    public float SpreadTailWeight = 0.2f;
    public float lineWidth = 5;
    public Material material;
    Mesh mesh;
    bool IsRemoving;
    public List<Vector2> uvList;
    // Start is called before the first frame update
    void Start()
    {



        var go = new GameObject();
        go.AddComponent<MeshRenderer>();
        go.AddComponent<MeshFilter>();
        go.GetComponent<MeshRenderer>().material = material;
        mesh = new Mesh();
        go.GetComponent<MeshFilter>().mesh= mesh;
        //AddPos();
        totalDist = 0;
        LastPos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        currentRemoveTailTime -= Time.deltaTime;

        if (currentRemoveTailTime <= 0)
        {

            currentRemoveTailTime = removeTailTime;

            removeLastPoint();
            GenerateMesh();
        }

        var Dist = Vector3.Distance(transform.position, LastPos);
        if (Dist >= GenerateDist)
        {
            LastPos = transform.position;
            if (ListPos.Count > 2 && isForceRotate)
            {
                var lastPos = ListPos[ListPos.Count - 2];
                var moveDir = (transform.position - lastPos).normalized;
                transform.rotation = Quaternion.LookRotation(moveDir);
            }

            AddPos();
            totalDist += Dist;

     
       
            if (totalDist > maxDist)
            {
                totalDist = 0;
                Debug.Log("max Dist exceed");
                removeLastPoint();
            }


            GenerateMesh();
        }
    }
    void AddPos() {

        var leftPos = new Vector3(0, 0, 0);
        var rightPos = new Vector3(0, 0, 0);

        leftPos = transform.position - transform.right * lineWidth;
        rightPos = transform.position + transform.right * lineWidth;
        // add points

        LeftPosList.Add(leftPos);
        RightPosList.Add(rightPos);
        ListPos.Add(transform.position);
    }

    void removeLastPoint() {
        if (LeftPosList.Count >= 2 && RightPosList.Count >= 2 && LeftPosList.Count == RightPosList.Count&&!IsRemoving)
        {
            IsRemoving = true;
            LeftPosList.RemoveAt(0);
            RightPosList.RemoveAt(0);
            ListPos.RemoveAt(0);
            IsRemoving = false;
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
            Vector2[] uvs = new Vector2[mesh.vertices.Length];
            float totalSquare = LeftPosList.Count - 1;
            //up list 
            for (int i = 0; i < uvs.Length; i += 2)
            {
  
                    float a = 1 / totalSquare * (uvs.Length -i)*0.5f;
                    uvs[i] = new Vector2(a, 1);
                Debug.Log("i  "+i+"  uvs[i]  "+uvs[i]+ "  totalSquare  "+ totalSquare+ " uvs.Length "+ uvs.Length);
            }

            //down list 
            for (int i = 1; i < uvs.Length; i += 2)
            {

                float b = 1 / totalSquare* (uvs.Length - i-1) * 0.5f;
                uvs[i] = new Vector2(b, 0);
 
            }

            uvList.Clear();
            uvList.AddRange(uvs);
            mesh.uv = uvs;
            mesh.triangles = indices;
            mesh.RecalculateNormals();
        }
        
    }
}
