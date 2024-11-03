Shader "Custom/Distortion"
{
    Properties
    {
        _Noise("Noise", 2D) = "white" {}
        _StrengthFilter("Strength Filter", 2D) = "white" {}
        _Strength("Distort Strength", float) = 1.0
        _Speed("Distort Speed", float) = 1.0
    }

    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent"
            "DisableBatching" = "True"
        }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

        // Render the object with the texture generated above, and invert the colors
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            sampler2D _Noise;
            sampler2D _StrengthFilter;
            sampler2D _BackgroundTexture;
            float     _Strength;
            float     _Speed;

            struct vertexInput
            {
                float4 vertex : POSITION;
                float3 texCoord : TEXCOORD0;    
            };

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                float4 grabPos : TEXCOORD0;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                
                o.pos = UnityObjectToClipPos(v.vertex); 
                o.grabPos = ComputeGrabScreenPos(o.pos);

                // Distort based on noise & strength filter
                float noise = tex2Dlod(_Noise, float4(v.texCoord, 0)).rgb;
                float3 filt = tex2Dlod(_StrengthFilter, float4(v.texCoord, 0)).rgb;
                o.grabPos.x += cos(noise * _Time.x * _Speed) * filt * _Strength;
                o.grabPos.y += sin(noise * _Time.x * _Speed) * filt * _Strength;

                return o;
            }


            float4 frag(vertexOutput input) : COLOR
            {
                //return float4(1,1,1,1); // billboard test
                return tex2Dproj(_BackgroundTexture, input.grabPos);
            }

            ENDCG
        }

    }
}