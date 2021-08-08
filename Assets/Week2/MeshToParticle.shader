Shader "Unlit/MeshToParticle"
{
 Properties
 {
  _MainTex ("Texture", 2D) = "white" {}
  _Color ("Color", Color) = (1,1,1,1)
  _Factor ("Factor", Float) = 2.0

  _Ramp ("Ramp", Range(0,1)) = 0
  _Size ("Size", Float) = 1.0
  _Spread ("Random Spread", Float) = 1.0
  _Frequency ("Noise Frequency", Float) = 1.0
  _Motion ("Motion Distance", Float) = 1.0

  _InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
 }

 SubShader
 {
  Tags { "Queue"="Transparent" "RenderType"="Transparent"}
  Blend One OneMinusSrcAlpha
  ColorMask RGB
  Cull Off Lighting Off ZWrite Off
  LOD 100

  Pass
  {
   CGPROGRAM
   #pragma vertex vert
   #pragma geometry geom
   #pragma fragment frag
   #pragma target 4.0
   #pragma multi_compile_particles
     	#include "UnityCG.cginc"

   sampler2D _MainTex;
   float4 _MainTex_ST;
   float4 _Color;
   float _Factor;

   float _Ramp;
   float _Size;
   float _Frequency;
   float _Spread;
   float _Motion;

   sampler2D_float _CameraDepthTexture;
   float _InvFade;

   
   // data coming from unity
   struct appdata
   {
    float4 vertex : POSITION;
    float4 texcoord : TEXCOORD0;
    fixed4 color : COLOR;
   };

      // vertex shader mostly just passes information to the geometry shader
   appdata vert (appdata v)
   {
    appdata o;

    // change the position to world space
    float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
    o.vertex = float4(worldPos,1);

    // pass these through unchanged
    o.texcoord = v.texcoord;
    o.color = v.color;

    return o;
   }
      // information that will be sent to the pixel shader
   struct v2f {
    float4 vertex : SV_POSITION;
    fixed4 color : COLOR;
    float2 texcoord : TEXCOORD0;
    #ifdef SOFTPARTICLES_ON
     float4 projPos : TEXCOORD1;
    #endif
   };


    // geometry vertex function
   // this will all get called in geometry shader
   // its nice to keep this stuff in its own function
   v2f geomVert (appdata v)
   {
    v2f o;
    o.vertex = UnityWorldToClipPos(v.vertex.xyz);
    o.color = v.color;
    o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
    #ifdef SOFTPARTICLES_ON
     o.projPos = ComputeScreenPos (o.vertex);
     // since the vertex is already in world space we need to 
     // skip some of the stuff in the COMPUTE_EYEDEPTH funciton
     // COMPUTE_EYEDEPTH(o.projPos.z);
     o.projPos.z = -mul(UNITY_MATRIX_V, v.vertex).z;
    #endif

    return o;
   }


      // geometry shader
   [maxvertexcount(4)]
   void geom(triangle appdata input[3], inout TriangleStream stream )
   {
    // get the values for the centers of the triangle
    float3 pointPosWorld = (input[0].vertex.xyz + input[1].vertex.xyz + input[2].vertex.xyz ) * 0.3333333;
    float4 pointColor = (input[0].color + input[1].color + input[2].color ) * 0.3333333;
    float4 uv = (input[0].texcoord + input[1].texcoord + input[2].texcoord ) * 0.3333333;
// lifetime based on tiling and ramp parameters
    half lifeTime = saturate( uv.x + lerp( -1.0, 1.0, _Ramp ) );

    // fade particle on and off based on lifetime
    float fade = smoothstep( 0.0, 0.1, lifeTime);
    fade *= 1.0 - smoothstep( 0.1, 1.0, lifeTime);

    // don't draw invisible particles
    if( fade == 0.0 ){
     return;
    }

    // multiply color alpha by fade value
    pointColor.w *= fade;

    
    // random number seed from uv coords
    float3 seed = float3( uv.x + 0.3 + uv.y * 2.3, uv.x + 0.6 + uv.y * 3.1, uv.x + 0.9 + uv.y * 9.7 );
    // random number per particle based on seed
    float3 random3 = frac( sin( dot( seed * float3(138.215, 547.756, 318.269), float3(167.214, 531.148, 671.248) ) * float3(158.321,456.298,725.681) ) * float3(158.321,456.298,725.681) );
    // random direction from random number
    float3 randomDir = normalize( random3 - 0.5 );

    
    // curl-ish noise for making the particles move in an interesting way
    float3 noise3x = float3( uv.x, uv.x + 2.3, uv.x + 5.7 ) * _Frequency;
    float3 noise3y = float3( uv.y + 7.3, uv.y + 9.7, uv.y + 12.3 ) * _Frequency;
    float3 noiseDir = sin(noise3x.yzx * 5.731 ) * sin( noise3x.zxy * 3.756 ) * sin( noise3x.xyz * 2.786 );
    noiseDir += sin(noise3y.yzx * 7.731 ) * sin( noise3y.zxy * 5.756 ) * sin( noise3y.xyz * 3.786 );

      // add the random direction and the curl direction to the world position
    pointPosWorld += randomDir * lifeTime * _Motion * _Spread;
    pointPosWorld += noiseDir * lifeTime * _Motion;

    
    // the up and left camera direction for making the camera facing particle quad
    float3 camUp = UNITY_MATRIX_V[1].xyz * _Size * 0.5;
    float3 camLeft = UNITY_MATRIX_V[0].xyz * _Size * 0.5;

    // v1-----v2
    // |     / |
    // |    /  |
    // |   C   |
    // |  /    |
    // | /     |
    // v3-----v4

    float3 v1 = pointPosWorld + camUp + camLeft;
    float3 v2 = pointPosWorld + camUp - camLeft;
    float3 v3 = pointPosWorld - camUp + camLeft;
    float3 v4 = pointPosWorld - camUp - camLeft;

      // send information for each vertex to the geomVert function

    appdata vertIN;
    vertIN.color = pointColor;

    vertIN.vertex = float4(v1,1);
    vertIN.texcoord.xy = float2(0,1);
    stream.Append( geomVert(vertIN) );

    vertIN.vertex = float4(v2,1);
    vertIN.texcoord.xy  = float2(1,1);
    stream.Append( geomVert(vertIN) );

    vertIN.vertex = float4(v3,1);
    vertIN.texcoord.xy  = float2(0,0);
    stream.Append( geomVert(vertIN) );

    vertIN.vertex = float4(v4,1);
    vertIN.texcoord.xy  = float2(1,0);
    stream.Append( geomVert(vertIN) );

   }


      // simple particle like pixel shader
   fixed4 frag (v2f IN) : SV_Target
   {
    #ifdef SOFTPARTICLES_ON
     float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)));
     float partZ = IN.projPos.z;
     IN.color.w *= saturate (_InvFade * (sceneZ-partZ));
    #endif

    // sample the texture
    fixed4 col = tex2D(_MainTex, IN.texcoord);
    col *= _Color;
    col *= IN.color;
    col.xyz *= _Factor;

    // premultiplied alpha
    col.xyz *= col.w;

    return col;
   }
      ENDCG
  }
  }
}
