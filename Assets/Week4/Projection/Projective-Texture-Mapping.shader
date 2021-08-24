Shader "Unlit/ProjectorShader"
{
    Properties
    {
	    AmbientCol ("AmbientCol", Color) = (1,1,1,1)
        MaterialSpecularColor ("MaterialSpecularColor", Color) = (1,1,1,1)
        MaterialSpecularShininess("MaterialSpecularShininess", range(1, 50)) = 0.3
        shadowBias("shadow bias", Range(0, 0.1)) = 0.05
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
                float2 uv2 : TEXCOORD4;
                float3 normal	: NORMAL;
                float4 color	: COLOR;

            };

            struct v2f
            {
            
       
                float4 vertex : SV_POSITION;
                float3 normal	: NORMAL;
                float4 color	: COLOR;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD4;
                float3 worldPos : TEXCOORD1;
                float4 shadowPos : TEXCOORD2;
                float4 shadowPos2 : TEXCOORD3;
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
            float shadowBias;	
			float4x4  MyShadowVP;
            float4x4  MyShadowVP2;        
            sampler2D MyShadowMap;
            sampler2D MyShadowMap2;
            sampler2D uvChecker;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.color = v.color;
                //o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                  o.normal =  UnityObjectToWorldNormal(v.normal.xyz); 
    	        float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.shadowPos = mul(MyShadowVP, wpos);
				o.shadowPos.xyz /= o.shadowPos.w;
                o.shadowPos2 = mul(MyShadowVP2, wpos);
				o.shadowPos2.xyz /= o.shadowPos2.w;
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
                   
                   //fallOff = smoothstep(InnerAngle[a], OuterAngle[a], CurrentAngle)
             
                    float RangeFactor = lightType[a] ==2 ? PLRangeFactor: SPRangeFactor;
                    RangeFactor= lightType[a] ==1 ? 1:RangeFactor;
                    DiffuseColor  += float4 (_LightColors[a]*max(0,NdotL)*_LightIntensityValue[a]*RangeFactor,0);
                    

                  
                   //float3 R = NdotL*N*2-L;
                    float3 R = reflect(L,N);
                    //float3 V= normalize( _LightPos[a].xyz -i.worldPos );
                    float3 V= normalize( i.worldPos.xyz -CamPos.xyz );
                    float4 Angle = max(0,dot(R,V));
                    TempSpecularCol =SpecularCol +  MaterialSpecularColor*pow(Angle,MaterialSpecularShininess)*RangeFactor;
                    SpecularCol =lightType[a] ==1 ? SpecularCol :TempSpecularCol; // 0 is spot 1 is directional light 2 = Point
                      
                    
                
                }
                    float4 color = 0;
                    color += AmbientCol;
				    color += DiffuseColor;
				  //  color += SpecularCol;




                // Projection 
	            float4 s = i.shadowPos;
         
				float3 uv = s.xyz * 0.5 + 0.5;
				float d = uv.z;
                	d -= shadowBias;

                float4 s2 = i.shadowPos2;
         
				float3 uv2 = s2.xyz * 0.5 + 0.5;
				float d2 = uv2.z;
                	d2 -= shadowBias;
                  //return d;
			    // if (true) {
				
				//     float3 L2 = normalize(-_LightPos[0].xyz);
				// 	float slope = tan(acos(dot(N,L2)));

				// 	d -= shadowBias * slope;
				// } else {
				// 	d -= shadowBias;
				// }




				// depth checking
				if (false) {
					if (d < 0) return float4(1,0,0,1);
					if (d > 1) return float4(0,1,0,1);
					return float4(0, 0, d, 1);
				}

				//return tex2D(uvChecker, uv); // projection checking

				float m = tex2D(MyShadowMap, uv).r;
                float glassShadow = tex2D(MyShadowMap2, uv).r;            
                return float4(glassShadow,0,0,1);
                //return float4(m.r,0,0,1);
				//return float4(m,m,m,1); // shadowMap checking
				//return float4(d, m, 0, 1);

				float c = 0;
				if (d > m.r)
                	return float4(0,0,0,1);
                return color;
                
            }
            ENDHLSL
        }
    }
}
