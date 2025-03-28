Shader "Unity Shaders Book/Chapter 6/6_BlinnPhongShader"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
       	_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass {
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "Lighting.cginc"

				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 worldNormal : TEXCOORD0;
					fixed4 worldPos : TEXCOORD1;
				};

				v2f vert(a2v i) {
					v2f o;
					o.pos = UnityObjectToClipPos(i.vertex);

					// o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));
					o.worldNormal = UnityObjectToWorldNormal(i.normal);

					o.worldPos = mul(unity_ObjectToWorld, i.vertex);
					
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET0 {
					fixed3 worldNormal = normalize(i.worldNormal);
					// fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
					// fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 halfDir = normalize(viewDir + worldLightDir);
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
					
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

					return fixed4(ambient+diffuse+specular, 1.0);
				}

			ENDCG
		}
    }
	FallBack "Specular"
}
