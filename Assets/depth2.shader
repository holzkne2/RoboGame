// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/BufferToPoint"
{
	SubShader
	{
		Pass
		{
			Fog{ Mode off }

			CGPROGRAM
#include "UnityCG.cginc"
#pragma target 5.0
#pragma vertex vert
#pragma fragment frag

			uniform sampler2D _CameraDepthTexture;
			float4x4 _world;

			struct VertexInput {
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4  pos : SV_POSITION;
				float3 depth : TEXCOORD2;
			};

			v2f vert(VertexInput v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float4x4 mv = mul(UNITY_MATRIX_V, unity_ObjectToWorld);
					o.depth = -mul(mv, v.vertex);
				return o;
			}

			float4 frag(v2f IN) : COLOR
			{

				return float4(IN.depth, 1.0);
			}
				ENDCG
		}
	}
}