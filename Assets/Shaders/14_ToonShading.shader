Shader "Unity Shaders Book/Chapter 14/14_ToonShading"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _OutlineScale("Outline Scale", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _SpecularScale ("Specular Range", Range(0, 0.1)) = 0.01
    }
    SubShader {
        // UsePass "Unity Shaders Book/Chapter 14/14_Outline/OUTLINE1"
        UsePass "Unity Shaders Book/Chapter 14/14_Outline/OUTLINE2"
        Pass {
            Tags {"LightMode"="ForwardBase"}

            Cull Back 

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            float4 _Ramp_ST;
            float _OutlineScale;
            fixed4 _OutlineColor;
            float4 _Specular;
            float _SpecularScale;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(a2v v) {
                v2f o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir = normalize(worldLightDir + worldViewDir);

                fixed4 c = tex2D(_MainTex, i.uv);
                fixed3 albedo = c.rgb * _Color.rgb;
                // _Color is used to control color tint

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                
                // add atten is too ugly???
                // UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);      
                // fixed shadow = SHADOW_ATTENUATION(i);

                fixed diff = dot(worldNormal, worldLightDir);
                diff = (diff * 0.5 + 0.5);          // half-Lambert as to sample Ramp texture
                
                fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

                fixed spec = dot(worldNormal, worldHalfDir);
                fixed w = fwidth(spec);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);
                    
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
