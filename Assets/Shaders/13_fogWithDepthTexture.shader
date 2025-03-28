Shader "Unity Shaders Book/Chapter 13/13_fogWithDepthTexture"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        sampler2D _CameraDepthTexture;

        half4 _MainTex_TexelSize;
        float4x4 _FrustumCornersRay;
        float _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;

        struct v2f {
            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;
            float3 interpolatedRay : TEXCOORD1;
        };

        v2f vert(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv.w = 1 - o.uv.w;
            #endif
            
            int index = 0;
            if (v.texcoord.x < 0.5 && v.texcoord.y < 0.5) {
                index = 0;
            } else if (v.texcoord.x > 0.5 && v.texcoord.y < 0.5) {
                index = 1;    
            } else if (v.texcoord.x > 0.5 && v.texcoord.y > 0.5) {
                index = 2;
            } else {
                index = 3;
            }

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0) 
                index = 3 - index;
            #endif

            o.interpolatedRay = _FrustumCornersRay[index].xyz;

            return o;
        }

        fixed4 frag(v2f i) : SV_Target {
            float linearDepthView = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.zw));
            float3 worldPos = _WorldSpaceCameraPos + linearDepthView * i.interpolatedRay;

            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity);

            fixed4 c = tex2D(_MainTex, i.uv.xy);
            c.rgb = lerp(c.rgb, _FogColor.rgb, fogDensity);

            return c;
        }

        ENDCG

        Pass {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
    FallBack Off
}
