Shader "Unlit/NewUnlitShader"
{
    Properties
    {
	    AmbientCol ("AmbientCol", Color) = (1,1,1,1)
        MaterialSpecularColor ("MaterialSpecularColor", Color) = (1,1,1,1)
        MaterialSpecularShininess("MaterialSpecularShininess", range(1, 50)) = 0.3
    }
    SubShader
    {
        
		Tags { "RenderType"="Opaque" }
        Pass
        {
            		Cull Off
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
       
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color	: COLOR;
                float3 normal	: NORMAL;
            };

            struct v2f
            {
            
       
                float4 vertex : SV_POSITION;
                float3 normal	: NORMAL;
                float4 color	: COLOR;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 AmbientCol;
            float4 _LightPos[100];
            float4 _LightRot[100];
            float _LightIntensityValue[100];
            float4 _LightColors[100];
            float lightType[100];
            float LightRange[100];
            float4 LightForward[100];   
            float InnerAngle[100];   
            float OuterAngle[100];   
            float4 LightRotation[100];   
            float4 CamPos;
            int NumberOfLight;
            float  MaterialSpecularShininess;
            float4 MaterialSpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                o.uv = v.uv;
                o.color = v.color;
                //o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.normal =  UnityObjectToWorldNormal(v.normal.xyz); 
                return o;
            }

            float3 quatMulVector(float4 quat, float3 v) {
				float3 qv = quat.xyz;
				float3 uv  = cross(qv, v);
				float3 uuv = cross(qv, uv);
				return v + (uv * quat.w + uuv) * 2;
			}


            float4 frag (v2f i) : SV_Target
            {
                float4 DiffuseColor=0 ;
                float4 SpecularCol=0;
                float3 N = normalize(i.normal);
                float4 TempSpecularCol=0;
                float4 TempDiffuseColor=0 ;
                [loop]
                for (int a = 0; a < NumberOfLight; a++)
                {
                    //Diffuse 
                    float3  L  = normalize(_LightPos[a].xyz -i.worldPos.xyz);
                    float3 DirLightL =quatMulVector(LightRotation[a], normalize(N*100 -i.worldPos.xyz));
                    float3  LightDir  = normalize(i.worldPos.xyz-_LightPos[a].xyz);
                    


                    float3 FinalL = lightType[a] ==1 ?DirLightL: L;
                    float3 NdotL = dot(N, FinalL); 
  
                    float CurrentAngle  = acos(dot(LightForward[a],LightDir));
                    float dist = length(_LightPos[a].xyz -i.worldPos.xyz);

                    float PLRangeFactor  =  dist <=LightRange[a]? 1: 0;
                    float SPRangeFactor =(1-smoothstep(InnerAngle[a], OuterAngle[a], CurrentAngle))*step(dist,LightRange[a]);
                   
             
                    float RangeFactor = lightType[a] ==2 ? PLRangeFactor: SPRangeFactor;
                    RangeFactor= lightType[a] ==1 ? 1:RangeFactor;
                    DiffuseColor  += float4 (_LightColors[a]*max(0,NdotL)*_LightIntensityValue[a]*RangeFactor,0);
                    

                  

                    float3 R = reflect(L,N);

                    float3 V= normalize( i.worldPos.xyz -CamPos.xyz );
                    float4 Angle = max(0,dot(R,V));
                    TempSpecularCol =SpecularCol +  MaterialSpecularColor*pow(Angle,MaterialSpecularShininess)*RangeFactor;
                    SpecularCol =lightType[a] ==1 ? SpecularCol :TempSpecularCol; // 0 is spot 1 is directional light 2 = Point
                      
                    
                
                }
                    float4 color = 0;
                    color += AmbientCol;
				    color += DiffuseColor;
				    color += SpecularCol;

                //return SpecularCol; 
                return color;
                
            }
            ENDHLSL
        }
    }
}
