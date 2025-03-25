Shader "Unity Shaders Book/Chapter 12/12_GaussianBlur"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Stride ("Stride", float) = 1.0
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _Stride;

        struct v2f {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        v2f vertBlurVertical(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord;
            o.uv[1] = v.texcoord + float2(0.0, _MainTex_TexelSize.y * 1.0) * _Stride;
            o.uv[2] = v.texcoord - float2(0.0, _MainTex_TexelSize.y * 1.0) * _Stride;
            o.uv[3] = v.texcoord + float2(0.0, _MainTex_TexelSize.y * 2.0) * _Stride;
            o.uv[4] = v.texcoord - float2(0.0, _MainTex_TexelSize.y * 2.0) * _Stride;

            return o;
        }

        v2f vertBlurHorizontal(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv[0] = v.texcoord;
            o.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _Stride;
            o.uv[2] = v.texcoord - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _Stride;
            o.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _Stride;
            o.uv[4] = v.texcoord - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _Stride;

            return o;
        }

        fixed4 fragBlur(v2f i) : SV_Target {
            float weight[3] = {0.4026, 0.2442, 0.0545};

            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            for (int it = 1; it < 3; ++it) {
                sum += tex2D(_MainTex, i.uv[2*it-1]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[2*it]).rgb * weight[it];
            }

            return fixed4(sum, 1.0);
        }

        ENDCG

        Pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur

            ENDCG
        }
        
        Pass {
            Name "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur

            ENDCG
        }
    }
    FallBack Off
}
