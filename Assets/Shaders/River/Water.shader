Shader "Custom/Water"
{
    Properties
    {
        _LowColor("low lava", Color) = (1,1,1,1)
        _MidColor("mid lava", Color) = (1,1,1,1)
        _HighColor("high lava", Color) = (1, 1, 1, 1)
        
        _SpeedX("X Speed", Range(-100, 100 )) = 100
        _SpeedZ("Z Speed", Range(-100, 100 )) = 100
        _SpeedXZ("XZ Speed", Range(-100, 100 )) = 100
                
        _FrequencyX("X Wave Frequency", Range(0, 10)) = 5        
        _FrequencyZ("Z Wave Frequency", Range(0, 10)) = 5
        _FrequencyXZ("XZ Wave Frequency", Range(0, 10)) = 5

        _AmplitudeX("X Amplitude", Range(0,1)) = 0.2
        _AmplitudeZ("Z Amplitude", Range(0,1)) = 0.2
        _AmplitudeXZ("XZ Amplitude", Range(0,1)) = 0.1

        _BubbleTexture("Bubble Texture", 2D) = "white" {}

    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" }
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _LowColor;
            float4 _MidColor;
            float4 _HighColor;
            
            float _SpeedX;
            float _SpeedZ;
            float _SpeedXZ;
            
            float _FrequencyX;
            float _FrequencyZ;
            float _FrequencyXZ;

            float _AmplitudeX;
            float _AmplitudeZ; 
            float _AmplitudeXZ; 

            sampler2D _BubbleTexture;
            
            
            // Input structure for vertex shader
            struct vertexInput {
                float4 vertex : POSITION;
            };

            // Output structure for vertex shader
            struct vertexOutput {
                float4 pos : SV_POSITION;
                float amp : TEXCOORD0; 
            };

            vertexOutput vert(vertexInput v) {
                vertexOutput o;
                o.pos = v.vertex;


                // // old implementation
                // float displacementX = (cos(o.pos.y* _FrequencyX) + cos(o.pos.x* _FrequencyX + (_SpeedX * _Time)));
                // float displacementZ = (cos(o.pos.y* _FrequencyZ) + cos(o.pos.z* _FrequencyZ + (_SpeedZ * _Time)));
                // float displacementXZ = (cos(o.pos.y* _FrequencyX) + cos(o.pos.x* _FrequencyXZ + (_SpeedXZ * _Time)) + cos(o.pos.z* _FrequencyXZ + (_SpeedXZ * _Time)));

                // // offset position by variable displacement and amplitude of each wave
                // o.pos.y += ((displacementX * _AmplitudeX) + (displacementZ * _AmplitudeZ) + (displacementXZ * _AmplitudeXZ));



                // Calculate your custom wave displacement equations
                float deltaX = cos(o.pos.x * _FrequencyX + _SpeedX * _Time) + o.pos.x;
                float deltaY = sin(deltaX);

                // Add more waves with different frequencies and directions
                float deltaX2 = cos(o.pos.z * _FrequencyZ + _SpeedZ * _Time) + o.pos.z;
                float deltaY2 = sin(deltaX2);

                float deltaX3 = (cos(o.pos.x * _FrequencyXZ + _SpeedXZ * _Time) + o.pos.x + cos(o.pos.z * _FrequencyXZ + _SpeedXZ * _Time) + o.pos.z) / 2;
                float deltaY3 = sin(deltaX3);

                // Offset the position by the wave displacement
                o.pos.x += deltaX + deltaX3;
                o.pos.z += deltaX2 + deltaX3;
                o.pos.y += ((deltaY * _AmplitudeX) + (deltaY2 * _AmplitudeZ) + (deltaY3 * _AmplitudeXZ));
                
                // Calculate amp for colour value, based Y position.
                o.amp = ((o.pos.y + 1) / 2); 
                
                // Transform to clip space.
                o.pos = UnityObjectToClipPos(o.pos);

                return o;
            };

            

            float4 frag(vertexOutput IN) : COLOR {
                fixed4 bubbleColor = tex2D(_BubbleTexture, IN.amp);

                fixed4 col;
                if (IN.amp < 0.35) {
                    col = _LowColor;
                } 
                else if (IN.amp >= 0.35 && IN.amp < 0.5) {
                    col = _MidColor;
                } 
                else {
                    col = _HighColor;
                }

                //col = lerp(_LowColor, _MidColor, bubbleColor.r);
                col.a = lerp(col.a, 0.0, bubbleColor.r);

                return col;
            }

            ENDCG
        }
       
    }
}
