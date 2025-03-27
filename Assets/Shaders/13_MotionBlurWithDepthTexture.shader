Shader "Unity Shaders Book/Chapter 13/13_MotionBlurWithDepthTexture"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurSize ("Blur Size", float) = 1.0
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _CurrentViewProjectionInverseMatrix;
        float4x4 _PreviousViewProjectionMatrix;
        half _BlurSize;

        struct v2f {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };

        v2f vert(appdata_img v) {
            v2f o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;

            #if UNITY_UV_STARTS_AT_TOP
            if (_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif

            return o;
        }

        fixed4 frag(v2f i) : SV_Target {
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            float4 ndc_pos = float4(2 * i.uv.x - 1, 2 * i.uv.y - 1, 2 * d - 1, 1.0f);
            float4 world_pos = mul(_CurrentViewProjectionInverseMatrix, ndc_pos);
            world_pos /= world_pos.w;

            
            float4 pre_pos = mul(_PreviousViewProjectionMatrix, world_pos);
            pre_pos /= pre_pos.w;
            float4 cur_pos = ndc_pos;

            float2 velocity = (cur_pos.xy - pre_pos.xy) / 2.0f;
            fixed4 c = tex2D(_MainTex, i.uv);
            float2 uv = i.uv + velocity * _BlurSize;
            for (int it = 1; it < 3; uv += velocity * _BlurSize, it++) {
                c += tex2D(_MainTex, uv);

            }
            c /= 3;
            return fixed4(c.rgb, 1.0f);
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
