using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;



//[ExecuteInEditMode]
public class SetLightInform : MonoBehaviour
{

    public List<Material>  materials;
    public List<Vector4> positions;
    public List<float> intensities;
    public List<Vector4> colors;
    public List<float> lightType;

    public List<float> LightRange;
    public List<float> InnerAngle;
    public List<Vector4> LightForward;
    public List<float> OuterAngle;
    
    public List<Vector4> LightRots;
    Light[] Lights;
    public Vector3 CamPos;
    // Start is called before the first frame update
    void Start()
    {
        // Lights = FindObjectsOfType<Light>();


        //for (int i = 0; i < Lights.Length; i++) {

        //    positions.Add(Lights[i].transform.position);
        //    intensities.Add(Lights[i].intensity);
        //    colors.Add(Lights[i].color);

        //}
        foreach (Material material in materials)
        {
            //fix unity stupid array size bug
            material.SetVectorArray("_LightPos", new Vector4[100]);
            material.SetFloatArray("_LightIntensityValue", new float[100]);
            material.SetVectorArray("_LightColors", new Vector4[100]);
            material.SetFloatArray("lightType", new float[100]);
            material.SetVectorArray("LightRotation", new Vector4[100]);
            material.SetFloatArray("LightRange", new float[100]);
            material.SetFloatArray("InnerAngle", new float[100]);
            material.SetFloatArray("OuterAngle", new float[100]);
        }
    }
        
    // Update is called once per frame
    void FixedUpdate()
    {
        Lights = null;
        Lights = FindObjectsOfType<Light>();


        if (Lights.Length > 0)
        {
            positions.Clear();
            intensities.Clear();
            colors.Clear();
            lightType.Clear();
            LightRange.Clear();
            LightRots.Clear();
            InnerAngle.Clear();
            OuterAngle.Clear();
            LightForward.Clear();
            CamPos = SceneView.lastActiveSceneView.pivot;
            Vector3 LightDirection;
            for (int i = 0; i < Lights.Length; i++)
            {
                positions.Add(Lights[i].transform.position);
                intensities.Add(Lights[i].intensity);
                colors.Add(Lights[i].color);
                lightType.Add((float)Lights[i].type);

                LightDirection = Lights[i].transform.forward;
                
               
                LightRots.Add(new Vector4(Lights[i].transform.rotation.x, Lights[i].transform.rotation.y, Lights[i].transform.rotation.z, 0));
                InnerAngle.Add(Lights[i].innerSpotAngle*Mathf.Deg2Rad*0.5f);
                OuterAngle.Add(Lights[i].spotAngle * Mathf.Deg2Rad*0.5f);
                //Mathf.Tan(InnerAngle * 0.5f * Mathf.Deg2Rad);
                LightForward.Add(LightDirection);
                // 0 is spot 1 is directional light 2 = Point
                if ((int)Lights[i].type == 2 || (int)Lights[i].type == 0)
                {
                    LightRange.Add(Lights[i].range);
                } else {
                    LightRange.Add(0);
                }
            }

            foreach (Material material in materials)
            {
                if (material && positions.Count > 0 && intensities.Count > 0 && colors.Count > 0)
                {
                    material.SetVector("CamPos", new Vector4(CamPos.x, CamPos.y, CamPos.z, 0));

                    material.SetVectorArray("_LightPos", positions);
                    material.SetFloatArray("_LightIntensityValue", intensities);
                    material.SetVectorArray("_LightColors", colors);
                    material.SetFloatArray("lightType", lightType);
                    material.SetVectorArray("LightRotation", LightRots);
                    material.SetFloatArray("LightRange", LightRange);
                    material.SetFloatArray("InnerAngle", InnerAngle);
                    material.SetFloatArray("OuterAngle", OuterAngle);
                    material.SetVectorArray("LightForward", LightForward);
                    material.SetInt("NumberOfLight", positions.Count);

                }
            }
        }
    }
    
}
