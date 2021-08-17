Shader "Unlit/ForceFieldShader"
{
  Properties
	{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0, 1)) = 1
		_Glow("Glow", Range(-100, 100)) = 20
		 _PulseTex("Hex Pulse Texture", 2D) = "white" {}
		 _AnimTex("_AnimTex", 2D) = "white" {}
		_IntersectionPower("Intersect Power", Range(0, 3)) = 1
		_AnimSpeed("_AnimSpeed", Range(0, 3)) = 1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }   //to switch render quene to 3000 , will draw other non transparent object first

		Pass
		{
			cull Off	// render for two side 
			ZWrite Off  // not update depth buffer, but we still need depth test
			//Blend SrcAlpha OneMinusSrcAlpha // can use other blend method 
			Blend SrcAlpha One
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD2;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldViewDir : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				float eyeZ : TEXCOORD3;
				float2 uv : TEXCOORD4;
				float2 uv2 : TEXCOORD5;
			};

			sampler2D _CameraDepthTexture;
			float4 _MainColor;
			float _RimPower;
			float _IntersectionPower;
			float _Glow;
			sampler2D _PulseTex;
			float4 _PulseTex_ST;
			sampler2D _AnimTex;
			float4 	_AnimTex_ST;
			float _AnimSpeed;
			v2f vert (appdata v)
			{
		
				v2f o;
				  o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _PulseTex);
                // o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z); // computes eye space depth of the vertex and outputs it in o. Use it in a vertex program when not rendering into a depth texture.
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldViewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex)));
                return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float2 offsetUv =   i.uv*float2(2,1) + float2(0,_Time.y*_AnimSpeed);
 				  float4 pulseTex = tex2D(_PulseTex, offsetUv);
   				float4 pulseTerm = pulseTex.r * _MainColor;

			
				float4 _animTexCol = tex2D(_AnimTex,  offsetUv);
				float4 finalCol = pulseTerm*_animTexCol.r ;

				//Rim
				float rim = 1 - abs(dot(i.worldNormal, normalize(i.worldViewDir)))* _RimPower;

				//intersect
				float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
				float partZ = i.screenPos.z;
				float diff = sceneZ - partZ;
				float intersect = (1 - diff) * _IntersectionPower;
				
				
				
				float v = max (rim, intersect);
				 return _MainColor*finalCol*_Glow+_MainColor*v;
			}	
			ENDHLSL
		}
	}
}
