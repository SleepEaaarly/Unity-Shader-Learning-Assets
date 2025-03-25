Shader "Unity Shaders Book/Chapter 12/12_MotionBlur"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurAmount;

        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed4 fragRGB(v2f i) : SV_Target {
            return fixed4(tex2D(_MainTex, i.uv).rgb, 1 - _BlurAmount);
        }

        fixed4 fragA(v2f i) : SV_Target {
            return tex2D(_MainTex, i.uv);
        }

        ENDCG

        Pass {
            Blend SrcAlpha OneMinusSrcAlpha
            ColorMask RGB

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }

        Pass {
            Blend Off
            ColorMask A

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
    FallBack Off
}
