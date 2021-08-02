Shader "Unlit/DissolveMultipleMaskUnlitShader"
{
    Properties
    {
        _FirstTex ("Texture1", 2D) = "white" {}
        _SecondTex("Texture2", 2D) = "white" {}
        _NoiseTex("NoiseTex", 2D) = "white" {}
        _SecondNoiseTex("NoiseTex2", 2D) = "white" {}
        _ThirdNoiseTex("NoiseTex3", 2D) = "white" {}
        _LerpAmount("Dissolve Amount", Range(0.0, 1.0)) = 0.0
        _LineWidth("Amount Width", Range(0.0, 0.2)) = 0.1
        _FirstColor("First Color", Color) = (1, 0, 0, 1) // Flame edge color value
        _SecondColor("Second Color", Color) = (1, 0, 0, 1)
        _EdgeWidth("EdgeWidth", Range(0.0, 0.5)) = 0.0
        _EdgeSoftness("EdgeSoftness", Range(-1, 1  )) = 0.0
        _Glow("_Glow", Range(-100, 100)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uvFirstTex : TEXCOORD0;
                float2 uvSecondTex : TEXCOORD1;
                float2 uvNoiseTex : TEXCOORD2;
                float2 uvSecondNoiseTex: TEXCOORD3;
                float2 uvThirdNoiseTex: TEXCOORD4;
            };

            struct v2f
            {
                float2 uvFirstTex : TEXCOORD0;
                float2 uvSecondTex : TEXCOORD1;
                float2 uvNoiseTex : TEXCOORD2;
                float2 uvSecondNoiseTex: TEXCOORD3;
                float2 uvThirdNoiseTex: TEXCOORD4;
                float4 vertex : SV_POSITION;
            };

            sampler2D _FirstTex;
            float4 _FirstTex_ST;
            sampler2D _SecondTex;
            float4 _SecondTex_ST;
            sampler2D _NoiseTex;
            sampler2D _SecondNoiseTex;
            sampler2D _ThirdNoiseTex;
            float4 _NoiseTex_ST;
            float4 _SecondNoiseTex_ST;
            float4 _ThirdNoiseTex_ST;
            float _LerpAmount;
            float _LineWidth;
            fixed _EdgeWidth;
            half _Glow;
            fixed _EdgeSoftness;
            fixed3 _FirstColor;
            fixed3 _SecondColor;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uvFirstTex = TRANSFORM_TEX(v.uvFirstTex, _FirstTex);
                o.uvSecondTex = TRANSFORM_TEX(v.uvSecondTex, _SecondTex);
                o.uvNoiseTex = TRANSFORM_TEX(v.uvNoiseTex, _NoiseTex);
                o.uvSecondNoiseTex = TRANSFORM_TEX(v.uvSecondNoiseTex, _SecondNoiseTex);
                o.uvThirdNoiseTex = TRANSFORM_TEX(v.uvThirdNoiseTex, _ThirdNoiseTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                fixed3 noiseCol = tex2D(_NoiseTex, i.uvNoiseTex).rgb;
                              
                                 
                fixed3 secondNoiseCol = tex2D(_SecondNoiseTex, i.uvSecondNoiseTex).rgb;
             //    noiseCol = pow(noiseCol, 10); // should this move to vertex shader?
                fixed Maskr= (noiseCol.r +secondNoiseCol.r)*0.5;
                  clip(Maskr-_LerpAmount); // if less than0, The pixel will be removed
                  //fixed Maskr=secondNoiseCol.r ;
          
                fixed Alpha = 1 - smoothstep(0.0, 1 , Maskr - _LerpAmount);//0.6
              //  fixed Alpha = step(0.0001, Maskr - _LerpAmount);
        
            //_LineWidth width range simulates gradient. t is0Is the normal color, for1At the boundary of ablation
            fixed t = 1 - smoothstep(0.0, _EdgeWidth, Maskr - _LerpAmount);
                     
             fixed3 FirstTexcol = tex2D(_FirstTex, i.uvFirstTex).rgb;
            fixed3 finalCol = lerp(FirstTexcol*_Glow, _FirstColor*_Glow, t );

                //fixed MinEdgeRange = clamp (0.5- _EdgeWidth,0,0.5 );//0.2
                //fixed MaxEdgeRange = clamp(0.5 + _EdgeWidth , 0.5, 1);//0.8

                               
           
                // fixed FirstAlpha = step(MinEdgeRange , Alpha);
                //fixed FirstSmoothAlpha = smoothstep(0, MinEdgeRange, Alpha+ _EdgeSoftness);
                //fixed FinalFirstAlpha = lerp(FirstAlpha, FirstSmoothAlpha, step(FirstAlpha,0.5 ));
                
                //fixed3 finalCol = lerp(FirstTexcol, _FirstColor*_Glow, FinalFirstAlpha);//first  if (a<0.5 && a >=0.2)
              
             
               // fixed3 finalCol = lerp(Firstcol, Secondcol, Alpha * step(0.0001, _LerpAmount));
                return fixed4(finalCol, 1);
            }
            ENDCG
        }
    }
}
