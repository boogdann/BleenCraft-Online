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
uniform float MaxFogDist;
uniform vec3 CameraPos;
uniform float aChanel; 
uniform bool discardMode;
uniform bool ColorMode;
uniform bool SkyMode;
uniform bool isTex2Enable;
uniform vec3 ObjColor;
uniform vec4 FogColor;

struct LightInfo {
    vec4 Position;
    vec3 Intensity;
};
uniform LightInfo lights[15];
uniform int LightsCount;

void ads( int i, vec4 LPos, vec3 LIntens, vec4 position, 
          vec3 norm, vec3 Ka, vec3 Kd, vec3 Ks, out vec3 ambDiff, out vec3 spec ) {

    vec3 s = normalize( vec3(LPos - position) );
    vec3 v = normalize(vec3(-position));
    vec3 r = reflect( -s, norm );
    
    float CandleCof = 1.5;
    if (i != 0) {
        float LightDist = abs(distance(vec3(LPos), FPosition));
        CandleCof = max(CandleRadius - LightDist, 0.0) / (CandleRadius / 5);
        if (CandleCof < 0.1) { return; }
        Ka = vec3(0.0);
        Ks = vec3(0.0);
    }

    ambDiff += CandleCof * LIntens * ( Ka + Kd * max( dot(s, norm), 0.0 ));
    spec += CandleCof * LIntens * Ks * pow( max( dot(r,v), 0.0 ), Shininess );
}


void main() {

    //Textures
    vec4 texColor = texture( Tex1, clamp(TexCoord, 0.0, 1.0) );
    if (discardMode) {
        if (texColor.x < 0.15) { discard; }
    }
    if (ColorMode) {
        texColor = vec4(ObjColor, 1.0);
    }
    if (isTex2Enable) {
        vec4 texColor2 = texture( Tex2, TexCoord );
        if ((texColor2.x > 0.0) && (texColor2.x < 0.9)) {
            texColor = texColor2;
        }
    }

    //Lightning
    vec3 ambDiff = vec3(0.0);
    vec3 spec = vec3(0.0);

    for( int i = 0; i < LightsCount; i++ )
         ads( i, lights[i].Position, lights[i].Intensity,
             eyePosition, eyeNorm, Ka, Kd, Ks, ambDiff, spec);

    vec4 resColor = (vec4(ambDiff, 1.0) * texColor + vec4(spec, 1.0)); 

    //Fog
    float dist = abs(distance(CameraPos, FPosition));
    if (SkyMode) {
        dist /= 30;
        resColor = 0.9 * texColor + vec4(spec, 1.0);
    }
    float fogFactor = (MaxFogDist - dist) / (15); //MinFogDist

    fogFactor = clamp( fogFactor, 0.0, 1.0 );
    resColor = mix( FogColor, resColor, fogFactor );

    //Result
    gl_FragColor = vec4(vec3(resColor), aChanel);
}