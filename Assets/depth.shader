// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:33322,y:32753,varname:node_3138,prsc:2|emission-9094-OUT;n:type:ShaderForge.SFN_Time,id:5659,x:31632,y:32567,varname:node_5659,prsc:2;n:type:ShaderForge.SFN_Tau,id:9108,x:31616,y:32436,varname:node_9108,prsc:2;n:type:ShaderForge.SFN_Multiply,id:8082,x:31833,y:32538,varname:node_8082,prsc:2|A-9108-OUT,B-5659-T;n:type:ShaderForge.SFN_Add,id:2907,x:31835,y:32713,cmnt:ModUVs,varname:node_2907,prsc:2|A-9449-OUT,B-4407-OUT;n:type:ShaderForge.SFN_Sin,id:9667,x:32059,y:32463,varname:node_9667,prsc:2|IN-8082-OUT;n:type:ShaderForge.SFN_RemapRange,id:9449,x:32260,y:32463,cmnt:Wave,varname:node_9449,prsc:2,frmn:-1,frmx:1,tomn:0,tomx:1|IN-9667-OUT;n:type:ShaderForge.SFN_HsvToRgb,id:9094,x:32363,y:32770,cmnt:Color,varname:node_9094,prsc:2|H-3752-OUT,S-403-OUT,V-423-OUT;n:type:ShaderForge.SFN_Noise,id:3752,x:32021,y:32730,cmnt:Noise,varname:node_3752,prsc:2|XY-2907-OUT;n:type:ShaderForge.SFN_FragmentPosition,id:5086,x:31443,y:32830,varname:node_5086,prsc:2;n:type:ShaderForge.SFN_Append,id:4407,x:31634,y:32807,cmnt:UVs,varname:node_4407,prsc:2|A-5086-X,B-5086-Z;n:type:ShaderForge.SFN_Vector1,id:403,x:32171,y:32841,varname:node_403,prsc:2,v1:0.9;n:type:ShaderForge.SFN_Vector1,id:423,x:32189,y:32925,varname:node_423,prsc:2,v1:1;pass:END;sub:END;*/

Shader "Shader Forge/depth" {
    Properties {
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
                float4 node_5659 = _Time;
                float2 node_2907 = ((sin((6.28318530718*node_5659.g))*0.5+0.5)+float2(i.posWorld.r,i.posWorld.b)); // ModUVs
                float2 node_3752_skew = node_2907 + 0.2127+node_2907.x*0.3713*node_2907.y;
                float2 node_3752_rnd = 4.789*sin(489.123*(node_3752_skew));
                float node_3752 = frac(node_3752_rnd.x*node_3752_rnd.y*(1+node_3752_skew.x)); // Noise
                float3 emissive = (lerp(float3(1,1,1),saturate(3.0*abs(1.0-2.0*frac(node_3752+float3(0.0,-1.0/3.0,1.0/3.0)))-1),0.9)*1.0);
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
