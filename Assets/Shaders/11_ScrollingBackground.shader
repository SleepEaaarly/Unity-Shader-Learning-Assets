Shader "Unity Shaders Book/Chapter 11/ScrollingBackground"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base Layer", 2D) = "white" {}
        _DetailTex ("2nd Layer", 2D) = "white" {}
        _ScrollX("Base Layer Scroll Speed", Float) = 1.0
        _Scroll2X("2nd Layer Scroll Speed", Float) = 1.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;


            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + (float2(_ScrollX, 0.0f) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + (float2(_Scroll2X, 0.0f) * _Time.y);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 dstColor = tex2D(_MainTex, i.uv.xy);
                fixed4 srcColor = tex2D(_DetailTex, i.uv.zw);

                // scrColor * a + dstColor * (1-a)
                fixed4 color = lerp(dstColor, srcColor, srcColor.a);
                color.rgb *= _Color;

                return color;
            }
            ENDCG
        }
    }
    FallBack "Transparent/VertexLit"
}
