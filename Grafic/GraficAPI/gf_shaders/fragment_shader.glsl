#version 330 core

in vec2 TexCoord;
in vec4 eyePosition;
in vec3 eyeNorm;
in vec3 FPosition;

layout(binding=0) uniform sampler2D Tex1;
layout(binding=1) uniform sampler2D Tex2;
uniform vec3 Kd;
uniform vec3 Ka;
uniform vec3 Ks;
uniform float Shininess;
uniform float CandleRadius;
uniform vec3 CameraPos;
uniform float aChanel; 
uniform bool discardMode;
uniform bool ColorMode;
uniform bool SkyMode;
uniform bool isTex2Enable;
uniform vec3 ObjColor;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};
uniform LightInfo lights[257];
uniform int LightsCount;

void ads( int i, vec4 LPos, vec3 LIntens, vec4 position, 
          vec3 norm, out vec3 ambDiff, out vec3 spec, vec3 Ka, vec3 Kd, vec3 Ks ) {

    vec3 s = normalize( vec3(LPos - position) );
    vec3 v = normalize(vec3(-position));
    vec3 r = reflect( -s, norm );
    
    float CandleCof = 1.5;
    if (i != 0) {
        float LightDist = abs(distance(vec3(LPos), FPosition));
        CandleCof = max(CandleRadius - LightDist, 0.0) / (CandleRadius / 5);
        Ka = vec3(0.0, 0.0, 0.0);
        Ks = vec3(0.0, 0.0, 0.0);
    }

    ambDiff += CandleCof * LIntens * ( Ka + Kd * max( dot(s, norm), 0.0 ));
    spec += CandleCof * LIntens * Ks * pow( max( dot(r,v), 0.0 ), Shininess );
}


void main() {
    vec4 texColor = texture( Tex1, TexCoord );
    if (isTex2Enable) {
        vec4 texColor2 = texture( Tex2, TexCoord );
        if ((texColor2.x > 0.0) && (texColor2.x < 0.9)) {
            texColor = texColor2;
        }
    }
    
    if (ColorMode) {
        texColor = vec4(ObjColor, 1.0);
    }
    if (discardMode && (texColor == vec4(1.0, 1.0, 1.0, 1.0))) {
        discard;//
    }

    float dist = abs(distance(CameraPos, FPosition));
    vec3 ambDiff = vec3(0.0);
    vec3 spec = vec3(0.0);
    for( int i = 0; i < LightsCount; i++ )
         ads( i, lights[i].Position, lights[i].Intensity,
             eyePosition, eyeNorm, ambDiff, spec, Ka, Kd, Ks);

    vec4 resColor = (vec4(ambDiff, 1.0) * texColor + vec4(spec, 1.0)); 

    //Fog
    float MaxFogDist = 250;
    float MinFogDist = 50;

    vec4 FogColor = vec4(0.2, 0.2, 0.2, 1.0);
    float fogFactor = (MaxFogDist - dist) / (MaxFogDist - MinFogDist);

    if (SkyMode) {
        fogFactor *= 130;
        resColor = 0.9 * texColor + vec4(spec, 1.0);
    }
    fogFactor = clamp( fogFactor, 0.0, 1.0 );
    resColor = mix( FogColor, resColor, fogFactor );

    gl_FragColor = vec4(vec3(resColor), aChanel);
}