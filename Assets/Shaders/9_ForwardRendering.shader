// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shaders Book/Chapter 9/9_ForwardRendering"
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
            Cull Off

            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "Lighting.cginc"

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

            v2f vert (a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
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
                fixed atten = 1.0;

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

            #pragma multi_compile_fwdadd

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

            v2f vert (a2v i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float3 worldNormal = normalize(i.worldNormal);

                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
              #ifdef USING_DIRECTIONAL_LIGHT
                  //float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
              #else
                  //float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
              #endif
            
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldHalfDir = normalize(worldLightDir+worldViewDir);

                fixed3 diffuse = _LightColor0.xyz * _Diffuse * saturate(dot(worldNormal, worldLightDir));
                fixed3 specular = _LightColor0.xyz * _Specular * pow(saturate(dot(worldNormal, worldHalfDir)), _Gloss);

                // The attenuation of directional light is always 1
            #ifdef USING_DIRECTIONAL_LIGHT
                fixed atten = 1.0;
            #else
                float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1.0)).xyz;
                fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
            #endif

                return fixed4(ambient+(diffuse+specular)*atten, 1.0f);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
