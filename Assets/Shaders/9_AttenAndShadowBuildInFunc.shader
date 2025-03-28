// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shaders Book/Chapter 9/9_AttenAndShadow"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss("Gloss", Range(8.0, 256)) = 80
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                //  Pass shadow coordinates to pixel shader
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir = normalize(worldLightDir+worldViewDir);

                fixed3 diffuse = _LightColor0.xyz * _Diffuse * saturate(dot(worldNormal, worldLightDir));
                fixed3 specular = _LightColor0.xyz * _Specular * pow(saturate(dot(worldNormal, worldHalfDir)), _Gloss);

                // compute attenuation and also shadow!
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient+(diffuse+specular)*atten, 1.0f);
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ForwardAdd"}

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // ForwardAdd use shadow, we need _fullshadows
            #pragma multi_compile_fwdadd_fullshadows

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldNormal = normalize(i.worldNormal);

                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir = normalize(worldLightDir+worldViewDir);

                fixed3 diffuse = _LightColor0.xyz * _Diffuse * saturate(dot(worldNormal, worldLightDir));
                fixed3 specular = _LightColor0.xyz * _Specular * pow(saturate(dot(worldNormal, worldHalfDir)), _Gloss);

                // The attenuation of directional light is always 1
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient+(diffuse+specular)*atten, 1.0f);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
