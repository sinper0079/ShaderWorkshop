using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightPosUpdate : MonoBehaviour
{

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("LightPos", transform.position);
    }
}
