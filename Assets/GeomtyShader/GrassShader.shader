// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GrassShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise("Texture", 2D) = "white" {}
		_Distortation("Texture", 2D) = "white" {}
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
			#pragma geometry geom
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

	struct v2g
	{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			float3 normal : NORMAL;
			//float3 worldPos :TEXCOORD2;
	};


			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 color : TEXCOORD1;
			
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Distortation;
			sampler2D _Noise;
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex =v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			/*	o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)).xyz;*/
				o.normal = v.normal;

				return o;
			}

			[maxvertexcount(111)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
				// here goes the real logic.
				g2f o;
				o.uv = input[0].uv;
				o.vertex = UnityObjectToClipPos( input[0].vertex);
				o.color = float3(1.,1.,1.);
				tristream.Append(o);
					o.uv = input[1].uv;
				o.vertex = UnityObjectToClipPos(input[1].vertex);
				o.color = float3(1., 1., 1.);
				tristream.Append(o);
					o.uv = input[2].uv;
				o.vertex = UnityObjectToClipPos(input[2].vertex);
				o.color = float3(1., 1., 1.);
				tristream.Append(o);
				tristream.RestartStrip();

				float3 normal = cross(input[1].vertex - input[0].vertex, input[2].vertex - input[0].vertex);

				int numberOfStacks = 36;
				float offset = 0.025f;
					for (float i = 1; i <= numberOfStacks; i++) {
						o.uv = input[0].uv;
						o.vertex = UnityObjectToClipPos( input[0].vertex + normal * offset*i);
						o.color = float(1.- i/numberOfStacks).xxx;
						tristream.Append(o);
						o.uv = input[1].uv;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.vertex = UnityObjectToClipPos(input[1].vertex + normal * offset*i);
						tristream.Append(o);
						o.uv = input[2].uv;
						o.color = float(1. - i / numberOfStacks).xxx;
						o.vertex = UnityObjectToClipPos(input[2].vertex + normal * offset*i);
						tristream.Append(o);
						tristream.RestartStrip();
				}
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
			
				float2 dis = tex2D(_Distortation,i.uv  *0.6+ _Time.xx*3.3);
				float displacementStrengh = 0.22* (((sin(_Time.y) + sin(_Time.y*0.5 + 1.051))/4.0) +0.5f);
				dis = dis * displacementStrengh*(1.0 - i.color.xx);
				fixed4 col = tex2D(_MainTex, i.uv *2.0 + dis.xy);
				float3 noise = tex2D(_Noise, i.uv *2.0 + dis.xy);
				
			if (step(col.x+noise.x*0.3, i.color.x) <= .0)discard;
			col.xyz = (1.0- i.color) * float3(0.1+(noise.x*0.25),0.7 ,0.1 );
				
			   
				return col;
			}
			ENDCG
		}

		
	}
}
