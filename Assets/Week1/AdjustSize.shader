// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/004 - VertexNormal"
{
	Properties {

		Scale("Scale", range(0, 3)) = 0.3
		_Rotation("_Rotation", range(0, 360)) = 0.3
		testTex("testTex", 2D) = "Black"

	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			Cull Off
			
		//---------------
			CGPROGRAM
			#pragma vertex vs_main
			#pragma fragment ps_main
			
			#include "UnityCG.cginc"
			#define M_PI 3.1415926535897932384626433832795

			struct appdata {
				float4 pos		: POSITION;
				float4 color	: COLOR;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
			};

			struct v2f {
				float4 pos		: SV_POSITION;
				float4 color	: COLOR;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
			};

	
			half Scale;
			half _Rotation;
			float4x4 MyInverseTranspose_LocalToWorldMatrix;
	 float4 RotateAroundYInDegrees (float4 vertex, float degrees)
     {
         float alpha = degrees * UNITY_PI / 180.0;
         float sina, cosa;
         sincos(alpha, sina, cosa);
         float2x2 m = float2x2(cosa, -sina, sina, cosa);
         return float4(mul(m, vertex.xz), vertex.yw).xzyw;
     }
			v2f vs_main (appdata v) {
				v2f o;

				o.pos = UnityObjectToClipPos(RotateAroundYInDegrees(v.pos, _Rotation)*Scale);
//				//float4x4 m = unity_ObjectToWorld;
//				float4x4 m = MyInverseTranspose_LocalToWorldMatrix;
//				float3 wnormal = normalize(mul(m, v.normal));

//				float4 wpos = mul(unity_ObjectToWorld, v.pos);
//				wpos.xyz += wnormal * myOffset;

			//	o.pos = mul(UNITY_MATRIX_VP, wpos);
				//float4 wpos = mul(unity_ObjectToWorld, v.pos);
				//o.pos =o.pos*Scale;
				o.color = v.color;
				o.uv = v.uv;
				o.normal = v.normal;
				return o;
			}

			sampler2D	testTex;

			float4 ps_main (v2f i) : SV_Target {
				return tex2D(testTex, i.uv);
			}
			ENDCG
		}
	}
}
