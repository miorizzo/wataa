﻿Shader "Unlit/BlendSprites"
{
    Properties
    {
        _MainTex ("FrontFace", 2D) = "white" {}
		_BackTex ("BackFace", 2D) = "white" {}
		[HideInInspector]_MaskTex ("Mask", 2D) = "white" {}
	}
	SubShader
    {
		Cull Off

        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			sampler2D _BackTex;
			sampler2D _MaskTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = lerp( tex2D(_MainTex, i.uv), tex2D(_BackTex, i.uv), 1-tex2D(_MaskTex, i.uv).r);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
