    Shader "Custom/Select"
    { 
    
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _RampTex("Ramp", 2D) = "white" {}
        _IsSelected("Is Selected", Range(0, 1)) = 0
        _Color("Color", Color) = (1, 1, 1, 1)
        _OutlineExtrusion("Outline Extrusion", float) = 0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)

    }
    

    // need two passes:
    // - one for our actual objects color 
    // - one for the "outline" rendered behind the object

    SubShader
    {
    
        // Regular color pass
        Pass
        {
            // Write to Stencil buffer (so that outline pass can read)
            Stencil
            {
                Ref 4
                Comp always
                Pass replace
                ZFail keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Properties
            float4 _Color; // Color property

            struct vertexInput{
                float4 vertex : POSITION;
            };

            struct vertexOutput{
                float4 pos : SV_POSITION;
            };

            vertexOutput vert(vertexInput input){
                vertexOutput output;
                output.pos = UnityObjectToClipPos(input.vertex);
                return output;
            }

            float4 frag() : COLOR{
                return _Color;
            }

            ENDCG
        }



        
        // Outline pass
        Pass
        {
            Cull OFF
            ZWrite OFF
            ZTest ON

            // Won't draw where it sees ref value 4
            Stencil
            {
                Ref 4
                Comp notequal
                Fail keep
                Pass replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Properties
            uniform float4 _OutlineColor;
            uniform float _OutlineSize;
            uniform float _OutlineExtrusion; // Updated based on selection
            uniform float _IsSelected;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

            vertexOutput vert(vertexInput input)
            {
                vertexOutput output;
                float4 newPos = input.vertex;

                // normal extrusion technique
                float3 normal = normalize(input.normal);

                // Apply outline extrusion only if the object is selected
                newPos += float4(normal, 0.0) * _IsSelected * _OutlineExtrusion;

                // convert to world space
                output.pos = UnityObjectToClipPos(newPos);
                output.color = _OutlineColor;

                return output;
            }

            float4 frag(vertexOutput input) : COLOR
            {
                return input.color;
            }

            ENDCG
        }

    }
    }