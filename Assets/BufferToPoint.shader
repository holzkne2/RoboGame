Shader "Unlit/BufferToPoint"
{
	Properties{
		_Color("Color", Color) = (0.9, 0.9, 0.9, 1)
		_ScanDistance("Scan Distance", float) = 0.2
		_ScanPosition("Scan Position", Vector) = (0,0,0,0)
		_ShadowMap("Shadow Map", Cube) = "white" {}
	}
	SubShader
	{
		Pass
		{
			//ZTest Always
			//Cull Off
			//ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma target 5.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
#pragma multi_compile_fog

			uniform StructuredBuffer<float3> _position;
			uniform StructuredBuffer<float3> _normals;
			uniform fixed3 _Color;

			uniform float4x4 _world;
			uniform float4x4 _it_mv;

			uniform float _ScanDistance;
			uniform float3 _ScanPosition;

			uniform samplerCUBE _ShadowMap;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 posWorld : TEXCOORD0;
				float3 normal : NORMAL;
				float depth : DEPTH;
				UNITY_FOG_COORDS(1)
				float2 uvs : TEXCOORD2;
			};

			v2f vert(uint id : SV_VertexID)
			{
				v2f OUT;

				float4x4 mvp = mul(UNITY_MATRIX_VP, _world);
				OUT.pos = mul(mvp, float4(_position[id], 1.0));

				OUT.posWorld = mul(_world, float4(_position[id], 1.0)).xyz;

				OUT.normal = mul((float3x3)_it_mv, _normals[id]);

				return OUT;
			}

			[maxvertexcount(3)]
			void geom(point v2f input[1], inout TriangleStream<v2f> OutputStream)
			{
				const float size = 0.02;
				float3 p1 = float3(0.0, -0.5, 0.0);
				float3 p2 = float3(0.866, 0.0, 0.0);
				float3 p3 = float3(0.0, 0.5, 0.0);

				float4x4 T = float4x4(
				1, 0, 0, input[0].posWorld.x,
				0, 1, 0, input[0].posWorld.y,
				0, 0, 1, input[0].posWorld.z,
				0, 0, 0, 1
				);

				float4x4 S = float4x4(
					size, 0, 0, 0,
					0, size, 0, 0,
					0, 0, size, 0,
					0, 0, 0, 1
					);

				float3 zaxis = input[0].normal;
				float3 up = normalize(float3(1, 1, 1));
				float3 xaxis = normalize(cross(up, zaxis));
				float3 yaxis = cross(zaxis, xaxis);

				float4x4 R = {
					xaxis.x, yaxis.x, zaxis.x, 0,
					xaxis.y, yaxis.y, zaxis.y, 0,
					xaxis.z, yaxis.z, zaxis.z, 0,
					0, 0, 0, 1
				};

				float4x4 world = mul(mul(T, R), S);

				
				v2f OUT;
				float4x4 mvp = mul(UNITY_MATRIX_VP, world);
				float4x4 mv = mul(UNITY_MATRIX_V, world);

				OUT.pos = mul(mvp, float4(p1, 1.0));
				OUT.posWorld = mul(world, float4(p1, 1.0)).xyz;
				OUT.depth = -mul(mv, float4(p1, 1.0)).z * _ProjectionParams.w;
				OUT.normal = input[0].normal;
				OUT.uvs = float2(-0.6, 0);
				UNITY_TRANSFER_FOG(OUT, OUT.pos);
				OutputStream.Append(OUT);

				OUT.pos = mul(mvp, float4(p2, 1.0));
				OUT.posWorld = mul(world, float4(p2, 1.0)).xyz;
				OUT.depth = -mul(mv, float4(p2, 1.0)).z * _ProjectionParams.w;
				OUT.normal = input[0].normal;
				OUT.uvs = float2(0.5, 1.8);
				UNITY_TRANSFER_FOG(OUT, OUT.pos);
				OutputStream.Append(OUT);

				OUT.pos = mul(mvp, float4(p3, 1.0));
				OUT.posWorld = mul(world, float4(p3, 1.0)).xyz;
				OUT.depth = -mul(mv, float4(p3, 1.0)).z * _ProjectionParams.w;
				OUT.normal = input[0].normal;
				OUT.uvs = float2(1.6, 0);
				UNITY_TRANSFER_FOG(OUT, OUT.pos);
				OutputStream.Append(OUT);

			}

			float ShadowCalculation(float3 pos)
			{
				float3 toLight = pos - _ScanPosition;
					float closestDepth = texCUBE(_ShadowMap, toLight);
					float currentDepth = length(toLight) * _ProjectionParams.y;
				return currentDepth - 0.05 > closestDepth ? 1.0 : 0.0;
			}

			float4 frag(v2f IN) : COLOR
			{
				float3 N = normalize(IN.normal);
				float3 V = normalize(_WorldSpaceCameraPos.xyz - IN.posWorld.xyz);
				float3 WV = normalize(_ScanPosition.xyz - IN.posWorld.xyz);

				float4 col = float4(_Color * saturate(dot(N, V)) * saturate(dot(N, WV)), 1.0);

				float dist = distance(mul(UNITY_MATRIX_V, _ScanPosition),
					mul(UNITY_MATRIX_V, IN.posWorld)) * _ProjectionParams.w;

				float scan = 0.0;
				if (dist > _ScanDistance)
				{
					clip(-0.5);
					return float4(0.0, 0.0, 0.0, 0.0);
				}

				float shadow = ShadowCalculation(IN.posWorld);
				clip((1.0 - length((IN.uvs*2.0 + -1.0))) - 0.5);

				UNITY_APPLY_FOG(IN.fogCoord, col);
				return col;
			}
				ENDCG
		}
	}
	FallBack "Diffuse"
}