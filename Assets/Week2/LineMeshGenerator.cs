using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineMeshGenerator : MonoBehaviour
{
    Vector3 LastPos;
    Vector3 tempLastPos;
    float maxDist = 40;
    float GenerateDist = 2;
    float totalDist;
    public List<Vector3> ListPos;
    public float lineWidth=5;

    // Start is called before the first frame update
    void Start()
    {
        LastPos = transform.position;
        ListPos.Add(transform.position);
        gameObject.AddComponent<MeshRenderer>();
         
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        var Dist = Vector3.Distance(transform.position, LastPos);
        if (Dist >= GenerateDist) {
            LastPos = transform.position;
            var leftPos = transform.position- transform.right * lineWidth;
            var rightPos = transform.position + transform.right * lineWidth;

            Debug.DrawLine(LastPos, leftPos, Color.red, 20);
            Debug.DrawLine(LastPos, rightPos, Color.red, 20);

            ListPos.Add(transform.position);
            totalDist += Dist;
            if (totalDist > maxDist) {
                ListPos.RemoveAt(0);    
            }
            GenerateMesh();
        }
    }

    void GenerateMesh() {
        var PosArray = ListPos.ToArray();
        
        if (PosArray.Length > 2) {
            for (var i = 0; i < PosArray.Length; i++)
            {
                if (i > 1) {
                    var LastPos = PosArray[i - 1];
                    var CurPos = PosArray[i];
                    var dir =(CurPos - LastPos).normalized;
                    var left= Quaternion.AngleAxis(-90, Vector3.up) * dir;
                    var right = Quaternion.AngleAxis(90, Vector3.up) * dir;
                    var leftPos = LastPos + left * lineWidth;
                    var rightPos = LastPos + right * lineWidth;
                    Debug.DrawLine(LastPos, leftPos,Color.red,20);
                    Debug.DrawLine(LastPos, rightPos, Color.red, 20);
                   
                }
            }
        }
    }
}
