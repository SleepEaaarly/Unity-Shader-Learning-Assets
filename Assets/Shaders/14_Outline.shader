// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 14/14_Outline"
{
	Properties {
		_OutlineScale("Outline Scale", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
	}

	SubShader {
		
		Cull Front

		CGINCLUDE
		
		float _OutlineScale;
		fixed4 _OutlineColor;

		struct a2v_1 {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		struct a2v_2 {
			float4 vertex : POSITION;
		};

		struct v2f {
			float4 pos : SV_POSITION;
		};

		v2f vert1(a2v_1 v) {
			v2f o;
			float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
			float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			normal.z = -0.5;
			pos = pos + float4(normalize(normal), 0) * _OutlineScale;
			o.pos = mul(UNITY_MATRIX_P, pos);

			return o;
		}
		
		v2f vert2(a2v_2 v) {
			v2f o;
			o.pos = UnityObjectToClipPos(float4(v.vertex.xyz * (1.0f + _OutlineScale), 1.0f));

			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			return fixed4(_OutlineColor.rgb, 1.0f);
		}

		ENDCG

		Pass {
			Name "OUTLINE1"
			CGPROGRAM
			// #pragma enable_d3d11_debug_symbols
			#pragma vertex vert1
			#pragma fragment frag			
			ENDCG
		}

		Pass {
			Name "OUTLINE2"
			CGPROGRAM
			// #pragma enable_d3d11_debug_symbols
			#pragma vertex vert2
			#pragma fragment frag			
			ENDCG
		}
	}
	FallBack Off
}
