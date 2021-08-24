Shader "Unlit/Transparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (1,1,1,1)	   
        AmbientCol ("AmbientCol", Color) = (1,1,1,1)
        MaterialSpecularColor ("MaterialSpecularColor", Color) = (1,1,1,1)
        MaterialSpecularShininess("MaterialSpecularShininess", range(1, 50)) = 0.3
    }
    SubShader
    {
    	Tags { "Queue"="Transparent" "RenderType"="Transparent" }   //to switch render quene to 3000 , will draw other non transparent object first
        LOD 100
        cull Off
	    Blend SrcAlpha OneMinusSrcAlpha
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
            float4 _MainColor;
            sampler2D _MainTex;
             float4 _MainTex_ST;
            float  MaterialSpecularShininess;
            float4 MaterialSpecularColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
				    color += SpecularCol;
                float4 col = tex2D(_MainTex, i.uv);
                //return SpecularCol; 
                return (col* _MainColor.a+color);
                //return color;
            }
                  ENDHLSL

            // CGPROGRAM
            // #pragma vertex vert
            // #pragma fragment frag
            // // make fog work
            // #pragma multi_compile_fog

            // #include "UnityCG.cginc"

            // struct appdata
            // {
            //     float4 vertex : POSITION;
            //     float2 uv : TEXCOORD0;
            // };

            // struct v2f
            // {
            //     float2 uv : TEXCOORD0;
            //     UNITY_FOG_COORDS(1)
            //     float4 vertex : SV_POSITION;
            // };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            // float4 _MainColor;

            // v2f vert (appdata v)
            // {
            //     v2f o;
            //     o.vertex = UnityObjectToClipPos(v.vertex);
            //     o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //     UNITY_TRANSFER_FOG(o,o.vertex);
            //     return o;
            // }

            // fixed4 frag (v2f i) : SV_Target
            // {
            //     // sample the texture
            //     fixed4 col = tex2D(_MainTex, i.uv);
            //     // apply fog
            //     UNITY_APPLY_FOG(i.fogCoord, col);
            
            //     return col* _MainColor.a;
            // }
            // ENDCG
        }
    }
}
