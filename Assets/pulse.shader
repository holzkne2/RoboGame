// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0,fgcg:0,fgcb:0,fgca:1,fgde:0.02,fgrn:0,fgrf:20,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-3085-OUT;n:type:ShaderForge.SFN_Distance,id:4046,x:32260,y:32650,varname:node_4046,prsc:2|A-7521-XYZ,B-3151-XYZ;n:type:ShaderForge.SFN_Transform,id:7521,x:32072,y:32482,varname:node_7521,prsc:2,tffrom:0,tfto:3|IN-5115-XYZ;n:type:ShaderForge.SFN_FragmentPosition,id:5115,x:31824,y:32472,varname:node_5115,prsc:2;n:type:ShaderForge.SFN_Vector4Property,id:389,x:31837,y:32693,ptovrint:False,ptlb:Pos,ptin:_Pos,varname:node_389,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:0,v2:0,v3:0,v4:0;n:type:ShaderForge.SFN_Transform,id:3151,x:32072,y:32707,varname:node_3151,prsc:2,tffrom:0,tfto:3|IN-389-XYZ;n:type:ShaderForge.SFN_ProjectionParameters,id:5697,x:32072,y:32914,varname:node_5697,prsc:2;n:type:ShaderForge.SFN_Multiply,id:3085,x:32417,y:32758,varname:node_3085,prsc:2|A-4046-OUT,B-5697-RFAR;proporder:389;pass:END;sub:END;*/

Shader "Shader Forge/pulse" {
    Properties {
        _Pos ("Pos", Vector) = (0,0,0,0)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _Pos;
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float node_3085 = (distance(mul( UNITY_MATRIX_V, float4(i.posWorld.rgb,0) ).xyz.rgb,mul( UNITY_MATRIX_V, float4(_Pos.rgb,0) ).xyz.rgb)*_ProjectionParams.a);
                float3 emissive = float3(node_3085,node_3085,node_3085);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
