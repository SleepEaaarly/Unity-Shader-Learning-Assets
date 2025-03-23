Shader "Unity Shaders Book/Chapter 12/12_EdgeDetection"
{
    Properties{
        _MainTex ("Base (RGB)", 2D) = "white" {}
		// _EdgeOnly ("Edge Only", Float) = 1.0
		// _EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		// _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
	}
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                return o;
            }

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                const half Gx[3][3] = {-1,-2,-1,0,0,0,1,2,1};
                const half Gy[3][3] = {-1,0,1,-2,0,2,-1,0,1};

                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for (int row = -1; row <= 1; ++row) {
                    for (int col = -1; col <= 1; ++col) {
                        half2 uv = i.uv + half2(row, col) * _MainTex_TexelSize.xy;
                        texColor = luminance(tex2D(_MainTex, uv));
                        edgeX += texColor * Gx[row+1][col+1];
                        edgeY += texColor * Gy[row+1][col+1];
                    }
                }
                // grad of edge
                half edge = abs(edgeX) + abs(edgeY);

                fixed4 withEdgeColor = lerp(tex2D(_MainTex, i.uv), _EdgeColor, edge);
                fixed4 onlyEdgeColor = lerp(_BackgroundColor, _EdgeColor, edge);
                // return fixed4(edge, edge, edge, 1.0);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }

            ENDCG
        }
    }
    FallBack Off
}
