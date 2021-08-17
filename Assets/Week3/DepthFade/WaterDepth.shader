Shader "Custom/Depth Fade" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _InterpCol ("_InterpCol", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = "white" {}
        _Depth ("Depth Fade", Range(-1, 3)) = 1.0
        _Fix ("Depth Distance", Range(-1, 3)) = -0.09
        _AnimSpeed("_AnimSpeed", Range(0, 3)) = 1
    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
        Cull off
        ZWrite Off
 
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
           
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"
 
            sampler2D _CameraDepthTexture;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Depth;
            float _Fix;
            float _AnimSpeed;
            float4 _Color;
            float4 _InterpCol;
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
                float4 uv : TEXCOORD0;
            	float2 uv2 : TEXCOORD1;
            };
 
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv = ComputeScreenPos (o.vertex);

                  o.uv2 = TRANSFORM_TEX(v.uv2, _MainTex);
                return o;
            }
 
            float4 frag (v2f i) : SV_Target
            { 

                float2 OffsetUv =  i.uv2+ (0, _Time.y*_AnimSpeed);
                float4 MainTexcol = tex2D(_MainTex, OffsetUv);
                float2 uv = i.uv.xy / i.uv.w;
                float lin = LinearEyeDepth (tex2D (_CameraDepthTexture, uv).r);
                float dist = i.uv.w - _Fix;
                float depth = lin - dist;
                return lerp (_InterpCol, _Color+MainTexcol, saturate (depth * _Depth));
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}