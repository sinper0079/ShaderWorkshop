// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/VertexControl"
{
    Properties {

		
		Weight("Weight", range(0, 1)) = 0
		height("height", range(0, 4)) = 0
		testTex("testTex", 2D) = "white" {}
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


			struct appdata {
				float4 pos		: POSITION;
				float4 color	: COLOR;
				float2 uv: TEXCOORD0;
				float2 uv2: TEXCOORD1;
				float2 uv3: TEXCOORD2;
				float3 normal	: NORMAL;
				          
			};

			struct v2f {
				float4 pos		: SV_POSITION;
				float4 color	: COLOR;
				float2 uv: TEXCOORD0;
				float2 uv2: TEXCOORD1;
				float2 uv3: TEXCOORD2;
				float3 normal	: NORMAL;
			};

	

			
			sampler2D testTex;
			float4 testTex_ST;
			float Weight;
			float height;
			
			v2f vs_main (appdata v) {
				v2f o;

			  	float4 centerPoint = float4(v.uv2.x, v.uv2.y, v.uv3.x,1); 
				float4	wCenterPoint = mul(unity_ObjectToWorld, centerPoint);
				float4 wpos = mul(unity_ObjectToWorld, v.pos);

				float4 finalWpos = lerp (wpos ,wCenterPoint, Weight);   
				 
				float2 origin = float2(0,0);
				float2 direction =normalize(float2(finalWpos.x, finalWpos.y)- origin  );
				finalWpos.y+=  Weight*height;
				finalWpos.x +=direction.x*Weight*height;
				finalWpos.y +=direction.y*Weight*height;
				o.pos = mul(UNITY_MATRIX_VP, finalWpos);
		
				o.color = centerPoint;
				o.uv = v.uv;
				o.normal = v.normal;
				return o;
			}

		

			float4 ps_main (v2f i) : SV_Target {
				return tex2D(testTex, i.uv);
			}
			ENDCG
		}
	}
}
