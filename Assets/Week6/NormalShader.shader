Shader "Unlit/NormalShader"
{
    Properties
    {
	
       	AmbientCol		("Ambient Color", Color) = (0,0,0,0)
		diffuseCol		("Diffuse Color", Color) = (1,1,1,1)
		specularCol		("Specular Color", Color) = (1,1,1,1)
		specularShininess	("Specular Shininess", Range(0,100)) = 10
        _NormalMap("NormalMap",2D) = "white"{}
        _SpecularMap("SpecularMap",2D) = "white"{}
        _DiffuseMap("DiffuseMap",2D) = "white"{}
          MaterialSpecularColor ("MaterialSpecularColor", Color) = (1,1,1,1)
        MaterialSpecularShininess("MaterialSpecularShininess", range(1, 50)) = 0.3
    }
  SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Pass
			{
				HLSLPROGRAM
				#pragma vertex vert
				#pragma fragment frag

			#include "../MyCommon/MyCommon.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
			struct Attributes
			{
				float4 positionOS   : POSITION;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
				 float2 uv : TEXCOORD0;
			};

			struct Varyings
			{
				float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
                float3 tangent: TANGENT;
				float3 wpos : TEXCOORD1;
				float3 wtangent :TEXCOORD2;
				float3 wnormal :TEXCOORD3;
				float4 color : COLOR;
			};

			struct SurfaceInfo {
				float3 baseColor;
				float3 positionWS;
				float4 ambient;
				float diffuse;
				float specular;
				float shininess;
				float3 normal;
                float3 tangent;
              	float4 NormalColor;
				float4 SpecularColor;
				float4 DiffuseColor; 
				float2 uv;
			};


       		float4 AmbientCol;
			float4 diffuseCol;
			float4 specularCol;
			float specularShininess;
			float3 LightPos;
			TEXTURE2D(_NormalMap);
			TEXTURE2D(_SpecularMap);
			TEXTURE2D(_DiffuseMap);

			SAMPLER(sampler_NormalMap);
			SAMPLER(sampler_SpecularMap);
			SAMPLER(sampler_DiffuseMap);
            
			CBUFFER_START(UnityPerMaterial)
				float4 _DiffuseMap_ST;
			CBUFFER_END
			float4 computeLighting(SurfaceInfo s) {

				float3 N = normalize(s.normal);
				float3 L = normalize(LightPos - s.positionWS);
				float3 V = normalize(s.positionWS - _WorldSpaceCameraPos);

				float3 T = normalize(s.tangent);
				float3x3 TBN = float3x3(T, cross(N, T), N);
			
				//normal map
				N = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, s.uv).xyz * 2 - 1; 
				N.y = -N.y;

				N = mul(TBN, N); 

				float3 R = reflect(L,N);

				float4 ambient  = s.ambient;
				float4 diffuse  = 	s.diffuse * SAMPLE_TEXTURE2D(_DiffuseMap,sampler_DiffuseMap, s.uv) * dot(N,L);
			
				float  specularAngle = max(0, dot(R,V));				
				float4 specular = specularCol * SAMPLE_TEXTURE2D(_SpecularMap,sampler_SpecularMap, s.uv) * pow(specularAngle, s.shininess);

				float4 color = 0;
				color += ambient;
				color += diffuse;
				color += specular;

				return color;
			}

			//float  MyGBuffer_depth;
	
            


			Varyings vert (Attributes i) {
				Varyings o;
				o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
				o.wpos  = TransformObjectToWorld(i.positionOS.xyz);
				o.wnormal = TransformObjectToWorldDir(i.normal);
				o.wtangent = TransformObjectToWorldDir(i.tangent);
				o.uv = TRANSFORM_TEX(i.uv, _DiffuseMap);
				o.color = 1;
				return o;
			}

			float4 frag (Varyings i) : SV_Target {
			
				float4 o = i.color;
				SurfaceInfo s;
			//	s.baseColor  = AmbientCol.rgb;
				s.positionWS = i.wpos.xyz;
				s.normal     = normalize (i.wnormal);
      			s.tangent  =   normalize (i.wtangent);

				s.ambient   = AmbientCol;
				s.diffuse   = diffuseCol;
				s.specular  = specularCol;
				s.shininess = specularShininess;
                s.uv = i.uv;
				

				

				return computeLighting(s);
			}
			ENDHLSL
		}
	}
}
