#version 330 core
layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texture;

uniform mat4 model;
uniform mat4 MVP;

out vec2 TexCoord;
out vec4 eyePosition;
out vec3 eyeNorm;
out vec3 FPosition;

void main() {

    TexCoord = texture;

    eyeNorm = normalize( mat3(model) * normal);
    eyePosition = model * vec4(pos,1.0);
    FPosition = vec3(eyePosition);

    gl_Position = MVP * vec4(pos,1.0);
}