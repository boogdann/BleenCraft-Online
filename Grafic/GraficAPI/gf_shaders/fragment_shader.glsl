#version 330 core

in vec2 TexCoord;

uniform sampler2D Tex1;

void main() {
    vec4 texColor = texture( Tex1, TexCoord );
    gl_FragColor = vec4(0.4, 0.3, 0.2, 1.0) * texColor;
}