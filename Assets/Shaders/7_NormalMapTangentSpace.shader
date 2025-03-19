Shader "Unity Shaders Book/Chapter 7/Normal Map In World Space"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    } 
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;          // xy is texcoord, zw is normtexcoord
                float4 TtoW0: TEXCOORD1;
                float4 TtoW1: TEXCOORD2;
                float4 TtoW2: TEXCOORD3;
            };

            v2f vert(a2v i) {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);

                o.uv.xy = TRANSFORM_TEX(i.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(i.texcoord, _BumpMap);

                float3 worldNormal = normalize(UnityObjectToWorldNormal(i.normal));
                float3 worldTangent = normalize(UnityObjectToWorldDir(i.tangent));
                float3 worldBinormal = normalize(cross(worldNormal, worldTangent) * i.tangent.w);

                float3 worldPos = mul(unity_ObjectToWorld, i.vertex).xyz;
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET0 {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump.xy = bump.xy * _BumpScale;
                bump.z = sqrt(1 - dot(bump.xy, bump.xy));
                fixed3 worldNormal = fixed3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump));


                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                fixed3 halfDir = normalize(worldLightDir+worldViewDir);
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}