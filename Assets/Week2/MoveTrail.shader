
Shader "MoveToTrailUV/MoveToTrailUV_Add"
{
	Properties
	{
		_MainTex("Main Texture (RGB)", 2D) = "white" {}
		_MainTexVFade("MainTex V Fade", Range(0, 1)) = 0
		_MainTexVFadePow("MainTex V Fade Pow", Float) = 1
		_MainTexPow("Main Texture Gamma", Float) = 1
		_MainTexMultiplier("Main Texture Multiplier", Float) = 1
		_TintTex("Tint Texture (RGB)", 2D) = "white" {}
		_Multiplier("Multiplier", Float) = 1
		_MainScrollSpeedU("Main Scroll U Speed", Float) = 10
		_MainScrollSpeedV("Main Scroll V Speed", Float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
			Blend One One // Additive
			ZWrite Off

			Pass
			{
				HLSLPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

				struct Attributes
				{
					float4 positionOS : POSITION;
					float2 uv : TEXCOORD0;
					float4 color : COLOR;
				};

				struct Varyings
				{
					float2 uv : TEXCOORD0;
					float2 uvOrigin : TEXCOORD1; 
					float4 positionHCS : SV_POSITION;
					float4 color : COLOR;
				};

				sampler2D _MainTex;
				sampler2D _TintTex;

				CBUFFER_START(UnityPerMaterial)
					float4 _MainTex_ST;
					float _MainTexVFade;
					float _MainTexVFadePow;
					float _MainTexPow;
					float _MainTexMultiplier;
					float _Multiplier;
					float _MainScrollSpeedU;
					float _MainScrollSpeedV;
					
					
					float _MoveToMaterialUV;
				CBUFFER_END

				Varyings vert(Attributes IN)
				{
					Varyings o;
					o.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
					o.uv = TRANSFORM_TEX(IN.uv, _MainTex);
					o.uv.x -= frac(_Time.x * _MainScrollSpeedU) + _MoveToMaterialUV;
					o.uv.y -= frac(_Time.x * _MainScrollSpeedV);
					o.uvOrigin = IN.uv;
					o.color = IN.color;
					return o;
				}

				float4 frag(Varyings IN) : SV_Target
				{
					float4 mainTex = tex2D(_MainTex, IN.uv);

				
					float vFade = 1 - abs(IN.uvOrigin.y - 0.5) * 2; 
					vFade = pow(abs(vFade), _MainTexVFadePow); 
					vFade = lerp(1, vFade, _MainTexVFade);
					mainTex.rgb *= vFade; 
					mainTex.rgb = pow(abs(mainTex.rgb), _MainTexPow) * _MainTexMultiplier; 
					
					
					float intensity = _Multiplier * IN.color.a;

					// Tint
					float avr = mainTex.r * 0.3333 + mainTex.g * 0.3334 + mainTex.b * 0.3333;
					avr = saturate(avr * intensity); 
					float4 col = tex2D(_TintTex, float2(avr, 0.5));

					float intensityHigh = max(1, intensity); 
					col.rgb *= intensityHigh * IN.color.rgb;
					return col;
				}
				ENDHLSL
			}
		}
}
