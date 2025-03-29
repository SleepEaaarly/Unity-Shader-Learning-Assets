Shader "Unity Shaders Book/Chapter 14/14_ToonShading"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _OutlineScale("Outline Scale", Range(0, 1)) = 0.1
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
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

            fixed4 _Color;
            float _OutlineScale;
            fixed4 _OutlineColor;

            struct a2v {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                return fixed4(_Color.rgb, 1.0f);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
